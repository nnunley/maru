;;; eval-multimethod.k - Typed, IR-based Maru evaluator using multi-method dispatch
;;; 
;;; This implements the Maru evaluator using multi-methods for clean extensibility
;;; and proper separation of concerns.

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

;; Base class for all Maru values
(define-class <maru-value> () (tag))

;; Type-specific classes
(define-class <maru-undefined> <maru-value> ())
(define-class <maru-long>      <maru-value> (bits))
(define-class <maru-double>    <maru-value> (bits))
(define-class <maru-string>    <maru-value> (length data))
(define-class <maru-symbol>    <maru-value> (name))
(define-class <maru-pair>      <maru-value> (head tail))
(define-class <maru-array>     <maru-value> (size capacity elements))
(define-class <maru-expr>      <maru-value> (defn ctx))
(define-class <maru-form>      <maru-value> (function symbol))
(define-class <maru-fixed>     <maru-value> (function))
(define-class <maru-subr>      <maru-value> (name impl))
(define-class <maru-variable>  <maru-value> (name value env index))
(define-class <maru-env>       <maru-value> (parent level offset bindings))
(define-class <maru-context>   <maru-value> (home env bindings))

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

;; Standard I/O streams
(extern void* stdout)
(extern void* stderr)

;;; ================================================================
;;; Global Variables
;;; ================================================================

(define symbols     <maru-array>* 0)  ; Symbol table
(define globals     <maru-env>* 0)    ; Global environment
(define evaluators  <maru-array>* 0)  ; Type-indexed evaluator table
(define applicators <maru-array>* 0)  ; Type-indexed applicator table

;;; ================================================================
;;; Multi-method Definitions
;;; ================================================================

;; Generic function for evaluation
(define-generic maru-eval (exp ctx))

;; Generic function for application
(define-generic maru-apply (fun args ctx))

;; Generic function for printing
(define-generic maru-print (obj port))

;; Generic function for type checking
(define-generic maru-type-of (obj))

;;; ================================================================
;;; Tagged Integer Support
;;; ================================================================

(define-function maru-tagged-int? ((obj void*)) -> int32
  (& (cast int64 obj) 1))

(define-function maru-tag-int ((value int64)) -> <maru-long>*
  (cast <maru-long>* (| (<< value 1) 1)))

(define-function maru-untag-int ((obj void*)) -> int64
  (>> (cast int64 obj) 1))

;;; ================================================================
;;; Type Checking Methods
;;; ================================================================

(define-method maru-type-of <maru-value> () -> int32
  self.tag)

(define-method maru-type-of void* () -> int32
  (if (maru-tagged-int? self)
      MARU-LONG
    (if self
        (cast <maru-value>* self).tag
      MARU-UNDEFINED)))

;;; ================================================================
;;; Constructors as Methods
;;; ================================================================

(define-method maru-make <maru-undefined> () -> <maru-undefined>*
  (cast <maru-undefined>* 0))

(define-method maru-make <maru-long> ((value int64)) -> <maru-long>*
  (if (and (>= value -1073741824) (<= value 1073741823))  ; Fits in tagged int
      (maru-tag-int value)
    ;; Box large integers
    (let ((obj <maru-long>* (cast <maru-long>* (gc_malloc (sizeof <maru-long>)))))
      (set obj.tag MARU-LONG)
      (set obj.bits value)
      obj)))

(define-method maru-make <maru-string> ((cstr char*)) -> <maru-string>*
  (let* ((len int32 (strlen cstr))
         (obj <maru-string>* (cast <maru-string>* (gc_malloc (sizeof <maru-string>))))
         (data char* (cast char* (gc_malloc_atomic (+ len 1)))))
    (set obj.tag MARU-STRING)
    (set obj.length len)
    (set obj.data data)
    (memcpy data (cast void* cstr) (+ len 1))
    obj))

(define-method maru-make <maru-symbol> ((name char*)) -> <maru-symbol>*
  (let ((obj <maru-symbol>* (cast <maru-symbol>* (gc_malloc_atomic (sizeof <maru-symbol>)))))
    (set obj.tag MARU-SYMBOL)
    (set obj.name (strdup name))
    obj))

