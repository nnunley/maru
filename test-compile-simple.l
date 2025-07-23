;; Simple test for compilation
(define-function add (a b)
  (+ a b))

(define-function factorial (n)
  (if (<= n 1)
      1
      (* n (factorial (- n 1)))))