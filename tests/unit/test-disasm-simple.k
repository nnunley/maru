;; Simple ARM64 Disassembler Test

(require "disasm-arm64-simple.k")

(println "Testing Simple ARM64 Disassembler")
(println "=================================")

;; Test a few basic instructions
(println "\nTesting individual instructions:")

;; Test mov w0, #42
(let ((instruction (arm64-disassemble-word 0x52800540)))
  (println (format "52800540: %s" instruction)))

;; Test ret
(let ((instruction (arm64-disassemble-word 0xD65F03C0)))
  (println (format "D65F03C0: %s" instruction)))

;; Test add x0, x1, x2  
(let ((instruction (arm64-disassemble-word 0x8B020020)))
  (println (format "8B020020: %s" instruction)))

;; Test str x0, [sp, #16]
(let ((instruction (arm64-disassemble-word 0xF90007E0)))
  (println (format "F90007E0: %s" instruction)))

;; Test buffer disassembly
(println "\nTesting buffer disassembly:")

(let ((buffer (buffer-new 64)))
  ;; Write some test instructions
  (buffer-write-long buffer 0x52800540)  ; mov w0, #42
  (buffer-write-long buffer 0xD65F03C0)  ; ret
  
  (println "Buffer disassembly:")
  (arm64-print-disassembly buffer))

(println "\nSimple disassembler test complete!")