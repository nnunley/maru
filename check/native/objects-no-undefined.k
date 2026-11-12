;; object-type is refused, naming what it needs, when <undefined> isn't declared
(define-object <long> 3 ((bits long)) atom)
(define-function f long ((x oop)) (return (object-type x)))
