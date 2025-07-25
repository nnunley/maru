;;; evalm-with-ports.l - Multi-Method Evaluator with Port Streams
;;;
;;; Enhanced version of evalm-simple.l that uses port streams for output
;;; instead of direct print calls, providing better formatted output control.

(println "🚀 Multi-Method Evaluator with Port Streams Loading...")

;; Load port streams infrastructure
(load "lib/stream/port.l")
(load "lib/pretty-print.l")

;; Multi-method dispatch tables
(define *eval-methods* (array 32))
(define *print-methods* (array 32))

;; Type constants for dispatch  
(define MM-UNDEFINED 0)
(define MM-LONG 2)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)

;; Helper functions for method registration
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
  "Numbers evaluate to themselves"
  obj)

(define-function mm-eval-string (obj env)
  "Strings evaluate to themselves"
  obj)

(define-function mm-eval-symbol (obj env)
  "Symbols look themselves up in the environment"
  (let ((binding (assq obj env)))
    (if binding 
        (cdr binding)
        (let ()
          (println "Warning: undefined symbol " obj)
          obj))))

(define-function mm-eval-pair (obj env)
  "Pairs are function applications"
  (if (pair? obj)
      (let ((fn (mm-eval (car obj) env))
            (args (map (lambda (arg) (mm-eval arg env)) (cdr obj))))
        (if (procedure? fn)
            (apply fn args)
            (let ()
              (println "Error: not a function " fn)
              ())))
      obj))

;; Enhanced print methods using port streams
(define-function mm-print-number-to-port (obj port)
  "Print number to port stream"
  (port-write port (long->string obj)))

(define-function mm-print-string-to-port (obj port)
  "Print string to port stream with quotes"
  (port-write port "\"" obj "\""))

(define-function mm-print-symbol-to-port (obj port)
  "Print symbol to port stream"
  (port-write port (symbol->string obj)))

(define-function mm-print-pair-to-port (obj port)
  "Print pair to port stream with proper formatting"
  (port-write port "(")
  (mm-print-to-port (car obj) port)
  (let ((rest (cdr obj)))
    (while (pair? rest)
      (port-write port " ")
      (mm-print-to-port (car rest) port)
      (set rest (cdr rest)))
    (if rest
        (let ()
          (port-write port " . ")
          (mm-print-to-port rest port))))
  (port-write port ")"))

(define-function mm-print-default-to-port (obj port)
  "Default print method to port stream"
  (port-write port "<object:type" (long->string (type-of obj)) ">"))

;; Port-based print methods (for backward compatibility)
(define-function mm-print-number (obj)
  "Print number using console port"
  (let ((port (console-port)))
    (mm-print-number-to-port obj port)))

(define-function mm-print-string (obj)
  "Print string using console port"
  (let ((port (console-port)))
    (mm-print-string-to-port obj port)))

(define-function mm-print-symbol (obj)
  "Print symbol using console port"
  (let ((port (console-port)))
    (mm-print-symbol-to-port obj port)))

(define-function mm-print-pair (obj)
  "Print pair using console port"
  (let ((port (console-port)))
    (mm-print-pair-to-port obj port)))

(define-function mm-print-default (obj)
  "Default print using console port"
  (let ((port (console-port)))
    (mm-print-default-to-port obj port)))

;; Register print methods
(mm-register-print-method MM-LONG mm-print-number)
(mm-register-print-method MM-STRING mm-print-string)
(mm-register-print-method MM-SYMBOL mm-print-symbol)
(mm-register-print-method MM-PAIR mm-print-pair)

;; Register eval methods  
(mm-register-eval-method MM-UNDEFINED mm-eval-undefined)
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-SYMBOL mm-eval-symbol)
(mm-register-eval-method MM-PAIR mm-eval-pair)

;; Core dispatch functions
(define-function mm-eval (obj env)
  "Multi-method evaluation dispatcher"
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (if method
        (method obj env)
        (mm-eval-undefined obj env))))

(define-function mm-print (obj)
  "Multi-method print dispatcher"
  (let* ((type-id (type-of obj))
         (method (array-at *print-methods* type-id)))
    (if method
        (method obj)
        (mm-print-default obj))))

;; Enhanced port-based functions
(define-function mm-print-to-port (obj port)
  "Multi-method print to specific port"
  (let* ((type-id (type-of obj))
         (method (array-at *print-methods* type-id)))
    (cond
      ((= type-id MM-LONG) (mm-print-number-to-port obj port))
      ((= type-id MM-STRING) (mm-print-string-to-port obj port))
      ((= type-id MM-SYMBOL) (mm-print-symbol-to-port obj port))
      ((= type-id MM-PAIR) (mm-print-pair-to-port obj port))
      (else (mm-print-default-to-port obj port)))))

(define-function mm-print-to-string (obj)
  "Print object to string using string port"
  (let ((port (string-port)))
    (mm-print-to-port obj port)
    (port-contents port)))

