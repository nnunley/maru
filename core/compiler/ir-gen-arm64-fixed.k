;;; ir-gen-arm64-fixed.k -- Fixed ARM64 IR Generator
;;; Generates proper ARM64 assembly instead of x86

(require "ir2.k")
(require "port.l")	(define-function long->string (x) (format "%d" x))

(define *info-level* 0)

(define *optimise-literals*	())
(define *optimise-globals*	())
(define *align-functions*	16)
(define *compact-prologues*	())
(define *compact-epilogues*	())

(define-structure <ir-gen-arm64> (frame current-section callsize port))

(define-function ir-gen-new ()	(make <ir-gen-arm64> (port (string-port))))

(define-function arm64-mangle (s)
  (let* ((in  (symbol->string s))
	 (len (string-length in))
	 (out (array)))
    (for (i 0 len)
      (let ((c (string-at in i)))
	(if (or (and (<= 0x61 c) (<= c 0x7a))
		(and (<= 0x40 c) (<= c 0x5a))
		(and (<= 0x30 c) (<= c 0x39)))
	    (array-append out c)
	  (if (= ?_ c)
	      (array-append-all out "__")
	    (array-append-all out (format "_%02x" c))))))
    (array->string out)))

(define-function ir-gen-arm64-section (self name)
  (unless (= name (<ir-gen-arm64>-current-section self))
    (emitln self "	."name)
    (set (<ir-gen-arm64>-current-section self) name)))

(define-function ir-gen-arm64-variable-name (var)
  (concat-string "v_" (arm64-mangle (symbol->string (<ir-variable>-name var)))))

(define-function ir-gen-arm64-function-name (func)
  (if (<ir-function>-export func)
      (concat-string __USER_LABEL_PREFIX__ (symbol->string (<ir-function>-export func)))
    (concat-string "f_" (arm64-mangle (symbol->string (car (<ir-function>-parameters func)))))))

;;;

(define-structure <ir-register> (name))
(define-structure <ir-label> (number))

(define-function ir-gen-output (gen) (<ir-gen-arm64>-port gen))

(define-function emit    (gen  str) (print   (<ir-gen-arm64>-port gen) str))
(define-function emitln  (gen  str) (println (<ir-gen-arm64>-port gen) str))
(define-function emitf   (gen args) (apply format (<ir-gen-arm64>-port gen) args))
(define-function emitfln (gen args) (emitf gen args) (emitln gen ""))

(define-function info (gen level . args)
  (and (<= level *info-level*)
       (list-do arg args (format *error* " %s" arg))
       (format *error* "\n")))

;;; ARM64 Register Names
(define-selector x64-name)
(define-selector x32-name)

(define-method x64-name <long> () (format "x%d" self))
(define-method x32-name <long> () (format "w%d" self))

(define %x0  0)  (define %w0  0)
(define %x1  1)  (define %w1  1)
(define %x2  2)  (define %w2  2)
(define %x3  3)  (define %w3  3)
(define %x4  4)  (define %w4  4)
(define %x5  5)  (define %w5  5)
(define %x6  6)  (define %w6  6)
(define %x7  7)  (define %w7  7)
(define %x8  8)  (define %w8  8)
(define %x9  9)  (define %w9  9)
(define %x10 10) (define %w10 10)
(define %x11 11) (define %w11 11)
(define %x12 12) (define %w12 12)
(define %x13 13) (define %w13 13)
(define %x14 14) (define %w14 14)
(define %x15 15) (define %w15 15)
(define %x16 16) (define %w16 16)
(define %x17 17) (define %w17 17)
(define %x18 18) (define %w18 18)
(define %x19 19) (define %w19 19)
(define %x20 20) (define %w20 20)
(define %x21 21) (define %w21 21)
(define %x22 22) (define %w22 22)
(define %x23 23) (define %w23 23)
(define %x24 24) (define %w24 24)
(define %x25 25) (define %w25 25)
(define %x26 26) (define %w26 26)
(define %x27 27) (define %w27 27)
(define %x28 28) (define %w28 28)
(define %x29 29) (define %w29 29)  ; Frame pointer
(define %x30 30) (define %w30 30)  ; Link register
(define %sp  31)                   ; Stack pointer
(define %xzr 31) (define %wzr 31)  ; Zero register

