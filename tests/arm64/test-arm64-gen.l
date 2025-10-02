;; Test ARM64 code generation with a simple function

(load "boot.l")
(load "core/compiler/emit.l")

;; Activate ARM64 backend
(use-arm64-backend)

;; Define a simple function to compile
(define test-add (a b) (+ a b))

;; This should generate ARM64 assembly for the function