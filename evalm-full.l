;;; evalm-full.l - Full-Featured Multi-Method Evaluator
;;;
;;; Multi-method evaluator with complete access to Maru's environment.
;;; No explicit bootstrap needed - Maru already provides full access!

(println "🚀 Full Multi-Method Evaluator Loading...")

;; Dispatch tables
(define *eval-methods* (array 32))
(define *print-methods* (array 32))

;; Type constants (match Maru's internal types)
(define MM-UNDEFINED 0)
(define MM-INDIRECT 1) 
(define MM-LONG 2)
(define MM-DOUBLE 3)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)
(define MM-ARRAY 7)
(define MM-SUBR 8)
(define MM-EXPR 9)

;; Forward declarations
(define mm-eval ())
(define mm-print ())

;; Method registration helpers
(define-function mm-register-eval-method (type-id method)
  (set-array-at *eval-methods* type-id method))

(define-function mm-register-print-method (type-id method)
  (set-array-at *print-methods* type-id method))

;; Enhanced evaluation methods with full environment
(define-function mm-eval-undefined (obj env)
  ())

(define-function mm-eval-number (obj env)
  obj)

(define-function mm-eval-string (obj env)
  obj)

(define-function mm-eval-symbol (obj env)
  "Symbol lookup with full environment access"
  (if (defined? obj)
      (eval obj)
      (error "Undefined symbol:" obj)))

(define-function mm-eval-pair (obj env)
  "Function application with full environment"
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
          
          ;; For complex forms, delegate to standard evaluator
          ((or (= fn-symbol 'let)
               (= fn-symbol 'define) 
               (= fn-symbol 'lambda)
               (= fn-symbol 'set))
           (eval obj))
          
          ;; Function application
          (1
           (let* ((fn (mm-eval fn-symbol env))
                  (evaluated-args (map (lambda (arg) (mm-eval arg env)) args)))
             (apply fn evaluated-args)))))
      obj))

(define-function mm-eval-array (obj env)
  obj)

(define-function mm-eval-subr (obj env)
  obj)

(define-function mm-eval-expr (obj env)
  obj)

;; Register evaluation methods
(mm-register-eval-method MM-UNDEFINED mm-eval-undefined)
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-SYMBOL mm-eval-symbol)
(mm-register-eval-method MM-PAIR mm-eval-pair)
(mm-register-eval-method MM-ARRAY mm-eval-array)
(mm-register-eval-method MM-SUBR mm-eval-subr)
(mm-register-eval-method MM-EXPR mm-eval-expr)

;; Generic multi-method evaluator
(set mm-eval (lambda (obj env)
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (if method
        (method obj env)
        (eval obj))))) ; Fallback to standard evaluator

;; Enhanced print methods
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
  (print "#<subr:" (subr-name obj) ">"))

(define-function mm-print-expr (obj)
  (print "#<expr>"))

;; Register print methods
(mm-register-print-method MM-LONG mm-print-number)
(mm-register-print-method MM-STRING mm-print-string)
(mm-register-print-method MM-SYMBOL mm-print-symbol)
(mm-register-print-method MM-PAIR mm-print-pair)
(mm-register-print-method MM-ARRAY mm-print-array)
(mm-register-print-method MM-SUBR mm-print-subr)
(mm-register-print-method MM-EXPR mm-print-expr)

;; Generic printer
(set mm-print (lambda (obj)
  (let* ((type-id (type-of obj))
         (method (array-at *print-methods* type-id)))
    (if method
        (method obj)
        (print obj)))))

