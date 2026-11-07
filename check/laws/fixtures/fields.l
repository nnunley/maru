;;; fields.law's support: rec answers a record with fields a and b; plain answers a number.
(define-function rec (n) (law-record "a" n "b" (list n n)))
(define-function plain (n) n)
