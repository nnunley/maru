# Understanding .k vs .l Files in Maru

## Overview

The Maru project uses two distinct file extensions that represent different approaches to programming within the same metacircular system:

- **`.l` files**: Dynamic, untyped Lisp syntax (traditional Maru)
- **`.k` files**: Typed, structured syntax with IR compilation support

## Key Differences

### 1. Type System

**`.l` files** (Lisp-style):
- Dynamic typing
- No type declarations required
- Runtime type checking
- Maximum flexibility

**`.k` files** (Typed Maru):
- Static type declarations
- Compile-time type checking
- Type inference where possible
- Better optimization opportunities

### 2. Compilation Path

**`.l` files**:
```
.l file → eval/eval2 → interpreted execution
        ↘
          emit.l → assembly/C code generation
```

**`.k` files**:
```
.k file → maru.k compiler → IR system → multiple backends
                                        ├── ir-gen-c.k → C
                                        ├── ir-gen-x86.k → x86 asm
                                        └── ir-gen-arm64.k → ARM64 asm
```

### 3. Syntax Examples

**`.l` file** (traditional S-expressions):
```lisp
(define-function add (a b)
  (+ a b))

(define result (add 5 3))
```

**`.k` file** (typed Maru):
```lisp
(define-function add (int a) (int b) -> int
  (+ a b))

(define result int (add 5 3))
```

## The IR System Bridge

The `maru.k` file serves as a crucial bridge between these two worlds:

### Type Mapping
```lisp
(define maru->ir-type-map
  `((void    . ,IR-VOID)
    (char    . ,IR-INT8)
    (int     . ,IR-INT32)
    (long    . ,IR-LONG)
    (float   . ,IR-FLOAT)
    (double  . ,IR-DOUBLE)
    ...))
```

### Compilation Methods
The file defines `maru-compile` methods that transform Maru expressions into IR instructions:
- Literals → IR literals
- Variables → IR variable references
- Control flow → IR control structures
- Function calls → IR function calls

## File Organization in Maru

### Core System Files (.l)
- `boot.l` - Core language bootstrap
- `emit.l` - Code generator
- `eval.l` - Metacircular evaluator
- `repl.l` - Read-eval-print loop

### IR System Files (.k)
- `ir.k` - IR instruction definitions
- `ir2.k` - Extended IR functionality
- `maru.k` - Maru→IR compiler

### Backend Files (.k)
- `ir-gen-c.k` - C code generator
- `ir-gen-x86.k` - x86 assembly generator
- `ir-gen-arm64.k` - ARM64 assembly generator

### Architecture Support (.k)
- `asm-x86.k` - x86 assembly helpers
- `asm-arm64.k` - ARM64 assembly helpers

## Use Cases

### When to Use .l Files
- Rapid prototyping
- Dynamic metaprogramming
- Language experimentation
- Bootstrap and core system code
- When maximum flexibility is needed

### When to Use .k Files
- Performance-critical code
- C library integration
- Multi-platform deployment
- When type safety is important
- System programming tasks

## Integration Example

A typical mixed project might:

1. Use `.l` files for high-level logic and DSLs
2. Use `.k` files for performance-critical kernels
3. Compile `.k` files through IR to native code
4. Load and call compiled functions from `.l` code

```lisp
;; In main.l
(load "fast-math.k")  ; Compiles through IR
(define result (fast-fibonacci 40))  ; Calls compiled function
```

## Evolution Path

The existence of both file types suggests an evolution strategy:

1. **Phase 1**: Traditional Maru (.l files) with metacircular evaluation
2. **Phase 2**: Introduction of typed Maru (.k files) for performance
3. **Phase 3**: IR system enables multiple backend targets
4. **Future**: Possible unification where .l files can optionally use types

## Benefits of the Dual System

1. **Backward Compatibility**: Existing .l code continues to work
2. **Gradual Migration**: Can move performance-critical code to .k incrementally
3. **Best of Both Worlds**: Dynamic flexibility + static performance
4. **Multiple Targets**: One .k source can target x86, ARM64, C, etc.
5. **Interoperability**: Easy mixing of typed and untyped code

## Conclusion

The .k/.l distinction in Maru represents a sophisticated approach to language evolution. Rather than forcing a choice between dynamic and static typing, Maru provides both, allowing developers to choose the right tool for each part of their system. The IR system acts as a unifying compilation target that enables this flexibility while maintaining the metacircular properties that make Maru unique.