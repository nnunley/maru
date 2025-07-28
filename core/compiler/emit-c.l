;;; emit-c.l -- C code generation backend
;;;
;;; This file contains C-specific emit methods that generate
;;; C code in the style of eval.c (with oop typedef and LONG macros)

(emit-writeln "; Loading C backend emit-c.l")

(require "lib/stream/port.l")

;;; C code generation state
(define *c-indent* 0)
(define *c-arg-count* 0)

(define-function c-indent ()
  (port-indent *emit-output-port* (* *c-indent* 2)))

(define-function c-newline ()
  (port-newline *emit-output-port*)
  (c-indent))

;;; Helper to get temp name
(define-function c-temp-name (temp)
  (concat-string "_tmp" (long->string (>> (<TI32>-offset temp) 2))))

;;; C EMIT INSTRUCTIONS

;; Memory and object access instructions
(define-emit (OOP-AT TI32)
  (c-indent) (c-emitln "_acc = ((oop*)_acc)[getLong(" $1 ")];"))

(define-emit (SET-OOP-AT TI32 TI32)  
  (c-indent) (c-emitln "((oop*)_acc)[getLong(" $1 ")] = " $2 ";"))

(define-emit (OOP-AT)
  (c-indent) (c-emitln "_acc = ((oop*)_acc)[_arg0];"))

(define-emit (SET-OOP-AT)
  (c-indent) (c-emitln "((oop*)_arg0)[_arg1] = _acc;"))

;; Load/Store instructions  
(define-emit (LOAD LI32)
  (emit-writeln "  _acc = LONG(" $1 ");"))

(define-emit (LOAD GI32)
  (emit-writeln "  _acc = " $1 ";"))

(define-emit (LOAD TI32)
  (emit-writeln "  _acc = " (c-temp-name $1) ";"))

(define-emit (STORE TI32)
  (emit-writeln "  " (c-temp-name $1) " = _acc;"))

;; Arithmetic instructions
(define-emit (ADD TI32)
  (emit-writeln "  _acc = LONG(LONG(_acc) + LONG(" (c-temp-name $1) "));"))

(define-emit (SUB TI32)
  (emit-writeln "  _acc = LONG(LONG(_acc) - LONG(" (c-temp-name $1) "));"))

(define-emit (MUL TI32)
  (emit-writeln "  _acc = LONG(LONG(_acc) * LONG(" (c-temp-name $1) "));"))

;; Comparison instructions
(define-emit (LT TI32)
  (emit-writeln "  _acc = (LONG(_acc) < LONG(" (c-temp-name $1) ")) ? _true : nil;"))

(define-emit (LE TI32)  
  (emit-writeln "  _acc = (LONG(_acc) <= LONG(" (c-temp-name $1) ")) ? _true : nil;"))

(define-emit (EQ TI32)
  (emit-writeln "  _acc = (_acc == " (c-temp-name $1) ") ? _true : nil;"))

(define-emit (NE TI32)
  (emit-writeln "  _acc = (_acc != " (c-temp-name $1) ") ? _true : nil;"))

