;; an unchecked accessor's operand must be an object: a long is refused, as get refuses it
(define-object <pair> 19 ((head oop) (tail oop)))
(define-function g long ((x long)) (return (cast (<pair>-head x) long)))
