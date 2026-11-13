;;; objects.law's driver (check/laws/objects.law): a program's operations, one a line on stdin with its code first, run
;;; through ir2's object level on the kernel's objects (kernel-objects.k) and two of its own, printing what each reads.
;;; check.l's law_objects compiles it after maru-gc.k (less its main) and kernel.k, through C under ASan; its argument is
;;; gc_frequency.  New memory is filled with the sentinel byte (gc_poison), so a field nothing wrote reads S.
;;;   1 s t        new: slot s gets (new <t>)
;;;   2 s t a b    make: slot s gets what t's kernel constructor makes of a and b
;;;   3 s f v      set: the unchecked accessor of slot s's own type writes field f (mod the writable fields)
;;;   4 s f        look: the unchecked accessor of slot s's own type reads field f (mod its fields), or - for none (an
;;;                immediate integer has none, and set leaves it alone)
;;;   5 s t f      get: (get <t> field slot), its type checked; prints "F t actual" first on a mismatch
;;;   6 s t f v    put: (put <t> field slot value), the same, and refused for an immediate
;;;   7 s          type: (object-type slot)
;;;   8            collect
;;; A written value is an object (v mod 5 names slot 0 to 3, or nil) for an oop field, or v * 64 + the line, so no
;;; two writes agree.  check/laws/objects-model.l prints what each should print, by the same rules.

(define-object <knot>	13 ((value long) (next oop) (count int)))
(define-object <pixel>	14 ((r int) (g int) (x double)) atom)

(define (scanf	(int char * ...)	*)	(extern scanf))
(define (atol	(long char *)		*)	(extern atol))

(define-constant objects_poison		-6510615555426900571)	; 0xa5a5a5a5a5a5a5a5: gc_poison's byte in every byte of a word
(define-constant objects_poison_int	-1515870811)		; and of an int

(define (slots oop *) 0)

