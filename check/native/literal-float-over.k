;;; refused (check/native.l): a literal past float's range, beside a float
(define-function f float ((x float)) (return (* x 1e39)))
