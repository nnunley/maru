;;; objects.law's references: a program's operations (objects-programs.law's encode) run by the compiled driver
;;; check/objects-run.k, and on a model here that says what the driver should print, line for line.
;;;   (agrees ops pace)          accept if the driver's lines are the model's, reject if not, (crash status) if it died
;;;   (clean ops pace)           accept if no line the driver prints holds the sentinel S, reject if one does, or (crash status)
;;;   (ops_using ops code)       how many operations have that code
;;;   (made_reads ops)           how many looks and gets read a slot a constructor last filled
;;; OBJECTS_LAW_RUN names the driver, OBJECTS_LAW_TMP a directory for its input and output, and OBJECTS_LAW_TAGGED is 1
;;; when the driver's kernel tags its integers (check.l's law_objects sets all three).

(define-function ol-env (name)
  (let ((p ((subr "getenv" "s>p") name)) (chars ()) (i 0))
    (or (and p (!= 0 p)) (error name " is not set"))
    (while (< 0 (byte-at p i)) (push chars (byte-at p i)) (set i (+ i 1)))
    (list->string (list-reverse! chars))))
(define ol-system (subr "system" "s>i"))
(define ol-fopen (subr "fopen" "ss>p"))
(define ol-fprintf (subr "fprintf" "ps.>i"))
(define ol-fclose (subr "fclose" "p>i"))

;; the output's lines
(define-function ol-lines (text)
  (let ((out ()) (start 0) (i 0) (n (string-length text)))
    (while (< i n)
      (when (= (string-at text i) 10)
	(push out (string-copy text start (- i start)))
	(set start (+ i 1)))
      (set i (+ i 1)))
    (and (< start n) (push out (string-copy text start (- n start))))
    (list-reverse! out)))

