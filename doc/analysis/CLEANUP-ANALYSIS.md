# Maru Project Cleanup Analysis

## Executive Summary

The Maru project has grown organically and needs systematic cleanup to improve maintainability and organization. This analysis identifies 742+ files with significant redundancy and organizational issues.

## Current State Analysis

### Root Directory Issues

**Overcrowded Root** (74 items):
- 17 `.l` files (should be in appropriate subdirectories)
- 10 `.c` files (mix of generated and manual files)
- 26 `.md` files (documentation scattered)
- Multiple shell scripts and temporary files

**Key Problems**:
1. **Development artifacts in root**: test files, exploration scripts, temporary builds
2. **Documentation fragmentation**: 26 MD files + more in subdirectories
3. **Generated files mixed with source**: eval2.c variants, compiled outputs
4. **Experimental code proliferation**: Multiple versions of same concepts

### Redundant File Analysis

#### emit-c Related Files (94+ files)
```
Core implementation: emit-c.l (root)
Redundant variants: 15+ emit-c-* files in core/compiler/
Experimental versions: 20+ in archive/experimental/
Test files: 25+ in tests/
Design documents: 10+ in doc/design/emit-c/
```

#### Backend Files (50+ redundant)
```
Working implementations:
- core/compiler/emit.l (main backend)
- emit-c.l (C backend)
- backend-selection.l (selection logic)

Redundant/experimental:
- emit-backend-selection-patch.l
- test-backend-selection.l
- 15+ emit-* variants in core/compiler/
- 20+ experimental emit files
```

#### eval2 Related Files (30+ variants)
```
Current: eval2.c (generated)
Redundant: eval2-*.c files (manual variants)
Analysis: eval2-features-analysis.l, eval2-utf8-integration-plan.l
Archive: Multiple eval2 experiments
```

#### Test File Proliferation (200+ files)
```
Structure:
- tests/archive/ (100+ old test files)
- tests/backends/ (30+ backend tests)
- tests/emit-c/ (10+ emit-c tests)
- tests/threaded-c/ (15+ threaded tests)
- tests/infrastructure/ (25+ basic tests)
- tests/evaluation/ (20+ eval tests)

Issues:
- Many tests are duplicates or near-duplicates
- Test organization doesn't match current codebase structure
- Archive tests may no longer be relevant
```

#### Documentation Duplication (50+ files)
```
Root level: 26 .md files
doc/ directory: 15+ files
archive/documentation/: 25+ files

Overlapping content:
- Multiple README files
- Repeated implementation summaries
- Scattered architecture docs
```

## Cleanup Strategy

### Phase 1: Safe Consolidation (Conservative)

#### A. Root Directory Cleanup
**Move to appropriate locations**:
```bash
# Move analysis/discovery files
discover-system.l → tools/analysis/
explore-globals.l → tools/analysis/
metacircular-discovery.l → tools/analysis/
eval-introspection.l → tools/analysis/

# Move test files
simple-test.l → tests/basic/
port-dispatch-concept.l → tests/concepts/

# Move feature analysis
eval2-features-analysis.l → doc/analysis/
eval2-utf8-integration-plan.l → doc/plans/

# Move prototype files
mach-o-writer.l → prototypes/
show-externs.l → tools/debug/
```

#### B. Backend File Consolidation
**Keep active implementations**:
- `core/compiler/emit.l` (main backend with selection)
- `emit-c.l` (C backend implementation)

**Archive redundant variants**:
```bash
# Move to archive
core/compiler/emit-c-*.l → archive/backends/emit-c/
core/compiler/emit-*backend*.l → archive/backends/
core/compiler/emit-threaded*.l → archive/backends/threaded/
```

#### C. Test Organization
**Consolidate test structure**:
```bash
tests/
├── unit/           # Atomic unit tests
├── integration/    # Cross-component tests  
├── backends/       # Backend-specific tests (keep essential only)
├── regression/     # Regression test suite
└── archive/        # Historical tests (compress)
```

**Remove redundant tests**:
- Duplicate emit-c test files
- Obsolete threaded-c tests
- Non-functional archive tests

#### D. Documentation Consolidation
**Merge overlapping docs**:
```bash
# Consolidate implementation docs
*-COMPLETE.md → doc/implementation/
*-SUMMARY.md → doc/summaries/
*-ANALYSIS.md → doc/analysis/

# Remove redundant READMEs
Keep: README.md (main), arch/README.md, compilers/nile/README.md
Archive: All other README files
```

### Phase 2: Structural Reorganization

#### A. Proposed Directory Structure
```
maru/
├── src/                    # Active source code
│   ├── core/              # Core compiler (boot.l, eval.l)
│   ├── backends/          # Code generation backends
│   ├── lib/               # Standard libraries
│   └── tools/             # Development utilities
├── tests/                 # Organized test suite
├── doc/                   # Consolidated documentation
├── examples/              # Usage examples
├── archive/               # Historical/experimental code
├── build/                 # Generated files (git-ignored)
└── tools/                 # Build and development scripts
```

#### B. Core File Mapping
```bash
# Core files (keep in place)
boot.l → src/core/boot.l
eval.l → src/core/eval.l
core/compiler/emit.l → src/backends/emit.l

# Backend files
emit-c.l → src/backends/emit-c.l
backend-selection.l → src/backends/selection.l

# Generated files (move to build/)
eval2.c → build/eval2.c
*.o, *.dSYM → build/
```

### Phase 3: Advanced Cleanup (Aggressive)

#### A. Dead Code Elimination
**Candidates for removal**:
- Experimental files with no clear purpose
- Duplicate implementations
- Failed prototype attempts
- Obsolete format converters

#### B. Code Deduplication
**Merge similar implementations**:
- Consolidate emit-c variants into single configurable backend
- Merge overlapping test utilities
- Unify documentation formats

#### C. Build System Modernization
- Move all generated files to build/
- Update .gitignore for new structure
- Simplify Makefile targets

## Risk Assessment

### Low Risk Operations
- Moving files to archive/
- Consolidating documentation
- Organizing tests without deletion
- Moving development tools

### Medium Risk Operations  
- Deleting redundant test files
- Removing experimental code
- Merging similar implementations

### High Risk Operations
- Deleting core functionality
- Changing file organization that affects Makefile
- Removing files referenced by other parts

## Implementation Plan

### Step 1: Analysis and Backup (DONE)
- ✅ Comprehensive file inventory
- ✅ Dependency analysis
- ✅ Risk assessment

### Step 2: Safe Moves (Next)
- Move obvious development artifacts
- Consolidate documentation
- Organize test files

### Step 3: Redundancy Removal
- Archive duplicate implementations
- Remove dead experimental code
- Clean up generated files

### Step 4: Structure Reorganization
- Implement new directory structure
- Update build system
- Validate functionality

## Immediate Actions Recommended

1. **Create archive structure** for safe storage
2. **Move development tools** out of root
3. **Consolidate documentation** into doc/
4. **Clean up test redundancy** while preserving functionality
5. **Organize backend files** by purpose

## Success Metrics

- **Root directory**: Reduce from 74 to <20 items
- **Documentation**: Consolidate 50+ docs into organized structure
- **Test files**: Reduce redundancy while maintaining coverage
- **Backend files**: Clear separation of active vs. experimental
- **Build artifacts**: Move to dedicated build/ directory

This cleanup will significantly improve project navigability and maintainability while preserving all essential functionality and history.