;;; ARM64 Instruction Emission

(define-function ir-gen-arm64-load (gen type location)
  (cond
    ((= type IR-INT8)		(emitln gen "	ldrb	w0, "location))
    ((= type IR-INT16)		(emitln gen "	ldrh	w0, "location))
    ((= type IR-INT32)		(emitln gen "	ldr	w0, "location))
    ((= type IR-INT64)		(emitln gen "	ldr	x0, "location))
    ((ir-pointer-type? type)	(emitln gen "	ldr	x0, "location))
    ((= type IR-FLOAT32)	(emitln gen "	ldr	s0, "location))
    ((= type IR-FLOAT64)	(emitln gen "	ldr	d0, "location))
    (else			(error "cannot load: "type))))

(define-function ir-gen-arm64-store (gen type location)
  (cond
    ((= type IR-INT8)		(emitln gen "	strb	w0, "location))
    ((= type IR-INT16)		(emitln gen "	strh	w0, "location))
    ((= type IR-INT32)		(emitln gen "	str	w0, "location))
    ((= type IR-INT64)		(emitln gen "	str	x0, "location))
    ((ir-pointer-type? type)	(emitln gen "	str	x0, "location))
    ((= type IR-FLOAT32)	(emitln gen "	str	s0, "location))
    ((= type IR-FLOAT64)	(emitln gen "	str	d0, "location))
    (else			(error "cannot store: "type))))

(define-function ir-gen-arm64-move-struct (type from to gen)
  ;; Copy struct using x9 as counter, x10 as src, x11 as dst
  (emitln gen "	mov	x9, #"(<ir-struct-type>-size type))
  (emitln gen "	mov	x10, "from)
  (emitln gen "	mov	x11, "to)
  (emitln gen "1:")
  (emitln gen "	ldrb	w12, [x10], #1")
  (emitln gen "	strb	w12, [x11], #1")
  (emitln gen "	subs	x9, x9, #1")
  (emitln gen "	b.ne	1b"))

;;; Stack Frame Management

(define-selector ir-location-arm64-offset)

(define-method ir-location-arm64-offset <ir-frame> (gen)
  (format "[x29, #%d]" (- self.offset)))

(define-method ir-location-arm64-offset <ir-global> (gen)
  (format "%s" (ir-gen-arm64-variable-name self)))

(define-method ir-location-arm64-offset <ir-local> (gen)
  (format "[x29, #%d]" (- self.offset)))

;;; IR Instruction Methods

(define-method ir-gen-arm64 <ir-lit> (gen)
  (let ((val self.value))
    (cond
      ((= self.type IR-INT8)  (emitln gen "	mov	w0, #"(& 0xff val)))
      ((= self.type IR-INT16) (emitln gen "	mov	w0, #"(& 0xffff val)))
      ((= self.type IR-INT32) (emitln gen "	mov	w0, #"val))
      ((= self.type IR-INT64)
       ;; For 64-bit immediates, use movz/movk sequence
       (emitln gen "	movz	x0, #"(& 0xffff val))
       (emitln gen "	movk	x0, #"(& 0xffff (>> val 16))", lsl #16")
       (emitln gen "	movk	x0, #"(& 0xffff (>> val 32))", lsl #32")
       (emitln gen "	movk	x0, #"(& 0xffff (>> val 48))", lsl #48"))
      ((ir-pointer-type? self.type)
       (if (= 0 val)
           (emitln gen "	mov	x0, xzr")
         (emitln gen "	mov	x0, #"val)))
      (else (error "cannot generate literal: "self.type" "val)))))

