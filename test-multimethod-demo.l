;;; test-multimethod-demo.l - Demonstrate multi-method concepts

(println "\n=== Multi-Method Design in eval-multimethod.k ===")

;; Since we can't directly compile .k files, let's demonstrate
;; the concepts using Maru's existing features

;; 1. Show how selectors work (single dispatch)
(println "\n1. Single-dispatch with selectors:")

(define-selector describe)
(add-method describe <long> '(self) '((list "Number: " self)))
(add-method describe <string> '(self) '((list "String: " self)))
(add-method describe <pair> '(self) '((list "List with " (length self) " elements")))

(println (describe 42))
(println (describe "hello"))
(println (describe '(a b c)))

;; 2. Show method dispatch
(println "\n2. Method dispatch demonstration:")

(define-structure <evaluator> (type-table))

(define-function make-evaluator ()
  (let ((eval-table (array 32)))  ; Array indexed by type
    ;; Register evaluators for each type
    (array-at eval-table 2 (lambda (exp ctx) exp))  ; LONG - self eval
    (array-at eval-table 4 (lambda (exp ctx) exp))  ; STRING - self eval
    (array-at eval-table 6 (lambda (exp ctx)        ; PAIR - application
                            ;; simplified - real one would eval and apply
                            (list 'applying (car exp))))
    (new <evaluator> eval-table)))

(define-function test-eval (evaluator exp)
  (let* ((type (type-of exp))
         (eval-fn (array-at (<evaluator>-type-table evaluator) type)))
    (if eval-fn
        (eval-fn exp ())
        (list 'no-evaluator-for type))))

(let ((my-eval (make-evaluator)))
  (println "\n   Dispatching based on type:")
  (println (list "   42 => " (test-eval my-eval 42)))
  (println (list "   \"hello\" => " (test-eval my-eval "hello")))
  (println (list "   '(+ 1 2) => " (test-eval my-eval '(+ 1 2)))))

;; 3. Show the design pattern
(println "\n3. The eval-multimethod.k design pattern:")
(println "   Instead of:")
(println "     (cond")
(println "       ((= type MARU-LONG) ...)")
(println "       ((= type MARU-STRING) ...)")
(println "       ((= type MARU-PAIR) ...))")
(println)
(println "   We have:")
(println "     (define-method maru-eval <maru-long> ((ctx ...)) ...)")
(println "     (define-method maru-eval <maru-string> ((ctx ...)) ...)")
(println "     (define-method maru-eval <maru-pair> ((ctx ...)) ...)")

;; 4. Benefits
(println "\n4. Benefits of multi-method design:")
(println "   - Each type's behavior is defined with the type")
(println "   - Adding new types doesn't require modifying dispatcher")
(println "   - Methods can be organized by operation (eval, apply, print)")
(println "   - Follows single responsibility principle")
(println "   - Clean, readable, maintainable code")

;; 5. Compilation
(println "\n5. When compiled through the .k infrastructure:")
(println "   - Methods compile to functions")
(println "   - Generic dispatch compiles to indexed table lookup")
(println "   - Type checking happens at compile time where possible")
(println "   - Result is efficient C code with clean structure")

(println "\n=== Multi-method demonstration complete! ===\n")