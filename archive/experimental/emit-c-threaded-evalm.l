;;; emit-c-threaded-evalm.l -- Enhanced Threaded C Backend for evalm
;;;
;;; This version can handle more complex operations needed for evalm compilation

;;; Load the base threaded backend
(load "emit-c-threaded-fixed.l")

;;; Additional operations for evalm support

(define-function c-gen-threaded-variable (var-name next)
  "Generate threaded code for variable reference"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "ctx->acc = lookup_variable(\"") (print var-name) (println "\", ctx);")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-let (bindings body-thread next)
  "Generate threaded code for let binding"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit-line "/* Push new environment frame */")
    (c-emit-line "push_env_frame(ctx);")
    
    ;; Generate bindings
    (list-do binding bindings
      (let ((var (car binding))
            (val (cadr binding)))
        (c-emit "bind_variable(\"") (print var) (print "\", ")
        (if (long? val)
            (print "LONG(" val ")")
            (print "nil"))
        (println ", ctx);")))
    
    ;; Execute body
    (c-emit "oop result = ") (print body-thread) (println "(ctx);")
    
    ;; Pop environment frame
    (c-emit-line "pop_env_frame(ctx);")
    (c-emit-line "ctx->acc = result;")
    (c-emit "return ") (print next) (println "(ctx);")
    
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-lambda (params body-thread next)
  "Generate threaded code for lambda"
  (let ((thread-name (c-fresh-thread))
        (lambda-name (concat-string "lambda_" (long->string *c-thread-counter*))))
    
    ;; Generate the lambda function
    (print "oop ") (print lambda-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit-line "/* Lambda body */")
    (c-emit "return ") (print body-thread) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    
    ;; Generate the thread that creates the closure
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    (c-emit "ctx->acc = make_closure(") (print lambda-name) (println ", ctx);")
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

(define-function c-gen-threaded-funcall (func-thread args-threads next)
  "Generate threaded code for function call"
  (let ((thread-name (c-fresh-thread)))
    (print "oop ") (print thread-name) (println "(thread_context *ctx) {")
    (set *c-indent-level* 1)
    
    ;; Evaluate function
    (c-emit "oop func = ") (print func-thread) (println "(ctx);")
    
    ;; Evaluate arguments
    (let ((arg-count 0))
      (list-do arg-thread args-threads
        (c-emit "oop arg") (print arg-count) (print " = ")
        (print arg-thread) (println "(ctx);")
        (set arg-count (+ arg-count 1))))
    
    ;; Call function
    (c-emit-line "/* Call function with arguments */")
    (c-emit "ctx->acc = apply_function(func")
    (let ((i 0))
      (list-do arg args-threads
        (print ", arg") (print i)
        (set i (+ i 1))))
    (println ", ctx);")
    
    (c-emit "return ") (print next) (println "(ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    thread-name))

;;; Extended expression compiler
(define-function c-gen-expr-to-threaded-extended (expr next-thread)
  "Convert extended expressions to threaded code"
  (cond
    ((long? expr)
     (c-gen-threaded-literal expr next-thread))
    
    ((symbol? expr)
     (c-gen-threaded-variable expr next-thread))
    
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ((= op '+)
          (let* ((left (cadr expr))
                 (right (caddr expr)))
            (if (and (long? left) (long? right))
                (c-gen-threaded-binop "+" left right next-thread)
                (error "Complex arithmetic not yet supported"))))
         
         ((= op 'let)
          (let ((bindings (cadr expr))
                (body (caddr expr)))
            (let ((body-thread (c-gen-expr-to-threaded-extended body "thread_ret")))
              (c-gen-threaded-let bindings body-thread next-thread))))
         
         ((= op 'lambda)
          (let ((params (cadr expr))
                (body (caddr expr)))
            (let ((body-thread (c-gen-expr-to-threaded-extended body "thread_ret")))
              (c-gen-threaded-lambda params body-thread next-thread))))
         
         (else
          ;; Function call
          (let ((func-thread (c-gen-expr-to-threaded-extended (car expr) "thread_cont"))
                (arg-threads (map (lambda (arg) 
                                   (c-gen-expr-to-threaded-extended arg "thread_cont"))
                                 (cdr expr))))
            (c-gen-threaded-funcall func-thread arg-threads next-thread))))))
    
    (else
     (error "Unsupported expression type"))))

;;; Runtime support functions
(define-function generate-runtime-support ()
  "Generate runtime support functions for evalm"
  (println "/* Runtime support for evalm */")
  (println)
  (println "typedef struct Env {")
  (println "    struct Env *parent;")
  (println "    oop bindings[256];")
  (println "    char *names[256];")
  (println "    int count;")
  (println "} Env;")
  (println)
  (println "typedef struct {")
  (println "    thread_func func;")
  (println "    Env *env;")
  (println "} Closure;")
  (println)
  (println "oop lookup_variable(char *name, thread_context *ctx) {")
  (println "    /* Simplified variable lookup */")
  (println "    return nil;")
  (println "}")
  (println)
  (println "void bind_variable(char *name, oop value, thread_context *ctx) {")
  (println "    /* Simplified variable binding */")
  (println "}")
  (println)
  (println "void push_env_frame(thread_context *ctx) {")
  (println "    /* Push new environment frame */")
  (println "}")
  (println)
  (println "void pop_env_frame(thread_context *ctx) {")
  (println "    /* Pop environment frame */")
  (println "}")
  (println)
  (println "oop make_closure(thread_func func, thread_context *ctx) {")
  (println "    /* Create closure */")
  (println "    return nil;")
  (println "}")
  (println)
  (println "oop apply_function(oop func, oop arg0, thread_context *ctx) {")
  (println "    /* Apply function */")
  (println "    return nil;")
  (println "}")
  (println))

;;; Test evalm-style compilation
(define-function test-evalm-compilation ()
  "Test compiling evalm-style code"
  (println "\n=== Evalm-Style Compilation Test ===")
  (generate-threaded-c-header)
  (generate-runtime-support)
  
  ;; Return thread
  (println "oop thread_ret(thread_context *ctx) {")
  (println "    return ctx->acc;")
  (println "}")
  (println)
  
  ;; Test expression: (let ((x 10)) (+ x 32))
  (let* ((expr '(let ((x 10)) (+ x 32)))
         (main-thread (c-gen-expr-to-threaded-extended expr "thread_ret")))
    
    (println "/* Test expression: (let ((x 10)) (+ x 32)) */")
    (println "oop eval_let_expr() {")
    (set *c-indent-level* 1)
    (c-emit-line "thread_context ctx = {0};")
    (c-emit-line "ctx.sp = ctx.stack;")
    (c-emit "return ") (print main-thread) (println "(&ctx);")
    (set *c-indent-level* 0)
    (println "}")
    (println)
    
    (println "int main() {")
    (set *c-indent-level* 1)
    (c-emit-line "printf(\"Evalm-style threaded compilation test\\n\");")
    (c-emit-line "/* Would execute: (let ((x 10)) (+ x 32)) */")
    (c-emit-line "return 0;")
    (set *c-indent-level* 0)
    (println "}")))

(println "emit-c-threaded-evalm.l loaded")