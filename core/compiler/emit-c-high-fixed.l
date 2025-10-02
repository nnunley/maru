;;; emit-c-high-fixed.l -- High-Level C Code Generation Backend (Fixed)
;;;
;;; This backend generates idiomatic C code by operating at the expression
;;; and statement level rather than simulating assembly instructions.

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

;;; String utility
(define-function c-join-strings (strings separator)
  "Join list of strings with separator"
  (if (pair? strings)
      (if (pair? (cdr strings))
          (concat-strings (car strings) separator (c-join-strings (cdr strings) separator))
          (car strings))
      ""))

;;; Binary and comparison operations
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

;;; Main expression generation
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

(define-function c-gen-expr (expr)
  "Generate C expression and return the expression string"
  (cond
    ;; Literals
    ((long? expr) (concat-string "LONG(" (long->string expr) ")"))
    ((string? expr) (concat-string "(oop)\"" expr "\""))
    
    ;; Variables  
    ((variable? expr)
     (let ((value (<variable>-value expr)))
       (if (extern? value)
           (concat-string "((oop)" (<variable>-name expr) ")")
           (c-var-name expr))))
    
    ;; Pairs (function calls and operations)
    ((pair? expr) (c-gen-pair-expr expr))
    
    ;; Default
    (else "nil")))

;;; Simple test function
(define-function test-c-gen ()
  "Test the C generation functions"
  (println "Testing C expression generation:")
  (println "42 -> " (c-gen-expr 42))
  (println "\"hello\" -> " (c-gen-expr "hello"))
  (println "Done."))

(println "emit-c-high-fixed.l loaded - High-level C backend ready")