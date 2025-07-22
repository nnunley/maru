;;; Test simple assembly generation

(require "boot.l")

;; Load emit.l (defaults to x86 backend)
(require "emit.l")

;; Now compile-begin should be available if emit.l loaded correctly
(if (defined? 'compile-begin)
    (println "compile-begin is defined!")
    (error "compile-begin is NOT defined"))

;; Simple test
(compile-begin)

(define-function main ()
  42)

(compile-end)