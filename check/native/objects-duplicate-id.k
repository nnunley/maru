;; two object types with one id are refused, naming both
(define-object <pair> 19 ((head oop) (tail oop)))
(define-object <other> 19 ((x long)))
(define-function f long () (return 0))