(define-method maru-make <maru-pair> ((head <maru-value>*) (tail <maru-value>*)) -> <maru-pair>*
  (let ((obj <maru-pair>* (cast <maru-pair>* (gc_malloc (sizeof <maru-pair>)))))
    (set obj.tag MARU-PAIR)
    (set obj.head head)
    (set obj.tail tail)
    obj))

(define-method maru-make <maru-array> ((size int32)) -> <maru-array>*
  (let* ((obj <maru-array>* (cast <maru-array>* (gc_malloc (sizeof <maru-array>))))
         (cap int32 (if size size 1))
         (elems <maru-value>** (cast <maru-value>** (gc_malloc (* 8 cap)))))
    (set obj.tag MARU-ARRAY)
    (set obj.size size)
    (set obj.capacity cap)
    (set obj.elements elems)
    (memset (cast void* elems) 0 (* 8 cap))
    obj))

(define-method maru-make <maru-env> ((parent <maru-env>*) (level int32) (offset int32)) -> <maru-env>*
  (let ((obj <maru-env>* (cast <maru-env>* (gc_malloc (sizeof <maru-env>)))))
    (set obj.tag MARU-ENV)
    (set obj.parent parent)
    (set obj.level (if parent (+ parent.level level) 0))
    (set obj.offset offset)
    (set obj.bindings (maru-make <maru-array> 0))
    obj))

(define-method maru-make <maru-variable> ((name <maru-value>*) (value <maru-value>*) (env <maru-env>*) (index int32)) -> <maru-variable>*
  (let ((obj <maru-variable>* (cast <maru-variable>* (gc_malloc (sizeof <maru-variable>)))))
    (set obj.tag MARU-VARIABLE)
    (set obj.name name)
    (set obj.value value)
    (set obj.env env)
    (set obj.index index)
    obj))

(define-method maru-make <maru-expr> ((defn <maru-value>*) (ctx <maru-context>*)) -> <maru-expr>*
  (let ((obj <maru-expr>* (cast <maru-expr>* (gc_malloc (sizeof <maru-expr>)))))
    (set obj.tag MARU-EXPR)
    (set obj.defn defn)
    (set obj.ctx ctx)
    obj))

(define-method maru-make <maru-context> ((home <maru-context>*) (env <maru-env>*)) -> <maru-context>*
  (let ((obj <maru-context>* (cast <maru-context>* (gc_malloc (sizeof <maru-context>)))))
    (set obj.tag MARU-CONTEXT)
    (set obj.home home)
    (set obj.env env)
    (set obj.bindings (maru-make <maru-array> 0))
    obj))

(define-method maru-make <maru-fixed> ((fn <maru-value>*)) -> <maru-fixed>*
  (let ((obj <maru-fixed>* (cast <maru-fixed>* (gc_malloc (sizeof <maru-fixed>)))))
    (set obj.tag MARU-FIXED)
    (set obj.function fn)
    obj))

(define-method maru-make <maru-subr> ((name char*) (impl void*)) -> <maru-subr>*
  (let ((obj <maru-subr>* (cast <maru-subr>* (gc_malloc_atomic (sizeof <maru-subr>)))))
    (set obj.tag MARU-SUBR)
    (set obj.name name)
    (set obj.impl impl)
    obj))

;;; ================================================================
;;; Accessor Methods
;;; ================================================================

(define-method maru-car <maru-pair> () -> <maru-value>*
  self.head)

(define-method maru-car <maru-value> () -> <maru-value>*
  (cast <maru-value>* 0))

(define-method maru-cdr <maru-pair> () -> <maru-value>*
  self.tail)

(define-method maru-cdr <maru-value> () -> <maru-value>*
  (cast <maru-value>* 0))

(define-method maru-length <maru-array> () -> int32
  self.size)

(define-method maru-length <maru-string> () -> int32
  self.length)

(define-method maru-at <maru-array> ((idx int32)) -> <maru-value>*
  (if (and (>= idx 0) (< idx self.size))
      (indir self.elements idx)
    (cast <maru-value>* 0)))

