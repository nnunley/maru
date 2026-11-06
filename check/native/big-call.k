;;; Refused (check/native.l): a call passing a struct over 16 bytes by value, to a C function the unit doesn't define.
(define-struct <big> ((a long) (b long) (c long)))
(define (consume (long struct <big>) *) (extern consume))
(define-function hand-over long ((p struct <big> *)) (return (consume (indir p 0))))
