# Maru Quick Navigation Guide

*Fast access to everything you need in the Maru project*

## 🎯 I Want To...

### Learn Maru
- **Start Here**: [README.md](README.md) → [Getting Started](doc/GETTING_STARTED.md) → [Tutorial](doc/tutorial.md)
- **Understand Concepts**: [Architecture](doc/ARCHITECTURE.md) → [Metacircular Design](doc/metacircular-compiler.md)
- **See Examples**: Run `./README.examples` or check [tests/](tests/)

### Write Maru Code
- **Language Reference**: [API Reference](API-REFERENCE.md)
- **Understand .l vs .k**: [File Types Guide](doc/k-vs-l-files.md)
- **Bootstrap Functions**: [boot.l](core/bootstrap/boot.l) and [boot2.l](core/bootstrap/boot2.l)

### Compile Programs
- **Basic**: `./eval program.l`
- **Self-hosting**: `./eval2 program.l`
- **To C**: `./eval core/compiler/emit.l program.l > output.c`
- **Understanding emit.l**: [Emit Guide](doc/emit.l-guide.md)

### Build the System
- **Quick Build**: `make clean && make`
- **Cross-platform**: `MARU_TARGET_ARCH=arm64 make`
- **Details**: [Makefile](Makefile), [Target Architecture](MARU-TARGET-ARCH-INTEGRATION.md)

### Debug Issues
- **Debug Build**: `make debug`
- **Trace Execution**: `./eval -v program.l`
- **Debug Tools**: [lib/debug/](lib/debug/)

### Extend Maru
- **Add Features**: Modify [eval.l](core/eval.l) → regenerate
- **New Backend**: Study [emit.l](core/compiler/emit.l) patterns
- **Parser/Grammar**: [PEG System](core/peg.l), [Grammar Guide](grammars/README.md)

### Build a Language
- **Example**: [Nile Language](compilers/nile/README.md)
- **Parser Generator**: [PEG Documentation](PEG-IR-COMPILER-COMPLETE.md)
- **Runtime FFI**: [Nile Runtime](runtimes/nile/)

## 📁 Key Files Quick Reference

### Core System
| File | Purpose | See Also |
|------|---------|----------|
| [eval.c](eval.c) | Bootstrap evaluator | [eval2 generation](doc/eval2-generation.md) |
| [eval.l](core/eval.l) | Self-hosting evaluator | [Design](doc/eval.k-design-document.md) |
| [boot.l](core/bootstrap/boot.l) | Core definitions | [boot2.l](core/bootstrap/boot2.l) |
| [emit.l](core/compiler/emit.l) | Code generator | [Guide](doc/emit.l-guide.md) |

### Compilation
| What | Command | Output |
|------|---------|--------|
| Run .l file | `./eval file.l` | Execution |
| Run .k file | `./eval file.k` | Execution |
| Compile to C | `./eval emit.l file.l` | C code |
| Self-compile | `./eval2 file.l` | Execution |

### Architecture Support
| Platform | Files | Documentation |
|----------|-------|---------------|
| ARM64 | [arch/arm64/](arch/arm64/) | [ARM64 Backend](ARM64-BACKEND.md) |
| x86-64 | [arch/x86/](arch/x86/) | [x86 in emit.l](core/compiler/emit-x86.l) |
| Cross-platform | [Makefile](Makefile) | [Target Arch](MARU-TARGET-ARCH-INTEGRATION.md) |

## 🔍 Common Tasks

### REPL Sessions
```bash
# Basic REPL
./eval

# Enhanced REPL
make run

# With libraries
./eval lib/repl.l
```

### Testing
```bash
# Run all tests
make test

# Specific test
./eval tests/test-basics.l

# K-file tests
make test-maru
```

### Documentation
- **Full Index**: [Documentation Index](DOCUMENTATION-INDEX.md)
- **API Reference**: [API Reference](API-REFERENCE.md)
- **Project State**: [CLAUDE.md](CLAUDE.md)

## 📚 Learning Paths

### Beginner Path
1. [README](README.md) → [Tutorial](doc/tutorial.md)
2. Run examples: `./README.examples`
3. Try REPL: `make run`
4. Read [boot.l](core/bootstrap/boot.l)

### Compiler Path
1. [Architecture](doc/ARCHITECTURE.md)
2. [Metacircular Concepts](doc/metacircular-compiler.md)
3. Study [eval.l](core/eval.l) and [emit.l](core/compiler/emit.l)
4. [eval2 Generation](doc/eval2-generation.md)

### Language Builder Path
1. [PEG System](PEG-IR-COMPILER-COMPLETE.md)
2. [Nile Example](compilers/nile/README.md)
3. [Grammar Examples](grammars/)
4. [Port Streams](PORT-STREAMS-COMPLETED.md)

### Systems Path
1. [Multi-methods](doc/multimethod-implementation-summary.md)
2. [Memory/GC](core/gc.l)
3. [FFI System](lib/dlopen.k)
4. [Architecture Backends](arch/)

## 🚀 Recent Features (2024-2025)

| Feature | Documentation | Files |
|---------|---------------|-------|
| Port Streams | [Complete](PORT-STREAMS-COMPLETED.md) | [lib/stream/](lib/stream/) |
| PEG IR | [Compiler](PEG-IR-COMPILER-COMPLETE.md) | [peg-ir-demo.l](peg-ir-demo.l) |
| Cross-platform | [Integration](MARU-TARGET-ARCH-INTEGRATION.md) | [Makefile](Makefile) |
| Multi-methods | [Summary](doc/multimethod-implementation-summary.md) | [evalm](evalm) |

## 🛠️ Troubleshooting

### Build Issues
- Check [Makefile](Makefile)
- See [Target Architecture](MARU-TARGET-ARCH-INTEGRATION.md)
- Review [Bootstrap Correction](MARU-BOOTSTRAP-CORRECTION.md)

### Runtime Issues
- Enable verbose: `./eval -v`
- Check [osdefs](doc/osdefs.md)
- Debug with [lib/debug/](lib/debug/)

### Documentation
- Can't find something? Check [Full Index](DOCUMENTATION-INDEX.md)
- Historical context: [Project History](doc/project-history/)
- Academic background: [Piumarta 2011](doc/piumarta-2011-open-extensible-composition-models.md)

---

*Quick tip: Use your editor's file search for "TODO" to find areas needing work!*