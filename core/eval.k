;;; eval.k - Typed, IR-based Maru evaluator
;;; 
;;; This implements the Maru evaluator using the typed .k infrastructure,
;;; compiling through the IR system to multiple backends.
;;;
;;; Based on eval.l but reimplemented with static typing and multi-methods.

(require "ir.k")
(require "maru.k")

;;; ================================================================
;;; Type System Bridge
;;; ================================================================

;; Type tags mirror eval.l's type system
(define-constant MARU-UNDEFINED  0)
(define-constant MARU-DATA       1)
(define-constant MARU-LONG       2)
(define-constant MARU-DOUBLE     3)
(define-constant MARU-STRING     4)
(define-constant MARU-SYMBOL     5)
(define-constant MARU-PAIR       6)
(define-constant MARU-ARRAY      8)
(define-constant MARU-EXPR       9)
(define-constant MARU-FORM      10)
(define-constant MARU-FIXED     11)
(define-constant MARU-SUBR      12)
(define-constant MARU-VARIABLE  13)
(define-constant MARU-ENV       14)
(define-constant MARU-CONTEXT   15)

;; Forward declarations for mutual recursion
(define-type maru-value  void*)
(define-type maru-pair   void*)
(define-type maru-array  void*)
(define-type maru-expr   void*)
(define-type maru-env    void*)
(define-type maru-context void*)

;; Universal value structure
(define-struct MValue (
  (tag  int32)
  (data void*)  ; Points to type-specific data
))

;; Type-specific structures
(define-struct MPair (
  (head maru-value)
  (tail maru-value)
))

(define-struct MArray (
  (size    int32)
  (capacity int32)
  (elements maru-value*)
))

(define-struct MString (
  (length int32)
  (data   char*)
))

(define-struct MSymbol (
  (name char*)
))

(define-struct MExpr (
  (defn maru-value)  ; (env formals . body)
  (ctx  maru-context)
))

(define-struct MVariable (
  (name  maru-value)
  (value maru-value)
  (env   maru-env)
  (index int32)
))

(define-struct MEnv (
  (parent   maru-env)
  (level    int32)
  (offset   int32)
  (bindings maru-array)
))

(define-struct MContext (
  (home     maru-context)
  (env      maru-env)
  (bindings maru-array)
))

(define-struct MSubr (
  (name char*)
  (impl void*)  ; Function pointer
))

(define-struct MForm (
  (function maru-value)
  (symbol   maru-value)
))

(define-struct MFixed (
  (function maru-value)
))

;;; ================================================================
;;; External Functions (GC and Runtime)
;;; ================================================================

(extern void*  gc_malloc         (int64))
(extern void*  gc_malloc_atomic  (int64))
(extern void   gc_push_root      (void**))
(extern void   gc_pop_root       (void**))
(extern void   gc_initialise     ())
(extern int    printf            (char* ...))
(extern int    fprintf           (void* char* ...))
(extern void*  memset            (void* int int64))
(extern void*  memcpy            (void* void* int64))
(extern void   exit              (int))
(extern int    strlen            (char*))
(extern char*  strdup            (char*))
(extern int    strcmp            (char* char*))

;;; ================================================================
;;; Global Variables and Constants
;;; ================================================================

(define symbols     maru-value 0)  ; Symbol table
(define globals     maru-value 0)  ; Global environment
(define evaluators  maru-value 0)  ; Type-indexed evaluator table
(define applicators maru-value 0)  ; Type-indexed applicator table

(define s_t         maru-value 0)  ; Symbol 't'
(define s_quote     maru-value 0)  ; Symbol 'quote'
(define s_lambda    maru-value 0)  ; Symbol 'lambda'
(define s_define    maru-value 0)  ; Symbol 'define'
(define s_set       maru-value 0)  ; Symbol 'set'
(define s_if        maru-value 0)  ; Symbol 'if'
(define s_let       maru-value 0)  ; Symbol 'let'

;;; ================================================================
;;; Memory Management
;;; ================================================================

(define-function maru-alloc ((tag int32) (size int64)) -> maru-value
  (let ((obj MValue* (cast MValue* (gc_malloc size))))
    (set obj.tag tag)
    (cast maru-value obj)))

