;;; test-eval-k-demo.l - Demonstration of eval.k core concepts
;;;
;;; This demonstrates how eval.k would work if compiled through IR

(println "\n=== eval.k Core Evaluation Demo ===\n")

;; Type constants
(define MARU-UNDEFINED  0)
(define MARU-LONG       2)
(define MARU-STRING     4)
(define MARU-SYMBOL     5)
(define MARU-PAIR       6)
(define MARU-VARIABLE   13)
(define MARU-ENV        14)
(define MARU-EXPR       9)
(define MARU-FIXED      11)

;; Universal value structure
(define-structure <maru-value> (tag data))

;; Helper to create values
(define-function make-value (tag data)
  (let ((v (new <maru-value>)))
    (set (<maru-value>-tag v) tag)
    (set (<maru-value>-data v) data)
    v))

;; Type checking
(define-function value-type (obj)
  (if obj
      (if (and (long? obj) (& obj 1))  ; Tagged integer
          MARU-LONG
        (<maru-value>-tag obj))
    MARU-UNDEFINED))

;; Environment structure
(define-structure <maru-env> (bindings parent))

(define-function make-env (parent)
  (let ((env (new <maru-env>)))
    (set (<maru-env>-bindings env) ())
    (set (<maru-env>-parent env) parent)
    env))

;; Variable structure
(define-structure <maru-var> (name value))

;; Environment lookup
(define-function env-lookup (env name)
  (if env
      (let ((binding (assq name (<maru-env>-bindings env))))
        (if binding
            (<maru-var>-value (cdr binding))
          (env-lookup (<maru-env>-parent env) name)))
    ()))

;; Environment define
(define-function env-define (env name value)
  (let ((var (new <maru-var>)))
    (set (<maru-var>-name var) name)
    (set (<maru-var>-value var) value)
    (set (<maru-env>-bindings env) 
         (cons (cons name var) (<maru-env>-bindings env)))
    var))

;; Simple evaluator
(define-function maru-eval (exp env)
  (let ((type (value-type exp)))
    (cond
      ;; Self-evaluating
      ((= type MARU-UNDEFINED) exp)
      ((= type MARU-LONG) exp)
      ((= type MARU-STRING) exp)
      
      ;; Symbol lookup
      ((= type MARU-SYMBOL)
       (let ((name (<maru-value>-data exp)))
         (println "  Looking up: " name)
         (env-lookup env name)))
      
      ;; Pair - function application
      ((= type MARU-PAIR)
       (let* ((pair (<maru-value>-data exp))
              (fn (car pair))
              (args (cdr pair)))
         (println "  Applying: " (if (= (value-type fn) MARU-SYMBOL)
                                    (<maru-value>-data fn)
                                  "<function>"))
         ;; Simplified application
         (if (= (value-type fn) MARU-SYMBOL)
             (let ((name (<maru-value>-data fn)))
               (cond
                 ((= name '+) 
                  (let ((a (maru-eval (car args) env))
                        (b (maru-eval (cadr args) env)))
                    (+ a b)))
                 ((= name 'quote)
                  (car args))
                 (else
                  (println "    Unknown function: " name)
                  ())))
           ())))
      
      ;; Default
      (else exp))))

;; Create test environment
(println "1. Creating environment:")
(define test-env (make-env ()))
(env-define test-env 'x 42)
(env-define test-env 'y 8)
(println "   Defined x = 42, y = 8")

;; Test 1: Variable lookup
(println "\n2. Variable lookup test:")
(let ((sym-x (make-value MARU-SYMBOL 'x)))
  (println "   Result: " (maru-eval sym-x test-env)))

;; Test 2: Self-evaluating
(println "\n3. Self-evaluating test:")
(println "   Number 123: " (maru-eval 123 test-env))
(println "   String: " (maru-eval (make-value MARU-STRING "hello") test-env))

;; Test 3: Simple application
(println "\n4. Function application test:")
(let* ((plus (make-value MARU-SYMBOL '+))
       (x (make-value MARU-SYMBOL 'x))
       (y (make-value MARU-SYMBOL 'y))
       (expr (make-value MARU-PAIR (list plus x y))))
  (println "   (+ x y) = " (maru-eval expr test-env)))

;; Test 4: Quote
(println "\n5. Quote test:")
(let* ((quote-sym (make-value MARU-SYMBOL 'quote))
       (hello (make-value MARU-SYMBOL 'hello))
       (expr (make-value MARU-PAIR (list quote-sym hello))))
  (let ((result (maru-eval expr test-env)))
    (println "   (quote hello) = " 
             (if (= (value-type result) MARU-SYMBOL)
                 (<maru-value>-data result)
               result))))

(println "\n=== Demo complete ===\n")

;; Summary
(println "This demonstrates how eval.k would:")
(println "- Use a universal value type for all Maru values")
(println "- Implement type checking and dispatch")
(println "- Handle environments and variable lookup")
(println "- Evaluate expressions including function application")
(println "- All while using static types that compile through IR")