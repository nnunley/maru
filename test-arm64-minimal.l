;;; test-arm64-minimal.l - Minimal ARM64 IR test

(require "ir.k")

;; Simple test without complex dependencies
(println "=== Minimal ARM64 Test ===")

;; Define basic instruction class
(define-class <ir-arm64-test> <ir-insn> (value))

(define-function test-arm64-basic ()
  "Basic ARM64 test"
  (let ((insn (new <ir-arm64-test> () () IR-VOID () 42)))
    (println "Created test instruction: " insn)
    insn))

;; Test basic functionality
(let ((result (test-arm64-basic)))
  (println "Test result: " result))

;; Test register encoding function
(define-function arm64-register-encoding-simple (reg)
  "Simple register encoding"
  (cond
    ((= reg 'x0) 0)
    ((= reg 'x1) 1)
    ((= reg 'x2) 2)
    (else 31)))

(println "Register encodings:")
(println "  x0 = " (arm64-register-encoding-simple 'x0))
(println "  x1 = " (arm64-register-encoding-simple 'x1))
(println "  x2 = " (arm64-register-encoding-simple 'x2))

(println "=== Minimal ARM64 Test Complete ===")