/* Simple Threaded C Code */
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
    ctx->acc = LONG(42);    return thread_1(ctx);
}

int main() {
    thread_context ctx = {0};
    ctx.sp = ctx.stack;
    oop result = thread_2(&ctx);
    printf("Result: %ld\n", getLong(result));
    return 0;
}
