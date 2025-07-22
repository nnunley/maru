;; ARM64 Disassembler - Instruction Decoding and Formatting
;; Decodes ARM64 machine code back into readable assembly

(require "asm-arm64.k")

;; ARM64 instruction decoding utilities
(define-function _extract-bits (word start end)
  "Extract bits from start to end (inclusive) from word"
  (& (>> word start) (- (<< 1 (+ (- end start) 1)) 1)))

(define-function _extract-bit (word pos)
  "Extract single bit at position"
  (_extract-bits word pos pos))

;; Register name lookup tables
(define arm64-x-register-names 
  '("x0" "x1" "x2" "x3" "x4" "x5" "x6" "x7" "x8" "x9" "x10" "x11" "x12" "x13" "x14" "x15"
    "x16" "x17" "x18" "x19" "x20" "x21" "x22" "x23" "x24" "x25" "x26" "x27" "x28" "x29" "x30" "sp"))

(define arm64-w-register-names
  '("w0" "w1" "w2" "w3" "w4" "w5" "w6" "w7" "w8" "w9" "w10" "w11" "w12" "w13" "w14" "w15"
    "w16" "w17" "w18" "w19" "w20" "w21" "w22" "w23" "w24" "w25" "w26" "w27" "w28" "w29" "w30" "wsp"))

(define arm64-s-register-names
  '("s0" "s1" "s2" "s3" "s4" "s5" "s6" "s7" "s8" "s9" "s10" "s11" "s12" "s13" "s14" "s15"
    "s16" "s17" "s18" "s19" "s20" "s21" "s22" "s23" "s24" "s25" "s26" "s27" "s28" "s29" "s30" "s31"))

(define arm64-d-register-names
  '("d0" "d1" "d2" "d3" "d4" "d5" "d6" "d7" "d8" "d9" "d10" "d11" "d12" "d13" "d14" "d15"
    "d16" "d17" "d18" "d19" "d20" "d21" "d22" "d23" "d24" "d25" "d26" "d27" "d28" "d29" "d30" "d31"))

