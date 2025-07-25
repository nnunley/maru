# Understanding eval2.c Generation

## Overview

This document explains the specific process of generating eval2.c, the self-hosted C implementation of the Maru evaluator. It provides practical guidance for developers working on core language modifications.

## The Generation Process

### Prerequisites

Before generating eval2.c, ensure you have:
1. A working `eval` executable (built from eval.c)
2. The core language files: boot.l, emit.l, eval.l
3. A proper understanding of what you're modifying

### Basic Generation Command

```bash
./eval emit.l eval.l > eval2.c
```

Note: boot.l is implicitly loaded by eval during startup.

### What Happens During Generation

1. **eval starts up**: Loads its built-in primitives from eval.c
2. **boot.l is loaded**: Provides core language constructs
3. **emit.l is loaded**: Provides C code generation functions
4. **eval.l is processed**: Each form is compiled to C code
5. **C code is emitted**: Written to stdout (redirected to eval2.c)

## Understanding the Files

### eval.c - The Bootstrap

This is the hand-written C evaluator that includes:
```c
// Core data structures
typedef struct _oop *oop;

// Primitive operations
oop _cons(oop a, oop d) { ... }
oop _car(oop x) { ... }

// The evaluator loop
oop eval(oop expr, oop env) { ... }
```

### eval.l - The Metacircular Evaluator

This contains the same evaluator logic, but written in Lisp:
```lisp
(define (eval expr env)
  (cond
    ((symbol? expr) (lookup expr env))
    ((pair? expr)
     (case (car expr)
       ((quote) (cadr expr))
       ((if) (eval-if (cdr expr) env))
       ...))
    (else expr)))
```

### emit.l - The C Code Generator

This transforms Lisp expressions into C code:
```lisp
(define (emit-literal obj)
  (cond
    ((number? obj) (emit "makeNumber(%ld)" obj))
    ((string? obj) (emit-string obj))
    ((symbol? obj) (emit "intern(\"%s\")" (symbol->string obj)))
    ...))
```

### The Generated eval2.c

The output is a complete C program that includes:
- All primitives reimplemented in generated C
- The evaluator logic translated to C
- Proper initialization code
- Integration with gc.c and buffer.c

## Code Generation Details

### String Handling (Current State)

The current emit.l generates wide character strings:
```c
// Generated code uses:
wchar_t *str = L"Hello, world!";
swprintf(buffer, size, L"%ls", str);
```

### Symbol Interning

Symbols are interned during compilation:
```c
// Lisp: 'foo
// Generated: intern("foo")
```

### Number Representation

Numbers use tagged pointers:
```c
// Lisp: 42
// Generated: ((oop)((42 << 1) | 1))
```

### Function Calls

Function calls are translated to C:
```lisp
;; Lisp: (+ 1 2)
;; Generated: _plus(makeNumber(1), makeNumber(2))
```

## Making Language Changes

### Step 1: Understand the Layer

Determine which layer needs modification:
- **Syntax changes**: Modify the reader in eval.c/eval.l
- **Semantic changes**: Modify the evaluator in eval.l
- **Code generation**: Modify emit.l
- **Primitives**: Add to both eval.c and eval.l

### Step 2: Test Incrementally

1. Test your change with the interpreted evaluator:
```bash
./eval boot.l your-test.l
```

2. Test compilation of simple expressions:
```bash
echo '(your-new-feature ...)' | ./eval emit.l -
```

3. Regenerate eval2.c only when confident:
```bash
./eval emit.l eval.l > eval2.c.new
# Verify the generated code looks correct
diff eval2.c eval2.c.new
mv eval2.c.new eval2.c
```

### Step 3: Verify Metacircularity

```bash
# Build the new eval2
make eval2

# Test that it can regenerate itself
./eval2 emit.l eval.l > eval3.c
diff eval2.c eval3.c  # Should be identical
```

## Common Issues and Solutions

### Issue: Generated Code Doesn't Compile

**Symptoms**: C compiler errors when building eval2

**Common Causes**:
- Missing includes in generated code
- Type mismatches in emitted code
- Undefined functions

