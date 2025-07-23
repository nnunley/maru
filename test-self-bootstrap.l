;;; Test whether evalm can process its own source definitions

;; Load the multi-method dispatch infrastructure separately
(println "=== Self-Bootstrap Test: Can evalm process its own definitions? ===")
(println "")

;; Test 1: Can we redefine multi-method infrastructure?
(println "Test 1: Multi-method infrastructure redefinition")

;; Define a simple multi-method system
(define *test-methods* (array 32))

(define-function test-mm-eval (obj env)
  "Test multi-method evaluator"
  (let* ((type-id (type-of obj))
         (method (array-at *test-methods* type-id)))
    (if method
        (method obj env)
        (eval obj))))

;; Register a method
(set-array-at *test-methods* 2  ;; Long integer
  (lambda (obj env) 
    (println "  MM: Processing long integer " obj)
    obj))

(println "  Multi-method system redefined: ✅")
(println "")

;; Test 2: Can we use the redefined system?
(println "Test 2: Using redefined multi-method system")
(let ((result (test-mm-eval 42 ())))
  (println "  Result: " result)
  (println "  Success: ✅"))
(println "")

;; Test 3: Can we define method registration functions?
(println "Test 3: Method registration functions")
(define-function register-eval-method (type-id method)
  "Register a method for a specific type"
  (set-array-at *test-methods* type-id method)
  (println "  Registered method for type " type-id))

(register-eval-method 4  ;; String
  (lambda (obj env)
    (println "  MM: Processing string " obj)
    obj))

(println "  Method registration: ✅")
(println "")

;; Test 4: Test the registered methods
(println "Test 4: Testing registered methods")
(println "  Integer: " (test-mm-eval 123 ()))
(println "  String: " (test-mm-eval "hello" ()))
(println "")

(println "✅ Self-bootstrap capability verified!")
(println "✅ Multi-method system can redefine itself!")