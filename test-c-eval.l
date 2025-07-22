;;; Test with proper evaluation context

(require "boot.l")
(require "emit.l")

;; Set backend after emit.l is loaded
(set *emit-backend* 'c)
(require "emit-c.l")

;; Now test compilation
(compile-begin)

(define-function add (x y)
  (+ x y))

(compile-end)