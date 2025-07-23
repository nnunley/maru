# Bootstrap Plan for eval.k - Typed IR-Based Evaluator

## Overview

This document outlines the technical approach for creating `eval.k`, a typed implementation of the Maru evaluator that compiles through the IR system to multiple backends (C, x86, ARM64).

## Key Challenges

### 1. Dynamic vs Static Type Mismatch

The core challenge is bridging Maru's dynamic type system with IR's static type system:

**Maru's Dynamic Types** (from eval.l):
- `<undefined>` (0) - nil value
- `<long>` (2) - tagged integers or boxed longs
- `<double>` (3) - floating point
- `<string>` (4) - character strings  
- `<symbol>` (5) - interned symbols
- `<pair>` (6) - cons cells
- `<array>` (8) - dynamic arrays
- `<expr>` (9) - lambda expressions
- `<form>` (10) - special forms
- `<fixed>` (11) - fixed applicators
- `<subr>` (12) - built-in functions
- `<variable>` (13) - variable references
- `<env>` (14) - environments
- `<context>` (15) - evaluation contexts

**IR's Static Types**:
- Primitive types: `IR-VOID`, `IR-INT8`, `IR-INT32`, `IR-INT64`, `IR-FLOAT32`, `IR-FLOAT64`
- Pointer types: `IR-STRING` (char*), custom pointer types
- No built-in support for dynamic typing

### 2. Tagged Value Representation

The solution is to create a **universal value type** in IR that can represent any Maru value:

```c
// Conceptual C representation
typedef struct {
    int32_t type;    // Type tag (0-15)
    union {
        int64_t    as_long;
        double     as_double;
        void*      as_pointer;
        struct {
            void* head;
            void* tail;
        } as_pair;
    } data;
} MValue;
```

In IR, this would be:
```lisp
(define-struct MValue (
  (type int32)
  (data union (
    (as_long int64)
    (as_double double)
    (as_pointer void*)
    (as_pair struct ((head void*) (tail void*)))
  ))
))
```

### 3. Core Evaluator Functions

The evaluator needs these key functions reimplemented in typed Maru:

#### Type Checking and Conversion
```lisp
(define-function get-type ((obj MValue*)) -> int32
  (if (& obj.data.as_long 1)  ; tagged integer check
      <long>
    obj.type))

(define-function make-long ((value int64)) -> MValue*
  (let ((obj MValue* (gc-malloc (sizeof MValue))))
    (set obj.type <long>)
    (set obj.data.as_long value)
    obj))
```

#### Core Eval Function
```lisp
(define-function k-eval ((exp MValue*) (ctx MValue*)) -> MValue*
  (let ((type int32 (get-type exp)))
    (cond
      ((= type <undefined>) exp)
      ((= type <long>) exp)
      ((= type <string>) exp)
      ((= type <variable>) (eval-variable exp ctx))
      ((= type <pair>) (eval-pair exp ctx))
      ((= type <symbol>) (error "symbol in eval?"))
      (else (eval-custom-type exp ctx)))))
```

### 4. Memory Management Integration

The garbage collector needs to work with the IR system:

```lisp
(define-function gc-malloc ((size int64)) -> void*
  (extern gc_malloc))  ; Link to existing C GC

(define-function gc-protect ((vars MValue**) (count int32)) -> void
  ; Implement root protection for IR-generated code
  )
```

### 5. Bootstrap Stages

#### Stage 1: Core Infrastructure
1. Define `MValue` type in IR
2. Implement type checking functions
3. Create constructors for each type
4. Port garbage collector interface

#### Stage 2: Data Structure Support
1. Implement pair operations (car, cdr, cons)
2. Array operations
3. String handling
4. Symbol table management

#### Stage 3: Environment and Binding
1. Port environment creation
2. Variable lookup (local and global)
3. Binding management
4. Context switching

#### Stage 4: Core Evaluator
1. Implement `k-eval` main function
2. Special form handlers (define, lambda, let, if, etc.)
3. Function application
4. Primitive operations

#### Stage 5: Reader and Printer
1. S-expression reader
2. Pretty printer
3. REPL infrastructure

#### Stage 6: Bootstrap Test
1. Load boot.l using eval.k
2. Self-evaluate simple expressions
3. Full metacircular test

## Implementation Strategy

### Phase 1: Minimal Evaluator
Create a minimal eval.k that can:
- Evaluate numbers and strings
- Handle basic arithmetic
- Support define and simple functions

### Phase 2: Full Language Support
- Add all special forms
- Implement apply and eval
- Support macros and quasiquote

### Phase 3: Self-Hosting
- Use eval.k to load boot.l
- Compile eval.k itself through IR
- Generate C, x86, and ARM64 versions

## Technical Decisions

### 1. Type Representation
- Use tagged pointers for immediate values (integers)
- Box everything else with type tags
- Maintain compatibility with existing eval.c memory layout

### 2. Calling Convention
- Match C calling convention for interop
- Support variable argument lists for Lisp functions
- Handle tail call optimization where possible

### 3. Error Handling
- Use setjmp/longjmp for non-local exits
- Maintain error context for debugging
- Compatible error messages with eval.c

## Benefits of eval.k

1. **Multi-Backend Support**: One implementation, multiple targets
2. **Type Safety**: Catch errors at compile time where possible
3. **Performance**: Static typing enables optimizations
4. **Debugging**: Better error messages and stack traces
5. **Modernization**: Clean separation of concerns

## Migration Path

1. Start with eval.k alongside eval.l
2. Test equivalence on test suite
3. Benchmark performance
4. Gradually migrate features
5. Eventually replace eval2.c generation

## Estimated Effort

- Core infrastructure: 2-3 weeks
- Full evaluator: 4-6 weeks  
- Testing and debugging: 2-3 weeks
- Performance optimization: 2-3 weeks

Total: 10-15 weeks for production-ready implementation

## Conclusion

Creating eval.k is technically feasible and offers significant advantages. The key is careful design of the dynamic type system within IR's static framework. This would modernize Maru's implementation while maintaining its metacircular elegance.