(define-method maru-set-at <maru-array> ((idx int32) (val <maru-value>*)) -> void
  (if (>= idx 0)
      (let ()
        ;; Grow array if needed
        (if (>= idx self.capacity)
            (let* ((new-cap int32 (* 2 (if (> idx self.capacity) idx self.capacity)))
                   (new-elems <maru-value>** (cast <maru-value>** (gc_malloc (* 8 new-cap)))))
              (memcpy (cast void* new-elems) (cast void* self.elements) (* 8 self.size))
              (memset (cast void* (addressof (indir new-elems self.size))) 0 
                      (* 8 (- new-cap self.size)))
              (set self.elements new-elems)
              (set self.capacity new-cap)))
        (if (>= idx self.size)
            (set self.size (+ idx 1)))
        (set-indir self.elements idx val))))

;;; ================================================================
;;; Evaluation Methods
;;; ================================================================

;; Default evaluation - return self
(define-method maru-eval <maru-value> ((ctx <maru-context>*)) -> <maru-value>*
  self)

;; Undefined evaluates to itself
(define-method maru-eval <maru-undefined> ((ctx <maru-context>*)) -> <maru-value>*
  self)

;; Numbers are self-evaluating
(define-method maru-eval <maru-long> ((ctx <maru-context>*)) -> <maru-value>*
  self)

;; Strings are self-evaluating
(define-method maru-eval <maru-string> ((ctx <maru-context>*)) -> <maru-value>*
  self)

;; Variables need lookup
(define-method maru-eval <maru-variable> ((ctx <maru-context>*)) -> <maru-value>*
  (if (= 0 self.env.level)  ; Global variable
      self.value
    ;; Local variable - navigate to correct context
    (let ((delta int32 (- ctx.env.level self.env.level))
          (c <maru-context>* ctx))
      (while (> delta 0)
        (set c c.home)
        (set delta (- delta 1)))
      (maru-at c.bindings self.index))))

;; Symbols should not appear in evaluation
(define-method maru-eval <maru-symbol> ((ctx <maru-context>*)) -> <maru-value>*
  (maru-error "symbol in eval?" (cast <maru-value>* self)))

;; Pair evaluation - function application
(define-method maru-eval <maru-pair> ((ctx <maru-context>*)) -> <maru-value>*
  (let ((fn <maru-value>* (maru-eval (maru-car self) ctx)))
    ;; Check if it's a special form (fixed)
    (if (= (maru-type-of fn) MARU-FIXED)
        ;; Special form - don't evaluate arguments
        (maru-apply fn (cast <maru-value>* (maru-cdr self)) ctx)
      ;; Regular function - evaluate arguments
      (let ((args <maru-value>* (maru-eval-list (maru-cdr self) ctx)))
        (maru-apply fn args ctx)))))

;; Helper function to evaluate a list
(define-function maru-eval-list ((list <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (if (= (maru-type-of list) MARU-PAIR)
      (let ((head <maru-value>* (maru-eval (maru-car list) ctx))
            (tail <maru-value>* (maru-eval-list (maru-cdr list) ctx)))
        (cast <maru-value>* (maru-make <maru-pair> head tail)))
    list))

;;; ================================================================
;;; Application Methods
;;; ================================================================

;; Default application - error
(define-method maru-apply <maru-value> ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-error "cannot apply" self))

;; Expression (lambda) application
(define-method maru-apply <maru-expr> ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let* ((defn <maru-value>* self.defn)
         (env <maru-value>* (maru-car defn))
         (formals <maru-value>* (maru-car (maru-cdr defn)))
         (body <maru-value>* (maru-cdr (maru-cdr defn)))
         (new-ctx <maru-context>* (maru-make <maru-context> self.ctx (cast <maru-env>* env))))
    (maru-bind-arguments new-ctx formals args)
    (maru-eval-sequence body new-ctx)))

;; Fixed (special form) application
(define-method maru-apply <maru-fixed> ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-apply self.function args ctx))

