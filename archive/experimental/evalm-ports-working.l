;;; evalm-ports-working.l - Working Multi-Method Evaluator with Port Streams
;;;
;;; Properly organized to avoid forward reference issues

(println "🚀 Multi-Method Evaluator with Port Streams")

;; Load port streams infrastructure
(load "lib/stream/port.l")
(load "lib/pretty-print.l")

;; Multi-method dispatch tables
(define *eval-methods* (array 32))
(define *print-methods* (array 32))

;; Type constants matching Maru's internal type system
(define MM-UNDEFINED 0)
(define MM-LONG 2)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)

;; Method registration functions
(define-function mm-register-eval-method (type-id method)
  "Register an evaluation method for a specific type"
  (set-array-at *eval-methods* type-id method))

(define-function mm-register-print-method (type-id method)  
  "Register a print method for a specific type"
  (set-array-at *print-methods* type-id method))

;; =================================================================
;; FORWARD DECLARATIONS (to resolve circular dependencies)
;; =================================================================

(define mm-eval)
(define mm-print-to-port)

;; =================================================================
;; EVALUATION METHODS (Multi-method dispatch for evaluation)
;; =================================================================

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
  "Symbols look themselves up in the environment"
  (let ((binding (assq obj env)))
    (if binding 
        (cdr binding)
        (let ()
          (println "Warning: undefined symbol " obj)
          obj))))

