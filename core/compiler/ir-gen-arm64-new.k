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

(define-function ir-gen-output (gen))

(define-function info (gen level . args)	(and (< level *info-level*) (apply println args)))

(define-method do-emit <long> (gen)		(print self))
(define-method do-emit <symbol> (gen)		(print self))
(define-method do-emit <string> (gen)		(print self))

(define-method do-emit <ir-register> (gen)	(print self.name))
(define-method do-emit <ir-lit> (gen)		(print "#" (car self.parameters)))
(define-method do-emit <ir-location> (gen)	(print "[" (if self.base (<ir-register>-name self.base) "sp") ", #" self.offset "]"))
(define-method do-emit <ir-label> (gen)		(print "L"(<ir-label>-number self)))
(define-method do-emit <ir-global> (gen)	(print (ir-gen-arm64-variable-name self)))
(define-method do-emit <ir-local> (gen)		(do-emit self.location gen))
(define-method do-emit <ir-parameter> (gen)	(do-emit self.location gen))

(define-function emit (gen . args)	(list-do arg args (do-emit arg gen)))
(define-function emitln (gen . args)	(list-do arg args (do-emit arg gen)) (print "\n"))

;; ARM64 Register Definitions
;; ARM64 has 31 general-purpose registers (X0-X30) plus SP
;; W0-W30 are 32-bit views of X0-X30
;; X0-X7: Parameter/result registers
;; X8: Indirect result location register
;; X9-X15: Temporary registers
;; X16-X17: Intra-procedure-call scratch registers
;; X18: Platform register
;; X19-X28: Callee-saved registers
;; X29: Frame pointer (FP)
;; X30: Link register (LR)
;; SP: Stack pointer

(define x0  (new <ir-register> "x0"))
(define x1  (new <ir-register> "x1"))
(define x2  (new <ir-register> "x2"))
(define x3  (new <ir-register> "x3"))
(define x4  (new <ir-register> "x4"))
(define x5  (new <ir-register> "x5"))
(define x6  (new <ir-register> "x6"))
(define x7  (new <ir-register> "x7"))
(define x8  (new <ir-register> "x8"))
(define x9  (new <ir-register> "x9"))
(define x10 (new <ir-register> "x10"))
(define x11 (new <ir-register> "x11"))
(define x12 (new <ir-register> "x12"))
(define x13 (new <ir-register> "x13"))
(define x14 (new <ir-register> "x14"))
(define x15 (new <ir-register> "x15"))
(define x29 (new <ir-register> "x29")) ; Frame pointer
(define x30 (new <ir-register> "x30")) ; Link register
(define sp  (new <ir-register> "sp"))  ; Stack pointer

;; 32-bit views
(define w0  (new <ir-register> "w0"))
(define w1  (new <ir-register> "w1"))
(define w2  (new <ir-register> "w2"))
(define w3  (new <ir-register> "w3"))
(define w8  (new <ir-register> "w8"))
(define w9  (new <ir-register> "w9"))
(define w10 (new <ir-register> "w10"))

;; Zero registers
(define xzr (new <ir-register> "xzr"))
(define wzr (new <ir-register> "wzr"))

(define *ir-gen-arm64-last-label* 0)

(define-function ir-gen-arm64-temp-label (gen)		(new <ir-label> (incr *ir-gen-arm64-last-label*)))

;; ARM64 Load/Store Operations
(define-function ir-gen-arm64-load (type location gen)
  (cond
    ((= type IR-INT8)		(emitln gen "	ldrb	w0, " location))
    ((= type IR-INT16)		(emitln gen "	ldrh	w0, " location))
    ((= type IR-INT32)		(emitln gen "	ldr	w0, " location))
    ((= type IR-INT64)		(emitln gen "	ldr	x0, " location))
    ((ir-pointer-type? type)	(emitln gen "	ldr	x0, " location))
    ((= type IR-FLOAT32)	(emitln gen "	ldr	s0, " location))
    ((= type IR-FLOAT64)	(emitln gen "	ldr	d0, " location))
    (else			(error "cannot load: "type))))

