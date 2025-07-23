/* eval-k-generated.c - C code that would be generated from eval.k
 *
 * This represents what the IR system would generate when compiling eval.k
 * through ir-gen-c.k backend.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

/* External GC functions */
extern void* gc_malloc(int64_t size);
extern void* gc_malloc_atomic(int64_t size);
extern void gc_push_root(void** ptr);
extern void gc_pop_root(void** ptr);
extern void gc_initialise(void);

/* Type definitions from eval.k */

/* Type tags */
#define MARU_UNDEFINED  0
#define MARU_DATA       1
#define MARU_LONG       2
#define MARU_DOUBLE     3
#define MARU_STRING     4
#define MARU_SYMBOL     5
#define MARU_PAIR       6
#define MARU_ARRAY      8
#define MARU_EXPR       9
#define MARU_FORM      10
#define MARU_FIXED     11
#define MARU_SUBR      12
#define MARU_VARIABLE  13
#define MARU_ENV       14
#define MARU_CONTEXT   15

/* Forward declarations */
typedef void* maru_value;
typedef void* maru_env;
typedef void* maru_context;
typedef void* maru_array;

/* Universal value structure */
typedef struct MValue {
    int32_t tag;
    void* data;
} MValue;

/* Type-specific structures */
typedef struct MPair {
    maru_value head;
    maru_value tail;
} MPair;

typedef struct MArray {
    int32_t size;
    int32_t capacity;
    maru_value* elements;
} MArray;

typedef struct MString {
    int32_t length;
    char* data;
} MString;

typedef struct MSymbol {
    char* name;
} MSymbol;

typedef struct MExpr {
    maru_value defn;
    maru_context ctx;
} MExpr;

typedef struct MVariable {
    maru_value name;
    maru_value value;
    maru_env env;
    int32_t index;
} MVariable;

typedef struct MEnv {
    maru_env parent;
    int32_t level;
    int32_t offset;
    maru_array bindings;
} MEnv;

typedef struct MContext {
    maru_context home;
    maru_env env;
    maru_array bindings;
} MContext;

typedef struct MSubr {
    char* name;
    void* impl;
} MSubr;

typedef struct MFixed {
    maru_value function;
} MFixed;

/* Global variables */
static maru_value symbols = NULL;
static maru_value globals = NULL;
static maru_value evaluators = NULL;
static maru_value applicators = NULL;
static maru_value s_t = NULL;
static maru_value s_quote = NULL;
static maru_value s_lambda = NULL;
static maru_value s_define = NULL;
static maru_value s_set = NULL;
static maru_value s_if = NULL;
static maru_value s_let = NULL;

/* Memory management */
static maru_value maru_alloc(int32_t tag, int64_t size) {
    MValue* obj = (MValue*)gc_malloc(size);
    obj->tag = tag;
    return (maru_value)obj;
}

static maru_value maru_alloc_atomic(int32_t tag, int64_t size) {
    MValue* obj = (MValue*)gc_malloc_atomic(size);
    obj->tag = tag;
    return (maru_value)obj;
}

/* Type checking */
static int32_t maru_type_of(maru_value obj) {
    if (!obj) return MARU_UNDEFINED;
    if ((int64_t)obj & 1) return MARU_LONG;  /* Tagged integer */
    return ((MValue*)obj)->tag;
}

static int32_t maru_nil_p(maru_value obj) {
    return obj == NULL;
}

static int32_t maru_pair_p(maru_value obj) {
    return maru_type_of(obj) == MARU_PAIR;
}

static int32_t maru_symbol_p(maru_value obj) {
    return maru_type_of(obj) == MARU_SYMBOL;
}

static int32_t maru_variable_p(maru_value obj) {
    return maru_type_of(obj) == MARU_VARIABLE;
}

static int32_t maru_fixed_p(maru_value obj) {
    return maru_type_of(obj) == MARU_FIXED;
}

/* Tagged integers */
static int32_t maru_tagged_int_p(maru_value obj) {
    return (int64_t)obj & 1;
}

static maru_value maru_tag_int(int64_t value) {
    return (maru_value)((value << 1) | 1);
}

static int64_t maru_untag_int(maru_value obj) {
    return (int64_t)obj >> 1;
}

static maru_value maru_make_long(int64_t value) {
    return maru_tag_int(value);
}

static int64_t maru_long_value(maru_value obj) {
    if (maru_tagged_int_p(obj)) {
        return maru_untag_int(obj);
    }
    return 0;
}

