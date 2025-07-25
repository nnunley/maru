# Maru: A Metacircular Language Workbench

*"The best way to predict the future is to invent it" — Alan Kay*

Maru is a sophisticated self-hosting Lisp compiler and language workbench developed by Ian Piumarta at VPRI as part of Alan Kay's STEPS project. Beyond being a metacircular compiler, Maru serves as a powerful platform for building domain-specific languages, demonstrating how complex language implementations can emerge from simple, elegant foundations.

## What Makes Maru Special?

### 🔄 **Metacircular Architecture**
Maru compiles itself. The entire compiler is written in the language it compiles, creating an elegant bootstrap process where the language can extend and modify itself.

### 🎯 **Multiple Compilation Targets**  
One source language, multiple targets:
- **C code** (primary, portable)
- **x86 assembly** (direct machine code)
- **ARM64 assembly** (Apple Silicon support)  
- **LLVM IR** (advanced optimizations)

### 📝 **Dual Syntax System**
- **`.l files`**: Traditional S-expression Lisp syntax for dynamic programming, macros, and exploration
- **`.k files`**: Typed (but still dynamic) structured syntax with IR compilation support for performance

### 🛠️ **Language Workbench Capabilities**
Maru includes sophisticated tools for building new languages:
- **PEG Parser Generator**: Build parsers for any syntax (including Unicode)
- **Multi-Method System**: Extensible compiler passes
- **Port Streams**: Clean I/O abstraction for code generation
- **Example: Nile**: A complete stream processing language built on Maru

### 🧠 **Educational Excellence**
At ~1,750 lines for the complete compiler, Maru is small enough to understand completely yet sophisticated enough for real development. Perfect for learning language implementation.

### 🏗️ **VPRI STEPS Heritage**
Part of Alan Kay's ambitious project to create a complete personal computing system in under 20,000 lines of code, demonstrating the power of principled minimalism.

## Quick Start

### Prerequisites
- Unix-like system (Linux, macOS, Windows with WSL)
- C compiler (GCC or Clang)
- `make` build system
- Optional: `rlwrap` for enhanced REPL experience

### Build Maru

```bash
# Clone or extract the Maru source
cd maru

# Build the complete system
make clean && make

# This creates:
# ./eval    - Initial C-based bootstrapper  
# ./eval2   - Self-compiled version (generated from eval.l)
# ./evalm   - Multi-method evaluator
```

### Your First Maru Program

Start the interactive REPL:
```bash
# Enhanced REPL (if rlwrap is available)
make run

# Or basic REPL
./eval
```

Try some basic Lisp:
```lisp
;; Arithmetic
(+ 1 2 3)
;;=> 6

;; Define a function
(define-function factorial (n)
  (if (< n 2) 
      1 
      (* n (factorial (- n 1)))))

(factorial 5)
;;=> 120

;; List processing
(map (lambda (x) (* x x)) '(1 2 3 4 5))
;;=> (1 4 9 16 25)
```

### Compile Your First Program

Create a file `hello.l`:
```lisp
(println "Hello, Maru!")
(println "2 + 2 = " (+ 2 2))
```

Run it:
```bash
./eval hello.l
```

### Understanding the Bootstrap Process

Maru's self-hosting bootstrap is its most elegant feature:

```
1. eval.c        →  (C compiler)    →  eval         (handwritten C evaluator)
2. eval + boot.l →  (interpreter)   →  Lisp environment
3. eval + emit.l →  (interpreter)   →  Lisp-to-C compiler  
4. eval + eval.l →  (compilation)   →  eval2.c      (generated C)
5. eval2.c       →  (C compiler)    →  eval2        (self-compiled evaluator)
```

The magic: `eval2` is functionally identical to `eval`, but was generated from Lisp source code!

Verify the metacircular property:
```bash
# eval2 can compile itself
./eval2 core/compiler/emit.l core/eval.l > eval3.c

# Compare - they should be identical  
diff eval2.c eval3.c
```