(define-method ir-gen-arm64 <ir-global> (gen)
  ;; Load address of global variable
  (emitln gen "	adrp	x0, ")(emit gen (ir-gen-arm64-variable-name self))(emitln gen "@PAGE")
  (emitln gen "	add	x0, x0, ")(emit gen (ir-gen-arm64-variable-name self))(emitln gen "@PAGEOFF"))

(define-method ir-gen-arm64 <ir-get> (gen)
  (ir-gen-arm64-load gen self.type (ir-location-arm64-offset self.location gen)))

(define-method ir-gen-arm64 <ir-set> (gen)
  (ir-gen-arm64 self.value gen)
  (ir-gen-arm64-store gen self.type (ir-location-arm64-offset self.location gen)))

;;; Binary Operations

(define-method ir-gen-arm64 <ir-add> (gen)
  (ir-gen-arm64 self.operand-r gen)
  (emitln gen "	mov	x1, x0")
  (ir-gen-arm64 self.operand-l gen)
  (cond
    ((= self.type IR-INT32) (emitln gen "	add	w0, w0, w1"))
    ((= self.type IR-INT64) (emitln gen "	add	x0, x0, x1"))
    ((ir-pointer-type? self.type) (emitln gen "	add	x0, x0, x1"))
    (else (error "cannot add: "self.type))))

(define-method ir-gen-arm64 <ir-sub> (gen)
  (ir-gen-arm64 self.operand-r gen)
  (emitln gen "	mov	x1, x0")
  (ir-gen-arm64 self.operand-l gen)
  (cond
    ((= self.type IR-INT32) (emitln gen "	sub	w0, w0, w1"))
    ((= self.type IR-INT64) (emitln gen "	sub	x0, x0, x1"))
    ((ir-pointer-type? self.type) (emitln gen "	sub	x0, x0, x1"))
    (else (error "cannot sub: "self.type))))

(define-method ir-gen-arm64 <ir-mul> (gen)
  (ir-gen-arm64 self.operand-r gen)
  (emitln gen "	mov	x1, x0")
  (ir-gen-arm64 self.operand-l gen)
  (cond
    ((= self.type IR-INT32) (emitln gen "	mul	w0, w0, w1"))
    ((= self.type IR-INT64) (emitln gen "	mul	x0, x0, x1"))
    (else (error "cannot mul: "self.type))))

(define-method ir-gen-arm64 <ir-div> (gen)
  (ir-gen-arm64 self.operand-r gen)
  (emitln gen "	mov	x1, x0")
  (ir-gen-arm64 self.operand-l gen)
  (cond
    ((= self.type IR-INT32) (emitln gen "	sdiv	w0, w0, w1"))
    ((= self.type IR-INT64) (emitln gen "	sdiv	x0, x0, x1"))
    (else (error "cannot div: "self.type))))

;;; Comparison Operations

(define-method ir-gen-arm64 <ir-lt> (gen)
  (ir-gen-arm64 self.operand-r gen)
  (emitln gen "	mov	x1, x0")
  (ir-gen-arm64 self.operand-l gen)
  (cond
    ((= (<ir-insn>-type self.operand-l) IR-INT32)
     (emitln gen "	cmp	w0, w1")
     (emitln gen "	cset	w0, lt"))
    ((= (<ir-insn>-type self.operand-l) IR-INT64)
     (emitln gen "	cmp	x0, x1")
     (emitln gen "	cset	x0, lt"))
    (else (error "cannot compare: "(<ir-insn>-type self.operand-l)))))

(define-method ir-gen-arm64 <ir-eq> (gen)
  (ir-gen-arm64 self.operand-r gen)
  (emitln gen "	mov	x1, x0")
  (ir-gen-arm64 self.operand-l gen)
  (cond
    ((= (<ir-insn>-type self.operand-l) IR-INT32)
     (emitln gen "	cmp	w0, w1")
     (emitln gen "	cset	w0, eq"))
    ((= (<ir-insn>-type self.operand-l) IR-INT64)
     (emitln gen "	cmp	x0, x1")
     (emitln gen "	cset	x0, eq"))
    (else (error "cannot compare: "(<ir-insn>-type self.operand-l)))))

