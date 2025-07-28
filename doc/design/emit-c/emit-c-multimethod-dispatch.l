;;; emit-c-multimethod-dispatch.l - Type-specialized C generation using multimethods

(load "boot.l")

;;; ================================================================
;;; MULTIMETHOD SELECTORS FOR C GENERATION
;;; ================================================================

(define-selector emit-c-operation)

;;; ================================================================
;;; CONTEXT TYPES FOR DISPATCH
;;; ================================================================

(define-structure <numeric-context> ())
(define-structure <object-context> ())  
(define-structure <unknown-context> ())

;;; ================================================================
;;; EXPRESSION COMPILATION WITH CONTEXT (forward declaration)
;;; ================================================================

(define emit-c-expr ())  ; Forward declaration

;;; ================================================================
;;; ARITHMETIC OPERATIONS - SPECIALIZED BY CONTEXT  
;;; ================================================================

;; Numeric context - direct C arithmetic (fast)
(add-method emit-c-operation <numeric-context>
  '(context op left right)
  '((cond
      ((= op '+) 
       (concat-string "LONG("
         (concat-string (emit-c-expr left context)
           (concat-string " + "
             (concat-string (emit-c-expr right context) ")")))))
      ((= op '-)
       (concat-string "LONG("
         (concat-string (emit-c-expr left context)
           (concat-string " - "
             (concat-string (emit-c-expr right context) ")")))))
      ((= op '>)
       (concat-string "("
         (concat-string (emit-c-expr left context)
           (concat-string " > "
             (concat-string (emit-c-expr right context)
               " ? s_true : nil)")))))
      (else "/* unknown numeric op */"))))

;; Object context - safe runtime dispatch
(add-method emit-c-operation <object-context>
  '(context op left right)
  '((cond
      ((= op '+)
       (concat-string "add("
         (concat-string (emit-c-expr left context)
           (concat-string ", "
             (concat-string (emit-c-expr right context) ")")))))
      ((= op '-)
       (concat-string "subtract("
         (concat-string (emit-c-expr left context)
           (concat-string ", "
             (concat-string (emit-c-expr right context) ")")))))
      ((= op '>)
       (concat-string "greater_than("
         (concat-string (emit-c-expr left context)
           (concat-string ", "
             (concat-string (emit-c-expr right context) ")")))))
      (else "/* unknown object op */"))))

;; Unknown context - conservative safe dispatch
(add-method emit-c-operation <unknown-context>
  '(context op left right)
  '((emit-c-operation (new <object-context>) op left right)))

;;; ================================================================
;;; EXPRESSION COMPILATION WITH CONTEXT (actual definition)
;;; ================================================================

(set emit-c-expr (lambda (expr context)
  "Compile expression in given type context"
  (cond
    ;; Numbers - context affects wrapping
    ((long? expr) 
     (if (= (type-of context) <numeric-context>)
         (long->string expr)              ; Raw number
         (concat-string "LONG(" (concat-string (long->string expr) ")"))))
    
    ;; Symbols
    ((symbol? expr)
     (if (= expr 'nil) "nil" (symbol->string expr)))
    
    ;; Lists - dispatch operation
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ;; Binary operations
         ((or (= op '+) (= op '-) (= op '*) (= op '>))
          (emit-c-operation context op (cadr expr) (caddr expr)))
         
         ;; Function calls
         (else
          (concat-string (symbol->string op) "(")))))
    
    (else "nil"))))

;;; ================================================================
;;; CONTEXT INFERENCE
;;; ================================================================

(define-function infer-numeric-context (expr)
  "Try to determine if expression is definitely numeric"
  (cond
    ((long? expr) 1)  ; Numbers are numeric
    ((symbol? expr) 0)  ; Variables unknown
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ;; Arithmetic always produces numbers
         ((or (= op '+) (= op '-) (= op '*)) 1)
         ;; Comparisons produce booleans (object context)
         ((or (= op '<) (= op '>) (= op '=)) 0)
         (else 0))))
    (else 0)))

(define-function choose-context (expr)
  "Choose optimal context for expression"
  (if (infer-numeric-context expr)
      (new <numeric-context>)
      (new <object-context>)))

;;; ================================================================
;;; HIGH-LEVEL COMPILATION
;;; ================================================================

(define-function compile-optimized (expr)
  "Compile with context-aware optimization"
  (let ((context (choose-context expr)))
    (emit-c-expr expr context)))

(define-function compile-safe (expr)
  "Compile with safe runtime dispatch"
  (emit-c-expr expr (new <object-context>)))

;;; ================================================================
;;; TESTS
;;; ================================================================

(println "=== MULTIMETHOD-BASED C GENERATION ===")
(println)

(println "Test expression: (+ 1 2)")
(println "Numeric context:  " (compile-optimized '(+ 1 2)))
(println "Safe context:     " (compile-safe '(+ 1 2)))
(println)

(println "Test expression: (> a b)")  
(println "Object context:   " (compile-optimized '(> a b)))
(println "Safe context:     " (compile-safe '(> a b)))
(println)

(println "=== GENERATED C COMPARISON ===")
(println)
(println "OPTIMIZED (numeric context):")
(println "  (+ 1 2)  =>  LONG(1 + 2)")
(println "  Fast direct arithmetic when types known")
(println)
(println "SAFE (object context):")  
(println "  (+ a b)  =>  add(a, b)")
(println "  Runtime dispatch with type checking")
(println)