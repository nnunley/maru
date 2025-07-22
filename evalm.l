;;; evalm.l - Interactive Multi-Method Evaluator
;;;
;;; A working demonstration of multi-method dispatch for evaluation,
;;; compiled into an interactive REPL you can play with.

(println "🚀 Multi-Method Evaluator Loading...")

;; Dispatch tables
(define *eval-methods* (array 32))
(define *print-methods* (array 32))

;; Type constants
(define MM-UNDEFINED 0)
(define MM-LONG 2)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)

;; Forward declaration
(define mm-eval ())
(define mm-print ())

;; Helper functions  
(define-function mm-register-eval-method (type-id method)
  (set-array-at *eval-methods* type-id method))

(define-function mm-register-print-method (type-id method)
  (set-array-at *print-methods* type-id method))

;; Evaluation methods
(define-function mm-eval-undefined (obj env) ())
(define-function mm-eval-number (obj env) obj)
(define-function mm-eval-string (obj env) obj)

(define-function mm-eval-symbol (obj env)
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
  (if (pair? obj)
      (let* ((fn-symbol (car obj))
             (args (cdr obj)))
        (cond
          ((= fn-symbol 'quote) (car args))
          ((= fn-symbol 'if)
           (let* ((condition (mm-eval (car args) env))
                  (then-form (car (cdr args)))
                  (else-form (car (cdr (cdr args)))))
             (if condition
                 (mm-eval then-form env)
                 (if else-form (mm-eval else-form env) ()))))
          (1 (let* ((fn (mm-eval fn-symbol env))
                    (evaluated-args (map (lambda (arg) (mm-eval arg env)) args)))
               (apply fn evaluated-args)))))
      obj))

;; Register methods
(mm-register-eval-method MM-UNDEFINED mm-eval-undefined)
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-SYMBOL mm-eval-symbol)
(mm-register-eval-method MM-PAIR mm-eval-pair)

;; Generic evaluator
(set mm-eval (lambda (obj env)
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (if method
        (method obj env)
        (error "No evaluation method for type:" type-id)))))

;; Print methods
(define-function mm-print-number (obj) (print obj))
(define-function mm-print-string (obj) (print "\"" obj "\""))
(define-function mm-print-symbol (obj) (print obj))

(define-function mm-print-pair (obj)
  (print "(")
  (let ((first 1))
    (while (pair? obj)
      (if (not first) (print " "))
      (set first ())
      (mm-print (car obj))
      (set obj (cdr obj)))
    (if obj (let () (print " . ") (mm-print obj))))
  (print ")"))

(define-function mm-print-default (obj) (print obj))

;; Register print methods
(mm-register-print-method MM-LONG mm-print-number)
(mm-register-print-method MM-STRING mm-print-string)
(mm-register-print-method MM-SYMBOL mm-print-symbol)
(mm-register-print-method MM-PAIR mm-print-pair)

;; Generic printer
(set mm-print (lambda (obj)
  (let* ((type-id (type-of obj))
         (method (array-at *print-methods* type-id)))
    (if method
        (method obj)
        (mm-print-default obj)))))

;; REPL
(define-function evalm-repl ()
  (println "\n🎯 Multi-Method Evaluator REPL")
  (println "=============================")
  (println "Interactive demonstration of multi-method dispatch")
  (println "")
  (println "Key Features:")
  (println "  • Type-based method dispatch (O(1) lookup)")
  (println "  • No switch statements - each type has its own method")
  (println "  • Extensible architecture following Open/Closed Principle")
  (println "")
  (println "Commands:")
  (println "  :help    - Show detailed help")
  (println "  :demo    - Run demonstration")
  (println "  :methods - Show dispatch tables")
  (println "  :explore - Maru introspection and reflection")
  (println "  :quit    - Exit")
  (println "")
  (println "Try these examples:")
  (println "  42           (self-evaluating number)")
  (println "  \"hello\"      (self-evaluating string)")  
  (println "  (+ 1 2 3)    (arithmetic)")
  (println "  (quote foo)  (quoted symbol)")
  (println "  (if 1 'a 'b) (conditional)")
  (println "")
  
  (let ((continue 1) (env ()))
    (while continue
      (print "evalm> ")
      (let ((input (read)))
        (cond
          ((= input ':quit)
           (set continue ())
           (println "\nGoodbye! Multi-method dispatch demonstrated! 🎉")
           (exit 0))
          
          ((= input ':help)
           (println "\n📚 Multi-Method Evaluator Help")
           (println "==============================")
           (println "")
           (println "This evaluator demonstrates multi-method dispatch:")
           (println "")
           (println "1. DISPATCH PROCESS:")
           (println "   • Determine input type (number, string, pair, symbol)")
           (println "   • Look up method in dispatch table O(1)")
           (println "   • Call type-specific method")
           (println "")
           (println "2. NO SWITCH STATEMENTS:")
           (println "   • Traditional: giant switch with all types")
           (println "   • Multi-method: each type has its own method")
           (println "   • Result: clean, extensible, maintainable")
           (println "")
           (println "3. SUPPORTED EXPRESSIONS:")
           (println "   • Numbers: 42, -17, 999")
           (println "   • Strings: \"hello\", \"world\"")
           (println "   • Symbols: foo, bar (with quote)")
           (println "   • Lists: (+ 1 2), (cons 'a 'b)")
           (println "   • Special: (quote x), (if c t e)")
           (println ""))
          
          ((= input ':demo)
           (println "\n🚀 Multi-Method Dispatch Demo")
           (println "=============================")
           (println "")
           (println "Evaluating different types:")
           (println "")
           
           ;; Demo each type
           (print "Number 42: ")
           (mm-print (mm-eval 42 env))
           (println " (dispatched to mm-eval-number)")
           
           (print "String \"test\": ")
           (mm-print (mm-eval "test" env))
           (println " (dispatched to mm-eval-string)")
           
           (print "Quote (quote hello): ")  
           (mm-print (mm-eval '(quote hello) env))
           (println " (dispatched to mm-eval-pair)")
           
           (print "Arithmetic (+ 5 3): ")
           (mm-print (mm-eval '(+ 5 3) env))
           (println " (dispatched to mm-eval-pair)")
           
           (println "")
           (println "Each type automatically routed to its specialized method!"))
          
          ((= input ':methods)
           (println "\n🔧 Dispatch Table Status")
           (println "========================")
           (println "")
           (println "Evaluation methods registered:")
           (println "  Type 0 (undefined): mm-eval-undefined")
           (println "  Type 2 (long):      mm-eval-number")
           (println "  Type 4 (string):    mm-eval-string")
           (println "  Type 5 (symbol):    mm-eval-symbol")
           (println "  Type 6 (pair):      mm-eval-pair")
           (println "")
           (println "Print methods registered:")
           (println "  Type 2 (long):      mm-print-number")
           (println "  Type 4 (string):    mm-print-string")
           (println "  Type 5 (symbol):    mm-print-symbol")
           (println "  Type 6 (pair):      mm-print-pair")
           (println "")
           (println "Performance: O(1) dispatch via array lookup")
           (println "Extensibility: Add new types without changing core"))
          
          ((= input ':explore)
           (println "\n🔍 Maru Introspection and Reflection Guide")
           (println "===========================================")
           (println "")
           (println "Maru provides powerful introspective capabilities:")
           (println "")
           (println "📋 TYPE INSPECTION:")
           (println "  (type-of obj)     - Get numeric type ID")
           (println "  (pair? obj)       - Test if object is a pair/list")
           (println "  (symbol? obj)     - Test if object is a symbol")
           (println "  (string? obj)     - Test if object is a string")
           (println "  (long? obj)       - Test if object is a number")
           (println "  (fixed? obj)      - Test if object is a built-in")
           (println "")
           (println "📊 TYPE CONSTANTS:")
           (println "  0=undefined, 1=indirect, 2=long, 3=double, 4=string,")
           (println "  5=symbol, 6=pair, 7=array, 8=subr, 9=expr, etc.")
           (println "")
           (println "🗂️  DATA STRUCTURE INSPECTION:")
           (println "  (car obj)         - Get first element of pair")
           (println "  (cdr obj)         - Get rest of pair")
           (println "  (cadr obj)        - Get second element (car of cdr)")
           (println "  (caddr obj)       - Get third element")
           (println "  (length obj)      - Get length of list/array")
           (println "  (array-at arr i)  - Get array element at index")
           (println "  (string-at s i)   - Get character at index")
           (println "")
           (println "🧠 EVALUATION AND ENVIRONMENTS:")
           (println "  (eval expr)       - Evaluate an expression")
           (println "  (expand expr)     - Macro-expand expression")
           (println "  (apply fn args)   - Apply function to arguments")
           (println "  (defined? sym)    - Check if symbol is defined")
           (println "")
           (println "🔧 FUNCTION INSPECTION:")
           (println "  (subr-name fn)    - Get name of built-in function")
           (println "  (address-of obj)  - Get memory address")
           (println "")
           (println "💾 MEMORY AND ALLOCATION:")
           (println "  (allocate type size) - Allocate memory")
           (println "  (oop-at obj i)    - Get object pointer at index")
           (println "  (set-oop-at obj i val) - Set object pointer")
           (println "")
           (println "🖨️  OUTPUT AND DEBUGGING:")
           (println "  (print obj)       - Print object")
           (println "  (dump obj)        - Debug dump of object")
           (println "  (warn msg)        - Print warning message")
           (println "  (format fmt ...)  - Formatted printing")
           (println "")
           (println "💡 EXPLORATION EXAMPLES:")
           (println "  Note: These functions work in full Maru REPL (./eval):")
           (println "  Try: (type-of (quote hello))    => 5 (symbol)")
           (println "  Try: (type-of \"hello\")          => 4 (string)")
           (println "  Try: (type-of 42)              => 2 (long)")
           (println "  Try: (dump (cons 'a 'b))       => Debug info")
           (println "  Try: (subr-name +)             => Function name")
           (println "")
           (println "  In this evalm demo, you can try:")
           (println "  42, \"hello\", (+ 1 2), (quote foo), (if 1 'a 'b)")
           (println "")
           (println "🎯 Multi-Method Context:")
           (println "  Our dispatch uses (type-of obj) for O(1) lookup")
           (println "  Each type ID maps to its evaluation method")
           (println "  This avoids expensive conditional chains")
           (println ""))
          
          (1
           ;; Evaluate and print result
           (print "=> ")
           (mm-print (mm-eval input env))
           (println)))))))

;; Info
(println "✅ Multi-method dispatch system initialized")
(let ((eval-count 0) (print-count 0))
  (array-do method *eval-methods*
    (if method (set eval-count (+ eval-count 1))))
  (array-do method *print-methods*
    (if method (set print-count (+ print-count 1))))
  (println "✅ Registered" eval-count "evaluation methods")
  (println "✅ Registered" print-count "print methods"))
(println "✅ Ready for interactive use!")
(println "")

;; Simple interactive detection:
;; Only start REPL if no additional files are being processed  
;; This mimics the original eval behavior without needing isatty
(println "🎯 Multi-method evaluator ready!")
(println "🎯 For interactive REPL, call: (evalm-repl)")