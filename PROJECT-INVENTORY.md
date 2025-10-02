# Maru Project File Inventory

## Overview

The Maru project contains 742 files organized into several categories. The project shows signs of active development with many exploration and test files in the root directory that could benefit from better organization.

## File Categories

### 1. Core Compiler Files

#### Bootstrap Files
- `boot.l` - Primary bootstrap file (also in core/bootstrap/)
- `boot2.l` - Secondary bootstrap file (also in core/bootstrap/)
- `core/bootstrap/bootstrap-eval2.l` - Bootstrap for eval2

#### Primary Compiler Components
- `emit.l` - Main code emitter (link to core/compiler/emit.l)
- `eval.l` - Main evaluator
- `eval.k` - Evaluator kernel implementation
- `core/eval.k` - Core evaluator kernel
- `core/eval.l` - Core evaluator
- `peg.l` - PEG parser generator
- `core/peg.l` - Core PEG implementation

#### Generated C Files (DO NOT EDIT)
- `eval.c` - Generated from eval sources
- `eval2.c` - Generated eval2 implementation
- `buffer.c` - Buffer management
- `gc.c` - Garbage collector
- `wcs.c` - Wide character support
- `mkosdefs.c` - OS definitions generator

#### Binary Executables
- `eval` - Main evaluator executable
- `eval2` - Secondary evaluator
- `eval2-utf8` - UTF-8 enabled evaluator
- `evalm` - Shell script wrapper for eval
- `maru-check` - Testing utility
- `mkosdefs` - OS definitions generator
- `generated` - Generated executable
- `return42` - Simple test binary
- `threaded-add-simple` - Threading test

### 2. Architecture Support

#### ARM64 Backend (arch/arm64/)
- 16 files for ARM64 support including:
  - `arm64-spec.l`, `arm64-compiler-complete.l`
  - `asm-arm64.l`, `assembler-arm64.k`
  - `disasm-arm64.k` and variants

#### x86 Architecture (arch/x86/, arch/x86-64/)
- `x86-compiler.l` - x86 compiler
- `asm-x86.l`, `asm-x86.k` - x86 assembler
- `asm-x86-64.l` - x86-64 support

#### Common Architecture Files (arch/common/)
- `asm-common.k` - Common assembler code
- `assembler.k` - Base assembler

### 3. Compiler Infrastructure (core/compiler/)

#### Code Emission (33 emit-* files)
Multiple versions and variants of emitters:
- `emit-c.l`, `emit-c-backend.l`, `emit-c-threaded.l`
- `emit-x86.l`, `emit-asm.l`
- Various experimental versions (simple, minimal, proper, etc.)

#### Compilation Tools (17 compile-* files)
- `compile.l` - Main compiler
- `compile-arm64.l`, `compile-peg.l`, `compile-grammar.l`
- Various specialized compilers

#### IR and Code Generation
- `ir.k`, `ir2.k` - Intermediate representation
- `ir-gen-*.k` files for different targets
- `ir-arm64*.l` files for ARM64 IR

### 4. Recent Development Files (Root Directory)

These appear to be recent explorations that should be organized:

#### Port/Stream Development (NEW)
- `port-dispatch-concept.l`
- `evalm-ports-clean.l`, `evalm-ports-working.l`
- `evalm-proper-dispatch.l`, `evalm-with-ports.l`
- `test-port-integration.l`, `test-evalm-ports.l`
- `test-port-streams-complete.l`, `test-repl-with-ports.l`

#### PEG Compiler Development
- `peg-boot-enhanced.l`, `peg-boot-final.l`
- `peg-compile-generated.l`, `peg-grammar-environments.l`
- `peg-ir-compiler.l`, `peg-ir-demo.l`
- `peg-simple-compiler.l`

#### Dotted Access Feature
- `dotted-access-enhanced.l`, `dotted-access-minimal.l`
- `dotted-access-simple.l`, `dotted-access-working.l`
- `dotted-environment-access.l`
- `debug-dotted.l`, `test-dotted-syntax.l`

