;;; Test simple C backend functionality

(require "core/compiler/emit.l")

;; Switch to C backend
(set *emit-backend* 'c)

(compile-begin)

(define test-value 42)

(compile-end)