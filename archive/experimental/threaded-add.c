/* Threaded C Code with Arithmetic */
#include <stdio.h>
#include <stdlib.h>

typedef void *oop;
#define LONG(n) ((oop)(((long)(n) << 1) | 1))
#define getLong(x) ((long)(x) >> 1)

typedef struct {
    oop stack[1024];
    oop *sp;
    oop acc;
} thread_context;

/* Forward declarations */
oop thread_1(thread_context *ctx);
oop thread_2(thread_context *ctx);

/* Thread implementations */
oop thread_1(thread_context *ctx) {
    return ctx->acc;
}

oop thread_2(thread_context *ctx) {
[32m[?7lthreaded-arithmetic.l:46[0m (begin (print "    ctx->acc = LONG(" left " + " right ");") (println))
[?7h[32m[?7lthreaded-arithmetic.l:45[0m (if (and (long? left) (long? right)) (begin (print "    ctx->acc = LONG(" left " + " right ");") (println)) (begin (println "    /* Non-literal arithmetic not yet supported */") (println "    ctx->acc = LONG(0);")))
[?7h[32m[?7lthreaded-arithmetic.l:43[0m (let ((left (cadr expr)) (right (caddr expr))) (if (and (long? left) (long? right)) (begin (print "    ctx->acc = LONG(" left " + " right ");") (println)) (begin (println "    /* Non-literal arithmetic not yet supported */") (println "    ctx->acc = LONG(0);"))))
[?7h[32m[?7lthreaded-arithmetic.l:42[0m (if (and (pair? expr) (= (car expr) (quote +))) (let ((left (cadr expr)) (right (caddr expr))) (if (and (long? left) (long? right)) (begin (print "    ctx->acc = LONG(" left " + " right ");") (println)) (begin (println "    /* Non-literal arithmetic not yet supported */") (println "    ctx->acc = LONG(0);")))) (begin (println "    /* Expression type not supported */") (println "    ctx->acc = LONG(0);")))
[?7h[32m[?7lthreaded-arithmetic.l:36[0m (if (long? expr) (begin (print "    ctx->acc = LONG(" expr ");") (println)) (if (and (pair? expr) (= (car expr) (quote +))) (let ((left (cadr expr)) (right (caddr expr))) (if (and (long? left) (long? right)) (begin (print "    ctx->acc = LONG(" left " + " right ");") (println)) (begin (println "    /* Non-literal arithmetic not yet supported */") (println "    ctx->acc = LONG(0);")))) (begin (println "    /* Expression type not supported */") (println "    ctx->acc = LONG(0);"))))
[?7h[32m[?7lthreaded-arithmetic.l:70[0m (threaded-arithmetic-gen (quote (+ 40 2)))
[?7h