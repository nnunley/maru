/* jit-runtime.c - Runtime support for Maru JIT PoC */

#include <dlfcn.h>
#include <stdio.h>
#include <stdlib.h>

/* Wrapper functions for dlopen/dlsym/dlclose */

void* dlopen_wrapper(const char* path) {
    void* handle = dlopen(path, RTLD_NOW | RTLD_LOCAL);
    if (!handle) {
        fprintf(stderr, "dlopen error: %s\n", dlerror());
    }
    return handle;
}

void* dlsym_wrapper(void* handle, const char* symbol) {
    void* sym = dlsym(handle, symbol);
    if (!sym) {
        fprintf(stderr, "dlsym error for %s: %s\n", symbol, dlerror());
    }
    return sym;
}

int dlclose_wrapper(void* handle) {
    return dlclose(handle);
}

/* Call a compiled function that takes no args and returns long */
long call_fn_0(void* fn) {
    typedef long (*fn_t)();
    return ((fn_t)fn)();
}

/* Call a compiled function that takes 1 arg and returns long */
long call_fn_1(void* fn, long arg1) {
    typedef long (*fn_t)(long);
    return ((fn_t)fn)(arg1);
}

/* Call a compiled function that takes 2 args and returns long */
long call_fn_2(void* fn, long arg1, long arg2) {
    typedef long (*fn_t)(long, long);
    return ((fn_t)fn)(arg1, arg2);
}