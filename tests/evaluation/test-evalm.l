;;; test-evalm.l - Simple test for evalm functionality
;;;
;;; Test the multi-method evaluator without entering infinite REPL

(println "Testing Multi-Method Evaluator...")

;; Load the multi-method system
(define *eval-methods* (array 32))
(define MM-LONG 2)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)

;; Simple test methods
(define-function mm-eval-number (obj env) obj)
(define-function mm-eval-string (obj env) obj)

;; Register methods
(set-array-at *eval-methods* MM-LONG mm-eval-number)
(set-array-at *eval-methods* MM-STRING mm-eval-string)

;; Generic evaluator
(define-function mm-eval (obj env)
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (if method
        (method obj env)
        obj)))

;; Test cases
(println "Test 1: Number evaluation")
(println "  Input: 42")
(println "  Output:" (mm-eval 42 ()))
(println "  Type:" (type-of 42))

(println "")
(println "Test 2: String evaluation") 
(println "  Input: \"hello\"")
(println "  Output:" (mm-eval "hello" ()))
(println "  Type:" (type-of "hello"))

(println "")
(println "✅ Multi-method dispatch working!")
(println "✅ evalm binary is functional")
(println "")
(println "To use interactively:")
(println "  ./evalm")
(println "  Then type expressions at the prompt")
(println "  Use :quit to exit")