# Maru Reorganization - File Migration Mapping

## Core Files (→ core/)
```
boot.l                → core/boot.l
emit.l                → core/emit.l
eval.l                → core/eval.l
eval.k                → core/eval.k
buffer.l              → core/buffer.l
gc.l                  → core/gc.l
osdefs.l              → core/osdefs.l
```

## Active Features (→ src/features/)

### Port/Streams Implementation
```
evalm-ports-clean.l        → src/features/port-streams/evalm-ports-clean.l
evalm-ports-working.l      → src/features/port-streams/evalm-ports-working.l
evalm-proper-dispatch.l    → src/features/port-streams/evalm-proper-dispatch.l
evalm-with-ports.l         → src/features/port-streams/evalm-with-ports.l
port-dispatch-concept.l    → src/features/port-streams/port-dispatch-concept.l
demo-port-dispatch.l       → src/features/port-streams/examples/demo-port-dispatch.l
test-evalm-ports.l         → src/features/port-streams/tests/test-evalm-ports.l
test-port-integration.l    → src/features/port-streams/tests/test-port-integration.l
test-port-streams-complete.l → src/features/port-streams/tests/test-port-streams-complete.l
test-repl-with-ports.l     → src/features/port-streams/tests/test-repl-with-ports.l
PORT-STREAMS-COMPLETED.md  → src/features/port-streams/README.md
```

### PEG Compiler Enhancements
```
peg-boot-enhanced.l       → src/features/peg-compiler/peg-boot-enhanced.l
peg-boot-final.l          → src/features/peg-compiler/peg-boot-final.l
peg-compile-generated.l   → src/features/peg-compiler/peg-compile-generated.l
peg-grammar-environments.l → src/features/peg-compiler/peg-grammar-environments.l
peg-ir-compiler.l         → src/features/peg-compiler/peg-ir-compiler.l
peg-simple-compiler.l     → src/features/peg-compiler/peg-simple-compiler.l
PEG-IR-COMPILER-COMPLETE.md → src/features/peg-compiler/README.md
```

### Dotted Access Feature
```
dotted-access-enhanced.l  → src/features/dotted-access/dotted-access-enhanced.l
dotted-access-minimal.l   → src/features/dotted-access/dotted-access-minimal.l
dotted-access-simple.l    → src/features/dotted-access/dotted-access-simple.l
dotted-access-working.l   → src/features/dotted-access/dotted-access-working.l
dotted-environment-access.l → src/features/dotted-access/dotted-environment-access.l
debug-dotted.l            → src/features/dotted-access/debug/debug-dotted.l
test-dotted-syntax.l      → src/features/dotted-access/tests/test-dotted-syntax.l
test-self-dot.l           → src/features/dotted-access/tests/test-self-dot.l
```

## Backend Variants (→ src/backends/)

### C Backend Variants
```
emit-c.l                  → src/backends/c-backend/emit-c.l
emit-c-high.l             → src/backends/c-backend/emit-c-high.l
emit-compatibility-layer.l → src/backends/c-backend/compatibility-layer.l
```

### Threaded Backend
```
emit-c-threaded.l         → src/backends/threaded-backend/emit-c-threaded.l
emit-c-threaded-clean.l   → src/backends/threaded-backend/variants/clean.l
emit-c-threaded-complete.l → src/backends/threaded-backend/variants/complete.l
emit-c-threaded-evalm.l   → src/backends/threaded-backend/variants/evalm.l
emit-c-threaded-final.l   → src/backends/threaded-backend/variants/final.l
emit-c-threaded-fixed.l   → src/backends/threaded-backend/variants/fixed.l
emit-c-threaded-minimal.l → src/backends/threaded-backend/variants/minimal.l
emit-c-threaded-proper.l  → src/backends/threaded-backend/variants/proper.l
emit-c-threaded-super-minimal.l → src/backends/threaded-backend/variants/super-minimal.l
emit-c-threaded-twopass.l → src/backends/threaded-backend/variants/twopass.l
emit-c-threaded-working.l → src/backends/threaded-backend/variants/working.l
```

### IR Backend
```
emit-ir.l                 → src/backends/ir-backend/emit-ir.l
emit-ir-simple.l          → src/backends/ir-backend/emit-ir-simple.l
```

## Library Files (→ src/lib/)
Already well-organized in lib/ - just move:
```
lib/*                     → src/lib/*
```

