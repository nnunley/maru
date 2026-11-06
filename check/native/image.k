;;; A code image's table, filled when it loads (check/native-image.l): a global with an initialiser (which __init sets),
;;; a C function, and a string literal.
(define (strlen (long char *) *) (extern strlen))
(define (count long) 40)
(define-function greet long ()
  (set count (+ count 1))
  (return (+ count (strlen "hello"))))
