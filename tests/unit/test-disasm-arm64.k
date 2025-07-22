;; Test ARM64 Disassembler
;; Simple test to verify ARM64 disassembler functionality

(require "disasm-arm64.k")

(println "Testing ARM64 Disassembler")
(println "========================")

;; Test individual instruction decoding
(println "\n1. Testing individual instructions:")

(let ((test-cases (list
                    (list 0xD10043FF "sub sp, sp, #16")
                    (list 0xF90007FD "str x29, [sp, #8]") 
                    (list 0x910023FD "add x29, sp, #8")
                    (list 0x52800800 "mov w0, #64")
                    (list 0xAA0003E0 "mov x0, x0")
                    (list 0xF94007FD "ldr x29, [sp, #8]")
                    (list 0x910043FF "add sp, sp, #16")
                    (list 0xD65F03C0 "ret")
                    (list 0x14000000 "b #0")
                    (list 0x97FFFFFF "bl #-4")
                    (list 0x54000040 "b.eq #8")
                    (list 0xEB00001F "cmp x0, x0")
                    (list 0x9A801020 "cset x0, eq")
                    )))
  
  (list-do test-case test-cases
    (let ((word (car test-case))
          (expected (cadr test-case))
          (instruction (arm64-disassemble-word word)))
      (println (format "%08X: %s" word instruction)))))

;; Test buffer disassembly
(println "\n2. Testing buffer disassembly:")

(let ((buffer (buffer-new 64)))
  ;; Simple function: mov w0, #42; ret
  (buffer-write-long buffer 0x52800540)  ; mov w0, #42
  (buffer-write-long buffer 0xD65F03C0)  ; ret
  
  (println "Function code:")
  (arm64-print-disassembly buffer))

;; Test more complex instruction patterns
(println "\n3. Testing complex instruction patterns:")

(let ((complex-buffer (buffer-new 128)))
  ;; Function prologue
  (buffer-write-long complex-buffer 0xA9BF7BFD)  ; stp x29, x30, [sp, #-16]!
  (buffer-write-long complex-buffer 0x910003FD)  ; mov x29, sp
  
  ;; Load and store operations
  (buffer-write-long complex-buffer 0xF9000BE0)  ; str x0, [sp, #16]
  (buffer-write-long complex-buffer 0xF9400BE0)  ; ldr x0, [sp, #16]
  
  ;; Arithmetic operations
  (buffer-write-long complex-buffer 0x91000400)  ; add x0, x0, #1
  (buffer-write-long complex-buffer 0xD1000400)  ; sub x0, x0, #1
  
  ;; Function epilogue
  (buffer-write-long complex-buffer 0xA8C17BFD)  ; ldp x29, x30, [sp], #16
  (buffer-write-long complex-buffer 0xD65F03C0)  ; ret
  
  (println "Complex function:")
  (arm64-print-disassembly complex-buffer))

;; Test error handling
(println "\n4. Testing unknown instruction handling:")

(let ((unknown-instruction (arm64-disassemble-word 0x00000000)))
  (println (format "00000000: %s" unknown-instruction)))

(println "\nARM64 Disassembler test complete!")