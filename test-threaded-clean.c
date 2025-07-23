#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef union Object *oop;
#define nil ((oop)0)
#define LONG(n) ((oop)(((long)(n) << 1) | 1))
#define getLong(x) ((long)(x) >> 1)

/* Threaded execution context */
typedef struct {
    oop stack[1024];   /* Value stack */
    oop *sp;           /* Stack pointer */
    oop locals[256];   /* Local variables */
    oop acc;           /* Accumulator */
} thread_context;

typedef oop (*thread_func)(thread_context *ctx);

/* Stack operations */
#define PUSH(ctx, val) (*((ctx)->sp++) = (val))
#define POP(ctx) (*(--(ctx)->sp))
#define PEEK(ctx) (*((ctx)->sp - 1))

oop thread_1(thread_context *ctx) {
    return ctx->acc;
}

oop thread_2(thread_context *ctx) {
    long left = 40;
    long right = 2;
    ctx->acc = LONG(left + right);
    return thread_1(ctx);
}

oop add_42_threaded() {
    thread_context ctx = {0};
    ctx.sp = ctx.stack;
    return thread_2(&ctx);
}

int main() {
    oop result = add_42_threaded();
    printf("Threaded result: %ld\n", getLong(result));
    return 0;
}