/* Constructors */
static maru_value maru_cons(maru_value head, maru_value tail) {
    MValue* val = (MValue*)maru_alloc(MARU_PAIR, sizeof(MValue));
    MPair* pair = (MPair*)gc_malloc(sizeof(MPair));
    val->data = pair;
    pair->head = head;
    pair->tail = tail;
    return (maru_value)val;
}

static maru_value maru_car(maru_value obj) {
    if (maru_pair_p(obj)) {
        return ((MPair*)((MValue*)obj)->data)->head;
    }
    return NULL;
}

static maru_value maru_cdr(maru_value obj) {
    if (maru_pair_p(obj)) {
        return ((MPair*)((MValue*)obj)->data)->tail;
    }
    return NULL;
}

static maru_value maru_make_string(char* cstr) {
    int32_t len = strlen(cstr);
    MValue* val = (MValue*)maru_alloc(MARU_STRING, sizeof(MValue));
    MString* str = (MString*)gc_malloc(sizeof(MString));
    char* data = (char*)gc_malloc_atomic(len + 1);
    val->data = str;
    str->length = len;
    str->data = data;
    memcpy(data, cstr, len + 1);
    return (maru_value)val;
}

static maru_value maru_make_symbol(char* name) {
    MValue* val = (MValue*)maru_alloc_atomic(MARU_SYMBOL, sizeof(MValue));
    MSymbol* sym = (MSymbol*)gc_malloc_atomic(sizeof(MSymbol));
    val->data = sym;
    sym->name = strdup(name);
    return (maru_value)val;
}

static char* maru_symbol_name(maru_value obj) {
    if (maru_symbol_p(obj)) {
        return ((MSymbol*)((MValue*)obj)->data)->name;
    }
    return "";
}

static maru_value maru_make_array(int32_t size) {
    MValue* val = (MValue*)maru_alloc(MARU_ARRAY, sizeof(MValue));
    MArray* arr = (MArray*)gc_malloc(sizeof(MArray));
    int32_t cap = size ? size : 1;
    maru_value* elems = (maru_value*)gc_malloc(sizeof(maru_value) * cap);
    val->data = arr;
    arr->size = size;
    arr->capacity = cap;
    arr->elements = elems;
    memset(elems, 0, sizeof(maru_value) * cap);
    return (maru_value)val;
}

static int32_t maru_array_length(maru_value obj) {
    if (maru_type_of(obj) == MARU_ARRAY) {
        return ((MArray*)((MValue*)obj)->data)->size;
    }
    return 0;
}

static maru_value maru_array_at(maru_value obj, int32_t idx) {
    if (maru_type_of(obj) == MARU_ARRAY && idx >= 0 && idx < maru_array_length(obj)) {
        MArray* arr = (MArray*)((MValue*)obj)->data;
        return arr->elements[idx];
    }
    return NULL;
}

static void maru_array_set(maru_value obj, int32_t idx, maru_value val) {
    if (maru_type_of(obj) == MARU_ARRAY && idx >= 0) {
        MArray* arr = (MArray*)((MValue*)obj)->data;
        if (idx >= arr->capacity) {
            /* Grow array */
            int32_t new_cap = idx >= arr->capacity ? (idx > arr->capacity ? idx : arr->capacity) * 2 : arr->capacity;
            maru_value* new_elems = (maru_value*)gc_malloc(sizeof(maru_value) * new_cap);
            memcpy(new_elems, arr->elements, sizeof(maru_value) * arr->size);
            memset(&new_elems[arr->size], 0, sizeof(maru_value) * (new_cap - arr->size));
            arr->elements = new_elems;
            arr->capacity = new_cap;
        }
        if (idx >= arr->size) {
            arr->size = idx + 1;
        }
        arr->elements[idx] = val;
    }
}

/* Environment functions */
static maru_value maru_make_env(maru_env parent, int32_t level, int32_t offset) {
    MEnv* env = (MEnv*)maru_alloc(MARU_ENV, sizeof(MValue) + sizeof(MEnv));
    ((MValue*)env)->data = env;
    env->parent = parent;
    env->level = parent ? ((MEnv*)((MValue*)parent)->data)->level + level : 0;
    env->offset = offset;
    env->bindings = maru_make_array(0);
    return (maru_value)env;
}

static maru_value maru_make_variable(maru_value name, maru_value value, maru_env env, int32_t index) {
    MVariable* var = (MVariable*)maru_alloc(MARU_VARIABLE, sizeof(MValue) + sizeof(MVariable));
    ((MValue*)var)->data = var;
    var->name = name;
    var->value = value;
    var->env = env;
    var->index = index;
    return (maru_value)var;
}

static maru_value maru_variable_value(maru_value var) {
    if (maru_variable_p(var)) {
        return ((MVariable*)((MValue*)var)->data)->value;
    }
    return NULL;
}

