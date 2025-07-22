;;; emit-consolidated.l -- Clean multi-method based emit system
;;; Consolidates all C generation code into proper multi-method dispatch

;; (require "osdefs.k")  ; Not needed for basic testing

;;; ============================================================================
;;; CORE EMIT FRAMEWORK (from emit.l)
;;; ============================================================================

(define __PREFIX__ (if (or (defined? '__MACH__) (defined? '__WIN32__)) "_" ""))

(define-function string->type-name (str) (string->symbol (concat-string "<" (concat-string str ">"))))
(define-function symbol->type-name (sym) (string->type-name (symbol->string sym)))
(define-function align (alignment value) (& (- alignment) (+ (- alignment 1) value)))

;;; Backend Types - Clean separation using types instead of symbols
(define-structure <x86-backend> ())
(define-structure <c-backend> (pass functions current-function current-params))

;;; Global backend instances
(define *x86-backend* (new <x86-backend>))
(define *c-backend* (let ((backend (new <c-backend>)))
                       (set (<c-backend>-pass backend) 1)
                       (set (<c-backend>-functions backend) ())
                       (set (<c-backend>-current-function backend) "unknown")
                       (set (<c-backend>-current-params backend) ())
                       backend))

;;; Current active backend
(define *active-backend* *x86-backend*)

;;; Backend switching
(define-function use-x86-backend () (set *active-backend* *x86-backend*))
(define-function use-c-backend () (set *active-backend* *c-backend*))

;;; ============================================================================
;;; INSTRUCTION TYPES
;;; ============================================================================

