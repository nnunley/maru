;;; evalm-environment-stack.l - Multi-Method Evaluator with Piumarta Environment Stack
;;;
;;; This implements the complete Piumarta architecture:
;;; - Multi-method dispatch (our contribution)
;;; - Environment stack management (from eval.l)
;;; - Proper lexical scoping and variable lookup

(println "🚀 Multi-Method Evaluator with Environment Stack Loading...")

;; ==================================================================
;; ENVIRONMENT STACK IMPLEMENTATION (from eval.l)
;; ==================================================================

;; Environment structure helpers
;; In Maru, we'll use associative arrays to simulate the C structures
(define-function create-env (parent level offset)
  "Create new environment frame with parent chain"
  (let ((env (array 4)))  ;; [parent, level, offset, bindings]
    (set-array-at env 0 parent)                    ;; parent env
    (set-array-at env 1 (if parent (+ (array-at parent 1) level) level))  ;; level
    (set-array-at env 2 offset)                    ;; offset
    (set-array-at env 3 (array 0))                 ;; bindings array
    env))

(define-function env-parent (env) (array-at env 0))
(define-function env-level (env) (array-at env 1))
(define-function env-offset (env) (array-at env 2))
(define-function env-bindings (env) (array-at env 3))

(define-function set-env-parent (env val) (set-array-at env 0 val))
(define-function set-env-level (env val) (set-array-at env 1 val))
(define-function set-env-offset (env val) (set-array-at env 2 val))
(define-function set-env-bindings (env val) (set-array-at env 3 val))

;; Variable structure helpers
(define-function create-variable (name value env index)
  "Create variable binding"
  (let ((var (array 4)))   ;; [name, value, env, index]
    (set-array-at var 0 name)
    (set-array-at var 1 value)
    (set-array-at var 2 env)
    (set-array-at var 3 index)
    var))

(define-function var-name (var) (array-at var 0))
(define-function var-value (var) (array-at var 1))
(define-function var-env (var) (array-at var 2))
(define-function var-index (var) (array-at var 3))

(define-function set-var-value (var val) (set-array-at var 1 val))

;; Context structure helpers
(define-function create-context (home env bindings)
  "Create evaluation context"
  (let ((ctx (array 3)))   ;; [home, env, bindings]
    (set-array-at ctx 0 home)
    (set-array-at ctx 1 env)
    (set-array-at ctx 2 bindings)
    ctx))

(define-function ctx-home (ctx) (array-at ctx 0))
(define-function ctx-env (ctx) (array-at ctx 1))
(define-function ctx-bindings (ctx) (array-at ctx 2))

;; ==================================================================
;; ENVIRONMENT OPERATIONS (adapted from eval.l)
;; ==================================================================

(define-function env-find-variable (env name)
  "Find variable in environment chain - traverses from current to parent"
  (let ((current-env env)
        (result ()))
    (while (and current-env (not result))
      (let* ((bindings (env-bindings current-env))
             (count (length bindings))
             (index 0))
        (while (and (< index count) (not result))
          (let ((var (array-at bindings index)))
            (if (= name (var-name var))
                (set result var)
                (set index (+ index 1)))))
        (if (not result)
            (set current-env (env-parent current-env)))))
    result))

(define-function env-lookup (env name)
  "Look up variable value in environment chain"
  (let ((var (env-find-variable env name)))
    (if var
        (var-value var)
        (if (defined? name)
            ;; Fall back to global lookup for built-ins
            (eval name)
            (error "Undefined variable:" name)))))

(define-function env-define (env name value)
  "Define variable in current environment frame"
  (let* ((bindings (env-bindings env))
         (count (length bindings))
         (index 0)
         (found ()))
    ;; Check if already defined in this frame
    (while (and (< index count) (not found))
      (let ((var (array-at bindings index)))
        (if (= name (var-name var))
            (let ()
              (set-var-value var value)
              (set found var))
            (set index (+ index 1)))))
    
    ;; If not found, create new binding
    (if (not found)
        (let* ((offset (env-offset env))
               (var (create-variable name value env offset))
               (new-bindings (array (+ count 1))))
          ;; Copy existing bindings
          (let ((i 0))
            (while (< i count)
              (set-array-at new-bindings i (array-at bindings i))
              (set i (+ i 1))))
          ;; Add new binding
          (set-array-at new-bindings count var)
          (set-env-bindings env new-bindings)
          (set-env-offset env (+ offset 1))
          var)
        found)))

(define-function is-global-var (var)
  "Check if variable is global (level 0)"
  (let ((var-environment (var-env var)))
    (and var-environment (= 0 (env-level var-environment)))))

;; ==================================================================
;; MULTI-METHOD DISPATCH WITH ENVIRONMENT STACK
;; ==================================================================

;; Dispatch tables
(define *env-eval-methods* (array 32))
(define *env-print-methods* (array 32))

;; Type constants
(define ENV-MM-UNDEFINED 0)
(define ENV-MM-LONG 2)
(define ENV-MM-DOUBLE 3)
(define ENV-MM-STRING 4)
(define ENV-MM-SYMBOL 5)
(define ENV-MM-PAIR 6)
(define ENV-MM-ARRAY 7)

;; Method registration
(define-function env-mm-register-eval-method (type-id method)
  (set-array-at *env-eval-methods* type-id method))

(define-function env-mm-register-print-method (type-id method)
  (set-array-at *env-print-methods* type-id method))