(define-function maru-alloc-atomic ((tag int32) (size int64)) -> maru-value
  (let ((obj MValue* (cast MValue* (gc_malloc_atomic size))))
    (set obj.tag tag)
    (cast maru-value obj)))

;; GC protection helpers
(define-function gc-protect-1 ((v1 void**) (body void* ()) ) -> void*
  (gc_push_root v1)
  (let ((result void* (body)))
    (gc_pop_root v1)
    result))

(define-function gc-protect-2 ((v1 void**) (v2 void**) (body void* ())) -> void*
  (gc_push_root v1)
  (gc_push_root v2)
  (let ((result void* (body)))
    (gc_pop_root v2)
    (gc_pop_root v1)
    result))

;;; ================================================================
;;; Type Checking and Predicates
;;; ================================================================

(define-function maru-type-of ((obj maru-value)) -> int32
  (if obj
      (if (& (cast int64 obj) 1)  ; Tagged integer check
          MARU-LONG
        (cast MValue* obj).tag)
    MARU-UNDEFINED))

(define-function maru-nil? ((obj maru-value)) -> int32
  (= obj 0))

(define-function maru-pair? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-PAIR))

(define-function maru-symbol? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-SYMBOL))

(define-function maru-string? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-STRING))

(define-function maru-long? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-LONG))

(define-function maru-array? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-ARRAY))

(define-function maru-expr? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-EXPR))

(define-function maru-variable? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-VARIABLE))

(define-function maru-env? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-ENV))

(define-function maru-fixed? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-FIXED))

(define-function maru-subr? ((obj maru-value)) -> int32
  (= (maru-type-of obj) MARU-SUBR))

;;; ================================================================
;;; Tagged Integer Support
;;; ================================================================

(define-function maru-tagged-int? ((obj maru-value)) -> int32
  (& (cast int64 obj) 1))

(define-function maru-tag-int ((value int64)) -> maru-value
  (cast maru-value (| (<< value 1) 1)))

(define-function maru-untag-int ((obj maru-value)) -> int64
  (>> (cast int64 obj) 1))

(define-function maru-make-long ((value int64)) -> maru-value
  (maru-tag-int value))  ; Use tagged representation for small integers

(define-function maru-long-value ((obj maru-value)) -> int64
  (if (maru-tagged-int? obj)
      (maru-untag-int obj)
    0))  ; TODO: Handle boxed longs

;;; ================================================================
;;; Constructors
;;; ================================================================

(define-function maru-cons ((head maru-value) (tail maru-value)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-PAIR (sizeof MValue))))
         (pair MPair* (cast MPair* (gc-malloc (sizeof MPair)))))
    (set val.data (cast void* pair))
    (set pair.head head)
    (set pair.tail tail)
    (cast maru-value val)))

(define-function maru-car ((obj maru-value)) -> maru-value
  (if (maru-pair? obj)
      (cast MPair* (cast MValue* obj).data).head
    0))

(define-function maru-cdr ((obj maru-value)) -> maru-value
  (if (maru-pair? obj)
      (cast MPair* (cast MValue* obj).data).tail
    0))

(define-function maru-make-string ((cstr char*)) -> maru-value
  (let* ((len int32 (strlen cstr))
         (val MValue* (cast MValue* (maru-alloc MARU-STRING (sizeof MValue))))
         (str MString* (cast MString* (gc-malloc (sizeof MString))))
         (data char* (cast char* (gc_malloc_atomic (+ len 1)))))
    (set val.data (cast void* str))
    (set str.length len)
    (set str.data data)
    (memcpy data (cast void* cstr) (+ len 1))
    (cast maru-value val)))

(define-function maru-make-symbol ((name char*)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc-atomic MARU-SYMBOL (sizeof MValue))))
         (sym MSymbol* (cast MSymbol* (gc_malloc_atomic (sizeof MSymbol)))))
    (set val.data (cast void* sym))
    (set sym.name (strdup name))
    (cast maru-value val)))

(define-function maru-symbol-name ((obj maru-value)) -> char*
  (if (maru-symbol? obj)
      (cast MSymbol* (cast MValue* obj).data).name
    ""))