;; Subr (built-in) application
(define-method maru-apply <maru-subr> ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let ((impl <maru-value>* (<maru-value>*) ((args <maru-value>*) (ctx <maru-context>*)) (cast <maru-value>* (<maru-value>*) ((args <maru-value>*) (ctx <maru-context>*)) self.impl)))
    (impl args ctx)))

;;; ================================================================
;;; Printing Methods
;;; ================================================================

(define-method maru-print <maru-undefined> ((port void*)) -> void
  (fprintf port "nil"))

(define-method maru-print <maru-long> ((port void*)) -> void
  (if (maru-tagged-int? (cast void* self))
      (fprintf port "%lld" (cast long (maru-untag-int (cast void* self))))
    (fprintf port "%lld" (cast long self.bits))))

(define-method maru-print <maru-string> ((port void*)) -> void
  (fprintf port "\"%s\"" self.data))

(define-method maru-print <maru-symbol> ((port void*)) -> void
  (fprintf port "%s" self.name))

(define-method maru-print <maru-pair> ((port void*)) -> void
  (fprintf port "(")
  (let ((list <maru-value>* (cast <maru-value>* self)))
    (while (= (maru-type-of list) MARU-PAIR)
      (maru-print (maru-car list) port)
      (set list (maru-cdr list))
      (if (= (maru-type-of list) MARU-PAIR)
          (fprintf port " ")))
    (if (not (= (maru-type-of list) MARU-UNDEFINED))
        (let ()
          (fprintf port " . ")
          (maru-print list port))))
  (fprintf port ")"))

(define-method maru-print <maru-array> ((port void*)) -> void
  (fprintf port "#(")
  (let ((len int32 self.size))
    (for (i 0 len)
      (if i (fprintf port " "))
      (maru-print (maru-at self i) port)))
  (fprintf port ")"))

(define-method maru-print <maru-expr> ((port void*)) -> void
  (fprintf port "#<expr>"))

(define-method maru-print <maru-variable> ((port void*)) -> void
  (maru-print self.name port))

(define-method maru-print <maru-env> ((port void*)) -> void
  (fprintf port "#<env:%d>" self.level))

(define-method maru-print <maru-context> ((port void*)) -> void
  (fprintf port "#<context>"))

(define-method maru-print <maru-subr> ((port void*)) -> void
  (fprintf port "#<subr:%s>" self.name))

(define-method maru-print <maru-fixed> ((port void*)) -> void
  (fprintf port "#<fixed>"))

(define-method maru-print <maru-value> ((port void*)) -> void
  (fprintf port "#<type:%d>" self.tag))

;;; ================================================================
;;; Helper Functions
;;; ================================================================

(define-function maru-error ((msg char*) (obj <maru-value>*)) -> void
  (fprintf stderr "\nERROR: %s: " msg)
  (maru-print obj stderr)
  (fprintf stderr "\n")
  (exit 1))

(define-function maru-bind-arguments ((ctx <maru-context>*) (formals <maru-value>*) (args <maru-value>*)) -> void
  (let ((locals <maru-array>* ctx.bindings))
    (while (= (maru-type-of formals) MARU-PAIR)
      (if (not (= (maru-type-of args) MARU-PAIR))
          (maru-error "too few arguments" formals))
      (let ((formal <maru-value>* (maru-car formals)))
        (if (= (maru-type-of formal) MARU-VARIABLE)
            (maru-set-at locals (cast <maru-variable>* formal).index (maru-car args))))
      (set formals (maru-cdr formals))
      (set args (maru-cdr args)))
    ;; Handle rest arguments
    (if (= (maru-type-of formals) MARU-VARIABLE)
        (maru-set-at locals (cast <maru-variable>* formals).index args)
      (if (not (= (maru-type-of args) MARU-UNDEFINED))
          (maru-error "too many arguments" args)))))

