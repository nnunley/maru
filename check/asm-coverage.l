;;; asm-coverage.spec against the rows, and against ir2.
;;;
;;;   ./eval check/asm-coverage.l ISA
;;;
;;; Every form the table lists for ISA must have a row, and every (operation,
;;; type) pair ir2 can compile must be named by some form's classes.  The
;;; operations and their types are read from ir2.k's own declarations
;;; (define-unary-arithmetic and the rest, with their type predicates), so an
;;; operation added there is required here without anyone listing it.
;;; Prints what is missing or uncovered, then "asm coverage ISA ok" if nothing.

(define isa (string->symbol (next-argument)))

(require "asm-table.l")
(require "asm-arm64.l")

(define-function split (str sep)
  (let ((out ()) (start 0) (n (string-length str)))
    (for (i 0 n)
      (when (= sep (string-at str i))
	(or (= start i) (set out (cons (string-copy str start (- i start)) out)))
	(set start (+ i 1))))
    (and (< start n) (set out (cons (string-copy str start (- n start)) out)))
    (list-reverse! out)))

(define-function file-lines (path)	(split (contents-of-file-named path) ?\n))

(define-function starts? (str prefix)
  (and (<= (string-length prefix) (string-length str))
       (= 0 (string-compare str prefix 0 (string-length prefix)))))

;;; ---------------------------------------------------------------- what ir2 needs

(define integer-types	'("s8" "u8" "s16" "u16" "s32" "u32" "s64" "u64"))
(define float-types	'("f32" "f64"))
(define numeric-types	(concat-list integer-types float-types))

;; A class's type, possibly a group, as the types it stands for.
(define-function types-of (t)
  (cond ((= t "i32")	'("s8" "u8" "s16" "u16" "s32" "u32"))
	((= t "i64")	'("s64" "u64"))
	((= t "s32")	'("s8" "s16" "s32"))
	((= t "u32")	'("u8" "u16" "u32"))
	(else		(list t))))

(define required ())
(define-function needs (op types)	(list-do t types (set required (cons (concat-strings op "." t) required))))

;; Operations from ir2.k: (define-<kind> NAME [PREDICATE]) and the add/sub classes.
(list-do line (file-lines "ir2.k")
  (let ((w (split line 32)))
    (cond
      ((or (starts? line "(define-unary-arithmetic ") (starts? line "(define-binary-arithmetic "))
       (needs (cadr w) (if (starts? (caddr w) "ir-integral-type?") integer-types numeric-types)))
      ((starts? line "(define-shift ")		(needs (string-copy (cadr w) 0 (- (string-length (cadr w)) 1)) integer-types))
      ((or (starts? line "(define-relation ") (starts? line "(define-arithmetic-relation "))
       (needs (string-copy (cadr w) 0 (- (string-length (cadr w)) 1)) numeric-types))
      ((starts? line "(define-class <ir-add> ")	(needs "add" numeric-types))
      ((starts? line "(define-class <ir-sub> ")	(needs "sub" numeric-types)))))

;; Casts between every integer and float type, between the floats, and every widening.
(list-do i integer-types
  (list-do f float-types
    (set required (cons (concat-strings "cast." i "." f) (cons (concat-strings "cast." f "." i) required)))))
(set required (concat-list '("cast.f32.f64" "cast.f64.f32") required))
(list-do pair '(("s8" "s16") ("s8" "s32") ("s8" "s64") ("s16" "s32") ("s16" "s64") ("s32" "s64")
		("u8" "u16") ("u8" "u32") ("u8" "u64") ("u16" "u32") ("u16" "u64") ("u32" "u64"))
  (set required (cons (concat-strings "cast." (car pair) "." (cadr pair)) required)))
;; Loads and stores of every type (indir, set-indir, member), and control.
(needs "load" numeric-types)
(needs "store" numeric-types)
(set required (concat-list '("branch" "call" "call.indirect" "return" "lit.i64" "addressof") required))

;;; ---------------------------------------------------------------- the table

(define-function fields (line)	; ISA, CLASSES and FORM, split at the first two runs of tabs
  (let ((out ()) (i 0) (n (string-length line)))
    (for (k 0 2)
      (let ((j i))
	(while (and (< j n) (!= ?\t (string-at line j))) (set j (+ j 1)))
	(set out (cons (string-copy line i (- j i)) out))
	(while (and (< j n) (= ?\t (string-at line j))) (set j (+ j 1)))
	(set i j)))
    (list-reverse! (cons (string-copy line i (- n i)) out))))

(define covered ())
(define-function cover (class)	; op.T or cast.T1.T2, with groups expanded
  (let ((parts (split class ?.)))
    (set covered (cons class covered))
    (cond
      ((= 3 (list-length parts))
       (list-do a (types-of (cadr parts))
	 (list-do b (types-of (caddr parts))
	   (set covered (cons (concat-strings (car parts) "." a "." b) covered)))))
      ((= 2 (list-length parts))
       (list-do t (types-of (cadr parts)) (set covered (cons (concat-strings (car parts) "." t) covered)))))))

(define forms 0)
(define missing 0)
(list-do line (file-lines "asm-coverage.spec")
  (when (and (< 0 (string-length line)) (!= ?# (string-at line 0)))
    (let ((f (fields line)))
      (when (= isa (string->symbol (car f)))
	(set forms (+ forms 1))
	(list-do c (split (cadr f) ?,) (cover c))
	(let ((form (asm-parse-form isa (caddr f))))
	  (unless (and form (list-detect r (asm-forms isa (car form)) (equal (car r) (cadr form))))
	    (set missing (+ missing 1))
	    (println "MISSING " (caddr f) (if form "" "  (notation not understood)"))))))))

(define uncovered 0)
(list-do r required
  (unless (member? r covered)
    (set uncovered (+ uncovered 1))
    (println "UNCOVERED " r)))

(println "asm coverage " isa ": " forms " forms, " missing " missing, "
	 (list-length required) " ir2 needs, " uncovered " uncovered")
(if (and (= 0 missing) (= 0 uncovered)) (println "asm coverage " isa " ok"))
