;;; simple-arithmetic-threaded.l - Simple Arithmetic Threaded C Backend

;; Generate threaded C program for (+ 40 2)
(define-function gen-add-40-2 ()
  ;; Header
  (println "/* Threaded C Code for (+ 40 2) */")
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
  
  ;; Add operation thread
  (println "oop thread_2(thread_context *ctx) {")
  (println "    ctx->acc = LONG(40 + 2);")
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

;; Generate
(gen-add-40-2)