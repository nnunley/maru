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
    (array->string mangled)))

;;; IA32 -- OPERANDS

(define *label-source* ())
(define *label-counter* 0)

(define-function temp-label-name ()
  (let ((label (concat-string "_L_" (long->string (set *label-counter* (+ *label-counter* 1))))))
    (and *label-source* (set label (concat-strings label"_"(car *label-source*)"_"(long->string (cdr *label-source*)))))
    label))

(define-operand LABEL (name) 	__PREFIX__(mangle-label (<LABEL>-name self)))
(define-operand GI32 (name)	(<GI32>-name self))
(define-operand LI32 (value)	(<LI32>-value self))
(define-operand TI32 (offset)	(<TI32>-offset self))

(define-function temp? (obj)	(= <TI32> (type-of obj)))

;;; INSTRUCTIONS

;;; Define all instructions used by the code generator
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

(define-instruction NEG)
(define-instruction ADD)
(define-instruction SUB)
(define-instruction MUL)
(define-instruction DIV)
(define-instruction AND)
(define-instruction OR)
(define-instruction XOR)
(define-instruction NOT)
(define-instruction LT)
(define-instruction LE)
(define-instruction EQ)
(define-instruction NE)
(define-instruction GE)
(define-instruction GT)
(define-instruction SLA)
(define-instruction SRA)

(define-instruction BR)
(define-instruction BF)
(define-instruction BT)
(define-instruction CALL)

(define-instruction LOAD)
(define-instruction STORE)
(define-instruction ADDR)
(define-instruction MOVE)

(define-instruction CHR-AT)
(define-instruction SET-CHR-AT)
(define-instruction OOP-AT)
(define-instruction SET-OOP-AT)

;;; 

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


;;; 

;; Original gen-env - works for both C and assembly backends
(define-function gen-env (env)
  (let* ((vars  (<env>-bindings env))
         (comp  (compiler 0))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        ;; (println "## defn " name)  ; commented out for cleaner output
        (warn name "\n")
        ;;x;(println (<expr>-defn (cdar env)))
        (gen-definition value name comp)))
    (for (i 0 (<compiler>-pc comp))
                        (apply emit (array-at (<compiler>-asm comp) i)))))

