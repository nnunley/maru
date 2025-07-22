;;; emit-c-proper.l -- Proper C code generation backend for Maru
;;;
;;; This generates C code that matches the style of eval.c with proper
;;; typedefs, structures, and runtime support.

;;; C code generation state
(define *c-indent* 0)
(define *c-in-data* ())
(define *c-functions* ())  ;; List of generated functions
(define *c-globals* ())     ;; List of global variables

(define-function c-indent ()
  (for (i 0 *c-indent*) (print "  ")))

(define-function c-newline ()
  (println)
  (c-indent))

;;; Helper to get temp name
(define-function c-temp-name (temp)
  (concat-string "_tmp_" (long->string (>> (<TI32>-offset temp) 2))))

;;; Helper to get param name
(define-function c-param-name (param)
  (concat-string "_param_" (long->string (>> (<TI32>-offset param) 2))))

;;; Override TI32 printing for C
(define-method do-print <TI32> () 
  (if (= *emit-backend* 'c)
      (print (c-temp-name self))
      (print (<TI32>-offset self) "(%esp)")))

;;; C DIRECTIVES AND STRUCTURE

(define-emit (TEXT)             
  (and (= *emit-backend* 'c) *c-in-data* (let ()
    (println "};")
    (println)
    (set *c-in-data* ()))))

(define-emit (DATA)             
  (and (= *emit-backend* 'c) (set *c-in-data* 1)))

(define-emit (SECTION string)   ) ; No-op in C

(define-emit (INDIRECT LABEL)   ) ; No-op in C

(define-emit (GLOBAL LABEL)     
  (if (= *emit-backend* 'c)
      ()  ; Global functions are already visible in C
      (println "	.globl " $1)))

(define-emit (ALIGN long)       
  (if (!= *emit-backend* 'c)
      (println "	.align " $1)))

(define-emit (LONG long)        
  (if (= *emit-backend* 'c)
      (let ()
        (print "  LONG(" $1 "),")
        (println))
      (println "	.long " $1)))

(define-emit (LONG LABEL)       
  (if (= *emit-backend* 'c)
      (let ()
        (print "  (oop)" $1 ",")
        (println))
      (println "	.long " $1)))

(define-emit (ASCIZ string)     
  (if (= *emit-backend* 'c)
      (let ()
        (print "  ")
        (dumpln $1)
        (print ",")
        (println))
      (let ()
        (print "	.asciz ")
        (dumpln $1))))

(define-emit (DEFLABEL LABEL)   
  (if (= *emit-backend* 'c)
      (if *c-in-data*
          (let ()
            (println)
            (println "static oop " $1 "[] = {"))
          (println $1 ":"))
      (println $1 ":")))

(define-emit (ENTER long)       
  (if (= *emit-backend* 'c)
      (let ()
        (println "{")
        (set *c-indent* (+ *c-indent* 1))
        ;; Variable declarations will be added by gen-definition
        )
      (let ()
        (println "	pushl %ebp")
        (println "	movl %esp,%ebp")
        (println "	subl $" $1 ",%esp"))))

(define-emit (LEAVE long)       
  (if (= *emit-backend* 'c)
      (let ()
        (c-indent) (println "return _eax;")
        (set *c-indent* (- *c-indent* 1))
        (println "}")
        (println))
      (let ()
        (println "	addl $" $1 ",%esp")
        (println "	leave")
        (println "	ret"))))

;;; ARITHMETIC OPERATIONS

(define-emit (NEG)              
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(-getLong(_eax));"))
      (println "	negl %eax")))

(define-emit (ADD TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) + getLong(" $1 "));"))
      (println "	addl " $1 ",%eax")))

(define-emit (SUB TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) - getLong(" $1 "));"))
      (println "	subl " $1 ",%eax")))

(define-emit (MUL TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) * getLong(" $1 "));"))
      (println "	mull " $1)))

(define-emit (DIV TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) / getLong(" $1 "));"))
      (let ()
        (println "	movl $0,%edx")
        (println "	divl " $1))))

(define-emit (AND TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) & getLong(" $1 "));"))
      (println "	andl " $1 ",%eax")))

(define-emit (OR TI32)          
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) | getLong(" $1 "));"))
      (println "	orl " $1 ",%eax")))

(define-emit (XOR TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) ^ getLong(" $1 "));"))
      (println "	xorl " $1 ",%eax")))

(define-emit (NOT)              
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (_eax == nil) ? s_t : nil;"))
      (let ()
        (println "	cmpl $0,%eax")
        (println "	sete %al")
        (println "	movzbl %al,%eax"))))

;;; COMPARISON OPERATIONS

(define-emit (LT TI32)          
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (getLong(_eax) < getLong(" $1 ")) ? s_t : nil;"))
      (let ()
        (println "	cmpl " $1 ",%eax")
        (println "	setl %al")
        (println "	movzbl %al,%eax"))))

