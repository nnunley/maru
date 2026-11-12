;; a unit's own function named get, used before its definition, is an ordinary call: get's object form is only for
;; a declared object type
(define-function f long () (return (get 3)))
(define-function get long ((x long)) (return (+ x 1)))