(define-function maru-make-array ((size int32)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-ARRAY (sizeof MValue))))
         (arr MArray* (cast MArray* (gc-malloc (sizeof MArray))))
         (cap int32 (if size size 1))
         (elems maru-value* (cast maru-value* (gc_malloc (* 8 cap)))))  ; 8 bytes per pointer
    (set val.data (cast void* arr))
    (set arr.size size)
    (set arr.capacity cap)
    (set arr.elements elems)
    (memset (cast void* elems) 0 (* 8 cap))
    (cast maru-value val)))

(define-function maru-array-length ((obj maru-value)) -> int32
  (if (maru-array? obj)
      (cast MArray* (cast MValue* obj).data).size
    0))

(define-function maru-array-at ((obj maru-value) (idx int32)) -> maru-value
  (if (and (maru-array? obj)
           (>= idx 0)
           (< idx (maru-array-length obj)))
      (let ((arr MArray* (cast MArray* (cast MValue* obj).data)))
        (indir arr.elements idx))
    0))

(define-function maru-array-set ((obj maru-value) (idx int32) (val maru-value)) -> void
  (if (and (maru-array? obj)
           (>= idx 0))
      (let ((arr MArray* (cast MArray* (cast MValue* obj).data)))
        (if (>= idx arr.capacity)
            ;; Need to grow array
            (let* ((new-cap int32 (if (>= idx arr.capacity) 
                                     (* 2 (if (> idx arr.capacity) idx arr.capacity))
                                     arr.capacity))
                   (new-elems maru-value* (cast maru-value* (gc_malloc (* 8 new-cap)))))
              (memcpy (cast void* new-elems) (cast void* arr.elements) (* 8 arr.size))
              (memset (cast void* (addressof (indir new-elems arr.size))) 0 
                      (* 8 (- new-cap arr.size)))
              (set arr.elements new-elems)
              (set arr.capacity new-cap)))
        (if (>= idx arr.size)
            (set arr.size (+ idx 1)))
        (set-indir arr.elements idx val))))

(define-function maru-array-append ((obj maru-value) (val maru-value)) -> void
  (maru-array-set obj (maru-array-length obj) val))

;;; ================================================================
;;; Environment and Variable Support
;;; ================================================================

(define-function maru-make-env ((parent maru-env) (level int32) (offset int32)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-ENV (sizeof MValue))))
         (env MEnv* (cast MEnv* (gc-malloc (sizeof MEnv)))))
    (set val.data (cast void* env))
    (set env.parent parent)
    (set env.level (if parent
                       (+ (cast MEnv* (cast MValue* parent).data).level level)
                     0))
    (set env.offset offset)
    (set env.bindings (maru-make-array 0))
    (cast maru-value val)))

(define-function maru-make-variable ((name maru-value) (value maru-value) (env maru-env) (index int32)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-VARIABLE (sizeof MValue))))
         (var MVariable* (cast MVariable* (gc-malloc (sizeof MVariable)))))
    (set val.data (cast void* var))
    (set var.name name)
    (set var.value value)
    (set var.env env)
    (set var.index index)
    (cast maru-value val)))

(define-function maru-variable-value ((var maru-value)) -> maru-value
  (if (maru-variable? var)
      (cast MVariable* (cast MValue* var).data).value
    0))

(define-function maru-set-variable-value ((var maru-value) (val maru-value)) -> void
  (if (maru-variable? var)
      (set (cast MVariable* (cast MValue* var).data).value val)))

(define-function maru-variable-name ((var maru-value)) -> maru-value
  (if (maru-variable? var)
      (cast MVariable* (cast MValue* var).data).name
    0))

(define-function maru-variable-env ((var maru-value)) -> maru-env
  (if (maru-variable? var)
      (cast MVariable* (cast MValue* var).data).env
    0))

(define-function maru-variable-index ((var maru-value)) -> int32
  (if (maru-variable? var)
      (cast MVariable* (cast MValue* var).data).index
    0))

(define-function maru-global? ((var maru-value)) -> int32
  (if (maru-variable? var)
      (let ((env maru-env (maru-variable-env var)))
        (and env 
             (= 0 (cast MEnv* (cast MValue* env).data).level)))
    0))

;;; ================================================================
;;; Expression (Lambda) Support
;;; ================================================================

