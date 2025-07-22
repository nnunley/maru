#ifndef EVAL_H
#define EVAL_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <wchar.h>
#include <ffi.h>
#include <assert.h>

// GC_APP_HEADER is defined in gc.h
#define GC_APP_HEADER int type;

// Forward declarations for GC functions
extern void GC_add_root(void *p);
extern void GC_delete_root(void *p);
extern void *GC_malloc(size_t size);
extern void *GC_malloc_atomic(size_t size);
extern void GC_gcollect(void);
extern int GC_atomic(void *obj);
extern size_t GC_size(void *obj);

// Main object type
typedef union Object *oop;

// Object types enum
enum { Undefined, Data, Long, Double, String, Symbol, Pair, _Array, Array, Expr, Form, Fixed, Subr, Variable, Env, Context };

// Struct definitions (simplified for header)
struct Data	{ GC_APP_HEADER };
struct Long	{ GC_APP_HEADER long	    bits; };
struct Double	{ GC_APP_HEADER double    bits; };
struct String	{ GC_APP_HEADER oop       size;  wchar_t *bits; };
struct Symbol	{ GC_APP_HEADER wchar_t  *bits; };
struct Pair	{ GC_APP_HEADER oop 	    head, tail, source; };
struct Array	{ GC_APP_HEADER oop       size, _array; };
struct Expr	{ GC_APP_HEADER oop 	    name, defn, ctx, profile; };
struct Form	{ GC_APP_HEADER oop 	    function, symbol; };
struct Fixed	{ GC_APP_HEADER oop       function; };
struct Subr	{ GC_APP_HEADER wchar_t  *name;  void *imp;  void *sig;  int profile; };
struct Variable	{ GC_APP_HEADER oop 	    name, value, env, index, type; };
struct Env	{ GC_APP_HEADER oop 	    parent, level, offset, bindings, stable; };
struct Context	{ GC_APP_HEADER oop 	    home, env, bindings, callee, pc; };

union Object {
  GC_APP_HEADER
  struct Data		Data;
  struct Long		Long;
  struct Double		Double;
  struct String		String;
  struct Symbol		Symbol;
  struct Pair		Pair;
  struct Array		Array;
  struct Expr		Expr;
  struct Form		Form;
  struct Fixed		Fixed;
  struct Subr		Subr;
  struct Variable	Variable;
  struct Env		Env;
  struct Context	Context;
};

// Runtime functions (from eval.c)
extern oop make_pair(oop head, oop tail);
extern oop car(oop pair);
extern oop cdr(oop pair);

// Macros from eval.c
#define TAG_INT 1

#if (TAG_INT)
  static inline int getType(oop obj)	{ return obj ? (((long)obj & 1) ? Long : ((struct { int type; } *)obj)->type) : Undefined; }
#else
  static inline int getType(oop obj)	{ return obj ? ((struct { int type; } *)obj)->type : Undefined; }
#endif

#define is(TYPE, OBJ)			((OBJ) && (TYPE == getType(OBJ)))

#define setType(OBJ, TYPE)		(((struct { int type; } *)OBJ)->type = (TYPE))

#define get(OBJ, TYPE, FIELD)		(((struct TYPE *)OBJ)->FIELD)
#define set(OBJ, TYPE, FIELD, VALUE)	(((struct TYPE *)OBJ)->FIELD = (VALUE))

#if (TAG_INT)
  static inline int  isLong(oop x)	{ return (((long)x & 1) || Long == getType(x)); }
  static inline oop  newLong(long x)	{ if ((x ^ (x << 1)) < 0) { oop obj= GC_malloc_atomic(sizeof(struct Long));  set(obj, Long,bits, x);  return obj; }  return ((oop)((x << 1) | 1)); }
  static inline long getLong(oop x)	{ if ((long)x & 1) return (long)x >> 1;  return get(x, Long,bits); }
#else
# define     isLong(X)			is(Long, (X))
  static oop newLong(long bits)		{ oop obj= GC_malloc_atomic(sizeof(struct Long));  set(obj, Long,bits, bits);  return obj; }
# define     getLong(X)			get((X), Long,bits)
#endif

#endif // EVAL_H
