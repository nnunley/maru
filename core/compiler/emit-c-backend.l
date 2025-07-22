;;; emit-c-backend.l -- C code generation backend
;;;
;;; This file contains C-specific emit methods

;;; C code generation state
(define *c-indent* 0)
(define *c-temps* ())
(define *c-arg-count* 0)

(define-function c-indent ()
  (for (i 0 *c-indent*) (print "  ")))

(define-function c-newline ()
  (println)
  (c-indent))

;;; Override TI32 printing for C
(define-method do-print <TI32> () 
  (print "_tmp_" (>> (<TI32>-offset self) 2)))

;;; C DIRECTIVES AND STRUCTURE

(define-emit (TEXT)             ) ; No-op in C
(define-emit (DATA)             ) ; No-op in C
(define-emit (SECTION string)   ) ; No-op in C
(define-emit (INDIRECT LABEL)   ) ; No-op in C

(define-emit (GLOBAL LABEL)     ) ; Global functions are already visible in C

(define-emit (ALIGN long)       ) ; No-op in C

(define-emit (LONG long)        
  (print "  " $1 ",") (c-newline))

(define-emit (LONG LABEL)       
  (print "  (long)" $1 ",") (c-newline))

(define-emit (ASCIZ string)     
  (print "  ") (dumpln $1) (print ",") (c-newline))

(define-emit (DEFLABEL LABEL)   
  (println)
  (println "static long " $1 "[] = {"))

(define-emit (ENTER long)       
  (println "{")
  (set *c-indent* (+ *c-indent* 1))
  (set *c-temps* ()))

(define-emit (LEAVE long)       
  (set *c-indent* (- *c-indent* 1))
  (println "}")
  (println))

;;; ARITHMETIC OPERATIONS

(define-emit (NEG)              
  (c-indent) (println "_eax = -_eax;"))

(define-emit (ADD TI32)         
  (c-indent) (println "_eax = _eax + " $1 ";"))

(define-emit (SUB TI32)         
  (c-indent) (println "_eax = _eax - " $1 ";"))

(define-emit (MUL TI32)         
  (c-indent) (println "_eax = _eax * " $1 ";"))

(define-emit (DIV TI32)         
  (c-indent) (println "_eax = _eax / " $1 ";"))

(define-emit (AND TI32)         
  (c-indent) (println "_eax = _eax & " $1 ";"))

(define-emit (OR TI32)          
  (c-indent) (println "_eax = _eax | " $1 ";"))

(define-emit (XOR TI32)         
  (c-indent) (println "_eax = _eax ^ " $1 ";"))

(define-emit (NOT)              
  (c-indent) (println "_eax = !_eax;"))

;;; COMPARISON OPERATIONS

(define-emit (LT TI32)          
  (c-indent) (println "_eax = _eax < " $1 " ? 1 : 0;"))

(define-emit (LE TI32)          
  (c-indent) (println "_eax = _eax <= " $1 " ? 1 : 0;"))

(define-emit (EQ TI32)          
  (c-indent) (println "_eax = _eax == " $1 " ? 1 : 0;"))

(define-emit (NE TI32)          
  (c-indent) (println "_eax = _eax != " $1 " ? 1 : 0;"))

(define-emit (GE TI32)          
  (c-indent) (println "_eax = _eax >= " $1 " ? 1 : 0;"))

(define-emit (GT TI32)          
  (c-indent) (println "_eax = _eax > " $1 " ? 1 : 0;"))

(define-emit (SLA TI32)         
  (c-indent) (println "_eax = _eax << " $1 ";"))

(define-emit (SRA TI32)         
  (c-indent) (println "_eax = _eax >> " $1 ";"))

;;; CONTROL FLOW

(define-emit (BR LABEL)         
  (c-indent) (println "goto " $1 ";"))

(define-emit (BF LABEL)         
  (c-indent) (println "if (!_eax) goto " $1 ";"))

(define-emit (BT LABEL)         
  (c-indent) (println "if (_eax) goto " $1 ";"))

(define-emit (CALL LABEL)       
  (c-indent) (print "_eax = " $1 "(")
  (for (i 0 *c-arg-count*)
    (and (> i 0) (print ", "))
    (print "_arg_" i))
  (println ");")
  (set *c-arg-count* 0))

