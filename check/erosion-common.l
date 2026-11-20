;;; What checks share (check/erosion.l, check/erosion-attribution.l, check/exe.l, check/git-object.l): expect, which notes
;;; a failure and goes on, and ifs, a body of n decisions.
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function ifs (n) (let ((s "")) (for (i 0 n) (set s (concat-string s "(if a b) "))) s))	; n decisions, each one form
