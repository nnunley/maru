# Maru Branch History and Evolution

This document describes the different versions of Maru preserved in the git branches and their significance in understanding the language's evolution.

## Branch Overview

### bootstrap Branch
- **Content**: The original Maru implementation
- **Key Feature**: Assembly-only generation
- **Makefile target**: Generates .s (assembly) files
- **eval2**: Used for self-validation (regenerate assembly and diff)

### version-2.1 Branch  
- **Release**: Early 2012
- **Architecture**: Still assembly-focused
- **Platform**: 32-bit x86 only (-m32 flag)
- **Bootstrap**: Uses boot-eval.c → eval.s → eval

### version-2.4 Branch
- **Release**: August 2012
- **Status**: Last version before current architecture
- **Changes**: Added Windows support, restored metacircular bootstrap
- **Note**: Still primarily assembly-based

### main/master Branch (Current)
- **Architecture**: Dual approach - both C and assembly generation
- **Key Change**: eval2.c is now a C file (not assembly)
- **IR System**: Full support for multiple backends
- **Backends**: C, x86, ARM64, LLVM IR

## Architectural Evolution

### Phase 1: Pure Assembly (bootstrap → version-2.4)
```makefile
# Generate assembly from Lisp
boot-eval boot.l emit.l eval.l > eval.s

# Self-validation
eval boot.l emit.l eval.l > eval2.s
diff eval.s eval2.s
```

**Characteristics**:
- Direct machine code generation
- Platform-specific (x86-32)
- eval2 was for validation, not a different implementation

### Phase 2: Parallel Development (Current)
```makefile
# Direct C generation
eval emit.l eval.l > eval2.c

# IR-based generation (multiple targets)
eval2 ir-gen-c.k maru.k source.k > output.c
eval2 ir-gen-x86.k maru.k source.k > output.s
```

**Characteristics**:
- Multiple code generation strategies
- Platform independence through C
- IR system for clean architecture
- eval2.c is now the self-hosted C implementation

## Key Observations

1. **Not a Transition**: The move from assembly to C wasn't a replacement but an addition. The IR system supports both.

2. **Early C Support**: Git history shows C generation was considered from December 2009 (NOTES file about C code generation).

3. **Pragmatic Evolution**: The shift represents practical needs:
   - Portability across architectures
   - Easier debugging and maintenance
   - Integration with existing C ecosystems

4. **Preserved Capability**: Assembly generation still exists through ir-gen-x86.k and ir-gen-arm64.k

## Using Historical Branches

To explore historical versions:

```bash
# Check out a historical version
git checkout version-2.1

# Compare Makefiles
git diff version-2.1 main -- Makefile

# See evolution of emit.l
git log --oneline --follow emit.l
```

## Lessons from History

1. **Incremental Evolution**: Maru evolved by adding capabilities, not replacing them
2. **Pragmatic Decisions**: C generation added for practical portability
3. **Maintained Philosophy**: Self-hosting and metacircular evaluation preserved throughout
4. **Multiple Strategies**: Different code generation approaches for different needs

The branch history shows Maru as a living system that evolved to meet practical needs while maintaining its theoretical elegance.