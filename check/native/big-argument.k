;;; Refused (check/native.l): a struct over 16 bytes as an argument by value, until C's by-reference convention is written.
(define-struct <big> ((a long) (b long) (c long)))
(define-function first-of long ((s struct <big>)) (return (. s a)))
