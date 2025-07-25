# Nile Language Compiler

This directory contains the Nile programming language compiler, which uses Maru as its implementation platform.

## Overview

Nile is a declarative stream processing language designed for creating real-time graphics pipelines. It was created by Dan Amelang at VPRI (Viewpoints Research Institute) as part of the STEPS project.

## Language Features

- **Mathematical Notation**: Nile uses Unicode mathematical symbols (∀, ∧, ∨, ≤, ≥, etc.)
- **Stream Processing**: First-class support for stream operations with `>>` operator
- **Type System**: Simple but effective type system with Numbers, Booleans, and user-defined types
- **Pattern Matching**: Process definitions can pattern match on input streams
- **Functional Style**: Pure functional semantics with immutable data

## Directory Structure

```
compilers/nile/
├── nile-compiler.l          # Main compiler entry point
├── nile-grammar.g           # PEG grammar for Nile syntax
├── nile-ast-nodes.l         # AST node definitions
├── nile-resolve.l           # Name resolution pass
├── nile-type-check.l        # Type checking pass
├── nile-gen-code-c.l        # C code generation
├── nile-gen-code-maru.l     # Maru code generation
├── nile-builtins.l          # Built-in operations
├── nile-builtins-c.l        # C implementations of builtins
├── nile-builtins-maru.l     # Maru implementations of builtins
├── nile-process-template.c  # C template for processes
├── prelude.nl               # Standard library
├── nile-to-c-compiler.sh    # Shell script for C compilation
├── nile-to-maru-compiler.sh # Shell script for Maru compilation
└── test/
    └── test.nl              # Test file
```

## Building

The Nile compiler requires a working Maru installation. From the main Maru directory:

```bash
# Build Maru first
make eval gceval

# Then you can use the Nile compiler scripts
./compilers/nile/nile-to-c-compiler.sh ModuleName input.nl > output.c
```

## Usage

### Compiling to C

```bash
./nile-to-c-compiler.sh MyModule my-program.nl > my-program.c
```

This generates a C file that can be compiled with any C compiler. The generated code depends on the Nile runtime library which is available in `runtimes/nile/`.

### Compiling to Maru

```bash
./nile-to-maru-compiler.sh MyModule my-program.nl > my-program.l
```

This generates Maru code that can be loaded and executed within the Maru environment.

## Example

Here's a simple Nile program that transforms points by a matrix:

```nile
type Point = (x:Number, y:Number)
type Matrix = (a:Number, b:Number, c:Number, d:Number, e:Number, f:Number)

TransformPoint (M:Matrix) : Point >> Point
    (a, b, c, d, e, f) = M
    ∀ (x, y)
        >> (ax + cy + e, bx + dy + f)
```

### Compiling and Running the Example

```bash
# Generate C code
./compilers/nile/nile-to-c-compiler.sh MyGraphics transform.nl > transform.c

# Compile with the runtime (from project root)
gcc -o transform transform.c \
    runtimes/nile/nile.c \
    runtimes/nile/nile-process.c \
    runtimes/nile/nile-builtins.c \
    -I runtimes/nile/ \
    -lm -pthread

# Run the program
./transform
```

## Implementation Details

The Nile compiler showcases sophisticated use of Maru:

1. **PEG Parser**: Uses Maru's PEG system to parse Unicode mathematical notation
2. **Multi-Pass Compilation**: Separate passes for parsing, resolution, type checking, and code generation
3. **Multi-Backend**: Supports compilation to both C and Maru
4. **Metaprogramming**: Leverages Maru's metaprogramming capabilities for code generation

## How It Uses Maru

Nile demonstrates several advanced Maru features:

- **Object System**: Defines AST nodes as Maru objects with methods
- **Generic Functions**: Uses multi-methods for compiler passes
- **PEG Grammars**: Complex grammar with Unicode support
- **Code Generation**: Template-based code generation to multiple targets
- **FFI Integration**: Generated C code interfaces with external libraries

## Integration with Maru

This Nile compiler is integrated into the Maru project structure. The original Nile repository included additional components:
- JavaScript implementation
- Smalltalk implementation  
- C runtime library
- Visualization tools

Only the Maru-based compiler is included here, as it best demonstrates Maru's capabilities as a language implementation platform.

## References

- Original Nile repository: https://github.com/damelang/nile
- STEPS project reports: http://www.vpri.org/pdf/tr2011004_steps11.pdf
- Dan Amelang's publications on Nile and stream processing

## License

Nile was developed at VPRI and is available under the MIT license (see MIT-LICENSE in the Nile repository).