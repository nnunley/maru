;;; Test C code generation backend

(define EMIT_BACKEND 'c)
(require "emit.l")

(compile-begin)

(define-function add (x y)
  (+ x y))

(define-function factorial (n)
  (if (<= n 1)
      1
    (* n (factorial (- n 1)))))

(define-function main ()
  (let ((a 5)
        (b 7))
    (add a b)))

(compile-end)