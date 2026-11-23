;;; refused (check/native.l): a nonzero literal a float would hold as 0, beside a float
(define-function f float ((x float)) (return (* x 1e-50)))