;; Full-featured REPL
(define-function evalm-full-repl ()
  (println "\n🎯 Full Multi-Method Evaluator REPL")
  (println "===================================")
  (println "Complete Maru environment with multi-method dispatch!")
  (println "")
  (println "Features:")
  (println "  • All Maru built-in functions available")
  (println "  • Multi-method dispatch for evaluation")
  (println "  • O(1) method lookup")
  (println "  • Fallback to standard evaluator for complex forms")
  (println "")
  (println "Commands:")
  (println "  :help      - Show help")
  (println "  :demo      - Multi-method demonstration")  
  (println "  :methods   - Show dispatch tables")
  (println "  :introspect - Test all introspection functions")
  (println "  :compare   - Compare MM vs standard evaluation")
  (println "  :types     - Show Maru type system")
  (println "  :quit      - Exit")
  (println "")
  
  (let ((continue 1)
        (env ()))
    (while continue
      (print "full> ")
      (let ((input (read)))
        (cond
          ((= input ':quit)
           (set continue ())
           (println "Goodbye from Full Multi-Method Evaluator! 🎉")
           (exit 0))
          
          ((= input ':help)
           (println "\nFull Multi-Method Evaluator Help")
           (println "===============================")
           (println "")
           (println "This evaluator demonstrates multi-method dispatch while")
           (println "providing full access to Maru's complete environment.")
           (println "")
           (println "Multi-method dispatch process:")
           (println "  1. Get type ID of input object")
           (println "  2. Look up method in dispatch table O(1)")
           (println "  3. Call type-specific method")
           (println "  4. Fallback to standard eval for unknown types")
           (println "")
           (println "All Maru functions work: type-of, dump, defined?, etc.")
           (println ""))
          
          ((= input ':demo)
           (println "\nFull Multi-Method Dispatch Demo")
           (println "==============================")
           (println "")
           
           (let ((test-cases (list 
                              42 
                              3.14
                              "hello world"
                              'quoted-symbol
                              '(+ 2 3)
                              (array 1 2 3)
                              +)))  ; the + function itself
             (list-do test-case test-cases
               (println "Input: " test-case)
               (println "  Type ID: " (type-of test-case))
               (print "  MM Result: ")
               (mm-print (mm-eval test-case env))
               (println "")
               (print "  Std Result: ")
               (print (eval test-case))
               (println "")
               (println ""))
             (println "All results should match!")))
          
          ((= input ':methods)
           (println "\nDispatch Table Status")
           (println "====================")
           (let ((eval-count 0)
                 (print-count 0))
             (array-do method *eval-methods*
               (if method (set eval-count (+ eval-count 1))))
             (array-do method *print-methods*
               (if method (set print-count (+ print-count 1))))
             (println "Evaluation methods registered: " eval-count)
             (println "Print methods registered: " print-count))
           (println "")
           (println "Type mappings:")
           (println "  0=undefined, 1=indirect, 2=long, 3=double")
           (println "  4=string, 5=symbol, 6=pair, 7=array") 
           (println "  8=subr, 9=expr, etc."))
          
          ((= input ':introspect)
           (println "\nComplete Introspection Test Suite")
           (println "================================")
           (println "")
           
           (println "🔍 TYPE INSPECTION:")
           (let ((test-objects (list 42 3.14 "test" 'symbol (cons 1 2) (array 1 2))))
             (list-do obj test-objects
               (println "  " obj " => type " (type-of obj))))
           (println "")
           
           (println "🧪 PREDICATE FUNCTIONS:")
           (println "  (pair? (cons 1 2)) => " (pair? (cons 1 2)))
           (println "  (symbol? 'test) => " (symbol? 'test))  
           (println "  (string? \"hello\") => " (string? "hello"))
           (println "  (fixed? +) => " (fixed? +))
           (println "")
           
           (println "🔧 FUNCTION INSPECTION:")
           (println "  (subr-name +) => " (subr-name +))
           (println "  (subr-name type-of) => " (subr-name type-of))
           (println "  (defined? 'nonexistent) => " (defined? 'nonexistent))
           (println "  (defined? 'type-of) => " (defined? 'type-of))
           (println "")
           
           (println "📊 DATA STRUCTURE ANALYSIS:")
           (let ((test-pair (cons 'first 'second))
                 (test-list '(a b c d))
                 (test-array (array 'x 'y 'z)))
             (println "  Pair: " test-pair)
             (println "    (car ...) => " (car test-pair))
             (println "    (cdr ...) => " (cdr test-pair))
             (println "  List: " test-list)  
             (println "    Note: length() works on arrays, not lists")
             (println "    (cadr ...) => " (cadr test-list))
             (println "  Array: " test-array)
             (println "    (length ...) => " (length test-array))
             (println "    (array-at ... 1) => " (array-at test-array 1)))
           (println "")
           
           (println "🖨️ DEBUG OUTPUT:")
           (let ((complex-obj (cons (array 1 2) (cons 'nested 'structure))))
             (print "  (dump complex-obj) => ")
             (dump complex-obj)
             (println "")))
          
          ((= input ':compare)  
           (println "\nMulti-Method vs Standard Evaluator")
           (println "=================================")
           (let ((test-exprs '(42 
                              "test"
                              (+ 1 2 3)
                              (cons 'a 'b)
                              (if 1 'true 'false))))
             (list-do expr test-exprs
               (println "Expression: " expr)
               (print "  MM: ")
               (mm-print (mm-eval expr env))
               (println "")
               (print "  Std: ")
               (print (eval expr))
               (println "")
               (println ""))))
          
          ((= input ':types)
           (println "\nMaru Type System Overview")
           (println "========================")
           (println "")
           (println "Core types and their IDs:")
           (let ((examples (list 
                           (list () "undefined/nil" 0)
                           (list 42 "long integer" 2) 
                           (list 3.14 "double float" 3)
                           (list "text" "string" 4)
                           (list 'symbol "symbol" 5)
                           (list '(a b) "pair/cons" 6)
                           (list (array 1 2) "array" 7)
                           (list + "built-in function" 8))))
             (list-do example examples
               (let ((obj (car example))
                     (desc (car (cdr example)))
                     (expected-type (car (cdr (cdr example)))))
                 (print "  ")
                 (print obj)
                 (print " (")  
                 (print desc)
                 (print ") => ")
                 (println (type-of obj)))))
           (println "")
           (println "This type system enables O(1) dispatch!"))
          
          (1
           ;; Evaluate using multi-method dispatch
           (print "=> ")
           (let ((result (mm-eval input env)))
             (mm-print result)
             (println))))))))

;; Initialize and show status
(println "✅ Full multi-method dispatch system initialized")
(let ((eval-registered 0)
      (print-registered 0))
  (array-do method *eval-methods*
    (if method (set eval-registered (+ eval-registered 1))))
  (array-do method *print-methods*
    (if method (set print-registered (+ print-registered 1))))
  (println "✅ " eval-registered " evaluation methods registered")
  (println "✅ " print-registered " print methods registered"))
(println "✅ All Maru built-in functions accessible!")
(println "")

;; Simple interactive detection: 
;; Only start REPL if no additional files are being processed
;; This mimics the original eval behavior without needing isatty
(println "🎯 Multi-method evaluator ready!")
(println "🎯 For interactive REPL, call: (evalm-full-repl)")