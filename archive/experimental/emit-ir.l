;;; emit-ir.l - Emit using IR infrastructure
;;;
;;; This is a modern implementation of emit.l that uses Maru's IR system
;;; instead of direct code generation. It provides a cleaner abstraction
;;; and supports multiple backends through the IR infrastructure.

(require "boot.l")

;; Define missing functions
(define-function array-last (arr)
  (if (< 0 (array-length arr))
      (array-at arr (- (array-length arr) 1))))

(define-function array-append-all (dest src)
  (array-do item src
    (array-append dest item))
  dest)

(require "core/compiler/ir.k")
(require "core/compiler/ir2.k")
(require "core/compiler/scope.k")

;;; Global IR context
(define *ir-context* ())
(define *ir-function* ())
(define *ir-locals* ())
(define *ir-scope* ())

;;; Initialize IR system
(define-function ir-initialize ()
  (set *ir-context* (ir-new <ir> ()))
  (set *ir-scope* (scope-new ()))
  
  ;; Define built-in types
  (ir-declare *ir-context* 'oop (ir-pointer-to IR-VOID))
  (ir-declare *ir-context* 'long IR-LONG)
  (ir-declare *ir-context* 'char IR-INT8)
  (ir-declare *ir-context* 'void IR-VOID))

;;; Environment management
(define-structure <ir-env> (parent level offset bindings))

(define-function ir-env-new (parent)
  (let ((env (new <ir-env>)))
    (set (<ir-env>-parent env) parent)
    (set (<ir-env>-level env) (if parent (+ (<ir-env>-level parent) 1) 0))
    (set (<ir-env>-offset env) 0)
    (set (<ir-env>-bindings env) (array))
    env))

(define-function ir-env-define (env name type)
  (let* ((offset (<ir-env>-offset env))
         (var (new <ir-local> name type)))
    (set (<ir-local>-offset var) offset)
    (array-append (<ir-env>-bindings env) var)
    (set (<ir-env>-offset env) (+ offset (ir-type-size type)))
    var))

(define-function ir-env-lookup (env name)
  (let ((bindings (<ir-env>-bindings env)))
    (array-do var bindings
      (if (= name (<ir-variable>-name var))
          (return var)))
    (if (<ir-env>-parent env)
        (ir-env-lookup (<ir-env>-parent env) name))))

;;; IR instruction builders
(define-function ir-make-literal (value type)
  (new <ir-literal> () () type value))

(define-function ir-make-get-var (var)
  (new <ir-get-var> () () (<ir-variable>-type var) var))

(define-function ir-make-set-var (var value)
  (new <ir-set-var> () (list value) IR-VOID var))

(define-function ir-make-get-arg (index type)
  (new <ir-get-arg> () () type index))

(define-function ir-make-call (func args)
  (new <ir-call> () (cons func args) (<ir-function>-type func)))

(define-function ir-make-if (condition then-part else-part)
  (new <ir-if> () (list condition then-part else-part) IR-VOID))

(define-function ir-make-while (condition body)
  (new <ir-while> () (list condition body) IR-VOID))

(define-function ir-make-return (value)
  (new <ir-return> () (list value) IR-VOID))

(define-function ir-make-block (statements)
  (new <ir-block> () statements IR-VOID))

;;; Expression compilation to IR
(define-function compile-expr (expr env)
  (cond
    ;; Literals
    ((long? expr)
     (ir-make-literal expr IR-LONG))
    
    ((string? expr)
     (ir-make-literal expr IR-STRING))
    
    ;; Variables
    ((symbol? expr)
     (let ((var (ir-env-lookup env expr)))
       (if var
           (ir-make-get-var var)
           (error "Undefined variable: " expr))))
    
    ;; Lists (function calls, special forms)
    ((pair? expr)
     (let ((head (car expr))
           (args (cdr expr)))
       (cond
         ;; Special form: quote
         ((= head 'quote)
          (ir-make-literal (car args) (ir-pointer-to IR-VOID)))
         
         ;; Special form: if
         ((= head 'if)
          (let ((cond-ir (compile-expr (car args) env))
                (then-ir (compile-expr (car (cdr args)) env))
                (else-ir (if (cdr (cdr args))
                            (compile-expr (car (cdr (cdr args))) env)
                            (ir-make-literal 0 IR-VOID))))
            (ir-make-if cond-ir then-ir else-ir)))
         
         ;; Special form: let
         ((= head 'let)
          (let* ((bindings (car args))
                 (body (cdr args))
                 (new-env (ir-env-new env))
                 (bind-stmts (array)))
            ;; Process bindings
            (list-do binding bindings
              (let* ((name (if (pair? binding) (car binding) binding))
                     (init (if (pair? binding) 
                              (compile-expr (car (cdr binding)) env)
                              (ir-make-literal 0 IR-VOID)))
                     (var (ir-env-define new-env name IR-LONG)))
                (array-append bind-stmts (ir-make-set-var var init))))
            ;; Compile body in new environment
            (let ((body-stmts (map (lambda (stmt) (compile-expr stmt new-env)) body)))
              (ir-make-block (array-append-all bind-stmts body-stmts)))))
         
         ;; Special form: define
         ((= head 'define)
          (let* ((name (car args))
                 (value (compile-expr (car (cdr args)) env))
                 (var (or (ir-env-lookup env name)
                         (ir-env-define env name IR-LONG))))
            (ir-make-set-var var value)))
         
         ;; Function calls
         (else
          (let ((func (ir-env-lookup env head)))
            (if (and func (inherits-from (type-of func) <ir-function>))
                (let ((arg-irs (map (lambda (arg) (compile-expr arg env)) args)))
                  (ir-make-call func arg-irs))
                (error "Unknown function: " head)))))))
    
    ;; Default
    (else
     (error "Cannot compile expression: " expr))))

;;; Function compilation
(define-function compile-function (name params body)
  (let* ((param-types (map (lambda (p) IR-LONG) params))
         (func-type (ir-function-type IR-LONG param-types))
         (func (ir-declare *ir-context* name func-type <ir-function>))
         (env (ir-env-new ()))
         (param-vars (array)))
    
    ;; Create parameter bindings
    (list-do-with-index (param idx) params
      (let ((var (ir-env-define env param IR-LONG)))
        (array-append param-vars var)))
    
    ;; Set function parameters
    (set (<ir-function>-parameters func) params)
    
    ;; Compile body
    (let ((body-stmts (map (lambda (stmt) (compile-expr stmt env)) body)))
      (set (<ir-function>-body func) (ir-make-block body-stmts)))
    
    ;; Add to program
    (array-append (<ir>-program *ir-context*) func)
    func))

;;; Top-level compilation
(define-function compile-toplevel (expr)
  (cond
    ;; Function definition
    ((and (pair? expr) (= (car expr) 'define-function))
     (let* ((name (car (cdr expr)))
            (params (car (cdr (cdr expr))))
            (body (cdr (cdr (cdr expr)))))
       (compile-function name params body)))
    
    ;; Global definition
    ((and (pair? expr) (= (car expr) 'define))
     (let* ((name (car (cdr expr)))
            (value (car (cdr (cdr expr))))
            (var (ir-declare *ir-context* name IR-LONG)))
       (array-append (<ir>-program *ir-context*) 
                     (ir-make-set-var var (compile-expr value (ir-env-new ()))))))
    
    ;; Other expressions (compile as statements in main)
    (else
     (if (not *ir-function*)
         (set *ir-function* (compile-function 'main () ())))
     (let ((stmt (compile-expr expr (ir-env-new ()))))
       (array-append (<ir-function>-body *ir-function*) stmt)))))

;;; Backend selection and code generation
(define-function emit-ir-to-c ()
  (require "core/compiler/ir-gen-c.k")
  (ir-gen-c *ir-context*))

(define-function emit-ir-to-x86 ()
  (require "core/compiler/ir-gen-x86.k")
  (ir-gen-x86 *ir-context*))

(define-function emit-ir-to-arm64 ()
  (require "core/compiler/ir-gen-arm64.k")
  (ir-gen-arm64 *ir-context*))

;;; Main entry point
(define-function emit-with-ir (expressions . options)
  (ir-initialize)
  
  ;; Compile all expressions
  (list-do expr expressions
    (compile-toplevel expr))
  
  ;; Generate code based on target
  (let ((target (or (car options) 'c)))
    (cond
      ((= target 'c)      (emit-ir-to-c))
      ((= target 'x86)    (emit-ir-to-x86))
      ((= target 'arm64)  (emit-ir-to-arm64))
      (else (error "Unknown target: " target)))))

;;; Compatibility layer with original emit.l interface
(define-function emit args
  ;; For now, just compile everything to C
  (emit-with-ir args 'c))

(println "emit-ir.l loaded - IR-based code generation ready")
(println "Usage: (emit-with-ir expressions [target])")
(println "Targets: 'c, 'x86, 'arm64")