(define-function maru-make-expr ((defn maru-value) (ctx maru-context)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-EXPR (sizeof MValue))))
         (expr MExpr* (cast MExpr* (gc-malloc (sizeof MExpr)))))
    (set val.data (cast void* expr))
    (set expr.defn defn)
    (set expr.ctx ctx)
    (cast maru-value val)))

(define-function maru-expr-defn ((expr maru-value)) -> maru-value
  (if (maru-expr? expr)
      (cast MExpr* (cast MValue* expr).data).defn
    0))

(define-function maru-expr-ctx ((expr maru-value)) -> maru-context
  (if (maru-expr? expr)
      (cast MExpr* (cast MValue* expr).data).ctx
    0))

;;; ================================================================
;;; Context Support
;;; ================================================================

(define-function maru-make-context ((home maru-context) (env maru-env)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-CONTEXT (sizeof MValue))))
         (ctx MContext* (cast MContext* (gc-malloc (sizeof MContext)))))
    (set val.data (cast void* ctx))
    (set ctx.home home)
    (set ctx.env env)
    (set ctx.bindings (maru-make-array 0))
    (cast maru-value val)))

(define-function maru-context-env ((ctx maru-value)) -> maru-env
  (if (= (maru-type-of ctx) MARU-CONTEXT)
      (cast MContext* (cast MValue* ctx).data).env
    0))

(define-function maru-context-bindings ((ctx maru-value)) -> maru-array
  (if (= (maru-type-of ctx) MARU-CONTEXT)
      (cast MContext* (cast MValue* ctx).data).bindings
    0))

(define-function maru-context-home ((ctx maru-value)) -> maru-context
  (if (= (maru-type-of ctx) MARU-CONTEXT)
      (cast MContext* (cast MValue* ctx).data).home
    0))

;;; ================================================================
;;; Fixed and Subr Support
;;; ================================================================

(define-function maru-make-fixed ((fn maru-value)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-FIXED (sizeof MValue))))
         (fixed MFixed* (cast MFixed* (gc-malloc (sizeof MFixed)))))
    (set val.data (cast void* fixed))
    (set fixed.function fn)
    (cast maru-value val)))

(define-function maru-fixed-function ((obj maru-value)) -> maru-value
  (if (maru-fixed? obj)
      (cast MFixed* (cast MValue* obj).data).function
    0))

(define-function maru-make-subr ((name char*) (impl void*)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc-atomic MARU-SUBR (sizeof MValue))))
         (subr MSubr* (cast MSubr* (gc_malloc_atomic (sizeof MSubr)))))
    (set val.data (cast void* subr))
    (set subr.name name)
    (set subr.impl impl)
    (cast maru-value val)))

(define-function maru-subr-impl ((obj maru-value)) -> void*
  (if (maru-subr? obj)
      (cast MSubr* (cast MValue* obj).data).impl
    0))

;;; ================================================================
;;; Error Handling
;;; ================================================================

(define-function maru-error ((msg char*) (obj maru-value)) -> void
  (fprintf (extern stderr) "\nERROR: %s: " msg)
  (maru-print obj (extern stderr))
  (fprintf (extern stderr) "\n")
  (exit 1))

;;; ================================================================
;;; Printing
;;; ================================================================

(define-function maru-print ((obj maru-value) (port void*)) -> void
  (let ((type int32 (maru-type-of obj)))
    (cond
      ((= type MARU-UNDEFINED) (fprintf port "nil"))
      ((= type MARU-LONG) (fprintf port "%ld" (maru-long-value obj)))
      ((= type MARU-STRING) 
       (let ((str MString* (cast MString* (cast MValue* obj).data)))
         (fprintf port "\"%s\"" str.data)))
      ((= type MARU-SYMBOL) (fprintf port "%s" (maru-symbol-name obj)))
      ((= type MARU-PAIR)
       (fprintf port "(")
       (maru-print-list obj port)
       (fprintf port ")"))
      ((= type MARU-ARRAY)
       (fprintf port "#(")
       (let ((len int32 (maru-array-length obj)))
         (for (i 0 len)
           (if i (fprintf port " "))
           (maru-print (maru-array-at obj i) port)))
       (fprintf port ")"))
      ((= type MARU-EXPR) (fprintf port "#<expr>"))
      ((= type MARU-VARIABLE) 
       (maru-print (maru-variable-name obj) port))
      ((= type MARU-ENV) (fprintf port "#<env>"))
      ((= type MARU-CONTEXT) (fprintf port "#<context>"))
      ((= type MARU-SUBR) (fprintf port "#<subr>"))
      ((= type MARU-FIXED) (fprintf port "#<fixed>"))
      (else (fprintf port "#<type:%d>" type)))))

