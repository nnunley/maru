;;; emit-c-high.l -- High-Level C Code Generation Backend
;;;
;;; This backend generates idiomatic C code by operating at the expression
;;; and statement level rather than simulating assembly instructions.
;;; It overrides the gen() methods to build C constructs directly.

;;; C Generation State
(define *c-output* ())
(define *c-indent-level* 0)
(define *c-temp-counter* 0)
(define *c-label-counter* 0)
(define *c-in-function* ())
(define *c-var-names* ())  ; Map from variables to C names

;;; Utility Functions

(define-function c-indent ()
  (for (i 0 *c-indent-level*) (print "    ")))

(define-function c-emit-line (str)
  (c-indent)
  (println str))

(define-function c-emit (str)
  (print str))

(define-function c-newline ()
  (println)
  (c-indent))

(define-function c-fresh-temp ()
  (let ((name (concat-string "_t" (long->string (set *c-temp-counter* (+ *c-temp-counter* 1))))))
    name))

(define-function c-fresh-label ()
  (let ((name (concat-string "_L" (long->string (set *c-label-counter* (+ *c-label-counter* 1))))))
    name))

(define-function c-var-name (var)
  (or (cdr (assq var *c-var-names*))
      (let ((name (concat-string "_v" (long->string (list-length *c-var-names*)))))
        (set *c-var-names* (cons (cons var name) *c-var-names*))
        name)))

;;; C Expression Generation - Forward declarations
(define c-gen-pair-expr ())
(define c-gen-binary-op ())
(define c-gen-comparison ())
(define c-gen-equality ())
(define c-gen-inequality ())
(define c-gen-function-call ())
(define c-join-strings ())

