# Maru Project Documentation Index

*A comprehensive guide to all documentation, source files, and resources in the Maru language workbench*

## 📚 Table of Contents

1. [Quick Start](#quick-start)
2. [Core Documentation](#core-documentation)
3. [Architecture & Design](#architecture--design)
4. [Language Features](#language-features)
5. [Implementation Details](#implementation-details)
6. [Development Guides](#development-guides)
7. [Project History](#project-history)
8. [API Reference](#api-reference)
9. [Examples & Tutorials](#examples--tutorials)
10. [Related Languages](#related-languages)

---

## 🚀 Quick Start

- **[README.md](README.md)** - Main project overview and getting started guide
- **[doc/GETTING_STARTED.md](doc/GETTING_STARTED.md)** - Detailed setup and first steps
- **[doc/tutorial.md](doc/tutorial.md)** - Interactive tutorial for learning Maru
- **[README.examples](README.examples)** - Script to run built-in examples

## 📖 Core Documentation

### Project Overview
- **[CLAUDE.md](CLAUDE.md)** - Comprehensive development documentation and current state
- **[doc/ARCHITECTURE.md](doc/ARCHITECTURE.md)** - System architecture overview
- **[doc/metacircular-compiler.md](doc/metacircular-compiler.md)** - Understanding the self-hosting nature

### Language Fundamentals
- **[doc/k-vs-l-files.md](doc/k-vs-l-files.md)** - Understanding .k (typed) vs .l (untyped) files
- **[boot.l](core/bootstrap/boot.l)** - Core language bootstrap definitions
- **[boot2.l](core/bootstrap/boot2.l)** - Extended bootstrap features

## 🏗️ Architecture & Design

### Core System
- **[core/eval.l](core/eval.l)** - The heart of Maru: self-hosting evaluator
- **[eval.c](eval.c)** - Initial C bootstrap evaluator
- **[doc/eval2-generation.md](doc/eval2-generation.md)** - How eval2 is generated

### Compilation System
- **[core/compiler/emit.l](core/compiler/emit.l)** - Main code generator (Lisp to C)
- **[doc/emit.l-guide.md](doc/emit.l-guide.md)** - Understanding the code generator
- **[C-THREADED-INTEGRATION-DESIGN.md](C-THREADED-INTEGRATION-DESIGN.md)** - Threaded C backend design

### Parser System
- **[core/peg.l](core/peg.l)** - PEG parser generator
- **[PEG-IR-COMPILER-COMPLETE.md](PEG-IR-COMPILER-COMPLETE.md)** - PEG IR compilation system
- **[grammars/README.md](grammars/README.md)** - Grammar specifications

## 🔧 Language Features

### Recent Additions (2024-2025)
- **[PORT-STREAMS-COMPLETED.md](PORT-STREAMS-COMPLETED.md)** - I/O abstraction layer
- **[MARU-TARGET-ARCH-INTEGRATION.md](MARU-TARGET-ARCH-INTEGRATION.md)** - Cross-platform support
- **[doc/multimethod-implementation-summary.md](doc/multimethod-implementation-summary.md)** - Multi-method dispatch

### Type System (.k files)
- **[doc/eval.k-design-document.md](doc/eval.k-design-document.md)** - Typed Maru design
- **[doc/eval.k-compilation-complete.md](doc/eval.k-compilation-complete.md)** - K file compilation
- **[doc/eval.k-ir-compilation.md](doc/eval.k-ir-compilation.md)** - IR system for K files

### Architecture Support
- **[ARM64-BACKEND.md](ARM64-BACKEND.md)** - ARM64/Apple Silicon support
- **[ARM64-DISASSEMBLER.md](ARM64-DISASSEMBLER.md)** - ARM64 debugging tools
- **[arch/](arch/)** - Architecture-specific implementations

## 💻 Implementation Details

### Bootstrap Process
- **[MARU-BOOTSTRAP-CORRECTION.md](MARU-BOOTSTRAP-CORRECTION.md)** - Bootstrap fixes
- **[doc/eval.k-bootstrap-plan.md](doc/eval.k-bootstrap-plan.md)** - K file bootstrap
- **[core/bootstrap/](core/bootstrap/)** - Bootstrap implementation files

### Code Generation Backends
- **[core/compiler/](core/compiler/)** - All compiler backends
  - `emit-c.l` - Standard C backend
  - `emit-x86.l` - x86 assembly backend
  - `ir-arm64.l` - ARM64 IR backend
  - `emit-c-threaded.l` - Threaded C backend

### Memory Management
- **[core/gc.l](core/gc.l)** - Garbage collector
- **[gc.c](gc.c)** - C garbage collector implementation

## 📝 Development Guides

### Building & Testing
- **[Makefile](Makefile)** - Build system
- **[doc/comprehensive-test-results.md](doc/comprehensive-test-results.md)** - Test suite results
- **[tests/](tests/)** - Test files

### Adding Features
- **[doc/implementation-plan.md](doc/implementation-plan.md)** - Feature implementation guide
- **[IMPLEMENTATION-SUMMARY.md](IMPLEMENTATION-SUMMARY.md)** - Recent implementations
- **[doc/grammar-driven-assembly.md](doc/grammar-driven-assembly.md)** - Grammar-based development

### Debugging & Analysis
- **[lib/debug/](lib/debug/)** - Debugging utilities
- **[doc/osdefs.md](doc/osdefs.md)** - OS-specific definitions
- **[mkosdefs.c](mkosdefs.c)** - OS definition generator

## 📜 Project History

### Evolution & Timeline
- **[doc/project-history/MARU-VERSION-EVOLUTION.md](doc/project-history/MARU-VERSION-EVOLUTION.md)** - Version history
- **[doc/project-history/MARU-ARCHAEOLOGICAL-TIMELINE.md](doc/project-history/MARU-ARCHAEOLOGICAL-TIMELINE.md)** - Development timeline
- **[doc/branch-history.md](doc/branch-history.md)** - Git branch evolution

### VPRI Heritage
- **[VPRI-MARU-ANALYSIS.md](VPRI-MARU-ANALYSIS.md)** - VPRI contributions
- **[doc/piumarta-2011-open-extensible-composition-models.md](doc/piumarta-2011-open-extensible-composition-models.md)** - Academic foundation
- **[original/README.md](original/README.md)** - Original implementation notes

### Cleanup & Reorganization
- **[CLEANUP-COMPLETED.md](CLEANUP-COMPLETED.md)** - Recent cleanup efforts
- **[doc/project-history/REORGANIZATION-PROPOSAL.md](doc/project-history/REORGANIZATION-PROPOSAL.md)** - Future structure
- **[doc/restructuring-guide.md](doc/restructuring-guide.md)** - Restructuring plans

## 🔌 API Reference

### Core Functions (boot.l)
- Forms: `define-form`, `define-macro`
- Functions: `define-function`, `lambda`
- Structures: `define-structure`, `define-method`
- Control: `if`, `while`, `let`, `set`

### Compiler API (emit.l)
- `encode` - Main compilation entry
- `gen-xxx` - Code generation functions
- `emit-xxx` - Output functions

### Parser API (peg.l)
- `peg-compile` - Compile PEG grammar
- `define-parser` - Create parser
- Grammar operators: `match`, `sequence`, `choice`

### Library Functions
- **[lib/](lib/)** - Standard library
  - `stream/` - I/O and ports
  - `pretty-print.l` - Formatted output
  - `repl.l` - Interactive REPL
  - `ansiterm.l` - Terminal control

## 📖 Examples & Tutorials

### Basic Examples
- **[tests/test-*.l](tests/)** - Unit tests as examples
- **[demo-port-dispatch.l](demo-port-dispatch.l)** - Port system demo
- **[peg-ir-demo.l](peg-ir-demo.l)** - PEG IR demonstration

### Advanced Examples
- **[lib/tinycc/](lib/tinycc/)** - C compiler integration
- **[lib/x86-64/](lib/x86-64/)** - x86-64 assembly examples
- **[net/](net/)** - Networking examples

## 🌊 Related Languages

### Nile - Stream Processing Language
- **[compilers/nile/README.md](compilers/nile/README.md)** - Nile overview
- **[NILE-MARU-ANALYSIS.md](NILE-MARU-ANALYSIS.md)** - Integration with Maru
- **[NILE-TO-C-COMPILATION.md](NILE-TO-C-COMPILATION.md)** - Compilation process
- **[runtimes/nile/](runtimes/nile/)** - Nile runtime system

### Language Building Resources
- **[grammars/](grammars/)** - Example grammars
- **[compilers/](compilers/)** - Example compilers
- **[runtimes/](runtimes/)** - Runtime systems

---

## 🔍 Quick Reference

### File Types
- **`.l`** - Untyped Lisp source files
- **`.k`** - Typed Maru source files  
- **`.g`** - Grammar specification files
- **`.nl`** - Nile language files
- **`.md`** - Documentation files

### Key Directories
- **`core/`** - Core compiler and language
- **`lib/`** - Standard libraries
- **`arch/`** - Architecture-specific code
- **`doc/`** - Documentation
- **`tests/`** - Test suite
- **`compilers/`** - Language implementations
- **`grammars/`** - Parser grammars

### Build Artifacts
- `eval` - Bootstrap evaluator
- `eval2` - Self-compiled evaluator
- `evalm` - Multi-method evaluator
- `*.c` - Generated C code
- `*.o` - Object files

---

*Last updated: July 2025 | Maru v2.5+ with recent enhancements*