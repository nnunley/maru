;; Simple ARM64 Disassembler
;; Basic instruction decoding for common ARM64 instructions

;; ARM64 instruction decoding utilities
(define-function _extract-bits (instruction-word start end)
  "Extract bits from start to end (inclusive) from instruction word"
  (& (>> instruction-word start) (- (<< 1 (+ (- end start) 1)) 1)))

(define-function _extract-bit (instruction-word pos)
  "Extract single bit at position"
  (_extract-bits instruction-word pos pos))

;; Register name lookup tables  
(define arm64-x-register-names 
  '("x0" "x1" "x2" "x3" "x4" "x5" "x6" "x7" "x8" "x9" "x10" "x11" "x12" "x13" "x14" "x15"
    "x16" "x17" "x18" "x19" "x20" "x21" "x22" "x23" "x24" "x25" "x26" "x27" "x28" "x29" "x30" "sp"))

(define arm64-w-register-names
  '("w0" "w1" "w2" "w3" "w4" "w5" "w6" "w7" "w8" "w9" "w10" "w11" "w12" "w13" "w14" "w15" 
    "w16" "w17" "w18" "w19" "w20" "w21" "w22" "w23" "w24" "w25" "w26" "w27" "w28" "w29" "w30" "wsp"))

;; Helper functions for register name lookup
(define-function _get-x-register-name (reg)
  (if (= reg 31) "xzr" (nth arm64-x-register-names reg)))

(define-function _get-w-register-name (reg)
  (if (= reg 31) "wzr" (nth arm64-w-register-names reg)))

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

;; Basic ARM64 instruction decoder
(define-function arm64-decode-simple (instruction-word)
  "Decode common ARM64 instructions"
  (cond
    ;; Return instruction (exact match)
    ((= instruction-word 0xD65F03C0)
     (new <arm64-instruction> 0 instruction-word "ret" ()))
    
    ;; Branch instructions (bits 31:26 = 000101 for B, 100101 for BL)
    ((= (_extract-bits instruction-word 26 31) 5)
     (arm64-decode-branch instruction-word))
    ((= (_extract-bits instruction-word 26 31) 37)
     (arm64-decode-branch-link instruction-word))
    
    ;; Move immediate (MOVZ: sf=x, opc=10, hw=xx, bits 31:23 = xx1100101)
    ((= (_extract-bits instruction-word 23 25) 5)
     (arm64-decode-move-immediate instruction-word))
    
    ;; Add/subtract immediate (bits 31:24 = x001000x or x101000x)
    ((or (= (_extract-bits instruction-word 24 30) 17)  ; 0010001
         (= (_extract-bits instruction-word 24 30) 81)  ; 1010001  
         (= (_extract-bits instruction-word 24 30) 49)  ; 0110001
         (= (_extract-bits instruction-word 24 30) 113)) ; 1110001
     (arm64-decode-add-sub-immediate instruction-word))
    
    ;; Load/store register (bits 31:24 = 111110xx)
    ((= (_extract-bits instruction-word 24 29) 62)
     (arm64-decode-load-store instruction-word))
    
    ;; Add/subtract shifted register (bits 31:24 = x001011x)
    ((or (= (_extract-bits instruction-word 24 30) 11)  ; 0001011
         (= (_extract-bits instruction-word 24 30) 75)  ; 1001011
         (= (_extract-bits instruction-word 24 30) 43)  ; 0101011
         (= (_extract-bits instruction-word 24 30) 107)) ; 1101011
     (arm64-decode-register-ops instruction-word))
    
    ;; Unknown instruction
    (else
     (new <arm64-instruction> 0 instruction-word "unknown" 
          (list (format "0x%08X" instruction-word)))))))

