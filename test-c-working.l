;;; Working test for C code generation

(require "boot.l")
(require "emit.l")

;; Now override the backend
(set *emit-backend* 'c)

;; Load C backend
(require "emit-c.l")

;; Test compilation
(compile-begin)

(define-function add (x y)
  (+ x y))

(define-function main ()
  (add 40 2))

(compile-end)