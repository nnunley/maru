;;; emit-asm-x86.l -- x86 assembly code generation
;;;
;;; This file contains x86-specific emit methods that generate
;;; assembly code for the x86 architecture.

;;; ASSEMBLY DIRECTIVES

(define-emit	(TEXT)			(println "	.text"))
(define-emit	(DATA)			(println "	.data"))
(define-emit	(SECTION string)	(println "	.section "$1))

(define-emit	(INDIRECT LABEL)	(println "	.indirect_symbol "$1))
(define-emit	(GLOBAL LABEL)		(println "	.globl "$1))

(define-emit	(ALIGN long)		(println "	.align " $1))

(define-emit	(LONG long)		(println "	.long "$1))
(define-emit	(LONG LABEL)		(println "	.long "$1))

(define-emit	(ASCIZ string)		(print   "	.asciz ") (dumpln $1))

(define-emit	(DEFLABEL LABEL)	(println $1":"))

(define-emit	(ENTER long)		(println "	pushl %ebp")
				 	(println "	movl %esp,%ebp")
				 	(and (!= 0 $1) (println "	subl $"$1",%esp")))

(define-emit	(LEAVE long)		(println "	addl $"$1",%esp")
				 	(println "	movl %ebp,%esp")
				 	(println "	popl %ebp")
				 	(println "	ret"))

(define-emit	(NEG)			(println "	negl %eax"))

(define-emit	(ADD TI32)		(println "	addl "$1",%eax"))

(define-emit	(SUB TI32)		(println "	subl "$1",%eax"))

(define-emit	(MUL TI32)		(println "	mull "$1))

(define-emit	(DIV TI32)		(println "	movl $0,%edx")
				 	(println "	divl "$1))

(define-emit	(AND TI32)		(println "	andl "$1",%eax"))

(define-emit	(OR TI32)		(println "	orl "$1",%eax"))

(define-emit	(XOR TI32)		(println "	xorl "$1",%eax"))

(define-emit	(NOT)			(println "	cmpl $0,%eax")
				 	(println "	sete %al")
				 	(println "	movzbl %al,%eax"))

(define-emit	(LT TI32)		(println "	cmpl "$1",%eax")
				 	(println "	setl %al")
				 	(println "	movzbl %al,%eax"))

(define-emit	(LE TI32)		(println "	cmpl "$1",%eax")
				 	(println "	setle %al")
				 	(println "	movzbl %al,%eax"))

(define-emit	(EQ TI32)		(println "	cmpl "$1",%eax")
				 	(println "	sete %al")
				 	(println "	movzbl %al,%eax"))

(define-emit	(NE TI32)		(println "	cmpl "$1",%eax")
				 	(println "	setne %al")
				 	(println "	movzbl %al,%eax"))

(define-emit	(GE TI32)		(println "	cmpl "$1",%eax")
				 	(println "	setge %al")
				 	(println "	movzbl %al,%eax"))

(define-emit	(GT TI32)		(println "	cmpl "$1",%eax")
				 	(println "	setg %al")
				 	(println "	movzbl %al,%eax"))

(define-emit	(SLA TI32)		(println "	movl "$1",%ecx")
				 	(println "	sall %cl,%eax"))

(define-emit	(SRA TI32)		(println "	movl "$1",%ecx")
				 	(println "	sarl %cl,%eax"))

(define-emit	(BR LABEL)		(println "	jmp "$1))

(define-emit	(BF LABEL)		(println "	cmpl $0,%eax")
				 	(println "	je "$1))

(define-emit	(BT LABEL)		(println "	cmpl $0,%eax")
				 	(println "	jne "$1))

(define-emit	(CALL LABEL)		(println "	call "$1))
(define-emit	(CALL long)		(println "	call *%eax"))

(define-emit	(LOAD LI32)		(println "	movl $"$1",%eax"))
(define-emit	(LOAD LABEL)		(println "	movl $"$1",%eax"))
(define-emit	(LOAD GI32)		(println "	movl " $1",%eax"))
(define-emit	(LOAD TI32)		(println "	movl " $1",%eax"))

(define-emit	(STORE TI32)		(println "	movl %eax,"$1))
(define-emit	(STORE GI32)		(println "	movl %eax,"$1))

(define-emit	(ADDR GI32)		(println "	movl $"$1",%eax"))
(define-emit	(ADDR TI32)		(println "	leal "$1",%eax"))

(define-emit	(MOVE TI32 TI32)	(println "	movl "$1",%ecx")
				 	(println "	movl %ecx,"$2))

(define-emit	(COMMENT pair)		(print "## ") (apply println $1))

(define-emit	(CHR-AT TI32)		(println "	movl "$1",%ecx")
				 	(println "	movsbl (%eax,%ecx),%eax"))

(define-emit	(CHR-AT)		(println "	movsbl (%eax),%eax"))

(define-emit	(SET-CHR-AT TI32 TI32)	(println "	movl "$1",%ecx")
				 	(println "	movl "$2",%edx")
				 	(println "	movb %cl,(%eax,%edx)"))

(define-emit	(OOP-AT TI32)		(println "	movl "$1",%ecx")
				 	(println "	movl (%eax,%ecx,4),%eax"))

(define-emit	(SET-OOP-AT TI32 TI32)	(println "	movl "$1",%ecx")
				 	(println "	movl "$2",%edx")
				 	(println "	movl %ecx,(%eax,%edx,4)"))

;;; OPERAND DEFINITIONS

(define-unary   %%neg		NEG)
(define-unary   %%not		NOT)
(define-unary   string-length	OOP-AT)

(define-binary  +		ADD)
(define-binary  -		SUB)
(define-binary  *		MUL)
(define-binary  /		DIV)
(define-binary  &		AND)
(define-binary  |		OR)
(define-binary  ^		XOR)
(define-binary  <		LT)
(define-binary  <=		LE)
(define-binary  =		EQ)
(define-binary  !=		NE)
(define-binary  >=		GE)
(define-binary  >		GT)
(define-binary  <<		SLA)
(define-binary  >>		SRA)

(define-binary  string-at	CHR-AT)
(define-binary  oop-at		OOP-AT)

(define-ternary set-oop-at	SET-OOP-AT)
(define-ternary set-string-at	SET-CHR-AT)