;;; test-environment-stack.l - Essential Environment Stack Tests

;; Load the multi-method evaluator with environment stack
(load "evalm.l")

(println "=== Environment Stack Essential Tests ===")

;; Test 1: Basic environment operations
(println "Test 1: Basic Operations")
(let* ((env (create-env () 0 0)))
  (env-define env 'x 42)
  (let ((var (env-find-variable env 'x)))
    (println "  Variable lookup: " (if (and var (= 42 (var-value var))) "PASS" "FAIL"))))

;; Test 2: Environment chain traversal  
(println "Test 2: Chain Traversal")
(let* ((parent (create-env () 0 0))
       (child (create-env parent 1 0)))
  (env-define parent 'parent-var "parent")
  (env-define child 'child-var "child")
  (let ((parent-from-child (env-find-variable child 'parent-var))
        (child-from-parent (env-find-variable parent 'child-var)))
    (println "  Chain traversal: " 
             (if (and parent-from-child (not child-from-parent)) "PASS" "FAIL"))))

;; Test 3: Multi-method evaluation with let
(println "Test 3: Let Evaluation")
(let ((result (env-mm-evaluate '(let ((x 10) (y 20)) (+ x y)))))
  (println "  Let binding result: " result)
  (println "  Let evaluation: " (if (= result 30) "PASS" "FAIL")))

;; Test 4: Variable shadowing
(println "Test 4: Shadowing")
(let ((result (env-mm-evaluate '(let ((x 1)) (let ((x 2)) x)))))
  (println "  Shadowing result: " result) 
  (println "  Variable shadowing: " (if (= result 2) "PASS" "FAIL")))

(println "")
(println "✅ Essential environment stack tests complete")
(println "🎯 Core functionality validated")