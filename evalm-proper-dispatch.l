;;; evalm-proper-dispatch.l - Evaluator with Proper Multiple Dispatch
;;;
;;; This demonstrates the REAL intent of port streams - multiple dispatch for different data types
;;; integrated with an evaluator, not just I/O redirection.

(println "🚀 Multi-Method Evaluator with Proper Port Dispatch System")
(println "==========================================================")

;; Load Maru's multiple dispatch infrastructure
(load "lib/stream/port.l")
(load "lib/pretty-print.l")

(println "✅ Maru's multiple dispatch system loaded")

;; Create evaluation dispatch tables (like before)
(define *eval-methods* (array 32))

;; Type constants
(define MM-UNDEFINED 0)
(define MM-LONG 2)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)

;; Forward declaration
(define mm-eval)

;; Method registration
(define-function mm-register-eval-method (type-id method)
  (set-array-at *eval-methods* type-id method))

;; Simple evaluation methods
(define-function mm-eval-undefined (obj env) ())
(define-function mm-eval-number (obj env) obj)
(define-function mm-eval-string (obj env) obj)
(define-function mm-eval-symbol (obj env)
  (let ((binding (assq obj env)))
    (if binding (cdr binding) obj)))
(define-function mm-eval-pair (obj env)
  (if (pair? obj)
      (let ((fn-name (car obj)))
        (cond
          ((= fn-name 'quote) (cadr obj))
          (else
           (let ((fn (mm-eval fn-name env))
                 (args (map (lambda (arg) (mm-eval arg env)) (cdr obj))))
             (apply fn args)))))
      obj))

;; Register eval methods
(mm-register-eval-method MM-UNDEFINED mm-eval-undefined)
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-SYMBOL mm-eval-symbol)
(mm-register-eval-method MM-PAIR mm-eval-pair)

;; Main evaluator using dispatch table
(set mm-eval
     (lambda (obj env)
       (let* ((type-id (type-of obj))
              (method (array-at *eval-methods* type-id)))
         (if method
             (method obj env)
             (mm-eval-undefined obj env)))))

(println "✅ Multi-method evaluator ready")

;; ================================================================
;; THE KEY INSIGHT: Use Maru's EXISTING multiple dispatch system!
;; ================================================================

;; Instead of creating custom print methods, we can EXTEND Maru's existing 
;; do-pretty system to handle evaluation results specially

;; Define a new result type for evaluation results
(define-structure <eval-result> (expression result environment))

;; Create constructor
(define-function make-eval-result (expr result env)
  (new <eval-result> expr result env))

;; Add a custom do-pretty method for eval results using Maru's dispatch system
(define-method do-pretty <eval-result> (port col)
  (port-write port "=> ")
  (do-pretty self.result port col)
  (port-write port " ")
  (port-write port "(from: ")
  (do-pretty self.expression port col)
  (port-write port ")"))

(println "✅ Custom evaluation result type with multiple dispatch ready")

;; ================================================================
;; DEMONSTRATION
;; ================================================================

(define-function demo-proper-dispatch ()
  (println "\n🎯 Proper Multiple Dispatch Demo")
  (println "================================")
  
  ;; Test environment
  (define test-env '((x . 10) (y . 20) (+ . +) (- . -) (* . *)))
  
  ;; Test expressions
  (define test-exprs '(42 "hello" 'x (+ x y) (list 1 2 3)))
  
  (println "\n1. Standard evaluation results:")
  (list-do expr test-exprs
    (let ((result (mm-eval expr test-env)))
      (print "   " expr " => ")
      (print result)
      (println)))
  
  (println "\n2. Using Maru's multiple dispatch for formatting:")
  (list-do expr test-exprs
    (let ((result (mm-eval expr test-env)))
      (print "   ")
      (pretty-print expr)
      (print "   => ")
      (pretty-print result)))
  
  (println "\n3. Custom eval-result type with multiple dispatch:")
  (list-do expr test-exprs
    (let* ((result (mm-eval expr test-env))
           (eval-result (make-eval-result expr result test-env)))
      (print "   ")
      (do-pretty eval-result (console-port) 0)
      (println)))
  
  (println "\n4. Output control via port abstraction:")
  (println "   To console:")
  (let ((expr '(* x y))
        (result (mm-eval '(* x y) test-env))
        (eval-result (make-eval-result '(* x y) (mm-eval '(* x y) test-env) test-env)))
    (print "     ")
    (do-pretty eval-result (console-port) 0)
    (println))
  
  (println "   Captured to string:")
  (let ((port (string-port))
        (expr '(* x y))
        (result (mm-eval '(* x y) test-env))
        (eval-result (make-eval-result '(* x y) (mm-eval '(* x y) test-env) test-env)))
    (do-pretty eval-result port 0)
    (println "     '" (port-contents port) "'"))
  
  (println "\n5. The Power of Multiple Dispatch:")
  (println "   • Each type (long, string, symbol, pair, eval-result) has its own method")
  (println "   • No switch statements - automatic dispatch based on type")
  (println "   • Port abstraction handles output destination")
  (println "   • Easy to extend with new types and methods")
  (println "   • Follows Maru's object-oriented design patterns")
  
  (println "\n✨ This is the REAL intent of 'port streams' in Maru!")
  (println "✨ Multiple dispatch + Port abstraction = Flexible, extensible output system!"))

;; Run the demonstration
(demo-proper-dispatch)

(println "\n🎉 Proper Multiple Dispatch Integration Complete!")