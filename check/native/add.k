;;; Typed Maru compiled natively and called by address (check/native.l): parameters, a literal, add, subtract, return.
(define-function add3 long ((a long) (b long) (c long)) (return (+ a (+ b c))))
(define-function neg long ((a long)) (return (- 0 a)))
