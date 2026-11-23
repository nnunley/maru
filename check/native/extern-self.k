;;; A function declared extern and defined in the same unit (as nile.k declares the runtime's interface and
;;; nile-builtins.k defines it): a call through the declaration reaches the unit's own function, as C's linker binds it,
;;; not a C symbol of that name looked up when the image loads (check/native.l).
(define (twice_extern (long long) *)
  (extern twice_extern))
(define-function twice_extern long ((a long)) (return (+ a a)))
(define-function call_twice long ((a long)) (return (+ 1 (twice_extern a))))