(define-function c-gen-pair-expr (expr)
  "Generate C expression for pair (operation or function call)"
  (let ((op (car expr))
        (args (cdr expr)))
    (cond
      ;; Arithmetic operations
      ((variable? op)
       (let ((op-name (<variable>-name op)))
         (cond
           ((= op-name '+) (c-gen-binary-op "+" args))
           ((= op-name '-) (if (pair? (cdr args))
                               (c-gen-binary-op "-" args)
                               (concat-string "LONG(-getLong(" (c-gen-expr (car args)) "))")))
           ((= op-name '*) (c-gen-binary-op "*" args))
           ((= op-name '/) (c-gen-binary-op "/" args))
           ((= op-name '&) (c-gen-binary-op "&" args))
           ((= op-name '|) (c-gen-binary-op "|" args))
           ((= op-name '^) (c-gen-binary-op "^" args))
           ((= op-name '<) (c-gen-comparison "<" args))
           ((= op-name '<=) (c-gen-comparison "<=" args))
           ((= op-name '=) (c-gen-equality args))
           ((= op-name '!=) (c-gen-inequality args))
           ((= op-name '>=) (c-gen-comparison ">=" args))
           ((= op-name '>) (c-gen-comparison ">" args))
           ((= op-name '<<) (c-gen-binary-op "<<" args))
           ((= op-name '>>) (c-gen-binary-op ">>" args))
           ((= op-name 'not) (concat-string "((" (c-gen-expr (car args)) " == nil) ? LONG(1) : nil)"))
           
           ;; Function call
           (else (c-gen-function-call op args)))))
      
      ;; Direct function call
      (else (c-gen-function-call op args)))))

(define-function c-gen-binary-op (op-str args)
  "Generate binary arithmetic operation"
  (if (and (pair? args) (pair? (cdr args)))
      (concat-strings "LONG(getLong(" (c-gen-expr (car args)) ") " op-str " getLong(" (c-gen-expr (cadr args)) "))")
      "nil"))

(define-function c-gen-comparison (op-str args)
  "Generate comparison operation"
  (if (and (pair? args) (pair? (cdr args)))
      (concat-strings "((getLong(" (c-gen-expr (car args)) ") " op-str " getLong(" (c-gen-expr (cadr args)) ")) ? LONG(1) : nil)")
      "nil"))

(define-function c-gen-equality (args)
  "Generate equality comparison"
  (if (and (pair? args) (pair? (cdr args)))
      (concat-strings "((" (c-gen-expr (car args)) " == " (c-gen-expr (cadr args)) ") ? LONG(1) : nil)")
      "nil"))

(define-function c-gen-inequality (args)
  "Generate inequality comparison"  
  (if (and (pair? args) (pair? (cdr args)))
      (concat-strings "((" (c-gen-expr (car args)) " != " (c-gen-expr (cadr args)) ") ? LONG(1) : nil)")
      "nil"))

(define-function c-gen-function-call (func args)
  "Generate function call"
  (let ((func-name (if (variable? func) (<variable>-name func) "unknown"))
        (arg-exprs (map c-gen-expr args)))
    (concat-strings (symbol->string func-name) "(" (c-join-strings arg-exprs ", ") ")")))

(define-function c-join-strings (strings separator)
  "Join list of strings with separator"
  (if (pair? strings)
      (if (pair? (cdr strings))
          (concat-strings (car strings) separator (c-join-strings (cdr strings) separator))
          (car strings))
      ""))

;;; C Statement Generation

(define-function c-gen-statement (expr)
  "Generate C statement for expression"
  (cond
    ;; Control structures
    ((and (pair? expr) (variable? (car expr)))
     (let ((op-name (<variable>-name (car expr))))
       (cond
         ((= op-name 'if) (c-gen-if expr))
         ((= op-name 'while) (c-gen-while expr))
         ((= op-name 'set) (c-gen-set expr))
         ((= op-name 'let) (c-gen-let expr))
         ((= op-name 'return) (c-gen-return expr))
         
         ;; Expression statement
         (else (c-emit-line (concat-string (c-gen-expr expr) ";"))))))
    
    ;; Expression statement
    (else (c-emit-line (concat-string (c-gen-expr expr) ";")))))

(define-function c-gen-if (expr)
  "Generate C if statement"
  (let ((condition (c-gen-expr (cadr expr)))
        (then-body (caddr expr))
        (else-body (and (pair? (cdddr expr)) (cadddr expr))))
    (c-emit-line (concat-string "if (" condition " != nil) {"))
    (set *c-indent-level* (+ *c-indent-level* 1))
    (c-gen-statement then-body)
    (set *c-indent-level* (- *c-indent-level* 1))
    (c-emit-line "}")
    (when else-body
      (c-emit-line " else {")
      (set *c-indent-level* (+ *c-indent-level* 1))
      (c-gen-statement else-body)
      (set *c-indent-level* (- *c-indent-level* 1))
      (c-emit-line "}"))))

(define-function c-gen-while (expr)
  "Generate C while loop"
  (let ((condition (c-gen-expr (cadr expr)))
        (body-exprs (cddr expr)))
    (c-emit-line (concat-string "while (" condition " != nil) {"))
    (set *c-indent-level* (+ *c-indent-level* 1))
    (list-do body-expr body-exprs
      (c-gen-statement body-expr))
    (set *c-indent-level* (- *c-indent-level* 1))
    (c-emit-line "}")))

(define-function c-gen-set (expr)
  "Generate C assignment statement"
  (let ((var (cadr expr))
        (value-expr (c-gen-expr (caddr expr))))
    (c-emit-line (concat-strings (c-var-name var) " = " value-expr ";"))))

(define-function c-gen-let (expr)
  "Generate C let statement (local variable declaration)"
  (let ((bindings (caddr expr))
        (body-exprs (cdddr expr)))
    ;; Generate variable declarations
    (list-do binding bindings
      (let ((var (car binding))
            (init-expr (if (pair? (cdr binding))
                           (c-gen-expr (cadr binding))
                           "nil")))
        (c-emit-line (concat-strings "oop " (c-var-name var) " = " init-expr ";"))))
    ;; Generate body
    (list-do body-expr body-exprs
      (c-gen-statement body-expr))))

(define-function c-gen-return (expr)
  "Generate C return statement"
  (if (pair? (cdr expr))
      (c-emit-line (concat-string "return " (c-gen-expr (cadr expr)) ";"))
      (c-emit-line "return nil;")))

;;; High-Level Generator Overrides

(define-method gen-c-function <expr> (name ocomp)
  "Generate high-level C function"
  (let* ((main (= 'main name))
         (defn (<expr>-defn self))
         (params (cadr defn))
         (body (cddr defn)))
    
    ;; Generate function signature
    (if main
        (println "int main(int argc, char **argv) {")
        (let ()
          (print "oop " (symbol->string name) "(")
          (let ((first 1))
            (list-do param params
              (and (not first) (print ", "))
              (set first ())
              (print "oop " (c-var-name param))))
          (println ") {")))
    
    ;; Function body
    (set *c-indent-level* 1)
    (set *c-var-names* ())  ; Reset variable names
    (set *c-temp-counter* 0)
    
    ;; Generate parameter declarations for main
    (when main
      (list-do param params
        (c-emit-line (concat-string "oop " (c-var-name param) " = nil;  // parameter"))))
    
    ;; Generate body statements
    (list-do body-expr body
      (c-gen-statement body-expr))
    
    ;; Default return for main
    (when main
      (c-emit-line "return 0;"))
    
    ;; Close function
    (set *c-indent-level* 0)
    (println "}")
    (println)))

;;; Environment Generation for High-Level C

(define-function gen-env-c-high (env)
  "Generate complete C file with high-level approach"
  ;; File header
  (println "/* Generated by Maru High-Level C Backend */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println "#include <string.h>")
  (println)
  
  ;; Type definitions
  (println "typedef union Object *oop;")
  (println "#define nil ((oop)0)")
  (println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (println "#define getLong(x) ((long)(x) >> 1)")
  (println)
  
  ;; External declarations
  (let* ((vars (<env>-bindings env))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name (<variable>-name (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (when (extern? value)
          (println "extern oop " (<extern>-name value) "();")))))
  (println)
  
  ;; Function declarations
  (let* ((vars (<env>-bindings env))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name (<variable>-name (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (when (= <expr> (type-of value))
          (if (= 'main name)
              (println "int main(int argc, char **argv);")
              (println "oop " (symbol->string name) "();"))))))
  (println)
  
  ;; Generate function definitions
  (let* ((vars (<env>-bindings env))
         (index (array-length vars)))
    (while (<= 0 (set index (- index 1)))
      (let ((name (<variable>-name (array-at vars index)))
            (value (<variable>-value (array-at vars index))))
        (when (= <expr> (type-of value))
          (println "/* function " (symbol->string name) " */")
          (gen-c-function value name ()))))))

;;; Override the main generation function
(define-function gen-env-high-level (env) (gen-env-c-high env))

(println "emit-c-high.l loaded - High-level C backend ready")