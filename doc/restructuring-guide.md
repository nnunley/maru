# Codebase Restructuring Guide

## Current Issues and Solutions

### 1. File Organization Problems

**Current Issues**:
- Mixed file types in root directory (C, Lisp, Maru, grammars)
- Test files intermixed with core code
- No clear separation of concerns
- Grammar files scattered throughout

**Solutions**:
- Create logical directory hierarchy
- Separate core, runtime, libraries, and tests
- Group related functionality together
- Establish clear naming conventions

### 2. Grammar Extraction Plan

**Grammars to Extract**:
```
Current Location → New Location
peg.g → grammars/core/peg.g
irgol.g → grammars/core/irgol.g
irl.g → grammars/core/irl.g
x86.g → grammars/arch/x86.g
arm64-complete.g → grammars/arch/arm64.g
utf8*.g → grammars/unicode/
test-*.g → grammars/examples/
```

**Benefits**:
- Clear separation of grammar definitions
- Easier to find and modify grammars
- Better documentation structure
- Reusable grammar components

### 3. Core System Reorganization

**Before**:
```
maru/
├── eval.c
├── eval.l
├── eval2.c
├── emit.l
├── boot.l
├── boot2.l
├── gc.c
├── buffer.c
├── wcs.c
├── ir.k
├── ir-gen-*.k
├── maru.k
├── (100+ other files)
```

**After**:
```
maru/
├── core/
│   ├── bootstrap/
│   │   ├── eval.c        # C bootstrap
│   │   ├── boot.l        # Stage 1 bootstrap
│   │   └── boot2.l       # Stage 2 bootstrap
│   ├── compiler/
│   │   ├── eval.l        # Metacircular evaluator
│   │   ├── emit.l        # Code generator
│   │   └── eval2.c       # Generated evaluator
│   └── README.md
├── runtime/
│   ├── gc.c              # Garbage collector
│   ├── gc.h
│   ├── buffer.c          # Buffer management
│   ├── buffer.h
│   └── strings/
│       ├── wcs.c         # Wide char support (legacy)
│       ├── utf8.c        # UTF-8 support
│       └── README.md
└── ir/
    ├── core/
    │   ├── ir.k          # IR definitions
    │   └── ir.h          # IR C interface
    └── backends/
        ├── ir-gen-c.k    # C backend
        ├── ir-gen-x86.k  # x86 backend
        ├── ir-gen-arm64.k # ARM64 backend
        └── ir-gen-llir.k # LLVM backend
```

### 4. Naming Convention Improvements

**Current Issues**:
- Inconsistent naming (test-*, maru-*, ir-gen-*)
- No clear module prefixes
- Mixed naming styles

**Proposed Conventions**:
```
Core files:       maru-{component}.{ext}
IR files:         ir-{component}.{ext}
Test files:       test/{category}/test-{name}.{ext}
Library files:    lib/{category}/{name}.{ext}
Grammar files:    grammars/{category}/{name}.g
Architecture:     arch/{platform}/{component}.{ext}
```

### 5. Test Organization

**Current**: 50+ test-*.l files in root

**Proposed Structure**:
```
test/
├── unit/              # Unit tests
│   ├── core/         # Core language tests
│   ├── ir/           # IR system tests
│   └── runtime/      # Runtime tests
├── integration/       # Integration tests
│   ├── bootstrap/    # Bootstrap validation
│   ├── compilation/  # Compilation tests
│   └── metacircular/ # Self-hosting tests
├── performance/       # Performance benchmarks
├── examples/         # Example programs
└── fixtures/         # Test data and fixtures
```

### 6. Documentation Structure

**Enhance documentation organization**:
```
doc/
├── user/             # User documentation
│   ├── getting-started.md
│   ├── language-reference.md
│   └── tutorials/
├── developer/        # Developer documentation
│   ├── architecture.md
│   ├── contributing.md
│   ├── metacircular-compiler.md
│   └── backends/
├── api/              # API documentation
└── internals/        # Internal documentation
```

### 7. Build System Improvements

**Current Makefile Issues**:
- Missing eval2.c generation rule
- Inconsistent target naming
- No clear build stages

**Proposed Makefile Structure**:
```makefile
# Clear sections
.PHONY: all core runtime ir test doc clean

# Core targets
core: eval eval2

# Runtime targets  
runtime: gc buffer strings

# IR targets
ir: ir-backends

# Hierarchical dependencies
all: core runtime ir

# Clear build stages
bootstrap: eval
generate: eval2.c
compile: eval2
validate: test-metacircular
```

### 8. Module Dependencies

**Create clear dependency graph**:
```
bootstrap (eval.c)
    ↓
core language (boot.l)
    ↓
extended language (boot2.l)
    ↓
compiler (emit.l)
    ↓
evaluator (eval.l)
    ↓
IR system (ir.k)
    ↓
backends (ir-gen-*.k)
```

### 9. Migration Script

**Create automated migration script**:
```bash
#!/bin/bash
# migrate-structure.sh

# Create new directory structure
mkdir -p core/{bootstrap,compiler}
mkdir -p runtime/{strings}
mkdir -p ir/{core,backends}
mkdir -p grammars/{core,arch,unicode,examples}
mkdir -p test/{unit,integration,performance,examples}
mkdir -p doc/{user,developer,api,internals}

# Move files with git mv to preserve history
git mv eval.c core/bootstrap/
git mv boot.l boot2.l core/bootstrap/
git mv eval.l emit.l eval2.c core/compiler/
# ... etc

# Update references in code
find . -name "*.l" -o -name "*.k" -o -name "*.c" | \
  xargs sed -i 's|"boot\.l"|"core/bootstrap/boot.l"|g'
# ... etc
```

### 10. Benefits of Restructuring

1. **Improved Navigation**: Developers can quickly find relevant code
2. **Better Modularity**: Clear separation of concerns
3. **Easier Testing**: Organized test structure
4. **Simplified Building**: Clear build dependencies
5. **Enhanced Documentation**: Logical documentation structure
6. **Reduced Complexity**: Fewer files in each directory
7. **Better Collaboration**: Clear code ownership areas

## Implementation Priority

1. **Phase 1**: Create directory structure (non-breaking)
2. **Phase 2**: Move grammars (low risk)
3. **Phase 3**: Reorganize tests (medium risk)
4. **Phase 4**: Move core files (high risk, requires careful testing)
5. **Phase 5**: Update build system
6. **Phase 6**: Documentation updates

## Validation Checklist

- [ ] All files moved with git history preserved
- [ ] All references updated in code
- [ ] Build system works correctly
- [ ] All tests pass
- [ ] Metacircular compilation verified
- [ ] Documentation updated
- [ ] No broken imports/requires

This restructuring will make the codebase significantly more maintainable and approachable for new contributors.