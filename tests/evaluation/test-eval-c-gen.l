;; Test eval generation with C backend
(require "core/compiler/emit.l")
(use-c-backend)

(compile-begin)

;; Simple evaluator function for testing
(define-function simple-eval (expr)
  (if (long? expr)
      expr
    42))

(define-function main ()
  (simple-eval 123))

(compile-end)