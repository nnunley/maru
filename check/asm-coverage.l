;;; Every form asm-coverage.spec lists for an instruction set has a row.
;;;
;;;   ./eval check/asm-coverage.l ISA
;;;
;;; Prints each missing form, then "asm coverage ISA: N forms, M missing", and
;;; "asm coverage ISA ok" when none is missing.

(define isa (string->symbol (next-argument)))

(require "asm-table.l")
(require "asm-arm64.l")

(define-function fields (line)	; ISA, CLASS and FORM, split at the first two runs of tabs
  (let ((out ()) (i 0) (n (string-length line)))
    (for (k 0 2)
      (let ((j i))
	(while (and (< j n) (!= ?\t (string-at line j))) (set j (+ j 1)))
	(set out (cons (string-copy line i (- j i)) out))
	(while (and (< j n) (= ?\t (string-at line j))) (set j (+ j 1)))
	(set i j)))
    (list-reverse! (cons (string-copy line i (- n i)) out))))

(define forms 0)
(define missing 0)
(let ((text (contents-of-file-named "asm-coverage.spec")) (i 0))
  (while (< i (string-length text))
    (let ((j i))
      (while (and (< j (string-length text)) (!= ?\n (string-at text j))) (set j (+ j 1)))
      (let ((line (string-copy text i (- j i))))
	(when (and (< 0 (string-length line)) (!= ?# (string-at line 0)))
	  (let ((f (fields line)))
	    (when (= isa (string->symbol (car f)))
	      (set forms (+ forms 1))
	      (let ((form (asm-parse-form isa (caddr f))))
		(unless (and form (list-detect r (asm-forms isa (car form)) (equal (car r) (cadr form))))
		  (set missing (+ missing 1))
		  (println "MISSING " (caddr f) (if form "" "  (notation not understood)"))))))))
      (set i (+ j 1)))))

(println "asm coverage " isa ": " forms " forms, " missing " missing")
(if (= 0 missing) (println "asm coverage " isa " ok"))
