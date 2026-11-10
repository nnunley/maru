;;; check/source/defs.l -- definitions check/source.l asks for their sources

(define-function source-fixture-f (x)
  ; a comment inside
  (+ x 1))
(define-form source-fixture-g (a) `(list ,a))
(define-selector source-fixture-s (self) 0)
(define-method source-fixture-s <pair> () 1)
(define-method source-fixture-s <long> ()
  2)
(define-structure <source-fixture> (a b))
(define source-fixture-h (lambda () 'h))
(define-function source-fixture-f (x) (* x 2))
