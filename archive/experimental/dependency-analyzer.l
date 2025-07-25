;;; Dependency Analysis System for Threaded Backend
;;; Analyzes compilation environments to determine what's needed from outer evaluator

;; Enhanced environment with dependency tracking
(define *missing-dependencies* ())
(define *external-references* ())
(define *compilation-depth* 0)

;; Simple environment structure: (parent level bindings missing-deps)
(define environment-with-tracking (lambda (parent)
  (list parent 
        (if parent (+ (cadr parent) 1) 0) 
        ()  ; bindings
        ()  ; missing dependencies
        )))

;; Dependency tracking functions
(define track-dependency (lambda (name type context)
  "Record a dependency that's needed from outer evaluator"
  (let ((dep (list name type context *compilation-depth*)))
    (set *missing-dependencies* (cons dep *missing-dependencies*))
    dep)))

(define find-in-environment (lambda (env name)
  "Search for binding in environment chain, track if missing"
  (cond
    ((not env) 
     (track-dependency name 'undefined 'global-lookup)
     nil)
    ((member? name (caddr env))  ; found in current bindings
     (list name 'local 'found))
    (else 
     (find-in-environment (car env) name)))))  ; search parent

;; Enhanced compile-begin with dependency tracking
(define-form compile-begin-with-deps ()
  "Create compilation environment with dependency tracking"
  `(let ()
     (set *compilation-depth* (+ *compilation-depth* 1))
     (set *globals* (environment-with-tracking *globals*))
     (set *missing-dependencies* ())))

(define-form compile-end-with-deps ()
  "End compilation and return dependency analysis"
  `(let ((env *globals*)
         (deps *missing-dependencies*))
     (set *globals* (car env))
     (set *compilation-depth* (- *compilation-depth* 1))
     (list 'compilation-result env deps)))

;; Analysis functions
(define analyze-dependencies (lambda (deps)
  "Analyze collected dependencies and categorize them"
  (let ((undefined-funcs ())
        (undefined-vars ())
        (forms-needed ())
        (structures-needed ()))
    
    (while deps
      (let* ((dep (car deps))
             (name (car dep))
             (type (cadr dep))
             (context (caddr dep)))
        (cond
          ((= context 'function-call)
           (set undefined-funcs (cons name undefined-funcs)))
          ((= context 'variable-reference)
           (set undefined-vars (cons name undefined-vars)))
          ((= context 'special-form)
           (set forms-needed (cons name forms-needed)))
          ((= context 'structure-access)
           (set structures-needed (cons name structures-needed))))
        (set deps (cdr deps))))
    
    (list 
      (cons 'functions undefined-funcs)
      (cons 'variables undefined-vars)
      (cons 'forms forms-needed)
      (cons 'structures structures-needed))))

;; Mock compile function that tracks dependencies
(define compile-with-dependency-tracking (lambda (expr)
  "Compile expression and track what dependencies are needed"
  
  (println "/* Compilation with dependency tracking */")
  (println "/* Environment depth: " *compilation-depth* " */")
  
  ;; Analyze the expression for dependencies
  (let ((deps (analyze-expression-dependencies expr)))
    (println "/* Dependencies found: " (length deps) " */")
    (for-each deps (lambda (dep)
      (println "/*   " (car dep) " (" (cadr dep) ") */")))))

;; Expression analysis
(define analyze-expression-dependencies (lambda (expr)
  "Recursively analyze expression to find dependencies"
  (cond
    ((long? expr) ())  ; literals have no dependencies
    ((string? expr) ())
    ((symbol? expr)  ; variable reference
     (if (find-in-environment *globals* expr)
         ()  ; found locally
         (list (track-dependency expr 'variable 'variable-reference))))
    ((pair? expr)
     (let ((op (car expr))
           (args (cdr expr)))
       (append
         ;; Check if operator is defined
         (if (find-in-environment *globals* op)
             ()
             (list (track-dependency op 'function 'function-call)))
         ;; Recursively analyze arguments
         (apply append (map analyze-expression-dependencies args)))))
    (else ())))

;; For-each implementation (since it might not be available)
(define for-each (lambda (lst func)
  (while lst
    (func (car lst))
    (set lst (cdr lst)))))

;; Helper to check what's actually available in current environment
(define check-available-functions (lambda ()
  "Check what basic functions are available"
  (let ((funcs '(define define-function define-form lambda if cond while
                 cons car cdr list append map + - * / = < > 
                 println print concat-string long->string)))
    (println "/* Available functions: */")
    (for-each funcs (lambda (func)
      (println "/*   " func ": " (if (defined? func) "yes" "no") " */"))))))antml:parameter>
</invoke>