(define-function maru-print-list ((obj maru-value) (port void*)) -> void
  (while (maru-pair? obj)
    (maru-print (maru-car obj) port)
    (set obj (maru-cdr obj))
    (if (maru-pair? obj)
        (fprintf port " ")))
  (if (not (maru-nil? obj))
      (let ()
        (fprintf port " . ")
        (maru-print obj port))))

;;; ================================================================
;;; Forward declarations for mutual recursion
;;; ================================================================

(define maru-eval) ; Forward declaration

;;; ================================================================
;;; List Operations
;;; ================================================================

(define-function maru-cadr ((obj maru-value)) -> maru-value
  (maru-car (maru-cdr obj)))

(define-function maru-cddr ((obj maru-value)) -> maru-value
  (maru-cdr (maru-cdr obj)))

(define-function maru-caddr ((obj maru-value)) -> maru-value
  (maru-car (maru-cdr (maru-cdr obj))))

(define-function maru-list-length ((list maru-value)) -> int32
  (let ((len int32 0))
    (while (maru-pair? list)
      (set len (+ len 1))
      (set list (maru-cdr list)))
    len))

;;; ================================================================
;;; Symbol Table and Interning
;;; ================================================================

(define-function maru-intern ((name char*)) -> maru-value
  ;; Simple linear search for now
  (let ((len int32 (maru-array-length symbols)))
    (for (i 0 len)
      (let ((sym maru-value (maru-array-at symbols i)))
        (if (= 0 (strcmp name (maru-symbol-name sym)))
            (return sym))))
    ;; Not found, create new symbol
    (let ((sym maru-value (maru-make-symbol name)))
      (maru-array-append symbols sym)
      sym)))

;;; ================================================================
;;; Environment Operations
;;; ================================================================

(define-function maru-env-define ((env maru-value) (name maru-value) (value maru-value)) -> maru-value
  (if (maru-env? env)
      (let* ((e MEnv* (cast MEnv* (cast MValue* env).data))
             (bindings maru-array e.bindings)
             (index int32 (maru-array-length bindings))
             (var maru-value (maru-make-variable name value (cast maru-env env) index)))
        (maru-array-append bindings var)
        var)
    0))

(define-function maru-env-lookup ((env maru-value) (name maru-value)) -> maru-value
  (while (maru-env? env)
    (let* ((e MEnv* (cast MEnv* (cast MValue* env).data))
           (bindings maru-array e.bindings)
           (len int32 (maru-array-length bindings)))
      (for (i 0 len)
        (let ((var maru-value (maru-array-at bindings i)))
          (if (and (maru-variable? var)
                   (= name (maru-variable-name var)))
              (return var))))
      (set env (cast maru-value e.parent))))
  0)

;;; ================================================================
;;; Evaluation Functions
;;; ================================================================

(define-function maru-eval-list ((list maru-value) (ctx maru-context)) -> maru-value
  (if (maru-pair? list)
      (let ((head maru-value (maru-eval (maru-car list) ctx)))
        (let ((tail maru-value (maru-eval-list (maru-cdr list) ctx)))
          (maru-cons head tail)))
    list))

(define-function maru-eval-sequence ((forms maru-value) (ctx maru-context)) -> maru-value
  (let ((result maru-value 0))
    (while (maru-pair? forms)
      (set result (maru-eval (maru-car forms) ctx))
      (set forms (maru-cdr forms)))
    result))

(define-function maru-lookup-local ((var maru-value) (ctx maru-context)) -> maru-value
  (if (and (maru-variable? var) ctx)
      (let* ((var-data MVariable* (cast MVariable* (cast MValue* var).data))
             (ctx-data MContext* (cast MContext* (cast MValue* ctx).data))
             (var-env-data MEnv* (cast MEnv* (cast MValue* var-data.env).data))
             (ctx-env-data MEnv* (cast MEnv* (cast MValue* ctx-data.env).data))
             (delta int32 (- ctx-env-data.level var-env-data.level)))
        ;; Navigate to the right context
        (while (> delta 0)
          (set ctx (maru-context-home ctx))
          (if (not ctx)
              (return 0))
          (set delta (- delta 1)))
        ;; Look up in bindings
        (maru-array-at (maru-context-bindings ctx) var-data.index))
    0))

