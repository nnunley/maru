;;; test-pic-simple.l - Simple PIC instruction test

(require "ir.k")

(println "=== Simple PIC Test ===")

;; ADRP instruction class
(define-class <ir-arm64-adrp> <ir-insn> (dst-reg symbol page-offset))

(define-function ir-arm64-adrp (dst symbol offset)
  (new <ir-arm64-adrp> (list dst symbol offset) () IR-VOID () dst symbol offset))

;; Register encoding
(define-function arm64-register-encoding (reg)
  (cond
    ((= reg 'x0) 0) ((= reg 'x1) 1) ((= reg 'x2) 2)
    (else 0)))

;; ADRP machine code generation
(define-method ir-gen-machine-code <ir-arm64-adrp> ()
  (let ((rd (arm64-register-encoding self.dst-reg))
        (page-offset self.page-offset))
    ;; ADRP: sf=1, immlo=offset[1:0], op=10000, immhi=offset[32:12], Rd
    (let ((sf 1)
          (immlo (& page-offset 3))
          (op 0x10)
          (immhi (& (>> page-offset 12) 0x7FFFF)))
      (+ (+ (+ (<< sf 31) (<< immlo 29)) (<< op 24)) (<< immhi 5)) rd))))

;; Assembly generation
(define-method ir-gen-assembly <ir-arm64-adrp> ()
  (print "adrp " self.dst-reg ", " self.symbol "@PAGE"))

;; Test ADRP
(let ((adrp-insn (ir-arm64-adrp 'x0 'my_symbol 0)))
  (println "Created ADRP instruction: " adrp-insn)
  (print "Assembly: ") (ir-gen-assembly adrp-insn) (println)
  (let ((code (ir-gen-machine-code adrp-insn)))
    (println "Machine code: " code)))

(println "\n=== PIC Test Complete ===")