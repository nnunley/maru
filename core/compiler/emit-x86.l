;;; emit-x86.l -- x86 assembly code generation
;;;
;;; This file contains x86-specific emit methods that generate
;;; assembly code for the x86 architecture.

(require "lib/stream/port.l")

;;; ASSEMBLY DIRECTIVES

(define-emit	(TEXT)			(emit-writeln "	.text"))
(define-emit	(DATA)			(emit-writeln "	.data"))
(define-emit	(SECTION string)	(emit-writeln "	.section "$1))

(define-emit	(INDIRECT LABEL)	(emit-writeln "	.indirect_symbol "$1))
(define-emit	(GLOBAL LABEL)		(emit-writeln "	.globl "$1))

(define-emit	(ALIGN long)		(emit-writeln "	.align " $1))

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

(define-emit	(ENTER long)		(emit-writeln "	pushl %ebp")
					(emit-writeln "	movl %esp,%ebp")
					(emit-writeln "	subl $"$1",%esp"))

(define-emit	(LEAVE long)		(emit-writeln "	addl $"$1",%esp")
					(emit-writeln "	leave")
					(emit-writeln "	ret"))

(define-emit	(NEG)			(emit-writeln "	negl %eax"))

(define-emit	(ADD TI32)		(emit-writeln "	addl "$1",%eax"))

(define-emit	(SUB TI32)		(emit-writeln "	subl "$1",%eax"))

(define-emit	(MUL TI32)		(emit-writeln "	mull "$1))

(define-emit	(DIV TI32)		(emit-writeln "	movl $0,%edx")
					(emit-writeln "	divl "$1))

(define-emit	(AND TI32)		(emit-writeln "	andl "$1",%eax"))

(define-emit	(OR TI32)		(emit-writeln "	orl "$1",%eax"))

(define-emit	(XOR TI32)		(emit-writeln "	xorl "$1",%eax"))

(define-emit	(NOT)			(emit-writeln "	cmpl $0,%eax")
					(emit-writeln "	sete %al")
					(emit-writeln "	movzbl %al,%eax"))

(define-emit	(LT TI32)		(emit-writeln "	cmpl "$1",%eax")
					(emit-writeln "	setl %al")
					(emit-writeln "	movzbl %al,%eax"))

(define-emit	(LE TI32)		(emit-writeln "	cmpl "$1",%eax")
					(emit-writeln "	setle %al")
					(emit-writeln "	movzbl %al,%eax"))

(define-emit	(EQ TI32)		(emit-writeln "	cmpl "$1",%eax")
					(emit-writeln "	sete %al")
					(emit-writeln "	movzbl %al,%eax"))

(define-emit	(NE TI32)		(emit-writeln "	cmpl "$1",%eax")
					(emit-writeln "	setne %al")
					(emit-writeln "	movzbl %al,%eax"))

(define-emit	(GE TI32)		(emit-writeln "	cmpl "$1",%eax")
					(emit-writeln "	setge %al")
					(emit-writeln "	movzbl %al,%eax"))

(define-emit	(GT TI32)		(emit-writeln "	cmpl "$1",%eax")
					(emit-writeln "	setg %al")
					(emit-writeln "	movzbl %al,%eax"))

(define-emit	(SLA TI32)		(emit-writeln "	movl "$1",%ecx")
					(emit-writeln "	shll %cl,%eax"))

(define-emit	(SRA TI32)		(emit-writeln "	movl "$1",%ecx")
					(emit-writeln "	sarl %cl,%eax"))

(define-emit	(BR LABEL)		(emit-writeln "	jmp "$1))

(define-emit	(BF LABEL)		(emit-writeln "	cmpl $0,%eax")
					(emit-writeln "	je "$1))

(define-emit	(BT LABEL)		(emit-writeln "	cmpl $0,%eax")
					(emit-writeln "	jne "$1))

(define-emit	(CALL LABEL)		(emit-writeln "	call "$1))
(define-emit	(CALL long)		(emit-writeln "	call *%eax"))

(define-emit	(LOAD LI32)		(emit-writeln "	movl $"$1",%eax"))
(define-emit	(LOAD LABEL)		(emit-writeln "	movl $"$1",%eax"))
(define-emit	(LOAD GI32)		(emit-writeln "	movl " $1",%eax"))
(define-emit	(LOAD TI32)		(emit-writeln "	movl " $1",%eax"))

(define-emit	(STORE TI32)		(emit-writeln "	movl %eax,"$1))
(define-emit	(STORE GI32)		(emit-writeln "	movl %eax,"$1))

(define-emit	(ADDR GI32)		(emit-writeln "	movl $"$1",%eax"))
(define-emit	(ADDR TI32)		(emit-writeln "	leal "$1",%eax"))

(define-emit	(MOVE TI32 TI32)	(emit-writeln "	movl "$1",%ecx")
					(emit-writeln "	movl %ecx,"$2))

(define-emit	(COMMENT pair)		(emit-write "## ") (apply emit-writeln $1))

(define-emit	(CHR-AT TI32)		(emit-writeln "	movl "$1",%ecx")
					(emit-writeln "	leal (%eax,%ecx),%ecx")
					(emit-writeln "	xorl %eax,%eax")
					(emit-writeln "	movb (%ecx),%al"))

(define-emit	(SET-CHR-AT TI32 TI32)	(emit-writeln "	movl "$1",%ecx")
					(emit-writeln "	leal (%eax,%ecx),%ecx")
					(emit-writeln "	movl "$2",%eax")
					(emit-writeln "	movb %al,(%ecx)"))

(define-emit	(OOP-AT TI32)		(emit-writeln "	movl "$1",%ecx")
			  		(emit-writeln "	leal (%eax,%ecx,4),%ecx")
			  		(emit-writeln "	movl (%ecx),%eax"))

(define-emit	(SET-OOP-AT TI32 TI32)	(emit-writeln "	movl "$1",%ecx")
					(emit-writeln "	leal (%eax,%ecx,4),%ecx")
					(emit-writeln "	movl "$2",%eax")
					(emit-writeln "	movl %eax,(%ecx)"))