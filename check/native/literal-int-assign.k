;;; refused (check/native.l): a literal an int can't hold, given to an int
(define-function f long () (let (((x int) 3000000000)) (return (cast x long))))
