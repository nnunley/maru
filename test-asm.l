;; Test assembly backend

(compile-begin)

(define-function double (x)
  (+ x x))

(compile-end)