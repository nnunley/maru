;;; emit-arm64.l -- ARM64 Assembly backend for Maru compiler
;;;
;;; This file contains the ARM64-specific emit definitions that were
;;; previously embedded in emit.l. This allows clean separation of backends.

(emit-writeln "; Loading ARM64 backend emit-arm64.l")

(require "lib/stream/port.l")

;;; ARM64 ASSEMBLY DIRECTIVES

(define-emit	(TEXT)			(emit-writeln "	.text"))
(define-emit	(DATA)			(emit-writeln "	.data"))
(define-emit	(SECTION string)	(emit-writeln "	.section "$1))
(define-emit	(GLOBAL LABEL)		(emit-writeln "	.globl "$1))
(define-emit	(ALIGN long)		(emit-writeln "	.align "$1))
(define-emit	(LONG long)		(emit-writeln "	.long "$1))
(define-emit	(LONG LABEL)		(emit-writeln "	.long "$1))
(define-emit	(ASCIZ string)		
  (emit-write "	.asciz ")
  ;; Manually emit the string representation since dumpln uses print
  (emit-write "\"")
  (for-each $1 (lambda (c) 
    (cond
      ((= c ?\") (emit-write "\\\""))
      ((= c ?\\) (emit-write "\\\\"))
      ((= c ?\n) (emit-write "\\n"))
      ((= c ?\r) (emit-write "\\r"))
      ((= c ?\t) (emit-write "\\t"))
      ((< c 32) (emit-write "\\" (format "%03o" c)))
      (else (emit-write (format "%c" c))))))
  (emit-write "\"")
  (emit-writeln))
(define-emit	(DEFLABEL LABEL)	(emit-writeln $1":"))

;;; ARM64 FUNCTION PROLOGUE/EPILOGUE

(define-emit	(ENTER long)		(emit-writeln "	stp	x29, x30, [sp, #-"(+ $1 16)"]!")
			 		(emit-writeln "	mov	x29, sp"))

(define-emit	(LEAVE long)		(emit-writeln "	ldp	x29, x30, [sp], #"(+ $1 16))
			 		(emit-writeln "	ret"))

;;; ARM64 ARITHMETIC OPERATIONS

(define-emit	(NEG)			(emit-writeln "	neg	x0, x0"))
(define-emit	(ADD TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	add	x0, x0, x1"))
(define-emit	(SUB TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	sub	x0, x0, x1"))
(define-emit	(MUL TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	mul	x0, x0, x1"))

;;; ARM64 COMPARISON OPERATIONS

(define-emit	(LT TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	cmp	x0, x1")
			 		(emit-writeln "	cset	x0, lt"))

(define-emit	(LE TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	cmp	x0, x1")
			 		(emit-writeln "	cset	x0, le"))

(define-emit	(EQ TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	cmp	x0, x1")
			 		(emit-writeln "	cset	x0, eq"))

(define-emit	(NE TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	cmp	x0, x1")
			 		(emit-writeln "	cset	x0, ne"))

(define-emit	(GE TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	cmp	x0, x1")
			 		(emit-writeln "	cset	x0, ge"))

(define-emit	(GT TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	cmp	x0, x1")
			 		(emit-writeln "	cset	x0, gt"))

;;; ARM64 CONTROL FLOW

(define-emit	(BR LABEL)		(emit-writeln "	b	"$1))
(define-emit	(BF LABEL)		(emit-writeln "	cbz	x0, "$1))
(define-emit	(BT LABEL)		(emit-writeln "	cbnz	x0, "$1))
(define-emit	(CALL LABEL)		(emit-writeln "	bl	"$1))

;;; ARM64 LOAD/STORE OPERATIONS

(define-emit	(LOAD LI32)		(emit-writeln "	mov	x0, #"$1))
(define-emit	(LOAD LABEL)		(emit-writeln "	adrp	x0, "$1"@PAGE")
			 		(emit-writeln "	add	x0, x0, "$1"@PAGEOFF"))
(define-emit	(LOAD TI32)		(emit-writeln "	ldr	x0, [x29, #"$1"]"))
(define-emit	(STORE TI32)		(emit-writeln "	str	x0, [x29, #"$1"]"))

;;; ARM64 MEMORY OPERATIONS

(define-emit	(OOP-AT TI32)		(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 		(emit-writeln "	ldr	x0, [x0, x1, lsl #3]"))
(define-emit	(SET-OOP-AT TI32 TI32)	(emit-writeln "	ldr	x1, [x29, #"$1"]")
			 			(emit-writeln "	ldr	x2, [x29, #"$2"]")
			 			(emit-writeln "	str	x1, [x0, x2, lsl #3]"))

;;; ARM64 MISC OPERATIONS

(define-emit	(COMMENT pair)		(emit-write "// ") (apply emit-writeln $1))