(define-function mm-pretty-print (obj)
  "Pretty print object using port streams"
  (pretty-print obj))

(define-function mm-pretty-print-to-string (obj)
  "Pretty print object to string"
  (pretty-string obj))

;; Enhanced REPL with port streams
(define-function evalm-repl ()
  "Multi-method evaluator REPL with port stream integration"
  (let ((env '((+ . +) (- . +) (* . +) (/ . /) 
               (quote . quote) (car . car) (cdr . cdr) (cons . cons)
               (list . list) (print . print) (println . println))))
    
    (println "\n🎯 Multi-Method Evaluator with Port Streams")
    (println "Enhanced with formatted output and pretty printing!")
    (println)
    (println "Features:")
    (println "  • Multi-method dispatch for evaluation and printing") 
    (println "  • Port streams for formatted output")
    (println "  • String port support for capturing output")
    (println "  • Pretty printing integration")
    (println "  • Type-based method dispatch (no switch statements!)")
    (println)
    (println "Commands:")
    (println "  :help     - Show this help")
    (println "  :methods  - Show registered methods")
    (println "  :ports    - Demonstrate port stream features")
    (println "  :pretty   - Demonstrate pretty printing")
    (println "  :quit     - Exit evaluator")
    (println)
    
    (let ((running t))
      (while running
        (print "evalm-ports> ")
        (let ((input (read)))
          (cond
            ((= input ':quit)
             (set running ())
             (println "Goodbye! Port streams + multi-methods demonstrated! 🎉"))
            
            ((= input ':help)
             (println)
             (println "This evaluator demonstrates multi-method dispatch with port streams:")
             (println "  1. Expression is evaluated using type-specific methods")
             (println "  2. Result is printed using port stream methods")
             (println "  3. Output can be directed to string or console ports")
             (println)
             (println "Port streams provide formatted output control!")
             (println "Multi-methods eliminate switch statements!"))
            
            ((= input ':methods)
             (let ((eval-count 0)
                   (print-count 0))
               (println)
               (println "Evaluation methods:")
               (array-do method *eval-methods*
                 (if method (set eval-count (+ eval-count 1))))
               (println "  " eval-count " methods registered")
               
               (println "Print methods:")
               (array-do method *print-methods*
                 (if method (set print-count (+ print-count 1))))
               (println "  " print-count " methods registered")
               (println)))
            
            ((= input ':ports)
             (println)
             (println "🔌 Port Streams Demonstration:")
             (println)
             
             ;; String port demo
             (let ((test-expr '(+ 2 3)))
               (println "1. Evaluating: " test-expr)
               (let ((result (mm-eval test-expr env)))
                 (println "   Result: " result)
                 
                 ;; Print to string port
                 (let ((string-output (mm-print-to-string result)))
                   (println "   As string: '" string-output "'"))
                 
                 ;; Print to console port
                 (print "   To console: ")
                 (mm-print result)
                 (println)))
             
             ;; Complex structure demo
             (let ((complex-data '(list with (nested structures) and 42 "strings")))
               (println)
               (println "2. Complex structure: " complex-data)
               (print "   Formatted: ")
               (mm-print complex-data)
               (println)
               (println "   As string: '" (mm-print-to-string complex-data) "'"))
             
             (println)
             (println "✨ Port streams provide flexible output control!"))
            
            ((= input ':pretty)
             (println)
             (println "🎨 Pretty Printing Demonstration:")
             (println)
             
             (let ((nested-data '(deeply (nested (structure with) many) levels and (parallel branches))))
               (println "Original data:")
               (mm-print nested-data)
               (println)
               (println)
               (println "Pretty printed:")
               (mm-pretty-print nested-data)
               (println)
               (println "Pretty printed to string:")
               (let ((pretty-string (mm-pretty-print-to-string nested-data)))
                 (println "'" pretty-string "'")))
             
             (println)
             (println "✨ Pretty printing uses port streams for formatting!"))
            
            (else
             (println)
             (let ((result (mm-eval input env)))
               (print "=> ")
               (mm-print result)
               (println))))))
    
    ;; Show final statistics
    (let ((eval-count 0)
          (print-count 0))
      (array-do method *eval-methods*
        (if method (set eval-count (+ eval-count 1))))
      (array-do method *print-methods*  
        (if method (set print-count (+ print-count 1))))
      (println)
      (println "Final method counts:")
      (println "  Eval methods:  " eval-count)
      (println "  Print methods: " print-count)
      (println "  Port streams: integrated ✅"))))

;; Initialize the system
(println "✅ Multi-method dispatch tables initialized")
(println "✅ Evaluation and printing methods registered")
(println "✅ Port streams integration complete")
(println "✅ Ready for enhanced multi-method evaluation!")
(println)

;; Start the REPL if run directly
(evalm-repl)