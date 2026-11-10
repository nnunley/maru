;;; check/source-lift.l -- source.l's definitions read from a file without running it (file-definitions) answer what the same
;;; definitions answer once loaded, and erosion measures through them
(require "source.l")
(require "erosion.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define defs (file-definitions "check/source/defs.l"))
(expect "each definer's kind and name, in order"
	(map (lambda (d) (list (<definition>-kind d) (<definition>-name d))) defs)
	'((function source-fixture-f) (form source-fixture-g) (selector source-fixture-s) (method source-fixture-s)
	  (method source-fixture-s) (type <source-fixture>) (function source-fixture-h) (function source-fixture-f)))
(load "check/source/defs.l")
(expect "read or loaded, a definition has the same form, lines and forms"
	(map (lambda (x) (list (source-form x) (line-count x) (form-count x)))
	     (list source-fixture-g <source-fixture> (array-at (<selector>-methods source-fixture-s) <long>)))
	(map (lambda (d) (list (source-form d) (line-count d) (form-count d)))
	     (list (cadr defs) (car (cddddr (cdr defs))) (car (cddddr defs)))))
(define two (forms-definitions "two.l" '((let () (define-function a () 1) (define-function b (x) (if x 1 2))))))
(expect "definitions inside a let are each a definition of their own" (map (lambda (d) (<definition>-name d)) two) '(a b))
(let ((m (erosion-of (list (cons "two.l" '((let () (define-function a () 1) (define-function b (x) (if x 1 2)))))))))
  (expect "erosion measures each, and counts the let's forms once"
	  (list (map (lambda (c) (<callable>-cc c)) (<erosion-metrics>-callables m)) (<erosion-metrics>-forms m))
	  '((1 2) 5)))
(println (if ok "source lift ok" "source lift FAILED"))
