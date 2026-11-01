;;; For adequacy.law: does a goal hold under the rules a law runs with (a mutant's, in adequacy)?
(define-function holds (rel . args) (if (rules-holds? *law-rules* (cons rel args) *ls*) 'Yes 'No))
(define-function reaches (x y) (if (assq y (cdr (assq x '((A (B) (C)) (B (C)))))) 'Yes 'No))	; for reach.law
