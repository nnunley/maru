;;; working-threaded.l - Working Threaded C Backend

;; Thread counter
(define *thread-num* 0)

;; Generate unique thread name (simplified)
(define-function next-thread ()
  (set *thread-num* (+ *thread-num* 1))
  (if (= *thread-num* 1) "thread_1"
      (if (= *thread-num* 2) "thread_2"
          (if (= *thread-num* 3) "thread_3"
              "thread_n"))))

;; Storage for generated code
(define *forward-decls* ())
(define *implementations* ())

;; Add forward declaration
(define-function add-forward-decl (decl)
  (set *forward-decls* (cons decl *forward-decls*)))

;; Add implementation
(define-function add-implementation (impl)
  (set *implementations* (cons impl *implementations*)))

;; Generate literal thread
(define-function gen-literal-thread (value next-thread)
  (let ((name (next-thread)))
    ;; Forward declaration
    (add-forward-decl (concat-string "oop " (concat-string name "(thread_context *ctx);")))
    
    ;; Implementation
    (add-implementation
      (lambda ()
        (println "oop " name "(thread_context *ctx) {")
        (print "    ctx->acc = LONG(" value ");")
        (println "    return " next-thread "(ctx);")
        (println "}")))
    
    name))

;; Generate return thread
(define-function gen-return-thread ()
  (let ((name (next-thread)))
    ;; Forward declaration  
    (add-forward-decl (concat-string "oop " (concat-string name "(thread_context *ctx);")))
    
    ;; Implementation
    (add-implementation
      (lambda ()
        (println "oop " name "(thread_context *ctx) {")
        (println "    return ctx->acc;")
        (println "}")))
    
    name))

;; Generate complete program
(define-function gen-threaded-program (expr)
  ;; Reset state
  (set *thread-num* 0)
  (set *forward-decls* ())
  (set *implementations* ())
  
  ;; Generate threads
  (let* ((ret-thread (gen-return-thread))
         (main-thread (gen-literal-thread expr ret-thread)))
    
    ;; Output header
    (println "/* Threaded C Code */")
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
    (let ((decls *forward-decls*))
      (while decls
        (println (car decls))
        (set decls (cdr decls))))
    (println)
    
    ;; Implementations
    (println "/* Thread implementations */")
    (let ((impls *implementations*))
      (while impls
        (let ((impl (car impls)))
          (impl))
        (println)
        (set impls (cdr impls))))
    
    ;; Main function
    (println "int main() {")
    (println "    thread_context ctx = {0};")
    (println "    ctx.sp = ctx.stack;")
    (println "    oop result = " main-thread "(&ctx);")
    (println "    printf(\"Result: %ld\\n\", getLong(result));")
    (println "    return 0;")
    (println "}")
    ))

;; Test
(println "=== Generating threaded program for 42 ===")
(gen-threaded-program 42)