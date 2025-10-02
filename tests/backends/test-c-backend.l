;; Test C backend
(require "core/compiler/emit.l")

;; Switch to C backend
(use-c-backend)

;; Simple function for testing
(define-function test-add (a b)
  (+ a b))

(define-function main ()
  42)