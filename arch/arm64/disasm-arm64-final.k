;; ARM64 Disassembler - Final Working Version
;; Supports common ARM64 instructions used by the Maru backend

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

;; ARM64 instruction structure
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

;; Main ARM64 instruction decoder
(define-function arm64-decode-instruction (instruction-word)
  "Decode common ARM64 instructions"
  (cond
    ;; Return instruction (exact match)
    ((= instruction-word 0xD65F03C0)
     (new <arm64-instruction> 0 instruction-word "ret" ()))
    
    ;; Move immediate instructions (MOVZ: bits 23-25 = 101)
    ((= (_extract-bits instruction-word 23 25) 5)
     (arm64-decode-move-immediate instruction-word))
    
    ;; Add/subtract immediate (bits 24-28 contain 10001)
    ((= (_extract-bits instruction-word 24 28) 17)
     (arm64-decode-add-sub-immediate instruction-word))
    
    ;; Load/store register (bits 24-27 = 1111)  
    ((= (_extract-bits instruction-word 24 27) 15)
     (arm64-decode-load-store instruction-word))
    
    ;; Branch instructions (bits 26-30 = 00101 for B, 10010 for BL)
    ((= (_extract-bits instruction-word 26 30) 5)
     (arm64-decode-branch instruction-word))
    ((= (_extract-bits instruction-word 26 30) 18)
     (arm64-decode-branch-link instruction-word))
    
    ;; Add/subtract shifted register (bits 24-28 = 01011)
    ((= (_extract-bits instruction-word 24 28) 11)
     (arm64-decode-add-sub-register instruction-word))
    
    ;; Logical shifted register (bits 24-28 = 01010)
    ((= (_extract-bits instruction-word 24 28) 10)
     (arm64-decode-logical-register instruction-word))
    
    ;; Unknown instruction
    (else
     (new <arm64-instruction> 0 instruction-word "unknown" 
          (list (format "0x%08X" instruction-word))))))

;; Decode move immediate instructions (MOV, MOVZ, MOVK, MOVN)
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
                      (else "mov")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      ;; MOV is an alias for MOVZ when hw=0 and not inverting
      (if (and (= opc 2) (= hw 0))
          (new <arm64-instruction> 0 instruction-word "mov"
               (list (reg-name Rd) (format "#%d" imm16)))
        (if (= hw 0)
            (new <arm64-instruction> 0 instruction-word mnemonic
                 (list (reg-name Rd) (format "#%d" imm16)))
          (new <arm64-instruction> 0 instruction-word mnemonic
               (list (reg-name Rd) (format "#%d" imm16) (format "lsl #%d" (* hw 16)))))))))

;; Decode add/subtract immediate instructions
(define-function arm64-decode-add-sub-immediate (instruction-word)
  (let ((sf (_extract-bit instruction-word 31))
        (op (_extract-bit instruction-word 30))
        (S (_extract-bit instruction-word 29))
        (sh (_extract-bit instruction-word 22))
        (imm12 (_extract-bits instruction-word 10 21))
        (Rn (_extract-bits instruction-word 5 9))
        (Rd (_extract-bits instruction-word 0 4)))
    
    (let ((mnemonic (cond
                      ((and (= op 0) (= S 0)) "add")
                      ((and (= op 0) (= S 1)) "adds")
                      ((and (= op 1) (= S 0)) "sub")
                      ((and (= op 1) (= S 1)) "subs")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name))
          (imm-val (if (= sh 1) (<< imm12 12) imm12)))
      
      ;; Handle CMP (SUBS with XZR destination)
      (if (and (= S 1) (= Rd 31))
          (new <arm64-instruction> 0 instruction-word "cmp"
               (list (reg-name Rn) (format "#%d" imm-val)))
        (new <arm64-instruction> 0 instruction-word mnemonic
             (list (reg-name Rd) (reg-name Rn) (format "#%d" imm-val)))))))

;; Decode load/store register instructions
(define-function arm64-decode-load-store (instruction-word)
  (let ((size (_extract-bits instruction-word 30 31))
        (opc (_extract-bits instruction-word 22 23))
        (imm12 (_extract-bits instruction-word 10 21))
        (Rn (_extract-bits instruction-word 5 9))
        (Rt (_extract-bits instruction-word 0 4)))
    
    (let ((is-load (= (_extract-bit opc 1) 1))
          (reg-name (if (>= size 3) _get-x-register-name _get-w-register-name))
          (scale (cond ((= size 3) 8) ((= size 2) 4) ((= size 1) 2) (else 1))))
      
      (cond
        ;; Byte operations
        ((= size 0)
         (if is-load
             (new <arm64-instruction> 0 instruction-word "ldrb"
                  (list (_get-w-register-name Rt) 
                        (format "[%s, #%d]" (_get-x-register-name Rn) imm12)))
           (new <arm64-instruction> 0 instruction-word "strb"
                (list (_get-w-register-name Rt)
                      (format "[%s, #%d]" (_get-x-register-name Rn) imm12)))))
        
        ;; Halfword operations
        ((= size 1)
         (if is-load
             (new <arm64-instruction> 0 instruction-word "ldrh"
                  (list (_get-w-register-name Rt)
                        (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 2))))
           (new <arm64-instruction> 0 instruction-word "strh"
                (list (_get-w-register-name Rt)
                      (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 2))))))
        
        ;; Word and doubleword operations
        (else
         (if is-load
             (new <arm64-instruction> 0 instruction-word "ldr"
                  (list (reg-name Rt)
                        (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 scale))))
           (new <arm64-instruction> 0 instruction-word "str"
                (list (reg-name Rt)
                      (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 scale)))))))))

;; Decode add/subtract register instructions
(define-function arm64-decode-add-sub-register (instruction-word)
  (let ((sf (_extract-bit instruction-word 31))
        (op (_extract-bit instruction-word 30))
        (S (_extract-bit instruction-word 29))
        (shift (_extract-bits instruction-word 22 23))
        (Rm (_extract-bits instruction-word 16 20))
        (imm6 (_extract-bits instruction-word 10 15))
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
               (list (reg-name Rn) (reg-name Rm)))
        (new <arm64-instruction> 0 instruction-word mnemonic
             (list (reg-name Rd) (reg-name Rn) (reg-name Rm)))))))

;; Decode logical register instructions (AND, ORR, EOR, etc.)
(define-function arm64-decode-logical-register (instruction-word)
  (let ((sf (_extract-bit instruction-word 31))
        (opc (_extract-bits instruction-word 29 30))
        (shift (_extract-bits instruction-word 22 23))
        (N (_extract-bit instruction-word 21))
        (Rm (_extract-bits instruction-word 16 20))
        (imm6 (_extract-bits instruction-word 10 15))
        (Rn (_extract-bits instruction-word 5 9))
        (Rd (_extract-bits instruction-word 0 4)))
    
    (let ((mnemonic (cond
                      ((and (= opc 1) (= N 0)) "orr")
                      ((and (= opc 2) (= N 0)) "eor")
                      ((and (= opc 0) (= N 0)) "and")
                      (else "logical")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      ;; Handle MOV (ORR with XZR source)
      (if (and (= opc 1) (= N 0) (= Rn 31) (= imm6 0))
          (new <arm64-instruction> 0 instruction-word "mov"
               (list (reg-name Rd) (reg-name Rm)))
        (new <arm64-instruction> 0 instruction-word mnemonic
             (list (reg-name Rd) (reg-name Rn) (reg-name Rm)))))))

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
  (arm64-decode-instruction instruction-word))

;; Export main functions
(define arm64-disasm arm64-disassemble-word)