;; Decode ADD/SUB immediate instructions
(define-function arm64-decode-add-sub-immediate (instruction-word)
  (let ((sf (_extract-bit instruction-word 31))
        (op (_extract-bit instruction-word 30))
        (S (_extract-bit instruction-word 29))
        (imm12 (_extract-bits instruction-word 10 21))
        (Rn (_extract-bits instruction-word 5 9))
        (Rd (_extract-bits instruction-word 0 4)))
    
    (let ((mnemonic (cond
                      ((and (= op 0) (= S 0)) "add")
                      ((and (= op 0) (= S 1)) "adds")
                      ((and (= op 1) (= S 0)) "sub") 
                      ((and (= op 1) (= S 1)) "subs")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      ;; Handle CMP (SUBS with XZR destination)
      (if (and (= S 1) (= Rd 31))
          (new <arm64-instruction> 0 instruction-word "cmp"
               (list (reg-name Rn) (format "#%d" imm12)))
        (new <arm64-instruction> 0 instruction-word mnemonic
             (list (reg-name Rd) (reg-name Rn) (format "#%d" imm12)))))))

;; Decode load/store instructions
(define-function arm64-decode-load-store (instruction-word)
  (let ((size (_extract-bits instruction-word 30 31))
        (opc (_extract-bits instruction-word 22 23))
        (imm12 (_extract-bits instruction-word 10 21))
        (Rn (_extract-bits instruction-word 5 9))
        (Rt (_extract-bits instruction-word 0 4)))
    
    (let ((is-load (= (_extract-bit opc 1) 1))
          (mnemonic (if is-load "ldr" "str"))
          (reg-name (if (>= size 3) _get-x-register-name _get-w-register-name))
          (scale (cond ((= size 3) 8) ((= size 2) 4) ((= size 1) 2) (else 1))))
      
      (new <arm64-instruction> 0 instruction-word mnemonic
           (list (reg-name Rt) 
                 (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 scale)))))))

;; Decode move immediate instructions
(define-function arm64-decode-move-immediate (instruction-word)
  (let ((sf (_extract-bit instruction-word 31))
        (opc (_extract-bits instruction-word 29 30))
        (hw (_extract-bits instruction-word 21 22))
        (imm16 (_extract-bits instruction-word 5 20))
        (Rd (_extract-bits instruction-word 0 4)))
    
    (let ((mnemonic (cond
                      ((= opc 0) "movn")
                      ((= opc 2) "movz")
                      ((= opc 3) "movk")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      ;; MOV is an alias for MOVZ when hw=0
      (if (and (= opc 2) (= hw 0))
          (new <arm64-instruction> 0 instruction-word "mov"
               (list (reg-name Rd) (format "#%d" imm16)))
        (new <arm64-instruction> 0 instruction-word mnemonic
             (list (reg-name Rd) (format "#%d" imm16) (format "lsl #%d" (* hw 16))))))))

;; Decode register operations
(define-function arm64-decode-register-ops (instruction-word)
  (let ((sf (_extract-bit instruction-word 31))
        (op (_extract-bit instruction-word 30))
        (S (_extract-bit instruction-word 29))
        (Rm (_extract-bits instruction-word 16 20))
        (Rn (_extract-bits instruction-word 5 9))
        (Rd (_extract-bits instruction-word 0 4)))
    
    (let ((reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      ;; Simplified register operation decoding
      (cond
        ;; MOV (ORR with XZR)
        ((and (= Rn 31) (= op 1) (= S 0))
         (new <arm64-instruction> 0 instruction-word "mov"
              (list (reg-name Rd) (reg-name Rm))))
        
        ;; ADD register
        ((and (= op 0) (= S 0))
         (new <arm64-instruction> 0 instruction-word "add"
              (list (reg-name Rd) (reg-name Rn) (reg-name Rm))))
        
        ;; SUB register  
        ((and (= op 1) (= S 0))
         (new <arm64-instruction> 0 instruction-word "sub"
              (list (reg-name Rd) (reg-name Rn) (reg-name Rm))))
        
        (else
         (new <arm64-instruction> 0 instruction-word "reg-op"
              (list (reg-name Rd) (reg-name Rn) (reg-name Rm))))))))

;; Decode branch instructions
(define-function arm64-decode-branch (instruction-word)
  (let ((imm26 (_extract-bits instruction-word 0 25)))
    ;; Sign extend and scale by 4
    (let ((offset (* (if (> imm26 33554431) (- imm26 67108864) imm26) 4)))
      (new <arm64-instruction> 0 instruction-word "b" (list (format "#%+d" offset))))))

(define-function arm64-decode-branch-link (instruction-word)
  (let ((imm26 (_extract-bits instruction-word 0 25)))
    ;; Sign extend and scale by 4
    (let ((offset (* (if (> imm26 33554431) (- imm26 67108864) imm26) 4)))
      (new <arm64-instruction> 0 instruction-word "bl" (list (format "#%+d" offset))))))

;; High-level disassembler interface
(define-function arm64-disassemble-word (instruction-word)
  "Disassemble a single 32-bit ARM64 instruction"
  (arm64-decode-simple instruction-word))

(define-function arm64-disassemble-buffer (buffer)
  "Disassemble ARM64 code from a buffer"
  (let ((size (<buffer>-size buffer))
        (instructions ()))
    (for (offset 0 (/ size 4))
      (let ((addr (* offset 4)))
        (if (<= (+ addr 3) size)
            (let ((instruction-word (| (| (| (buffer-at buffer addr)
                                             (<< (buffer-at buffer (+ addr 1)) 8))
                                          (<< (buffer-at buffer (+ addr 2)) 16))
                                       (<< (buffer-at buffer (+ addr 3)) 24))))
              (let ((instruction (arm64-disassemble-word instruction-word)))
                (set (<arm64-instruction>-address instruction) addr)
                (push instructions instruction))))))
    (reverse instructions)))

(define-function arm64-print-disassembly (buffer)
  "Print disassembly with addresses"
  (let ((instructions (arm64-disassemble-buffer buffer)))
    (list-do instruction instructions
      (print (format "%08X: " (<arm64-instruction>-address instruction)))
      (print instruction)
      (println))))

;; Export main functions
(define arm64-disasm arm64-disassemble-word)
(define arm64-disasm-buffer arm64-disassemble-buffer)
(define arm64-disasm-print arm64-print-disassembly)