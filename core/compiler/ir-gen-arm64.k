;;; ir-gen-arm64.k - ARM64 code generation backend
;;; This backend uses the define-emit pattern for consistency.

(require "core/compiler/emit.l")
(require "arch/arm64/asm-arm64.k") ;; For register constants

;;; --- ARM64 Backend Activation ---
(define-function use-arm64-backend ()
  "Activates the ARM64 backend and loads its instruction emitters."
  (println ";; Activating ARM64 define-emit backend.")
  (set *emit-backend* 'arm64)
  (load-arm64-emitters))

;;; --- ARM64 Operands ---
;; These operands generate ARM64 assembly syntax.

(define-operand REG (num size)
  "Represents an ARM64 register (e.g., x0, w0)."
  (if (= (<REG>-size self) 64)
      (format "x%d" (<REG>-num self))
    (format "w%d" (<REG>-num self))))

(define-operand IMM (value)
  "Represents an immediate value (e.g., #42)."
  (format "#%d" (<IMM>-value self)))

(define-operand MEM (base offset)
  "Represents a memory operand with base register and immediate offset."
  (format "[%s, #%d]" (<REG>-name (<MEM>-base self)) (<MEM>-offset self)))

(define-operand MEM_PRE (base offset)
  "Represents a memory operand with pre-indexing."
  (format "[%s, #%d]!" (<REG>-name (<MEM_PRE>-base self)) (<MEM_PRE>-offset self)))

(define-operand MEM_POST (base offset)
  "Represents a memory operand with post-indexing."
  (format "[%s], #%d" (<REG>-name (<MEM_POST>-base self)) (<MEM_POST>-offset self)))

(define-operand GVAR (name)
  "Represents a global variable, which requires PC-relative addressing."
  (format "%s" (<GVAR>-name self)))

;;; --- ARM64 Emitters ---

;; --- Data and Section Directives ---
(define-emit (TEXT)			(println "	.text"))
(define-emit (DATA)			(println "	.data"))
(define-emit (SECTION string)	(println "	.section "$1))
(define-emit (GLOBAL LABEL)		(println "	.globl "$1))
(define-emit (ALIGN long)		(println "	.align "$1))
(define-emit (LONG long)		(println "	.long "$1))
(define-emit (LONG LABEL)		(println "	.long "$1))
(define-emit (ASCIZ string)		(print   "	.asciz ") (dumpln $1))
(define-emit (DEFLABEL LABEL)	(println $1":"))

;; --- Function Prologue & Epilogue ---
;; $1: frame size in bytes
(define-emit (ENTER long)
  (println "	stp	x29, x30, [sp, #-16]!")
  (println "	mov	x29, sp")
  (if (> $1 0)
      (println "	sub	sp, sp, #"$1)))

;; $1: frame size in bytes
(define-emit (LEAVE long)
  (if (> $1 0)
      (println "	mov	sp, x29"))
  (println "	ldp	x29, x30, [sp], #16")
  (println "	ret"))

;; --- Load/Store/Move ---
;; Load from memory into register
(define-emit (LOAD REG MEM)   (println "	ldr	"$1", "$2))
;; Load from global variable
(define-emit (LOAD REG GVAR)  (println "	adrp	x9, "$2"@PAGE")
                              (println "	add	x9, x9, "$2"@PAGEOFF")
                              (println "	ldr	"$1", [x9]"))
;; Load immediate value
(define-emit (LOAD REG IMM)   (println "	mov	"$1", "$2))

;; Store register to memory
(define-emit (STORE REG MEM)  (println "	str	"$1", "$2))
;; Store register to global
(define-emit (STORE REG GVAR) (println "	adrp	x9, "$2"@PAGE")
                              (println "	add	x9, x9, "$2"@PAGEOFF")
                              (println "	str	"$1", [x9]"))

;; Move between registers
(define-emit (MOVE REG REG)   (println "	mov	"$1", "$2))

;; --- Arithmetic ---
(define-emit (ADD REG REG REG) (println "	add	"$1", "$2", "$3))
(define-emit (SUB REG REG REG) (println "	sub	"$1", "$2", "$3))
(define-emit (MUL REG REG REG) (println "	mul	"$1", "$2", "$3))
(define-emit (DIV REG REG REG) (println "	sdiv	"$1", "$2", "$3))
(define-emit (NEG REG)         (println "	neg	"$1", "$1))

;; --- Comparison ---
(define-emit (CMP REG REG)    (println "	cmp	"$1", "$2))
(define-emit (CSET REG symbol) (println "	cset	"$1", "$2)) ; $2 is cond (eq, ne, lt, etc)

;; --- Branching ---
(define-emit (BR LABEL)       (println "	b	"$1))
(define-emit (B.cond LABEL)   (println "	b."$1"	"$2)) ; $1 is condition
(define-emit (BL LABEL)       (println "	bl	"$1))
(define-emit (BLR REG)        (println "	blr	"$1))
(define-emit (RET)            (println "	ret"))

;; --- IR-Level Instructions ---
;; These are convenience emitters for the compiler IR.
;; The accumulator register is w0/x0.

;; Branch if False (w0 is zero)
(define-emit (BF LABEL)
  (println "	cmp	w0, #0")
  (println "	b.eq	"$1))

;; Branch if True (w0 is non-zero)
(define-emit (BT LABEL)
  (println "	cmp	w0, #0")
  (println "	b.ne	"$1))

(define-function load-arm64-emitters ()
  (println ";; ARM64 emitters loaded."))