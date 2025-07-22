;;; Test C code generation with emit.l and emit-c.l

(require "boot.l")

;; Load emit.l (which defaults to x86 backend)
(require "emit.l")

;; Now load the C backend
(require "emit-c.l")

;; Override gen-env to use C backend
(define-function gen-env (env) (gen-env-c env))

;; Now compile a simple test
(compile-begin)

(define-function add (a b)
  (+ a b))

(define-function main ()
  (add 40 2))

(compile-end)