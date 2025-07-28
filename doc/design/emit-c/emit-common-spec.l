;;; emit-common.l - Target-independent compilation logic
;;; 
;;; This file contains the core compilation infrastructure that works
;;; across all backend targets (C, x86, ARM64, etc.)

(require "osdefs.k")

;;; ================================================================
;;; CORE DATA STRUCTURES (unchanged from current emit.l)
;;; ================================================================

(define-structure <variable> (name value env index))
(define-structure <environment> (parent level offset bindings))  
(define-structure <extern> (name stub))
(define-structure <compiler> (level temps args))

;;; ================================================================
;;; BACKEND ABSTRACTION SYSTEM
;;; ================================================================

(define-structure <backend> (name output-port state features))

;;; Backend lifecycle generics
(define-generic backend-initialize (backend output-port))
(define-generic backend-finalize (backend))
(define-generic backend-supports-feature? (backend feature))

;;; ================================================================
;;; COMPILATION GENERICS - The Multi-Method Interface
;;; ================================================================

;;; Expression compilation
(define-generic compile-expression (backend expr compiler))
(define-generic compile-literal (backend value type))
(define-generic compile-variable-ref (backend var compiler))
(define-generic compile-function-call (backend func args compiler))
(define-generic compile-arithmetic (backend op args compiler))
(define-generic compile-comparison (backend op args compiler))
(define-generic compile-logical (backend op args compiler))

;;; Statement compilation  
(define-generic compile-statement (backend stmt compiler))
(define-generic compile-assignment (backend target value compiler))
(define-generic compile-conditional (backend test then else compiler))
(define-generic compile-loop (backend type test body compiler))
(define-generic compile-return (backend value compiler))

;;; Function compilation
(define-generic compile-function (backend name params body compiler))
(define-generic compile-function-prologue (backend func-info))
(define-generic compile-function-epilogue (backend func-info))

;;; Low-level instruction emission
(define-generic emit-instruction (backend instruction))
(define-generic emit-move (backend dest src))
(define-generic emit-call (backend target args))
(define-generic emit-label (backend name))
(define-generic emit-jump (backend target condition))

;;; ================================================================
;;; TARGET-INDEPENDENT COMPILATION LOGIC  
;;; ================================================================

;;; Temporary variable management (backend-agnostic)
(define-function new-temp (comp)
  (let ((temp (new <TI32>)))
    (if (< 0 (length (<compiler>-temps comp)))
        (let ((old (pop (<compiler>-temps comp))))
          (set (<TI32>-offset temp) (<TI32>-offset old)))
      (let ((offset (align 4 (<compiler>-level comp))))
        (set (<TI32>-offset temp) offset)
        (set (<compiler>-level comp) (+ offset 4))))
    temp))

;;; Environment management (unchanged)
(define-function environment (parent)
  (let ((self (new <env>)))
    (set (<env>-parent   self) parent)
    (set (<env>-level    self) (if parent (<env>-level  parent) 0))
    (set (<env>-offset   self) 0)
    (set (<env>-bindings self) (array))
    self))

;;; Generic compilation functions that delegate to backends
(define-function gen-tmp-prog (prog comp backend)
  "Compile a sequence of expressions, returning last result"
  (if (pair? prog)
      (if (pair? (cdr prog))
          (let ()
            (compile-expression backend (car prog) comp)
            (gen-tmp-prog (cdr prog) comp backend))
          (compile-expression backend (car prog) comp))
      (compile-literal backend prog 'symbol)))

(define-function gen-let (expr comp backend)
  "Compile let binding construct"
  (let ((bindings (caddr expr))
        (body (cdddr expr)))
    ;; Compile bindings
    (list-do binding bindings
      (let ((var-name (car binding))
            (var-value (cadr binding)))
        (let ((temp (compile-expression backend var-value comp)))
          ;; Add to environment
          (environment-bind var-name temp))))
    ;; Compile body
    (gen-tmp-prog body comp backend)))

(define-function gen-if (expr comp backend)
  "Compile conditional expression"
  (let ((test (cadr expr))
        (then-branch (caddr expr))
        (else-branch (if (cdddr expr) (cadddr expr) '())))
    (compile-conditional backend test then-branch else-branch comp)))

(define-function gen-while (expr comp backend)
  "Compile while loop"
  (let ((test (cadr expr))
        (body (cddr expr)))
    (compile-loop backend 'while test body comp)))

;;; ================================================================
;;; BACKEND FACTORY AND SELECTION
;;; ================================================================

(define *available-backends* '(c x86 arm64))
(define *default-backend* 'c)  ; C is default for portability
(define *current-backend* ())

(define-function create-backend (type output-port)
  "Factory function to create backend instances"
  (case type
    (c (require "core/compiler/emit-c.l")
       (new-c-backend output-port))
    (x86 (require "emit-x86.l")
         (new-x86-backend output-port))
    (arm64 (require "emit-arm64.l")
           (new-arm64-backend output-port))
    (else (error "Unknown backend type: " type))))

(define-function set-compilation-target (target)
  "Set the default compilation target"
  (if (member target *available-backends*)
      (set *default-backend* target)
      (error "Unsupported backend: " target)))

;;; ================================================================
;;; MAIN COMPILATION INTERFACE
;;; ================================================================

(define-function encode-with-backend (backend-type expr)
  "Compile expression using specified backend"
  (let ((backend (create-backend backend-type (current-output-port)))
        (compiler (compiler 0)))
    (backend-initialize backend (current-output-port))
    (compile-expression backend expr compiler)
    (backend-finalize backend)))

(define-function encode (expr)
  "Compile expression using default backend"
  (encode-with-backend *default-backend* expr))

;;; ================================================================
;;; UTILITY FUNCTIONS (target-independent)
;;; ================================================================

(define-function mangle-identifier (name)
  "Create safe identifier name (backend may override)"
  (let ((str (symbol->string name)))
    ;; Basic mangling - backends can override
    (string->symbol (concat-string "_maru_" str))))

(define-function temp-counter ()
  "Generate unique temporary numbers"
  (let ((counter (or (defined? '*temp-counter*) 0)))
    (set *temp-counter* (+ counter 1))
    counter))

;;; ================================================================
;;; EXPRESSION TYPE CLASSIFICATION
;;; ================================================================

(define-function literal? (expr)
  "Test if expression is a literal value"
  (or (long? expr) (string? expr) (null? expr)))

(define-function variable-ref? (expr)
  "Test if expression is a variable reference"
  (symbol? expr))

(define-function function-call? (expr)
  "Test if expression is a function call"
  (and (pair? expr) (symbol? (car expr))))

(define-function special-form? (expr)
  "Test if expression is a special form"
  (and (pair? expr) 
       (member (car expr) '(let if while set lambda quote))))

;;; ================================================================
;;; DEBUGGING AND INTROSPECTION
;;; ================================================================

(define-function dump-backend-info (backend)
  "Display information about a backend"
  (println "Backend: " (<backend>-name backend))
  (println "Features: " (<backend>-features backend))
  (println "State: " (<backend>-state backend)))

(define-function list-available-backends ()
  "List all available compilation backends"
  *available-backends*)

;;; Export the main interface
(export encode encode-with-backend set-compilation-target 
        list-available-backends create-backend)