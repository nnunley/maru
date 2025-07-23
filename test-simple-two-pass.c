#include <stdio.h>
#include <stdlib.h>

typedef union Object *oop;
#define nil ((oop)0)
#define LONG(n) ((oop)(((long)(n) << 1) | 1))
#define getLong(x) ((long)(x) >> 1)

// Forward declarations
static oop add_2Dtwo(oop a, oop b);
static oop multiply(oop x, oop y);  
static oop max(oop a, oop b);
static oop test_2Dmain(void);

// Function implementations
static oop add_2Dtwo(oop a, oop b)
{
    return LONG(getLong(a) + getLong(b));
}

static oop v_add_2Dtwo = (oop)add_2Dtwo;

static oop multiply(oop x, oop y)
{
    return LONG(getLong(x) * getLong(y));
}

static oop v_multiply = (oop)multiply;

static oop max(oop a, oop b)
{
    return ((getLong(a) > getLong(b)) ? a : b);
}

static oop v_max = (oop)max;

static oop test_2Dmain(void)
{
    return add_2Dtwo(multiply(LONG(3), LONG(4)), max(LONG(5), LONG(2)));
}

static oop v_test_2Dmain = (oop)test_2Dmain;

int main() {
    oop result = test_2Dmain();
    printf("Result: %ld\n", getLong(result));
    return 0;
}