#### Other Recent Tests
- `demo-port-dispatch.l`
- `test-char-conversion.l`
- `test-self-dot.l`

### 5. Library Files (lib/)

#### Core Libraries
- `repl.l` - Read-eval-print loop
- `pretty-print.l` - Pretty printer
- `buffer.k` - Buffer operations
- `stream/port.l` - Port implementation

#### Graphics Libraries
- `libgl.k`, `libglfw.k`, `libglu.k`
- `libgezira.k`, `libnile.k`
- `gl-texbuf.k`

#### Utilities
- `maru-check.k`, `maru-gc.k`, `maru-test.k`
- `maru-utf8.k` - UTF-8 support
- `ansiterm.l` - Terminal support
- `random.k`, `matrix.k`, `trie.k`

#### Debug Tools (lib/debug/)
- `debug-simple.l`, `debug-text-parser.l`
- `debug-x86-parser.l`, `text-parser.l`

### 6. Test Suite (tests/)

Organized into subdirectories:
- `tests/archive/` - 74 archived test files
- `tests/arm64/` - 16 ARM64-specific tests
- `tests/backends/` - 32 backend tests
- `tests/evaluation/` - 23 evaluation tests
- `tests/infrastructure/` - 30 infrastructure tests
- `tests/threaded-c/` - 7 threaded C tests
- `tests/unit/` - Unit tests with subdirectories

### 7. Documentation

#### Markdown Documentation (doc/)
- Architecture guides, getting started
- Implementation notes and plans
- Test results and design documents

#### Recent Documentation (Root)
- `CLEANUP-COMPLETED.md`
- `ESSENTIAL-CORE-FILES.md`
- `IMPLEMENTATION-SUMMARY.md`
- `PEG-IR-COMPILER-COMPLETE.md`
- `PORT-STREAMS-COMPLETED.md`
- `MARU-TARGET-ARCH-INTEGRATION.md`

### 8. Archive Directory

Contains 285 files in two subdirectories:
- `archive/documentation/` - 26 old documentation files
- `archive/experimental/` - 259 experimental files including:
  - Many test files and explorations
  - Generated C files
  - Experimental implementations

### 9. Grammar Files (grammars/)

Organized grammar definitions:
- `grammars/arch/` - Architecture-specific grammars
- `grammars/core/` - Core language grammars
- `grammars/examples/` - Example grammars
- `grammars/unicode/` - Unicode support grammars

### 10. Other Directories

- `net/` - Network support with TCP/IP implementations
- `old/` - Old evaluator versions (eval2.c, eval3.c, eval4.c)
- `examples/` - Currently empty
- `runtime/` - Runtime support (empty)
- `ir/` - IR subdirectories (backends/, core/)
- `cleanup-analysis/` - Cleanup planning

## Files Needing Organization

### Root Directory Clutter
The following files in the root directory appear to be explorations or tests that should be moved:

1. **Recent Port/Stream Work** (10 files) - Should move to a dedicated development branch or tests/
2. **PEG Compiler Work** (7 files) - Should integrate into core/compiler/ or tests/
3. **Dotted Access Feature** (7 files) - Should move to a feature branch or tests/
4. **Test Files** (4 files) - Should move to tests/

### Naming Patterns

The project uses several naming conventions:
- `.l` files - Lisp source files
- `.k` files - Kernel/low-level implementations
- `.g` files - Grammar definitions
- `.c` files - Generated C code (DO NOT EDIT)
- `-complete`, `-final`, `-working` suffixes indicate development stages
- `test-` prefix for test files

## Recommendations

1. **Move recent explorations** from root to appropriate subdirectories
2. **Consolidate emit-* files** - Many variants could be archived
3. **Organize test files** better - Some are scattered in root
4. **Create feature branches** for active development (ports, PEG compiler)
5. **Archive old experiments** - Many files in archive/experimental/ could be cleaned up

## Summary Statistics

- Total files: ~742
- Core compiler files: ~40
- Test files: ~200+
- Experimental/archived: ~285
- Documentation: ~50+
- Active development files in root: ~30