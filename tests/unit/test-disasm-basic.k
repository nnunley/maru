;; Basic ARM64 Disassembler Test - No buffer dependencies

(require "disasm-arm64-simple.k")

(println "Testing ARM64 Disassembler (Basic)")
(println "==================================")

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

;; Test unknown instruction (0x00000000)
(let ((inst (arm64-disassemble-word 0)))
  (print "00000000: ")
  (println inst))

(println "\nBasic disassembler test complete!")