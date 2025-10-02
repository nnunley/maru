;;; test-arm64-min.l - Minimal ARM64 Test

(require "ir.k")

(println "=== Minimal ARM64 Test ===")

;; Simple ARM64 instruction
(define-class <ir-arm64-mov-imm> <ir-insn> (immediate dst-reg))

(define-function ir-arm64-mov-imm (imm dst)
  (new <ir-arm64-mov-imm> (list imm dst) () IR-VOID () imm dst))

;; Test instruction creation
(let ((mov-insn (ir-arm64-mov-imm 42 'x0)))
  (println "Created: " mov-insn))

(println "=== Test Complete ===")