# Maru Architecture Documentation

## Overview

Maru is a self-hosting Lisp-like programming language developed as part of the VPRI (Viewpoints Research Institute) STEPS project. The STEPS project, led by Alan Kay, aimed to create a complete personal computing system in under 20,000 lines of code. Maru served as the foundation language for this ambitious goal, combining functional programming with object-oriented features while demonstrating advanced language implementation techniques including bootstrapping, multiple compilation backends, and a sophisticated type system.

## Language Philosophy

Maru embodies several key design principles:

1. **Self-Hosting**: The language is implemented in itself, bootstrapping from a minimal C-based evaluator
2. **Dual Syntax**: Supports both S-expression (.l files) and structured syntax (.k files)
3. **Multiple Targets**: Compiles to C, x86, ARM64, and LLVM IR
4. **Hybrid OOP**: Combines prototype-based and class-based object systems
5. **System Programming**: Provides low-level access through FFI and direct memory manipulation

## Core Components

### 1. Bootstrap System

The bootstrap process begins with minimal primitives implemented in C:

```
eval.c → boot.l → core language → maru.k → full system
```

**Key Files:**
- `eval.c`: Minimal evaluator with primitive operations
- `boot.l`: Bootstrap definitions (forms, macros, basic functions)
- `maru.k`: Core language structures and type system

### 2. Language Variants

#### Lisp Syntax (.l files)
Traditional S-expression syntax used for:
- Bootstrap code
- Macro definitions  
- Dynamic/exploratory programming

Example:
```lisp
(define-form define-macro (name args . body)
  `(define-form ,name ,args ,@body))
```

#### Maru Syntax (.k files)
Structured syntax with type annotations used for:
- System programming
- Compiler implementation
- Performance-critical code

Example:
```
define-structure <ir-node> (type params source)

define-method ir-dump <ir-node> (node depth)
{
    indent depth;
    print "NODE " node.type "\n";
}
```

### 3. Compilation Pipeline

```
Source Code (.l/.k)
    ↓
Parser (PEG-based)
    ↓
AST
    ↓
IR Generation (ir.k)
    ↓
Backend Selection
    ├─→ C Code (ir-gen-c.k)
    ├─→ x86 Assembly (ir-gen-x86.k)
    ├─→ ARM64 Assembly (ir-gen-arm64.k)
    └─→ LLVM IR (ir-gen-llir.k)
```

#### Intermediate Representation (IR)

The IR system uses a graph-based representation:

- **Nodes**: Represent operations (arithmetic, control flow, memory access)
- **Edges**: Represent data flow between operations
- **Types**: Carry type information for optimization

Key IR structures:
- `<ir-node>`: Base node type
- `<ir-function>`: Function definition
- `<ir-module>`: Compilation unit

### 4. Type System

Maru features a sophisticated type system combining:

#### Primitive Types
- Integers: `int`, `long`, `short`, `char`
- Floating-point: `float`, `double`
- Pointers: `void*`, typed pointers
- Arrays: Fixed-size and dynamic

#### Composite Types
```
define-structure <point> (x y)
define-union <value> (int-val float-val ptr-val)
```

#### Object System
- **Structures**: Named fields with accessors
- **Methods**: Generic functions with multiple dispatch
- **Inheritance**: Prototype-based delegation
- **Metaclasses**: Types are first-class objects

### 5. Runtime System

#### Memory Management
- **Garbage Collector**: Mark-and-sweep algorithm (maru-gc.k)
- **Manual Memory**: Direct allocation for system programming
- **Reference Counting**: Optional for specific objects

#### Evaluator
The evaluator (eval.c/eval.l) implements:
- **Lexical Scoping**: Proper closure support
- **Tail Call Optimization**: Efficient recursion
- **Continuations**: First-class continuations for control flow
- **Dynamic Variables**: Thread-local storage

### 6. Extension Mechanisms

#### Foreign Function Interface (FFI)
```
define-alien-function malloc (size_t) -> void*
define-alien-variable errno int
```

#### C Integration
- Call C functions directly
- Access C structures
- Link with existing libraries

#### Library Bindings
- OpenGL (libgl.k, libglfw.k)
- Network protocols (net/*.k)
- System calls via FFI

## Architectural Patterns

### 1. Bootstrapping Strategy

The language bootstraps in stages:

1. **Stage 0**: C-based evaluator with minimal primitives
2. **Stage 1**: Basic Lisp forms and control structures
3. **Stage 2**: Object system and macros
4. **Stage 3**: Compiler and IR system
5. **Stage 4**: Full language with all features

### 2. Compiler Architecture

The compiler uses a multi-pass design:

1. **Parsing**: PEG-based parser generates AST
2. **Semantic Analysis**: Type checking and name resolution
3. **IR Generation**: Convert AST to intermediate representation
4. **Optimization**: IR-level optimizations
5. **Code Generation**: Backend-specific code emission

### 3. Object Model

Objects in Maru follow a unified model:

```
Object
  ├─ Header (type, size, GC info)
  ├─ Slots (instance variables)
  └─ Methods (vtable or method dictionary)
