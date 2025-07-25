;; -*- coke -*-
;; Linter for the Lisp dialect

;; Core linter structures
(define-structure <lint-issue> (type message expr location))
(define-structure <lint-type> (name predicate))
(define-structure <lint-scope> (parent bindings))
(define-structure <linter> (environment warnings errors special-forms type-info scope-stack))

;; Type system
(define-function make-type-info ()
  (let ((types (array)))
    (set-array-at types 'number  (new <lint-type> 'number  (lambda (x) (or (long? x) (double? x)))))
    (set-array-at types 'string  (new <lint-type> 'string  string?))
    (set-array-at types 'symbol  (new <lint-type> 'symbol  symbol?))
    (set-array-at types 'pair    (new <lint-type> 'pair    pair?))
    (set-array-at types 'array   (new <lint-type> 'array   array?))
    types))

;; Special form validators
(define-function make-special-form-validators ()
  (let ((validators (array)))
    ;; define validator
    (set-array-at validators 'define 
      (lambda (linter form)
        (or (>= (list-length form) 3)
            (add-error linter "Define requires name and value" form))
        (let ((name (cadr form))
              (value (caddr form)))
          (or (symbol? name)
              (add-error linter "Define requires symbol name" form))
          (lint-expression linter value))))
    
    ;; lambda validator  
    (set-array-at validators 'lambda
      (lambda (linter form)
        (or (>= (list-length form) 2)
            (add-error linter "Lambda requires args and body" form))
        (let ((args (cadr form))
              (body (cddr form)))
          (push-scope linter)
          (when (pair? args)
            (for-each arg args
              (or (symbol? arg)
                  (add-error linter "Lambda arg must be symbol" arg))
              (add-binding linter arg)))
          (for-each expr body
            (lint-expression linter expr))
          (pop-scope linter))))
    
    ;; let validator
    (set-array-at validators 'let
      (lambda (linter form)
        (or (>= (list-length form) 2)
            (add-error linter "Let requires bindings and body" form))
        (let ((bindings (cadr form))
              (body (cddr form)))
          (push-scope linter)
          (when (pair? bindings)
            (for-each binding bindings
              (or (and (pair? binding) (= 2 (list-length binding)))
                  (add-error linter "Invalid let binding" binding))
              (let ((name (car binding))
                    (value (cadr binding)))
                (or (symbol? name)
                    (add-error linter "Let binding name must be symbol" name))
                (lint-expression linter value)
                (add-binding linter name))))
          (for-each expr body
            (lint-expression linter expr))
          (pop-scope linter))))

    ;; quasiquote validator
    (set-array-at validators 'quasiquote
      (lambda (linter form)
        (or (= 2 (list-length form))
            (add-error linter "Quasiquote requires one argument" form))))

    ;; unquote validator  
    (set-array-at validators 'unquote
      (lambda (linter form)
        (or (= 2 (list-length form))
            (add-error linter "Unquote requires one argument" form))))

    ;; unquote-splicing validator
    (set-array-at validators 'unquote-splicing
      (lambda (linter form)
        (or (= 2 (list-length form))
            (add-error linter "Unquote-splicing requires one argument" form))))
    
    validators))

;; Linter creation
(define-function create-linter ()
  (let ((linter (new <linter>)))
    (set (<linter>-environment linter) (new <lint-scope> () (array)))
    (set (<linter>-warnings linter) (array))
    (set (<linter>-errors linter) (array))
    (set (<linter>-special-forms linter) (make-special-form-validators))
    (set (<linter>-type-info linter) (make-type-info))
    (set (<linter>-scope-stack linter) (array))
    ;; Add core bindings
    (for-each binding '(define lambda let quasiquote unquote unquote-splicing)
      (add-binding linter binding))
    linter))

;; Scope management
(define-function push-scope (linter)
  (let ((scope (new <lint-scope> (<linter>-environment linter) (array))))
    (array-append (<linter>-scope-stack linter) (<linter>-environment linter))
    (set (<linter>-environment linter) scope)))

(define-function pop-scope (linter)
  (let ((stack (<linter>-scope-stack linter)))
    (when (> (array-length stack) 0)
      (set (<linter>-environment linter) 
           (array-at stack (- (array-length stack) 1)))
      (set-array-length stack (- (array-length stack) 1)))))

(define-function add-binding (linter name)
  (array-append (<lint-scope>-bindings (<linter>-environment linter)) name))

(define-function lookup-binding (scope name)
  (let ((found ()))
    (when scope
      (let ((bindings (<lint-scope>-bindings scope)))
        (let ((i 0) (len (array-length bindings)))
          (while (and (not found) (< i len))
            (when (= name (array-at bindings i))
              (set found t))
            (set i (+ i 1)))))
      (or found
          (lookup-binding (<lint-scope>-parent scope) name)))
    found))

;; Issue reporting
(define-function add-error (linter message expr)
  (array-append (<linter>-errors linter)
    (new <lint-issue> 'error message expr ())))

(define-function add-warning (linter message expr)
  (array-append (<linter>-warnings linter)
    (new <lint-issue> 'warning message expr ())))

(define-function print-issue (issue)
  (print (<lint-issue>-type issue) ": " (<lint-issue>-message issue) " in ")
  (dump (<lint-issue>-expr issue))
  (println))

(define-function report-issues (linter)
  (let ((errors (<linter>-errors linter))
        (warnings (<linter>-warnings linter)))
    (for-each error errors
      (print-issue error))
    (for-each warning warnings
      (print-issue warning))))

;; Main linting function
(define-function lint-expression (linter expr)
  (cond
    ;; Special forms
    ((and (pair? expr) (symbol? (car expr)))
     (let ((validator (array-at (<linter>-special-forms linter) (car expr))))
       (if validator
           (validator linter expr)
           (lint-function-call linter expr))))
    
    ;; Variables
    ((symbol? expr)
     (or (lookup-binding (<linter>-environment linter) expr)
         (add-warning linter "Undefined variable" expr)))
    
    ;; Lists
    ((pair? expr)
     (for-each e expr
       (lint-expression linter e)))
    
    ;; Literals are always valid
    ((or (number? expr) (string? expr))
     t)
    
    (else
      (add-error linter "Invalid expression" expr))))

(define-function lint-function-call (linter expr)
  (for-each arg (cdr expr)
    (lint-expression linter arg)))

;; File handling
(define-function lint-file (filename)
  ;; Skip core files
  (let ((linter (create-linter))
        (stream (or (open filename) (error "Cannot open file: " filename)))
        (success t))
    (let ((form))
      (while (and success (!= DONE (set form (read stream))))
        (lint-expression linter form)
        (set success (= 0 (array-length (<linter>-errors linter)))))
      (close stream)
      (report-issues linter)
      success)))

;; Eval integration
(define-function eval-with-lint (expr env)
  (let ((linter (create-linter)))
    (lint-expression linter expr)
    (when (= 0 (array-length (<linter>-errors linter)))
      (eval expr env))))

;; Export main functions
(define lint lint-expression)
(define lint-program lint-file)

;; Command line handling
(define-function main (argc argv)
  (let ((verbose 0)
        (repled 0))
    (while *arguments*
      (let ((arg (next-argument)))
        (cond
          ((string=? arg "-v") (set verbose (+ verbose 1)))
          (else
            (println "Linting " arg "...")
            (if (lint-file arg)
                (println "No errors found.")
                (println "Linting failed."))
            (set repled 1)))))
    (when (= 0 repled)
      (println "Usage: " (car argv) " [-v] file...")
      (println "  -v  Verbose output"))))

;; Run main if this is the main script
(when *arguments*
  (main *argc* *argv*)) 