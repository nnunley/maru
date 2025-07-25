;;; Test assembly generation (default x86 backend)

(require "boot.l")
(require "emit.l")

;; Test compilation with x86 backend (default)
(compile-begin)

(define-function main ()
  42)

(compile-end)