;;; ================================================================
;;; Application Functions
;;; ================================================================

(define-function maru-bind-arguments ((ctx maru-context) (formals maru-value) (args maru-value)) -> void
  (let ((locals maru-array (maru-context-bindings ctx)))
    (while (maru-pair? formals)
      (if (not (maru-pair? args))
          (maru-error "too few arguments" formals))
      (let ((formal maru-value (maru-car formals)))
        (if (maru-variable? formal)
            (maru-array-set locals 
                           (maru-variable-index formal)
                           (maru-car args))))
      (set formals (maru-cdr formals))
      (set args (maru-cdr args)))
    ;; Handle rest arguments
    (if (maru-variable? formals)
        (maru-array-set locals (maru-variable-index formals) args)
      (if args
          (maru-error "too many arguments" args)))))

(define-function maru-apply-expr ((fun maru-value) (arguments maru-value) (ctx maru-context)) -> maru-value
  (if (maru-expr? fun)
      (let* ((defn maru-value (maru-expr-defn fun))
             (env maru-value (maru-car defn))
             (formals maru-value (maru-cadr defn))
             (body maru-value (maru-cddr defn))
             (new-ctx maru-context (cast maru-context 
                                        (maru-make-context (maru-expr-ctx fun) 
                                                          (cast maru-env env)))))
        (maru-bind-arguments new-ctx formals arguments)
        (maru-eval-sequence body new-ctx))
    (maru-error "not a function" fun)))

(define-function maru-apply ((fun maru-value) (arguments maru-value) (ctx maru-context)) -> maru-value
  (let ((type int32 (maru-type-of fun)))
    (cond
      ((= type MARU-EXPR) (maru-apply-expr fun arguments ctx))
      ((= type MARU-FIXED)
       (maru-apply (maru-fixed-function fun) arguments ctx))
      ((= type MARU-SUBR)
       (let ((impl maru-value (maru-value) ((void*) (maru-context))) (cast maru-value (maru-value) ((void*) (maru-context)) (maru-subr-impl fun)))
         (impl arguments ctx)))
      (else
       ;; Check applicators table
       (let ((app maru-value (maru-array-at applicators type)))
         (if app
             (maru-apply app (maru-cons fun arguments) ctx)
           (maru-error "cannot apply" fun)))))))

;;; ================================================================
;;; Core Evaluator
;;; ================================================================

(set maru-eval
  (lambda ((exp maru-value) (ctx maru-context)) -> maru-value
    (let ((type int32 (maru-type-of exp)))
      (cond
        ;; Self-evaluating types
        ((= type MARU-UNDEFINED) exp)
        ((= type MARU-LONG) exp)
        ((= type MARU-STRING) exp)
        
        ;; Variable lookup
        ((= type MARU-VARIABLE)
         (if (maru-global? exp)
             (maru-variable-value exp)
           (maru-lookup-local exp ctx)))
        
        ;; List evaluation (function application)
        ((= type MARU-PAIR)
         (let ((head maru-value (maru-eval (maru-car exp) ctx)))
           (if (maru-fixed? head)
               ;; Special form - don't evaluate arguments
               (maru-apply (maru-fixed-function head) (maru-cdr exp) ctx)
             ;; Regular function - evaluate arguments
             (let ((args maru-value (maru-eval-list (maru-cdr exp) ctx)))
               (maru-apply head args ctx)))))
        
        ;; Symbols should not appear in evaluation
        ((= type MARU-SYMBOL)
         (maru-error "symbol in eval?" exp))
        
        ;; Check evaluators table for custom types
        (else
         (let ((ev maru-value (maru-array-at evaluators type)))
           (if ev
               (maru-apply ev (maru-cons exp 0) ctx)
             exp)))))))

;;; ================================================================
;;; Special Forms
;;; ================================================================

(define-function subr-quote ((args maru-value) (ctx maru-context)) -> maru-value
  (maru-car args))