## Generated Files (→ build/generated/)
```
eval.c                    → build/generated/eval.c
eval2.c                   → build/generated/eval2.c
buffer.c                  → build/generated/buffer.c
gc.c                      → build/generated/gc.c
osdefs.c                  → build/generated/osdefs.c
eval-*.c                  → build/generated/
test-*.c                  → build/generated/
```

## Binaries (→ build/binaries/)
```
eval                      → build/binaries/eval
eval2                     → build/binaries/eval2
evalm                     → build/binaries/evalm
maru                      → build/binaries/maru
test-*                    → build/binaries/
mini-*                    → build/binaries/
simple-*                  → build/binaries/
```

## Tests (→ tests/)

### Unit Tests
```
test-buffer.l             → tests/unit/core/test-buffer.l
test-gc.l                 → tests/unit/core/test-gc.l
test-emit.l               → tests/unit/emit/test-emit.l
test-eval.l               → tests/unit/eval/test-eval.l
```

### Integration Tests
```
test-boot.l               → tests/integration/test-boot.l
test-bootstrap.l          → tests/integration/test-bootstrap.l
test-metacircular.l       → tests/integration/test-metacircular.l
```

### Regression Tests
```
test-regression-*.l       → tests/regression/
```

## Experiments (→ experiments/)

### Emit Experiments (with dates estimated from content)
```
emit-split-*.l            → experiments/2023-11-emit-split/
emit-2.4.l                → experiments/2023-10-emit-legacy/
eval-threaded-attempt*.c  → experiments/2024-01-eval-threading/
mini-eval*.l              → experiments/2023-12-mini-eval/
simple-*.l                → experiments/2024-01-simple-variants/
```

### Debug Scripts
```
debug-*.l                 → experiments/debug-scripts/
analyze-*.l               → experiments/analysis-scripts/
check-*.l                 → experiments/validation-scripts/
```

## Documentation Updates

### Existing Documentation
```
doc/*                     → doc/* (keep current structure)
ARM64-*.md                → doc/architecture/arm64/
MARU-TARGET-ARCH-*.md     → doc/architecture/cross-compilation/
```

### Archive Documentation
```
archive/documentation/*   → doc/historical/
```

### New Documentation Files
```
REORGANIZATION-PROPOSAL.md → doc/development/reorganization-proposal.md
MIGRATION-MAPPING.md      → doc/development/migration-mapping.md
IMPLEMENTATION-SUMMARY.md → doc/development/implementation-summary.md
ESSENTIAL-CORE-FILES.md   → doc/development/essential-core-files.md
```

## Files to Delete (After Backup)

### Generated Files
```
*.o
*.dSYM/
core.* (core dumps)
```

### Temporary Scripts
```
temp-*.l
tmp-*.l
run-*.sh (unless needed)
```

### Obsolete Tests
```
test-old-*.l
test-broken-*.l
```

## Special Handling Required

### Files Needing Path Updates
1. **Makefile** - Update all paths to new structure
2. **boot.l** - Update load paths for moved files
3. **Test runners** - Update test discovery paths
4. **Build scripts** - Update compilation paths

### Files to Preserve in Root
```
.gitignore
LICENSE
README.md
Makefile
CLAUDE.md (restored)
DEVELOPMENT.md (new)
```

### New Files to Create
```
core/README.md            - Explain core components
src/README.md             - Development guidelines
experiments/README.md     - Experiment documentation
tests/README.md           - Testing guidelines
build/.gitignore          - Ignore all generated files
```

## Implementation Order

### Step 1: Create Structure
```bash
mkdir -p core src/{features/{port-streams,peg-compiler,dotted-access,multimethod}/{,tests,examples},backends/{c-backend,threaded-backend,ir-backend}/variants,lib}
mkdir -p build/{generated,binaries,intermediates}
mkdir -p tests/{unit/{core,emit,eval},integration,regression,experiments,fixtures}
mkdir -p experiments/{debug-scripts,analysis-scripts,validation-scripts}
mkdir -p tools/{bootstrap,analysis,migration}
mkdir -p examples/{basic,advanced,tutorials}
mkdir -p doc/{architecture/{arm64,x86,cross-compilation},development,api,historical}
```

### Step 2: Move Core Files First
Essential files that everything depends on

### Step 3: Move Feature Files
Group related files together

### Step 4: Move Tests
Organize by type and component

### Step 5: Clean Up
Remove generated files and update build system

## Validation Checklist

After each major step:
- [ ] Bootstrap still works
- [ ] Tests can be found and run
- [ ] No broken imports
- [ ] Documentation updated
- [ ] Git history preserved