(define-form define-instruction (name)
  (let* ((sname (symbol->string name))
         (tname (string->symbol (concat-string "<" (concat-string sname ">")))))
    `(let ()
       (define-structure ,tname ())
       (define-method do-print ,tname () (print ,sname))
       (define ,name (new ,tname)))))

;; Core instructions
(define-instruction TEXT)
(define-instruction DATA)
(define-instruction DEFLABEL)
(define-instruction ENTER)
(define-instruction LEAVE)
(define-instruction LOAD)
(define-instruction CALL)

;;; ============================================================================
;;; MULTI-METHOD EMIT SYSTEM
;;; ============================================================================

(define-generic emit backend-instruction-args
  (error "emit: no method for " (type-of (car backend-instruction-args)) 
         " with " (type-of (cadr backend-instruction-args))))

;; Helper to emit with current backend
(define-function emit-with-backend args
  (apply emit (cons *active-backend* args)))

;; Program emission (sequence of instructions) - removed for now due to syntax issues

;;; ============================================================================
;;; X86 BACKEND METHODS
;;; ============================================================================

(define-multimethod emit ((<x86-backend> backend) (<TEXT> instr))
  (println "\t.text"))

(define-multimethod emit ((<x86-backend> backend) (<DATA> instr))
  (println "\t.data"))

(define-multimethod emit ((<x86-backend> backend) (<DEFLABEL> instr) label)
  (println) 
  (println label ":"))

(define-multimethod emit ((<x86-backend> backend) (<ENTER> instr) size)
  (println "\tpushl %ebp")
  (println "\tmovl %esp,%ebp")
  (println "\tsubl $" size ",%esp"))

(define-multimethod emit ((<x86-backend> backend) (<LEAVE> instr) size)
  (println "\tmovl %ebp,%esp")
  (println "\tpopl %ebp")
  (println "\tretl"))

(define-multimethod emit ((<x86-backend> backend) (<LOAD> instr) operand)
  (println "\tmovl $" operand ",%eax"))

(define-multimethod emit ((<x86-backend> backend) (<CALL> instr) nargs)
  (println "\tcall *%eax"))

;;; ============================================================================
;;; C BACKEND METHODS  
;;; ============================================================================

;; C Backend helper functions
(define-function c-indent (backend)
  (let ((level (or (<c-backend>-indent-level backend) 0)))
    (for (i 0 level) (print "    "))))

(define-function c-gen-preamble (backend)
  (println "/* Generated C code */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>") 
  (println "#include \"gc.h\"")
  (println)
  (println "typedef void *oop;")
  (println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (println "#define IS_LONG(obj) ((long)(obj) & 1)")
  (println "#define GC_PROTECT(var) GC_add_root((void*)&(var))")
  (println "#define GC_UNPROTECT(var) GC_delete_root((void*)&(var))")
  (println))

(define-function c-gen-forward-declarations (backend)
  (println "/* Forward declarations */")
  (let ((funcs (<c-backend>-functions backend)))
    (while (pair? funcs)
      (let* ((func-info (car funcs))
             (name (car func-info))
             (params (cadr func-info)))
        (print "static oop " name "(")
        (if (pair? params)
            (let ((first 't))
              (while (pair? params)
                (if first (set first ()) (print ", "))
                (print "oop " (symbol->string (car params)))
                (set params (cdr params))))
          (print "void"))
        (println ");"))
      (set funcs (cdr funcs))))
  (println))

;; C emit methods
(define-multimethod emit ((<c-backend> backend) (<TEXT> instr))
  (if (= (<c-backend>-pass backend) 2)
      (println "/* TEXT section */")))

(define-multimethod emit ((<c-backend> backend) (<DATA> instr))
  (if (= (<c-backend>-pass backend) 2)
      (println "/* DATA section */")))

(define-multimethod emit ((<c-backend> backend) (<DEFLABEL> instr) label)
  (if (= (<c-backend>-pass backend) 2)
      (let ()
        (println)
        (print label ":")
        (set (<c-backend>-current-function backend) (symbol->string label)))))

(define-multimethod emit ((<c-backend> backend) (<ENTER> instr) size)
  (if (= (<c-backend>-pass backend) 2)
      (let ((params (<c-backend>-current-params backend)))
        (println)
        (print "static oop " (<c-backend>-current-function backend) "(")
        (if (pair? params)
            (let ((first 't))
              (while (pair? params)
                (if first (set first ()) (print ", "))
                (print "oop " (symbol->string (car params)))
                (set params (cdr params))))
          (print "void"))
        (println ") {")
        (println "    oop _acc = LONG(0);")
        (println "    /* locals: " size " bytes */"))))

(define-multimethod emit ((<c-backend> backend) (<LEAVE> instr) size)
  (if (= (<c-backend>-pass backend) 2)
      (let ()
        (println "    return _acc;")
        (println "}"))))

(define-multimethod emit ((<c-backend> backend) (<LOAD> instr) value)
  (if (= (<c-backend>-pass backend) 2)
      (println "    _acc = " value ";")))

(define-multimethod emit ((<c-backend> backend) (<CALL> instr) nargs)
  (if (= (<c-backend>-pass backend) 2)
      (println "    /* CALL with " nargs " args */")))

;;; ============================================================================
;;; COMPILATION FRAMEWORK (simplified from emit.l)
;;; ============================================================================

;; Environment and compiler structures (simplified)
(define-structure <env> (parent level offset bindings))
(define-structure <variable> (name value env index))
(define-structure <compiler> (level))

(define-function environment (parent)
  (let ((self (new <env>)))
    (set (<env>-parent self) parent)
    (set (<env>-bindings self) (array))
    self))

(define-function variable (name value env index)
  (let ((self (new <variable>)))
    (set (<variable>-name self) name)
    (set (<variable>-value self) value)
    (set (<variable>-env self) env)
    (set (<variable>-index self) index)
    self))

(define-function compiler (level)
  (let ((self (new <compiler>)))
    (set (<compiler>-level self) level)
    self))

;;; ============================================================================
;;; TWO-PASS C GENERATION (consolidated)
;;; ============================================================================

(define-generic gen-definition value-name-comp
  (error "gen-definition: no method for " (type-of (car value-name-comp))))

;; For functions (expressions with lambda)
(define-structure <expr> (defn))

(define-multimethod gen-definition ((<expr> expr) name comp)
  (let* ((defn (<expr>-defn expr))
         (params (cadr defn))
         (body (cddr defn)))
    (if (= (type-of *active-backend*) <c-backend>)
        ;; C backend: two-pass generation
        (if (= (<c-backend>-pass *active-backend*) 1)
            ;; Pass 1: collect function info
            (let ((param-names (map (lambda (p) (<variable>-name p)) params)))
              (set (<c-backend>-functions *active-backend*)
                   (cons (list name param-names body) 
                         (<c-backend>-functions *active-backend*))))
          ;; Pass 2: generate code
          (let ()
            (set (<c-backend>-current-params *active-backend*) 
                 (cadr (find-function *active-backend* name)))
            (emit-with-backend DEFLABEL name)
            (emit-with-backend ENTER 16)
            ;; Generate body (simplified for now)
            (println "    _acc = 42; /* TODO: compile body */")
            (emit-with-backend LEAVE 16)))
      ;; X86 backend: direct generation
      (let ()
        (emit-with-backend TEXT)
        (emit-with-backend DEFLABEL name)
        (emit-with-backend ENTER 16)
        (emit-with-backend LEAVE 16)))))

;; Helper to find function in C backend
(define-function find-function (backend name)
  (let ((funcs (<c-backend>-functions backend))
        (result ()))
    (while (and (pair? funcs) (not result))
      (if (= name (car (car funcs)))
          (set result (car funcs)))
      (set funcs (cdr funcs)))
    result))

;; Environment compilation with proper multi-method dispatch
(define-function gen-env (env)
  (let* ((vars (<env>-bindings env))
         (comp (compiler 0))
         (index (array-length vars)))
    (if (= (type-of *active-backend*) <c-backend>)
        ;; C backend: two-pass
        (let ()
          ;; Pass 1: collect
          (set (<c-backend>-pass *active-backend*) 1)
          (set (<c-backend>-functions *active-backend*) ())
          (while (<= 0 (set index (- index 1)))
            (let ((name (<variable>-name (array-at vars index)))
                  (value (<variable>-value (array-at vars index))))
              (gen-definition value name comp)))
          ;; Generate preamble and declarations
          (c-gen-preamble *active-backend*)
          (c-gen-forward-declarations *active-backend*)
          ;; Pass 2: generate
          (set (<c-backend>-pass *active-backend*) 2)
          (set index (array-length vars))
          (while (<= 0 (set index (- index 1)))
            (let ((name (<variable>-name (array-at vars index)))
                  (value (<variable>-value (array-at vars index))))
              (gen-definition value name comp))))
      ;; X86 backend: single pass
      (while (<= 0 (set index (- index 1)))
        (let ((name (<variable>-name (array-at vars index)))
              (value (<variable>-value (array-at vars index))))
          (gen-definition value name comp))))))

;;; ============================================================================
;;; COMPILE BEGIN/END (simplified)
;;; ============================================================================

(define *globals* ())

(define-form compile-begin ()
  `(set *globals* (environment *globals*)))

(define-form compile-end ()
  `(let ((env *globals*))
     (set *globals* (<env>-parent env))
     (gen-env env)))

;;; ============================================================================
;;; CONVENIENCE FUNCTIONS
;;; ============================================================================

(define-function environment-define (env name value)
  "Add a binding to an environment"
  (let ((var (variable name value env 0))
        (bindings (<env>-bindings env)))
    (array-append bindings var)))

(println "emit-consolidated.l loaded - clean multi-method architecture ready")