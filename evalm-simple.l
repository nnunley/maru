;;; evalm-simple.l - Simple Multi-Method Evaluator REPL
;;;
;;; This creates a working evalm binary that demonstrates multi-method 
;;; dispatch concepts in a form you can interact with immediately.

(println "🚀 Multi-Method Evaluator Loading...")

;; Multi-method dispatch tables
(define *eval-methods* (array 32))
(define *print-methods* (array 32))

;; Type constants for dispatch  
(define MM-UNDEFINED 0)
(define MM-LONG 2)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)

;; Helper functions
(define-function mm-register-eval-method (type-id method)
  "Register an evaluation method for a type"
  (set-array-at *eval-methods* type-id method))

(define-function mm-register-print-method (type-id method)  
  "Register a print method for a type"
  (set-array-at *print-methods* type-id method))

;; Multi-method evaluation functions
(define-function mm-eval-undefined (obj env)
  "Undefined values evaluate to themselves"
  ())

(define-function mm-eval-number (obj env)
  "Numbers are self-evaluating"  
  obj)

(define-function mm-eval-string (obj env)
  "Strings are self-evaluating"
  obj)

(define-function mm-eval-symbol (obj env)
  "Look up symbols in environment"
  (cond
    ((= obj 't) 't)
    ((= obj 'nil) ())
    ((= obj '+) +)
    ((= obj '-) -)
    ((= obj '*) *)
    ((= obj 'cons) cons)
    ((= obj 'car) car)
    ((= obj 'cdr) cdr)
    ((= obj 'list) list)
    (1 (error "Undefined symbol:" obj))))

(define-function mm-eval-pair (obj env)
  "Evaluate function applications"
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
           (println "Let not implemented in this demo")
           ())
          
          ;; Function application
          (1
           (let* ((fn (mm-eval fn-symbol env))
                  (evaluated-args (map (lambda (arg) (mm-eval arg env)) args)))
             (apply fn evaluated-args)))))
      obj))

;; Register evaluation methods in dispatch table
(mm-register-eval-method MM-UNDEFINED mm-eval-undefined)
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-SYMBOL mm-eval-symbol)
(mm-register-eval-method MM-PAIR mm-eval-pair)

;; Generic multi-method evaluator
(define-function mm-eval (obj env)
  "Multi-method evaluator using dispatch table"
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (if method
        (method obj env)
        (error "No evaluation method for type:" type-id))))

;; Print methods for nice output
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

(define-function mm-print-default (obj)
  (print obj))

;; Register print methods
(mm-register-print-method MM-LONG mm-print-number)
(mm-register-print-method MM-STRING mm-print-string)
(mm-register-print-method MM-SYMBOL mm-print-symbol)
(mm-register-print-method MM-PAIR mm-print-pair)

;; Generic multi-method printer
(define-function mm-print (obj)
  "Multi-method printer using dispatch table"
  (let* ((type-id (type-of obj))
         (method (array-at *print-methods* type-id)))
    (if method
        (method obj)
        (mm-print-default obj))))

;; Main REPL
(define-function evalm-repl ()
  "Multi-Method Evaluator REPL - Interactive Demo"
  (println "\n🎯 Multi-Method Evaluator REPL")
  (println "=============================")
  (println "Demonstrates multi-method dispatch for evaluation and printing")
  (println "")
  (println "Features:")
  (println "  • Type-based method dispatch (no switch statements!)")
  (println "  • O(1) method lookup via dispatch tables")
  (println "  • Extensible architecture")
  (println "")
  (println "Commands:")
  (println "  :help     - Show help")
  (println "  :methods  - Show registered methods")
  (println "  :extend   - Demo adding new types")
  (println "  :quit     - Exit")
  (println "")
  (println "Examples:")
  (println "  42")
  (println "  \"hello\"")
  (println "  (+ 1 2 3)")
  (println "  (quote (a b c))")
  (println "  (if 1 'yes 'no)")
  (println "")
  
  (let ((continue 1)
        (env ()))
    (while continue
      (print "evalm> ")
      (let ((input (read)))
        (cond
          ((= input ':quit)
           (set continue ())
           (println "Goodbye! Multi-method dispatch demonstrated! 🎉"))
          
          ((= input ':help)
           (println "Multi-Method Evaluator Help")
           (println "===========================")
           (println "")
           (println "This evaluator uses multi-method dispatch:")
           (println "  1. Input type is determined (long, string, pair, etc.)")
           (println "  2. Appropriate method is looked up in dispatch table")
           (println "  3. Method is called with the object")
           (println "")
           (println "No switch statements! Each type has its own method.")
           (println "")
           (println "Supported expressions:")
           (println "  Numbers: 42, -5, 1000")
           (println "  Strings: \"hello\", \"world\"")
           (println "  Quotes: (quote foo), (quote (a b c))")  
           (println "  Arithmetic: (+ 1 2), (* 3 4)")
           (println "  Lists: (cons 1 2), (car '(a b))")
           (println "  Conditionals: (if condition then else)")
           (println ""))
          
          ((= input ':methods)
           (println "Registered Multi-Method Dispatch Tables")
           (println "======================================")
           (println "")
           (println "Evaluation methods:")
           (let ((count 0))
             (array-do i *eval-methods*
               (if i (set count (+ count 1))))
             (println "  " count " methods registered"))
           (println "  Type 0 (undefined): mm-eval-undefined")
           (println "  Type 2 (long): mm-eval-number")
           (println "  Type 4 (string): mm-eval-string")
           (println "  Type 5 (symbol): mm-eval-symbol")
           (println "  Type 6 (pair): mm-eval-pair")
           (println "")
           (println "Print methods:")
           (let ((count 0))
             (array-do i *print-methods*
               (if i (set count (+ count 1))))
             (println "  " count " methods registered"))
           (println "  Dispatch: O(1) array lookup")
           (println ""))
          
          ((= input ':extend)
           (println "Multi-Method Extensibility Demo")
           (println "===============================")
           (println "")
           (println "Adding a new 'vector' type without changing core evaluator:")
           (println "")
           
           ;; Demo adding a new type
           (define MM-VECTOR 20)
           (define-function mm-eval-vector (obj env)
             (list 'vector-with (length obj) 'elements))
           (mm-register-eval-method MM-VECTOR mm-eval-vector)
           
           (println "✓ Registered MM-VECTOR type (id: 20)")
           (println "✓ Added mm-eval-vector method")
           (println "✓ No changes to core evaluator needed!")
           (println "✓ Follows Open/Closed Principle")
           (println "")
           (println "This is the power of multi-method dispatch!"))
          
          (1
           ;; Evaluate the expression
           (print "=> ")
           (let ((result (mm-eval input env)))
             (mm-print result)
             (println))))))))

;; Statistics and info
(define-function show-evalm-info ()
  "Show information about the multi-method evaluator"
  (println "\n📊 Multi-Method Evaluator Statistics")
  (println "====================================")
  (println "Dispatch Tables:")
  (let ((eval-count 0)
        (print-count 0))
    (array-do method *eval-methods*
      (if method (set eval-count (+ eval-count 1))))
    (array-do method *print-methods*  
      (if method (set print-count (+ print-count 1))))
    (println "  Eval methods:  " eval-count)
    (println "  Print methods: " print-count))
  (println "")
  (println "Performance:")
  (println "  Dispatch time: O(1)")
  (println "  Memory usage: O(types)")
  (println "  Extensibility: Perfect")
  (println "")
  (println "Architecture Benefits:")
  (println "  ✓ No giant switch statements")
  (println "  ✓ Easy to add new types")
  (println "  ✓ Methods stay with their types")
  (println "  ✓ Clean separation of concerns")
  (println ""))

;; Initialize
(println "✅ Multi-method dispatch tables initialized")
(println "✅ Evaluation and printing methods registered")
(println "✅ Ready for interactive use!")
(println "")
(show-evalm-info)
(println "Type (evalm-repl) to start the REPL!")
(println "")

;; Auto-start the REPL
(evalm-repl)