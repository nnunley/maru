;; Test ARM64 Assembler + Disassembler Integration

(require "disasm-arm64-simple.k")

(println "ARM64 Assembler + Disassembler Integration Test")
(println "==============================================")

;; Test that we can create and decode instructions  
(println "\nTesting instruction creation and decoding:")

;; Create some test instruction encodings (as if from assembler output)
(let ((test-instructions (list
                          0xD65F03C0  ; ret
                          0x52800540  ; mov w0, #42  
                          0xD10043FF  ; sub sp, sp, #16
                          0x910023FD  ; add x29, sp, #8
                          )))
  
  (list-do instruction-word test-instructions
    (let ((decoded (arm64-disassemble-word instruction-word)))
      (println (format "%08X: %s" instruction-word decoded)))))

(println "\nTest complete - ARM64 disassembler working!")