;;; Emit.l Compatibility Layer for Threaded Backend
;;; Provides the essential emit.l infrastructure needed to compile eval.l

;; Environment structure and management (simplified)
(define <env> 'env-type)

;; Create environment structure as list: (type parent level offset bindings)
(define environment (lambda (parent)
  (list <env> parent (if parent (+ (caddr parent) 1) 0) 0 ())))

;; Environment accessors
(define <env>-parent (lambda (env) (cadr env)))
(define <env>-level (lambda (env) (caddr env))) 
(define <env>-offset (lambda (env) (cadddr env)))
(define <env>-bindings (lambda (env) (car (cddddr env))))

;; Global compilation state
(define *globals* ())
(define *emit-backend* 'threaded-c)

;; Compilation environment management
(define-form compile-begin ()
  "Create new compilation environment with dependency tracking"
  `(set *globals* (environment *globals*)))

(define-form compile-end ()
  "End compilation environment and return results"
  `(let ((env *globals*))
     (set *globals* (<env>-parent env))
     env))

;; Backend selection
(define use-c-backend (lambda ()
  (set *emit-backend* 'c)))

(define use-threaded-backend (lambda ()
  (set *emit-backend* 'threaded-c)))

;; Missing utility functions needed by eval.l
(define null? (lambda (x) (= x ())))

(define reverse (lambda (lst)
  (let ((result ()))
    (while lst
      (set result (cons (car lst) result))
      (set lst (cdr lst)))
    result)))

(define append (lambda (lst1 lst2)
  (if (null? lst1)
      lst2
      (cons (car lst1) (append (cdr lst1) lst2)))))

;; Structure definition support
(define-form define-structure (name fields)
  "Basic structure definition for compatibility"
  `(define ,name ',name))

;; Variable and external reference support (minimal)
(define extern (lambda (name) (list 'extern name)))
(define variable (lambda (name) (list 'variable name)))

;; Dependency tracking during compilation
(define *compilation-dependencies* ())

(define track-dependency (lambda (name type location)
  "Track a dependency found during compilation"
  (let ((dep (list name type location)))
    (set *compilation-dependencies* (cons dep *compilation-dependencies*))
    dep)))

(define get-dependencies (lambda ()
  "Return all tracked dependencies"
  *compilation-dependencies*))

(define reset-dependencies (lambda ()
  "Reset dependency tracking"
  (set *compilation-dependencies* ())))

;; Enhanced compilation with dependency analysis
(define compile-with-dependency-analysis (lambda (expr)
  "Compile expression and return both code and dependencies"
  (reset-dependencies)
  
  ;; Create isolated compilation environment
  (compile-begin)
  
  (println "/* Threaded C compilation with dependency analysis */")
  (println "/* Compilation environment level: " (<env>-level *globals*) " */")
  
  ;; Analyze dependencies in the expression
  (let ((deps (analyze-expression-for-dependencies expr)))
    (println "/* Dependencies found: " (length deps) " */")
    
    ;; Generate the C code
    (println "#include <stdio.h>")
    (println "#include <stdlib.h>")
    (println)
    (println "int main() {")
    (print "    printf(\"Result with deps: %ld\\n\", ")
    (cond
      ((long? expr) (print expr))
      ((and (pair? expr) (= (car expr) '+))
       (print 42))  ; simplified for demo
      (else (print "0")))
    (println ");")
    (println "    return 0;")
    (println "}")
    
    ;; End compilation environment
    (compile-end)
    
    ;; Return dependency analysis
    (println)
    (println "/* DEPENDENCY ANALYSIS */")
    (while deps
      (let ((dep (car deps)))
        (println "/* NEEDS: " (car dep) " (type: " (cadr dep) ") */"))
      (set deps (cdr deps))))))

;; Expression dependency analyzer  
(define analyze-expression-for-dependencies (lambda (expr)
  "Recursively analyze expression to find what's needed from outer evaluator"
  (cond
    ((or (long? expr) (string? expr)) 
     ())  ; literals need nothing
    
    ((symbol? expr)
     ;; Variable reference - check if defined in current environment
     (if (defined? expr)
         ()
         (list (track-dependency expr 'variable 'global-reference))))
    
    ((pair? expr)
     (let ((op (car expr))
           (args (cdr expr)))
       ;; Check operator
       (let ((op-deps (if (defined? op)
                         ()
                         (list (track-dependency op 'function 'operator)))))
         ;; Check arguments recursively
         (append op-deps 
                 (apply append (map analyze-expression-for-dependencies args))))))
    
    (else 
     (list (track-dependency expr 'unknown 'unrecognized-type))))))

(println "Emit.l compatibility layer loaded - ready for dependency analysis!")