## Exploring the Language

### Important: .k vs .l Files
- **`.l` files**: Traditional untyped Lisp syntax
- **`.k` files**: Typed Lisp syntax with IR compilation support
- Both can be evaluated directly: `./eval file.l` or `./eval file.k`
- For high-performance compilation, .k files are processed through the IR system

### Core Files Structure
```
maru/
├── Makefile              # Build system
├── eval.c, eval          # Bootstrap C evaluator  
├── boot.l, boot2.l       # Language bootstrap definitions
├── eval.l                # Self-hosting evaluator (the heart of Maru)
├── eval2.c, eval2        # Generated self-compiled version
├── core/                 # Stable compiler infrastructure
│   ├── bootstrap/        # Bootstrap system
│   ├── compiler/         # Code generation backends
│   ├── eval.l            # Main evaluator source
│   └── peg*.l           # Parser generator
├── lib/                  # Standard library
│   ├── repl.l           # REPL implementation
│   ├── stream/          # I/O system
│   └── *.k              # Typed library modules
├── arch/                 # Architecture-specific code
├── grammars/            # PEG parser grammars
├── compilers/           # Example language implementations
│   └── nile/            # Stream processing language
├── runtimes/            # Runtime libraries
│   └── nile/            # Nile runtime (C + FFI)
└── doc/                 # Documentation
```

### Language Features

**Traditional Lisp Features (.l files):**
```lisp
;; Macros and metaprogramming
(define-form when (condition . body)
  `(if ,condition (begin ,@body)))

;; First-class functions
(define compose 
  (lambda (f g) 
    (lambda (x) (f (g x)))))

;; Object system with methods
(define-method print Point (p)
  (print "(" p.x ", " p.y ")"))
```

**Typed Maru Features (.k files):**
```lisp
;; Type annotations for performance
(define-function add (int a) (int b) -> int
  (+ a b))

;; Structure definitions
(define-structure <point> (int x) (int y))

;; C integration
(define-alien-function malloc (long size) -> void*)
```

### Available Examples

```bash
# Run the built-in examples
./README.examples

# Interactive REPL with libraries
./eval lib/repl.l

# Test the multi-method evaluator
./evalm
```

## Development and Testing

### Run Tests
```bash
# Basic functionality tests
make test

# Maru-language (.k) tests  
make test-maru

# Cross-platform testing
MARU_TARGET_ARCH=arm64 make test
```

### Performance Benchmarking
```bash
# Compare C vs compiled Maru performance
make maru-bench
```

### Debugging
```bash
# Debug build
make debug

# Verbose execution
./eval -v boot.l your-program.l

# Trace compilation
echo '(+ 1 2)' | ./eval core/compiler/emit.l -
```

## Learning Path

### 1. **Start with the REPL**
Get comfortable with Lisp syntax and basic operations.

### 2. **Study the Bootstrap**  
Read `boot.l` and `boot2.l` to understand how the language is built up from primitives.

### 3. **Explore Code Generation**
Look at `core/compiler/emit.l` to see how Lisp compiles to C.

### 4. **Understand Self-Hosting**
Examine `core/eval.l` - this is the evaluator written in itself.

### 5. **Experiment with Extensions**
Try adding new language features or compilation targets.

## Advanced Usage

### Building Domain-Specific Languages

Maru excels as a language workbench. See the Nile language for a complete example:

```bash
# Explore the Nile stream processing language
cd compilers/nile
cat README.md

# Example: Compile a Nile program to C
./nile-to-c-compiler.sh MyModule examples/transform.nl > transform.c

# Build with the Nile runtime
gcc -o transform transform.c \
    ../../runtimes/nile/nile.c \
    ../../runtimes/nile/nile-process.c \
    ../../runtimes/nile/nile-builtins.c \
    -I ../../runtimes/nile/ -lm -pthread