(define-function maru-eval-sequence ((forms <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let ((result <maru-value>* (cast <maru-value>* 0)))
    (while (= (maru-type-of forms) MARU-PAIR)
      (set result (maru-eval (maru-car forms) ctx))
      (set forms (maru-cdr forms)))
    result))

;;; ================================================================
;;; Symbol Table
;;; ================================================================

(define-function maru-intern ((name char*)) -> <maru-symbol>*
  ;; Linear search
  (let ((len int32 (maru-length symbols)))
    (for (i 0 len)
      (let ((sym <maru-value>* (maru-at symbols i)))
        (if (and (= (maru-type-of sym) MARU-SYMBOL)
                 (= 0 (strcmp name (cast <maru-symbol>* sym).name)))
            (return (cast <maru-symbol>* sym)))))
    ;; Not found, create new
    (let ((sym <maru-symbol>* (maru-make <maru-symbol> name)))
      (maru-set-at symbols len (cast <maru-value>* sym))
      sym)))

;;; ================================================================
;;; Environment Operations
;;; ================================================================

(define-method maru-define <maru-env> ((name <maru-value>*) (value <maru-value>*)) -> <maru-variable>*
  (let* ((bindings <maru-array>* self.bindings)
         (index int32 (maru-length bindings))
         (var <maru-variable>* (maru-make <maru-variable> name value self index)))
    (maru-set-at bindings index (cast <maru-value>* var))
    var))

(define-method maru-lookup <maru-env> ((name <maru-symbol>*)) -> <maru-variable>*
  (let ((bindings <maru-array>* self.bindings)
        (len int32 (maru-length bindings)))
    (for (i 0 len)
      (let ((var <maru-value>* (maru-at bindings i)))
        (if (and (= (maru-type-of var) MARU-VARIABLE)
                 (= (cast <maru-value>* name) (cast <maru-variable>* var).name))
            (return (cast <maru-variable>* var)))))
    ;; Not found in this environment, try parent
    (if self.parent
        (maru-lookup self.parent name)
      (cast <maru-variable>* 0))))

;;; ================================================================
;;; Special Forms
;;; ================================================================

(define-function subr-quote ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-car args))

(define-function subr-lambda ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (cast <maru-value>* (maru-make <maru-expr> args ctx)))

(define-function subr-define ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let* ((var <maru-value>* (maru-car args))
         (val <maru-value>* (maru-eval (maru-car (maru-cdr args)) ctx)))
    (if (= (maru-type-of var) MARU-VARIABLE)
        (set (cast <maru-variable>* var).value val)
      (maru-error "non-variable in define" var))
    val))

(define-function subr-if ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (if (not (= (maru-type-of (maru-eval (maru-car args) ctx)) MARU-UNDEFINED))
      (maru-eval (maru-car (maru-cdr args)) ctx)
    (maru-eval-sequence (maru-cdr (maru-cdr args)) ctx)))

;;; ================================================================
;;; Built-in Functions
;;; ================================================================

(define-function subr-cons ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (cast <maru-value>* (maru-make <maru-pair> (maru-car args) (maru-car (maru-cdr args)))))

(define-function subr-car ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-car (maru-car args)))

(define-function subr-cdr ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-cdr (maru-car args)))

(define-function subr-print ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (while (not (= (maru-type-of args) MARU-UNDEFINED))
    (maru-print (maru-car args) stdout)
    (set args (maru-cdr args))
    (if (not (= (maru-type-of args) MARU-UNDEFINED))
        (printf " ")))
  (cast <maru-value>* 0))

(define-function subr-println ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (subr-print args ctx)
  (printf "\n")
  (cast <maru-value>* 0))

;;; ================================================================
;;; Initialization
;;; ================================================================

(define-function define-subr ((name char*) (impl void*)) -> void
  (let ((subr <maru-subr>* (maru-make <maru-subr> name impl)))
    (maru-define globals (cast <maru-value>* (maru-intern name)) (cast <maru-value>* subr))))

(define-function define-fsubr ((name char*) (impl void*)) -> void
  (let* ((subr <maru-subr>* (maru-make <maru-subr> name impl))
         (fixed <maru-fixed>* (maru-make <maru-fixed> (cast <maru-value>* subr))))
    (maru-define globals (cast <maru-value>* (maru-intern name)) (cast <maru-value>* fixed))))