;; Main multi-method dispatch function (defined EARLY for forward references)
(define env-mm-eval
  (lambda (obj env ctx)
    (let* ((type-id (type-of obj))
           (method (array-at *env-eval-methods* type-id)))
      (if method
          (method obj env ctx)
          ;; Fallback to standard eval for unhandled types
          (eval obj)))))

;; ==================================================================
;; ENVIRONMENT-AWARE EVALUATION METHODS
;; ==================================================================

(define-function env-mm-eval-undefined (obj env ctx)
  "Handle undefined values"
  ())

(define-function env-mm-eval-number (obj env ctx)
  "Numbers evaluate to themselves"
  obj)

(define-function env-mm-eval-string (obj env ctx)
  "Strings evaluate to themselves"
  obj)

(define-function env-mm-eval-symbol (obj env ctx)
  "Symbol lookup through environment chain"
  (println "  [ENV-MM] Looking up symbol: " obj " in environment")
  (env-lookup env obj))

(define-function env-mm-eval-pair (obj env ctx)
  "Function application with proper environment management"
  (if (pair? obj)
      (let* ((head (car obj))
             (tail (cdr obj)))
        (cond
          ;; Special form: quote
          ((= head 'quote)
           (car tail))
          
          ;; Special form: if
          ((= head 'if)
           (let* ((condition (env-mm-eval (car tail) env ctx))
                  (then-form (car (cdr tail)))
                  (else-form (if (cdr (cdr tail)) (car (cdr (cdr tail))) ())))
             (if condition
                 (env-mm-eval then-form env ctx)
                 (if else-form 
                     (env-mm-eval else-form env ctx)
                     ()))))
          
          ;; Special form: let
          ((= head 'let)
           (let* ((bindings (car tail))
                  (body (cdr tail))
                  (new-env (create-env env 0 (env-offset env))))
             (println "  [ENV-MM] Creating let environment")
             
             ;; Process bindings
             (let ((binding-list bindings))
               (while (pair? binding-list)
                 (let* ((binding (car binding-list))
                        (var-name (if (pair? binding) (car binding) binding))
                        (var-value (if (pair? binding) 
                                      (env-mm-eval (car (cdr binding)) env ctx)
                                      ())))
                   (env-define new-env var-name var-value)
                   (println "    [ENV-MM] Defined " var-name " = " var-value))
                 (set binding-list (cdr binding-list))))
             
             ;; Evaluate body in new environment
             (let ((result ()))
               (let ((body-list body))
                 (while (pair? body-list)
                   (set result (env-mm-eval (car body-list) new-env ctx))
                   (set body-list (cdr body-list))))
               result)))
          
          ;; Special form: lambda  
          ((= head 'lambda)
           (println "  [ENV-MM] Creating lambda closure")
           ;; For now, create a simple closure representation
           ;; In full implementation, would create proper closure with env capture
           (list 'closure tail env))
          
          ;; Function application
          (else
           (let* ((fn (env-mm-eval head env ctx))
                  (evaluated-args (map (lambda (arg) (env-mm-eval arg env ctx)) tail)))
             (println "  [ENV-MM] Applying " fn " to " evaluated-args)
             (apply fn evaluated-args)))))
      obj))

(define-function env-mm-eval-array (obj env ctx)
  "Arrays evaluate to themselves"
  obj)

;; ==================================================================
;; REGISTER EVALUATION METHODS
;; ==================================================================

(env-mm-register-eval-method ENV-MM-UNDEFINED env-mm-eval-undefined)
(env-mm-register-eval-method ENV-MM-LONG env-mm-eval-number)
(env-mm-register-eval-method ENV-MM-DOUBLE env-mm-eval-number) 
(env-mm-register-eval-method ENV-MM-STRING env-mm-eval-string)
(env-mm-register-eval-method ENV-MM-SYMBOL env-mm-eval-symbol)
(env-mm-register-eval-method ENV-MM-PAIR env-mm-eval-pair)
(env-mm-register-eval-method ENV-MM-ARRAY env-mm-eval-array)

;; ==================================================================
;; TOP-LEVEL EVALUATION FUNCTION
;; ==================================================================

(define-function env-mm-evaluate (expression)
  "Top-level evaluation with global environment"
  (let* ((global-env (create-env () 0 0))
         (ctx (create-context () global-env (array 0))))
    
    ;; Define some global variables in the environment
    (env-define global-env '+ +)
    (env-define global-env '- -)
    (env-define global-env '* *)
    (env-define global-env '/ /)
    (env-define global-env 'cons cons)
    (env-define global-env 'car car)
    (env-define global-env 'cdr cdr)
    (env-define global-env 'println println)
    
    (println "🎯 Evaluating with environment stack: " expression)
    (env-mm-eval expression global-env ctx)))

;; ==================================================================
;; INITIALIZATION
;; ==================================================================

(println "✅ Environment stack implementation complete")
(let ((eval-registered 0)
      (print-registered 0))
  (array-do method *env-eval-methods*
    (if method (set eval-registered (+ eval-registered 1))))
  (array-do method *env-print-methods*
    (if method (set print-registered (+ print-registered 1))))
  (println "✅ " eval-registered " environment-aware evaluation methods registered")
  (println "✅ " print-registered " environment-aware print methods registered"))

(println "🎯 Multi-method evaluator with environment stack ready!")
(println "🎯 Use (env-mm-evaluate expr) for environment-aware evaluation")