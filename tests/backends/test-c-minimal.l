;;; Minimal test for C code generation

;; Load the necessary modules
(require "boot.l")
(require "emit.l")
(require "emit-c.l")

;; Override gen-env to use C backend instead of assembly
(define-function gen-env (env) (gen-env-c env))

;; Test compilation with a very simple function
(compile-begin)

(define-function test-add (a b)
  (+ a b))

(define-function main ()
  (test-add 21 21))

(compile-end)