(define-function mm-eval-pair (obj env)
  "Pairs are function applications or special forms"
  (if (pair? obj)
      (let ((fn-name (car obj)))
        ;; Handle special forms
        (cond
          ((= fn-name 'quote)
           (cadr obj))
          (else
           ;; Regular function application - try to apply
           (let ((fn (mm-eval fn-name env))
                 (args (map (lambda (arg) (mm-eval arg env)) (cdr obj))))
             (apply fn args)))))
      obj))

;; =================================================================
;; PORT-BASED PRINTING METHODS
;; =================================================================

(define-function mm-print-number-to-port (obj port)
  "Print number to port"
  (port-write port (long->string obj)))

(define-function mm-print-string-to-port (obj port)
  "Print string to port with quotes"
  (port-write port "\"" obj "\""))

(define-function mm-print-symbol-to-port (obj port)
  "Print symbol to port"
  (port-write port (symbol->string obj)))

(define-function mm-print-pair-to-port (obj port)
  "Print pair to port with proper list formatting"
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

;; =================================================================
;; CONSOLE PRINTING METHODS
;; =================================================================

(define-function mm-print-number (obj)
  "Print number to console"
  (let ((port (console-port)))
    (mm-print-number-to-port obj port)))

(define-function mm-print-string (obj)
  "Print string to console"
  (let ((port (console-port)))
    (mm-print-string-to-port obj port)))

(define-function mm-print-symbol (obj)
  "Print symbol to console"
  (let ((port (console-port)))
    (mm-print-symbol-to-port obj port)))

(define-function mm-print-pair (obj)
  "Print pair to console"
  (let ((port (console-port)))
    (mm-print-pair-to-port obj port)))

(define-function mm-print-default (obj)
  "Default print method"
  (let ((port (console-port)))
    (port-write port "<object:type-" (long->string (type-of obj)) ">")))

;; =================================================================
;; MAIN DISPATCH FUNCTIONS (defined after methods)
;; =================================================================

(set mm-eval
     (lambda (obj env)
       "Multi-method evaluation dispatcher"
       (let* ((type-id (type-of obj))
              (method (array-at *eval-methods* type-id)))
         (if method
             (method obj env)
             (mm-eval-undefined obj env)))))

(set mm-print-to-port
     (lambda (obj port)
       "Multi-method print dispatcher for port streams"
       (let ((type-id (type-of obj)))
         (cond
           ((= type-id MM-LONG) (mm-print-number-to-port obj port))
           ((= type-id MM-STRING) (mm-print-string-to-port obj port))
           ((= type-id MM-SYMBOL) (mm-print-symbol-to-port obj port))
           ((= type-id MM-PAIR) (mm-print-pair-to-port obj port))
           (else (port-write port "<object:type-" (long->string type-id) ">"))))))

(define-function mm-print (obj)
  "Multi-method print dispatcher (to console)"
  (let* ((type-id (type-of obj))
         (method (array-at *print-methods* type-id)))
    (if method
        (method obj)
        (mm-print-default obj))))

;; =================================================================
;; PORT STREAM UTILITY FUNCTIONS
;; =================================================================

(define-function mm-print-to-string (obj)
  "Print object to string using string port"
  (let ((port (string-port)))
    (mm-print-to-port obj port)
    (port-contents port)))

(define-function mm-eval-and-print (expr env)
  "Evaluate expression and print result"
  (let ((result (mm-eval expr env)))
    (print "=> ")
    (mm-print result)
    (println)
    result))

(define-function mm-eval-and-print-to-string (expr env)
  "Evaluate expression and return result as string"
  (let* ((result (mm-eval expr env))
         (output (mm-print-to-string result)))
    (concat-string "=> " output)))

;; =================================================================
;; METHOD REGISTRATION
;; =================================================================

;; Register evaluation methods
(mm-register-eval-method MM-UNDEFINED mm-eval-undefined)
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-SYMBOL mm-eval-symbol)
(mm-register-eval-method MM-PAIR mm-eval-pair)

;; Register print methods
(mm-register-print-method MM-LONG mm-print-number)
(mm-register-print-method MM-STRING mm-print-string)
(mm-register-print-method MM-SYMBOL mm-print-symbol)
(mm-register-print-method MM-PAIR mm-print-pair)

;; =================================================================
;; DEMONSTRATION
;; =================================================================

(define-function demo-evalm-ports ()
  "Demonstrate evalm with port streams"
  (println "\n🎯 Multi-Method Evaluator with Port Streams Demo")
  (println "==================================================")
  
  ;; Create test environment
  (define test-env '((x . 10) (y . 20) (+ . +) (- . -) (* . *) 
                     (quote . quote) (list . list)))
  
  ;; Test 1: Basic evaluation
  (println "\n1. Basic Evaluation:")
  (let ((test-exprs '(42 "hello" 'world (+ 2 3) (list 1 2 3))))
    (map (lambda (expr)
           (let ((result (mm-eval expr test-env)))
             (println "   " expr " => " (mm-print-to-string result))))
         test-exprs))
  
  ;; Test 2: Port stream features
  (println "\n2. Port Stream Features:")
  (let ((result (mm-eval '(* 6 7) test-env)))
    (println "   Result: " result)
    (println "   To string: '" (mm-print-to-string result) "'")
    (print "   To console: ")
    (mm-print result)
    (println))
  
  ;; Test 3: Complex structures
  (println "\n3. Complex Structures:")
  (let ((nested '(a (b c) d)))
    (println "   Nested: " nested)
    (println "   Via port: '" (mm-print-to-string nested) "'")
    (println "   Pretty printed:")
    (pretty-print nested))
  
  ;; Test 4: Statistics
  (println "\n4. Method Statistics:")
  (let ((eval-count 0) (print-count 0))
    (array-do method *eval-methods*
      (if method (set eval-count (+ eval-count 1))))
    (array-do method *print-methods*
      (if method (set print-count (+ print-count 1))))
    (println "   Eval methods:  " eval-count)
    (println "   Print methods: " print-count)
    (println "   Port streams:  ✅"))
  
  (println "\n✨ Port streams provide flexible output control!")
  (println))

;; Initialize and run
(println "✅ Multi-method dispatch tables initialized")
(println "✅ Methods registered")
(println "✅ Port streams integrated")

(demo-evalm-ports)

(println "🎉 EVALM WITH PORT STREAMS COMPLETE!")