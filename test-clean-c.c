#include <stdio.h>
#include <stdlib.h>

typedef union Object *oop;
#define nil ((oop)0)
#define LONG(n) ((oop)(((long)(n) << 1) | 1))
#define getLong(x) ((long)(x) >> 1)

// Forward declarations
static oop maru_2Dmain(void);
static oop test_2Dif(oop x);
static oop multiply(oop x, oop y);
static oop add_2Dtwo(oop a, oop b);

static oop maru_2Dmain(void)
{
    return add_2Dtwo(multiply(LONG(3), LONG(4)), LONG(5));
}

static oop v_maru_2Dmain = (oop)maru_2Dmain;

static oop test_2Dif(oop x)
{
    return (((long)(x) & 1) ? x : LONG(0));
}

static oop v_test_2Dif = (oop)test_2Dif;

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

int main() {
    oop result = maru_2Dmain();
    printf("Result: %ld\n", getLong(result));
    return 0;
}