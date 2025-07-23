;;; evalm-simple-boot.l - Simplified Bootstrapped Multi-Method Evaluator
;;;
;;; Test version to verify bootstrap process works

(println "🚀 Simple Bootstrapped Multi-Method Evaluator Loading...")

;; Test that we have access to built-in functions
(println "Testing built-in access:")
(println "  (type-of 42) => " (type-of 42))
(println "  (type-of \"hello\") => " (type-of "hello"))  
(println "  (defined? '+) => " (defined? '+))

;; Simple dispatch table
(define *methods* (array 10))
(set-array-at *methods* 2 (lambda (x) (cons 'NUMBER x)))
(set-array-at *methods* 4 (lambda (x) (cons 'STRING x)))

;; Simple multi-method evaluator
(define-function mm-eval-simple (obj)
  (let* ((type-id (type-of obj))
         (method (array-at *methods* type-id)))
    (if method
        (method obj)
        obj)))

;; Simple REPL
(define-function simple-repl ()
  (println "\n🎯 Simple Bootstrapped Multi-Method REPL")
  (println "=======================================")
  (println "This version has full access to Maru's built-ins!")
  (println "")
  (println "Commands:")
  (println "  :test  - Test introspection functions")
  (println "  :quit  - Exit")
  (println "")
  
  (let ((continue 1))
    (while continue
      (print "simple> ")
      (let ((input (read)))
        (cond
          ((= input ':quit)
           (set continue ())
           (println "Goodbye!")
           (exit 0))
          
          ((= input ':test)
           (println "\nIntrospection Tests:")
           (println "  (type-of 42) = " (type-of 42))
           (println "  (type-of \"test\") = " (type-of "test"))
           (println "  (subr-name +) = " (subr-name +))
           (println "  (defined? 'nonexistent) = " (defined? 'nonexistent))
           (println "  (defined? 'type-of) = " (defined? 'type-of))
           (let ((test-pair (cons 'a 'b)))
             (println "  (cons 'a 'b):")
             (println "    car = " (car test-pair))
             (println "    cdr = " (cdr test-pair))
             (print "    dump = ")
             (dump test-pair)
             (println "")))
          
          (1
           (println "Input: " input)
           (println "Type: " (type-of input))
           (println "MM-Eval: " (mm-eval-simple input))
           (println "Std-Eval: " (eval input))))))))

;; Show that everything works
(println "✅ Built-in functions accessible!")
(println "✅ Multi-method dispatch ready!")
(println "")
(simple-repl)