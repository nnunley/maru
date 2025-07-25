;;; Simple Dotted Environment Access System
;;; Uses available Maru string functions

(define-function progress-dot args (apply println (cons "; Dot Access: " args)))

(progress-dot "implementing simple dotted access")

;;; Helper function to find dot in string
(define-function find-dot-position (str)
  "Find position of first dot in string, return () if not found"
  (let ((len (string-length str))
        (pos 0)
        (found ()))
    (while (and (< pos len) (not found))
      (if (= (string-at str pos) ?.)
          (set found pos)
          (set pos (+ pos 1))))
    found))

;;; Parse dotted symbols
(define-function parse-dotted-symbol (symbol)
  "Parse symbol like 'env.name' into ('env' 'name')"
  (let ((str (symbol->string symbol)))
    (let ((dot-pos (find-dot-position str)))
      (if dot-pos
          (list (string->symbol (substring str 0 dot-pos))
                (string->symbol (substring str (+ dot-pos 1) (string-length str))))
          ()))))

(define-function is-dotted-symbol? (symbol)
  "Check if symbol contains dot"
  (and (symbol? symbol)
       (find-dot-position (symbol->string symbol))))

;;; Simple environment structure
(define-structure <simple-env> (bindings name))

(define-function make-simple-env (name)
  "Create simple environment"
  (let ((env (new <simple-env>)))
    (set (<simple-env>-name env) name)
    (set (<simple-env>-bindings env) ())
    env))

(define-function env-set (env symbol value)
  "Set symbol in environment"
  (let ((binding (assq symbol (<simple-env>-bindings env))))
    (if binding
        (set-cdr binding value)
        (set (<simple-env>-bindings env)
             (cons (cons symbol value) (<simple-env>-bindings env)))))
  value)

(define-function env-get (env symbol)
  "Get symbol from environment"
  (let ((binding (assq symbol (<simple-env>-bindings env))))
    (if binding (cdr binding) ())))

(define-function env-has? (env symbol)
  "Check if environment has symbol"
  (assq symbol (<simple-env>-bindings env)))

;;; Macro for dotted access
(define-form dot-access (env-expr symbol-name)
  "Access symbol in environment: (dot-access my-env field)"
  `(env-get ,env-expr ',symbol-name))

;;; Compile-time dotted symbol expansion
(define-function expand-dotted-expr (expr env-map)
  "Expand dotted symbols in expression using environment map"
  (cond
    ((symbol? expr)
     (if (is-dotted-symbol? expr)
         (let ((parts (parse-dotted-symbol expr)))
           (if (and parts (= (length parts) 2))
               (let ((env-name (car parts))
                     (symbol-name (cadr parts)))
                 (let ((env-var (assq env-name env-map)))
                   (if env-var
                       `(env-get ,(cdr env-var) ',symbol-name)
                       expr)))
               expr))
         expr))
    ((pair? expr)
     (map (lambda (sub-expr) (expand-dotted-expr sub-expr env-map)) expr))
    (else expr)))

;;; Environment context macro
(define-form with-env (env-name env-value . body)
  "Execute body with dotted access to environment"
  (let ((env-map (list (cons env-name env-value)))
        (expanded-body (map (lambda (form)
                              (expand-dotted-expr form (list (cons env-name env-value))))
                            body)))
    `(let ((,env-name ,env-value))
       ,@expanded-body)))

(progress-dot "testing simple dotted access")

;;; Test the system
(define test-env (make-simple-env 'test))
(env-set test-env 'x 42)
(env-set test-env 'y "hello")
(env-set test-env 'name "test-environment")

(progress-dot "created test environment")

;; Test basic operations
(println "Basic environment operations:")
(println "  env-get test-env 'x: " (env-get test-env 'x))
(println "  env-get test-env 'y: " (env-get test-env 'y))
(println "  env-has? test-env 'x: " (env-has? test-env 'x))
(println "  env-has? test-env 'z: " (env-has? test-env 'z))

;; Test dotted symbol parsing
(println "Dotted symbol parsing:")
(println "  find-dot-position \"env.x\": " (find-dot-position "env.x"))
(println "  parse-dotted-symbol 'env.x: " (parse-dotted-symbol 'env.x))
(println "  is-dotted-symbol? 'env.x: " (is-dotted-symbol? 'env.x))
(println "  is-dotted-symbol? 'simple: " (is-dotted-symbol? 'simple))

;; Test compile-time expansion (manual)
(println "Manual expansion test:")
(let ((env-map (list (cons 'test test-env)))
      (test-expr 'test.x))
  (println "  Original: " test-expr)
  (println "  Expanded: " (expand-dotted-expr test-expr env-map))
  (println "  Evaluated: " (eval (expand-dotted-expr test-expr env-map))))

(progress-dot "simple dotted access system working")