(define-function ir-gen-arm64-store (type location gen)
  (cond
    ((= type IR-INT8)		(emitln gen "	strb	w0, " location))
    ((= type IR-INT16)		(emitln gen "	strh	w0, " location))
    ((= type IR-INT32)		(emitln gen "	str	w0, " location))
    ((= type IR-INT64)		(emitln gen "	str	x0, " location))
    ((ir-pointer-type? type)	(emitln gen "	str	x0, " location))
    ((= type IR-FLOAT32)	(emitln gen "	str	s0, " location))
    ((= type IR-FLOAT64)	(emitln gen "	str	d0, " location))
    (else			(error "cannot store: "type))))

(define-function ir-gen-arm64-spill (insn gen)	
  (or (ir-struct-type? (<ir-insn>-type insn))
      (and (ir-lit? insn) (= insn (<ir-insn>-location insn)))
      (ir-gen-arm64-store (<ir-insn>-type insn) (<ir-insn>-location insn) gen)))

(define-function ir-gen-arm64-reload (insn gen)	
  (or (ir-struct-type? (<ir-insn>-type insn))
      (and (ir-lit? insn) (= insn (<ir-insn>-location insn)))
      (ir-gen-arm64-load  (<ir-insn>-type insn) (<ir-insn>-location insn) gen)))

;; ARM64 Function Prologue/Epilogue
(define-function ir-gen-arm64-prologue (gen framesize)
  (emitln gen "	stp	x29, x30, [sp, #-16]!")  ; Save frame pointer and link register
  (emitln gen "	mov	x29, sp")               ; Set up frame pointer
  (when (> framesize 16)
    (emitln gen "	sub	sp, sp, #" (- framesize 16))))  ; Allocate stack space

(define-function ir-gen-arm64-epilogue (gen)
  (emitln gen "	mov	sp, x29")               ; Restore stack pointer
  (emitln gen "	ldp	x29, x30, [sp], #16")   ; Restore frame pointer and link register
  (emitln gen "	ret"))                       ; Return

;; ARM64 Move Operations
(define-function ir-gen-arm64-move-struct-with (type sinit src dinit dst gen)
  (info gen 2 "# move struct <"sinit" "dinit"> "type)
  (emitln gen "	mov	x1, " src)              ; Source address
  (emitln gen "	mov	x2, " dst)              ; Destination address
  (emitln gen "	mov	x3, #" (<ir-struct-type>-size type))  ; Size
  (emitln gen "	bl	memcpy"))               ; Call memcpy

(define-function ir-gen-arm64-move-struct  (type src dst gen)	(ir-gen-arm64-move-struct-with type "mov" src "mov" dst gen))
(define-function ir-gen-arm64-load-struct  (type src dst gen)	(ir-gen-arm64-move-struct-with type "ldr" src "mov" dst gen))
(define-function ir-gen-arm64-store-struct (type src dst gen)	(ir-gen-arm64-move-struct-with type "mov" src "str" dst gen))

