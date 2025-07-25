;;; Enhanced Dotted Environment Access System
;;; Compile-time expansion of env.symbol syntax similar to self.field

(define-function progress-enhanced args (apply println (cons "; Enhanced Dot: " args)))

(progress-enhanced "implementing enhanced dotted access with compile-time expansion")

;;; Manual string splitting (works with available Maru functions)
(define-function split-at-dot (str)
  "Split string at first dot, return (before . after) or () if no dot"
  (let ((len (string-length str))
        (before "")
        (after "")
        (pos 0)
        (found-dot ()))
    
    ;; Find the dot
    (while (and (< pos len) (not found-dot))
      (if (= (string-at str pos) ?.)
          (set found-dot pos)
          (set pos (+ pos 1))))
    
    (if found-dot
        ;; Build before and after strings character by character
        (let ((i 0))
          ;; Build before string
          (while (< i found-dot)
            (set before (concat-string before (string (string-at str i))))
            (set i (+ i 1)))
          ;; Build after string  
          (set i (+ found-dot 1))
          (while (< i len)
            (set after (concat-string after (string (string-at str i))))
            (set i (+ i 1)))
          (cons before after))
        ())))

(define-function parse-dotted-symbol (sym)
  "Parse dotted symbol into (env-name . symbol-name)"
  (if (symbol? sym)
      (let ((parts (split-at-dot (symbol->string sym))))
        (if parts
            (cons (string->symbol (car parts))
                  (string->symbol (cdr parts)))
            ()))
      ()))

(define-function is-dotted-symbol? (sym)
  "Check if symbol contains dot"
  (and (symbol? sym)
       (split-at-dot (symbol->string sym))))

;;; Environment structure
(define-structure <env> (name bindings))

(define-function make-env (name)
  "Create new environment"
  (let ((env (new <env>)))
    (set (<env>-name env) name)
    (set (<env>-bindings env) ())
    env))

(define-function env-define (env symbol value)
  "Define symbol in environment"
  (let ((binding (assq symbol (<env>-bindings env))))
    (if binding
        (set-cdr binding value)
        (set (<env>-bindings env)
             (cons (cons symbol value) (<env>-bindings env)))))
  value)

(define-function env-lookup (env symbol)
  "Look up symbol in environment"
  (let ((binding (assq symbol (<env>-bindings env))))
    (if binding (cdr binding) ())))

;;; Compile-time dotted symbol expansion
(define-function expand-dotted-expr (expr env-map)
  "Expand dotted symbols in expression using environment map"
  (cond
    ((symbol? expr)
     (if (is-dotted-symbol? expr)
         (let ((parts (parse-dotted-symbol expr)))
           (if parts
               (let ((env-name (car parts))
                     (symbol-name (cdr parts)))
                 (let ((env-binding (assq env-name env-map)))
                   (if env-binding
                       `(env-lookup ,(cdr env-binding) ',symbol-name)
                       expr)))
               expr))
         expr))
    ((pair? expr)
     (cons (expand-dotted-expr (car expr) env-map)
           (expand-dotted-expr (cdr expr) env-map)))
    (else expr)))

;;; Environment context macro with compile-time expansion
(define-form with-env-access (env-bindings . body)
  "Execute body with dotted access expanded at compile time
   Usage: (with-env-access ((env my-env)) (+ env.x env.y))"
  (let ((expanded-body (map (lambda (form)
                              (expand-dotted-expr form env-bindings))
                            body)))
    `(let ,(map (lambda (binding)
                  (list (car binding) (cadr binding)))
                env-bindings)
       ,@expanded-body)))

;;; Accessor form creation (similar to with-instance-accessors)
(define-function make-env-accessor (env-name symbol-name)
  "Create accessor form for env.symbol -> (env-lookup env 'symbol)"
  (let ((dotted-sym (string->symbol (concat-string (symbol->string env-name)
                                                   (concat-string "." (symbol->string symbol-name))))))
    `(,dotted-sym () ((env-var) (list 'env-lookup env-var ',symbol-name)))))

(define-function get-env-symbols (env)
  "Get all symbol names from environment"
  (map car (<env>-bindings env)))

;;; Dynamic environment form (like with-instance-accessors)
(define-form with-env-forms (env . body)
  "Execute body with env.symbol forms available dynamically"
  (let ((env-symbols (get-env-symbols (eval env))))
    (let ((accessor-forms (map (lambda (sym)
                                 (make-env-accessor 'env sym))
                               env-symbols)))
      `(with-forms ,accessor-forms
         (let ((env ,env))
           ,@body)))))

(progress-enhanced "testing enhanced dotted access system")

;;; Test the system
(define test-env (make-env 'test))
(env-define test-env 'x 42)
(env-define test-env 'y 17)
(env-define test-env 'name "test-environment")
(env-define test-env 'add (lambda (a b) (+ a b)))

(progress-enhanced "created test environment with x, y, name, add")

;; Test basic operations
(println "Basic environment operations:")
(println "  env-lookup test-env 'x: " (env-lookup test-env 'x))
(println "  env-lookup test-env 'y: " (env-lookup test-env 'y))
(println "  env-lookup test-env 'name: " (env-lookup test-env 'name))

;; Test dotted symbol parsing
(println "Dotted symbol parsing:")
(println "  split-at-dot \"env.x\": " (split-at-dot "env.x"))
(println "  parse-dotted-symbol 'env.x: " (parse-dotted-symbol 'env.x))
(println "  is-dotted-symbol? 'env.x: " (is-dotted-symbol? 'env.x))
(println "  is-dotted-symbol? 'simple: " (is-dotted-symbol? 'simple))

;; Test compile-time expansion
(println "Compile-time expansion test:")
(let ((env-map '((env . test-env)))
      (test-expr '(+ env.x env.y)))
  (println "  Original expression: " test-expr)
  (println "  Expanded expression: " (expand-dotted-expr test-expr env-map))
  (println "  Evaluated result: " (eval (expand-dotted-expr test-expr env-map))))

;; Test with-env-access macro
(println "with-env-access macro test:")
(println "  Result of (+ env.x env.y): "
         (with-env-access ((env test-env))
           (+ env.x env.y)))

(println "  Result of calling env.add function: "
         (with-env-access ((env test-env))
           (env.add env.x env.y)))

;; Test nested expressions
(println "Nested expression test:")
(println "  Result of (* (+ env.x env.y) 2): "
         (with-env-access ((env test-env))
           (* (+ env.x env.y) 2)))

;; Demonstrate PEG grammar concept
(progress-enhanced "demonstrating PEG grammar environment concept")

(define peg-grammar (make-env 'peg))
(env-define peg-grammar 'letter '(match-class letter))
(env-define peg-grammar 'digit '(match-class digit))
(env-define peg-grammar 'identifier '(match-sequence peg.letter (match-star (match-or peg.letter peg.digit))))

(println "PEG grammar environment:")
(println "  peg.letter: " (env-lookup peg-grammar 'letter))
(println "  peg.digit: " (env-lookup peg-grammar 'digit))

(println "PEG rule with dotted access:")
(with-env-access ((peg peg-grammar))
  (println "  identifier rule: " peg.identifier))

(progress-enhanced "enhanced dotted access system complete")
(progress-enhanced "ready for PEG grammar integration with isolated environments")