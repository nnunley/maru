# The Maru Metacircular Compiler

## What is a Metacircular Compiler?

A metacircular compiler is a self-hosting compiler that can compile its own source code. It's "meta" because it operates at a higher level of abstraction, and "circular" because it creates a closed loop where the compiler can regenerate itself.

## The Maru Bootstrap Process

### Stage 1: Initial Bootstrap in C

The journey begins with `eval.c`, a minimal Lisp evaluator written in C:

```
eval.c → (C compiler) → eval
```

This evaluator includes:
- Basic S-expression parsing
- Primitive operations (arithmetic, cons, car, cdr)
- Memory management (garbage collector)
- Wide character support for strings

### Stage 2: Loading the Core Language

The `eval` executable loads and evaluates Lisp code to build the language:

```
eval + boot.l → Basic Lisp environment
eval + boot.l + boot2.l → Extended Lisp with more features
```

Key files:
- **boot.l**: Core language forms (define, lambda, if, let)
- **boot2.l**: Extended features (cond, case, pattern matching)

### Stage 3: The Compiler

The compiler is implemented in Lisp itself:

```
eval + boot.l + emit.l → Lisp-to-C compiler
```

**emit.l** contains:
- Code generation functions
- C syntax emission
- Type handling
- Memory layout decisions

### Stage 4: Self-Compilation

This is where the magic happens. The evaluator compiles itself:

```
eval + boot.l + emit.l + eval.l → eval2.c
```

**eval.l** contains:
- The complete evaluator implementation in Lisp
- All the functionality of eval.c, but written in Lisp
- When processed by emit.l, it generates C code

### Stage 5: The Second Generation

```
eval2.c → (C compiler) → eval2
```

Now `eval2` is functionally identical to `eval`, but it was generated from Lisp source rather than hand-written in C.

## The Metacircular Property

To verify the metacircular property:

```bash
# eval2 should be able to regenerate itself
./eval2 emit.l eval.l > eval3.c
diff eval2.c eval3.c  # Should be identical
```

This proves that the compiler can compile itself, completing the metacircular loop.

## Code Generation Evolution

### Historical Context from Git Branches

The repository's historical branches (bootstrap, version-2.1, version-2.4) reveal the true evolution story:

### Original Maru: Assembly-First Design

The early versions compiled directly to x86 assembly:

```
boot-eval + boot.l + emit.l + eval.l → eval.s (assembly)
```

The Makefile from these versions shows:
```makefile
eval2 : eval .force
	./eval boot.l emit.l eval.l > eval2.s
	diff eval.s eval2.s  # Self-validation
```

This approach:
- Provided direct control over machine code
- Demonstrated complete self-hosting without C
- Used eval2 as a self-validation mechanism (not a different implementation)
- Was limited to x86 architecture

### Parallel Development Strategy (2009)

Rather than a "transition," the git history reveals that C code generation was added as a parallel option from early in the project (December 2009). The system evolved to support multiple backends through the IR system:

- **Direct generation**: emit.l → assembly
- **IR-based generation**: 
  - ir-gen-c.k → C code
  - ir-gen-x86.k → x86 assembly
  - ir-gen-arm64.k → ARM64 assembly
  - ir-gen-llir.k → LLVM IR

### Current Architecture

The current version uses emit.l to generate C code:

```
eval + boot.l + emit.l + eval.l → eval2.c (C code)
```

This decision prioritized:
- **Cross-platform portability**: Runs on any architecture with a C compiler
- **Maintainability**: C code is easier to debug and understand
- **Optimization**: Leverages decades of C compiler optimization work  
- **Integration**: Better interoperability with existing C libraries
- **Practicality**: Reduces platform-specific code maintenance

The shift to C generation represents a mature design choice, trading some theoretical purity for significant practical benefits. The system remains metacircular—it still compiles itself—but now targets a portable intermediate language (C) rather than platform-specific assembly.

## Understanding the Compilation Pipeline

### 1. Reading Phase
```lisp
;; S-expression: (+ 1 2)
;; Becomes: (cons '+ (cons 1 (cons 2 nil)))
```

### 2. Evaluation Phase
```lisp
;; Looks up '+' in environment
;; Finds primitive addition function
;; Applies to arguments 1 and 2
;; Returns 3
```

### 3. Compilation Phase
When compiling instead of evaluating:
```lisp
;; (+ 1 2) generates:
;; C code: (makeNumber(1 + 2))
;; Or optimized: (makeNumber(3))
```

### 4. Code Emission
The emit.l functions generate actual C syntax:
```c
oop makeNumber(long n) {
    return (oop)((n << 1) | 1);
}
```

## Key Concepts

### Object Representation

Maru uses tagged pointers:
- Odd pointers represent small integers
- Even pointers point to heap objects
- This allows efficient integer arithmetic

### Memory Management

The garbage collector (gc.c) is shared between:
- The bootstrap evaluator (eval)
- The generated evaluator (eval2)
- Any compiled Maru programs

### Type System

The compiler maintains type information:
- Primitive types (int, char, pointer)
- Compound types (cons cells, arrays)
- User-defined types (structures)

## Working with the Metacircular Compiler

### Modifying the Language

To add a new special form:

1. Add it to eval.l:
```lisp
(define-form when (condition . body)
  `(if ,condition (begin ,@body)))
```

2. Regenerate eval2.c:
```bash
./eval emit.l eval.l > eval2.c
```

3. Rebuild eval2:
```bash
make eval2
```

### Debugging the Compiler

To understand code generation:

```bash
# Generate C code for a simple expression
echo '(+ 1 2)' | ./eval emit.l -
```

To trace evaluation:
```bash
# Use debug flags in eval
./eval -v boot.l test.l
```

## Common Patterns

### Quasiquote in Compilation

The compiler heavily uses quasiquote for code generation:

```lisp
`(printf "%d\n" ,(compile-expr expr))
```

### Recursive Compilation

Most compilation is recursive:
```lisp
(define (compile-if expr)
  `(if ,(compile-expr (cadr expr))
       ,(compile-expr (caddr expr))
       ,(compile-expr (cadddr expr))))
```

### Environment Management

The compiler maintains compile-time environments:
```lisp
(define (compile-let bindings body env)
  (let ((new-env (extend-env bindings env)))
    (compile-body body new-env)))
```

## The Beauty of Metacircularity

The metacircular architecture provides:

1. **Expressiveness**: The language can extend itself
2. **Elegance**: Minimal core with maximum capability
3. **Understanding**: The compiler's implementation is in the language it compiles
4. **Evolution**: Easy to experiment with new features

## Further Reading

- Alan Kay's papers on STEPS and VPRI
- "The Art of the Interpreter" (Steele & Sussman)
- Structure and Interpretation of Computer Programs (SICP)
- The original Lisp papers by John McCarthy

## Exercises

1. **Trace the Bootstrap**: Follow a simple expression through compilation
2. **Add a Feature**: Implement a new special form in eval.l
3. **Optimize**: Add a simple optimization to emit.l
4. **Understand Types**: Trace how types are preserved through compilation

---

*This document explains the metacircular compilation process in Maru, one of the most elegant aspects of the language's design.*