# Maru Metacircular Compiler - Detailed Technical Documentation

## Overview

This document provides a deep technical understanding of Maru's metacircular compiler loop, focusing on the bootstrap process, compilation stages, and the relationships between key files. This supplements the general architecture documentation with specific implementation details relevant to the current development work.

## The Metacircular Compiler Loop

### What is a Metacircular Compiler?

A metacircular compiler is a self-hosting compiler written in the language it compiles. Maru achieves this through a carefully orchestrated bootstrap process that progressively builds more sophisticated versions of itself.

### Bootstrap Stages

The Maru bootstrap process consists of multiple stages:

#### Stage 0: Initial C Bootstrap (eval.c)
```
eval.c (C code) → eval (executable)
```
- Written in C, includes minimal Lisp evaluator
- Implements core primitives: cons, car, cdr, arithmetic, I/O
- Includes garbage collector (gc.c) and buffer management
- Uses wide characters (wchar_t) for string handling via wcs.c
- Can read and evaluate S-expressions

#### Stage 1: Core Language Bootstrap (boot.l)
```
eval + boot.l → Core language features
```
- Defines fundamental forms: define, lambda, if, quote
- Implements basic macros and control structures
- Establishes the object system foundation
- Creates the environment for further compilation

#### Stage 2: Extended Bootstrap (boot2.l)
```
eval + boot.l + boot2.l → Extended language
```
- Adds more sophisticated language features
- Implements pattern matching (cond, case)
- Extends the macro system
- Provides additional data structures

#### Stage 3: Compiler Implementation (emit.l)
```
eval + boot.l + emit.l → Machine code generator
```
- Implements code generation for various targets
- Originally focused on x86 assembly generation
- Transforms S-expressions to assembly code
- Handles calling conventions and register allocation

#### Stage 4: Self-Compilation (eval.l)
```
eval + boot.l + emit.l + eval.l → eval2.c
```
- eval.l contains the metacircular evaluator
- When processed through emit.l, generates C code
- The output is eval2.c - a C implementation of the evaluator
- This completes the metacircular loop

#### Stage 5: Second Generation (eval2)
```
eval2.c (generated C) → eval2 (executable)
```
- Compiled with standard C compiler
- Functionally equivalent to eval but generated from Lisp
- Can now regenerate itself without the original eval.c
- Uses the same runtime support (gc.c, buffer.c, wcs.c)

### File Relationships and Dependencies

```
┌─────────────┐
│   eval.c    │ (Hand-written C bootstrap)
└──────┬──────┘
       │ compiles to
       ▼
┌─────────────┐
│    eval     │ (Bootstrap executable)
└──────┬──────┘
       │ loads & executes
       ▼
┌─────────────────────────────────┐
│  boot.l + emit.l + eval.l       │
└─────────────┬───────────────────┘
              │ generates
              ▼
       ┌─────────────┐
       │   eval2.c   │ (Generated C code)
       └──────┬──────┘
              │ compiles to
              ▼
       ┌─────────────┐
       │    eval2    │ (Self-hosted executable)
       └─────────────┘
```

### Key Implementation Details

#### Character Encoding (Current State)
- Uses wide characters (wchar_t) throughout
- String literals use L"..." notation
- Character manipulation via wcs.c functions
- TODO: Transitioning to UTF-8 representation

#### Memory Management
- Custom garbage collector (gc.c)
- Mark-and-sweep algorithm
- Integrated with both eval and eval2
- Handles both atomic and non-atomic allocations

#### Code Generation Pipeline
1. **Parsing**: S-expressions → AST
2. **Compilation**: AST → Assembly/C code
3. **Emission**: Formatted output with proper syntax
4. **Integration**: Links with runtime support

### Evolution from Assembly to C Generation

Looking at the historical branches (bootstrap, version-2.1, version-2.4) reveals the architectural evolution:

#### Early Architecture: Direct Assembly Generation
```makefile
# Original approach - generated assembly:
eval: boot-eval boot.l emit.l eval.l
	./boot-eval boot.l emit.l eval.l > eval.s
	gcc -m32 -c -o eval.o eval.s

# Self-validation through reassembly:
eval2 : eval .force
	./eval boot.l emit.l eval.l > eval2.s
	diff eval.s eval2.s  # Verify identical output
```

#### Parallel Development Strategy

The git history (December 2009) shows C code generation was added early as a parallel option, not a replacement:
- **emit.l**: Originally generated x86 assembly directly
- **IR system**: Added to support multiple backends
  - ir-gen-c.k → C code generation
  - ir-gen-x86.k → x86 assembly
  - ir-gen-arm64.k → ARM64 assembly  
  - ir-gen-llir.k → LLVM IR

The current version has emit.l generating C code (eval2.c) for portability, while maintaining assembly generation through the IR system. However, the current Makefile is missing the explicit rule to regenerate eval2.c:

```makefile
# Missing rule (should be added):
eval2.c : emit.l eval.l eval
	./eval emit.l eval.l > eval2.c

# Existing rule:
eval2 : eval2.c gc.c gc.h buffer.c chartab.h wcs.c osdefs.k
	$(CC) -g $(CFLAGS) -o eval2 eval2.c $(LIBS)
```

