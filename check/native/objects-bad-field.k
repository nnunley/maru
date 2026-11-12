;; a field the object type doesn't have is refused when compiled, naming it
(define-object <pair> 19 ((head oop) (tail oop)))
(define-function bad oop ((p oop)) (return (object-slot <pair> hed p)))
