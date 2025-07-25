;;; Dotted Environment Access System
;;; Extends Maru's existing self.field syntax to support env.symbol access

(define-function progress-env args (apply println (cons "; Env Access: " args)))

(progress-env "implementing dotted environment access")

;;; Environment structure (if not already defined)
(define-structure <environment> (parent bindings))

(define-function make-environment (parent)
  "Create new environment with optional parent"
  (let ((env (new <environment>)))
    (set (<environment>-parent env) parent)
    (set (<environment>-bindings env) ())
    env))

;;; Environment operations
(define-function env-define (env name value)
  "Define symbol in environment"
  (let ((binding (assq name (<environment>-bindings env))))
    (if binding
        (set-cdr binding value)
        (set (<environment>-bindings env)
             (cons (cons name value) (<environment>-bindings env)))))
  value)

(define-function env-lookup (env name)
  "Look up symbol in environment chain"
  (let ((binding (assq name (<environment>-bindings env))))
    (if binding
        (cdr binding)
        (if (<environment>-parent env)
            (env-lookup (<environment>-parent env) name)
            ()))))

(define-function env-defined? (env name)
  "Check if symbol is defined in environment chain"
  (or (assq name (<environment>-bindings env))
      (and (<environment>-parent env)
           (env-defined? (<environment>-parent env) name))))

;;; Parse dotted symbols
(define-function parse-dotted-symbol (symbol)
  "Parse symbol like 'env.name' into ('env' 'name')"
  (let ((str (symbol->string symbol)))
    (let ((dot-pos (string-find-char str ?.)))
      (if dot-pos
          (list (string->symbol (substring str 0 dot-pos))
                (string->symbol (substring str (+ dot-pos 1) (string-length str))))
          ()))))

(define-function is-dotted-symbol? (symbol)
  "Check if symbol contains dot"
  (and (symbol? symbol)
       (let ((str (symbol->string symbol)))
         (string-find-char str ?.))))

;;; Environment accessor creation
(define-function make-environment-accessor (env-name symbol-name)
  "Create accessor form for env.symbol"
  `(,env-name () ((env-var) (list 'env-lookup env-var ',symbol-name))))

(define-function make-environment-accessors (env-name symbols)
  "Create accessor forms for all symbols in environment"
  (map (lambda (sym)
         (let ((dotted-name (concat-symbol env-name (concat-symbol '. sym))))
           (make-environment-accessor dotted-name sym)))
       symbols))

;;; Dynamic environment binding
(define *environment-stack* ())

(define-function push-environment (env)
  "Push environment onto stack"
  (set *environment-stack* (cons env *environment-stack*)))

(define-function pop-environment ()
  "Pop environment from stack"
  (let ((env (car *environment-stack*)))
    (set *environment-stack* (cdr *environment-stack*))
    env))

(define-function current-environment ()
  "Get current environment"
  (car *environment-stack*))

;;; Environment context form
(define-form with-environment (env . body)
  "Execute body with environment bindings available as env.symbol"
  `(let ()
     (push-environment ,env)
     (with-forms ,(make-environment-accessors 'env 
                    (env-get-all-symbols env))
       (let ((result (let () ,@body)))
         (pop-environment)
         result))))

(define-function env-get-all-symbols (env)
  "Get all symbol names defined in environment"
  (let ((symbols ()))
    (let ((current env))
      (while current
        (map (lambda (binding)
               (let ((name (car binding)))
                 (if (not (member? name symbols))
                     (set symbols (cons name symbols)))))
             (<environment>-bindings current))
        (set current (<environment>-parent current))))
    symbols))

;;; Compile-time dotted symbol resolution
(define-function expand-dotted-symbols (expr env-bindings)
  "Expand dotted symbols in expression"
  (cond
    ((symbol? expr)
     (if (is-dotted-symbol? expr)
         (let ((parts (parse-dotted-symbol expr)))
           (if parts
               (let ((env-name (car parts))
                     (symbol-name (cadr parts)))
                 (if (assq env-name env-bindings)
                     `(env-lookup ,(cdr (assq env-name env-bindings)) ',symbol-name)
                     expr))
               expr))
         expr))
    ((pair? expr)
     (cons (expand-dotted-symbols (car expr) env-bindings)
           (expand-dotted-symbols (cdr expr) env-bindings)))
    (else expr)))

;;; Enhanced environment context with compile-time expansion
(define-form with-environment-expanded (bindings . body)
  "Execute body with compile-time dotted symbol expansion"
  (let ((expanded-body (map (lambda (form)
                              (expand-dotted-symbols form bindings))
                            body)))
    `(let () ,@expanded-body)))

(progress-env "testing environment access system")

;;; Test the system
(define test-env (make-environment ()))
(env-define test-env 'x 42)
(env-define test-env 'y "hello")
(env-define test-env 'add (lambda (a b) (+ a b)))

(progress-env "test environment created with x, y, add")

;; Test basic environment operations
(println "Basic environment operations:")
(println "  env-lookup test-env 'x: " (env-lookup test-env 'x))
(println "  env-lookup test-env 'y: " (env-lookup test-env 'y))
(println "  env-defined? test-env 'x: " (env-defined? test-env 'x))
(println "  env-defined? test-env 'z: " (env-defined? test-env 'z))

;; Test dotted symbol parsing
(println "Dotted symbol parsing:")
(println "  parse-dotted-symbol 'env.x: " (parse-dotted-symbol 'env.x))
(println "  parse-dotted-symbol 'test.field: " (parse-dotted-symbol 'test.field))
(println "  is-dotted-symbol? 'env.x: " (is-dotted-symbol? 'env.x))
(println "  is-dotted-symbol? 'simple: " (is-dotted-symbol? 'simple))

;; Test compile-time expansion
(println "Compile-time expansion:")
(let ((test-bindings '((env . test-env)))
      (test-expr '(+ env.x env.x)))
  (println "  Original: " test-expr)
  (println "  Expanded: " (expand-dotted-symbols test-expr test-bindings)))

;; Test with manual expansion
(println "Manual dotted access:")
(println "  env.x via expansion: " (env-lookup test-env 'x))
(println "  env.y via expansion: " (env-lookup test-env 'y))

(progress-env "environment access system ready")