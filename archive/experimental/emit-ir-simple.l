;;; emit-ir-simple.l - Simplified IR-based emit
;;;
;;; This demonstrates how emit.l could use an IR approach
;;; without requiring the full .k infrastructure

(require "boot.l")

;;; Simple IR node types
(define-structure <ir-node> (type))
(define-structure <ir-literal> (type value))
(define-structure <ir-variable> (type name))
(define-structure <ir-binary-op> (type op left right))
(define-structure <ir-if> (type test then else))
(define-structure <ir-let> (type bindings body))
(define-structure <ir-call> (type func args))
(define-structure <ir-function> (type name params body))
(define-structure <ir-block> (type statements))

;;; IR builders
(define-function make-ir-literal (value)
  (let ((node (new <ir-literal>)))
    (set (<ir-literal>-type node) 'literal)
    (set (<ir-literal>-value node) value)
    node))

(define-function make-ir-variable (name)
  (let ((node (new <ir-variable>)))
    (set (<ir-variable>-type node) 'variable)
    (set (<ir-variable>-name node) name)
    node))

(define-function make-ir-binary-op (op left right)
  (let ((node (new <ir-binary-op>)))
    (set (<ir-binary-op>-type node) 'binary-op)
    (set (<ir-binary-op>-op node) op)
    (set (<ir-binary-op>-left node) left)
    (set (<ir-binary-op>-right node) right)
    node))

(define-function make-ir-if (test then else)
  (let ((node (new <ir-if>)))
    (set (<ir-if>-type node) 'if)
    (set (<ir-if>-test node) test)
    (set (<ir-if>-then node) then)
    (set (<ir-if>-else node) else)
    node))

(define-function make-ir-let (bindings body)
  (let ((node (new <ir-let>)))
    (set (<ir-let>-type node) 'let)
    (set (<ir-let>-bindings node) bindings)
    (set (<ir-let>-body node) body)
    node))

(define-function make-ir-call (func args)
  (let ((node (new <ir-call>)))
    (set (<ir-call>-type node) 'call)
    (set (<ir-call>-func node) func)
    (set (<ir-call>-args node) args)
    node))

(define-function make-ir-function (name params body)
  (let ((node (new <ir-function>)))
    (set (<ir-function>-type node) 'function)
    (set (<ir-function>-name node) name)
    (set (<ir-function>-params node) params)
    (set (<ir-function>-body node) body)
    node))

(define-function make-ir-block (statements)
  (let ((node (new <ir-block>)))
    (set (<ir-block>-type node) 'block)
    (set (<ir-block>-statements node) statements)
    node))

;;; Convert S-expressions to IR
(define-function sexp->ir (expr)
  (cond
    ;; Literals
    ((or (long? expr) (string? expr))
     (make-ir-literal expr))
    
    ;; Variables
    ((symbol? expr)
     (make-ir-variable expr))
    
    ;; Lists
    ((pair? expr)
     (let ((op (car expr))
           (args (cdr expr)))
       (cond
         ;; Binary operations
         ((member? op '(+ - * / < > <= >= = !=))
          (make-ir-binary-op op 
                             (sexp->ir (car args))
                             (sexp->ir (car (cdr args)))))
         
         ;; If
         ((= op 'if)
          (make-ir-if (sexp->ir (car args))
                      (sexp->ir (car (cdr args)))
                      (if (cdr (cdr args))
                          (sexp->ir (car (cdr (cdr args))))
                          (make-ir-literal ()))))
         
         ;; Let
         ((= op 'let)
          (let ((bindings (map (lambda (b)
                                (if (pair? b)
                                    (cons (car b) (sexp->ir (car (cdr b))))
                                    (cons b (make-ir-literal ()))))
                              (car args)))
                (body (map sexp->ir (cdr args))))
            (make-ir-let bindings body)))
         
         ;; Function definition
         ((= op 'define-function)
          (make-ir-function (car args)
                           (car (cdr args))
                           (make-ir-block (map sexp->ir (cdr (cdr args))))))
         
         ;; Function call
         (else
          (make-ir-call op (map sexp->ir args))))))
    
    ;; Default
    (else expr)))

;;; Helper to generate indentation
(define-function indent-string (level)
  (let ((str ""))
    (while (< 0 level)
      (set str (concat-string str "  "))
      (set level (- level 1)))
    str))

;;; Generate C code from IR
(define-function ir->c (node indent)
  (let ((spaces (indent-string indent)))
    (cond
      ;; Literal
      ((= (<ir-node>-type node) 'literal)
       (let ((val (<ir-literal>-value node)))
         (cond
           ((long? val) (print val))
           ((string? val) (print "\"" val "\""))
           ((not val) (print "NULL"))
           (else (print "/* unknown literal */")))))
      
      ;; Variable
      ((= (<ir-node>-type node) 'variable)
       (print "v_" (<ir-variable>-name node)))
      
      ;; Binary operation
      ((= (<ir-node>-type node) 'binary-op)
       (print "(")
       (ir->c (<ir-binary-op>-left node) 0)
       (print " " (<ir-binary-op>-op node) " ")
       (ir->c (<ir-binary-op>-right node) 0)
       (print ")"))
      
      ;; If statement
      ((= (<ir-node>-type node) 'if)
       (print spaces "if (")
       (ir->c (<ir-if>-test node) 0)
       (println ") {")
       (ir->c (<ir-if>-then node) (+ indent 1))
       (println)
       (print spaces "} else {")
       (println)
       (ir->c (<ir-if>-else node) (+ indent 1))
       (println)
       (print spaces "}"))
      
      ;; Let binding
      ((= (<ir-node>-type node) 'let)
       (println spaces "{")
       ;; Declare variables
       (list-do binding (<ir-let>-bindings node)
         (print spaces "  long v_" (car binding) " = ")
         (ir->c (cdr binding) 0)
         (println ";"))
       ;; Body
       (list-do stmt (<ir-let>-body node)
         (ir->c stmt (+ indent 1))
         (println ";"))
       (print spaces "}"))
      
      ;; Function call
      ((= (<ir-node>-type node) 'call)
       (print "f_" (<ir-call>-func node) "(")
       (let ((first 1))
         (list-do arg (<ir-call>-args node)
           (if first
               (set first ())
               (print ", "))
           (ir->c arg 0)))
       (print ")"))
      
      ;; Function definition
      ((= (<ir-node>-type node) 'function)
       (print "long f_" (<ir-function>-name node) "(")
       (let ((first 1))
         (list-do param (<ir-function>-params node)
           (if first
               (set first ())
               (print ", "))
           (print "long v_" param)))
       (println ") {")
       (ir->c (<ir-function>-body node) 1)
       (println)
       (println "}"))
      
      ;; Block
      ((= (<ir-node>-type node) 'block)
       (list-do stmt (<ir-block>-statements node)
         (print spaces)
         (ir->c stmt indent)
         (println ";")))
      
      ;; Unknown
      (else
       (print "/* unknown IR node: " (<ir-node>-type node) " */")))))

;;; Main interface
(define-function emit-ir (expressions)
  (println "/* Generated C code via IR */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println)
  
  ;; Convert to IR and generate C
  (list-do expr expressions
    (let ((ir (sexp->ir expr)))
      (ir->c ir 0)
      (println)
      (println))))

;;; Test it
(define test-program
  '((define-function add (a b)
      (+ a b))
    
    (define-function factorial (n)
      (if (<= n 1)
          1
          (* n (factorial (- n 1)))))))

(println "=== Testing Simple IR-based Emit ===")
(println)
(println "Test program:")
(println test-program)
(println)
(println "Converting to IR and generating C...")
(emit-ir test-program)
(println)
(println "=== Done ===")