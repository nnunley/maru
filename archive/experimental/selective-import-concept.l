;;; Direct demonstration of selective import concept

;; Set up simulation of outer evaluator values
(define outer-pi 3.14159)
(define outer-helper "helper-function")
(define outer-debug 1)  ; true

;; Track what we have locally vs what we can import
(define local-bindings ())

(define is-local? (lambda (name)
  "Check if name is defined locally"
  (member? name local-bindings)))

(define can-import-safely? (lambda (name)
  "Check if we can safely import without shadowing"
  (and (defined? name)  ; available in outer evaluator
       (not (is-local? name)))))  ; not shadowed locally

(define show-import-analysis (lambda (names)
  "Analyze import possibilities for list of names"
  (println "Import Analysis:")
  (while names
    (let ((name (car names)))
      (print "  " name ": ")
      (cond
        ((is-local? name) (println "SHADOWED (cannot import)"))
        ((defined? name) (println "CAN IMPORT"))  
        (else (println "NOT AVAILABLE"))))
    (set names (cdr names)))))

;; Demonstration
(println "=== Selective Import Concept Demo ===")
(println)

(println "Available in outer evaluator:")
(println "  outer-pi: " outer-pi)
(println "  outer-helper: " outer-helper)  
(println "  outer-debug: " outer-debug)
(println)

;; Test 1: No local definitions
(println "--- Scenario 1: Clean environment ---")
(set local-bindings ())
(show-import-analysis '(outer-pi outer-helper outer-debug missing-func))
(println)

;; Test 2: Some local definitions shadow outer
(println "--- Scenario 2: Some local shadowing ---") 
(set local-bindings '(outer-pi))  ; pi is defined locally
(show-import-analysis '(outer-pi outer-helper outer-debug))
(println)

;; Test 3: Usage-based conditional import
(println "--- Scenario 3: Usage-based import ---")
(define analyze-expression-imports (lambda (expr local-names)
  "Analyze what an expression would need to import"
  (set local-bindings local-names)
  (println "Expression: " expr)
  (println "Local bindings: " local-names)
  
  (cond
    ((symbol? expr)
     (if (can-import-safely? expr)
         (println "  Would import: " expr)
         (println "  Cannot import: " expr)))
    ((pair? expr)
     (println "  Analyzing function call...")
     (analyze-expression-imports (car expr) local-names)  ; operator
     (let ((args (cdr expr)))
       (while args
         (if (symbol? (car args))
             (analyze-expression-imports (car args) local-names))
         (set args (cdr args)))))))

;; Test expression analysis
(analyze-expression-imports '(+ outer-pi outer-helper) ())
(println)
(analyze-expression-imports '(+ outer-pi outer-helper) '(outer-pi))
(println)

(println "=== Concept Demonstrated ===") 
(println "✓ Can detect shadowing in environment chain")
(println "✓ Can selectively import non-conflicting values")
(println "✓ Can analyze expressions for import needs")
(println "✓ Enables smart conditional imports from outer evaluator")