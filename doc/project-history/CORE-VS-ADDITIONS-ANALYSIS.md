# Maru Core vs. Additions Analysis

## Executive Summary

The current Maru codebase has grown from **22 original files** (Dan Amelang, 2011) to **130+ files**, representing a ~6x expansion. Most additions appear to be experimental features and organizational improvements, but this has obscured the clean original design.

## Original Core System (Dan Amelang, 2011)

### Core Bootstrap Files ✅
```
boot.l          - Core language bootstrap (✓ preserved)
emit.l          - Code generation (moved to core/compiler/emit.l)
eval.c          - C evaluator (✓ preserved)  
eval.l          - Lisp evaluator (✓ preserved)
gc.c/gc.h       - Garbage collector (✓ preserved)
buffer.c        - Buffer support (✓ preserved)
chartab.h       - Character tables (✓ preserved)
```

### Original Auxiliary Files 📁
```
Makefile        - Build system (✓ preserved, enhanced)
README          - Documentation (✗ missing)
hello.l         - Simple example (✗ missing)
mpl.l           - MPL compiler (✗ missing) 
parser.l        - Parser (moved to core/parser.l)
repl.l          - REPL (moved to lib/repl.l)
sim.l           - Simulator (✗ missing)
```

### Original PEG System 📁
```
peg-boot.l      - PEG bootstrap (moved to core/peg-boot.l)
peg-compile.l   - PEG compiler (moved to core/peg-compile.l)
peg.g           - PEG grammar (moved to grammars/core/peg.g)
peg.l           - PEG implementation (moved to core/peg.l)
```

### Original Tests 📁
```
test-emit.l     - Emit tests (moved to tests/backends/test-emit.l)
test-peg.l      - PEG tests (moved to tests/archive/test-peg.l)
test-repl.l     - REPL tests (moved to tests/archive/test-repl.l)
```

## What's Been Added (130+ files total)

### 1. Experimental Features (Root Directory) 🧪
**Problem**: Root cluttered with experiments that obscure core system

```
Current experimental files in root:
- debug-dotted.l, dotted-access-*.l (5+ variants)
- evalm-*.l (4+ variants) 
- peg-*.l (8+ variants)
- port-*.l (4+ variants)
- jit-*.l (10+ variants from recent analysis)
- discover-system.l, eval-introspection.l
- boot2.l, eval2.c, eval.h
- Various test-*.l files mixed with core
```

**Assessment**: Most appear to be development experiments rather than stable features.

### 2. Organizational Structure (Good) ✅
```
core/           - Core compiler components
├── compiler/   - Code generation backends  
├── peg-*.l     - PEG system components
└── parser.l    - Parser implementation

lib/            - Library components
├── stream/     - Port streams system
├── repl.l      - REPL implementation  
├── dlopen.k    - FFI system (discovered!)
└── lib*.k      - OpenGL, etc. bindings

arch/           - Architecture-specific backends
├── arm64/      - ARM64 code generation
└── x86/        - x86-64 code generation

tests/          - Organized test suite
grammars/       - Grammar definitions
doc/            - Documentation
```

**Assessment**: Good organizational structure, but core files should be more prominent.

### 3. Major Feature Additions ✅
```
1. Cross-Platform Architecture Support
   - arch/arm64/*.l, arch/x86/*.l
   - MARU_TARGET_ARCH system
   
2. FFI System (lib/dlopen.k) - CRITICAL DISCOVERY
   - Complete foreign function interface
   - Real examples: lib/libgl.k (97 OpenGL functions)
   - This was NOT in original 2011 snapshot
   
3. Port Streams System
   - lib/stream/port.l
   - I/O abstraction layer
   
4. Enhanced PEG System  
   - IR compilation, grammar environments
   - Dynamic parser generation
   
5. Multi-Method System
   - Generic function dispatch
   - Object system integration
```

## Core System Analysis

### Original Bootstrap Architecture (2011)
```
1. eval (C) loads boot.l
2. boot.l defines core language  
3. emit.l loaded for code generation
4. eval.l loaded for Lisp evaluator
5. System becomes self-hosting
```

### Current Bootstrap (Preserved but Obscured)
```
Same basic architecture, but:
- emit.l moved to core/compiler/emit.l
- Multiple emit variants (30+ files)
- Additional bootstrap variants (boot2.l)
- Enhanced with new features
```

## Critical Findings

### 1. FFI System Wasn't Original ⚠️
**Discovery**: `lib/dlopen.k` and associated FFI infrastructure was NOT in the 2011 snapshot. This appears to be a major later addition that enables:
- Dynamic library loading
- Foreign function interface  
- JIT compilation capabilities (our recent analysis)
- OpenGL bindings, system integration

### 2. Architecture Backends Are New ⚠️
**Discovery**: `arch/arm64/` and `arch/x86/` directories are later additions, not part of original design. Original emit.l was simpler and more direct.

### 3. Core Bootstrap Still Works ✅  
**Verified**: The fundamental bootstrap process from boot.l → emit.l → eval.l is preserved, just enhanced and reorganized.

## Recommendations

### Immediate: Identify Core vs. Experimental
1. **Archive Experiments**: Move root-level experimental files to `experiments/` directory
2. **Restore Core Visibility**: Make original core files more prominent  
3. **Document Additions**: Clearly mark what's original vs. added
4. **Preserve History**: Keep git history showing evolution

### Core Files That Should Be Prominent
```
Essential original architecture:
- boot.l (✓ already prominent)
- core/compiler/emit.l (original emit.l)
- eval.c, eval.l (✓ already prominent)
- core/peg-boot.l, core/peg.l (original PEG)
```

### Features to Preserve as Enhancements
```
Valuable additions to keep:
- lib/dlopen.k (enables JIT, FFI)
- arch/ backends (cross-platform support)  
- lib/stream/ (I/O improvements)
- Organizational structure (core/, lib/, tests/)
```

### Experimental Files to Archive
```
Root-level experiments to move:
- dotted-access-*.l variants (keep working version)
- evalm-*.l variants (development experiments)
- jit-*.l files (recent analysis artifacts)
- debug-*.l, discover-*.l (analysis tools)
- Multiple peg-*.l variants (keep stable versions)
```

## Key Insight: FFI Enables Modern Capabilities

**Critical Discovery**: The FFI system (`lib/dlopen.k`) that enables JIT compilation, OpenGL integration, and system interface was NOT part of the original 2011 design. This is a major enhancement that transforms Maru from an academic metacircular compiler into a practical system programming language.

**Original Design**: Clean, minimal metacircular compiler focused on self-hosting
**Current Reality**: Practical language with FFI, cross-platform support, and modern capabilities

## Conclusion

The current codebase preserves the elegant original Dan/Ian architecture while adding significant practical capabilities. The main issue is organization - too many experimental files in the root directory obscure the clean original design.

**Action Plan**: 
1. Archive experiments to restore core visibility
2. Document what's original vs. enhanced  
3. Preserve the valuable additions (FFI, architecture support)
4. Make the evolution story clear for future developers

The core is still there - it's just been enhanced and needs better organization to shine through.