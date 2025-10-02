;;; simple-working-threaded.l - Simple Working Threaded C Backend

;; Generate simple threaded C program
(define-function simple-threaded-gen (value)
  ;; Header
  (println "/* Simple Threaded C Code */")
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
  
  ;; Value thread
  (println "oop thread_2(thread_context *ctx) {")
  (print "    ctx->acc = LONG(" value ");")
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

;; Test - generate without debug output to stderr
(simple-threaded-gen 42)