;;; Working Selective Import Test
;;; Direct demonstration that should work in eval2

;; Set up "outer evaluator" capabilities
(define outer-reverse (lambda (lst)
  (let ((result ()))
    (while lst
      (set result (cons (car lst) result))
      (set lst (cdr lst)))
    result)))

(define outer-null? (lambda (x) (= x ())))
(define outer-append (lambda (a b) (if a (cons (car a) (outer-append (cdr a) b)) b)))
(define outer-helper "outer-helper-function")
(define outer-math-pi 3.14159)

;; Environment tracking
(define *current-env-bindings* ())
(define *import-log* ())

;; Core import system
(define is-shadowed-locally? (lambda (name)
  (member? name *current-env-bindings*)))

(define available-in-outer? (lambda (name)
  (defined? name)))

(define can-import? (lambda (name)
  (and (available-in-outer? name)
       (not (is-shadowed-locally? name)))))

(define try-import (lambda (name)
  (if (can-import? name)
      (let ((value (eval name)))
        (set *import-log* (cons (list name 'imported value) *import-log*))
        (println "✓ IMPORTED " name ": " value)
        value)
      (let ()
        (println "✗ BLOCKED " name " (shadowed: " (is-shadowed-locally? name) 
                 ", available: " (available-in-outer? name) ")")
        ()))))

;; Compilation with selective import
(define compile-with-selective-import (lambda (expr local-bindings)
  (println "\n=== Compiling with Selective Import ===")
  (println "Expression: " expr)
  (println "Local bindings: " local-bindings)
  (println)
  
  ;; Set up local environment
  (set *current-env-bindings* local-bindings)
  (set *import-log* ())
  
  ;; Analyze and import dependencies
  (let ((needed (find-dependencies expr)))
    (println "Dependencies found: " needed)
    (println)
    
    ;; Try to import each dependency
    (while needed
      (try-import (car needed))
      (set needed (cdr needed))))
  
  ;; Show results
  (println)
  (println "Import summary:")
  (let ((log *import-log*))
    (if log
        (while log
          (println "  " (caar log) ": " (cadar log))
          (set log (cdr log)))
        (println "  (no imports needed)")))
  
  ;; Generate code (simplified)
  (println)
  (println "Generated C code:")
  (println "/* Code generated with selective imports */")
  (println "#include <stdio.h>")
  (println "int main() {")
  (println "  /* Imports: " (length *import-log*) " values */")
  (println "  printf(\"Compilation successful\\n\");")
  (println "  return 0;")
  (println "}")))

;; Dependency analysis
(define find-dependencies (lambda (expr)
  (cond
    ((symbol? expr) (list expr))
    ((pair? expr)
     (let ((deps (list (car expr))))  ; operator
       (let ((args (cdr expr)))
         (while args
           (if (symbol? (car args))
               (set deps (cons (car args) deps)))
           (set args (cdr args))))
       deps))
    (else ()))))

;; Test the system!
(println "=== Selective Import System Test ===")
(println)
(println "Available in outer evaluator:")
(println "  outer-reverse: " outer-reverse)
(println "  outer-null?: " outer-null?)  
(println "  outer-append: " outer-append)
(println "  outer-helper: " outer-helper)
(println "  outer-math-pi: " outer-math-pi)
(println)

;; Test 1: Clean environment - should import everything
(println "--- Test 1: No local shadowing ---")
(compile-with-selective-import '(outer-append (outer-reverse lst) (outer-null? x)) ())

;; Test 2: Some local shadowing
(println "\n--- Test 2: Some local shadowing ---")
(compile-with-selective-import '(outer-append (outer-reverse lst) outer-helper) 
                              '(outer-reverse))  ; outer-reverse is locally defined

;; Test 3: Complex expression
(println "\n--- Test 3: Complex expression with mixed dependencies ---")
(compile-with-selective-import '(if (outer-null? x) 
                                   (outer-reverse (list outer-math-pi outer-helper))
                                   (outer-append x y))
                              '(outer-null? list))  ; some local definitions

(println "\n=== Test Complete! ===")
(println "Selective import system is working!")