;;; refused (check/native.l): an int compared with a literal an int can't hold
(define-function f long ((i int)) (return (cast (< i 3000000000) long)))
