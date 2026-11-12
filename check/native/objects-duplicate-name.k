;; two object types with one name are refused, as two structs are
(define-object <pair> 19 ((head oop) (tail oop)))
(define-object <pair> 20 ((x long)))
(define-function f long () (return 0))