```

### 4. Evaluation Model

The evaluator supports multiple evaluation strategies:

- **Interpreted**: Direct AST evaluation
- **Compiled**: Via C or machine code
- **JIT**: Planned but not yet implemented

## Design Decisions

### Why Two Syntaxes?

1. **Lisp syntax (.l)**: Ideal for macros and metaprogramming
2. **Maru syntax (.k)**: Better for systems programming and readability

### Why Multiple Backends?

1. **C Backend**: Portability and debugging
2. **Native Backends**: Performance optimization
3. **LLVM Backend**: Advanced optimizations and future-proofing

### Why Self-Hosting?

1. **Dogfooding**: Language must be suitable for complex tasks
2. **Flexibility**: Easy to extend the language
3. **Elegance**: Demonstrates language expressiveness

## Extension Guide

### Adding a New Backend

1. Create `ir-gen-yourtarget.k`
2. Implement IR node visitors
3. Handle calling conventions
4. Integrate with build system

### Adding Language Features

1. Extend parser grammar (grammar.g)
2. Add AST node types
3. Implement evaluation rules
4. Update compiler passes

### Contributing

The codebase follows these conventions:

- **Naming**: Lisp-style with hyphens
- **Files**: .l for dynamic code, .k for static
- **Testing**: See test-*.l files
- **Documentation**: Inline comments and doc/

## Performance Considerations

### Optimization Strategies

1. **Type Inference**: Reduce dynamic dispatch
2. **Inline Caching**: Speed up method calls
3. **Escape Analysis**: Stack-allocate when possible
4. **Constant Folding**: Compile-time evaluation

### Benchmarking

Performance tests in:
- `benchmark.l`: Language benchmarks
- `test-performance.l`: Specific optimizations

## Future Directions

### Planned Features

1. **JIT Compilation**: Dynamic optimization
2. **Concurrent GC**: Better multicore support
3. **Module System**: Namespace management
4. **Package Manager**: Dependency management

### Research Areas

1. **Gradual Typing**: Optional static types
2. **Effect System**: Track side effects
3. **Partial Evaluation**: Compile-time optimization
4. **Live Programming**: Hot code reloading

## Historical Context: VPRI STEPS Project

Maru was developed as a foundational component of the VPRI STEPS (Steps Toward Expressive Programming Systems) project. STEPS aimed to demonstrate that a complete personal computing system could be built in under 20,000 lines of code by using:

1. **Domain-Specific Languages**: Each system component uses the most appropriate language
2. **Aggressive Abstraction**: Maximum code reuse and expressiveness
3. **Self-Description**: Systems that can explain and modify themselves
4. **Mathematical Foundations**: Sound theoretical basis for all components

Within STEPS, Maru served as:
- **The Bootstrap Language**: Foundation for building other languages
- **The Systems Language**: Low-level implementation of critical components  
- **The Meta-Language**: Tool for creating domain-specific languages

### STEPS Architecture Layers

1. **Maru**: Self-describing foundation language (this project)
2. **OMeta**: Parsing and pattern matching language
3. **Nile**: Graphics and image processing language
4. **Gezira**: Graphics renderer built with Nile
5. **Frank**: Document and UI description language

## References

- **STEPS Reports**: VPRI technical reports (2007-2012)
- **FONC Project**: Fundamentals of New Computing initiative
- **Alan Kay's Vision**: "The best way to predict the future is to invent it"
- **Related Work**: Squeak Smalltalk, Self, COLA (Combined Object Lambda Architecture)
- **Modern Successors**: Projects inspired by STEPS/Maru approach

## Conclusion

Maru represents a sophisticated approach to language design, combining the expressiveness of Lisp with the performance needs of systems programming. Its self-hosting nature and multiple compilation targets make it an excellent platform for language research and practical programming.