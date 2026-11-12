;; an oop written to a long field is refused when compiled
(define-object <long> 3 ((bits long)) atom)
(define-function bad void ((n oop)) (set (<long>-bits n) n))
