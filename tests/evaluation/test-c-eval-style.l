;;; Test C code generation with eval.c style

(require "boot.l")
(require "emit.l")

;; Now override the backend
(set *emit-backend* 'c)

;; Load C backend
(require "emit-c-proper.l")

;; Test compilation
(compile-begin)

(define-function add (x y)
  (+ x y))

(define-function factorial (n)
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))

(define-function main ()
  (factorial 5))

(compile-end)