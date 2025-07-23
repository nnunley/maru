;;; evalm-bootstrapped.l - Properly Bootstrapped Multi-Method Evaluator
;;;
;;; This version goes through the proper Maru bootstrap process to have
;;; access to the full environment, just like other evaluators.

(println "🚀 Multi-Method Evaluator Loading (Bootstrapped)...")

;; First, load the bootstrap environment
(println "Loading bootstrap environment...")
(load "core/bootstrap/boot.l")
(println "✅ Bootstrap loaded")

;; Optionally load extended bootstrap
;; (load "core/bootstrap/boot2.l") 
;; (println "✅ Extended bootstrap loaded")

;; Now we have access to the full Maru environment!
;; Let's create our multi-method dispatch system on top of it

;; Dispatch tables
(define *eval-methods* (array 32))
(define *print-methods* (array 32))

;; Type constants (these should match Maru's internal type system)
(define MM-UNDEFINED 0)
(define MM-LONG 2)
(define MM-STRING 4)  
(define MM-SYMBOL 5)
(define MM-PAIR 6)
(define MM-ARRAY 7)
(define MM-SUBR 8)

;; Forward declarations
(define mm-eval ())
(define mm-print ())

;; Helper functions for method registration
(define-function mm-register-eval-method (type-id method)
  "Register an evaluation method for a specific type"
  (set-array-at *eval-methods* type-id method))

(define-function mm-register-print-method (type-id method)
  "Register a print method for a specific type"
  (set-array-at *print-methods* type-id method))

;; Enhanced evaluation methods with full environment access
(define-function mm-eval-undefined (obj env)
  "Handle undefined values"
  ())

(define-function mm-eval-number (obj env)
  "Numbers are self-evaluating"
  obj)

(define-function mm-eval-string (obj env)
  "Strings are self-evaluating"
  obj)

(define-function mm-eval-symbol (obj env)
  "Look up symbols in the environment - now with full bootstrap!"
  ;; Instead of hardcoded symbols, we can actually look them up
  ;; in the proper Maru environment
  (if (defined? obj)
      (eval obj)
      (error "Undefined symbol:" obj)))

(define-function mm-eval-array (obj env)
  "Arrays are self-evaluating"
  obj)

(define-function mm-eval-subr (obj env) 
  "Built-in functions are self-evaluating"
  obj)

(define-function mm-eval-pair (obj env)
  "Evaluate function applications with full environment"
  (if (pair? obj)
      (let* ((fn-symbol (car obj))
             (args (cdr obj)))
        (cond
          ;; Special forms
          ((= fn-symbol 'quote)
           (car args))
          
          ((= fn-symbol 'if)
           (let* ((condition (mm-eval (car args) env))
                  (then-form (car (cdr args)))
                  (else-form (car (cdr (cdr args)))))
             (if condition
                 (mm-eval then-form env)
                 (if else-form (mm-eval else-form env) ()))))
          
          ((= fn-symbol 'let)
           ;; We could implement let here, or delegate to standard eval
           (eval obj))
          
          ((= fn-symbol 'define)
           ;; Delegate complex forms to standard evaluator
           (eval obj))
          
          ;; Function application - now with full access to all functions!
          (1
           (let* ((fn (mm-eval fn-symbol env))
                  (evaluated-args (map (lambda (arg) (mm-eval arg env)) args)))
             (apply fn evaluated-args)))))
      obj))

;; Register evaluation methods
(mm-register-eval-method MM-UNDEFINED mm-eval-undefined)
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-SYMBOL mm-eval-symbol)
(mm-register-eval-method MM-PAIR mm-eval-pair)
(mm-register-eval-method MM-ARRAY mm-eval-array)
(mm-register-eval-method MM-SUBR mm-eval-subr)

;; Generic multi-method evaluator
(set mm-eval (lambda (obj env)
  "Multi-method evaluator with full environment access"
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (if method
        (method obj env)
        ;; Fallback to standard evaluator for unknown types
        (eval obj)))))

;; Enhanced print methods that can use full environment
(define-function mm-print-number (obj)
  (print obj))

(define-function mm-print-string (obj)
  (print "\"" obj "\""))

(define-function mm-print-symbol (obj)
  (print obj))

(define-function mm-print-pair (obj)
  (print "(")
  (let ((first 1))
    (while (pair? obj)
      (if (not first) (print " "))
      (set first ())
      (mm-print (car obj))
      (set obj (cdr obj)))
    (if obj
        (let ()
          (print " . ")
          (mm-print obj))))
  (print ")"))

(define-function mm-print-array (obj)
  (print "#(")
  (let ((len (length obj)))
    (for (i 0 len)
      (if (> i 0) (print " "))
      (mm-print (array-at obj i))))
  (print ")"))

(define-function mm-print-subr (obj)
  (print "#<subr " (subr-name obj) ">"))

(define-function mm-print-default (obj)
  ;; Use Maru's built-in print for unknown types
  (print obj))

;; Register print methods
(mm-register-print-method MM-LONG mm-print-number)
(mm-register-print-method MM-STRING mm-print-string)
(mm-register-print-method MM-SYMBOL mm-print-symbol)
(mm-register-print-method MM-PAIR mm-print-pair)
(mm-register-print-method MM-ARRAY mm-print-array)
(mm-register-print-method MM-SUBR mm-print-subr)

;; Generic multi-method printer
(set mm-print (lambda (obj)
  "Multi-method printer with full environment support"
  (let* ((type-id (type-of obj))
         (method (array-at *print-methods* type-id)))
    (if method
        (method obj)
        (mm-print-default obj)))))

;; Enhanced REPL with full environment access
(define-function evalm-repl-bootstrapped ()
  "Multi-Method Evaluator REPL - Fully Bootstrapped"
  (println "\n🎯 Multi-Method Evaluator REPL (Bootstrapped)")
  (println "============================================")
  (println "Full Maru environment loaded - all functions available!")
  (println "")
  (println "Key Features:")
  (println "  • Full access to Maru's built-in functions")
  (println "  • Multi-method dispatch for evaluation and printing")
  (println "  • O(1) method lookup via dispatch tables")
  (println "  • Proper bootstrap environment integration")
  (println "")
  (println "Commands:")
  (println "  :help     - Show help")
  (println "  :demo     - Demonstrate multi-method dispatch")
  (println "  :methods  - Show dispatch tables")
  (println "  :explore  - Test introspection functions")
  (println "  :compare  - Compare with standard evaluator")
  (println "  :quit     - Exit")
  (println "")
  (println "Now you can use ALL Maru functions:")
  (println "  (type-of obj), (dump obj), (defined? sym)")
  (println "  (subr-name fn), (address-of obj), etc.")
  (println "")
  
  (let ((continue 1)
        (env ()))  ; We could build a proper environment here
    (while continue
      (print "evalm-boot> ")
      (let ((input (read)))
        (cond
          ((= input ':quit)
           (set continue ())
           (println "\nGoodbye from bootstrapped Multi-Method Evaluator! 🎉")
           (exit 0))
          
          ((= input ':help)
           (println "\nBootstrapped Multi-Method Evaluator Help")
           (println "=======================================")
           (println "")
           (println "This evaluator has been properly bootstrapped with boot.l,")
           (println "giving it access to the full Maru environment.")
           (println "")
           (println "Multi-method dispatch works by:")
           (println "  1. Getting the type of the input object")
           (println "  2. Looking up the method in the dispatch table")
           (println "  3. Calling the appropriate method")
           (println "")
           (println "Available functions include all Maru built-ins:")
           (println "  type-of, dump, defined?, subr-name, address-of,")
           (println "  print, warn, format, car, cdr, cons, pair?,")
           (println "  array-at, set-array-at, length, eval, apply, etc.")
           (println ""))
          
          ((= input ':demo)
           (println "\nBootstrapped Multi-Method Demo")
           (println "=============================")
           (println "")
           
           ;; Demo with real introspection
           (let ((test-cases (list 
                              42 
                              "hello" 
                              'symbol
                              '(+ 1 2)
                              (array 1 2 3))))
             (list-do test-case test-cases
               (println "Testing: " test-case)
               (println "  Type ID: " (type-of test-case))
               (print "  MM-Eval result: ")
               (mm-print (mm-eval test-case env))
               (println "")
               (print "  Standard eval result: ")
               (print (eval test-case))
               (println "")
               (println ""))))
          
          ((= input ':methods)
           (println "\nDispatch Table Status")
           (println "====================")
           (let ((eval-count 0)
                 (print-count 0))
             (array-do method *eval-methods*
               (if method (set eval-count (+ eval-count 1))))
             (array-do method *print-methods*
               (if method (set print-count (+ print-count 1))))
             (println "Evaluation methods: " eval-count)
             (println "Print methods: " print-count))
           (println "")
           (println "Registered types:")
           (println "  0 (undefined), 2 (long), 4 (string)")
           (println "  5 (symbol), 6 (pair), 7 (array), 8 (subr)")
           (println ""))
          
          ((= input ':explore)
           (println "\nIntrospection Function Tests")
           (println "===========================")
           (println "Now these work because we're bootstrapped!")
           (println "")
           
           ;; Test various introspection functions
           (println "Type inspection:")
           (println "  (type-of 42) => " (type-of 42))
           (println "  (type-of \"hello\") => " (type-of "hello"))
           (println "  (type-of 'symbol) => " (type-of 'symbol))
           (println "  (type-of (cons 1 2)) => " (type-of (cons 1 2)))
           (println "")
           
           (println "Function inspection:")
           (println "  (subr-name +) => " (subr-name +))
           (println "  (defined? 'undefined-sym) => " (defined? 'undefined-sym))
           (println "  (defined? '+) => " (defined? '+))
           (println "")
           
           (println "Structure inspection:")
           (let ((test-pair (cons 'a 'b)))
             (println "  (cons 'a 'b) creates:")
             (println "    (car (cons 'a 'b)) => " (car test-pair))
             (println "    (cdr (cons 'a 'b)) => " (cdr test-pair))
             (print "    (dump (cons 'a 'b)) => ")
             (dump test-pair)
             (println "")))
          
          ((= input ':compare)
           (println "\nMulti-Method vs Standard Evaluation Comparison")
           (println "=============================================")
           (let ((test-expr '(+ (* 2 3) 4)))
             (println "Test expression: " test-expr)
             (print "Multi-method result: ")
             (mm-print (mm-eval test-expr env))
             (println "")
             (print "Standard result: ")
             (print (eval test-expr))
             (println "")
             (println "Both should produce the same result!")
             (println "")))
          
          (1
           ;; Evaluate the expression using multi-method dispatch
           (print "=> ")
           (let ((result (mm-eval input env)))
             (mm-print result)
             (println)))))))

;; Initialize
(println "✅ Multi-method dispatch system with full bootstrap initialized")
(println "✅ All Maru built-in functions are now available")
(println "✅ Ready for fully-featured interactive use!")
(println "")
(println "🎯 Type (evalm-repl-bootstrapped) to start the enhanced REPL")
(println "")

;; Auto-start
(evalm-repl-bootstrapped)