;;; threaded-arithmetic.l - Threaded C Backend with Arithmetic

;; Generate threaded C program with arithmetic support
(define-function threaded-arithmetic-gen (expr)
  ;; Header
  (println "/* Threaded C Code with Arithmetic */")
  (println "#include <stdio.h>")
  (println "#include <stdlib.h>")
  (println)
  (println "typedef void *oop;")
  (println "#define LONG(n) ((oop)(((long)(n) << 1) | 1))")
  (println "#define getLong(x) ((long)(x) >> 1)")
  (println)
  (println "typedef struct {")
  (println "    oop stack[1024];") 
  (println "    oop *sp;")
  (println "    oop acc;")
  (println "} thread_context;")
  (println)
  
  ;; Forward declarations
  (println "/* Forward declarations */")
  (println "oop thread_1(thread_context *ctx);")
  (println "oop thread_2(thread_context *ctx);")
  (println)
  
  ;; Return thread
  (println "/* Thread implementations */")
  (println "oop thread_1(thread_context *ctx) {")
  (println "    return ctx->acc;")
  (println "}")
  (println)
  
  ;; Main computation thread
  (println "oop thread_2(thread_context *ctx) {")
  (if (long? expr)
      ;; Simple literal
      (begin
        (print "    ctx->acc = LONG(" expr ");")
        (println))
      ;; Arithmetic expression
      (if (and (pair? expr) (= (car expr) '+))
          (let ((left (cadr expr))
                (right (caddr expr)))
            (if (and (long? left) (long? right))
                (begin
                  (print "    ctx->acc = LONG(" left " + " right ");")
                  (println))
                (begin
                  (println "    /* Non-literal arithmetic not yet supported */")
                  (println "    ctx->acc = LONG(0);"))))
          (begin
            (println "    /* Expression type not supported */")
            (println "    ctx->acc = LONG(0);"))))
  (println "    return thread_1(ctx);")
  (println "}")
  (println)
  
  ;; Main
  (println "int main() {")
  (println "    thread_context ctx = {0};")
  (println "    ctx.sp = ctx.stack;")
  (println "    oop result = thread_2(&ctx);")
  (println "    printf(\"Result: %ld\\n\", getLong(result));")
  (println "    return 0;")
  (println "}")
  )

;; Test with arithmetic
(threaded-arithmetic-gen '(+ 40 2))