(define-emit (CALL long)        
  (c-indent) (print "_eax = ((long (*)())_eax)(")
  (for (i 0 $1)
    (and (> i 0) (print ", "))
    (print "_arg_" i))
  (println ");")
  (set *c-arg-count* 0))

;;; LOAD/STORE OPERATIONS

(define-emit (LOAD LI32)        
  (c-indent) (println "_eax = " $1 ";"))

(define-emit (LOAD LABEL)       
  (c-indent) (println "_eax = (long)" $1 ";"))

(define-emit (LOAD GI32)        
  (c-indent) (println "_eax = " $1 ";"))

(define-emit (LOAD TI32)        
  (c-indent) (println "_eax = " $1 ";"))

(define-emit (STORE TI32)       
  (c-indent) (println $1 " = _eax;"))

(define-emit (STORE GI32)       
  (c-indent) (println $1 " = _eax;"))

(define-emit (ADDR GI32)        
  (c-indent) (println "_eax = (long)&" $1 ";"))

(define-emit (ADDR TI32)        
  (c-indent) (println "_eax = (long)&" $1 ";"))

(define-emit (MOVE TI32 TI32)   
  (c-indent) (println $2 " = " $1 ";"))

;;; MISC OPERATIONS

(define-emit (COMMENT pair)     
  (c-indent) (print "/* ") (apply print $1) (println " */"))

(define-emit (CHR-AT TI32)      
  (c-indent) (println "_eax = ((char*)_eax)[" $1 "];"))

(define-emit (SET-CHR-AT TI32 TI32)  
  (c-indent) (println "((char*)_eax)[" $2 "] = " $1 ";"))

(define-emit (OOP-AT TI32)      
  (c-indent) (println "_eax = ((long*)_eax)[" $1 "];"))

(define-emit (SET-OOP-AT TI32 TI32)  
  (c-indent) (println "((long*)_eax)[" $2 "] = " $1 ";"))

;;; Override gen-definition for C output
(define-method gen-definition <expr> (name ocomp)
  (let* ((main (= 'main name))
         (defn (<expr>-defn self))
         (body (cddr defn))
         (comp (compiler (+ 1 (<compiler>-level ocomp))))
         (tnam (if main name (concat-symbol name '_fn)))
         (params (map-with gen-param (cadr defn) comp)))
    ;; Generate function signature
    (print "long " tnam "(")
    (let ((first 1))
      (list-do param params
        (and (not first) (print ", "))
        (set first ())
        (print "long _param_" (>> (<TI32>-offset param) 2))))
    (println ") {")
    (set *c-indent* 1)
    
    ;; Declare registers
    (c-indent) (println "long _eax = 0;")
    
    ;; Declare arguments (up to max used)
    (let ((max-args (<compiler>-arg-limit comp)))
      (for (i 0 (>> max-args 2))
        (c-indent) (println "long _arg_" i " = 0;")))
    
    ;; Declare temps (up to max used)
    (let ((max-temps (<compiler>-tmp-limit comp)))
      (for (i 0 (>> max-temps 2))
        (c-indent) (println "long _tmp_" i " = 0;")))
    
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
    
    ;; Generate global variable if not main
    (or main
        (let ()
          (println "long " name " = (long)" tnam ";")
          (println)))))

;;; Override gen-definition methods for C
(define-method gen-definition <long> (name comp)
  (println "long " name " = " self "L;")
  (println))

(define-method gen-definition <string> (name comp)
  (print "char " name "_data[] = ")
  (dumpln self)
  (println ";")
  (println "long " name " = (long)" name "_data;")
  (println))

(define-method gen-definition <extern> (name comp)
  (println "extern long " (<extern>-name self) "();")
  (println "long " (concat-symbol (<extern>-name self) '$stub) " = (long)&" (<extern>-name self) ";")
  (println))

(define-method gen-definition <form> (name comp)
  (println "/* form " name " */"))

;;; Override gen-env for C output
(define-function gen-env (env)
  ;; Generate includes
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println "#include <string.h>")
  (println)
  
  ;; Forward declarations
  (println "/* Forward declarations */")
  (let* ((vars  (<env>-bindings env))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (and (= <expr> (type-of value))
             (let ((fname (if (= 'main name) name (concat-symbol name '_fn))))
               (print "long " fname "(")
               ;; TODO: Get param count from defn
               (println ");"))))))
  (println)
  
  ;; Generate definitions
  (let* ((vars  (<env>-bindings env))
         (comp  (compiler 0))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (gen-definition value name comp)))))