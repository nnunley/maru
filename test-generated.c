#include <stdio.h>
#include <stdlib.h>

typedef union Object *oop;
#define nil ((oop)0)
#define LONG(n) ((oop)(((long)(n) << 1) | 1))
#define getLong(x) ((long)(x) >> 1)

// Forward declarations
static oop add_2Dtwo(oop a, oop b);
static oop multiply(oop x, oop y);

static oop main(void)
{
    return add_2Dtwo(LONG(5), LONG(7));
}

static oop multiply(oop x, oop y)
{
    return LONG(getLong(x) * getLong(y));
}

static oop v_multiply = (oop)multiply;

static oop add_2Dtwo(oop a, oop b)
{
    return LONG(getLong(a) + getLong(b));
}

static oop v_add_2Dtwo = (oop)add_2Dtwo;

// Test main function
int real_main() {
    oop result = main();
    printf("Result: %ld\n", getLong(result));
    return 0;
}
