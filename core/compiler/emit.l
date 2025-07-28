(require "osdefs.k")

;; Backend selection variables (defined early for compile-end access)
(define *emit-backend* 'asm)  ; 'asm, 'c, 'arm64, or 'ir
(define *c-backend-active* ())
(define *arm64-backend-active* ())
(define *ir-backend-active* ())

;; Force C backend for testing (TODO: implement environment variable detection)
(set *emit-backend* 'c)
(set *c-backend-active* 1)

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

(require "lib/stream/port.l")

;; Global emit output port - defaults to console
(define *emit-output-port* (console-port))

;; Port-based emit helpers
(define-function emit-write args
  "Write multiple items to the emit output port"
  (list-do arg args
    (port-write *emit-output-port* arg)))

(define-function emit-writeln args
  "Write multiple items to the emit output port followed by newline"
  (apply emit-write args)
  (port-newline *emit-output-port*))

(define-function emit-string ()
  "Get the accumulated emit output as a string (for string ports)"
  (port-contents *emit-output-port*))

(define-function with-emit-port (port thunk)
  "Temporarily redirect emit output to a different port"
  (let ((old-port *emit-output-port*))
    (set *emit-output-port* port)
    (let ((result (thunk)))
      (set *emit-output-port* old-port)
      result)))

(define-generic emit op-args
  (emit-write "\nemit: illegal instruction: " op-args)
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

;; Define ->string methods for operands so they work with port system
(define-method ->string <LABEL> ()
  (concat-string __PREFIX__ (mangle-label (<LABEL>-name self))))

(define-method ->string <GI32> ()
  (<GI32>-name self))

(define-method ->string <LI32> ()
  (long->string (<LI32>-value self)))

(define-method ->string <TI32> ()
  (long->string (<TI32>-offset self)))

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

;; <fixed> objects should not be generated directly
;; They are handled through the forms mechanism in gen <pair>

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
  (cond
    ;; C backend: generate C global variable
    ((and (defined? '*c-backend-active*) *c-backend-active*)
     (emit-writeln "static oop v_" (mangle-label name) " = makeLong(" self ");"))
    ;; Assembly backends: use traditional approach
    (else
     (gen comp DATA)
     (gen comp DEFLABEL (LABEL name))
     (gen comp LONG self)
     (gen comp TEXT))))

(define-method gen-definition <string> (name comp)
  (cond
    ;; C backend: generate C string literal
    ((and (defined? '*c-backend-active*) *c-backend-active*)
     (emit-write "static oop v_" (mangle-label name) " = (oop)\"")
     ;; Escape string contents for C
     (for-each self (lambda (c)
       (cond
         ((= c ?\") (emit-write "\\\""))
         ((= c ?\\) (emit-write "\\\\"))
         ((= c ?\n) (emit-write "\\n"))
         ((= c ?\r) (emit-write "\\r"))
         ((= c ?\t) (emit-write "\\t"))
         ((< c 32) 
          (emit-write "\\")
          (emit-write (digit-for (>> c 6)))
          (emit-write (digit-for (& (>> c 3) 7)))
          (emit-write (digit-for (& c 7))))
         (else 
          ;; For regular characters, we need to convert them to strings
          ;; Since we don't have a char->string function, use array
          (let ((char-str (array->string (array c))))
            (emit-write char-str))))))
     (emit-writeln "\";"))
    ;; Assembly backends: use traditional approach
    (else
     (let ((temp (LABEL (temp-label-name))))
       (gen comp DATA)
       (gen comp DEFLABEL temp)
       (gen comp ASCIZ self)
       (gen comp ALIGN 4)
       (gen comp DEFLABEL (LABEL name))
       (gen comp LONG temp)
       (gen comp TEXT)))))

(define-method gen-definition <extern> (name comp)
  (cond
    ;; C backend: generate extern declaration
    ((and (defined? '*c-backend-active*) *c-backend-active*)
     (emit-writeln "extern oop " (mangle-label self.name) ";")
     (emit-writeln "static oop v_" (mangle-label name) " = (oop)&" (mangle-label self.name) ";"))
    ;; Assembly backends: use traditional approach
    (else
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
         (gen comp TEXT))))))

(define-method gen-definition <form> (name comp)
  (cond
    ;; C backend: generate comment
    ((and (defined? '*c-backend-active*) *c-backend-active*)
     (emit-writeln "/* form " name " */"))
    ;; Assembly backends: use traditional approach
    (else
     (gen comp COMMENT (list "form "name)))))

(define-function gen-param (var comp)
  ;;(print "gen-param ") (dumpln var)
  (set (<variable>-value var) (new-param comp)))


;;; 

;; Backend-aware gen-env function
(define-function gen-env (env)
  (cond
    ;; C backend: only generate definitions, no assembly emit path
    ((and (defined? '*c-backend-active*) *c-backend-active*)
     ;; Generate C header and includes
     (emit-writeln "// Generated C code from Maru")
     (emit-writeln "#include <stdint.h>")
     (emit-writeln "#include <stdlib.h>")
     (emit-writeln "#include <stdio.h>")
     (emit-writeln)
     (emit-writeln "// Basic runtime types")
     (emit-writeln "typedef intptr_t oop;")
     (emit-writeln "#define nil ((oop)0)")
     (emit-writeln "#define makeLong(x) ((oop)(((long)(x) << 1) | 1))")
     (emit-writeln "#define getLong(x) ((long)(x) >> 1)")
     (emit-writeln "#define LONG(x) makeLong(x)")
     (emit-writeln)
     (emit-writeln "// Runtime function prototypes")
     (emit-writeln "oop cons(oop car, oop cdr);")
     (emit-writeln)
     
     ;; For now, skip forward declarations to simplify the implementation
     ;; TODO: Add two-pass compilation later
     
     ;; Generate definitions
     (let* ((vars  (<env>-bindings env))
            (comp  (compiler 0))
            (index (array-length vars)))
       (while (<= 0 (set index (- index 1)))
         (let ((name  (<variable>-name  (array-at vars index)))
               (value (<variable>-value (array-at vars index))))
           (gen-definition value name comp))))
     
     ;; Generate main function if there's a main in the code
     ;; This provides the C entry point that sets up the Maru runtime
     (let ((has-main ()))
       ;; Check if any function is named 'main'
       (let* ((vars  (<env>-bindings env))
              (index (array-length vars)))
         (while (<= 0 (set index (- index 1)))
           (let ((name  (<variable>-name  (array-at vars index)))
                 (value (<variable>-value (array-at vars index))))
             (if (and (= 'main name) (= <expr> (type-of value)))
                 (set has-main 1)))))
       
       (if has-main
           (let ()
             (emit-writeln)
             (emit-writeln "// Runtime support functions")
             (emit-writeln "oop newString(const char *str) {")
             (emit-writeln "    // TODO: Implement proper string object creation")
             (emit-writeln "    return (oop)str;  // Simplified for now")
             (emit-writeln "}")
             (emit-writeln)
             (emit-writeln "oop cons(oop car, oop cdr) {")
             (emit-writeln "    // TODO: Implement proper cons cell creation")
             (emit-writeln "    return nil;  // Simplified for now")
             (emit-writeln "}")
             (emit-writeln)
             (emit-writeln "// Global variables")
             (emit-writeln "oop v__58arguments_58 = nil;  // *arguments*")
             (emit-writeln)
             (emit-writeln "// C entry point")
             (emit-writeln "int main(int argc, char **argv)")
             (emit-writeln "{")
             (emit-writeln "    // Initialize runtime if needed")
             (emit-writeln "    // TODO: Initialize GC, symbols, etc.")
             (emit-writeln "    ")
             (emit-writeln "    // Build *arguments* list from command line")
             (emit-writeln "    oop args = nil;")
             (emit-writeln "    for (int i = argc - 1; i >= 1; i--) {")
             (emit-writeln "        oop str = newString(argv[i]);")
             (emit-writeln "        args = cons(str, args);")
             (emit-writeln "    }")
             (emit-writeln "    v__58arguments_58 = args;")
             (emit-writeln "    ")
             (emit-writeln "    // Call the Maru main function")  
             (emit-writeln "    oop result = _main();")
             (emit-writeln "    ")
             (emit-writeln "    // Extract exit code from result")
             (emit-writeln "    if ((intptr_t)result & 1) {  // Tagged integer?")
             (emit-writeln "        return (int)getLong(result);")
             (emit-writeln "    }")
             (emit-writeln "    return 0;  // Default exit code")
             (emit-writeln "}"))))) 
    
    ;; Assembly backends: use traditional emit path
    (else
     (let* ((vars  (<env>-bindings env))
            (comp  (compiler 0))
            (index (array-length vars)))
       
       (while (<= 0 (set index (- index 1)))
         (let ((name  (<variable>-name  (array-at vars index)))
               (value (<variable>-value (array-at vars index))))
           ;; (println "## defn " name)  ; commented out for cleaner output
           ;; (warn name "\n")  ; commented out - was outputting function names
           ;;x;(println (<expr>-defn (cdar env)))
           (gen-definition value name comp)))
       (for (i 0 (<compiler>-pc comp))
                           (apply emit (array-at (<compiler>-asm comp) i)))))))

(define-form compile-begin ()	`(set *globals* (environment *globals*)))

(define-form compile-end ()	
  (let ((env *globals*))
    ;; Backend is already selected at top of file - don't override
    ;; (C backend is forced for eval2.c generation)
    (set *globals* (<env>-parent env))
    
    ;; Backend-specific emit methods are loaded here
    ;; For C backend, we use the integrated methods in this file
    ;; For assembly backends, we load the appropriate backend
    (cond
      ((and (defined? '*c-backend-active*) *c-backend-active*)
       ;; C backend methods are already integrated in this file
       ())
      ((and (defined? '*arm64-backend-active*) *arm64-backend-active*)
       (load "core/compiler/emit-arm64.l"))
      ((or (defined? '__x86_64__) (defined? '__i386__))
       (load "core/compiler/emit-x86.l"))
      (else
       ;; Default to x86 for now
       (load "core/compiler/emit-x86.l")))
    
    (gen-env env)))

;;; C BACKEND SUPPORT
;;; Using object-based approach with function name encapsulation

;; Backend variables already defined at top of file

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
  (emit-writeln "// Forward declarations")
  (list-do sig signatures
    (let ((name (car sig))
          (params (cdr sig)))
      (emit-write "static oop " (mangle-label name) "(")
      (if (= 0 (list-length params))
          (emit-write "void")
        (let ((first 1))
          (list-do param params
            (if first
                (set first ())
              (emit-write ", "))
            (emit-write "oop " (mangle-label (<variable>-name param))))))
      (emit-writeln ");")))
  (emit-writeln))

;; Helper functions that use the object context
(define-function c-indent ()
  (for (i 0 (<c-generator>-indent-level *c-gen*))
    (emit-write "  ")))

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
     (emit-write "LONG(" expr ")"))
    
    ;; Variables
    ((variable? expr)
     (emit-write (mangle-label (<variable>-name expr))))
    
    ;; String literals  
    ((string? expr)
     (emit-write "\"" expr "\""))
    
    ;; Function calls and operations
    ((pair? expr)
     (let ((op (car expr))
           (args (cdr expr)))
       (cond
         ;; Handle if statements - check for 'if symbol directly
         ((and (symbol? op) (= 'if op))
          (emit-write "(")
          (c-gen-expr (car args))  ;; condition
          (emit-write " ? ")
          (c-gen-expr (cadr args)) ;; then
          (emit-write " : ")
          (if (pair? (cddr args))
              (c-gen-expr (caddr args)) ;; else
            (emit-write "nil"))
          (emit-write ")"))
         
         ;; Handle Fixed forms (type 11)
         ((= 11 (type-of op))
          (emit-write "(")
          (c-gen-expr (car args))  ;; condition
          (emit-write " ? ")
          (c-gen-expr (cadr args)) ;; then
          (emit-write " : ")
          (if (pair? (cddr args))
              (c-gen-expr (caddr args)) ;; else
            (emit-write "nil"))
          (emit-write ")"))
         
         ;; Variable-based operations
         ((variable? op)
          (let ((op-name (<variable>-name op)))
            (cond
              ;; Special forms via variables
              ((= 'if op-name)
               (emit-write "(")
               (c-gen-expr (car args))  ;; condition
               (emit-write " ? ")
               (c-gen-expr (cadr args)) ;; then
               (emit-write " : ")
               (if (pair? (cddr args))
                   (c-gen-expr (caddr args)) ;; else
                 (emit-write "nil"))
               (emit-write ")"))
               
              ;; Type predicates
              ((= 'long? op-name)
               (emit-write "((long)(")
               (c-gen-expr (car args))
               (emit-write ") & 1)"))
              
              ;; Arithmetic operations
              ((= '+ op-name)
               (emit-write "LONG(getLong(")
               (c-gen-expr (car args))
               (emit-write ") + getLong(")
               (c-gen-expr (cadr args))
               (emit-write "))"))
              
              ((= '- op-name)
               (emit-write "LONG(getLong(")
               (c-gen-expr (car args))
               (emit-write ") - getLong(")
               (c-gen-expr (cadr args))
               (emit-write "))"))
              
              ((= '* op-name)
               (emit-write "LONG(getLong(")
               (c-gen-expr (car args))
               (emit-write ") * getLong(")
               (c-gen-expr (cadr args))
               (emit-write "))"))
              
              ;; Comparison operations
              ((= '> op-name)
               (emit-write "(getLong(")
               (c-gen-expr (car args))
               (emit-write ") > getLong(")
               (c-gen-expr (cadr args))
               (emit-write "))"))
              
              (else
               ;; Function call
               (emit-write (mangle-label op-name) "(")
               (let ((first 1))
                 (list-do arg args
                   (if first
                       (set first ())
                     (emit-write ", "))
                   (c-gen-expr arg)))
               (emit-write ")")))))
         
         (else
          ;; Debug: show what we don't recognize
          (emit-write "/* unknown expression type: ")
          (emit-write (type-of op))
          (emit-write " value: ")
          (with-emit-port (console-port) (lambda () (dumpln op)))
          (emit-write " */"))))
    
    (else
     (emit-write "nil")))))  ;; Close cond and c-gen-expr function

;; High-level C code generation that translates Lisp operations directly
(define-method gen-definition <expr> (name ocomp)
  (cond
    ;; C backend: generate high-level C code directly from Lisp expressions
    ((and (defined? '*c-backend-active*) *c-backend-active*)
      ;; Don't emit Lisp comments into C output
      ;; (emit-writeln "; C backend code generation for: " name)
      ;; C backend: generate high-level C code directly from Lisp expressions
      (let* ((main (= 'main name))
             (defn (<expr>-defn self))
             (params (cadr defn))
             (body (cddr defn)))
        (set (<c-generator>-current-function *c-gen*) name)
        
        ;; Generate C function signature (suppress the defn comment)
        (emit-write "static oop " (mangle-label name) "(")
        (let ((first 1))
          (list-do param params
            (if first
                (set first ())
              (emit-write ", "))
            (emit-write "oop " (mangle-label (<variable>-name param)))))
        (if (= 0 (list-length params))
            (emit-write "void"))
        (emit-writeln ")")
        (emit-writeln "{")
        (set (<c-generator>-indent-level *c-gen*) 
             (+ (<c-generator>-indent-level *c-gen*) 1))
        
        ;; Generate function body directly from Lisp expressions
        (c-indent) 
        (emit-write "return ")
        (c-gen-expr (car body))  ;; Generate C expression directly
        (emit-writeln ";")
        
        (set (<c-generator>-indent-level *c-gen*) 
             (- (<c-generator>-indent-level *c-gen*) 1))
        (emit-writeln "}")
        (emit-writeln)
        
        ;; Track generated functions
        (set (<c-generator>-functions *c-gen*) 
             (cons name (<c-generator>-functions *c-gen*)))
        
        (or main
            (let ()
              (emit-writeln "static oop v_" (mangle-label name) " = (oop)" (mangle-label name) ";")
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
    ((and (not *c-backend-active*) (not *arm64-backend-active*))
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


;;; BACKEND-SPECIFIC EMIT METHODS
;;; Backend-specific emit methods are now loaded from external files:
;;; - emit-x86.l for x86/x86-64 assembly
;;; - emit-arm64.l for ARM64 assembly  
;;; - emit-gc-c.l for C code generation
;;;
;;; The backend is selected based on platform or environment variables.


;; Switch backend to ARM64
(define-function use-arm64-backend ()
  (set *emit-backend* 'arm64)
  (set *arm64-backend-active* 1)
  (set *c-backend-active* ())
  (set *ir-backend-active* ()))

;; Switch backend to IR
(define-function use-ir-backend ()
  (set *emit-backend* 'ir)
  (set *ir-backend-active* 1)
  (set *c-backend-active* ())
  (set *arm64-backend-active* ()))

;; Backend selection

(define-function select-backend (name)
  (let ((backend (if name (string->symbol name) ())))
    (cond
      ((= backend 'c)     (use-c-backend))
      ((= backend 'arm64) (use-arm64-backend))
      ((= backend 'ir)    (use-ir-backend))
      (else
        (cond
          ((defined? '__arm64__)     (use-arm64-backend))
          ((defined? '__x86_64__)    (set *emit-backend* 'asm))
          ((defined? '__i386__)      (set *emit-backend* 'asm))
          (else                      (use-c-backend)))))))

;; Backend will be selected at compile-end