(define-emit (GE TI32)
  (emit-writeln "  _acc = (LONG(_acc) >= LONG(" (c-temp-name $1) ")) ? _true : nil;")

(define-emit (GT TI32)
  (emit-writeln "  _acc = (LONG(_acc) > LONG(" (c-temp-name $1) ")) ? _true : nil;"))

;; Helper function to build argument list
(define-function c-build-args (count)
  (if (<= count 0)
      ""
    (let ((args "_arg0"))
      (for (i 1 count)
        (set args (concat-string args (concat-string ", _arg" (long->string i)))))
      args)))

;; Control flow instructions
(define-emit (BR LABEL)
  (emit-writeln "  goto " $1 ";"))

(define-emit (BF LABEL)
  (emit-writeln "  if (!_acc) goto " $1 ";"))

(define-emit (BT LABEL)
  (emit-writeln "  if (_acc) goto " $1 ";"))

(define-emit (CALL long)
  (emit-writeln "  _acc = ((oop (*)())_acc)(" (c-build-args $1) ");"))

;; Function prologue/epilogue  
(define-emit (ENTER long)
  (emit-writeln "  // Function prologue (frame size: " $1 ")"))

(define-emit (LEAVE long)
  (emit-writeln "  return _acc;"))

;; Data directives
(define-emit (TEXT)
  (emit-writeln "// .text section"))

(define-emit (DATA)
  (emit-writeln "// .data section"))

(define-emit (DEFLABEL LABEL)
  (emit-writeln $1 ":"))

(define-emit (COMMENT pair)
  (emit-write "  // ") (apply emit-writeln $1))

;;; Override TI32 printing for C
(define-method do-print <TI32> () 
  (print (c-temp-name self)))


;; Port output helpers - these just delegate to the global emit functions
(define-function c-emit items
  ;; Write multiple items to the output port
  (apply emit-write items))

(define-function c-emitln items
  ;; Write multiple items to the output port and newline
  (apply emit-writeln items))

(define-function c-print-mangled-name (name)
  ;; For now, just print the name directly since symbol->string might not work in bootstrap
  (emit-write (mangle-label name)))

(define-function c-print-method-name (method-name types)
  ;; Generate mangled name for a method with type specializations
  ;; Format: method-name__type1_type2_..._typeN
  (c-print-mangled-name method-name)
  (c-emit "__")
  (if types
      (let ((first 1))
        (list-do type types
          (and (not first) (c-emit "_"))
          (set first ())
          (c-print-mangled-name type)))
      (c-emit "void")))

;;; C DIRECTIVES AND STRUCTURE

(define-emit (TEXT)             ) ; No-op in C
(define-emit (DATA)             ) ; No-op in C
(define-emit (SECTION string)   ) ; No-op in C
(define-emit (INDIRECT LABEL)   ) ; No-op in C

(define-emit (GLOBAL LABEL)     ) ; Global functions are already visible in C

(define-emit (ALIGN long)       ) ; No-op in C

(define-emit (LONG long)        
  (emit-write "  " $1 ",") (c-newline))

(define-emit (LONG LABEL)       
  (emit-write "  (long)" $1 ",") (c-newline))

(define-emit (ASCIZ string)     
  (emit-write "  ") 
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
  (emit-write ",") (c-newline))

(define-emit (DEFLABEL LABEL)   
  (emit-writeln)
  (emit-writeln "static long " $1 "[] = {"))

(define-emit (ENTER long)       
  (emit-writeln "{")
  (set *c-indent* (+ *c-indent* 1))
  (set *c-arg-count* 0))

(define-emit (LEAVE long)       
  (set *c-indent* (- *c-indent* 1))
  (emit-writeln "}")
  (emit-writeln))

;;; ARITHMETIC OPERATIONS

(define-emit (NEG)              
  (c-indent) (emit-writeln "_acc = LONG(-getLong(_acc));"))

(define-emit (ADD TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) + getLong(" $1 "));"))

(define-emit (SUB TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) - getLong(" $1 "));"))

(define-emit (MUL TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) * getLong(" $1 "));"))

(define-emit (DIV TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) / getLong(" $1 "));"))

(define-emit (AND TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) & getLong(" $1 "));"))

(define-emit (OR TI32)          
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) | getLong(" $1 "));"))

(define-emit (XOR TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) ^ getLong(" $1 "));"))

(define-emit (NOT)              
  (c-indent) (emit-writeln "_acc = (_acc == nil) ? LONG(1) : LONG(0);"))

;;; COMPARISON OPERATIONS

(define-emit (LT TI32)          
  (c-indent) (emit-writeln "_acc = (getLong(_acc) < getLong(" $1 ")) ? LONG(1) : LONG(0);"))

(define-emit (LE TI32)          
  (c-indent) (emit-writeln "_acc = (getLong(_acc) <= getLong(" $1 ")) ? LONG(1) : LONG(0);"))

(define-emit (EQ TI32)          
  (c-indent) (emit-writeln "_acc = (_acc == " $1 ") ? LONG(1) : LONG(0);"))

(define-emit (NE TI32)          
  (c-indent) (emit-writeln "_acc = (_acc != " $1 ") ? LONG(1) : LONG(0);"))