;; (field-cases mode t f x v line otherwise): for type t's field f (mod its fields, or its writable fields for put and set),
;; what mode does with object x: get or look shows the field, through get or the unchecked accessor; put or set writes
;; the value v makes, through put or the accessor.  otherwise, for a type with no fields, or ()
(define-form field-cases (mode t f x v line otherwise)
  (let ((types ())
	;; each type with fields, and its fields' kinds: oop (traced), long, int, double, or ptr (a C pointer, never written)
	(rows '((2 <long> (bits long)) (3 <double> (bits double)) (4 <string> (size oop) (bits ptr)) (5 <symbol> (bits ptr) (flags int))
	       (6 <pair> (head oop) (tail oop) (source oop)) (8 <array> (size oop) (_array oop))
	       (9 <expr> (name oop) (definition oop) (environment oop) (profile oop)) (10 <form> (function oop) (symbol oop))
	       (11 <fixed> (function oop)) (12 <subr> (name ptr) (imp ptr) (sig ptr) (profile int))
	       (13 <knot> (value long) (next oop) (count int)) (14 <pixel> (r int) (g int) (x double)))))
    (list-do row rows
      (let ((type (cadr row)) (fields ()) (k 0) (cases ()))
	(list-do fd (cddr row) (or (and (or (= mode 'put) (= mode 'set)) (= 'ptr (cadr fd))) (push fields fd)))
	(set k (list-length fields))
	(list-do fd fields
	  (set k (- k 1))
	  (let* ((name  (car fd))
		 (kind  (cadr fd))
		 (raw   `(,(concat-symbols type '- name) ,x))
		 (value (cond ((= kind 'oop)	`(slot_ref ,v))
			      ((= kind 'int)	`(cast (+ (* ,v 64) ,line) int))
			      ((= kind 'double)	`(cast (+ (* ,v 64) ,line) double))
			      (else		`(+ (* ,v 64) ,line))))
		 (show  (lambda (e)
			  (cond ((= kind 'oop)		`(show_oop ,e))
				((= kind 'long)		`(show_long ,e))
				((= kind 'int)		`(show_int ,e))
				((= kind 'double)	`(show_double ,e))
				(else			`(show_ptr (cast ,e long))))))
		 (act   (cond ((= mode 'get)	(show `(get ,type ,name ,x)))
			      ((= mode 'look)	(show raw))
			      ((= mode 'put)	`(put ,type ,name ,x ,value))
			      (else		`(set ,raw ,value)))))
	    (set cases `(if (= %i ,k) ,act ,@(and cases (list cases))))))
	(push types (list (car row) (list-length fields) cases))))
    (let ((chain otherwise))
      (list-do tc types
	(set chain `(if (= ,t ,(car tc)) (let (((%i long) (% ,f ,(cadr tc)))) ,(caddr tc)) ,@(and chain (list chain)))))
      chain)))

;; an oop field's value: slot v mod 5, or nil for 4
(define-function slot_ref oop ((v long))
  (let (((s long) (% v 5)))
    (if (< s 4) (return (indir slots s))))
  (return nil))

(define-function show_long void ((n long))
  (if (= n objects_poison) (printf "S\n") (printf "%ld\n" n)))

(define-function show_int void ((n int))
  (if (= n objects_poison_int) (printf "S\n") (printf "%d\n" n)))

(define-function show_double void ((d double))
  (let (((copy double) d) ((bits long) 0))
    (memcpy (cast (addressof bits) void *) (cast (addressof copy) void *) (sizeof long))
    (if (= bits objects_poison) (printf "S\n") (printf "%ld\n" (cast d long)))))

(define-function show_ptr void ((w long))
  (if (= w objects_poison) (printf "S\n") (if w (printf "p\n") (printf "0\n"))))

;; nil, S, @k for the first slot holding it, # and its value for a <long> no slot holds (an immediate, tagged, or boxed),
;; or t and its type
(define-function show_oop void ((x oop))
  (let (((s long) 0) ((found long) -1))
    (while (< s 4)
      (if (and (< found 0) (= x (indir slots s))) (set found s))
      (set s (+ s 1)))
    (if (= x nil)
	(printf "nil\n")
      (if (= (cast x long) objects_poison)
	  (printf "S\n")
	(if (>= found 0)
	    (printf "@%ld\n" found)
	  (if (= (object-type x) 2)
	      (let () (printf "#") (show_long (k_getLong x)))
	    (printf "t%ld\n" (object-type x))))))))

(define-function new_of oop ((t long))
  (if (= t 0) (return (new <undefined>)))
  (if (= t 1) (return (new <data> 16)))
  (if (= t 2) (return (new <long>)))
  (if (= t 3) (return (new <double>)))
  (if (= t 4) (return (new <string>)))
  (if (= t 5) (return (new <symbol>)))
  (if (= t 6) (return (new <pair>)))
  (if (= t 7) (return (new <_array> 32)))
  (if (= t 8) (return (new <array>)))
  (if (= t 9) (return (new <expr>)))
  (if (= t 10) (return (new <form>)))
  (if (= t 11) (return (new <fixed>)))
  (if (= t 12) (return (new <subr>)))
  (if (= t 13) (return (new <knot>)))
  (return (new <pixel>)))

;; a subr's implementation, for a <subr> to point at
(define-function objects-run-imp oop ((args oop) (env oop)) (return args))

(define-function make_of oop ((t long) (a long) (b long) (line long))
  (if (= t 1) (return (k_newData 16)))
  (if (= t 2) (return (k_newLong (+ (* a 64) line))))
  (if (= t 3) (return (k_newDouble (cast (+ (* a 64) line) double))))
  (if (= t 4) (return (k_newStringC "ab")))
  (if (= t 5) (return (k_newSymbolC "ab")))
  (if (= t 6) (return (k_cons (slot_ref a) (slot_ref b))))
  (if (= t 8) (return (k_newArray (% a 4))))
  (if (= t 9) (return (k_newExpr (slot_ref a) (slot_ref b))))
  (if (= t 10) (return (k_newForm (slot_ref a) (slot_ref b))))
  (if (= t 11) (return (k_newFixed (slot_ref a))))
  (if (= t 12) (return (k_newSubrC "ab" objects-run-imp)))
  (return (new_of t)))

(define-function read_long long ()
  (let (((n long) 0))
    (scanf "%ld" (addressof n))
    (return n)))

;; a checked access of type t on x, refused when x isn't a t (or isn't boxed?, as an immediate has no field to put): "F t actual"
;; first; afterwards ! unless type_check_fail was called exactly then, with t and x's type
(define-function check_before long ((t long) (x oop) (refused int))	; refused: ir2's truth value
  (if refused (printf "F %ld %ld\n" t (object-type x)))
  (return type_check_failures))

(define-function check_after void ((t long) (before long) (actual long) (refused int))
  (if (not refused)
      (if (!= before type_check_failures) (printf "!\n"))
    (if (or (!= type_check_failures (+ before 1)) (!= type_check_expected t) (!= type_check_actual actual))
	(printf "!\n"))))

;; each operation that reaches a field: set and look through slot x's own type, get and put through type t (each a
;; function of its own, so no one function holds all four dispatches: native code compiles a large one slowly)
(define-function op_set void ((x oop) (f long) (v long) (line long))
  (if (boxed? x) (field-cases set (object-type x) f x v line ())))

(define-function op_look void ((x oop) (f long))
  (if (not (boxed? x)) (printf "-\n") (field-cases look (object-type x) f x 0 0 (printf "-\n"))))

(define-function op_get void ((x oop) (t long) (f long))
  (let* (((actual long) (object-type x))
	 ((before long) (check_before t x (!= t actual))))
    (field-cases get t f x 0 0 ())
    (check_after t before actual (!= t actual))))

(define-function op_put void ((x oop) (t long) (f long) (v long) (line long))
  (let* (((actual long) (object-type x))
	 ((before long) (check_before t x (or (!= t actual) (not (boxed? x))))))
    (field-cases put t f x v line ())
    (check_after t before actual (or (!= t actual) (not (boxed? x))))))

(define-function main int ((argc int) (argv char * *))
  (gc_initialise)
  (set gc_poison 165)
  (set type_check_fatal 0)
  (set gc_frequency (atol (indir argv 1)))
  (set slots (cast (malloc (cast (* 4 (sizeof oop)) long)) oop *))
  (let (((s long) 0))
    (while (< s 4)
      (set (indir slots s) nil)
      (gc_push_root (cast (addressof (indir slots s)) void *))
      (set s (+ s 1))))
  (let (((code long) 0) ((line long) 0) ((x oop) nil) ((s long) 0) ((t long) 0) ((f long) 0) ((a long) 0))
    (while (= 1 (scanf "%ld" (addressof code)))
      (if (!= code 8) (set s (read_long)))
      (set x (indir slots (% s 4)))
      (if (= code 1) (set (indir slots s) (new_of (read_long))))
      (if (= code 2) (let ()
		       (set t (read_long))
		       (set a (read_long))
		       (set (indir slots s) (make_of t a (read_long) line))))
      (if (= code 3) (let () (set f (read_long)) (op_set x f (read_long) line)))
      (if (= code 4) (op_look x (read_long)))
      (if (= code 5) (let () (set t (read_long)) (op_get x t (read_long))))
      (if (= code 6) (let () (set t (read_long)) (set f (read_long)) (op_put x t f (read_long) line)))
      (if (= code 7) (printf "%ld\n" (object-type x)))
      (if (= code 8) (gc_gcollect))
      (set line (+ line 1))))
  (return 0))
