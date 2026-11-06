;;; Refused (check/native.l): a -0.0 literal, which native-gen.k's double bits would make 0.0.
(define-function negative-zero double () (return -0.0))
