;;; ir-arm64.l - ARM64-specific IR Extensions
;;;
;;; Extends the IR system with ARM64-specific instructions and machine code generation
;;; Comprehensive instruction set based on Maru's ARM64 requirements

(require "ir.k")
(require "record-case.l")

;; Define helper functions we need
(define-function expt (base exp)
  "Simple exponentiation function"
  (if (= exp 0) 1
    (if (= exp 1) base
      (* base (expt base (- exp 1))))))

;; Basic ARM64 constants we need
(define-constant _X0  0)  (define-constant _X1  1)  (define-constant _X2  2)  (define-constant _X3  3)
(define-constant _X29 29) (define-constant _X30 30) (define-constant _SP  31) (define-constant _XZR 31)

;; ARM64-specific IR instruction base class
(define-class <ir-arm64-insn> <ir-insn> (encoding))

;; ARM64 register type
(define-class <ir-arm64-register> <ir-variable> (arch-id bit-width reg-type))

(define-method do-print <ir-arm64-register> ()
  (print "<arm64-" self.reg-type " " self.name " id=" self.arch-id " bits=" self.bit-width ">"))

;; Data Movement Instructions

(define-class <ir-arm64-mov-imm-x> <ir-arm64-insn> (immediate dst-reg))
(define-class <ir-arm64-mov-imm-w> <ir-arm64-insn> (immediate dst-reg))
(define-class <ir-arm64-mov-x-x> <ir-arm64-insn> (src-reg dst-reg))
(define-class <ir-arm64-mov-w-w> <ir-arm64-insn> (src-reg dst-reg))

;; Arithmetic Instructions

(define-class <ir-arm64-add-x-x-x> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-add-w-w-w> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-add-x-x-imm> <ir-arm64-insn> (dst-reg src-reg immediate))
(define-class <ir-arm64-add-w-w-imm> <ir-arm64-insn> (dst-reg src-reg immediate))

(define-class <ir-arm64-sub-x-x-x> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-sub-w-w-w> <ir-arm64-insn> (dst-reg src1-reg src2-reg))
(define-class <ir-arm64-sub-x-x-imm> <ir-arm64-insn> (dst-reg src-reg immediate))
(define-class <ir-arm64-sub-w-w-imm> <ir-arm64-insn> (dst-reg src-reg immediate))

;; Load/Store Instructions

(define-class <ir-arm64-ldr-x-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-ldr-w-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-str-x-mem> <ir-arm64-insn> (src-reg mem-ref))
(define-class <ir-arm64-str-w-mem> <ir-arm64-insn> (src-reg mem-ref))

(define-class <ir-arm64-ldrb-w-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-strb-w-mem> <ir-arm64-insn> (src-reg mem-ref))
(define-class <ir-arm64-ldrh-w-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-strh-w-mem> <ir-arm64-insn> (src-reg mem-ref))

(define-class <ir-arm64-ldp-x-x-mem> <ir-arm64-insn> (dst1-reg dst2-reg mem-ref))
(define-class <ir-arm64-stp-x-x-mem> <ir-arm64-insn> (src1-reg src2-reg mem-ref))

;; Compare Instructions

(define-class <ir-arm64-cmp-x-x> <ir-arm64-insn> (src1-reg src2-reg))
(define-class <ir-arm64-cmp-w-w> <ir-arm64-insn> (src1-reg src2-reg))
(define-class <ir-arm64-cmp-x-imm> <ir-arm64-insn> (src-reg immediate))
(define-class <ir-arm64-cmp-w-imm> <ir-arm64-insn> (src-reg immediate))

;; Branch Instructions

(define-class <ir-arm64-b-label> <ir-arm64-insn> (target-label))
(define-class <ir-arm64-beq-label> <ir-arm64-insn> (target-label))
(define-class <ir-arm64-bne-label> <ir-arm64-insn> (target-label))
(define-class <ir-arm64-blr-x> <ir-arm64-insn> (target-reg))
(define-class <ir-arm64-ret> <ir-arm64-insn> ())

;; Address Calculation

(define-class <ir-arm64-adrp-x-label> <ir-arm64-insn> (dst-reg target-label))

;; Conditional Set

(define-class <ir-arm64-cset-x-cond> <ir-arm64-insn> (dst-reg condition))
(define-class <ir-arm64-cset-w-cond> <ir-arm64-insn> (dst-reg condition))

;; Floating-point Instructions

(define-class <ir-arm64-ldr-d-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-str-d-mem> <ir-arm64-insn> (src-reg mem-ref))
(define-class <ir-arm64-ldr-s-mem> <ir-arm64-insn> (dst-reg mem-ref))
(define-class <ir-arm64-str-s-mem> <ir-arm64-insn> (src-reg mem-ref))

;; Instruction Constructors

(define-function ir-arm64-mov-imm-x (imm dst)
  "Create ARM64 move immediate to X register"
  (new <ir-arm64-mov-imm-x> (list imm dst) () IR-VOID () imm dst))

(define-function ir-arm64-mov-imm-w (imm dst)
