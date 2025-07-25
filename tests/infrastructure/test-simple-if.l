;; Test simple if expression
(require "core/compiler/emit.l")
(use-c-backend)

(compile-begin)

(define-function test-if (x)
  (if (long? x) x 0))

(compile-end)