**Solution**: 
- Check emit.l for proper C code generation
- Ensure all primitives exist in both C and Lisp
- Verify header includes in emit.l

### Issue: Behavioral Differences

**Symptoms**: eval2 behaves differently from eval

**Common Causes**:
- Primitive implementations differ
- Evaluation order issues  
- Environment handling differences

**Solution**:
- Compare primitive implementations carefully
- Add debugging output to trace evaluation
- Use simple test cases to isolate issues

### Issue: Bootstrap Failures

**Symptoms**: Can't regenerate eval2.c

**Common Causes**:
- Circular dependencies in definitions
- Required features used before definition
- Memory corruption or GC issues

**Solution**:
- Ensure boot.l provides all prerequisites
- Check definition order in eval.l
- Run with GC debugging enabled

## The UTF-8 Migration

The current effort to migrate from wide characters to UTF-8 requires:

1. **Modifying emit.l** to generate UTF-8 string literals:
```lisp
;; Change from:
(emit "L\"%s\"" string)
;; To:
(emit "\"%s\"" string)
```

2. **Updating string functions** in eval.l:
```lisp
;; Use UTF-8 aware functions
(define (string-length str)
  (utf8-string-length str))  ; Count characters, not bytes
```

3. **Changing the C runtime**:
- Replace wcs.c with utf8.c
- Update Makefile dependencies
- Ensure consistent character handling

## Best Practices

1. **Always Keep eval2.c in Sync**: After changing eval.l or emit.l, regenerate eval2.c
2. **Test Both Evaluators**: Ensure eval and eval2 behave identically
3. **Document Changes**: Update comments in eval.l for significant changes
4. **Preserve Bootstrap Order**: Don't use features before they're defined
5. **Version Control**: Commit eval2.c along with its source changes

## Advanced Topics

### Debugging Code Generation

To debug emit.l, add tracing:
```lisp
(define *emit-trace* true)

(define (emit fmt . args)
  (when *emit-trace*
    (print "EMIT: " fmt " <- " args "\n"))
  (apply printf fmt args))
```

### Optimizing Generated Code

The generated code can be optimized by:
- Constant folding in emit.l
- Better register allocation
- Inlining small functions
- Type-specific operations

### Cross-Compilation

To generate code for a different platform:
1. Modify emit.l for target-specific code
2. Use appropriate type sizes
3. Handle endianness if necessary
4. Test on target platform

## Future Architecture: The IR-Based Generation

The codebase includes components for a next-generation architecture:

### boot2.l vs boot.l

**boot2.l** appears to be an enhanced bootstrap that includes:
- More sophisticated language features
- Better error handling
- Additional built-in forms
- Support for the IR system

### The IR System Pipeline

The future generation process would likely be:

```bash
# Current generation:
./eval emit.l eval.l > eval2.c

# Future IR-based generation:
./eval2 boot2.l ir.k ir-gen-c.k maru.k > eval3.c
```

### Why This Evolution?

1. **Cleaner Architecture**: IR provides better separation of concerns
2. **Multiple Backends**: Same IR can generate C, x86, ARM64, LLVM
3. **Better Optimization**: IR allows for cross-platform optimizations
4. **Type Safety**: The maru.k type system provides stronger guarantees
5. **Maintainability**: IR is easier to debug than direct code generation

### Transition Strategy

The presence of both systems suggests a gradual transition:
1. Maintain current eval2.c for stability
2. Develop IR-based system in parallel
3. Validate IR-generated code against current eval2
4. Eventually replace emit.l with IR-based generation

## Conclusion

The eval2.c generation process is the heart of Maru's metacircular implementation. Understanding this process is crucial for making core language changes. The key is to work incrementally, test thoroughly, and maintain the metacircular property at each step.

The codebase shows an evolution from direct code generation (emit.l) to a more sophisticated IR-based approach (ir.k, ir-gen-c.k). This represents the natural progression of a self-hosting language as it matures.

Remember: eval2.c is generated code. Never edit it directly. Always modify the source files (eval.l, emit.l) and regenerate.

---

*This document provides practical guidance for developers working with Maru's metacircular compiler, specifically focusing on eval2.c generation and its evolution toward an IR-based architecture.*