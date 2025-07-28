;; Simple test for emit system

;; Force C backend
(use-c-backend)
(println "C backend active: " *c-backend-active*)
(println "Emit backend: " *emit-backend*)

(compile-begin)

(define-function double (x)
  (+ x x))

(define-function main ()
  (double 21))

(compile-end)