;; Parameter allocation
(define-function ir-gen-arm64-allocate-parameters (offset param-list)
  (if param-list
      (let* ((param 	(cdar param-list))
	     (type  	(<ir-variable>-type param))
	     (size  	(<ir-type>-size type))
	     (alignment (<ir-type>-alignment type)))
	(set offset (ir-gen-arm64-allocate-parameters offset (cdr param-list)))
	(set offset (align offset alignment))
	(set (<ir-variable>-location param) (new <ir-location> offset 'args-in x29))
	(+ offset size))
    offset))

;; Allocation methods
(define-selector ir-gen-arm64-allocate)
(define-selector ir-gen-arm64-deallocate)

(define-method ir-gen-arm64-allocate <ir-gen-arm64> (type)		(ir-frame-allocate self.frame type))

(define-method ir-gen-arm64-deallocate <ir-location> (gen)	(ir-location-deallocate self))
(define-method ir-gen-arm64-deallocate <ir-insn> (gen)		(and self.location (ir-gen-arm64-deallocate self.location gen)))

(define-method ir-gen-arm64-allocate <ir-local> (gen)		(set self.location (ir-gen-arm64-allocate gen self.type)))
(define-method ir-gen-arm64-deallocate <ir-local> (gen)		(ir-gen-arm64-deallocate self.location gen))

(define-method ir-gen-arm64-allocate <ir-insn> (gen)
  (list-do opd self.operands (ir-gen-arm64-allocate   opd gen))
  (list-do opd self.operands (ir-gen-arm64-deallocate opd gen))
  (or (= IR-VOID self.type)
      (set self.location (ir-gen-arm64-allocate gen self.type))))

;; Return instruction
(define-method ir-gen-arm64-allocate <ir-return> (gen)
  (when self.operands
    (ir-gen-arm64-allocate (car self.operands) gen)
    (ir-gen-arm64-deallocate (car self.operands) gen))
  ())

(define-method ir-gen-arm64 <ir-return> (gen)
  (let* ((operand  (car self.operands))
	 (type     (<ir-insn>-type     operand))
	 (location (<ir-insn>-location operand)))
    (info gen 2 "# return value")
    (ir-gen-arm64 operand gen)
    (and (ir-struct-type? type)
	 (ir-gen-arm64-store-struct type location (new <ir-location> 16 'struct-return x29) gen))
    (info gen 2 "# return")
    (ir-gen-arm64-epilogue gen)))

;; Set variable operations  
(define-method ir-gen-arm64-allocate <ir-set-var> (gen)
  (set self.location (ir-gen-arm64-allocate gen self.type))
  (ir-gen-arm64-allocate (car self.operands) gen))

(define-method ir-gen-arm64-deallocate <ir-set-var> (gen)
  (ir-gen-arm64-deallocate (car self.operands) gen)
  (ir-gen-arm64-deallocate self.location gen))

(define-method ir-gen-arm64 <ir-set-var> (gen)
  (or (<ir-variable>-location self.parameters) (error "var has no location "self.parameters))
  (let ((value (car self.operands)))
    (info gen 2 "# set-var "self.parameters" <- "self.type" value")
    (ir-gen-arm64 value gen)
    (info gen 2 "# set-var "(<ir-variable>-type self.parameters))
    (if (ir-struct-type? self.type)
	(let ()
	  (ir-gen-arm64-move-struct self.type (<ir-insn>-location value) (<ir-variable>-location self.parameters) gen)
	  (ir-gen-arm64-move-struct self.type (<ir-insn>-location value) self.location gen))
      (ir-gen-arm64-store (<ir-variable>-type self.parameters) (<ir-variable>-location self.parameters) gen)
      (ir-gen-arm64-store self.type self.location gen))))

;; Let operations
(define-method ir-gen-arm64-allocate <ir-let> (gen)
  (or (= IR-VOID self.type)
      (set self.location (ir-gen-arm64-allocate gen self.type)))
  (let ((vars self.parameters))
    (list-do bind vars (ir-gen-arm64-allocate (cdr bind) gen))
    (list-do expr self.operands
      (ir-gen-arm64-allocate expr gen)
      (or (ir-return? expr)
	  (ir-gen-arm64-deallocate expr gen)))
    (list-do bind vars (ir-gen-arm64-deallocate (cdr bind) gen)))
  self.location)

(define-method ir-gen-arm64 <ir-let> (gen)
  (let ((last ()))
    (list-do expr self.operands (ir-gen-arm64 (set last expr) gen))))

;; While operations
(define-method ir-gen-arm64-allocate <ir-while> (gen)
  (ir-gen-arm64-allocate   (car   self.operands) gen)  (ir-gen-arm64-deallocate (car   self.operands) gen)
  (ir-gen-arm64-allocate   (cadr  self.operands) gen)  (ir-gen-arm64-deallocate (cadr  self.operands) gen)
  (or (= IR-VOID self.type)
      (set self.location (ir-gen-arm64-allocate gen self.type))))

(define-method ir-gen-arm64 <ir-while> (gen)
  (let ((test (car  self.operands))
	(body (cadr self.operands))
	(rpt (ir-gen-arm64-temp-label gen))
 	(tst (ir-gen-arm64-temp-label gen)))
			(info gen 2 "# WHILE")
			(emitln gen "	b	"tst)
    (emitln gen rpt":")	(ir-gen-arm64 body gen)
    (emitln gen tst":")	(ir-gen-arm64 test gen)
			(emitln gen "	cmp	x0, #0")
			(emitln gen "	b.ne	"rpt)
			(info gen 2 "# DONE")))

;; Variable operations
(define-method ir-gen-arm64-allocate <ir-get-var> (gen)
  (let ((var self.parameters))
    (set self.location
	 (cond
	   ((and (ir-global? self.parameters) *optimise-globals*)	var)
	   ((= self.type (<ir-variable>-type self.parameters))		(<ir-variable>-location var))
	   (else							(ir-gen-arm64-allocate gen self.type))))))

(define-method ir-gen-arm64 <ir-get-var> (gen)
  (or (<ir-variable>-location self.parameters) (error "var has no location "self.parameters))
  (or self.location (error "get-var has no location "self))
  (info gen 2 "# get var "self)
  (if (ir-struct-type? self.type)
      (ir-gen-arm64-move-struct self.type (<ir-variable>-location self.parameters) self.location gen)
    (ir-gen-arm64-load (<ir-variable>-type self.parameters) (<ir-variable>-location self.parameters) gen))
  (info gen 2 "# get var done"))

(define-method ir-gen-arm64-deallocate <ir-get-var> (gen)
  (let ((var self.parameters))
    (or (= self.location var)
	(= self.location (<ir-variable>-location var))
	(ir-gen-arm64-deallocate self.location gen))))

;; Literal operations
(define-method ir-gen-arm64-allocate <ir-lit> (gen)
  (cond
    ((and (= self.type IR-INT64)
	  *optimise-literals*)	(set self.location self))
    (else			(set self.location (ir-gen-arm64-allocate gen self.type)))))

(define-method ir-gen-arm64 <ir-lit> (gen)
  (info gen 2 "# LIT "self)
  (or (= self.location self)
      (let ((value    (car self.parameters))
	    (location self.location))
	(cond
	  ((= self.type IR-INT8)	(emitln gen "	mov	w0, #" (& value 0xff)))
	  ((= self.type IR-INT16)	(emitln gen "	mov	w0, #" (& value 0xffff)))
	  ((= self.type IR-INT32)	(emitln gen "	mov	w0, #" value))
	  ((= self.type IR-INT64)	(emitln gen "	mov	x0, #" value))
	  ((= self.type IR-FLOAT32)	(let ((label (ir-gen-arm64-temp-label gen)))
					  (ir-gen-arm64-section gen 'data)
					  (emitln gen	 "	.balign	4")
					  (emitln gen label":	.float	" value)
					  (ir-gen-arm64-section gen 'text)
					  (emitln gen "	adrp	x1, " label "@PAGE")
					  (emitln gen "	add	x1, x1, " label "@PAGEOFF")
					  (emitln gen "	ldr	s0, [x1]")))
	  ((= self.type IR-FLOAT64)	(let ((label (ir-gen-arm64-temp-label gen)))
					  (ir-gen-arm64-section gen 'data)
					  (emitln gen	 "	.balign	8")
					  (emitln gen label":	.double	" value)
					  (ir-gen-arm64-section gen 'text)
					  (emitln gen "	adrp	x1, " label "@PAGE")
					  (emitln gen "	add	x1, x1, " label "@PAGEOFF")
					  (emitln gen "	ldr	d0, [x1]")))
	  ((= self.type IR-STRING)	(let ((label (ir-gen-arm64-temp-label gen))
					      (len   (string-length value)))
					  (ir-gen-arm64-section gen 'data)
					  (emit gen label":	.byte	")
					  (for (i 0 len) (emit gen (string-at value i)","))
					  (emitln gen "0")
					  (ir-gen-arm64-section gen 'text)
					  (emitln gen "	adrp	x0, " label "@PAGE")
					  (emitln gen "	add	x0, x0, " label "@PAGEOFF")))
	  (else				(error "cannot generate literal type: "self.type))))))

(define-method ir-gen-arm64-deallocate <ir-lit> (gen)
  (or (= self self.location)
      (ir-gen-arm64-deallocate self.location gen)))

;; Indirect memory operations
(define-function ir-gen-arm64-indir-load (gen type ptr loc)
  (cond
    ((= type IR-INT8)		(emitln gen "	ldrb	w0, [" ptr "]"))
    ((= type IR-INT16)		(emitln gen "	ldrh	w0, [" ptr "]"))
    ((= type IR-INT32)		(emitln gen "	ldr	w0, [" ptr "]"))
    ((= type IR-INT64)		(emitln gen "	ldr	x0, [" ptr "]"))
    ((ir-pointer-type? type)	(emitln gen "	ldr	x0, [" ptr "]"))
    ((= type IR-FLOAT32)	(emitln gen "	ldr	s0, [" ptr "]"))
    ((= type IR-FLOAT64)	(emitln gen "	ldr	d0, [" ptr "]"))
    ((ir-struct-type? type)	(ir-gen-arm64-load-struct type ptr loc gen))
    (else			(error "cannot load indirect: "type))))

(define-function ir-gen-arm64-indir-store (gen type loc ptr)
  (cond
    ((= type IR-INT8)		(emitln gen "	strb	w0, [" ptr "]"))
    ((= type IR-INT16)		(emitln gen "	strh	w0, [" ptr "]"))
    ((= type IR-INT32)		(emitln gen "	str	w0, [" ptr "]"))
    ((= type IR-INT64)		(emitln gen "	str	x0, [" ptr "]"))
    ((ir-pointer-type? type)	(emitln gen "	str	x0, [" ptr "]"))
    ((= type IR-FLOAT32)	(emitln gen "	str	s0, [" ptr "]"))
    ((= type IR-FLOAT64)	(emitln gen "	str	d0, [" ptr "]"))
    ((ir-struct-type? type)	(ir-gen-arm64-store-struct type loc ptr gen))
    (else			(error "cannot store indirect: "type))))

;; Address-of operations
(define-function ir-gen-arm64-addressof-member (self dst gen)
  (with-instance-accessors <ir-member>
    (let* ((value  (car self.operands))
	   (vtype  (<ir-insn>-type value))
	   (member (car self.parameters))
	   (offset (<ir-struct-member>-offset member)))
      (if (and (ir-get-var? value) (ir-struct-type? vtype))
	  (ir-gen-arm64-addressof value dst gen)
	(info gen 2 "# address of "value)
	(ir-gen-arm64 value gen)
	(or (= x0 dst) (emitln gen "	mov	" dst ", x0")))
      (info gen 2 "# offset "offset)
      (or (= 0 offset)
	  (emitln gen "	add	" dst ", " dst ", #" (<ir-struct-member>-offset member))))))

(define-selector ir-gen-arm64-addressof)

(define-method ir-gen-arm64-addressof <ir-get-var> (dst gen)
  (info gen 2 "# address of "self.parameters)
  (emitln gen "	add	" dst ", x29, #" (<ir-location>-offset (<ir-variable>-location self.parameters))))

(define-method ir-gen-arm64-addressof <ir-member> (dst gen)	(ir-gen-arm64-addressof-member self dst gen))
(define-method ir-gen-arm64-addressof <ir-set-member> (dst gen)	(ir-gen-arm64-addressof-member self dst gen))

(define-method ir-gen-arm64-allocate <ir-addressof> (gen)
  (ir-gen-arm64-allocate (car self.operands) gen)
  (ir-gen-arm64-deallocate (car self.operands) gen)
  (set self.location (ir-gen-arm64-allocate gen self.type)))

(define-method ir-gen-arm64 <ir-addressof> (gen)
  (ir-gen-arm64-addressof (car self.operands) x0 gen))

;; Member operations
(define-method ir-gen-arm64-allocate <ir-member> (gen)
  (let* ((value (car self.operands))
	 (vtype (<ir-insn>-type value)))
    (or (ir-struct-type? vtype)
	(ir-gen-arm64-allocate value gen))
    (set self.location (ir-gen-arm64-allocate gen self.type))))

(define-method ir-gen-arm64 <ir-member> (gen)
  (let* ((memb     (car self.parameters))
	 (mtype    (<ir-struct-member>-type memb)))
    (info gen 2 "# get member "memb)
    (ir-gen-arm64-addressof self x0 gen)
    (ir-gen-arm64-indir-load gen mtype x0 self.location)))

(define-method ir-gen-arm64-allocate <ir-set-member> (gen)
  (let* ((lval  (car  self.operands))
	 (ltype (<ir-insn>-type lval))
	 (rval  (cadr self.operands)))
    (ir-gen-arm64-allocate     rval gen)
    (unless (ir-struct-type? ltype)
      (ir-gen-arm64-allocate   lval gen)
      (ir-gen-arm64-deallocate lval gen))
    (ir-gen-arm64-deallocate   rval gen)
    (set self.location (ir-gen-arm64-allocate gen self.type))))

(define-method ir-gen-arm64 <ir-set-member> (gen)
  (let* ((rval     (cadr self.operands))
	 (memb     (car self.parameters))
	 (mtype    (<ir-struct-member>-type memb)))
    (ir-gen-arm64        rval gen)
    (ir-gen-arm64-spill  rval gen)
    (info gen 2 "# set member "memb)
    (ir-gen-arm64-addressof self x1 gen)
    (ir-gen-arm64-reload rval gen)
    (ir-gen-arm64-indir-store gen mtype self.location x1)))

;; Arithmetic operations
(define-method ir-gen-arm64 <ir-add> (gen)
  (let* ((lhs (car  self.operands))
	 (rhs (cadr self.operands)))
    (ir-gen-arm64       rhs gen)
    (ir-gen-arm64-spill rhs gen)
    (ir-gen-arm64       lhs gen)
    (info gen 2 "# add")
    (cond
      ((= self.type IR-INT32)	(emitln gen "	ldr	w1, " (<ir-insn>-location rhs))
				(emitln gen "	add	w0, w0, w1"))
      ((= self.type IR-INT64)	(emitln gen "	ldr	x1, " (<ir-insn>-location rhs))
				(emitln gen "	add	x0, x0, x1"))
      (else			(error "cannot generate add on type: " self.type)))))

(define-method ir-gen-arm64 <ir-sub> (gen)
  (let* ((lhs (car  self.operands))
	 (rhs (cadr self.operands)))
    (ir-gen-arm64       rhs gen)
    (ir-gen-arm64-spill rhs gen)
    (ir-gen-arm64       lhs gen)
    (info gen 2 "# sub")
    (cond
      ((= self.type IR-INT32)	(emitln gen "	ldr	w1, " (<ir-insn>-location rhs))
				(emitln gen "	sub	w0, w0, w1"))
      ((= self.type IR-INT64)	(emitln gen "	ldr	x1, " (<ir-insn>-location rhs))
				(emitln gen "	sub	x0, x0, x1"))
      (else			(error "cannot generate sub on type: " self.type)))))

;; Comparison operations
(define-method ir-gen-arm64 <ir-eq> (gen)
  (let* ((lhs (car  self.operands))
	 (rhs (cadr self.operands)))
    (ir-gen-arm64       rhs gen)
    (ir-gen-arm64-spill rhs gen)
    (ir-gen-arm64       lhs gen)
    (info gen 2 "# eq")
    (cond
      ((= (<ir-insn>-type lhs) IR-INT32)	
       (emitln gen "	ldr	w1, " (<ir-insn>-location rhs))
       (emitln gen "	cmp	w0, w1")
       (emitln gen "	cset	w0, eq"))
      ((= (<ir-insn>-type lhs) IR-INT64)	
       (emitln gen "	ldr	x1, " (<ir-insn>-location rhs))
       (emitln gen "	cmp	x0, x1")
       (emitln gen "	cset	x0, eq"))
      (else			(error "cannot generate eq on type: " (<ir-insn>-type lhs))))))

;; Control flow
(define-method ir-gen-arm64-allocate <ir-if> (gen)
  (ir-gen-arm64-allocate   (car   self.operands) gen)  (ir-gen-arm64-deallocate (car   self.operands) gen)
  (ir-gen-arm64-allocate   (cadr  self.operands) gen)  (ir-gen-arm64-deallocate (cadr  self.operands) gen)
  (ir-gen-arm64-allocate   (caddr self.operands) gen)  (ir-gen-arm64-deallocate (caddr self.operands) gen)
  (or (= IR-VOID self.type)
      (set self.location (ir-gen-arm64-allocate gen self.type))))

(define-method ir-gen-arm64 <ir-if> (gen)
  (let ((test (car   self.operands))
	(then (cadr  self.operands))
	(else (caddr self.operands))
	(alt  (ir-gen-arm64-temp-label gen))
 	(end  (ir-gen-arm64-temp-label gen))
	(void (= IR-VOID self.type)))
		(info gen 2 "# IF")
		(ir-gen-arm64 test gen)
		(emitln gen "	cmp	x0, #0")
		(emitln gen "	b.eq	" alt)
		(info gen 2 "# THEN")
		(ir-gen-arm64 then gen)
		(emitln gen "	b	" end)
		(info gen 2 "# ELSE")
    (emitln gen alt":")	(ir-gen-arm64 else gen)
		(info gen 2 "# FI")
    (emitln gen end":")))

;; Function calls
(define-method ir-gen-arm64-allocate <ir-call> (gen)
  (or (= IR-VOID self.type)
      (set self.location (ir-gen-arm64-allocate gen self.type)))
  (list-do arg self.operands (ir-gen-arm64-allocate arg gen))
  (reverse-map-with ir-gen-arm64-deallocate self.operands gen)
  self.location)

(define-method ir-gen-arm64 <ir-call> (gen)
  (list-do op self.operands
    (ir-gen-arm64       op gen)
    (ir-gen-arm64-spill op gen))
  (info gen 2 "# call")
  (ir-gen-arm64-reload (car self.operands) gen)
  (emitln gen "	blr	x0"))

;; NOP operations
(define-method ir-gen-arm64-allocate <ir-nop> (gen))
(define-method ir-gen-arm64 <ir-nop> (gen))

;; Function implementation
(define-method ir-gen-function-implementation <ir-gen-arm64> (value)
  (let* ((name      (ir-gen-arm64-function-name value))
	 (type      (<ir-pointer-type>-referent (<ir-function>-type value)))
	 (args      (cadr (<ir-function>-parameters value)))
	 (scope     (<ir-function>-scope value))
	 (body      (<ir-function>-operands value))
	 (calls     (<ir-function>-calls value))
	 (offset    (if (ir-struct-type? (<ir-function-type>-ret-type type)) 24 16))
	 (argsize   (ir-gen-arm64-allocate-parameters offset (<ir-scope>-bindings scope)))
	 (framesize 0))
    (set self.callsize 0)
    (set self.frame (ir-frame-new))
    (list-do insn body (ir-gen-arm64-allocate insn self))
    (set self.callsize (align self.callsize 16))
    (set framesize (align (+ 16 (ir-frame-finalise self.frame self.callsize)) 16))
    (ir-gen-arm64-section self 'text)
    (and *align-functions* (emitln self "	.balign	"*align-functions*))
    (info self 0 "# FUNCTION "name" "self.callsize" "framesize" "type)
    (emitln self "	.globl	"name)
    (emitln self name":")
    (ir-gen-arm64-prologue self framesize)
    (let ((last))
      (list-do insn body (ir-gen-arm64 (set last insn) self))
      (unless (and last (ir-returns? last))
	(ir-gen-arm64-epilogue self)))))

;; Global declarations and initialization
(define-method ir-gen-declare-struct <ir-gen-arm64> (struct)	())

(define-method ir-gen-global-declaration <ir-gen-arm64> (var)	(set (<ir-variable>-location var) var))

(define-method ir-gen-local-declaration  <ir-gen-arm64> (var)	())

(define-method ir-gen-initialisation <ir-gen-arm64> (definition)
  (ir-gen-arm64-section self 'data)
  (let* ((setter (car (<ir-define>-operands definition)))
	 (var    (<ir-set-var>-parameters setter))
	 (name   (ir-gen-arm64-variable-name var))
	 (type   (<ir-global>-type var))
	 (init   (car (<ir-set-var>-operands setter)))
	 (kind   (type-of init)))
    (cond
      ((= kind <ir-extern>)	(emitln self name":	.quad	"__USER_LABEL_PREFIX__(car (<ir-extern>-parameters init))))
      ((= kind <ir-function>)	(emitln self name":	.quad	"(ir-gen-arm64-function-name init)))
      (else			(error "cannot initialise: "name" with: "value)))))

(define-method ir-gen-header <ir-gen-arm64> ()	
  (info self 0 "# ARM64 BACKEND HEADER")
  (emitln self "	.arch armv8-a"))

(define-method ir-gen-preamble <ir-gen-arm64> ()	(info self 0 "# PRE-INITIALISATION"))
(define-method ir-gen-postamble <ir-gen-arm64> ()	(info self 0 "# POST-INITIALISATION"))