;;; Control Flow

(define-method ir-gen-arm64 <ir-if> (gen)
  (let ((label-else (ir-label-new))
	(label-end  (ir-label-new)))
    (ir-gen-arm64 self.test gen)
    (emitln gen "	cbz	x0, "(ir-label-name label-else))
    (ir-gen-arm64 self.consequent gen)
    (emitln gen "	b	"(ir-label-name label-end))
    (emitln gen (ir-label-name label-else)":")
    (and self.alternate (ir-gen-arm64 self.alternate gen))
    (emitln gen (ir-label-name label-end)":")))

(define-method ir-gen-arm64 <ir-while> (gen)
  (let ((label-test (ir-label-new))
	(label-end  (ir-label-new)))
    (emitln gen "	b	"(ir-label-name label-test))
    (emitln gen (ir-label-name label-test)":")
    (ir-gen-arm64 self.test gen)
    (emitln gen "	cbz	x0, "(ir-label-name label-end))
    (ir-gen-arm64 self.body gen)
    (emitln gen "	b	"(ir-label-name label-test))
    (emitln gen (ir-label-name label-end)":")))

(define-method ir-gen-arm64 <ir-return> (gen)
  (and self.value (ir-gen-arm64 self.value gen))
  (emitln gen "	ldp	x29, x30, [sp], #16")  ; Epilogue
  (emitln gen "	ret"))

;;; Function Calls

(define-method ir-gen-arm64 <ir-call> (gen)
  ;; Simple calling convention: arguments in x0-x7
  (let ((args (cdr self.operands))
	(nargs 0))
    ;; Evaluate and push arguments
    (list-do arg args
      (ir-gen-arm64 arg gen)
      (if (< nargs 8)
          (emitln gen "	mov	x"nargs", x0")
        (error "too many arguments"))
      (incr nargs))
    ;; Call function
    (ir-gen-arm64 (car self.operands) gen)
    (emitln gen "	blr	x0")))

;;; Function Definition

(define-method ir-gen-arm64 <ir-function> (gen)
  (let ((name (ir-gen-arm64-function-name self)))
    ;; Function header
    (ir-gen-arm64-section gen "text")
    (emitln gen "	.align	4")
    (emitln gen "	.globl	"name)
    (emitln gen name":")
    
    ;; Prologue
    (emitln gen "	stp	x29, x30, [sp, #-16]!")
    (emitln gen "	mov	x29, sp")
    
    ;; Allocate stack frame if needed
    (let ((frame-size (align 16 (<ir-function>-frame-size self))))
      (when (> frame-size 0)
        (emitln gen "	sub	sp, sp, #"frame-size)))
    
    ;; Generate body
    (ir-gen-arm64 self.body gen)
    
    ;; Default return if needed
    (emitln gen "	ldp	x29, x30, [sp], #16")
    (emitln gen "	ret")))

;;; Top-level Generation

(define-method ir-gen-arm64 <ir-module> (gen)
  ;; Generate data section for globals
  (ir-gen-arm64-section gen "data")
  (list-do var self.globals
    (emitln gen "	.align	3")
    (emitln gen (ir-gen-arm64-variable-name var)":")
    (emitln gen "	.quad	0"))
  
  ;; Generate functions
  (list-do func self.functions
    (ir-gen-arm64 func gen)))

;;; Label Management

(define *ir-label-counter* 0)

(define-function ir-label-new ()
  (make <ir-label> (number (incr *ir-label-counter*))))

(define-function ir-label-name (label)
  (format ".L%d" (<ir-label>-number label)))

;;; API Entry Point

(define-function ir-gen (ir)
  (let ((gen (ir-gen-new)))
    (ir-gen-arm64 ir gen)
    (string-port-contents (ir-gen-output gen))))