;; Condition code names
(define arm64-condition-names
  '("eq" "ne" "cs" "cc" "mi" "pl" "vs" "vc" "hi" "ls" "ge" "lt" "gt" "le" "al" "nv"))

;; Helper functions for register name lookup
(define-function _get-x-register-name (reg)
  (if (= reg 31) "xzr" (nth arm64-x-register-names reg)))

(define-function _get-w-register-name (reg)
  (if (= reg 31) "wzr" (nth arm64-w-register-names reg)))

(define-function _get-s-register-name (reg)
  (nth arm64-s-register-names reg))

(define-function _get-d-register-name (reg)
  (nth arm64-d-register-names reg))

(define-function _get-condition-name (cond)
  (nth arm64-condition-names cond))

;; Instruction decoder structure
(define-structure <arm64-instruction> (word mnemonic operands))

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

;; Main instruction decoder
(define-function arm64-decode-instruction (instruction-word)
  "Decode a 32-bit ARM64 instruction word"
  (let ((op0 (_extract-bits instruction-word 25 28))
        (op1 (_extract-bits instruction-word 22 24))
        (op2 (_extract-bits instruction-word 19 21))
        (op3 (_extract-bits instruction-word 16 18)))
    
    (cond
      ;; Data processing - immediate
      ((= op0 8) (arm64-decode-data-processing-immediate word))
      ((= op0 9) (arm64-decode-data-processing-immediate word))
      
      ;; Branch, exception generation, and system instructions  
      ((= op0 10) (arm64-decode-branch-exception-system word))
      ((= op0 11) (arm64-decode-branch-exception-system word))
      
      ;; Loads and stores
      ((= op0 4) (arm64-decode-loads-stores word))
      ((= op0 5) (arm64-decode-loads-stores word))
      ((= op0 6) (arm64-decode-loads-stores word))
      ((= op0 7) (arm64-decode-loads-stores word))
      ((= op0 12) (arm64-decode-loads-stores word))
      ((= op0 13) (arm64-decode-loads-stores word))
      ((= op0 14) (arm64-decode-loads-stores word))
      ((= op0 15) (arm64-decode-loads-stores word))
      
      ;; Data processing - register
      ((= op0 0) (arm64-decode-data-processing-register word))
      ((= op0 1) (arm64-decode-data-processing-register word))
      
      ;; Data processing - scalar floating-point and advanced SIMD
      ((= op0 2) (arm64-decode-scalar-fp-simd word))
      ((= op0 3) (arm64-decode-scalar-fp-simd word))
      
      (else (new <arm64-instruction> word "unknown" ())))))

;; Data processing - immediate instructions
(define-function arm64-decode-data-processing-immediate (word)
  (let ((sf (_extract-bit word 31))
        (op (_extract-bit word 30))
        (S (_extract-bit word 29))
        (op1 (_extract-bits word 23 24)))
    
    (cond
      ;; PC-rel addressing
      ((= op1 0) (arm64-decode-pc-rel-addressing word))
      
      ;; Add/subtract immediate
      ((= op1 1) (arm64-decode-add-sub-immediate word))
      
      ;; Logical immediate  
      ((= op1 2) (arm64-decode-logical-immediate word))
      
      ;; Move wide immediate
      ((= op1 3) (arm64-decode-move-wide-immediate word))
      
      (else (new <arm64-instruction> word "unknown" ())))))

;; PC-relative addressing
(define-function arm64-decode-pc-rel-addressing (word)
  (let ((op (_extract-bit word 31))
        (immlo (_extract-bits word 29 30))
        (immhi (_extract-bits word 5 23))
        (Rd (_extract-bits word 0 4))
        (imm (| (<< immhi 2) immlo)))
    
    (if (= op 0)
        (new <arm64-instruction> word "adr" 
             (list (_get-x-register-name Rd) (format "#0x%X" imm)))
      (new <arm64-instruction> word "adrp" 
           (list (_get-x-register-name Rd) (format "#0x%X" (<< imm 12)))))))

;; Add/subtract immediate
(define-function arm64-decode-add-sub-immediate (word)
  (let ((sf (_extract-bit word 31))
        (op (_extract-bit word 30))
        (S (_extract-bit word 29))
        (sh (_extract-bit word 22))
        (imm12 (_extract-bits word 10 21))
        (Rn (_extract-bits word 5 9))
        (Rd (_extract-bits word 0 4)))
    
    (let ((mnemonic (cond
                      ((and (= op 0) (= S 0)) (if (= sf 1) "add" "add"))
                      ((and (= op 0) (= S 1)) (if (= sf 1) "adds" "adds"))
                      ((and (= op 1) (= S 0)) (if (= sf 1) "sub" "sub"))
                      ((and (= op 1) (= S 1)) (if (= sf 1) "subs" "subs"))
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name))
          (imm-val (if (= sh 1) (<< imm12 12) imm12)))
      
      ;; Handle special cases like CMP (SUBS with XZR destination)
      (if (and (= S 1) (= Rd 31))
          (new <arm64-instruction> word "cmp"
               (list (reg-name Rn) (format "#%d" imm-val)))
        (new <arm64-instruction> word mnemonic
             (list (reg-name Rd) (reg-name Rn) (format "#%d" imm-val)))))))

;; Move wide immediate
(define-function arm64-decode-move-wide-immediate (word)
  (let ((sf (_extract-bit word 31))
        (opc (_extract-bits word 29 30))
        (hw (_extract-bits word 21 22))
        (imm16 (_extract-bits word 5 20))
        (Rd (_extract-bits word 0 4)))
    
    (let ((mnemonic (cond
                      ((= opc 0) "movn")
                      ((= opc 2) "movz") 
                      ((= opc 3) "movk")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name))
          (shift (* hw 16)))
      
      ;; Special case: MOV (alias for MOVZ when shift is 0 and not all bits set)
      (if (and (= opc 2) (= hw 0))
          (new <arm64-instruction> word "mov"
               (list (reg-name Rd) (format "#%d" imm16)))
        (if (= shift 0)
            (new <arm64-instruction> word mnemonic
                 (list (reg-name Rd) (format "#%d" imm16)))
          (new <arm64-instruction> word mnemonic
               (list (reg-name Rd) (format "#%d" imm16) (format "lsl #%d" shift))))))))

;; Logical immediate
(define-function arm64-decode-logical-immediate (word)
  (let ((sf (_extract-bit word 31))
        (opc (_extract-bits word 29 30))
        (N (_extract-bit word 22))
        (immr (_extract-bits word 16 21))
        (imms (_extract-bits word 10 15))
        (Rn (_extract-bits word 5 9))
        (Rd (_extract-bits word 0 4)))
    
    (let ((mnemonic (cond
                      ((= opc 0) "and")
                      ((= opc 1) "orr")
                      ((= opc 2) "eor")
                      ((= opc 3) "ands")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      ;; Simplified immediate display (proper decoding would need bitmask logic)
      (new <arm64-instruction> word mnemonic
           (list (reg-name Rd) (reg-name Rn) (format "#0x%X" (| (<< immr 6) imms)))))))

;; Data processing - register instructions
(define-function arm64-decode-data-processing-register (word)
  (let ((op0 (_extract-bit word 30))
        (op1 (_extract-bit word 28))
        (op2 (_extract-bits word 21 24))
        (op3 (_extract-bits word 10 15)))
    
    (cond
      ;; Logical (shifted register)
      ((and (= op0 0) (= op1 0) (= op2 0)) (arm64-decode-logical-shifted-register word))
      
      ;; Add/subtract (shifted register)  
      ((and (= op0 0) (= op1 0) (= op2 1)) (arm64-decode-add-sub-shifted-register word))
      
      ;; Add/subtract (extended register)
      ((and (= op0 0) (= op1 0) (= op2 3)) (arm64-decode-add-sub-extended-register word))
      
      ;; Data processing (2 source)
      ((and (= op0 0) (= op1 1) (= op2 6)) (arm64-decode-data-processing-2source word))
      
      ;; Data processing (1 source)  
      ((and (= op0 1) (= op1 1) (= op2 6)) (arm64-decode-data-processing-1source word))
      
      (else (new <arm64-instruction> word "unknown" ())))))

;; Add/subtract shifted register
(define-function arm64-decode-add-sub-shifted-register (word)
  (let ((sf (_extract-bit word 31))
        (op (_extract-bit word 30))
        (S (_extract-bit word 29))
        (shift (_extract-bits word 22 23))
        (Rm (_extract-bits word 16 20))
        (imm6 (_extract-bits word 10 15))
        (Rn (_extract-bits word 5 9))
        (Rd (_extract-bits word 0 4)))
    
    (let ((mnemonic (cond
                      ((and (= op 0) (= S 0)) "add")
                      ((and (= op 0) (= S 1)) "adds")
                      ((and (= op 1) (= S 0)) "sub")
                      ((and (= op 1) (= S 1)) "subs")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name))
          (shift-name (nth '("lsl" "lsr" "asr" "reserved") shift)))
      
      ;; Handle CMP special case
      (if (and (= S 1) (= Rd 31))
          (if (= imm6 0)
              (new <arm64-instruction> word "cmp"
                   (list (reg-name Rn) (reg-name Rm)))
            (new <arm64-instruction> word "cmp"
                 (list (reg-name Rn) (reg-name Rm) (format "%s #%d" shift-name imm6))))
        (if (= imm6 0)
            (new <arm64-instruction> word mnemonic
                 (list (reg-name Rd) (reg-name Rn) (reg-name Rm)))
          (new <arm64-instruction> word mnemonic
               (list (reg-name Rd) (reg-name Rn) (reg-name Rm) (format "%s #%d" shift-name imm6))))))))

;; Logical shifted register
(define-function arm64-decode-logical-shifted-register (word)
  (let ((sf (_extract-bit word 31))
        (opc (_extract-bits word 29 30))
        (shift (_extract-bits word 22 23))
        (N (_extract-bit word 21))
        (Rm (_extract-bits word 16 20))
        (imm6 (_extract-bits word 10 15))
        (Rn (_extract-bits word 5 9))
        (Rd (_extract-bits word 0 4)))
    
    (let ((mnemonic (cond
                      ((and (= opc 0) (= N 0)) "and")
                      ((and (= opc 0) (= N 1)) "bic")
                      ((and (= opc 1) (= N 0)) "orr")
                      ((and (= opc 1) (= N 1)) "orn")
                      ((and (= opc 2) (= N 0)) "eor")
                      ((and (= opc 2) (= N 1)) "eon")
                      ((and (= opc 3) (= N 0)) "ands")
                      ((and (= opc 3) (= N 1)) "bics")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name))
          (shift-name (nth '("lsl" "lsr" "asr" "ror") shift)))
      
      ;; Handle MOV special case (ORR with XZR)
      (if (and (= opc 1) (= N 0) (= Rn 31) (= imm6 0))
          (new <arm64-instruction> word "mov"
               (list (reg-name Rd) (reg-name Rm)))
        (if (= imm6 0)
            (new <arm64-instruction> word mnemonic
                 (list (reg-name Rd) (reg-name Rn) (reg-name Rm)))
          (new <arm64-instruction> word mnemonic
               (list (reg-name Rd) (reg-name Rn) (reg-name Rm) (format "%s #%d" shift-name imm6))))))))

;; Loads and stores
(define-function arm64-decode-loads-stores (word)
  (let ((op0 (_extract-bits word 28 31))
        (op1 (_extract-bit word 26))
        (op2 (_extract-bits word 23 24))
        (op3 (_extract-bits word 16 21))
        (op4 (_extract-bits word 10 11)))
    
    (cond
      ;; Load/store register (immediate post-indexed)
      ((and (>= op0 14) (<= op0 15)) (arm64-decode-load-store-register-immediate word))
      
      ;; Load/store register (immediate pre-indexed)  
      ((and (>= op0 14) (<= op0 15)) (arm64-decode-load-store-register-immediate word))
      
      ;; Load/store register (unsigned immediate)
      ((and (>= op0 14) (<= op0 15)) (arm64-decode-load-store-register-immediate word))
      
      ;; Load/store register pair
      ((and (>= op0 10) (<= op0 11)) (arm64-decode-load-store-register-pair word))
      
      (else (new <arm64-instruction> word "unknown" ())))))

;; Load/store register immediate
(define-function arm64-decode-load-store-register-immediate (word)
  (let ((size (_extract-bits word 30 31))
        (opc (_extract-bits word 22 23))
        (imm12 (_extract-bits word 10 21))
        (Rn (_extract-bits word 5 9))
        (Rt (_extract-bits word 0 4)))
    
    (let ((is-load (= (_extract-bit opc 1) 1))
          (is-64bit (>= size 3)))
      
      (cond
        ;; 64-bit operations
        ((= size 3)
         (if is-load
             (new <arm64-instruction> word "ldr"
                  (list (_get-x-register-name Rt) 
                        (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 8))))
           (new <arm64-instruction> word "str"
                (list (_get-x-register-name Rt)
                      (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 8))))))
        
        ;; 32-bit operations
        ((= size 2)
         (if is-load
             (new <arm64-instruction> word "ldr"
                  (list (_get-w-register-name Rt)
                        (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 4))))
           (new <arm64-instruction> word "str"
                (list (_get-w-register-name Rt)
                      (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 4))))))
        
        ;; 16-bit operations
        ((= size 1)
         (if is-load
             (new <arm64-instruction> word "ldrh"
                  (list (_get-w-register-name Rt)
                        (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 2))))
           (new <arm64-instruction> word "strh"
                (list (_get-w-register-name Rt)
                      (format "[%s, #%d]" (_get-x-register-name Rn) (* imm12 2))))))
        
        ;; 8-bit operations
        ((= size 0)
         (if is-load
             (new <arm64-instruction> word "ldrb"
                  (list (_get-w-register-name Rt)
                        (format "[%s, #%d]" (_get-x-register-name Rn) imm12)))
           (new <arm64-instruction> word "strb"
                (list (_get-w-register-name Rt)
                      (format "[%s, #%d]" (_get-x-register-name Rn) imm12)))))
        
        (else (new <arm64-instruction> word "unknown" ()))))))

;; Load/store register pair
(define-function arm64-decode-load-store-register-pair (word)
  (let ((opc (_extract-bits word 30 31))
        (L (_extract-bit word 22))
        (imm7 (_extract-bits word 15 21))
        (Rt2 (_extract-bits word 10 14))
        (Rn (_extract-bits word 5 9))
        (Rt (_extract-bits word 0 4)))
    
    (let ((is-64bit (= opc 2))
          (offset (* imm7 (if (= opc 2) 8 4))))
      
      (if (= L 1)
          (new <arm64-instruction> word "ldp"
               (list (if is-64bit (_get-x-register-name Rt) (_get-w-register-name Rt))
                     (if is-64bit (_get-x-register-name Rt2) (_get-w-register-name Rt2))
                     (format "[%s, #%d]" (_get-x-register-name Rn) offset)))
        (new <arm64-instruction> word "stp"
             (list (if is-64bit (_get-x-register-name Rt) (_get-w-register-name Rt))
                   (if is-64bit (_get-x-register-name Rt2) (_get-w-register-name Rt2))
                   (format "[%s, #%d]" (_get-x-register-name Rn) offset)))))))

;; Branch, exception generation, and system instructions
(define-function arm64-decode-branch-exception-system (word)
  (let ((op0 (_extract-bits word 29 31))
        (op1 (_extract-bits word 12 25))
        (op2 (_extract-bits word 0 4)))
    
    (cond
      ;; Unconditional branch (immediate)
      ((and (= op0 0) (= (_extract-bits op1 10 13) 5)) (arm64-decode-unconditional-branch-immediate word))
      
      ;; Compare and branch (immediate) 
      ((and (= op0 1) (= (_extract-bits op1 10 13) 4)) (arm64-decode-compare-branch-immediate word))
      
      ;; Conditional branch (immediate)
      ((and (= op0 2) (= (_extract-bits op1 10 13) 4)) (arm64-decode-conditional-branch-immediate word))
      
      ;; Unconditional branch (register)
      ((and (= op0 3) (= (_extract-bits op1 10 13) 4)) (arm64-decode-unconditional-branch-register word))
      
      (else (new <arm64-instruction> word "unknown" ())))))

;; Unconditional branch immediate
(define-function arm64-decode-unconditional-branch-immediate (word)
  (let ((op (_extract-bit word 31))
        (imm26 (_extract-bits word 0 25)))
    
    ;; Sign extend imm26 and scale by 4
    (let ((offset (* (if (> imm26 (/ (expt 2 25) 1)) (- imm26 (expt 2 26)) imm26) 4)))
      (if (= op 0)
          (new <arm64-instruction> word "b" (list (format "#%+d" offset)))
        (new <arm64-instruction> word "bl" (list (format "#%+d" offset)))))))

;; Conditional branch immediate
(define-function arm64-decode-conditional-branch-immediate (word)
  (let ((imm19 (_extract-bits word 5 23))
        (cond (_extract-bits word 0 3)))
    
    ;; Sign extend imm19 and scale by 4
    (let ((offset (* (if (> imm19 (/ (expt 2 18) 1)) (- imm19 (expt 2 19)) imm19) 4)))
      (new <arm64-instruction> word (format "b.%s" (_get-condition-name cond))
           (list (format "#%+d" offset))))))

;; Unconditional branch register
(define-function arm64-decode-unconditional-branch-register (word)
  (let ((opc (_extract-bits word 21 24))
        (op2 (_extract-bits word 16 20))
        (op3 (_extract-bits word 10 15))
        (Rn (_extract-bits word 5 9))
        (op4 (_extract-bits word 0 4)))
    
    (cond
      ((and (= opc 0) (= op2 31) (= op3 0) (= op4 0)) 
       (new <arm64-instruction> word "br" (list (_get-x-register-name Rn))))
      ((and (= opc 1) (= op2 31) (= op3 0) (= op4 0))
       (new <arm64-instruction> word "blr" (list (_get-x-register-name Rn))))
      ((and (= opc 2) (= op2 31) (= op3 0) (= op4 0))
       (new <arm64-instruction> word "ret" (if (= Rn 30) () (list (_get-x-register-name Rn)))))
      (else (new <arm64-instruction> word "unknown" ())))))

;; Scalar floating-point and advanced SIMD (simplified)
(define-function arm64-decode-scalar-fp-simd (word)
  (new <arm64-instruction> word "simd/fp" ()))

;; Data processing 2-source
(define-function arm64-decode-data-processing-2source (word)
  (let ((sf (_extract-bit word 31))
        (opcode (_extract-bits word 10 15))
        (Rm (_extract-bits word 16 20))
        (Rn (_extract-bits word 5 9))
        (Rd (_extract-bits word 0 4)))
    
    (let ((mnemonic (cond
                      ((= opcode 2) "udiv")
                      ((= opcode 3) "sdiv")
                      ((= opcode 8) "lsl")
                      ((= opcode 9) "lsr") 
                      ((= opcode 10) "asr")
                      ((= opcode 11) "ror")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      (new <arm64-instruction> word mnemonic
           (list (reg-name Rd) (reg-name Rn) (reg-name Rm))))))

;; Data processing 1-source  
(define-function arm64-decode-data-processing-1source (word)
  (let ((sf (_extract-bit word 31))
        (opcode (_extract-bits word 10 15))
        (Rn (_extract-bits word 5 9))
        (Rd (_extract-bits word 0 4)))
    
    (let ((mnemonic (cond
                      ((= opcode 0) "rbit")
                      ((= opcode 1) "rev16")
                      ((= opcode 2) "rev32")
                      ((= opcode 3) "rev")
                      ((= opcode 4) "clz")
                      ((= opcode 5) "cls")
                      (else "unknown")))
          (reg-name (if (= sf 1) _get-x-register-name _get-w-register-name)))
      
      (new <arm64-instruction> word mnemonic
           (list (reg-name Rd) (reg-name Rn))))))

;; High-level disassembler interface
(define-function arm64-disassemble-word (instruction-word)
  "Disassemble a single 32-bit ARM64 instruction"
  (arm64-decode-instruction instruction-word))

(define-function arm64-disassemble-buffer (buffer)
  "Disassemble ARM64 code from a buffer"
  (let ((size (<buffer>-size buffer))
        (instructions ()))
    (for (offset 0 (/ size 4))
      (let ((addr (* offset 4)))
        (if (<= (+ addr 3) size)
            (let ((word (| (| (| (buffer-at buffer addr)
                                (<< (buffer-at buffer (+ addr 1)) 8))
                             (<< (buffer-at buffer (+ addr 2)) 16))
                          (<< (buffer-at buffer (+ addr 3)) 24))))
              (let ((instruction (arm64-disassemble-word word)))
                (set (<arm64-instruction>-word instruction) addr)
                (push instructions instruction))))))
    (reverse instructions)))

(define-function arm64-disassemble-file (filename)
  "Disassemble ARM64 code from a file"
  (let ((buffer (buffer-new 1024)))
    (buffer-load buffer filename)
    (arm64-disassemble-buffer buffer)))

(define-function arm64-print-disassembly (buffer)
  "Print disassembly with addresses"
  (let ((instructions (arm64-disassemble-buffer buffer)))
    (list-do instruction instructions
      (print (format "%08X: " (<arm64-instruction>-word instruction)))
      (print instruction)
      (println))))

;; Test function to verify disassembler
(define-function arm64-disassemble-test ()
  "Test the ARM64 disassembler with sample instructions"
  (let ((test-words (list
                      0xD10043FF  ; sub sp, sp, #16
                      0xF90007FD  ; str x29, [sp, #8]  
                      0x910023FD  ; add x29, sp, #8
                      0x52800800  ; mov w0, #64
                      0xF94007FD  ; ldr x29, [sp, #8]
                      0x910043FF  ; add sp, sp, #16
                      0xD65F03C0  ; ret
                      0x14000000  ; b #0
                      0x97FFFFFF  ; bl #-4
                      0x54000040  ; b.eq #8
                      )))
    
    (println "ARM64 Disassembler Test:")
    (list-do word test-words
      (let ((instruction (arm64-disassemble-word word)))
        (println (format "%08X: %s" word instruction))))))

;; Export main functions
(define arm64-disasm arm64-disassemble-word)
(define arm64-disasm-buffer arm64-disassemble-buffer)
(define arm64-disasm-print arm64-print-disassembly)