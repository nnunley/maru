;;; For float.law: a float32 value's family, by the format's own boundaries, and whether a value is one.
(define-function family (x) (symbol->string (rules-float-family x)))
(define-function is_float32 (x) (if (rules-float32? x) 1 0))