(define-emit (GE TI32)          
  (c-indent) (emit-writeln "_acc = (getLong(_acc) >= getLong(" $1 ")) ? LONG(1) : LONG(0);"))

(define-emit (GT TI32)          
  (c-indent) (emit-writeln "_acc = (getLong(_acc) > getLong(" $1 ")) ? LONG(1) : LONG(0);"))

(define-emit (SLA TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) << getLong(" $1 "));"))

(define-emit (SRA TI32)         
  (c-indent) (emit-writeln "_acc = LONG(getLong(_acc) >> getLong(" $1 "));"))

;;; CONTROL FLOW

(define-emit (BR LABEL)         
  (c-indent) (emit-writeln "goto " $1 ";"))

(define-emit (BF LABEL)         
  (c-indent) (emit-writeln "if (_acc == nil) goto " $1 ";"))

(define-emit (BT LABEL)         
  (c-indent) (emit-writeln "if (_acc != nil) goto " $1 ";"))

(define-emit (CALL LABEL)       
  (c-indent) (emit-write "_acc = " $1 "(")
  (for (i 0 *c-arg-count*)
    (and (> i 0) (emit-write ", "))
    (emit-write "_arg" i))
  (emit-writeln ");")
  (set *c-arg-count* 0))

(define-emit (CALL long)        
  (c-indent) (emit-write "_acc = ((oop (*)())_acc)(")
  (for (i 0 $1)
    (and (> i 0) (emit-write ", "))
    (emit-write "_arg" i))
  (emit-writeln ");")
  (set *c-arg-count* 0))

;;; LOAD/STORE OPERATIONS

(define-emit (LOAD LI32)        
  (c-indent) (emit-writeln "_acc = LONG(" $1 ");"))

(define-emit (LOAD LABEL)       
  (c-indent) (emit-writeln "_acc = (oop)" $1 ";"))

(define-emit (LOAD GI32)        
  (c-indent) (emit-writeln "_acc = " $1 ";"))

(define-emit (LOAD TI32)        
  (c-indent) (emit-writeln "_acc = " $1 ";"))

(define-emit (STORE TI32)       
  (c-indent) (emit-writeln $1 " = _acc;"))

(define-emit (STORE GI32)       
  (c-indent) (emit-writeln $1 " = _acc;"))

(define-emit (ADDR GI32)        
  (c-indent) (emit-writeln "_acc = (oop)&" $1 ";"))

(define-emit (ADDR TI32)        
  (c-indent) (emit-writeln "_acc = (oop)&" $1 ";"))

(define-emit (MOVE TI32 TI32)   
  (c-indent) (emit-writeln $2 " = " $1 ";")
  (set *c-arg-count* (+ *c-arg-count* 1)))

;;; MISC OPERATIONS

(define-emit (COMMENT pair)     
  (c-indent) (emit-write "/* ") (apply emit-write $1) (emit-writeln " */"))

(define-emit (CHR-AT TI32)      
  (c-indent) (emit-writeln "_acc = LONG(((char*)_acc)[getLong(" $1 ")]);"))

(define-emit (SET-CHR-AT TI32 TI32)  
  (c-indent) (emit-writeln "((char*)_acc)[getLong(" $1 ")] = (char)getLong(" $2 ");"))