This evolution from assembly to C generation represents a shift toward:
- **Better Portability**: C code compiles on any platform
- **Easier Debugging**: C code is more readable than assembly
- **Compiler Optimizations**: Leverages C compiler optimizations
- **Simpler Maintenance**: C code is easier to understand and modify

### Why eval2.c is Checked In

eval2.c is pre-generated and checked into version control because:
1. **Bootstrap Independence**: Can build Maru without a working Maru
2. **Stability**: Provides a known-good reference implementation
3. **Portability**: Avoids chicken-and-egg problem on new platforms
4. **Debugging**: Easier to debug C code than generated assembly

### Modern Evolution: IR-Based Compilation

While the original Maru used direct assembly generation, the modern version includes:

#### IR (Intermediate Representation) System
- Platform-independent code representation
- Multiple backend targets:
  - ir-gen-c.k → C code generation
  - ir-gen-x86.k → x86 assembly
  - ir-gen-arm64.k → ARM64 assembly
  - ir-gen-llir.k → LLVM IR

#### Maru Syntax (.k files)
- Structured syntax alternative to S-expressions
- Type annotations and better readability
- Compiles through the same IR system

### Next Generation Architecture (In Progress)

The codebase suggests a transition to a more sophisticated architecture:

#### Current Generation (eval2.c)
```
eval + boot.l + emit.l + eval.l → eval2.c
```
- Direct C code generation
- Based on original S-expression evaluator

#### Next Generation (Future eval2)
```
eval2 + boot2.l + ir.k + ir-gen-c.k + maru.k → new eval2.c
```
- Uses boot2.l for enhanced bootstrap features
- Leverages IR system for cleaner code generation
- Supports multiple backends through ir-gen-*.k
- Better type system via maru.k

This represents an architectural evolution:
1. **First Generation**: Hand-written C (eval.c)
2. **Second Generation**: Generated C from S-expressions (current eval2.c)
3. **Third Generation**: Generated via IR system (future eval2)

### UTF-8 Migration Strategy

The current effort to migrate from wide characters to UTF-8 involves:

1. **Create UTF-8 Support Libraries**:
   - utf8.c - C implementation with maru_ prefix
   - utf8.k - IR-based implementation
   - maru-utf8.k - Pure Maru implementation

2. **Modify Code Generation**:
   - Update emit.l to generate UTF-8 string literals
   - Change string handling from wcs.c to utf8.c
   - Ensure proper character counting vs byte counting

3. **Regenerate eval2.c**:
   - Use the modified emit.l to regenerate eval2.c
   - This will produce a UTF-8-aware evaluator
   - Maintains the metacircular property

### Understanding the Compilation Flow

For any modification to the core language:

1. **Modify Source Files**:
   - Change language semantics: modify eval.l
   - Change code generation: modify emit.l
   - Change bootstrap features: modify boot.l or boot2.l

2. **Regenerate eval2.c**:
   ```bash
   ./eval emit.l eval.l > eval2.c
   ```

3. **Rebuild eval2**:
   ```bash
   make eval2
   ```

4. **Test Metacircularity**:
   ```bash
   ./eval2 emit.l eval.l > eval2-test.c
   diff eval2.c eval2-test.c  # Should be identical
   ```

### Common Pitfalls and Solutions

1. **Never Modify eval2.c Directly**:
   - It's generated code
   - Changes will be lost on regeneration
   - Modify eval.l or emit.l instead

2. **Bootstrap Order Matters**:
   - boot.l must be loaded before boot2.l
   - emit.l must be loaded before eval.l for compilation
   - Order affects available features

3. **Type System Considerations**:
   - The IR system expects certain type definitions
   - UTF-8 changes must preserve type compatibility
   - Character vs byte distinctions are critical

### Development Workflow

When working on core language features:

1. **Test in Interpreted Mode First**:
   ```bash
   ./eval boot.l boot2.l test-file.l
   ```

2. **Generate and Test Compiled Version**:
   ```bash
   ./eval emit.l test-file.l > test-file.c
   cc -o test-file test-file.c gc.c buffer.c
   ```

3. **Update eval2.c When Stable**:
   ```bash
   ./eval emit.l eval.l > eval2.c.new
   mv eval2.c.new eval2.c
   git add eval2.c
   git commit -m "Regenerated eval2.c with new features"
   ```

### Future Directions

The metacircular architecture enables:
- **Self-Optimization**: Compiler can optimize itself
- **Language Evolution**: Easy to add new features
- **Platform Independence**: Multiple backend targets
- **Research Flexibility**: Experiment with new compilation strategies

### References for Deep Understanding

- Original Maru papers from VPRI
- STEPS project reports (2007-2012)
- Source code comments in eval.l and emit.l
- The IR system documentation (ir.html)

---

*This document is specifically created for the Claude Code AI assistant to understand the metacircular compilation process in detail. It complements the general ARCHITECTURE.md with implementation-specific details needed for current development work.*