;;; the driver: its lines, or (crash status) if it exited otherwise than 0 (ASan, a fault, the sentinel followed)
(define-function ol-real (ops pace)
  (let* ((dir (ol-env "OBJECTS_LAW_TMP"))
	 (in (concat-strings dir "/in"))
	 (out (concat-strings dir "/out"))
	 (f (ol-fopen in "w")))
    (or (and f (!= 0 f)) (error "objects: can't write " in))
    (list-do op ops
      (list-do x op (ol-fprintf f "%ld " x))
      (ol-fprintf f "\n"))
    (ol-fclose f)
    (let ((status (ol-system (concat-strings (ol-env "OBJECTS_LAW_RUN") " " (long->string pace) " < " in " > " out " 2>&1"))))
      (if (= 0 status)
	  (ol-lines (contents-of-file-named out))
	(list 'crash status)))))

;;; the model.  A type's fields, in order, by kind: oop (traced), long, int, double, or ptr (a C pointer the
;;; constructors write and set and put leave alone), as kernel-objects.k and check/objects-run.k declare them.
(define ol-fields
  (list->array
   '(()			; 0 <undefined>
     ()			; 1 <data>
     (long)		; 2 <long>
     (double)		; 3 <double>
     (oop ptr)		; 4 <string>: size bits
     (ptr int)		; 5 <symbol>: bits flags
     (oop oop oop)	; 6 <pair>: head tail source
     ()			; 7 <_array>
     (oop oop)		; 8 <array>: size _array
     (oop oop oop oop)	; 9 <expr>: name definition environment profile
     (oop oop)		; 10 <form>: function symbol
     (oop)		; 11 <fixed>: function
     (ptr ptr ptr int)	; 12 <subr>: name imp sig profile
     (long oop int)	; 13 <knot>: value next count
     (int int double))))	; 14 <pixel>, an atom: r g x

(define-function ol-nth (l i) (while (< 0 i) (set l (cdr l)) (set i (- i 1))) (car l))
(define-function ol-kinds (type) (array-at ol-fields type))
;; the indexes of the fields set and put can write: all but a ptr
(define-function ol-writable (type)
  (let ((out ()) (i 0))
    (list-do k (ol-kinds type)
      (or (= k 'ptr) (push out i))
      (set i (+ i 1)))
    (list-reverse! out)))

;; an object is an array: its type, then its fields' values; a tagged integer is a Maru integer, with no fields and equal
;; to another by value.  A value is S (nothing wrote it), () for nil, an object,
;; an integer, or p (a C pointer a constructor wrote)
(define-function ol-object (type values)
  (let ((obj (array (+ 1 (list-length (ol-kinds type))))) (i 1))
    (set-array-at obj 0 type)
    (for (j 0 (list-length (ol-kinds type))) (set-array-at obj (+ j 1) 'S))
    (list-do v values (set-array-at obj i v) (set i (+ i 1)))
    obj))
(define *ol-tagged* ())
(define-function ol-immediate? (obj) (long? obj))
(define-function ol-type (obj) (cond ((not obj) 0) ((ol-immediate? obj) 2) (else (array-at obj 0))))
;; a <long> a kernel constructor makes: an immediate when tagged (every value here fits), otherwise boxed
(define-function ol-long (n) (if *ol-tagged* n (ol-object 2 (list n))))

(define *ol-slots* ())
(define *ol-out* ())
(define-function ol-print (line) (push *ol-out* line))
;; an oop field's value from a number: slots 0 to 3, or nil
(define-function ol-ref (v) (let ((s (% v 5))) (and (< s 4) (array-at *ol-slots* s))))

(define ol-show-oop ())	; ol-show and ol-show-oop call each other
(define-function ol-show (kind x)
  (cond
    ((= x 'S)		"S")
    ((= kind 'oop)	(ol-show-oop x))
    ((= x 'p)		"p")
    (else		(long->string x))))
(define-function ol-show-oop (x)
  (if (not x)
      "nil"
    (let ((slot ()))
      (for (s 0 4) (and (not slot) (= x (array-at *ol-slots* s)) (set slot s)))
      (cond
	(slot			(concat-strings "@" (long->string slot)))
	((ol-immediate? x)	(concat-strings "#" (long->string x)))
	((= 2 (ol-type x))	(concat-strings "#" (ol-show 'long (array-at x 1))))
	(else			(concat-strings "t" (long->string (ol-type x))))))))
(define-function ol-zero (kind) (if (= kind 'oop) "nil" "0"))

;; what a write of v puts in a field of that kind: an object for an oop, otherwise v made distinct by the line it is on
(define-function ol-value (kind v line) (if (= kind 'oop) (ol-ref v) (+ (* v 64) line)))

;; what each kernel constructor makes of a and b (check/objects-run.k's make_of), by type; another type is made raw
(define ol-makers (array 15))
(define-form maker (type args . body) `(set-array-at ol-makers ,type (lambda ,args ,@body)))
(maker 2  (a b line) (ol-long (+ (* a 64) line)))
(maker 3  (a b line) (ol-object 3 (list (+ (* a 64) line))))
(maker 4  (a b line) (ol-object 4 (list (ol-long 2) 'p)))
(maker 5  (a b line) (ol-object 5 (list 'p 0)))
(maker 6  (a b line) (ol-object 6 (list (ol-ref a) (ol-ref b) ())))
(maker 8  (a b line) (ol-object 8 (list (ol-long (% a 4)) (ol-object 7 ()))))
(maker 9  (a b line) (ol-object 9 (list () (ol-ref a) (ol-ref b) (ol-long 0))))
(maker 10 (a b line) (ol-object 10 (list (ol-ref a) (ol-ref b))))
(maker 11 (a b line) (ol-object 11 (list (ol-ref a))))
(maker 12 (a b line) (ol-object 12 (list 'p 'p 0 0)))
(define-function ol-make (type a b line)
  (let ((f (array-at ol-makers type))) (if f (f a b line) (ol-object type ()))))

;; a checked access of type to obj: on a mismatch, or a put to an immediate, "F type actual" is printed, and the access
;; isn't made
(define-function ol-checked (type obj putting)
  (or (and (= type (ol-type obj)) (not (and putting (ol-immediate? obj))))
      (let () (ol-print (concat-strings "F " (long->string type) " " (long->string (ol-type obj)))) ())))

;; each operation, by its code (check/objects-run.k's header), given its line and its arguments after the code
(define ol-ops (array 9))
(define-form operation (code args . body) `(set-array-at ol-ops ,code (lambda (line ,@args) ,@body)))
(operation 1 (s t) (set-array-at *ol-slots* s (ol-object t ())))
(operation 2 (s t a b) (set-array-at *ol-slots* s (ol-make t a b line)))
(operation 3 (s f v)
  (let* ((obj (array-at *ol-slots* s)) (w (and (not (ol-immediate? obj)) (ol-writable (ol-type obj)))))
    (when w
      (let ((i (ol-nth w (% f (list-length w)))))
	(set-array-at obj (+ i 1) (ol-value (ol-nth (ol-kinds (ol-type obj)) i) v line))))))
(operation 4 (s f)
  (let* ((obj (array-at *ol-slots* s)) (ks (and (not (ol-immediate? obj)) (ol-kinds (ol-type obj)))))
    (if ks
	(let ((i (% f (list-length ks)))) (ol-print (ol-show (ol-nth ks i) (array-at obj (+ i 1)))))
      (ol-print "-"))))
(operation 5 (s t f)
  (let* ((obj (array-at *ol-slots* s)) (ks (ol-kinds t)) (i (% f (list-length ks))))
    (if (ol-checked t obj ())
	(ol-print (if (ol-immediate? obj) (long->string obj) (ol-show (ol-nth ks i) (array-at obj (+ i 1)))))
      (ol-print (ol-zero (ol-nth ks i))))))
(operation 6 (s t f v)
  (let* ((obj (array-at *ol-slots* s)) (w (ol-writable t)) (i (ol-nth w (% f (list-length w)))))
    (and (ol-checked t obj 't)
	 (set-array-at obj (+ i 1) (ol-value (ol-nth (ol-kinds t) i) v line)))))
(operation 7 (s) (ol-print (long->string (ol-type (array-at *ol-slots* s)))))
(operation 8 () ())
(define-function ol-step (op line) (apply (array-at ol-ops (car op)) (cons line (cdr op))))

(define-function ol-model (ops)
  (let ((line 0))
    (set *ol-tagged* (equal "1" (ol-env "OBJECTS_LAW_TAGGED")))
    (set *ol-slots* (array 4))
    (set *ol-out* ())
    (list-do op ops (ol-step op line) (set line (+ line 1)))
    (list-reverse! *ol-out*)))

(define-function crash? (x) (and (pair? x) (= 'crash (car x))))

(define-function agrees (ops pace)
  (let ((real (ol-real ops pace)))
    (cond ((crash? real)		real)
	  ((equal real (ol-model ops))	accept)
	  (else				reject))))

(define-function clean (ops pace)
  (let ((real (ol-real ops pace)) (verdict accept))
    (if (crash? real)
	real
      (list-do line real
	(for (i 0 (string-length line))
	  (and (= ?S (string-at line i)) (set verdict reject))))
      verdict)))

(define-function ops_using (ops code)
  (let ((n 0)) (list-do op ops (and (= code (car op)) (set n (+ n 1)))) n))

(define-function made_reads (ops)
  (let ((built (array 4)) (n 0))
    (list-do op ops
      (let ((code (car op)) (s (and (cdr op) (cadr op))))
	(cond ((= code 1)		(set-array-at built s ()))
	      ((= code 2)		(set-array-at built s 't))
	      ((or (= code 4) (= code 5))	(and (array-at built s) (set n (+ n 1)))))))
    n))