;;; Override gen-definition for C output
(define-method gen-definition <expr> (name ocomp)
  (let* ((main (= 'main name))
         (defn (<expr>-defn self))
         (body (cddr defn))
         (comp (compiler (+ 1 (<compiler>-level ocomp))))
         (params (map-with gen-param (cadr defn) comp)))
    ;; Generate function signature
    (if main
        (emit-writeln "int main(int argc, char **argv) {")
        (let ()
          (emit-write "oop ")
          (c-print-mangled-name name)
          (emit-write "(")
          (let ((first 1))
            (list-do param params
              (and (not first) (emit-write ", "))
              (set first ())
              (emit-write "oop _param" (>> (<TI32>-offset param) 2))))
          (emit-writeln ") {")))
    (set *c-indent* 1)
    
    ;; Declare accumulator variable
    (c-indent) (emit-writeln "oop _acc = nil;")
    
    ;; Declare arguments (up to max used)
    (let ((max-args (<compiler>-arg-limit comp)))
      (for (i 0 (>> max-args 2))
        (c-indent) (emit-writeln "oop _arg" i " = nil;")))
    
    ;; Declare temps (up to max used)
    (let ((max-temps (<compiler>-tmp-limit comp)))
      (for (i 0 (>> max-temps 2))
        (c-indent) (emit-writeln "oop _tmp" i " = nil;")))
    
    ;; Generate body
    (list-do e body (gen e comp))
    
    ;; Generate code
    (for (i 0 (<compiler>-pc comp)) 
      (apply emit (array-at (<compiler>-asm comp) i)))
    
    ;; Epilogue
    (and (<compiler>-epilogue comp)
         (let ()
           (emit-writeln (<compiler>-epilogue comp) ":")
           (c-indent)))
    
    ;; Return
    (if main
        (emit-writeln "return 0;")
        (emit-writeln "return _acc;"))
    (set *c-indent* 0)
    (emit-writeln "}")
    (emit-writeln)
    
    ;; Generate global variable if not main
    (or main
        (let ()
          (emit-write "oop ")
          (c-print-mangled-name name)
          (emit-write " = (oop)")
          (c-print-mangled-name name)
          (emit-writeln ";")))))

;;; Override gen-definition methods for C
(define-method gen-definition <long> (name comp)
  (emit-write "oop ")
  (c-print-mangled-name name)
  (emit-writeln " = LONG(" self ");")
  (emit-writeln))

(define-method gen-definition <string> (name comp)
  (emit-write "char ")
  (c-print-mangled-name name)
  (emit-write "_data[] = ")
  ;; Manually emit the string representation
  (emit-write "\"")
  (for-each self (lambda (c) 
    (cond
      ((= c ?\") (emit-write "\\\""))
      ((= c ?\\) (emit-write "\\\\"))
      ((= c ?\n) (emit-write "\\n"))
      ((= c ?\r) (emit-write "\\r"))
      ((= c ?\t) (emit-write "\\t"))
      ((< c 32) (emit-write "\\" (format "%03o" c)))
      (else (emit-write (format "%c" c))))))
  (emit-write "\"")
  (emit-writeln ";")
  (emit-write "oop ")
  (c-print-mangled-name name)
  (emit-write " = (oop)")
  (c-print-mangled-name name)
  (emit-writeln "_data;")
  (emit-writeln))

(define-method gen-definition <extern> (name comp)
  (emit-write "extern oop ")
  (c-print-mangled-name (<extern>-name self))
  (emit-writeln "();")
  (emit-write "oop ")
  (c-print-mangled-name (concat-symbol (<extern>-name self) '$stub))
  (emit-write " = (oop)&")
  (c-print-mangled-name (<extern>-name self))
  (emit-writeln ";")
  (emit-writeln))

(define-method gen-definition <form> (name comp)
  (emit-writeln "/* form " name " */"))

;;; Override gen-env for C output 
(define-function gen-env (env)
  ;; Generate includes and typedefs
  (emit-writeln "/* Generated by Maru compiler */")
  (emit-writeln "#include <stdio.h>")
  (emit-writeln "#include <stdlib.h>")
  (emit-writeln "#include <string.h>")
  (emit-writeln)
  (emit-writeln "typedef union Object *oop;")
  (emit-writeln "#define nil ((oop)0)")
  (emit-writeln "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (emit-writeln "#define getLong(x) ((long)(x) >> 1)")
  (emit-writeln)
  
  ;; Forward declarations
  (emit-writeln "/* Forward declarations */")
  (let* ((vars  (<env>-bindings env))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (and (= <expr> (type-of value))
             (let ()
               (emit-write "oop ")
               (c-print-mangled-name name)
               (emit-writeln "();"))))))
  (emit-writeln)
  
  ;; Generate definitions
  (let* ((vars  (<env>-bindings env))
         (comp  (compiler 0))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name  (<variable>-name  (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (emit-writeln "/* defn " name " */")
        (gen-definition value name comp))))))