#include <stdio.h>
#include <stdlib.h>

typedef union Object *oop;
#define nil ((oop)0)
#define LONG(n) ((oop)(((long)(n) << 1) | 1))
#define getLong(x) ((long)(x) >> 1)

## defn main
static oop main(void)
{
    return add_2Dtwo(LONG(5), LONG(7));
}

## defn multiply
static oop multiply(oop x, oop y)
{
    return LONG(getLong(x) * getLong(y));
}

static oop v_multiply = (oop)multiply;
## defn add-two
static oop add_2Dtwo(oop a, oop b)
{
    return LONG(getLong(a) + getLong(b));
}

static oop v_add_2Dtwo = (oop)add_2Dtwo;
