;;; emit-core.l -- Core structures and high-level code generation
;;;
;;; This file contains the core infrastructure for code generation,
;;; including structures, utilities, and high-level generation methods.
;;; Backend-specific emission (assembly, C, etc.) is handled separately.

(require "osdefs.k")

(define __PREFIX__ (if (or (defined? '__MACH__) (defined? '__WIN32__)) "_" ""))

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
  (print "\nemit: illegal instruction: "op-args)
  (error "aborted"))

(define-multimethod emit ((<pair> program))
  (while program
    (apply emit (car program))
    (set program (cdr program))))

(define-function %define-emit-param-name (index)
  (string->symbol (concat-string "$" (long->string index))))

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

(define-function digit-for (c)
  (if (< c 10)
      (+ c 0x30)
    (+ c 0x37)))

(define-function mangle-label (name)
  (let* ((plain  (symbol->string name))
	 (mangled (array))
	 (len     (string-length plain)))
    (array-append mangled (string-at __PREFIX__ 0))
    (for (i 0 len)
      (let ((c (string-at plain i)))
	(if (or (and (<= 0x30 c) (<= c 0x39))
		(and (<= 0x41 c) (<= c 0x5a))
		(and (<= 0x61 c) (<= c 0x7a))
		(= ?_ c))
	    (array-append mangled c)
	  (let ()
	    (array-append mangled ?_)
	    (array-append mangled (digit-for (>> c 4)))
	    (array-append mangled (digit-for (& c 15)))))))
    (array->string mangled)))

;;; OPERANDS

(define-operand LABEL	(name)		"L"(mangle-label name))
(define-operand GI32	(LABEL)		(<LABEL>-name LABEL))
(define-operand LI32	(value)		value)
(define-operand TI32	(offset)	(- offset)"(%ebp)")

(define temp?	 <TI32>)
(define temp-offset <TI32>-offset)

;;; INSTRUCTIONS

(define-instruction TEXT)
(define-instruction DATA)
(define-instruction SECTION)
(define-instruction GLOBAL)
(define-instruction ALIGN)
(define-instruction LONG)
(define-instruction ASCIZ)
(define-instruction DEFLABEL)
(define-instruction COMMENT)
(define-instruction INDIRECT)

(define-instruction ENTER)
(define-instruction LEAVE)

;;; CODE GENERATION INFRASTRUCTURE

(define label-counter 0)

