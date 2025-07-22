;; Minimal ARM64 disassembler test

;; Extract bits utility
(define-function _extract-bits (instruction-word start end)
  (& (>> instruction-word start) (- (<< 1 (+ (- end start) 1)) 1)))

;; Simple instruction structure
(define-structure <arm64-instruction> (address opcode mnemonic operands))

(define-method do-print <arm64-instruction> ()
  (print self.mnemonic)
  (if self.operands
      (let ((first-operand 1))
        (print "\t")
        (list-do operand self.operands
          (if first-operand
              (set first-operand ())
            (print ", "))
          (print operand)))))

;; Minimal decoder - just handle RET instruction
(define-function arm64-decode-minimal (instruction-word)
  (cond
    ((= instruction-word 0xD65F03C0)
     (new <arm64-instruction> 0 instruction-word "ret" ()))
    (else
     (new <arm64-instruction> 0 instruction-word "unknown" 
          (list (format "0x%08X" instruction-word))))))

;; Test function
(define-function arm64-disasm-minimal (instruction-word)
  (arm64-decode-minimal instruction-word))

;; Test it
(println "Testing minimal ARM64 disassembler:")

(let ((inst (arm64-disasm-minimal 0xD65F03C0)))
  (print "D65F03C0: ")
  (println inst))

(let ((inst (arm64-disasm-minimal 0x12345678)))
  (print "12345678: ")
  (println inst))

(println "Minimal test complete!")