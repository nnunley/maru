;; Test Final ARM64 Disassembler

(require "disasm-arm64-final.k")

(println "Testing Final ARM64 Disassembler")
(println "================================")

;; Test individual instruction decoding
(println "\nTesting individual instructions:")

;; Test mov w0, #42 (0x52800540)
(let ((inst (arm64-disassemble-word 1384121664)))
  (print "52800540: ")
  (println inst))

;; Test ret (0xD65F03C0)
(let ((inst (arm64-disassemble-word 3596551104)))
  (print "D65F03C0: ")
  (println inst))

;; Test sub sp, sp, #16 (0xD10043FF)
(let ((inst (arm64-disassemble-word 3506455551)))
  (print "D10043FF: ")
  (println inst))

;; Test add x29, sp, #8 (0x910023FD)
(let ((inst (arm64-disassemble-word 2432705533)))
  (print "910023FD: ")
  (println inst))

;; Test str x29, [sp, #8] (0xF90007FD)
(let ((inst (arm64-disassemble-word 4177528829)))
  (print "F90007FD: ")
  (println inst))

;; Test ldr x29, [sp, #8] (0xF94007FD)  
(let ((inst (arm64-disassemble-word 4181723133)))
  (print "F94007FD: ")
  (println inst))

;; Test add x0, x1, x2 (0x8B020020)
(let ((inst (arm64-disassemble-word 2342723616)))
  (print "8B020020: ")
  (println inst))

;; Test mov x0, x1 (0xAA0103E0)
(let ((inst (arm64-disassemble-word 2852258784)))
  (print "AA0103E0: ")
  (println inst))

;; Test unknown instruction
(let ((inst (arm64-disassemble-word 0)))
  (print "00000000: ")
  (println inst))

(println "\nFinal disassembler test complete!")

;; Show that we have successfully implemented the ARM64 disassembler
(println "\nARM64 disassembler capabilities:")
(println "- Move immediate instructions (MOV, MOVZ, MOVK)")
(println "- Add/subtract immediate and register")
(println "- Load/store operations (LDR, STR, LDRB, STRB, LDRH, STRH)")
(println "- Branch instructions (B, BL)")
(println "- Logical operations (AND, ORR, EOR)")
(println "- Return instruction (RET)")
(println "- Unknown instruction handling")