(define-emit (LE TI32)          
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (getLong(_eax) <= getLong(" $1 ")) ? s_t : nil;"))
      (let ()
        (println "	cmpl " $1 ",%eax")
        (println "	setle %al")
        (println "	movzbl %al,%eax"))))

(define-emit (EQ TI32)          
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (_eax == " $1 ") ? s_t : nil;"))
      (let ()
        (println "	cmpl " $1 ",%eax")
        (println "	sete %al")
        (println "	movzbl %al,%eax"))))

(define-emit (NE TI32)          
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (_eax != " $1 ") ? s_t : nil;"))
      (let ()
        (println "	cmpl " $1 ",%eax")
        (println "	setne %al")
        (println "	movzbl %al,%eax"))))

(define-emit (GE TI32)          
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (getLong(_eax) >= getLong(" $1 ")) ? s_t : nil;"))
      (let ()
        (println "	cmpl " $1 ",%eax")
        (println "	setge %al")
        (println "	movzbl %al,%eax"))))

(define-emit (GT TI32)          
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (getLong(_eax) > getLong(" $1 ")) ? s_t : nil;"))
      (let ()
        (println "	cmpl " $1 ",%eax")
        (println "	setg %al")
        (println "	movzbl %al,%eax"))))

(define-emit (SLA TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) << getLong(" $1 "));"))
      (let ()
        (println "	movl " $1 ",%ecx")
        (println "	shll %cl,%eax"))))

(define-emit (SRA TI32)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(getLong(_eax) >> getLong(" $1 "));"))
      (let ()
        (println "	movl " $1 ",%ecx")
        (println "	sarl %cl,%eax"))))

;;; CONTROL FLOW

(define-emit (BR LABEL)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "goto " $1 ";"))
      (println "	jmp " $1)))

(define-emit (BF LABEL)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "if (_eax == nil) goto " $1 ";"))
      (let ()
        (println "	cmpl $0,%eax")
        (println "	je " $1))))

(define-emit (BT LABEL)         
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "if (_eax != nil) goto " $1 ";"))
      (let ()
        (println "	cmpl $0,%eax")
        (println "	jne " $1))))

(define-emit (CALL LABEL)       
  (if (= *emit-backend* 'c)
      (let () 
        (c-indent) 
        (print "_eax = " $1 "(")
        ;; Arguments would be passed here
        (println ");"))
      (println "	call " $1)))

(define-emit (CALL long)        
  (if (= *emit-backend* 'c)
      (let () 
        (c-indent) 
        (println "_eax = ((oop (*)())(((struct Expr *)_eax)->imp))();"))  
      (println "	call *%eax")))

;;; LOAD/STORE OPERATIONS

(define-emit (LOAD LI32)        
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(" $1 ");"))
      (println "	movl $" $1 ",%eax")))

(define-emit (LOAD LABEL)       
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (oop)" $1 ";"))
      (println "	movl $" $1 ",%eax")))

(define-emit (LOAD GI32)        
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = " $1 ";"))
      (println "	movl " $1 ",%eax")))

(define-emit (LOAD TI32)        
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = " $1 ";"))
      (println "	movl " $1 ",%eax")))

(define-emit (STORE TI32)       
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println $1 " = _eax;"))
      (println "	movl %eax," $1)))

(define-emit (STORE GI32)       
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println $1 " = _eax;"))
      (println "	movl %eax," $1)))

(define-emit (ADDR GI32)        
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (oop)&" $1 ";"))
      (println "	movl $" $1 ",%eax")))

(define-emit (ADDR TI32)        
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = (oop)&" $1 ";"))
      (println "	leal " $1 ",%eax")))

(define-emit (MOVE TI32 TI32)   
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println $2 " = " $1 ";"))
      (let ()
        (println "	movl " $1 ",%ecx")
        (println "	movl %ecx," $2))))

;;; MISC OPERATIONS

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

(define-emit (CHR-AT TI32)      
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = LONG(((char*)_eax)[getLong(" $1 ")]);"))
      (let ()
        (println "	movl " $1 ",%ecx")
        (println "	leal (%eax,%ecx),%ecx")
        (println "	xorl %eax,%eax")
        (println "	movb (%ecx),%al"))))

(define-emit (SET-CHR-AT TI32 TI32)  
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "((char*)_eax)[getLong(" $1 ")] = getLong(" $2 ");"))
      (let ()
        (println "	movl " $1 ",%ecx")
        (println "	leal (%eax,%ecx),%ecx")
        (println "	movl " $2 ",%eax")
        (println "	movb %al,(%ecx)"))))

(define-emit (OOP-AT TI32)      
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "_eax = ((oop*)_eax)[getLong(" $1 ")];"))
      (let ()
        (println "	movl " $1 ",%ecx")
        (println "	leal (%eax,%ecx,4),%ecx")
        (println "	movl (%ecx),%eax"))))

