(load "core/compiler/emit.l")
(set *c-backend-active* 1)

(define-function simple-test ()
  (+ 1 2))

(define simple-var 42)

(compile-end)