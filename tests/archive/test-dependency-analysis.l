;;; Test the dependency analysis system

;; Load the compatibility layer
(define test-var 42)
(define test-func (lambda (x) (+ x 1)))

;; Manually include the compatibility functions since load has issues
(define <env> 'env-type)
(define environment (lambda (parent)
  (list <env> parent (if parent (+ (caddr parent) 1) 0) 0 ())))
(define <env>-level (lambda (env) (caddr env)))
(define <env>-parent (lambda (env) (cadr env)))
(define *globals* ())
(define *compilation-dependencies* ())

(define-form compile-begin ()
  `(set *globals* (environment *globals*)))

(define-form compile-end ()
  `(let ((env *globals*))
     (set *globals* (<env>-parent env))
     env))

(define track-dependency (lambda (name type location)
  (let ((dep (list name type location)))
    (set *compilation-dependencies* (cons dep *compilation-dependencies*))
    dep)))

(define analyze-expression-for-dependencies (lambda (expr)
  (cond
    ((or (long? expr) (string? expr)) ())
    ((symbol? expr)
     (if (defined? expr)
         ()
         (list (track-dependency expr 'variable 'global-reference))))
    ((pair? expr)
     (let ((op (car expr))
           (args (cdr expr)))
       (let ((op-deps (if (defined? op)
                         ()
                         (list (track-dependency op 'function 'operator)))))
         (append op-deps 
                 (apply append (map analyze-expression-for-dependencies args))))))
    (else 
     (list (track-dependency expr 'unknown 'unrecognized-type))))))

;; Test the dependency analysis
(println "=== Dependency Analysis Test ===")
(println)

;; Test 1: Simple expression with known functions
(println "Test 1: (+ 5 10)")
(set *compilation-dependencies* ())
(let ((deps (analyze-expression-for-dependencies '(+ 5 10))))
  (println "Dependencies found:" (length deps))
  (while *compilation-dependencies*
    (let ((dep (car *compilation-dependencies*)))
      (println "  " (car dep) " - " (cadr dep)))
    (set *compilation-dependencies* (cdr *compilation-dependencies*))))

(println)

;; Test 2: Expression with undefined function
(println "Test 2: (undefined-func x y)")
(set *compilation-dependencies* ())
(let ((deps (analyze-expression-for-dependencies '(undefined-func x y))))
  (println "Dependencies found:" (length deps))
  (while *compilation-dependencies*
    (let ((dep (car *compilation-dependencies*)))
      (println "  " (car dep) " - " (cadr dep)))
    (set *compilation-dependencies* (cdr *compilation-dependencies*))))

(println)

;; Test 3: Complex nested expression
(println "Test 3: (if (null? x) (reverse (list a b c)) (+ x 1))")
(set *compilation-dependencies* ())
(let ((deps (analyze-expression-for-dependencies '(if (null? x) (reverse (list a b c)) (+ x 1)))))
  (println "Dependencies found:" (length deps))
  (while *compilation-dependencies*
    (let ((dep (car *compilation-dependencies*)))
      (println "  " (car dep) " - " (cadr dep)))
    (set *compilation-dependencies* (cdr *compilation-dependencies*))))

(println)
(println "=== Analysis Complete ===")
(println "This shows exactly what the outer evaluator needs to provide!")