(define-function subr-lambda ((args maru-value) (ctx maru-context)) -> maru-value
  (maru-make-expr args ctx))

(define-function subr-define ((args maru-value) (ctx maru-context)) -> maru-value
  (let* ((var maru-value (maru-car args))
         (val maru-value (maru-eval (maru-cadr args) ctx)))
    (if (maru-variable? var)
        (maru-set-variable-value var val)
      (maru-error "non-variable in define" var))
    val))

(define-function subr-set ((args maru-value) (ctx maru-context)) -> maru-value
  (let* ((var maru-value (maru-car args))
         (val maru-value (maru-eval (maru-cadr args) ctx)))
    (if (not (maru-variable? var))
        (maru-error "cannot set undefined variable" var))
    (if (maru-global? var)
        (maru-set-variable-value var val)
      ;; Local variable
      (let* ((var-data MVariable* (cast MVariable* (cast MValue* var).data))
             (ctx-data MContext* (cast MContext* (cast MValue* ctx).data))
             (var-env-data MEnv* (cast MEnv* (cast MValue* var-data.env).data))
             (ctx-env-data MEnv* (cast MEnv* (cast MValue* ctx-data.env).data))
             (delta int32 (- ctx-env-data.level var-env-data.level)))
        ;; Navigate to the right context
        (while (> delta 0)
          (set ctx (maru-context-home ctx))
          (set delta (- delta 1)))
        ;; Set in bindings
        (maru-array-set (maru-context-bindings ctx) var-data.index val)))
    val))

(define-function subr-if ((args maru-value) (ctx maru-context)) -> maru-value
  (if (maru-eval (maru-car args) ctx)
      (maru-eval (maru-cadr args) ctx)
    (maru-eval-sequence (maru-cddr args) ctx)))

(define-function subr-let ((args maru-value) (ctx maru-context)) -> maru-value
  (let* ((bindings maru-value (maru-car args))
         (body maru-value (maru-cdr args))
         (locals maru-array (maru-context-bindings ctx)))
    ;; Process bindings
    (while (maru-pair? bindings)
      (let ((binding maru-value (maru-car bindings)))
        (if (maru-pair? binding)
            (let* ((var maru-value (maru-car binding))
                   (init maru-value (maru-cadr binding))
                   (val maru-value (maru-eval init ctx)))
              (if (maru-variable? var)
                  (maru-array-set locals (maru-variable-index var) val))))
        (set bindings (maru-cdr bindings))))
    ;; Evaluate body
    (maru-eval-sequence body ctx)))

;;; ================================================================
;;; Built-in Functions
;;; ================================================================

(define-function subr-cons ((args maru-value) (ctx maru-context)) -> maru-value
  (maru-cons (maru-car args) (maru-cadr args)))

(define-function subr-car ((args maru-value) (ctx maru-context)) -> maru-value
  (maru-car (maru-car args)))

(define-function subr-cdr ((args maru-value) (ctx maru-context)) -> maru-value
  (maru-cdr (maru-car args)))

(define-function subr-eq ((args maru-value) (ctx maru-context)) -> maru-value
  (if (= (maru-car args) (maru-cadr args))
      s_t
    0))

(define-function subr-add ((args maru-value) (ctx maru-context)) -> maru-value
  (let ((result int64 0))
    (while (maru-pair? args)
      (let ((arg maru-value (maru-car args)))
        (if (maru-long? arg)
            (set result (+ result (maru-long-value arg)))))
      (set args (maru-cdr args)))
    (maru-make-long result)))

(define-function subr-sub ((args maru-value) (ctx maru-context)) -> maru-value
  (if (maru-pair? args)
      (let ((result int64 (maru-long-value (maru-car args))))
        (set args (maru-cdr args))
        (if args
            (while (maru-pair? args)
              (let ((arg maru-value (maru-car args)))
                (if (maru-long? arg)
                    (set result (- result (maru-long-value arg)))))
              (set args (maru-cdr args)))
          (set result (- 0 result)))  ; Unary minus
        (maru-make-long result))
    (maru-make-long 0)))

(define-function subr-print ((args maru-value) (ctx maru-context)) -> maru-value
  (while (maru-pair? args)
    (maru-print (maru-car args) (extern stdout))
    (set args (maru-cdr args))
    (if (maru-pair? args)
        (printf " ")))
  0)

