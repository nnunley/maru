;;; Test C backend generation

(require "core/compiler/emit.l")

;; Switch to C backend
(use-c-backend)

(compile-begin)

;; Simple function with parameters
(define-function add (a b)
  (+ a b))

;; Function that calls another function  
(define-function test-main ()
  (add 40 2))

(compile-end)