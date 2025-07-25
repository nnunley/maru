;;; Test redefining eval within evalm

(println "=== Testing eval Redefinition in Multi-Method Evaluator ===")
(println "")

;; Test 1: Check current eval function
(println "Test 1: Current eval function")
(println "  eval defined? " (defined? 'eval))
(println "  eval type: " (type-of eval))
(if (defined? 'subr-name)
    (println "  eval name: " (subr-name eval))
    (println "  subr-name not available"))
(println "")

;; Test 2: Can we save the original eval?
(println "Test 2: Saving original eval")
(define original-eval eval)
(println "  Original eval saved: ✅")
(println "  Original type: " (type-of original-eval))
(println "")

;; Test 3: Can we redefine eval?
(println "Test 3: Redefining eval")
(define eval-call-count 0)

(define new-eval
  (lambda (expr)
    (set eval-call-count (+ eval-call-count 1))
    (println "  [NEW EVAL #" eval-call-count "] Evaluating: " expr)
    ;; Call the original eval to actually do the work
    (original-eval expr)))

;; Try to redefine eval
(define eval new-eval)
(println "  eval redefined: ✅")
(println "  New eval type: " (type-of eval))
(println "")

;; Test 4: Test the redefined eval
(println "Test 4: Testing redefined eval")
(println "  Testing (+ 1 2):")
(let ((result (eval '(+ 1 2))))
  (println "  Result: " result)
  (println "  Call count: " eval-call-count))
(println "")

;; Test 5: Test nested evaluation
(println "Test 5: Testing nested evaluation")
(println "  Testing (eval '(* 3 4)):")
(let ((result (eval '(eval '(* 3 4)))))
  (println "  Result: " result)
  (println "  Call count: " eval-call-count))
(println "")

(println "✅ eval redefinition test completed!")
(println "✅ Calls intercepted: " eval-call-count)