# Maru Project Cleanup Report

## Executive Summary

The Maru project has grown organically and accumulated many experimental files, duplicates, and obsolete code. This cleanup plan focuses on organizing the codebase while preserving functionality and history.

## Identified Issues

### 1. Test File Proliferation in Root Directory
**Files to move/remove:**
- `test-*.l` files in root (13 files)
- These are development artifacts from recent work
- Should be moved to appropriate test directories or removed if obsolete

### 2. Experimental Backend Files
**Duplicates and experiments:**
- `emit-c.l` (root) - appears to be the old C backend with assembly instructions
- `emit-clean.l` - unclear purpose, needs investigation
- `backend-selection.l` - likely superseded by multimethod dispatch

### 3. Core Compiler Directory Issues
**Files needing consolidation:**
- `emit-c-proper.l` - proof of concept, superseded by backend-dispatch.l
- `gen-c-proper.l` - proof of concept, superseded by backend-dispatch.l
- `gen-multimethod.l` - experimental, superseded by backend-dispatch.l
- `emit-c-multimethod.l` - early attempt, superseded

### 4. Archive Directory is Well-Organized
The archive/ directory properly contains historical experiments and documentation.

## Cleanup Plan

### Phase 1: Test Files (Safe)
Move test files from root to appropriate locations:

```bash
# Create tests/recent directory for recent development tests
mkdir -p tests/recent

# Move test files
mv test-backend-check.l tests/recent/
mv test-c-backend.l tests/recent/
mv test-minimal.l tests/recent/
mv test-first-half.l tests/recent/
mv test-simple-c.l tests/recent/
mv test-arm64-emit.l tests/recent/
mv test-arm64-emit-simple.l tests/recent/
mv test-c-proper.l tests/recent/
mv test-c-proper-simple.l tests/recent/
mv test-c-multimethod.l tests/recent/
mv test-gen-multimethod.l tests/recent/
mv test-backend-dispatch.l tests/recent/
mv test-multimethod-comprehensive.l tests/recent/
```

### Phase 2: Obsolete Backend Files (Moderate Risk)
Archive obsolete backend implementations:

```bash
# Create archive location
mkdir -p archive/backends/multimethod-development

# Move superseded files
mv core/compiler/emit-c-proper.l archive/backends/multimethod-development/
mv core/compiler/gen-c-proper.l archive/backends/multimethod-development/
mv core/compiler/gen-multimethod.l archive/backends/multimethod-development/
mv core/compiler/emit-c-multimethod.l archive/backends/multimethod-development/
```

### Phase 3: Root Directory Cleanup (Moderate Risk)
Move experimental files from root:

```bash
# Archive old C backend
mv emit-c.l archive/backends/emit-c-variants/emit-c-assembly-style.l

# Investigate and potentially remove
# emit-clean.l - needs investigation first
# backend-selection.l - check if still needed
```

### Phase 4: Documentation Consolidation (Safe)
- Keep recent documentation in doc/
- Ensure all markdown files are properly categorized

## Files to Investigate Before Removal

1. **emit-clean.l** - Purpose unclear, needs code review
2. **backend-selection.l** - May contain useful environment variable logic
3. **boot2.l** - Relationship to boot.l needs clarification

## Recommendations

### Immediate Actions (Safe)
1. Move all test-*.l files from root to tests/recent/
2. Create README in tests/recent/ explaining these are from multimethod development

### Short Term (This Week)
1. Archive superseded proof-of-concept files
2. Review and consolidate emit variants
3. Update documentation to reflect new structure

### Long Term
1. Implement consistent naming convention
2. Create development guidelines for future work
3. Set up CI to prevent test file accumulation in root

## Impact Assessment

### Low Risk
- Moving test files - purely organizational
- Archiving clearly superseded files

### Medium Risk  
- Removing emit-c.l from root (ensure nothing depends on it)
- Consolidating backend files

### High Risk
- None identified - all critical functionality preserved

## Validation Steps

After each phase:
1. Run `make clean && make`
2. Run `make test`
3. Test eval and eval2 generation
4. Verify multimethod dispatch still works

## Summary Statistics

- **Files in root to move**: 13 test files + 3 experimental files
- **Files in core/compiler to archive**: 4 proof-of-concept files  
- **Total files to reorganize**: ~20
- **Estimated space saved**: Minimal (files archived, not deleted)
- **Code clarity improvement**: Significant

This cleanup will significantly improve code organization without losing any functionality or history.