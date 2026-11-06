;; A unit with no main, built as a library (ir-gen-c's library mode, check/library-mode.l opens it): an extern from
;; libc (strlen), a function the unit also declares as an extern (the runtime's shape: nile.k declares what nile-builtins.k
;; defines), a global initialised by a literal, and exported functions that use them.
(define (strlen (long char *) *) (extern strlen))
(define (add1 (int int) *) (extern add1))
(define-function add1 int ((x int))
  (return (+ x 1)))
(define (base int) 40)
(define-function twice_add1 int ((x int))
  (return (add1 (add1 x))))
(define-function base_value int ((x int))
  (return (+ base x)))
(define-function strlen_of long ((s char *))
  (return (strlen s)))
(export twice_add1)
(export base_value)
(export strlen_of)
