(require "osdefs.k")

;;; Backend Selection System
(define *emit-backend* 'asm)  ; default to assembly backend
;; Available backends: 'asm, 'c, 'c-cps, 'c-threaded
(define *c-generation-mode* 'simple) ; 'simple, 'cps, or 'threaded

;;; Assembly backend state
(define __PREFIX__ (if (or (defined? '__MACH__) (defined? '__WIN32__)) "_" ""))

;;; C backend state
(define *c-indent-level* 0)
(define *c-current-function* "unknown_function")
(define *c-current-params* ())
(define *c-functions* ())  ; List of function info: (name params body)
(define *c-pass* 1)        ; Current pass (1=collect, 2=generate)
(define *c-arg-count* 0)   ; For tracking function arguments

;;; C backend helpers
(define-function c-indent ()
  (let ((i 0))
    (while (< i *c-indent-level*)
      (print "  ")
      (set i (+ i 1)))))

(define-function c-newline ()
  (println)
  (c-indent))

;;; Common infrastructure
(define-function string->type-name (str) (string->symbol (concat-string "<" (concat-string str ">"))))
(define-function symbol->type-name (sym) (string->type-name (symbol->string sym)))

(define-function align (alignment value)	(& (- alignment) (+ (- alignment 1) value )))

(define-function variable (name value env index)
  (let ((self (new <variable>)))
    (set (<variable>-name  self) name)
    (set (<variable>-value self) value)
    (set (<variable>-env   self) env)
    (set (<variable>-index self) index)
    self))

(define-function variable? (obj) (= <variable> (type-of obj)))

(define-function environment (parent)
  (let ((self (new <env>)))
    (set (<env>-parent   self) parent)
    (set (<env>-level    self) (if parent (<env>-level  parent) 0))
    (set (<env>-offset   self) 0)
    (set (<env>-bindings self) (array))
    self))

;;; EXTERN

(define-structure <extern> (name stub))

(define-function extern (name)
  (let ((self (new <extern>)))
    (set (<extern>-name self) name)
    self))

(define-function extern? (obj) (= <extern> (type-of obj)))

;;; DEFINE-OPERAND

(define-function define-operand-make-setters (tname fields)
  (if (pair? fields)
      (cons `(set (,(concat-symbol (concat-symbol tname '-) (car fields)) self) ,(car fields))
	    (define-operand-make-setters tname (cdr fields)))))

(define-form define-operand (name fields . printing)
  (let* ((sname (symbol->string name))
	 (tname (string->symbol (concat-string "<" (concat-string sname ">")))))
    (eval `(define-structure ,tname ,fields))
    (eval `(define-function ,name ,fields
	     (let ((self (new ,tname)))
	       ,@(define-operand-make-setters tname fields)
	       self)))
    `(define-method do-print ,tname () (print ,@printing))))

;;; DEFINE-INSTRUCTION

(define-form define-instruction (name)
  (let* ((sname (symbol->string name))
	 (tname (string->symbol (concat-string "<" (concat-string sname ">")))))
    `(let ()
       (define-structure ,tname ())
       (define-method do-print ,tname () (print ,sname))
       (define ,name (new ,tname)))))

;;; DEFINE-EMIT

(define-generic emit op-args
  (warn "emit: illegal instruction: " op-args "\n")
  (error "aborted"))

(define-multimethod emit ((<pair> program))
  (while program
    (apply emit (car program))
    (set program (cdr program))))

;; Helper function for parameter naming - use simple hardcoded approach
(define-function %define-emit-param-name (index)
  (cond
    ((= index 1) '$1)
    ((= index 2) '$2)
    ((= index 3) '$3)
    ((= index 4) '$4)
    ((= index 5) '$5)
    ((= index 6) '$6)
    ((= index 7) '$7)
    ((= index 8) '$8)
    ((= index 9) '$9)
    (else '$N)))  ;; fallback for more than 9 params

(define-function %define-emit-params (index types)
  (if (pair? types)
      (cons (list (symbol->type-name (car types)) (%define-emit-param-name index))
	    (%define-emit-params (+ index 1) (cdr types)))))

(define-form define-emit (op-args . body)
  (let* ((opsym (car op-args))
	 (sname (symbol->string opsym))
	 (tname (string->type-name sname)))
    `(let ()
       ,@(if (not (defined? opsym *globals*)) `((define-instruction ,opsym)))
       (define-multimethod emit ((,tname op) ,@(%define-emit-params 1 (cdr op-args))) ,@body))))

;;; Label mangling

(define-function digit-for (c)
  (if (< c 10)
      (+ c 0x30)
    (+ c 0x37)))

(define-function c-mangle-label (name)
  (let* ((plain  (symbol->string name))
	 (mangled (array))
	 (index   0)
	 (outdex  0)
	 (size    (string-length plain)))
    (while (< index size)
      (let ((c (string-at plain index)))
	(cond
	  ((or (and (<= 0x61 c) (<= c 0x7a))
	       (and (<= 0x41 c) (<= c 0x5a))
	       (and (<= 0x30 c) (<= c 0x39)))	(let ()
						  (set-array-at mangled outdex c)			(set outdex (+ outdex 1))))
	  ((= ?_ c)				(let ()
						  (set-array-at mangled outdex c)			(set outdex (+ outdex 1))
						  (set-array-at mangled outdex c)			(set outdex (+ outdex 1))))
	  (else					(let ()
						  (set-array-at mangled outdex 0x5f)			(set outdex (+ outdex 1))))))
      (set index (+ 1 index)))
    (array->string mangled)))

(define-function mangle-label (name)
  (if (= *emit-backend* 'c)
      (c-mangle-label name)
    (let* ((plain  (symbol->string name))
	   (mangled (array))
	   (index   0)
	   (outdex  0)
	   (size    (string-length plain)))
      (while (< index size)
	(let ((c (string-at plain index)))
	  (cond
	    ((or (and (<= 0x61 c) (<= c 0x7a))
		 (and (<= 0x41 c) (<= c 0x5a))
		 (and (<= 0x30 c) (<= c 0x39)))	(let ()
						    (set-array-at mangled outdex c)			(set outdex (+ outdex 1))))
	    ((= ?_ c)				(let ()
						    (set-array-at mangled outdex c)			(set outdex (+ outdex 1))
						    (set-array-at mangled outdex c)			(set outdex (+ outdex 1))))
	    (else					(let ()
						    (set-array-at mangled outdex 0x5f)			(set outdex (+ outdex 1))
						    (set-array-at mangled outdex (digit-for (>> c  4)))	(set outdex (+ outdex 1))
						    (set-array-at mangled outdex (digit-for (&  c 15)))	(set outdex (+ outdex 1))))))
	(set index (+ 1 index)))
      (array->string mangled))))

;;; OPERANDS

(define *label-source* ())
(define *label-counter* 0)

(define-function temp-label-name ()
  (let ((label (concat-string "_L_" (long->string (set *label-counter* (+ *label-counter* 1))))))
    (and *label-source* (set label (concat-strings label"_"(car *label-source*)"_"(long->string (cdr *label-source*)))))
    label))

(define-operand LABEL (name) 	__PREFIX__(mangle-label (<LABEL>-name self)))
(define-operand GI32 (name)	(<GI32>-name self))
(define-operand LI32 (value)	(<LI32>-value self))
(define-operand TI32 (offset)	(<TI32>-offset self)"(%esp)")

(define-function temp? (obj)	(= <TI32> (type-of obj)))

;;; Helper to get temp name for C
(define-function c-temp-name (temp)
  (concat-string "_tmp" (long->string (>> (<TI32>-offset temp) 2))))

;;; Helper to format TI32 for the current backend
(define-function fmt-ti32 (temp)
  (if (= *emit-backend* 'c)
      (c-temp-name temp)
    temp))

;;; UNIFIED INSTRUCTIONS - Each checks backend and generates appropriate output

(define-emit (TEXT)
  (if (= *emit-backend* 'c)
      () ; No-op in C
    (println "	.text")))

(define-emit (DATA)
  (if (= *emit-backend* 'c)
      () ; No-op in C
    (println "	.data")))

(define-emit (SECTION string)
  (if (= *emit-backend* 'c)
      () ; No-op in C
    (println "	.section "$1)))

(define-emit (INDIRECT LABEL)
  (if (= *emit-backend* 'c)
      () ; No-op in C
    (println "	.indirect_symbol "$1)))

(define-emit (GLOBAL LABEL)
  (if (= *emit-backend* 'c)
      () ; Global functions are already visible in C
    (println "	.globl "$1)))

(define-emit (ALIGN long)
  (if (= *emit-backend* 'c)
      () ; No-op in C
    (println "	.align " $1)))

(define-emit (LONG long)
  (if (= *emit-backend* 'c)
      (let ()
        (print "  " $1 ",") 
        (c-newline))
    (println "	.long "$1)))

(define-emit (LONG LABEL)
  (if (= *emit-backend* 'c)
      (let ()
        (print "  (long)" $1 ",") 
        (c-newline))
    (println "	.long "$1)))

(define-emit (ASCIZ string)
  (if (= *emit-backend* 'c)
      (let ()
        (print "  ") 
        (dumpln $1) 
        (print ",") 
        (c-newline))
    (let ()
      (print   "	.asciz ") 
      (dumpln $1))))

(define-emit (DEFLABEL LABEL)
  (if (= *emit-backend* 'c)
      (let ()
        (println)
        (println "static long " $1 "[] = {"))
    (println $1":")))

(define-emit (ENTER long)
  (if (= *emit-backend* 'c)
      (let ()
        (println "{")
        (set *c-indent-level* (+ *c-indent-level* 1))
        (set *c-arg-count* 0)
        (c-indent) (println "oop _acc = LONG(0);")
        (c-indent) (println "/* locals: " $1 " bytes */"))
    (let ()
      (println "	pushl %ebp")
      (println "	movl %esp,%ebp")
      (println "	subl $"$1",%esp"))))

(define-emit (LEAVE long)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) (println "return _acc;")
        (set *c-indent-level* (- *c-indent-level* 1))
        (println "}")
        (println))
    (let ()
      (println "	addl $"$1",%esp")
      (println "	leave")
      (println "	ret"))))

;;; ARITHMETIC OPERATIONS

(define-emit (NEG)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(-getLong(_acc));"))
    (println "	negl %eax")))

(define-emit (ADD TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) + getLong(" (c-temp-name $1) "));"))
    (println "	addl "$1",%eax")))

(define-emit (SUB TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) - getLong(" $1 "));"))
    (println "	subl "$1",%eax")))

(define-emit (MUL TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) * getLong(" $1 "));"))
    (println "	mull "$1)))

(define-emit (DIV TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) / getLong(" $1 "));"))
    (let ()
      (println "	movl $0,%edx")
      (println "	divl "$1))))

(define-emit (AND TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) & getLong(" $1 "));"))
    (println "	andl "$1",%eax")))

(define-emit (OR TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) | getLong(" $1 "));"))
    (println "	orl "$1",%eax")))

(define-emit (XOR TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) ^ getLong(" $1 "));"))
    (println "	xorl "$1",%eax")))

(define-emit (NOT)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (_acc == nil) ? LONG(1) : LONG(0);"))
    (let ()
      (println "	cmpl $0,%eax")
      (println "	sete %al")
      (println "	movzbl %al,%eax"))))

;;; COMPARISON OPERATIONS

(define-emit (LT TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (getLong(_acc) < getLong(" $1 ")) ? LONG(1) : LONG(0);"))
    (let ()
      (println "	cmpl "$1",%eax")
      (println "	setl %al")
      (println "	movzbl %al,%eax"))))

(define-emit (LE TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (getLong(_acc) <= getLong(" $1 ")) ? LONG(1) : LONG(0);"))
    (let ()
      (println "	cmpl "$1",%eax")
      (println "	setle %al")
      (println "	movzbl %al,%eax"))))

(define-emit (EQ TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (_acc == " $1 ") ? LONG(1) : LONG(0);"))
    (let ()
      (println "	cmpl "$1",%eax")
      (println "	sete %al")
      (println "	movzbl %al,%eax"))))

(define-emit (NE TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (_acc != " $1 ") ? LONG(1) : LONG(0);"))
    (let ()
      (println "	cmpl "$1",%eax")
      (println "	setne %al")
      (println "	movzbl %al,%eax"))))

(define-emit (GE TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (getLong(_acc) >= getLong(" $1 ")) ? LONG(1) : LONG(0);"))
    (let ()
      (println "	cmpl "$1",%eax")
      (println "	setge %al")
      (println "	movzbl %al,%eax"))))

(define-emit (GT TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (getLong(_acc) > getLong(" $1 ")) ? LONG(1) : LONG(0);"))
    (let ()
      (println "	cmpl "$1",%eax")
      (println "	setg %al")
      (println "	movzbl %al,%eax"))))

(define-emit (SLA TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) << getLong(" $1 "));"))
    (let ()
      (println "	movl "$1",%ecx")
      (println "	shll %cl,%eax"))))

(define-emit (SRA TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(getLong(_acc) >> getLong(" $1 "));"))
    (let ()
      (println "	movl "$1",%ecx")
      (println "	sarl %cl,%eax"))))

;;; CONTROL FLOW

(define-emit (BR LABEL)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "goto " $1 ";"))
    (println "	jmp "$1)))

(define-emit (BF LABEL)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "if (_acc == nil) goto " $1 ";"))
    (let ()
      (println "	cmpl $0,%eax")
      (println "	je "$1))))

(define-emit (BT LABEL)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "if (_acc != nil) goto " $1 ";"))
    (let ()
      (println "	cmpl $0,%eax")
      (println "	jne "$1))))

(define-emit (CALL LABEL)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (print "_acc = " $1 "(")
        (let ((i 0))
          (while (< i *c-arg-count*)
            (and (> i 0) (print ", "))
            (print "_arg" i)
            (set i (+ i 1))))
        (println ");")
        (set *c-arg-count* 0))
    (println "	call "$1)))

(define-emit (CALL long)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (print "_acc = ((oop (*)())_acc)(")
        (let ((i 0))
          (while (< i $1)
            (and (> i 0) (print ", "))
            (print "_arg" i)
            (set i (+ i 1))))
        (println ");")
        (set *c-arg-count* 0))
    (println "	call *%eax")))

;;; LOAD/STORE OPERATIONS

(define-emit (LOAD LI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(" $1 ");"))
    (println "	movl $"$1",%eax")))

(define-emit (LOAD LABEL)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (oop)" $1 ";"))
    (println "	movl $"$1",%eax")))

(define-emit (LOAD GI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = " $1 ";"))
    (println "	movl " $1",%eax")))

(define-emit (LOAD TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = " (fmt-ti32 $1) ";"))
    (println "	movl " $1",%eax")))

(define-emit (STORE TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println (fmt-ti32 $1) " = _acc;"))
    (println "	movl %eax,"$1)))

(define-emit (STORE GI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println $1 " = _acc;"))
    (println "	movl %eax,"$1)))

(define-emit (ADDR GI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (oop)&" $1 ";"))
    (println "	movl $"$1",%eax")))

(define-emit (ADDR TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = (oop)&" (fmt-ti32 $1) ";"))
    (println "	leal "$1",%eax")))

(define-emit (MOVE TI32 TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println $2 " = " $1 ";")
        (set *c-arg-count* (+ *c-arg-count* 1)))
    (let ()
      (println "	movl "$1",%ecx")
      (println "	movl %ecx,"$2))))

(define-emit (COMMENT pair)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (print "/* ") 
        (apply print $1) 
        (println " */"))
    (let ()
      (print "## ") 
      (apply println $1))))

;;; MEMORY ACCESS OPERATIONS

(define-emit (CHR-AT TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = LONG(((char*)_acc)[getLong(" $1 ")]);"))
    (let ()
      (println "	movl "$1",%ecx")
      (println "	leal (%eax,%ecx),%ecx")
      (println "	xorl %eax,%eax")
      (println "	movb (%ecx),%al"))))

(define-emit (SET-CHR-AT TI32 TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "((char*)_acc)[getLong(" $1 ")] = (char)getLong(" $2 ");"))
    (let ()
      (println "	movl "$1",%ecx")
      (println "	leal (%eax,%ecx),%ecx")
      (println "	movl "$2",%eax")
      (println "	movb %al,(%ecx)"))))

(define-emit (OOP-AT TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "_acc = ((oop*)_acc)[getLong(" $1 ")];"))
    (let ()
      (println "	movl "$1",%ecx")
      (println "	leal (%eax,%ecx,4),%ecx")
      (println "	movl (%ecx),%eax"))))

(define-emit (SET-OOP-AT TI32 TI32)
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) 
        (println "((oop*)_acc)[getLong(" $1 ")] = " $2 ";"))
    (let ()
      (println "	movl "$1",%ecx")
      (println "	leal (%eax,%ecx,4),%ecx")
      (println "	movl "$2",%eax")
      (println "	movl %eax,(%ecx)"))))

;;; COMPILER STRUCTURE

(define-structure <compiler> (level param-counter arg-counter arg-limit tmp-counter tmp-limit temps epilogue asm pc section))

(define-function compiler (level)
  (let ((self (new <compiler>)))
    (set (<compiler>-level	   self) level)
    (set (<compiler>-param-counter self) 0)
    (set (<compiler>-arg-counter   self) 0)
    (set (<compiler>-arg-limit	   self) 0)
    (set (<compiler>-tmp-counter   self) 0)
    (set (<compiler>-tmp-limit	   self) 0)
    (set (<compiler>-asm	   self) (array))
    (set (<compiler>-pc		   self) 0)
    self))

(define-function new-param (comp)
  (let* ((i (<compiler>-param-counter comp))
	 (t (TI32 i)))
    (set (<compiler>-param-counter comp) (+ i 4))
    t))

(define-function new-arg (comp)
  (let* ((i (<compiler>-arg-counter comp))
	 (t (TI32 i)))
    (set (<compiler>-arg-counter comp) (+ i 4))
    t))

(define-function free-args (comp args)
  (and (< (<compiler>-arg-limit comp) (<compiler>-arg-counter comp))
       (set (<compiler>-arg-limit comp) (<compiler>-arg-counter comp)))
  (set (<compiler>-arg-counter comp) 0))

(define-function new-temp (comp)
  (let* ((i (<compiler>-tmp-counter comp))
	 (t (TI32 i)))
    (set (<compiler>-tmp-counter comp) (+ i 4))
    (and (< (<compiler>-tmp-limit comp) (<compiler>-tmp-counter comp))
	 (set (<compiler>-tmp-limit comp) (<compiler>-tmp-counter comp)))
    t))

(define-function alloc-temp (comp)
  (or (pop (<compiler>-temps comp))
      (new-temp comp)))

(define-function free-temp (comp temp)		(push (<compiler>-temps comp) temp))
(define-function free-temps (comp temps)	(list-do temp temps (free-temp comp temp)))

;;; GEN

(define-selector gen)

(define-method gen <compiler> args
  ;;(print "## insn ") (dumpln args)
  (set-array-at (<compiler>-asm self) (<compiler>-pc self) args)
  (set (<compiler>-pc self) (+ 1 (<compiler>-pc self))))

(define-method gen <undefined>	(comp)	(gen comp LOAD (LI32 0)))
(define-method gen <long>	(comp)	(gen comp LOAD (LI32 self)))

(define-method gen <variable> (comp)
  (let ((value (<variable>-value self)))
    (if (extern? value)
	(gen comp LOAD (GI32 (LABEL (concat-symbol (<variable>-name self) '$stub))))
      (if (temp? value)
	  (gen comp LOAD value)
	  (gen comp LOAD (GI32 (LABEL (<variable>-name self))))))))

(define-method gen <string> (comp)
  (let ((label (LABEL (temp-label-name))))
    (gen comp DATA)
    (gen comp DEFLABEL label)
    (gen comp ASCIZ self)
    (gen comp TEXT)
    (gen comp LOAD label)))

(define-function gen-tmp-prog (prog comp)
  (while (pair? prog)
    (gen (car prog) comp)
    (set prog (cdr prog)))
  (let ((t (alloc-temp comp)))
    (gen comp STORE t)
    t))

(define-function gen-tmp (expr comp)
  (gen expr comp)
  (let ((t (alloc-temp comp)))
    (gen comp STORE t)
    t))

(define-function gen-arg (expr comp)
  (new-arg comp))

(define-function gen-move (a b comp)
  (gen comp MOVE a b))

(define-function generate-nullary (op args comp)
  (gen comp op))

(define-function generate-unary (op args comp)
  (gen (car args) comp)
  (gen comp op))

(define-function generate-binary (op args comp)
  (let ((tmp (gen-tmp (cadr args) comp)))
    (gen (car args) comp)
    (free-temp comp tmp)
    (gen comp op tmp)))

(define-function generate-ternary (op args comp)
  (let ((tmp2 (gen-tmp (caddr args) comp))
	(tmp1 (gen-tmp (cadr  args) comp)))
    (gen (car args) comp)
    (free-temp comp tmp1)
    (free-temp comp tmp2)
    (gen comp op tmp1 tmp2)))

(define generators (list->array (list generate-nullary generate-unary generate-binary generate-ternary)))

(define operators (list->array
  `(()								; nullary
    ((,-  ,NEG) (,not ,NOT))					; unary
    ((,+  ,ADD) (,-   ,SUB) (,* ,MUL) (,/ ,DIV)			; binary
     (,&  ,AND) (,|   ,OR ) (,^ ,XOR)
     (,<  ,LT ) (,<=  ,LE)  (,= ,EQ ) (,!= ,NE ) (,>= ,GE ) (,> ,GT )
     (,<< ,SLA) (,>>  ,SRA)
     (,oop-at         ,OOP-AT) (,string-at         ,CHR-AT))
    ((,set-oop-at ,SET-OOP-AT) (,set-string-at ,SET-CHR-AT))	; ternary
    )))

(define-function gen-let-binding (binding comp)
  (let ((var (car binding))
	(tmp (gen-tmp-prog (cdr binding) comp)))
    (set (<variable>-value var) tmp)))

(define-function gen-let (expr comp)
  (let ((temps (map-with gen-let-binding (caddr expr) comp)))
    (list-do stmt (cdddr expr) (gen stmt comp))
    (list-do temp temps (free-temp comp temp))))

(define-function gen-and (expr comp)
  (let ((done (LABEL (temp-label-name))))
    (set expr (cdr expr))
    (while expr
      (gen (car expr) comp)
      (and (set expr (cdr expr)) (gen comp BF done)))
    (gen comp DEFLABEL done)))

(define-function gen-or (expr comp)
  (let ((done (LABEL (temp-label-name))))
    (set expr (cdr expr))
    (while expr
      (gen (car expr) comp)
      (and (set expr (cdr expr)) (gen comp BT done)))
    (gen comp DEFLABEL done)))

(define-function gen-if (expr comp)
  (let ((a (LABEL (temp-label-name)))
	(b (LABEL (temp-label-name))))
    (gen (cadr expr) comp)
    (gen comp BF a)
    (gen (caddr expr) comp)
    (gen comp BR b)
    (gen comp DEFLABEL a)
    (list-do stmt (cdddr expr) (gen stmt comp))
    (gen comp DEFLABEL b)))

(define-function gen-while (expr comp)
  (let ((body (LABEL (temp-label-name)))
	(test (LABEL (temp-label-name))))
    (gen comp BR test)
    (gen comp DEFLABEL body)
    (list-do stmt (cddr expr) (gen stmt comp))
    (gen comp DEFLABEL test)
    (gen (cadr expr) comp)
    (gen comp BT body)))

(define-function gen-set (expr comp)
  (let* ((var (cadr expr))
	 (val (<variable>-value var)))
    (gen (caddr expr) comp)
    (if (temp? val)
	(gen comp STORE val)
      (gen comp STORE (GI32 (LABEL (<variable>-name var)))))))

(define-function gen-return (expr comp)
  (list-do stmt (cdr expr) (gen stmt comp))
  (gen comp BR (or (<compiler>-epilogue comp) (set (<compiler>-epilogue comp) (LABEL (temp-label-name))))))

(define-function gen-address-of (expr comp)
  (let ((var (cadr expr)))
    (or (variable? var) (error "address-of: non-variable argument: "var))
    (let ((val (<variable>-value var)))
      (if (temp? val)
	  (gen comp ADDR val)
	(gen comp ADDR (GI32 (LABEL (<variable>-name var))))))))

(define return		(fixed (lambda args (error "(return) encountered in interpreted code"))))
(define address-of	(fixed (lambda args (error "(address-of) encountered in interpreted code"))))

(define forms (list
  (cons  let		gen-let)
  (cons  and	 	gen-and)
  (cons  or	 	gen-or)
  (cons  if	 	gen-if)
  (cons  while		gen-while)
  (cons  set	 	gen-set)
  (cons  return		gen-return)
  (cons  address-of	gen-address-of)))

(define-method gen <pair> (comp)

  (and (= 0 (optimised))
       (let ((source (oop-at self 2)))
	 (and (!= *label-source* source)
	      (car source)
	      (let ()
		(set *label-source* source)
		;;(gen comp DEFLABEL (LABEL (temp-label-name)))		;; DEBUG ONLY
		;;(gen comp COMMENT (list (car source) " " (cdr source)))
		(gen comp DEFLABEL (LABEL (temp-label-name)))))))
  (let* ((head  (car self))
	 (arity (- (list-length self) 1))
	 (op    (and (variable? head) (cadr (assq (<variable>-value head) (array-at operators arity))))))
    (if op
	((array-at generators arity) op (cdr self) comp)
      (if (set op (cdr (assq head forms)))
	  (op self comp)
	(let* ((tmps (map-with gen-tmp (cdr self) comp))
	       (args (map-with gen-arg (cdr self) comp))
	       (func (gen (car self) comp))
	       (narg (list-length args)))
	  (map2-with gen-move tmps args comp)
	  (free-temps comp tmps)
	  (free-args  comp args)
	  (gen comp CALL narg))))))

;;; Two-pass helper functions for C backend
(define-function find-c-function (name)
  "Find function info by name in collected functions"
  (let ((result ()))
    (let ((funcs *c-functions*))
      (while (and (pair? funcs) (not result))
        (if (= name (car (car funcs)))
            (set result (car funcs)))
        (set funcs (cdr funcs))))
    result))

(define-function c-generate-forward-declarations ()
  "Generate forward declarations for all collected functions"
  (println "/* Forward declarations */")
  (let ((funcs *c-functions*))
    (while (pair? funcs)
      (let* ((func-info (car funcs))
             (name (car func-info))
             (param-names (cadr func-info))
             (main (car (cdr (cdr (cdr func-info))))))
        (print "static oop " (c-mangle-label name) "(")
        (let ((first 't))
          (let ((params param-names))
            (while (pair? params)
              (if first
                  (set first ())
                (print ", "))
              (print "oop " (symbol->string (car params)))
              (set params (cdr params)))))
        (if (not param-names)
            (print "void"))
        (println ");"))
      (set funcs (cdr funcs))))
  (println))

(define-function c-gen-preamble ()
  "Generate C preamble with includes and typedefs"
  (println "/* Generated by Maru unified emitter (C backend) */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println "#include <string.h>")
  (println "#include \"gc.h\"")
  (println)
  (println "/* Basic Maru types */")
  (println "typedef void *oop;")
  (println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (println "#define getLong(x) ((long)(x) >> 1)")
  (println)
  (println "/* Runtime functions */")
  (println "extern oop nil;")
  (println))

;;; GEN-DEFINITION

(define-selector gen-definition)

(define-method gen-definition <long> (name comp)
  (if (= *emit-backend* 'c)
      ;; C backend: only generate in pass 2
      (if (= *c-pass* 2)
          (println "static oop v_" (c-mangle-label name) " = LONG(" self ");"))
    ;; Assembly backend
    (let ()
      (gen comp DATA)
      (gen comp DEFLABEL (LABEL name))
      (gen comp LONG self)
      (gen comp TEXT))))

(define-method gen-definition <string> (name comp)
  (if (= *emit-backend* 'c)
      ;; C backend: only generate in pass 2
      (if (= *c-pass* 2)
          (let ()
            (print "static char v_" (c-mangle-label name) "_data[] = ")
            (dumpln self)
            (println ";")
            (println "static oop v_" (c-mangle-label name) " = (oop)v_" (c-mangle-label name) "_data;")))
    ;; Assembly backend
    (let ((temp (LABEL (temp-label-name))))
      (gen comp DATA)
      (gen comp DEFLABEL temp)
      (gen comp ASCIZ self)
      (gen comp ALIGN 4)
      (gen comp DEFLABEL (LABEL name))
      (gen comp LONG temp)
      (gen comp TEXT))))

(define-method gen-definition <extern> (name comp)
  (if (= *emit-backend* 'c)
      ;; C backend: only generate in pass 2 
      (if (= *c-pass* 2)
          (let ()
            (println "extern oop " (c-mangle-label (<extern>-name self)) "();")
            (println "static oop v_" (c-mangle-label (concat-symbol (<extern>-name self) '$stub)) " = (oop)" (c-mangle-label (<extern>-name self)) ";")))
    ;; Assembly backend
    (let ((nlabel (LABEL                (<extern>-name self)        ))
          (slabel (LABEL (concat-symbol (<extern>-name self) '$stub))))
      (if (defined? '__MACH__)
          (let ()
            (gen comp SECTION "__IMPORT,__pointers,non_lazy_symbol_pointers")
            (gen comp DEFLABEL slabel)
            (gen comp INDIRECT nlabel)
            (gen comp LONG 0)
            (gen comp TEXT))
        (gen comp DATA)
        (gen comp DEFLABEL slabel)
        (gen comp LONG nlabel)
        (gen comp TEXT)))))

(define-method gen-definition <form> (name comp)
  (if (= *emit-backend* 'c)
      ;; C backend: only generate in pass 2
      (if (= *c-pass* 2)
          (println "/* form " name " */"))
    ;; Assembly backend
    (gen comp COMMENT (list "form "name))))

(define-function gen-param (var comp)
  ;;(print "gen-param ") (dumpln var)
  (set (<variable>-value var) (new-param comp)))

(define-method gen-definition <expr> (name ocomp)
  ;; Two-pass generation for C backend
  (if (= *emit-backend* 'c)
      (let* ((main (= 'main name))
             (defn (<expr>-defn self))
             (params (cadr defn))
             (body (cddr defn)))
        (if (= *c-pass* 1)
            ;; Pass 1: Collect function information
            (let ((param-names (map (lambda (p) (<variable>-name p)) params)))
              (set *c-functions* (cons (list name param-names body main) *c-functions*)))
          ;; Pass 2: Generate code using collected information
          (let* ((func-info (find-c-function name))
                 (param-names (cadr func-info))
                 (comp (compiler (+ 1 (<compiler>-level ocomp)))))
            ;; Map params to the compiler
            (map-with gen-param params comp)
            ;; Set current function parameters for emit instructions
            (set *c-current-params* param-names)
            (set *c-current-function* (symbol->string name))
            ;; Generate the body
            (list-do e body (gen e comp))
            ;; Calculate frame sizes
            (let* ((arg-size (align 16             (<compiler>-arg-limit comp) ))
                   (tmp-size (align 16 (+ arg-size (<compiler>-tmp-limit comp))))
                   (frm-size (align 16 (+ tmp-size 8))))
              ;; Emit the function
              (if main
                  (let ()
                    (println)
                    (println "int main(int argc, char **argv) {")
                    (set *c-indent-level* 1)
                    (c-indent) (println "oop _acc = LONG(0);")
                    ;; Declare arguments
                    (let ((max-args (<compiler>-arg-limit comp)))
                      (let ((i 0))
                        (while (< i (>> max-args 2))
                          (c-indent) (println "oop _arg" i " = LONG(0);")
                          (set i (+ i 1)))))
                    ;; Declare temps
                    (let ((max-temps (<compiler>-tmp-limit comp)))
                      (let ((i 0))
                        (while (< i (>> max-temps 2))
                          (c-indent) (println "oop " (c-temp-name (TI32 (* i 4))) " = LONG(0);")
                          (set i (+ i 1)))))
                    ;; Generate code
                    (let ((i 0))
                      (while (< i (<compiler>-pc comp))
                        (apply emit (array-at (<compiler>-asm comp) i))
                        (set i (+ i 1))))
                    ;; Epilogue
                    (and (<compiler>-epilogue comp)
                         (println (mangle-label (<compiler>-epilogue comp)) ":"))
                    (c-indent) (println "return 0;")
                    (set *c-indent-level* 0)
                    (println "}")
                    (println))
                (let ()
                  (println)
                  (print "static oop " (c-mangle-label name) "(")
                  (let ((first 't))
                    (let ((params param-names))
                      (while (pair? params)
                        (if first
                            (set first ())
                          (print ", "))
                        (print "oop " (symbol->string (car params)))
                        (set params (cdr params)))))
                  (if (not param-names)
                      (print "void"))
                  (println ") {")
                  (set *c-indent-level* 1)
                  (c-indent) (println "oop _acc = LONG(0);")
                  ;; Declare arguments
                  (let ((max-args (<compiler>-arg-limit comp)))
                    (let ((i 0))
                      (while (< i (>> max-args 2))
                        (c-indent) (println "oop _arg" i " = LONG(0);")
                        (set i (+ i 1)))))
                  ;; Declare temps
                  (let ((max-temps (<compiler>-tmp-limit comp)))
                    (let ((i 0))
                      (while (< i (>> max-temps 2))
                        (c-indent) (println "oop " (c-temp-name (TI32 (* i 4))) " = LONG(0);")
                        (set i (+ i 1)))))
                  ;; Generate code
                  (let ((i 0))
                    (while (< i (<compiler>-pc comp))
                      (apply emit (array-at (<compiler>-asm comp) i))
                      (set i (+ i 1))))
                  ;; Epilogue
                  (and (<compiler>-epilogue comp)
                       (println (mangle-label (<compiler>-epilogue comp)) ":"))
                  (c-indent) (println "return _acc;")
                  (set *c-indent-level* 0)
                  (println "}")
                  (println)
                  ;; Generate global variable
                  (println "static oop v_" (c-mangle-label name) " = (oop)" (c-mangle-label name) ";")
                  (println)))))))
    ;; Original assembly backend logic
    (let* ((main (= 'main name))
           (defn (<expr>-defn self))
           (body (cddr defn))
           (comp (compiler (+ 1 (<compiler>-level ocomp))))
           (tnam (if main (LABEL name) (LABEL (temp-label-name))))
           (vnam (if main ()           (LABEL name)))
           (params (map-with gen-param (cadr defn) comp)))
      (list-do e body (gen e comp))
      (let* ((arg-size (align 16             (<compiler>-arg-limit comp) ))
             (tmp-size (align 16 (+ arg-size (<compiler>-tmp-limit comp))))
             (frm-size (align 16 (+ tmp-size 8))))
        (map (lambda (tmp) (set (<TI32>-offset tmp) (+ arg-size (<TI32>-offset tmp)))) (<compiler>-temps comp))
        (map (lambda (tmp) (set (<TI32>-offset tmp) (+ frm-size (<TI32>-offset tmp)))) params)
        (emit TEXT)
        (and main (emit GLOBAL tnam))
        (emit DEFLABEL tnam)
        (emit COMMENT (list "frame "arg-size" "(<compiler>-tmp-limit comp)" "tmp-size" "frm-size))
        (emit ENTER (- frm-size 8))
        (let ((i 0))
          (while (< i (<compiler>-pc comp))
            (apply emit (array-at (<compiler>-asm comp) i))
            (set i (+ i 1))))
        (and (<compiler>-epilogue comp)
             (emit DEFLABEL (<compiler>-epilogue comp)))
        (emit LEAVE (- frm-size 8)))
      (or main
        (let ()
          (gen ocomp DATA)
          (gen ocomp GLOBAL vnam)
          (gen ocomp DEFLABEL vnam)
          (gen ocomp LONG tnam)
          (gen ocomp TEXT))))))

;;; 

(define-function gen-env (env)
  (if (= *emit-backend* 'c)
      ;; Dispatch to appropriate C generation mode
      (if (= *c-generation-mode* 'cps)
          ;; CPS mode - load and use CPS generator
          (let ()
            (load "core/compiler/emit-c-cps.l")
            (generate-cps-function))
        (if (= *c-generation-mode* 'threaded)
            ;; Threaded mode - use integrated threaded generator
            (let ()
              (load "core/compiler/emit-threaded-integration.l")
              (gen-env-threaded env))
         ;; Simple mode - use existing two-pass generation
         (let* ((vars  (<env>-bindings env))
                (comp  (compiler 0))
                (index (array-length vars)))
           ;; Pass 1: Collect all function information
           (set *c-pass* 1)
           (set *c-functions* ())
           (while (<= 0 (set index (- index 1)))
             (let ((name  (<variable>-name  (array-at vars index)))
                   (value (<variable>-value (array-at vars index))))
               (gen-definition value name comp)))
           
           ;; Generate preamble and forward declarations
           (c-gen-preamble)
           (c-generate-forward-declarations)
           
           ;; Pass 2: Generate implementations
           (set *c-pass* 2)
           (set index (array-length vars))
           (while (<= 0 (set index (- index 1)))
             (let ((name  (<variable>-name  (array-at vars index)))
                   (value (<variable>-value (array-at vars index))))
               (gen-definition value name comp)))
           
           ;; Generate postamble
           (println)
           (println "/* End of generated C code */")))
    ;; Original assembly generation
    (let* ((vars  (<env>-bindings env))
           (comp  (compiler 0))
           (index (array-length vars)))
      (while (<= 0 (set index (- index 1)))
        (let ((name  (<variable>-name  (array-at vars index)))
              (value (<variable>-value (array-at vars index))))
        (println "## defn " name)
        (warn name "\n")
        ;;x;(println (<expr>-defn (cdar env)))
        (gen-definition value name comp)
        ))
      (let ((i 0))
        (while (< i (<compiler>-pc comp))
          (apply emit (array-at (<compiler>-asm comp) i))
          (set i (+ i 1))))
      )))

(define-form compile-begin ()	`(set *globals* (environment *globals*)))

(define-form compile-end ()	(let ((env *globals*))
				  (set *globals* (<env>-parent env))
				  (gen-env env)))

;;; Backend switching convenience functions
(define-function set-emit-backend (backend)
  "Switch between emit backends: 'asm, 'c, 'c-cps, 'c-threaded"
  (if (= backend 'asm)
      (let ()
        (set *emit-backend* 'asm)
        (warn "Using assembly backend\n"))
    (if (= backend 'c)
        (let ()
          (set *emit-backend* 'c)
          (set *c-generation-mode* 'simple)
          (warn "Using simple C backend\n"))
      (if (= backend 'c-cps)
          (let ()
            (set *emit-backend* 'c)
            (set *c-generation-mode* 'cps)
            (warn "Using CPS C backend\n")
            (load "core/compiler/emit-c-cps.l"))
        (if (= backend 'c-threaded)
            (let ()
              (set *emit-backend* 'c)
              (set *c-generation-mode* 'threaded)
              (warn "Using threaded C backend\n")
              (load "core/compiler/emit-threaded-integration.l"))
          (error "Unknown backend: " backend))))))

(define-function use-asm-backend () (set-emit-backend 'asm))
(define-function use-c-backend () (set-emit-backend 'c))
(define-function use-c-cps-backend () (set-emit-backend 'c-cps))
(define-function use-c-threaded-backend () (set-emit-backend 'c-threaded))