;; Test C generation using compile forms
(require "core/compiler/emit.l")

;; Switch to C backend
(use-c-backend)

(compile-begin)

;; Simple function for testing
(define-function test-add (a b)
  (+ a b))

(define-function main ()
  42)

(compile-end)