/* test-eval-k-generated.c - Test harness for eval.k generated C code */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/* Stub implementations of GC functions for testing */
void* gc_malloc(int64_t size) {
    return calloc(1, size);
}

void* gc_malloc_atomic(int64_t size) {
    return calloc(1, size);
}

void gc_push_root(void** ptr) {
    /* No-op for testing */
}

void gc_pop_root(void** ptr) {
    /* No-op for testing */
}

void gc_initialise(void) {
    /* No-op for testing */
}

/* Include the generated code */
#define STANDALONE_TEST
#include "eval-k-generated.c"