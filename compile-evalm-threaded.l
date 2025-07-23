;;; compile-evalm-threaded.l -- Compile evalm.l to threaded C
;;;
;;; This integrates the threaded C backend with evalm's parser

(println "Loading threaded C compiler for evalm...")

;; Load the complete threaded backend
(load "emit-c-threaded-complete.l")

;;; Parse evalm.l and extract key definitions
(define-function parse-evalm-file (filename)
  "Parse evalm.l and extract expressions"
  (let ((exprs ())
        (input (open filename "r")))
    (if input
        (let ((expr ()))
          (while (set expr (read input))
            (set exprs (cons expr exprs)))
          (close input)
          (reverse exprs))
        (error "Cannot open file: " filename))))

;;; Filter and process evalm expressions
(define-function process-evalm-expr (expr)
  "Process evalm expression for compilation"
  (cond
    ;; Skip comments and debug output
    ((and (pair? expr) (= (car expr) 'println))
     ())
    
    ;; Convert define-function to our format
    ((and (pair? expr) (= (car expr) 'define-function))
     expr)
    
    ;; Keep other definitions
    ((and (pair? expr) (= (car expr) 'define))
     expr)
    
    ;; Keep let expressions
    ((and (pair? expr) (= (car expr) 'let))
     expr)
    
    ;; Skip everything else for now
    (else ())))

;;; Compile evalm to threaded C
(define-function compile-evalm-to-c ()
  "Main function to compile evalm.l to threaded C"
  (println "=== Compiling evalm.l to Threaded C ===")
  (println)
  
  ;; Generate header
  (println "/* evalm-threaded.c - Generated from evalm.l */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println "#include <string.h>")
  (println)
  
  ;; Generate runtime (simplified version)
  (generate-complete-runtime)
  
  ;; Generate minimal runtime implementation
  (println "/* Minimal Runtime Implementation */")
  (println)
  (println "Env* env_new(Env *parent) {")
  (println "    Env *env = malloc(sizeof(Env));")
  (println "    env->parent = parent;")
  (println "    env->capacity = 256;")
  (println "    env->size = 0;")
  (println "    env->names = malloc(sizeof(oop) * env->capacity);")
  (println "    env->values = malloc(sizeof(oop) * env->capacity);")
  (println "    return env;")
  (println "}")
  (println)
  
  (println "Env* env_extend(Env *parent) {")
  (println "    return env_new(parent);")
  (println "}")
  (println)
  
  (println "oop env_lookup(Env *env, oop name) {")
  (println "    while (env) {")
  (println "        for (int i = 0; i < env->size; i++) {")
  (println "            if (env->names[i] == name) {")
  (println "                return env->values[i];")
  (println "            }")
  (println "        }")
  (println "        env = env->parent;")
  (println "    }")
  (println "    return nil;")
  (println "}")
  (println)
  
  (println "void env_define(Env *env, oop name, oop value) {")
  (println "    if (env->size < env->capacity) {")
  (println "        env->names[env->size] = name;")
  (println "        env->values[env->size] = value;")
  (println "        env->size++;")
  (println "    }")
  (println "}")
  (println)
  
  (println "oop intern(char *str) {")
  (println "    /* Simplified interning */")
  (println "    return (oop)str;")
  (println "}")
  (println)
  
  (println "oop make_string(char *str) {")
  (println "    return (oop)str;")
  (println "}")
  (println)
  
  (println "oop make_closure(thread_func func, Env *env) {")
  (println "    Closure *cl = malloc(sizeof(Closure));")
  (println "    cl->type = TYPE_CLOSURE;")
  (println "    cl->func = func;")
  (println "    cl->env = env;")
  (println "    return (oop)cl;")
  (println "}")
  (println)
  
  (println "int is_closure(oop obj) {")
  (println "    return !is_long(obj) && ((Closure*)obj)->type == TYPE_CLOSURE;")
  (println "}")
  (println)
  
  (println "int is_primitive(oop obj) {")
  (println "    return 0; /* No primitives yet */")
  (println "}")
  (println)
  
  (println "void error(char *msg) {")
  (println "    fprintf(stderr, \"Error: %s\\n\", msg);")
  (println "    exit(1);")
  (println "}")
  (println)
  
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
  
  ;; Compile some test expressions
  (println "/* Test expressions from evalm */")
  (set *c-thread-counter* 0)
  
  ;; Example 1: Simple arithmetic
  (let ((expr1 '(+ 10 32)))
    (println "/* Expression: " expr1 " */")
    (c-gen-expr-to-threaded-complete expr1 "thread_ret"))
  
  ;; Example 2: Let binding
  (let ((expr2 '(let ((x 42)) x)))
    (println "/* Expression: " expr2 " */")
    (c-gen-expr-to-threaded-complete expr2 "thread_ret"))
  
  ;; Example 3: Function definition and call
  (let ((expr3 '(define-function add (a b) (+ a b))))
    (println "/* Expression: " expr3 " */")
    (c-gen-expr-to-threaded-complete expr3 "thread_ret"))
  
  ;; Main function
  (println "int main() {")
  (set *c-indent-level* 1)
  (c-emit-line "thread_context ctx = {0};")
  (c-emit-line "ctx.sp = ctx.stack;")
  (c-emit-line "ctx.env = env_new(NULL);")
  (c-emit-line)
  (c-emit-line "printf(\"evalm threaded C compilation test\\n\");")
  (c-emit-line)
  
  ;; Test 1
  (c-emit-line "/* Test 1: (+ 10 32) */")
  (c-emit-line "ctx.acc = nil;")
  (c-emit-line "oop result1 = thread_1(&ctx);")
  (c-emit-line "printf(\"Test 1 result: %ld\\n\", getLong(result1));")
  (c-emit-line)
  
  ;; Test 2  
  (c-emit-line "/* Test 2: (let ((x 42)) x) */")
  (c-emit-line "ctx.acc = nil;")
  (c-emit-line "oop result2 = thread_3(&ctx);")
  (c-emit-line "printf(\"Test 2 result: %ld\\n\", getLong(result2));")
  (c-emit-line)
  
  ;; Test 3
  (c-emit-line "/* Test 3: Define and call add function */")
  (c-emit-line "ctx.acc = nil;")
  (c-emit-line "thread_7(&ctx); /* Define add */")
  (c-emit-line "/* Would call: (add 5 7) */")
  (c-emit-line)
  
  (c-emit-line "return 0;")
  (set *c-indent-level* 0)
  (println "}"))

;;; Test the compiler
(compile-evalm-to-c)