```

Key features for language building:
- **PEG Parser Generator**: Define grammars in `grammars/`
- **Multi-Method Dispatch**: Extensible compiler passes
- **Code Generation**: Clean separation of AST and output
- **FFI Support**: Interface with C libraries

### Cross-Platform Compilation
```bash
# Target ARM64 (Apple Silicon)
MARU_TARGET_ARCH=arm64 make

# Target x86-64  
MARU_TARGET_ARCH=x86_64 make
```

### Working with .k Files (Typed Maru)
```bash
# .k files can be run directly (interpreted mode)
./eval your-program.k

# OR compiled through IR for high performance
./eval2 core/compiler/ir-gen-c.k core/maru.k your-program.k > output.c
cc -fno-builtin -g -o your-program output.c -ldl
./your-program

# Compile to native assembly
./eval2 core/compiler/ir-gen-x86.k core/maru.k your-program.k > output.s
./eval2 core/compiler/ir-gen-arm64.k core/maru.k your-program.k > output.s
```

### Library Development
```bash
# Available libraries in lib/
ls lib/*.k lib/*.l

# Key libraries:
# lib/repl.l         - Interactive REPL
# lib/stream/        - I/O and port system  
# lib/maru-gc.k      - Garbage collection
# lib/maru-test.k    - Testing framework
```

## Recent Developments

### 🚀 Active Features (2024)

1. **Port Streams System**: Complete I/O abstraction layer with buffered output
2. **PEG IR Compiler**: Dynamic parser generation at runtime from intermediate representation
3. **Environment Access Syntax**: `env.symbol` for isolated grammar environments
4. **Cross-Architecture Support**: Unified build process for ARM64 and x86-64

### 📚 Included Languages

**Nile** - A complete stream processing language demonstrating Maru's capabilities:
- Unicode mathematical notation (∀, ≤, ≥, ∧, ∨)
- Efficient compilation to C
- High-performance runtime with multi-threading
- See `compilers/nile/` and `runtimes/nile/`

## Philosophy and Design

Maru embodies several key principles:

**🎯 Radical Simplicity**: Complex systems can emerge from simple foundations when designed with proper abstractions.

**🔄 Self-Description**: The system should be able to understand and modify itself.

**📚 Comprehensibility**: Every part of the system should be understandable by a single developer.

**🌉 Bridge Building**: Smooth transitions between different levels of abstraction (untyped ↔ typed, interpreted ↔ compiled).

**🧪 Experimentation**: The system should make it easy to try new ideas and language features.

## Contributing and Extending

Maru is designed for experimentation and extension:

- **Add language features**: Modify `eval.l` and regenerate
- **Create new backends**: Follow the pattern in `core/compiler/ir-gen-*.k`  
- **Build domain-specific languages**: Use Maru's PEG parser system
- **Educational use**: Perfect for compiler construction courses

## Community and Resources

- **Documentation**: See `doc/` directory for detailed technical documentation
- **Examples**: Study the built-in test files and examples  
- **Academic Papers**: Search for "VPRI STEPS" and Ian Piumarta's work on metacircular systems
- **Language Examples**: Nile demonstrates building complete languages on Maru
- **Historical Context**: Part of Alan Kay's vision for simplified computing systems

## License and History

Maru was developed by Ian Piumarta at Viewpoints Research Institute (VPRI) as part of the STEPS project (2007-2012). The project aimed to create a complete personal computing system in under 20,000 lines of code, demonstrating that sophisticated computing systems could be built with radical simplicity while maintaining full functionality.

Key collaborators included Dan Amelang (Nile language), Takashi Yamamiya, and other VPRI researchers who contributed to various aspects of the system.

---

*"The most powerful programming language is Lisp. If you don't know Lisp (or its variant, Scheme), you don't know what programming is. This is the most important thing you can learn in computer science." — Srinivasa Ramanujan*

Ready to explore the elegant simplicity of metacircular compilation? Start with `make run` and let Maru compile itself! 🚀