(define-function temp-label-name ()	(concat-symbol '.L (set label-counter (+ label-counter 1))))

(define-structure <compiler> (level arg-limit tmp-limit epilogue pc asm temps tmps args argv))

(define-function compiler (level)
  (let ((self (new <compiler>)))
    (set (<compiler>-level     self) level)
    (set (<compiler>-arg-limit self) 0)
    (set (<compiler>-tmp-limit self) 0)
    (set (<compiler>-epilogue  self) ())
    (set (<compiler>-pc        self) 0)
    (set (<compiler>-asm       self) (array))
    (set (<compiler>-temps     self) ())
    (set (<compiler>-tmps      self) 0)
    (set (<compiler>-args      self) ())
    (set (<compiler>-argv      self) 0)
    self))

(define-function gen (insn comp . args)
  (let ((pc (<compiler>-pc comp)))
    (set (<compiler>-pc comp) (+ pc 1))
    (array-at-set (<compiler>-asm comp) pc (cons insn args))))

(define-function new-tmp (comp)
  (let ((tmp (car (<compiler>-tmps comp))))
    (set (<compiler>-tmps comp) (cdr (<compiler>-tmps comp)))
    (and (not tmp)
	 (let ((off (<compiler>-tmp-limit comp)))
	   (set (<compiler>-tmp-limit comp) (+ off 4))
	   (set tmp (TI32 off))
	   (push (<compiler>-temps comp) tmp)))
    tmp))

(define-function new-arg (comp)
  (let ((tmp (car (<compiler>-argv comp))))
    (set (<compiler>-argv comp) (cdr (<compiler>-argv comp)))
    (and (not tmp)
	 (let ((off (<compiler>-arg-limit comp)))
	   (set (<compiler>-arg-limit comp) (+ off 4))
	   (set tmp (TI32 off))
	   (push (<compiler>-args comp) tmp)))
    tmp))

(define-function new-param (comp)
  (let ((off (<compiler>-arg-limit comp)))
    (set (<compiler>-arg-limit comp) (+ off 4))
    (TI32 off)))

(define-function free-tmp (comp tmp) (push (<compiler>-tmps comp) tmp))
(define-function free-arg (comp tmp) (push (<compiler>-argv comp) tmp))

(define-function free-temps (comp tmps) (list-do tmp tmps (free-tmp comp tmp)))
(define-function free-args  (comp tmps) (list-do tmp tmps (free-arg comp tmp)))

;;; HIGH-LEVEL CODE GENERATION

(define-selector gen)

(define *label-source* ())

(define-method gen <undefined>	(comp)	(gen comp LOAD (LI32 0)))
(define-method gen <long>	(comp)	(gen comp LOAD (LI32 self)))
(define-method gen <string>	(comp)	(gen-definition self (temp-label-name) comp) (gen comp LOAD (GI32 (LABEL name))))
(define-method gen <symbol>	(comp)	(gen comp LOAD (LI32 (data self))))
(define-method gen <extern>	(comp)	(gen comp LOAD (GI32 (LABEL (concat-symbol self.name '$stub)))))

(define-method gen <variable>	(comp)
  (let ((val (<variable>-value self)))
    (cond
      ((temp?   val)	(gen comp LOAD val))
      ((extern? val)	(gen comp gen  val))
      (else		(gen comp LOAD (GI32 (LABEL (<variable>-name self))))))))

(define-function gen-tmp (arg comp)
  (gen arg comp)
  (let ((tmp (new-tmp comp)))
    (gen comp STORE tmp)
    tmp))

(define-function gen-arg (arg comp)
  (gen arg comp)
  (let ((tmp (new-arg comp)))
    (gen comp STORE tmp)
    tmp))

(define-function gen-move (tmp arg comp)	(gen comp MOVE tmp arg))

(define-function gen-let (expr comp)
  (let* ((scope (<compiler>-level comp))
	 (bindings ())
	 (tmp 0))
    (list-do binding (cadr expr)
      (and binding
	   (let* ((name (car binding))
		  (init (cdr binding))
		  (val  (and (not (temp? init)) (new-tmp comp))))
	     (push bindings (cons name val))
	     (and init (gen (cadr binding) comp))
	     (and val  (gen comp STORE val)))))
    (list-do binding bindings
      (environment-define *globals* (car binding) (variable (car binding) (cdr binding) () ())))
    (list-do stmt (cddr expr) (gen stmt comp))
    (while (!= scope (<compiler>-level comp))
      (set *globals* (<env>-parent *globals*)))))

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

(define operators (array () () () ()))

(define-function define-nullary (name op) (array-append (array-at operators 0) (cons name op)))
(define-function define-unary   (name op) (array-append (array-at operators 1) (cons name op)))
(define-function define-binary  (name op) (array-append (array-at operators 2) (cons name op)))
(define-function define-ternary (name op) (array-append (array-at operators 3) (cons name op)))

(define-function generate-nullary (op args comp) (gen comp op))

(define-function generate-unary (op arg comp)
  (gen (car arg) comp)
  (gen comp op))

(define-function generate-binary (op args comp)
  (gen (car args) comp)
  (let ((tmp (new-tmp comp)))
    (gen comp STORE tmp)
    (gen (cadr args) comp)
    (gen comp op tmp)
    (free-tmp comp tmp)))

(define-function generate-ternary (op args comp)
  (gen (caddr args) comp)
  (let ((tmp2 (new-tmp comp)))
    (gen comp STORE tmp2)
    (gen (cadr args) comp)
    (let ((tmp1 (new-tmp comp)))
      (gen comp STORE tmp1)
      (gen (car args) comp)
      (gen comp op tmp1 tmp2)
      (free-tmp comp tmp2)
      (free-tmp comp tmp1))))

(define generators (list->array (list generate-nullary generate-unary generate-binary generate-ternary)))

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

;;; GEN-DEFINITION

(define-selector gen-definition)

(define-method gen-definition <long> (name comp)
  (gen comp DATA)
  (gen comp DEFLABEL (LABEL name))
  (gen comp LONG self)
  (gen comp TEXT))

(define-method gen-definition <string> (name comp)
  (let ((temp (LABEL (temp-label-name))))
    (gen comp DATA)
    (gen comp DEFLABEL temp)
    (gen comp ASCIZ self)
    (gen comp ALIGN 4)
    (gen comp DEFLABEL (LABEL name))
    (gen comp LONG temp)
    (gen comp TEXT)))

(define-method gen-definition <extern> (name comp)
  (let ((nlabel (LABEL                self.name        ))
	(slabel (LABEL (concat-symbol self.name '$stub))))
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
      (gen comp TEXT))))

(define-method gen-definition <form> (name comp)
  (gen comp COMMENT (list "form "name)))

(define-function gen-param (var comp)
  ;;(print "gen-param ") (dumpln var)
  (set (<variable>-value var) (new-param comp)))

(define-method gen-definition <expr> (name ocomp)
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
      (for (i 0 (<compiler>-pc comp)) (apply emit (array-at (<compiler>-asm comp) i)))
      (and (<compiler>-epilogue comp)
	   (emit DEFLABEL (<compiler>-epilogue comp)))
      (emit LEAVE (- frm-size 8)))
    (or main
      (let ()
	(gen ocomp DATA)
	(gen ocomp GLOBAL vnam)
	(gen ocomp DEFLABEL vnam)
	(gen ocomp LONG tnam)
	(gen ocomp TEXT)))))

;;; 

(define-function gen-env (env)
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
    (for (i 0 (<compiler>-pc comp))
                        (apply emit (array-at (<compiler>-asm comp) i)))
    ))

(define-form compile-begin ()	`(set *globals* (environment *globals*)))

(define-form compile-end ()	(let ((env *globals*))
				  (set *globals* (<env>-parent env))
				  (gen-env env)))