(define-function subr-println ((args maru-value) (ctx maru-context)) -> maru-value
  (subr-print args ctx)
  (printf "\n")
  0)

;;; ================================================================
;;; Initialization
;;; ================================================================

(define-function define-subr ((name char*) (impl void*)) -> void
  (let ((subr maru-value (maru-make-subr name impl)))
    (maru-env-define globals (maru-intern name) subr)))

(define-function define-fsubr ((name char*) (impl void*)) -> void
  (let* ((subr maru-value (maru-make-subr name impl))
         (fixed maru-value (maru-make-fixed subr)))
    (maru-env-define globals (maru-intern name) fixed)))

(define-function maru-init () -> void
  ;; Initialize GC
  (gc_initialise)
  
  ;; Create symbol table
  (set symbols (maru-make-array 0))
  (gc_push_root (addressof symbols))
  
  ;; Create important symbols
  (set s_t (maru-intern "t"))
  (set s_quote (maru-intern "quote"))
  (set s_lambda (maru-intern "lambda"))
  (set s_define (maru-intern "define"))
  (set s_set (maru-intern "set"))
  (set s_if (maru-intern "if"))
  (set s_let (maru-intern "let"))
  
  ;; Create global environment
  (set globals (maru-make-env 0 0 0))
  (gc_push_root (addressof globals))
  (maru-env-define globals (maru-intern "*globals*") globals)
  
  ;; Create evaluators and applicators tables
  (set evaluators (maru-make-array 32))
  (gc_push_root (addressof evaluators))
  (maru-env-define globals (maru-intern "*evaluators*") evaluators)
  
  (set applicators (maru-make-array 32))
  (gc_push_root (addressof applicators))
  (maru-env-define globals (maru-intern "*applicators*") applicators)
  
  ;; Define special forms
  (define-fsubr "quote" (cast void* subr-quote))
  (define-fsubr "lambda" (cast void* subr-lambda))
  (define-fsubr "define" (cast void* subr-define))
  (define-fsubr "set" (cast void* subr-set))
  (define-fsubr "if" (cast void* subr-if))
  (define-fsubr "let" (cast void* subr-let))
  
  ;; Define built-in functions
  (define-subr "cons" (cast void* subr-cons))
  (define-subr "car" (cast void* subr-car))
  (define-subr "cdr" (cast void* subr-cdr))
  (define-subr "eq?" (cast void* subr-eq))
  (define-subr "+" (cast void* subr-add))
  (define-subr "-" (cast void* subr-sub))
  (define-subr "print" (cast void* subr-print))
  (define-subr "println" (cast void* subr-println))
  
  ;; Define 't' as true
  (maru-env-define globals s_t s_t))

;;; ================================================================
;;; Test Entry Point
;;; ================================================================

(define-function test-eval () -> void
  (maru-init)
  
  (printf "eval.k initialized\n")
  
  ;; Test 1: Self-evaluating number
  (let* ((exp maru-value (maru-make-long 42))
         (ctx maru-context (cast maru-context (maru-make-context 0 (cast maru-env globals))))
         (result maru-value (maru-eval exp ctx)))
    (printf "Test 1: ")
    (maru-print result (extern stdout))
    (printf " (expected 42)\n"))
  
  ;; Test 2: Quote
  (let* ((sym maru-value (maru-intern "hello"))
         (exp maru-value (maru-cons s_quote (maru-cons sym 0)))
         (ctx maru-context (cast maru-context (maru-make-context 0 (cast maru-env globals))))
         (result maru-value (maru-eval exp ctx)))
    (printf "Test 2: ")
    (maru-print result (extern stdout))
    (printf " (expected hello)\n"))
  
  ;; Test 3: Addition
  (let* ((exp maru-value (maru-cons (maru-intern "+") 
                                   (maru-cons (maru-make-long 2)
                                             (maru-cons (maru-make-long 3) 0))))
         (ctx maru-context (cast maru-context (maru-make-context 0 (cast maru-env globals))))
         (result maru-value (maru-eval exp ctx)))
    (printf "Test 3: ")
    (maru-print result (extern stdout))
    (printf " (expected 5)\n"))
  
  (printf "Basic tests complete\n"))

;; Compile the test function
(compile-end)