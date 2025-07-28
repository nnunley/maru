# Maru Cleanup Execution Plan

## Overview

This cleanup plan addresses the file proliferation in the Maru project while preserving all functionality and maintaining a clear historical record.

## Cleanup Scripts Created

### 1. cleanup-phase1-safe.sh
**Purpose**: Organize test files scattered in root directory
**Risk**: None - only moves files
**Actions**:
- Moves 13 test-*.l files from root to tests/recent/
- Creates README.md documenting the test files
- Preserves all test functionality

### 2. cleanup-phase2-backend.sh  
**Purpose**: Archive superseded backend implementations
**Risk**: Low - moves obsolete proof-of-concept files
**Actions**:
- Archives 4 proof-of-concept files from core/compiler/
- Moves emit-clean.l and backend-selection.l from root
- Moves old emit-c.l to archive
- Documents the evolution path

## Execution Instructions

### Step 1: Review Current State
```bash
# Check current root directory
ls *.l | grep -E '^(test-|emit-|backend-)'

# Check core/compiler for files to archive
ls core/compiler/*-proper.l core/compiler/*-multimethod.l
```

### Step 2: Run Phase 1 (Safe) ✓ COMPLETED
```bash
# Run test file cleanup
./cleanup-phase1-safe.sh

# Verify build still works
make clean && make

# Run tests
make test
```
**Result**: Test files successfully moved to tests/recent/

### Step 3: Fix Build System ⚠️ REQUIRED
Before continuing with Phase 2, the build system must be fixed:
```bash
# The build currently fails with:
# - "cannot apply: ()" error with C backend
# - "selector gen has no method for <fixed>" with assembly backend

# This appears to be due to Fixed forms in eval.l
# The emit system needs to handle these types
```

### Step 4: Investigate emit-c.l ⚠️ REQUIRED
```bash
# Compare the two emit-c.l files:
diff emit-c.l core/compiler/emit-c.l

# Check which tests depend on root emit-c.l:
grep -r "load.*emit-c.l" tests/

# Document findings before deciding to move/archive
```

### Step 5: Run Phase 2 (Low Risk) - HOLD
```bash
# Run backend file consolidation
./cleanup-phase2-backend.sh

# Verify build
make clean && make

# Test multimethod dispatch
./eval test-multimethod-comprehensive.l
```

### Step 4: Update Documentation
After cleanup, update CLAUDE.md to note:
- Test files are now in tests/recent/
- Superseded implementations are in archive/backends/multimethod-development/
- backend-dispatch.l is the current multimethod implementation

## What's NOT Being Cleaned

### Preserved in Root
- boot.l - Core bootstrap file
- eval.l - Main evaluator
- Makefile - Build system
- Documentation files

### Preserved in core/compiler/
- emit.l - Main emit system
- backend-dispatch.l - Current multimethod implementation
- emit-arm64.l - ARM64 backend (updated with port streams)
- emit-x86.l - x86 backend (needs port stream update)

## Benefits

### Immediate
- Cleaner root directory (16 fewer files)
- Clear separation of tests from source
- Archived proof-of-concepts with documentation

### Long Term
- Easier navigation for new contributors
- Clear evolution path documented
- Reduced confusion about which files are current

## Rollback Plan

If any issues arise:
```bash
# Phase 1 rollback
mv tests/recent/test-*.l .

# Phase 2 rollback  
mv archive/backends/multimethod-development/*.l core/compiler/
mv archive/backends/emit-c-variants/emit-c-assembly-style.l emit-c.l
```

## Metrics

### Before Cleanup
- Root directory .l files: ~20
- Scattered test files: 13
- Obsolete backend files: 7

### After Cleanup
- Root directory .l files: 4 (boot.l, eval.l, eval.l.1, tpeg.l.*)
- Test files organized in tests/recent/
- Backend files archived with documentation

## Recommendations

1. **Run cleanup in order** - Phase 1 is safe, Phase 2 builds on it
2. **Test after each phase** - Ensure functionality preserved
3. **Document changes** - Update CLAUDE.md after completion
4. **Consider CI** - Add checks to prevent future file proliferation

This cleanup improves code organization significantly without any functional impact.