(define-emit (SET-OOP-AT TI32 TI32)  
  (if (= *emit-backend* 'c)
      (let () (c-indent) (println "((oop*)_eax)[getLong(" $1 ")] = " $2 ";"))
      (let ()
        (println "	movl " $1 ",%ecx")
        (println "	leal (%eax,%ecx,4),%ecx")
        (println "	movl " $2 ",%eax")
        (println "	movl %eax,(%ecx)"))))

;;; Override gen-definition for C output
(define-method gen-definition <expr> (name ocomp)
  (if (= *emit-backend* 'c)
      (let* ((main (= 'main name))
             (defn (<expr>-defn self))
             (body (cddr defn))
             (comp (compiler (+ 1 (<compiler>-level ocomp))))
             (params (map-with gen-param (cadr defn) comp)))
        ;; Generate function signature
        (print "static oop " name "(")
        (let ((first 1))
          (list-do param params
            (and (not first) (print ", "))
            (set first ())
            (print "oop " (c-param-name param))))
        (println ")")
        (println "{")
        (set *c-indent* 1)
        
        ;; Declare registers
        (c-indent) (println "oop _eax = nil;")
        
        ;; Declare arguments (up to max used)
        (let ((max-args (<compiler>-arg-limit comp)))
          (for (i 0 (>> max-args 2))
            (c-indent) (println "oop _arg_" i " = nil;")))
        
        ;; Declare temps (up to max used)
        (let ((max-temps (<compiler>-tmp-limit comp)))
          (for (i 0 (>> max-temps 2))
            (c-indent) (println "oop " (c-temp-name (TI32 (* i 4))) " = nil;")))
        
        ;; Generate body
        (list-do e body (gen e comp))
        
        ;; Generate code
        (for (i 0 (<compiler>-pc comp)) 
          (apply emit (array-at (<compiler>-asm comp) i)))
        
        ;; Epilogue
        (and (<compiler>-epilogue comp)
             (let ()
               (println (<compiler>-epilogue comp) ":")
               (c-indent)))
        
        ;; Return
        (println "return _eax;")
        (set *c-indent* 0)
        (println "}")
        (println)
        
        ;; Add to function list
        (set *c-functions* (cons name *c-functions*))
        
        ;; Generate global variable if not main
        (or main
            (let ()
              (println "static oop v_" name " = (oop)" name ";")
              (set *c-globals* (cons name *c-globals*)))))
      ;; Default x86 behavior
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
          (emit COMMENT (list "frame " arg-size " " (<compiler>-tmp-limit comp) " " tmp-size " " frm-size))
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
            (gen ocomp TEXT))))))

;;; Override gen-definition methods for C
(define-method gen-definition <long> (name comp)
  (if (= *emit-backend* 'c)
      (let ()
        (println "static oop v_" name " = LONG(" self ");")
        (println))
      (let ()
        (gen comp DATA)
        (gen comp DEFLABEL (LABEL name))
        (gen comp LONG self)
        (gen comp TEXT))))

(define-method gen-definition <string> (name comp)
  (if (= *emit-backend* 'c)
      (let ()
        (print "static wchar_t " name "_data[] = L")
        (dumpln self)
        (println ";")
        (println "static oop v_" name " = (oop)" name "_data;")
        (println))
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
      (let ()
        (println "extern oop " (<extern>-name self) "();")
        (println "static oop v_" (concat-symbol (<extern>-name self) '$stub) " = (oop)" (<extern>-name self) ";")
        (println))
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
          (gen comp TEXT)))))

(define-method gen-definition <form> (name comp)
  (if (= *emit-backend* 'c)
      (println "/* form " name " */")
      (gen comp COMMENT (list "form " name))))

;;; Override gen-env for C output
(define-function gen-env-c (env)
  ;; Generate C header
  (println "// Generated by Maru emit-c backend")
  (println)
  (println "#include <stddef.h>")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println "#include <string.h>")
  (println)
  
  ;; Generate typedefs to match eval.c style
  (println "// Type definitions")
  (println "typedef union Object *oop;")
  (println)
  (println "// Runtime support")
  (println "#define nil ((oop)0)")
  (println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (println "#define getLong(x) ((long)(x) >> 1)")
  (println)
  (println "// Global symbols")
  (println "static oop s_t = (oop)1;  // true value")
  (println)
  
  ;; Forward declarations
  (println "// Forward declarations")
  (let* ((vars  (<env>-bindings env))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (and (= <expr> (type-of value))
             (println "static oop " name "(oop);")))))
  (println)
  
  ;; Generate definitions
  (println "// Function definitions")
  (let* ((vars  (<env>-bindings env))
         (comp  (compiler 0))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (gen-definition value name comp))))
  
  ;; Generate main wrapper if needed
  (and (member? 'main *c-functions*)
       (let ()
         (println "// Main entry point")
         (println "int main(int argc, char *argv[])")
         (println "{")
         (println "  oop result = main();")
         (println "  if (result != nil) {")
         (println "    printf(\"%ld\\n\", getLong(result));")
         (println "  }")
         (println "  return 0;")
         (println "}")
         (println)))))