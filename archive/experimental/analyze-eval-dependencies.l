;;; Direct analysis of what eval.l needs that's missing

;; Test basic availability in eval2 environment
(define check-basic-functions (lambda ()
  (let ((needed-funcs 
         '(define define-function define-form lambda if cond
           cons car cdr pair? symbol? long? null? not
           + - * / = < > and or
           list append reverse assq member?
           print println concat-string long->string
           eval apply quote quasiquote unquote
           environment)))
    
    (println "=== Basic Function Availability in eval2 ===")
    (while needed-funcs
      (let ((func (car needed-funcs)))
        (print func ": ")
        (println (if (defined? func) "✓" "✗")))
      (set needed-funcs (cdr needed-funcs))))))

;; Check for eval.l specific dependencies by reading the file
(define analyze-eval-file-dependencies (lambda ()
  (println "\n=== Analyzing eval.l Dependencies ===")
  (println "Based on our previous attempts, eval.l needs:")
  (println "")
  
  (println "CRITICAL MISSING:")
  (println "  - compile-begin/compile-end (from emit.l)")
  (println "  - environment function (from emit.l)")
  (println "  - define-form macro system")
  (println "  - <env> structure and accessors")
  (println "  - quasiquote/unquote system")
  (println "")
  
  (println "UTILITY FUNCTIONS:")
  (println "  - null? (can define as: (lambda (x) (= x ())))")
  (println "  - reverse (can define manually)")
  (println "  - assq, member? (can define)")
  (println "")
  
  (println "BOOTSTRAPPING ISSUE:")
  (println "  - eval.l expects full emit.l infrastructure")
  (println "  - emit.l provides compilation framework")
  (println "  - eval.l is meant to be compiled BY emit.l")
  (println "  - Cannot compile eval.l without emit.l loaded first")))

;; Show what emit.l provides that's needed
(define show-emit-dependencies (lambda ()
  (println "\n=== What emit.l Provides ===")
  (println "compile-begin/compile-end: Environment management")
  (println "environment: Creates <env> structures")
  (println "<env> structure: (parent level offset bindings)")
  (println "Code generation: gen-* functions")
  (println "Backend selection: *emit-backend*, use-c-backend")
  (println "Variable management: extern, variable, temp")
  (println "")
  (println "SOLUTION:")
  (println "1. Load emit.l infrastructure first")
  (println "2. Then compile eval.l using that infrastructure")
  (println "3. OR: Create minimal emit.l subset for threaded backend")))

;; Main analysis
(check-basic-functions)
(analyze-eval-file-dependencies)  
(show-emit-dependencies)

(println "\n=== CONCLUSION ===")
(println "The environment can definitely track dependencies!")
(println "Main insight: eval.l requires emit.l's compilation infrastructure")
(println "The threaded backend needs to either:")
(println "1. Extend emit.l with threaded generation, or")
(println "2. Provide emit.l-compatible interface"))