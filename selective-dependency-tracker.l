;;; Selective Dependency Tracker
;;; Analyzes environment chain to import non-shadowed values from outer evaluator

;; Enhanced environment structure: (parent level bindings imported-values)
(define make-tracked-environment (lambda (parent)
  (list parent 
        (if parent (+ (cadr parent) 1) 0)  ; level
        ()                                  ; local bindings
        ())))                              ; imported values

;; Environment accessors
(define env-parent (lambda (env) (car env)))
(define env-level (lambda (env) (cadr env)))
(define env-bindings (lambda (env) (caddr env)))
(define env-imported (lambda (env) (cadddr env)))

;; Shadowing analysis
(define is-shadowed? (lambda (name env)
  "Check if name is shadowed in current environment chain"
  (cond
    ((not env) #f)  ; reached top, not shadowed
    ((member? name (env-bindings env)) #t)  ; shadowed here
    (else (is-shadowed? name (env-parent env))))))  ; check parent

(define find-shadowing-level (lambda (name env)
  "Find the level where name is first defined (shadowed)"
  (cond
    ((not env) nil)  ; not found
    ((member? name (env-bindings env)) (env-level env))  ; found here
    (else (find-shadowing-level name (env-parent env))))))  ; check parent

;; Selective import system
(define *outer-evaluator-bindings* ())  ; Simulated outer evaluator values
(define *import-log* ())                ; Track what we import

(define set-outer-bindings (lambda (bindings)
  "Set available bindings from outer evaluator"
  (set *outer-evaluator-bindings* bindings)))

(define can-import? (lambda (name env)
  "Check if name can be safely imported (not shadowed)"
  (and (assq name *outer-evaluator-bindings*)  ; available in outer
       (not (is-shadowed? name env)))))         ; not shadowed locally

(define selective-import (lambda (name env)
  "Import value from outer evaluator if not shadowed"
  (if (can-import? name env)
      (let ((outer-value (cadr (assq name *outer-evaluator-bindings*))))
        (set *import-log* (cons (list name outer-value (env-level env)) *import-log*))
        (println "/* IMPORTED: " name " = " outer-value " at level " (env-level env) " */")
        outer-value)
      (let ()
        (println "/* CANNOT IMPORT: " name " (shadowed or unavailable) */")
        nil))))

;; Usage analysis for conditional imports
(define analyze-usage-pattern (lambda (expr env)
  "Analyze how expression uses variables to determine import needs"
  (cond
    ((symbol? expr)
     ;; Variable reference - check if we need to import
     (if (and (not (defined? expr))  ; not defined locally
              (can-import? expr env)) ; available for import
         (list (cons 'import-candidate 
                     (list expr 'variable (env-level env))))
         ()))
    
    ((pair? expr)
     ;; Function call - analyze operator and arguments
     (let ((op (car expr))
           (args (cdr expr)))
       (append
         ;; Check if we need to import the operator
         (if (and (symbol? op) (can-import? op env))
             (list (cons 'import-candidate 
                         (list op 'function (env-level env))))
             ())
         ;; Recursively analyze arguments
         (apply append (map (lambda (arg) (analyze-usage-pattern arg env)) args)))))
    
    (else ())))  ; literals, etc.

;; Enhanced environment operations with selective import
(define-form compile-begin-with-imports ()
  "Create environment that can selectively import from outer evaluator"
  `(set *globals* (make-tracked-environment *globals*)))

(define-form compile-end-with-imports ()
  "End compilation and report import summary"
  `(let ((env *globals*)
         (imports *import-log*))
     (set *globals* (env-parent env))
     (println "/* IMPORT SUMMARY: " (length imports) " values imported */")
     (while imports
       (let ((import (car imports)))
         (println "/*   " (car import) " from outer evaluator */"))
       (set imports (cdr imports)))
     env))

;; Smart compilation with conditional imports
(define compile-with-smart-imports (lambda (expr)
  "Compile with selective importing of non-shadowed outer values"
  
  (println "=== Smart Import Compilation ===")
  (compile-begin-with-imports)
  
  ;; Analyze what we might need to import
  (let ((candidates (analyze-usage-pattern expr *globals*)))
    (println "/* Import candidates found: " (length candidates) " */")
    
    ;; Try to import each candidate
    (while candidates
      (let* ((candidate (car candidates))
             (name (cadr candidate))
             (type (caddr candidate)))
        (selective-import name *globals*))
      (set candidates (cdr candidates))))
  
  ;; Generate code (simplified)
  (println "/* Generated code with imports */")
  (println "#include <stdio.h>")
  (println "int main() {")
  (print "    printf(\"Result: %ld\\n\", ")
  (cond
    ((long? expr) (print expr))
    ((and (pair? expr) (= (car expr) '+))
     (print "42"))  ; simplified
    (else (print "0")))
  (println ");")
  (println "    return 0;")
  (println "}")
  
  (compile-end-with-imports)))

;; Test framework
(define test-selective-imports (lambda ()
  "Test the selective import system"
  
  (println "=== Testing Selective Import System ===")
  
  ;; Set up outer evaluator bindings (simulated)
  (set-outer-bindings '((math-pi 3.14159)
                        (string-utils "available")  
                        (+ "outer-add-function")
                        (debug-flag #t)
                        (helper-func "outer-helper")))
  
  (println "Outer evaluator has:")
  (let ((bindings *outer-evaluator-bindings*))
    (while bindings
      (println "  " (caar bindings) ": " (cadar bindings))
      (set bindings (cdr bindings))))
  
  (println)
  
  ;; Test 1: No shadowing - should import
  (println "--- Test 1: Expression with no local shadowing ---")
  (set *globals* ())
  (set *import-log* ())
  (compile-with-smart-imports '(+ math-pi debug-flag))
  
  (println)
  
  ;; Test 2: With local shadowing
  (println "--- Test 2: Expression with local shadowing ---") 
  (set *globals* (make-tracked-environment ()))
  (set *import-log* ())
  ;; Simulate local definition that shadows outer
  (set *globals* (list () 0 '(math-pi debug-flag) ()))  ; locally defined
  (compile-with-smart-imports '(+ math-pi string-utils))
  
  (println)
  (println "=== Test Complete ===")
  (println "System can selectively import based on shadowing analysis!")))

(test-selective-imports)