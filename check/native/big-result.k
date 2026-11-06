;;; Refused (check/native.l): a struct over 16 bytes as a result by value, until C's hidden result pointer is written.
(define-struct <big> ((a long) (b long) (c long)))
(define-function make-big (struct <big>) ((p struct <big> *)) (return (indir p 0)))
