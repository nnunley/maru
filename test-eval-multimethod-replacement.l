;;; Test replacing eval with multi-method version

(println "=== Replacing eval with Multi-Method Version ===")
(println "")

;; Save original eval
(define original-eval eval)

;; Create a multi-method eval replacement
(define *custom-eval-methods* (array 32))

;; Helper to register custom eval methods
(define-function register-custom-eval (type-id method)
  (set-array-at *custom-eval-methods* type-id method)
  (println "Registered custom eval method for type " type-id))

;; Multi-method eval implementation
(define multi-method-eval
  (lambda (expr)
    (let* ((type-id (type-of expr))
           (method (array-at *custom-eval-methods* type-id)))
      (if method
          ;; Use our custom method
          (method expr)
          ;; Fall back to original eval
          (original-eval expr)))))

;; Register some custom methods
(println "Registering custom evaluation methods...")

;; Custom method for long integers (type 2) - add debugging
(register-custom-eval 2
  (lambda (expr)
    (println "  [MULTI-METHOD] Evaluating integer: " expr)
    expr))  ;; Integers evaluate to themselves

;; Custom method for strings (type 4) - add debugging  
(register-custom-eval 4
  (lambda (expr)
    (println "  [MULTI-METHOD] Evaluating string: " expr)
    expr))  ;; Strings evaluate to themselves

;; Custom method for symbols (type 5) - lookup with debugging
(register-custom-eval 5
  (lambda (expr)
    (println "  [MULTI-METHOD] Looking up symbol: " expr)
    (original-eval expr)))  ;; Delegate symbol lookup

(println "")

;; Replace eval with our multi-method version
(define eval multi-method-eval)
(println "✅ eval replaced with multi-method version!")
(println "")

;; Test the new eval
(println "Testing multi-method eval:")
(println "")

(println "Test 1: Integer evaluation")
(println "  (eval 42) => " (eval 42))
(println "")

(println "Test 2: String evaluation")  
(println "  (eval \"hello\") => " (eval "hello"))
(println "")

(println "Test 3: Symbol evaluation")
(println "  (eval '+) => " (eval '+))
(println "")

(println "Test 4: Expression evaluation (falls back)")
(println "  (eval '(+ 1 2)) => " (eval '(+ 1 2)))
(println "")

(println "✅ Multi-method eval replacement successful!")
(println "✅ We have successfully redefined eval with multi-method dispatch!")