(define-function maru-init () -> void
  ;; Initialize GC
  (gc_initialise)
  
  ;; Create symbol table
  (set symbols (maru-make <maru-array> 0))
  (gc_push_root (cast void** (addressof symbols)))
  
  ;; Create global environment
  (set globals (maru-make <maru-env> (cast <maru-env>* 0) 0 0))
  (gc_push_root (cast void** (addressof globals)))
  (maru-define globals (cast <maru-value>* (maru-intern "*globals*")) (cast <maru-value>* globals))
  
  ;; Create evaluators and applicators tables
  (set evaluators (maru-make <maru-array> 32))
  (gc_push_root (cast void** (addressof evaluators)))
  (maru-define globals (cast <maru-value>* (maru-intern "*evaluators*")) (cast <maru-value>* evaluators))
  
  (set applicators (maru-make <maru-array> 32))
  (gc_push_root (cast void** (addressof applicators)))
  (maru-define globals (cast <maru-value>* (maru-intern "*applicators*")) (cast <maru-value>* applicators))
  
  ;; Define special forms
  (define-fsubr "quote" (cast void* subr-quote))
  (define-fsubr "lambda" (cast void* subr-lambda))
  (define-fsubr "define" (cast void* subr-define))
  (define-fsubr "if" (cast void* subr-if))
  
  ;; Define built-in functions
  (define-subr "cons" (cast void* subr-cons))
  (define-subr "car" (cast void* subr-car))
  (define-subr "cdr" (cast void* subr-cdr))
  (define-subr "print" (cast void* subr-print))
  (define-subr "println" (cast void* subr-println))
  
  ;; Define 't' as true
  (let ((t-sym <maru-value>* (cast <maru-value>* (maru-intern "t"))))
    (maru-define globals t-sym t-sym)))

;;; ================================================================
;;; Test Entry Point
;;; ================================================================

(define-function test-eval () -> void
  (maru-init)
  
  (printf "eval-multimethod.k initialized\n")
  
  ;; Test 1: Self-evaluating number
  (let* ((exp <maru-value>* (cast <maru-value>* (maru-make <maru-long> 42)))
         (ctx <maru-context>* (maru-make <maru-context> (cast <maru-context>* 0) globals))
         (result <maru-value>* (maru-eval exp ctx)))
    (printf "Test 1: ")
    (maru-print result stdout)
    (printf " (expected 42)\n"))
  
  ;; Test 2: Quote
  (let* ((sym <maru-value>* (cast <maru-value>* (maru-intern "hello")))
         (quote-sym <maru-value>* (cast <maru-value>* (maru-intern "quote")))
         (quote-var <maru-value>* (cast <maru-value>* (maru-lookup globals (cast <maru-symbol>* quote-sym))))
         (exp <maru-value>* (cast <maru-value>* (maru-make <maru-pair> quote-var 
                                                          (cast <maru-value>* (maru-make <maru-pair> sym (cast <maru-value>* 0))))))
         (ctx <maru-context>* (maru-make <maru-context> (cast <maru-context>* 0) globals))
         (result <maru-value>* (maru-eval exp ctx)))
    (printf "Test 2: ")
    (maru-print result stdout)
    (printf " (expected hello)\n"))
  
  ;; Test 3: Cons
  (let* ((cons-sym <maru-value>* (cast <maru-value>* (maru-intern "cons")))
         (cons-var <maru-value>* (cast <maru-value>* (maru-lookup globals (cast <maru-symbol>* cons-sym))))
         (one <maru-value>* (cast <maru-value>* (maru-make <maru-long> 1)))
         (two <maru-value>* (cast <maru-value>* (maru-make <maru-long> 2)))
         (exp <maru-value>* (cast <maru-value>* (maru-make <maru-pair> cons-var 
                                                          (cast <maru-value>* (maru-make <maru-pair> one
                                                                                        (cast <maru-value>* (maru-make <maru-pair> two (cast <maru-value>* 0))))))))
         (ctx <maru-context>* (maru-make <maru-context> (cast <maru-context>* 0) globals))
         (result <maru-value>* (maru-eval exp ctx)))
    (printf "Test 3: ")
    (maru-print result stdout)
    (printf " (expected (1 . 2))\n"))
  
  (printf "Basic tests complete\n"))

;; Compile the test function
(compile-end)