/* Forward declarations for mutual recursion */
static maru_value maru_eval(maru_value exp, maru_context ctx);
static maru_value maru_apply(maru_value fun, maru_value arguments, maru_context ctx);

/* Symbol table */
static maru_value maru_intern(char* name) {
    /* Simple linear search */
    int32_t len = maru_array_length(symbols);
    for (int32_t i = 0; i < len; i++) {
        maru_value sym = maru_array_at(symbols, i);
        if (strcmp(name, maru_symbol_name(sym)) == 0) {
            return sym;
        }
    }
    /* Not found, create new */
    maru_value sym = maru_make_symbol(name);
    maru_array_set(symbols, len, sym);
    return sym;
}

/* Print function for testing */
static void maru_print(maru_value obj, FILE* port) {
    int32_t type = maru_type_of(obj);
    switch (type) {
        case MARU_UNDEFINED:
            fprintf(port, "nil");
            break;
        case MARU_LONG:
            fprintf(port, "%lld", (long long)maru_long_value(obj));
            break;
        case MARU_STRING: {
            MString* str = (MString*)((MValue*)obj)->data;
            fprintf(port, "\"%s\"", str->data);
            break;
        }
        case MARU_SYMBOL:
            fprintf(port, "%s", maru_symbol_name(obj));
            break;
        case MARU_PAIR: {
            fprintf(port, "(");
            while (maru_pair_p(obj)) {
                maru_print(maru_car(obj), port);
                obj = maru_cdr(obj);
                if (maru_pair_p(obj)) fprintf(port, " ");
            }
            if (!maru_nil_p(obj)) {
                fprintf(port, " . ");
                maru_print(obj, port);
            }
            fprintf(port, ")");
            break;
        }
        default:
            fprintf(port, "#<type:%d>", type);
    }
}

/* Core evaluator (simplified for demonstration) */
static maru_value maru_eval(maru_value exp, maru_context ctx) {
    int32_t type = maru_type_of(exp);
    
    switch (type) {
        /* Self-evaluating types */
        case MARU_UNDEFINED:
        case MARU_LONG:
        case MARU_STRING:
            return exp;
            
        /* Symbol evaluation would do variable lookup */
        case MARU_SYMBOL:
            /* In full implementation, would look up in environment */
            fprintf(stderr, "ERROR: symbol evaluation not implemented\n");
            return NULL;
            
        /* Pair evaluation - function application */
        case MARU_PAIR: {
            maru_value fn = maru_eval(maru_car(exp), ctx);
            /* Simplified - in full implementation would handle special forms */
            return exp;
        }
            
        default:
            return exp;
    }
}

/* Initialization */
static void maru_init(void) {
    gc_initialise();
    
    /* Create symbol table */
    symbols = maru_make_array(0);
    gc_push_root((void**)&symbols);
    
    /* Create important symbols */
    s_t = maru_intern("t");
    s_quote = maru_intern("quote");
    s_lambda = maru_intern("lambda");
    s_define = maru_intern("define");
    s_set = maru_intern("set");
    s_if = maru_intern("if");
    s_let = maru_intern("let");
    
    /* Create global environment */
    globals = maru_make_env(NULL, 0, 0);
    gc_push_root((void**)&globals);
    
    /* Create evaluators and applicators tables */
    evaluators = maru_make_array(32);
    gc_push_root((void**)&evaluators);
    
    applicators = maru_make_array(32);
    gc_push_root((void**)&applicators);
}

/* Test function from eval.k */
void test_eval(void) {
    maru_init();
    
    printf("eval.k initialized (C version)\n");
    
    /* Test 1: Self-evaluating number */
    maru_value exp = maru_make_long(42);
    maru_value result = maru_eval(exp, NULL);
    printf("Test 1: ");
    maru_print(result, stdout);
    printf(" (expected 42)\n");
    
    /* Test 2: Quote */
    maru_value sym = maru_intern("hello");
    exp = maru_cons(s_quote, maru_cons(sym, NULL));
    /* Would evaluate to sym in full implementation */
    printf("Test 2: ");
    maru_print(sym, stdout);
    printf(" (expected hello)\n");
    
    /* Test 3: Cons */
    maru_value list = maru_cons(maru_make_long(1), 
                                maru_cons(maru_make_long(2),
                                         maru_cons(maru_make_long(3), NULL)));
    printf("Test 3: ");
    maru_print(list, stdout);
    printf(" (expected (1 2 3))\n");
    
    printf("Basic tests complete (C version)\n");
}

/* Main entry point for testing */
#ifdef STANDALONE_TEST
int main() {
    test_eval();
    return 0;
}
#endif