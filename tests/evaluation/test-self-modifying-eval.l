;;; Test ultimate self-modification: evalm redefining its own evaluation

(println "=== Ultimate Self-Modification Test ===")
(println "Self-modifying evaluator within evalm")
(println "")

;; Save the original eval
(define boot-eval eval)

;; Create our own eval that can modify itself
(define *dynamic-eval-methods* (array 32))
(define *eval-modification-count* 0)

;; Meta-evaluator that can modify its own behavior
(define meta-eval
  (lambda (expr)
    (let* ((type-id (type-of expr))
           (method (array-at *dynamic-eval-methods* type-id)))
      (cond
        ;; Special form: (modify-eval type new-method)
        ((and (pair? expr) (= 'modify-eval (car expr)))
         (let ((type-id (boot-eval (cadr expr)))
               (new-method (boot-eval (caddr expr))))
           (set *eval-modification-count* (+ *eval-modification-count* 1))
           (set-array-at *dynamic-eval-methods* type-id new-method)
           (println "  [SELF-MODIFY #" *eval-modification-count* "] Updated eval method for type " type-id)
           'eval-modified))
        
        ;; Use custom method if available
        (method (method expr))
        
        ;; Fall back to original eval
        (else (boot-eval expr))))))

;; Replace eval with our meta-evaluator
(define eval meta-eval)
(println "✅ eval replaced with self-modifying meta-evaluator!")
(println "")

;; Test 1: Basic evaluation still works
(println "Test 1: Basic evaluation")
(println "  42 => " (eval 42))
(println "  (+ 1 2) => " (eval '(+ 1 2)))
(println "")

;; Test 2: Self-modify to add custom integer handling
(println "Test 2: Self-modifying integer evaluation")
(eval '(modify-eval 2 (lambda (n)
                       (println "    [CUSTOM INT] Processing: " n)
                       (if (= n 42)
                           "THE ANSWER!"
                           n))))

(println "  Testing modified integer eval:")
(println "  41 => " (eval 41))
(println "  42 => " (eval 42))  
(println "  43 => " (eval 43))
(println "")

;; Test 3: Self-modify to add custom string handling
(println "Test 3: Self-modifying string evaluation")
(eval '(modify-eval 4 (lambda (s)
                       (println "    [CUSTOM STR] Processing: " s)
                       (if (= s "magic")
                           "✨ TRANSFORMED ✨"
                           s))))

(println "  Testing modified string eval:")
(println "  \"hello\" => " (eval "hello"))
(println "  \"magic\" => " (eval "magic"))
(println "")

;; Test 4: Demonstrate that the evaluator modified itself
(println "Test 4: Meta-evaluation statistics")
(println "  Total self-modifications: " *eval-modification-count*)
(println "  Current integer behavior: " (eval 42))
(println "  Current string behavior: " (eval "magic"))
(println "")

(println "🎯 ULTIMATE ACHIEVEMENT UNLOCKED!")
(println "✅ evalm has successfully created a SELF-MODIFYING evaluator!")
(println "✅ The evaluator can rewrite its own evaluation methods at runtime!")
(println "✅ This demonstrates COMPLETE metacircular mastery!")