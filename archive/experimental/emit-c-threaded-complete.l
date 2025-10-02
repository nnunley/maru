;;; emit-c-threaded-complete.l -- Complete Threaded C Backend for evalm
;;;
;;; Full implementation with all features needed for evalm compilation

(load "emit-c-threaded-fixed.l")

;;; Global state for compilation
(define *function-definitions* ())
(define *global-variables* ())
(define *string-literals* ())
(define *string-counter* 0)

;;; String literal handling
(define-function c-gen-string-literal (str)
  "Generate string literal and return its name"
  (let ((name (concat-string "str_" (long->string (set *string-counter* (+ *string-counter* 1))))))
    (set *string-literals* (cons (cons name str) *string-literals*))
    name))

;;; Enhanced operation generators

(define-function c-gen-threaded-string (str next)
  "Generate threaded code for string literal"
  (let ((thread-name (c-fresh-thread))
        (str-name (c-gen-string-literal str)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "ctx->acc = make_string(") (print str-name) (println ");")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-symbol (sym next)
  "Generate threaded code for symbol"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "ctx->acc = intern(\"") (print sym) (println "\");")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-variable-ref (var-name next)
  "Generate threaded code for variable reference"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "ctx->acc = env_lookup(ctx->env, intern(\"") (print var-name) (println "\"));")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-define (var val-thread next)
  "Generate threaded code for define"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "oop value = ") (print val-thread) (println "(ctx);")
    (c-emit "env_define(ctx->env, intern(\"") (print var) (println "\"), value);")
    (c-emit-line "ctx->acc = value;")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-lambda (params body-thread next)
  "Generate threaded code for lambda with proper closure"
  (let ((thread-name (c-fresh-thread))
        (lambda-name (concat-string "lambda_" (long->string *c-thread-counter*))))
    
    ;; Generate the lambda function
    (print "oop ") (print lambda-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    
    ;; Bind parameters from stack
    (let ((i 0))
      (list-do param params
        (c-emit "oop param") (print i) (print " = POP(ctx);") (println)
        (c-emit "env_define(ctx->env, intern(\"") (print param) (print "\"), param") (print i) (println ");")
        (set i (+ i 1))))
    
    ;; Execute body
    (c-emit "return ") (print body-thread) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    
    ;; Generate the thread that creates the closure
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "ctx->acc = make_closure(") (print lambda-name) (println ", ctx->env);")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-if (test-thread then-thread else-thread next)
  "Generate threaded code for if expression"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "oop test = ") (print test-thread) (println "(ctx);")
    (c-emit-line "if (test != nil && test != false_value) {")
    (set *c-indent-level* 2)
    (c-emit "return ") (print then-thread) (println "(ctx);")
    (set *c-indent-level* 1)
    (c-emit-line "} else {")
    (set *c-indent-level* 2)
    (c-emit "return ") (print else-thread) (println "(ctx);")
    (set *c-indent-level* 1)
    (c-emit-line "}")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-let (bindings body-thread next)
  "Generate threaded code for let with proper environment"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    
    ;; Push new environment frame
    (c-emit-line "Env *saved_env = ctx->env;")
    (c-emit-line "ctx->env = env_extend(ctx->env);")
    
    ;; Generate binding threads
    (list-do binding bindings
      (let ((var (car binding))
            (val-expr (cadr binding)))
        (if (pair? val-expr)
            (let ((val-thread (c-gen-expr-to-threaded-complete val-expr "thread_cont")))
              (c-emit "oop val_") (print var) (print " = ") (print val-thread) (println "(ctx);")
              (c-emit "env_define(ctx->env, intern(\"") (print var) (print "\"), val_") (print var) (println ");"))
            (if (long? val-expr)
                (progn
                  (c-emit "env_define(ctx->env, intern(\"") (print var) (print "\"), LONG(") (print val-expr) (println "));"))
                (c-emit "env_define(ctx->env, intern(\"") (print var) (println "\"), nil);")))))
    
    ;; Execute body
    (c-emit "oop result = ") (print body-thread) (println "(ctx);")
    
    ;; Restore environment
    (c-emit-line "ctx->env = saved_env;")
    (c-emit-line "ctx->acc = result;")
    (c-emit "return ") (print next) (println "(ctx);")
    
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-application (func-thread arg-threads next)
  "Generate threaded code for function application"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    
    ;; Evaluate function
    (c-emit "oop func = ") (print func-thread) (println "(ctx);")
    
    ;; Push arguments on stack (in reverse order)
    (let ((rev-args (reverse arg-threads)))
      (list-do arg-thread rev-args
        (c-emit "PUSH(ctx, ") (print arg-thread) (println "(ctx));")))
    
    ;; Call function
    (c-emit-line "if (is_closure(func)) {")
    (set *c-indent-level* 2)
    (c-emit-line "Closure *cl = (Closure*)func;")
    (c-emit-line "Env *saved_env = ctx->env;")
    (c-emit-line "ctx->env = env_extend(cl->env);")
    (c-emit-line "ctx->acc = cl->func(ctx);")
    (c-emit-line "ctx->env = saved_env;")
    (set *c-indent-level* 1)
    (c-emit-line "} else if (is_primitive(func)) {")
    (set *c-indent-level* 2)
    (c-emit "ctx->acc = apply_primitive(func, ") (print (list-length arg-threads)) (println ", ctx);")
    (set *c-indent-level* 1)
    (c-emit-line "} else {")
    (set *c-indent-level* 2)
    (c-emit-line "error(\"Not a function\");")
    (set *c-indent-level* 1)
    (c-emit-line "}")
    
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

