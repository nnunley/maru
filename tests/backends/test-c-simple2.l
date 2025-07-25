;;; Simple test for C code generation - attempt 2

(require "boot.l")  ;; Ensure boot is loaded first
(define EMIT_BACKEND 'c)
(require "emit.l")

;; Now compile-begin should be available
(compile-begin)

(define-function add (x y)
  (+ x y))

(define-function main ()
  (add 40 2))

(compile-end)