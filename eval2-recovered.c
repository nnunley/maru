// last edited: 2012-12-23 23:25:00 by piumarta on emilia.local

#define DEMO_BITS	1

#define _ISOC99_SOURCE	1
#define _BSD_SOURCE	1

#include <stdio.h>
#include <locale.h>
#include <stdarg.h>
#include <errno.h>
#include <math.h>
#include <signal.h>

// #include <stddef.h>
// #include <string.h>
// #include <sys/types.h>

#if defined(__MACH__)
# include <ffi/ffi.h>
#else
# include <ffi.h>
#endif

// #include <assert.h>

extern int isatty(int);

#if defined(WIN32)
# include <malloc.h>
# define swnprintf(BUF, SIZE, FMT, ARG) swprintf(BUF, FMT, ARG)
#else
# define swnprintf swprintf
#endif

// #define	TAG_INT	1
// //#define	LIB_GC	1

#if defined(NDEBUG)
# define GC_APP_HEADER	int type;
#else
# define GC_APP_HEADER	int printing, type;
#endif

#define GC_SAVE		1

#if (LIB_GC)
# include "libgc.c"
#else
# include "gc.c"
#endif
#include "wcs.c"
#include "buffer.c"

union Object;

typedef union Object *oop;

typedef oop (*imp_t)(oop args, oop env);

typedef union {
    int		 arg_int;
    int32_t	 arg_int32;
    int64_t	 arg_int64;
    long	 arg_long;
    float	 arg_float;
    double	 arg_double;
    void	*arg_pointer;
    char	*arg_string;
    wchar_t	*arg_String;
} arg_t;

typedef void (*cast_t)(oop arg, void **argp, arg_t *buf);

typedef struct {
    int		 arg_count;
    int		 arg_rest;
    ffi_type	*arg_types[32];
    cast_t	 arg_casts[32];
} proto_t;

#define nil ((oop)0)

enum {
    Undefined, Data, Long, Double, String, Symbol, Pair, _Array, Array, Expr, Form, Fixed, Subr,
//  Variable, Env, Context
};

typedef long long_t;

struct Data	{ };
struct Long	{ long_t    bits; };
struct Double	{ double    bits; };
struct String	{ oop	    size;  wchar_t *bits; };	/* bits is in managed memory */
struct Symbol	{ wchar_t  *bits; int flags};
struct Pair	{ oop	    head, tail, source; };
struct Array	{ oop	    size, _array; };
struct Expr	{ oop	    name, definition, environment, profile; };
struct Form	{ oop	    function, symbol; };
struct Fixed	{ oop	    function; };