(define-form compile-begin ()	`(set *globals* (environment *globals*)))

(define-form compile-end ()	(let ((env *globals*))
				  (set *globals* (<env>-parent env))
				  (gen-env env)))

;;; C BACKEND SUPPORT
;;; Using object-based approach with function name encapsulation

;; Backend selection variable  
(define *emit-backend* 'asm)  ; 'asm, 'c, 'arm64, or 'ir
;; Backend mode indicators for compile-time detection
(define *c-backend-active* ())
(define *arm64-backend-active* ())
(define *ir-backend-active* ())

;; C generator context using define-structure (higher-level approach)
(define-structure <c-generator> (
  indent-level        ;; Current indentation level
  in-data-section     ;; Are we in a data section?
  functions           ;; List of generated functions
  globals             ;; List of global variables
  temp-counter        ;; Counter for unique temp names
  current-function    ;; Current function being generated
  forward-decls       ;; List of forward declarations to emit
  implementations     ;; List of function implementations  
))

(define-function c-generator ()
  (let ((self (new <c-generator>)))
    (set (<c-generator>-indent-level     self) 1)
    (set (<c-generator>-in-data-section  self) ())
    (set (<c-generator>-functions        self) (list))
    (set (<c-generator>-globals          self) (list))
    (set (<c-generator>-temp-counter     self) 0)
    (set (<c-generator>-current-function self) ())
    (set (<c-generator>-forward-decls    self) (list))
    (set (<c-generator>-implementations  self) (list))
    self))

;; Global C generator instance
(define *c-gen* (c-generator))

;; Two-pass C generation system
;; Pass 1: Collect function signatures for forward declarations
(define-function c-collect-function-signatures (env)
  (let* ((vars  (<env>-bindings env))
         (index (array-length vars))
         (signatures (list)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (if (= <expr> (type-of value))
            (let* ((defn (<expr>-defn value))
                   (params (cadr defn)))
              (set signatures (cons (cons name params) signatures))))))
    signatures))

;; Generate forward declarations from signatures
(define-function c-gen-forward-declarations (signatures)
  (println "// Forward declarations")
  (list-do sig signatures
    (let ((name (car sig))
          (params (cdr sig)))
      (print "static oop " (mangle-label name) "(")
      (if (= 0 (list-length params))
          (print "void")
        (let ((first 1))
          (list-do param params
            (if first
                (set first ())
              (print ", "))
            (print "oop " (mangle-label (<variable>-name param))))))
      (println ");")))
  (println))

;; Helper functions that use the object context
(define-function c-indent ()
  (for (i 0 (<c-generator>-indent-level *c-gen*))
    (print "  ")))

(define-function c-param-name (param)
  (if (variable? param)
      (mangle-label (<variable>-name param))
    (concat-string "_param_" (long->string (>> (<TI32>-offset param) 2)))))

(define-function c-temp-name (temp)
  (concat-string "_temp_" (long->string (>> (<TI32>-offset temp) 2))))

;; High-level C expression generator  
(define-function c-gen-expr (expr)
  (cond
    ;; Literals
    ((long? expr)
     (print "LONG(" expr ")"))
    
    ;; Variables
    ((variable? expr)
     (print (mangle-label (<variable>-name expr))))
    
    ;; String literals  
    ((string? expr)
     (print "\"" expr "\""))
    
    ;; Function calls and operations
    ((pair? expr)
     (let ((op (car expr))
           (args (cdr expr)))
       (cond
         ;; Handle if statements - check for 'if symbol directly
         ((and (symbol? op) (= 'if op))
          (print "(")
          (c-gen-expr (car args))  ;; condition
          (print " ? ")
          (c-gen-expr (cadr args)) ;; then
          (print " : ")
          (if (pair? (cddr args))
              (c-gen-expr (caddr args)) ;; else
            (print "nil"))
          (print ")"))
         
         ;; Handle Fixed forms (type 11)
         ((= 11 (type-of op))
          (print "(")
          (c-gen-expr (car args))  ;; condition
          (print " ? ")
          (c-gen-expr (cadr args)) ;; then
          (print " : ")
          (if (pair? (cddr args))
              (c-gen-expr (caddr args)) ;; else
            (print "nil"))
          (print ")"))
         
         ;; Variable-based operations
         ((variable? op)
          (let ((op-name (<variable>-name op)))
            (cond
              ;; Special forms via variables
              ((= 'if op-name)
               (print "(")
               (c-gen-expr (car args))  ;; condition
               (print " ? ")
               (c-gen-expr (cadr args)) ;; then
               (print " : ")
               (if (pair? (cddr args))
                   (c-gen-expr (caddr args)) ;; else
                 (print "nil"))
               (print ")"))
               
              ;; Type predicates
              ((= 'long? op-name)
               (print "((long)(")
               (c-gen-expr (car args))
               (print ") & 1)"))
              
              ;; Arithmetic operations
              ((= '+ op-name)
               (print "LONG(getLong(")
               (c-gen-expr (car args))
               (print ") + getLong(")
               (c-gen-expr (cadr args))
               (print "))"))
              
              ((= '- op-name)
               (print "LONG(getLong(")
               (c-gen-expr (car args))
               (print ") - getLong(")
               (c-gen-expr (cadr args))
               (print "))"))
              
              ((= '* op-name)
               (print "LONG(getLong(")
               (c-gen-expr (car args))
               (print ") * getLong(")
               (c-gen-expr (cadr args))
               (print "))"))
              
              ;; Comparison operations
              ((= '> op-name)
               (print "(getLong(")
               (c-gen-expr (car args))
               (print ") > getLong(")
               (c-gen-expr (cadr args))
               (print "))"))
              
              (else
               ;; Function call
               (print (mangle-label op-name) "(")
               (let ((first 1))
                 (list-do arg args
                   (if first
                       (set first ())
                     (print ", "))
                   (c-gen-expr arg)))
               (print ")")))))
         
         (else
          ;; Debug: show what we don't recognize
          (print "/* unknown expression type: ")
          (print (type-of op))
          (print " value: ")
          (dumpln op)
          (print " */")))))
    
    (else
     (print "nil"))))

;; High-level C code generation that translates Lisp operations directly
(define-method gen-definition <expr> (name ocomp)
  (cond
    ;; C backend: generate high-level C code directly from Lisp expressions
    ((and (defined? '*c-backend-active*) *c-backend-active*)
      ;; C backend: generate high-level C code directly from Lisp expressions
      (let* ((main (= 'main name))
             (defn (<expr>-defn self))
             (params (cadr defn))
             (body (cddr defn)))
        (set (<c-generator>-current-function *c-gen*) name)
        
        ;; Generate C function signature (suppress the defn comment)
        (print "static oop " (mangle-label name) "(")
        (let ((first 1))
          (list-do param params
            (if first
                (set first ())
              (print ", "))
            (print "oop " (mangle-label (<variable>-name param)))))
        (if (= 0 (list-length params))
            (print "void"))
        (println ")")
        (println "{")
        (set (<c-generator>-indent-level *c-gen*) 
             (+ (<c-generator>-indent-level *c-gen*) 1))
        
        ;; Generate function body directly from Lisp expressions
        (c-indent) 
        (print "return ")
        (c-gen-expr (car body))  ;; Generate C expression directly
        (println ";")
        
        (set (<c-generator>-indent-level *c-gen*) 
             (- (<c-generator>-indent-level *c-gen*) 1))
        (println "}")
        (println)
        
        ;; Track generated functions
        (set (<c-generator>-functions *c-gen*) 
             (cons name (<c-generator>-functions *c-gen*)))
        
        (or main
            (let ()
              (println "static oop v_" (mangle-label name) " = (oop)" (mangle-label name) ";")
              (set (<c-generator>-globals *c-gen*)
                   (cons name (<c-generator>-globals *c-gen*))))))
    
    ;; ARM64 backend: generate ARM64 assembly code
    ((and (defined? '*arm64-backend-active*) *arm64-backend-active*)
      (let* ((main (= 'main name))
             (defn (<expr>-defn self))
             (body (cddr defn))
             (comp (compiler (+ 1 (<compiler>-level ocomp))))
             (tnam (if main (LABEL name) (LABEL (temp-label-name))))
             (vnam (if main () (LABEL name)))
             (params (map-with gen-param (cadr defn) comp)))
        (list-do e body (gen e comp))
        (let* ((arg-size (align 16 (<compiler>-arg-limit comp)))
               (tmp-size (align 16 (+ arg-size (<compiler>-tmp-limit comp))))
               (frm-size (align 16 (+ tmp-size 16))))  ; ARM64 needs 16-byte alignment
          (map (lambda (tmp) (set (<TI32>-offset tmp) (+ arg-size (<TI32>-offset tmp)))) (<compiler>-temps comp))
          (map (lambda (tmp) (set (<TI32>-offset tmp) (+ frm-size (<TI32>-offset tmp)))) params)
          (emit TEXT)
          (and main (emit GLOBAL tnam))
          (emit DEFLABEL tnam)
          (emit COMMENT (list "ARM64 frame " arg-size " " (<compiler>-tmp-limit comp) " " tmp-size " " frm-size))
          (emit ENTER (- frm-size 16))  ; ARM64 frame setup
          (for (i 0 (<compiler>-pc comp)) (apply emit (array-at (<compiler>-asm comp) i)))
          (and (<compiler>-epilogue comp)
               (emit DEFLABEL (<compiler>-epilogue comp)))
          (emit LEAVE (- frm-size 16)))  ; ARM64 frame teardown
        (or main
          (let ()
            (gen ocomp DATA)
            (gen ocomp GLOBAL vnam)
            (gen ocomp DEFLABEL vnam)
            (gen ocomp LONG tnam)
            (gen ocomp TEXT)))))
      
    ;; Assembly backend (x86): use original implementation
    (1
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
              (gen ocomp TEXT))))))))

;; For the C backend, we don't need low-level emit instructions
;; since we generate high-level C directly from Lisp expressions

;; Switch backend to C
(define-function use-c-backend ()
  (set *emit-backend* 'c)
  (set *c-backend-active* 1)
  (set *arm64-backend-active* ()))


;;; ASSEMBLY BACKEND EMIT METHODS
;;; These are needed for the traditional eval2.c generation

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
			 		(println "	andl $255,%eax"))

(define-emit	(LT TI32)		(println "	cmpl "$1",%eax")
			 		(println "	setl %al")
			 		(println "	andl $255,%eax"))

(define-emit	(LE TI32)		(println "	cmpl "$1",%eax")
			 		(println "	setle %al")
			 		(println "	andl $255,%eax"))

(define-emit	(EQ TI32)		(println "	cmpl "$1",%eax")
			 		(println "	sete %al")
			 		(println "	andl $255,%eax"))

(define-emit	(NE TI32)		(println "	cmpl "$1",%eax")
			 		(println "	setne %al")
			 		(println "	andl $255,%eax"))

(define-emit	(GE TI32)		(println "	cmpl "$1",%eax")
			 		(println "	setge %al")
			 		(println "	andl $255,%eax"))

(define-emit	(GT TI32)		(println "	cmpl "$1",%eax")
			 		(println "	setg %al")
			 		(println "	andl $255,%eax"))

(define-emit	(SLA TI32)		(println "	sall "$1",%eax"))
(define-emit	(SRA TI32)		(println "	sarl "$1",%eax"))

(define-emit	(BR LABEL)		(println "	jmp "$1))
(define-emit	(BT LABEL)		(println "	cmpl $0,%eax")
			 		(println "	jne "$1))
(define-emit	(BF LABEL)		(println "	cmpl $0,%eax")
			 		(println "	je "$1))

(define-emit	(CALL long)		(println "	call %eax"))

(define-emit	(LOAD LI32)		(println "	movl $"$1",%eax"))
(define-emit	(LOAD GI32)		(println "	movl "$1",%eax"))
(define-emit	(LOAD TI32)		(println "	movl "$1"(%ebp),%eax"))
(define-emit	(LOAD LABEL)		(println "	movl "$1",%eax"))

(define-emit	(STORE GI32)		(println "	movl %eax,"$1))
(define-emit	(STORE TI32)		(println "	movl %eax,"$1"(%ebp)"))

(define-emit	(ADDR GI32)		(println "	movl $"$1",%eax"))
(define-emit	(ADDR TI32)		(println "	leal "$1"(%ebp),%eax"))

(define-emit	(MOVE TI32 TI32)	(println "	movl "$1"(%ebp),%eax")
			 		(println "	movl %eax,"$2"(%ebp)"))

(define-emit	(CHR-AT)		(println "	movl 4(%esp),%eax")
			 		(println "	movb (%eax),%al")
			 		(println "	andl $255,%eax"))

(define-emit	(SET-CHR-AT)		(println "	movl 8(%esp),%eax")
			 		(println "	movl 4(%esp),%ecx")
			 		(println "	movb %al,(%ecx)")
			 		(println "	movl %eax,8(%esp)"))

(define-emit	(OOP-AT TI32)		(println "	movl "$1",%ecx")
			 		(println "	movl (%eax,%ecx,4),%eax"))

(define-emit	(SET-OOP-AT TI32 TI32)	(println "	movl "$1",%ecx")
			 		(println "	movl "$2",%edx")
			 		(println "	movl %ecx,(%eax,%edx,4)"))

(define-emit	(OOP-AT)		(println "	movl 4(%esp),%eax")
			 		(println "	movl (%eax),%eax"))

(define-emit	(SET-OOP-AT)		(println "	movl 8(%esp),%eax")
			 		(println "	movl 4(%esp),%ecx")
			 		(println "	movl %eax,(%ecx)")
			 		(println "	movl %eax,8(%esp)"))

;;; ARM64 ASSEMBLY BACKEND EMIT METHODS
;;; These emit ARM64 assembly instructions when ARM64 backend is active

;; ARM64 assembly directives
(define-emit	(ARM64-TEXT)		(println "	.text"))
(define-emit	(ARM64-DATA)		(println "	.data"))
(define-emit	(ARM64-SECTION string)	(println "	.section "$1))
(define-emit	(ARM64-GLOBAL LABEL)	(println "	.globl "$1))
(define-emit	(ARM64-ALIGN long)	(println "	.align "$1))
(define-emit	(ARM64-LONG long)	(println "	.long "$1))
(define-emit	(ARM64-LONG LABEL)	(println "	.long "$1))
(define-emit	(ARM64-ASCIZ string)	(print   "	.asciz ") (dumpln $1))
(define-emit	(ARM64-DEFLABEL LABEL)	(println $1":"))

;; ARM64 function prologue and epilogue
(define-emit	(ARM64-ENTER long)	(println "	stp	x29, x30, [sp, #-16]!")
			 		(println "	mov	x29, sp")
			 		(and (!= 0 $1) (println "	sub	sp, sp, #"$1)))

(define-emit	(ARM64-LEAVE long)	(and (!= 0 $1) (println "	add	sp, sp, #"$1))
			 		(println "	ldp	x29, x30, [sp], #16")
			 		(println "	ret"))

;; ARM64 arithmetic operations  
(define-emit	(ARM64-ADD TI32)	(println "	add	x0, x0, #"$1))
(define-emit	(ARM64-SUB TI32)	(println "	sub	x0, x0, #"$1))
(define-emit	(ARM64-MUL TI32)	(println "	mov	x1, #"$1)
			 		(println "	mul	x0, x0, x1"))
(define-emit	(ARM64-NEG)		(println "	neg	x0, x0"))

;; ARM64 comparison operations
(define-emit	(ARM64-LT TI32)		(println "	cmp	x0, #"$1)
			 		(println "	cset	x0, lt"))
(define-emit	(ARM64-LE TI32)		(println "	cmp	x0, #"$1)
			 		(println "	cset	x0, le"))
(define-emit	(ARM64-EQ TI32)		(println "	cmp	x0, #"$1)
			 		(println "	cset	x0, eq"))
(define-emit	(ARM64-NE TI32)		(println "	cmp	x0, #"$1)
			 		(println "	cset	x0, ne"))
(define-emit	(ARM64-GE TI32)		(println "	cmp	x0, #"$1)
			 		(println "	cset	x0, ge"))
(define-emit	(ARM64-GT TI32)		(println "	cmp	x0, #"$1)
			 		(println "	cset	x0, gt"))

;; ARM64 branching
(define-emit	(ARM64-BR LABEL)	(println "	b	"$1))
(define-emit	(ARM64-BF LABEL)	(println "	cbz	x0, "$1))
(define-emit	(ARM64-BT LABEL)	(println "	cbnz	x0, "$1))
(define-emit	(ARM64-CALL LABEL)	(println "	bl	"$1))

;; ARM64 load/store operations
(define-emit	(ARM64-LOAD LI32)	(println "	mov	x0, #"$1))
(define-emit	(ARM64-LOAD LABEL)	(println "	adrp	x0, "$1"@PAGE")
			 		(println "	add	x0, x0, "$1"@PAGEOFF"))
(define-emit	(ARM64-LOAD TI32)	(println "	ldr	x0, [x29, #"$1"]"))
(define-emit	(ARM64-STORE TI32)	(println "	str	x0, [x29, #"$1"]"))

;; ARM64 memory operations
(define-emit	(ARM64-OOP-AT TI32)	(println "	ldr	x1, [x29, #"$1"]")
			 		(println "	ldr	x0, [x0, x1, lsl #3]"))
(define-emit	(ARM64-SET-OOP-AT TI32 TI32)	(println "	ldr	x1, [x29, #"$1"]")
			 			(println "	ldr	x2, [x29, #"$2"]")
			 			(println "	str	x1, [x0, x2, lsl #3]"))

;; ARM64 comments
(define-emit	(ARM64-COMMENT pair)	(print "// ") (apply println $1))

(define-emit	(COMMENT pair)		(print   "	# ")
			 		(map print $1)
			 		(println))

;;; ARM64 BACKEND SETUP FUNCTIONS
;;; These must come after all emit methods are defined

;; Dynamically redefine generic emit methods to call ARM64 versions
(define-function load-arm64-emit-mappings ()
  ;; Override generic emit methods to call ARM64 versions
  (define-emit (TEXT)           (emit ARM64-TEXT))
  (define-emit (DATA)           (emit ARM64-DATA))
  (define-emit (SECTION string) (emit ARM64-SECTION $1))
  (define-emit (GLOBAL LABEL)   (emit ARM64-GLOBAL $1))
  (define-emit (ALIGN long)     (emit ARM64-ALIGN $1))
  (define-emit (LONG long)      (emit ARM64-LONG $1))
  (define-emit (LONG LABEL)     (emit ARM64-LONG $1))
  (define-emit (ASCIZ string)   (emit ARM64-ASCIZ $1))
  (define-emit (DEFLABEL LABEL) (emit ARM64-DEFLABEL $1))
  (define-emit (ENTER long)     (emit ARM64-ENTER $1))
  (define-emit (LEAVE long)     (emit ARM64-LEAVE $1))
  (define-emit (ADD TI32)       (emit ARM64-ADD $1))
  (define-emit (SUB TI32)       (emit ARM64-SUB $1))
  (define-emit (MUL TI32)       (emit ARM64-MUL $1))
  (define-emit (NEG)            (emit ARM64-NEG))
  (define-emit (LT TI32)        (emit ARM64-LT $1))
  (define-emit (LE TI32)        (emit ARM64-LE $1))
  (define-emit (EQ TI32)        (emit ARM64-EQ $1))
  (define-emit (NE TI32)        (emit ARM64-NE $1))
  (define-emit (GE TI32)        (emit ARM64-GE $1))
  (define-emit (GT TI32)        (emit ARM64-GT $1))
  (define-emit (BR LABEL)       (emit ARM64-BR $1))
  (define-emit (BF LABEL)       (emit ARM64-BF $1))
  (define-emit (BT LABEL)       (emit ARM64-BT $1))
  (define-emit (CALL LABEL)     (emit ARM64-CALL $1))
  (define-emit (LOAD LI32)      (emit ARM64-LOAD $1))
  (define-emit (LOAD LABEL)     (emit ARM64-LOAD $1))
  (define-emit (LOAD TI32)      (emit ARM64-LOAD $1))
  (define-emit (STORE TI32)     (emit ARM64-STORE $1))
  (define-emit (OOP-AT TI32)    (emit ARM64-OOP-AT $1))
  (define-emit (SET-OOP-AT TI32 TI32) (emit ARM64-SET-OOP-AT $1 $2))
  (define-emit (COMMENT pair)   (emit ARM64-COMMENT $1)))

;; Switch backend to ARM64
(define-function use-arm64-backend ()
  (set *emit-backend* 'arm64)
  (set *arm64-backend-active* 1)
  (set *c-backend-active* ())
  (set *ir-backend-active* ())
  (load-arm64-emit-mappings))

;; Switch backend to IR
(define-function use-ir-backend ()
  (set *emit-backend* 'ir)
  (set *ir-backend-active* 1)
  (set *c-backend-active* ())
  (set *arm64-backend-active* ()))