;;; Multi-method dispatch support
(define-function c-gen-threaded-multimethod (type-getter methods next)
  "Generate threaded code for multi-method dispatch"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit-line "oop obj = ctx->acc;")
    (c-emit "int type_id = ") (print type-getter) (println "(obj);")
    (c-emit-line "thread_func method = method_table[type_id];")
    (c-emit-line "if (method) {")
    (set *c-indent-level* 2)
    (c-emit-line "return method(ctx);")
    (set *c-indent-level* 1)
    (c-emit-line "} else {")
    (set *c-indent-level* 2)
    (c-emit-line "error(\"No method for type\");")
    (set *c-indent-level* 1)
    (c-emit-line "}")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

;;; Complete expression compiler
(define-function c-gen-expr-to-threaded-complete (expr next-thread)
  "Convert any expression to threaded code"
  (cond
    ((long? expr)
     (c-gen-threaded-literal expr next-thread))
    
    ((string? expr)
     (c-gen-threaded-string expr next-thread))
    
    ((symbol? expr)
     (c-gen-threaded-variable-ref expr next-thread))
    
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ;; Arithmetic operations
         ((= op '+) (c-gen-binop-from-expr expr "+" next-thread))
         ((= op '-) (c-gen-binop-from-expr expr "-" next-thread))
         ((= op '*) (c-gen-binop-from-expr expr "*" next-thread))
         ((= op '/) (c-gen-binop-from-expr expr "/" next-thread))
         
         ;; Comparison operations
         ((= op '<) (c-gen-comparison-from-expr expr "<" next-thread))
         ((= op '>) (c-gen-comparison-from-expr expr ">" next-thread))
         ((= op '=) (c-gen-comparison-from-expr expr "==" next-thread))
         
         ;; Special forms
         ((= op 'quote)
          (let ((val (cadr expr)))
            (cond
              ((symbol? val) (c-gen-threaded-symbol val next-thread))
              ((long? val) (c-gen-threaded-literal val next-thread))
              ((string? val) (c-gen-threaded-string val next-thread))
              (else (error "Unsupported quote value")))))
         
         ((= op 'if)
          (let* ((test (cadr expr))
                 (then-expr (caddr expr))
                 (else-expr (if (cdddr expr) (cadddr expr) 'nil))
                 (test-thread (c-gen-expr-to-threaded-complete test "thread_cont"))
                 (then-thread (c-gen-expr-to-threaded-complete then-expr next-thread))
                 (else-thread (c-gen-expr-to-threaded-complete else-expr next-thread)))
            (c-gen-threaded-if test-thread then-thread else-thread next-thread)))
         
         ((= op 'let)
          (let* ((bindings (cadr expr))
                 (body (caddr expr))
                 (body-thread (c-gen-expr-to-threaded-complete body "thread_cont")))
            (c-gen-threaded-let bindings body-thread next-thread)))
         
         ((= op 'lambda)
          (let* ((params (cadr expr))
                 (body (caddr expr))
                 (body-thread (c-gen-expr-to-threaded-complete body "thread_ret")))
            (c-gen-threaded-lambda params body-thread next-thread)))
         
         ((= op 'define)
          (let* ((var (cadr expr))
                 (val (caddr expr))
                 (val-thread (c-gen-expr-to-threaded-complete val "thread_cont")))
            (c-gen-threaded-define var val-thread next-thread)))
         
         ((= op 'define-function)
          (let* ((name (cadr expr))
                 (params (caddr expr))
                 (body (cadddr expr))
                 (lambda-expr (list 'lambda params body))
                 (lambda-thread (c-gen-expr-to-threaded-complete lambda-expr "thread_cont")))
            (c-gen-threaded-define name lambda-thread next-thread)))
         
         ;; Function application
         (else
          (let ((func-thread (c-gen-expr-to-threaded-complete (car expr) "thread_cont"))
                (arg-threads (map (lambda (arg)
                                   (c-gen-expr-to-threaded-complete arg "thread_cont"))
                                 (cdr expr))))
            (c-gen-threaded-application func-thread arg-threads next-thread))))))
    
    (else
     (error "Unsupported expression type: " expr))))

;;; Helper for binary operations
(define-function c-gen-binop-from-expr (expr op-str next)
  (let* ((left (cadr expr))
         (right (caddr expr)))
    (if (and (long? left) (long? right))
        (c-gen-threaded-binop op-str left right next)
        (let ((left-thread (c-gen-expr-to-threaded-complete left "thread_cont"))
              (right-thread (c-gen-expr-to-threaded-complete right "thread_cont"))
              (thread-name (c-fresh-thread)))
          (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
          (set *c-indent-level* 1)
          (c-emit "oop left = ") (print left-thread) (println "(ctx);")
          (c-emit "oop right = ") (print right-thread) (println "(ctx);")
          (c-emit "ctx->acc = LONG(getLong(left) ") (print op-str) (println " getLong(right));")
          (c-emit "return ") (print next) (println "(ctx);")
          (set *c-indent-level* 0)
          (println "}")
          (println)
          thread-name))))

;;; Helper for comparison operations
(define-function c-gen-comparison-from-expr (expr op-str next)
  (let* ((left (cadr expr))
         (right (caddr expr))
         (left-thread (c-gen-expr-to-threaded-complete left "thread_cont"))
         (right-thread (c-gen-expr-to-threaded-complete right "thread_cont"))
         (thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "oop left = ") (print left-thread) (println "(ctx);")
    (c-emit "oop right = ") (print right-thread) (println "(ctx);")
    (c-emit "ctx->acc = (getLong(left) ") (print op-str) (println " getLong(right)) ? true_value : false_value;")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

;;; Runtime support generation
(define-function generate-complete-runtime ()
  "Generate complete runtime support for evalm"
  (println "/* Complete Runtime Support for evalm */")
  (println)
  
  ;; Basic types
  (println "typedef long oop;")
  (println "#define nil ((oop)0)")
  (println "#define true_value ((oop)0x1A)")
  (println "#define false_value ((oop)0x0A)")
  (println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (println "#define getLong(x) ((long)(x) >> 1)")
  (println "#define is_long(x) ((x) & 1)")
  (println)
  
  ;; Object types
  (println "typedef enum {")
  (println "    TYPE_LONG, TYPE_STRING, TYPE_SYMBOL, TYPE_PAIR,")
  (println "    TYPE_CLOSURE, TYPE_PRIMITIVE, TYPE_ARRAY")
  (println "} ObjectType;")
  (println)
  
  ;; Environment structure
  (println "typedef struct Env {")
  (println "    struct Env *parent;")
  (println "    oop *names;")
  (println "    oop *values;")
  (println "    int size;")
  (println "    int capacity;")
  (println "} Env;")
  (println)
  
  ;; Closure structure
  (println "typedef struct {")
  (println "    ObjectType type;")
  (println "    thread_func func;")
  (println "    Env *env;")
  (println "} Closure;")
  (println)
  
  ;; Extended thread context
  (println "typedef struct {")
  (println "    oop stack[1024];")
  (println "    oop *sp;")
  (println "    oop locals[256];")
  (println "    oop acc;")
  (println "    Env *env;")
  (println "    thread_func *method_table;")
  (println "} thread_context;")
  (println)
  
  ;; Function declarations
  (println "/* Environment functions */")
  (println "Env* env_new(Env *parent);")
  (println "Env* env_extend(Env *parent);")
  (println "oop env_lookup(Env *env, oop name);")
  (println "void env_define(Env *env, oop name, oop value);")
  (println)
  
  (println "/* Object creation */")
  (println "oop make_string(char *str);")
  (println "oop make_closure(thread_func func, Env *env);")
  (println "oop intern(char *str);")
  (println)
  
  (println "/* Type checking */")
  (println "int is_closure(oop obj);")
  (println "int is_primitive(oop obj);")
  (println "int get_type(oop obj);")
  (println)
  
  (println "/* Application */")
  (println "oop apply_primitive(oop func, int argc, thread_context *ctx);")
  (println)
  
  (println "/* Error handling */")
  (println "void error(char *msg);")
  (println)
  
  ;; String literals
  (println "/* String literals */")
  (list-do lit *string-literals*
    (print "static char ") (print (car lit)) (print "[] = \"") (print (cdr lit)) (println "\";"))
  (println))

;;; Main compilation function
(define-function compile-to-threaded-c (expr)
  "Compile expression to complete threaded C program"
  (set *c-thread-counter* 0)
  (set *string-literals* ())
  
  ;; Generate header
  (println "/* Generated by Maru Threaded C Compiler */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println "#include <string.h>")
  (println)
  
  ;; Generate runtime
  (generate-complete-runtime)
  
  ;; Standard threads
  (println "/* Standard threads */")
  (println "oop thread_ret(thread_context *ctx) {")
  (println "    return ctx->acc;")
  (println "}")
  (println)
  
  (println "oop thread_cont(thread_context *ctx) {")
  (println "    return ctx->acc;")
  (println "}")
  (println)
  
  ;; Compile expression
  (let ((main-thread (c-gen-expr-to-threaded-complete expr "thread_ret")))
    
    ;; Main function
    (println "int main() {")
    (set *c-indent-level* 1)
    (c-emit-line "thread_context ctx = {0};")
    (c-emit-line "ctx.sp = ctx.stack;")
    (c-emit-line "ctx.env = env_new(NULL);")
    (c-emit-line)
    (c-emit "oop result = ") (print main-thread) (println "(&ctx);")
    (c-emit-line)
    (c-emit-line "printf(\"Result: %ld\\n\", is_long(result) ? getLong(result) : 0);")
    (c-emit-line "return 0;")
    (set *c-indent-level* 0)
    (println "}")))

;;; Reverse helper
(define-function reverse (lst)
  (let ((result ()))
    (while lst
      (set result (cons (car lst) result))
      (set lst (cdr lst)))
    result))

(println "emit-c-threaded-complete.l loaded")