;;; check/source.l -- source.l: what loading defined answers its own source, form and line counts and text
(require "source.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(load "check/source/defs.l")
(define fixture (find-and-read "check/source/defs.l"))	; its forms as Maru's reader makes them

(expect "a function redefined answers its latest definition" (source-form source-fixture-f) (car (cddddr (cdddr fixture))))
(expect "and that definition's lines" (line-count source-fixture-f) 1)
(expect "a form's source is its definition" (source-form source-fixture-g) (cadr fixture))
(expect "a comment line isn't counted, nor is a blank one; a structure is its definition"
	(list (line-count <source-fixture>) (form-count <source-fixture>)) '(1 2))
(expect "a selector's sources are its own and each method's, in the order defined"
	(map (lambda (s) (<source>-first s)) (sources source-fixture-s)) '(7 8 9))
(expect "a method spanning two lines counts both" (line-count (array-at (<selector>-methods source-fixture-s) <long>)) 2)
(expect "a lambda bound by define is a definition" (source-form source-fixture-h) (car (cddddr (cddr fixture))))
(expect "source-text is the definition's own text" (source-text <source-fixture>) "(define-structure <source-fixture> (a b))")
(expect "forms count as erosion counts them" (form-count source-fixture-g) 3)
(expect "what loading didn't define has no source" (source-of (lambda (x) x)) ())
(let ((m (array-at (<selector>-methods source-fixture-s) <pair>)))
  (expect "a method knows its file and lines" (list (<source>-path (source-of m)) (<source>-first (source-of m)) (<source>-last (source-of m)))
	  '("check/source/defs.l" 8 8)))
;; what was read before source.l: the boot file, which the evaluator read itself, and each file required before
(define boot-file (if (defined? 'find-and-read-in) "boot2.l" "boot.l"))
(expect "a boot definition answers its source in the boot file" (<source>-path (source-of load)) boot-file)
(expect "and its form as read" (car (source-form load)) 'define-function)
(expect "a selector the boot defined has sources" (not (not (sources equal))) 't)
(expect "a file required before source.l answers its sources" (<source>-path (source-of hash-at)) "hash.l")
(expect "a structure the boot defined" (car (source-form <selector>)) 'define-structure)
(println (if ok "source ok" "source FAILED"))
