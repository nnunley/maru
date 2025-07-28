# Maru Cleanup Status Report

## Phase 1: Test File Organization - COMPLETED ✓

### Actions Taken
- Successfully moved 13 test-*.l files from root to tests/recent/
- Created README.md in tests/recent/ documenting the files
- All test files preserved and organized

### Files Moved
1. test-backend-check.l
2. test-c-backend.l  
3. test-minimal.l
4. test-first-half.l
5. test-simple-c.l
6. test-arm64-emit.l
7. test-arm64-emit-simple.l
8. test-c-proper.l
9. test-c-proper-simple.l
10. test-c-multimethod.l
11. test-gen-multimethod.l
12. test-backend-dispatch.l
13. test-multimethod-comprehensive.l

## Phase 2: Backend File Consolidation - BLOCKED ⚠️

### Issue Discovered
During build verification after Phase 1, we discovered:

1. **Build System Issue**: The emit system has an error that prevents eval2.c generation
   - Error: "cannot apply: ()" when using C backend
   - Error: "selector gen has no method for <fixed>" when using assembly backend
   
2. **emit-c.l in root**: This file is NOT the old assembly-style backend as initially thought
   - It's actually a comprehensive multimethod-based C backend
   - Contains sophisticated two-pass compilation
   - May be important - needs investigation before archiving

3. **core/compiler/emit-c.l Issue**: Had to fix c-emitln definition order

### Current State
- Root directory is cleaner (13 fewer test files)
- Build system needs fixing before continuing with Phase 2
- emit-c.l in root needs careful investigation

## Recommendations

### Immediate Actions
1. **Fix Build System** - Priority 1
   - Investigate why gen has no method for <fixed> types
   - This may be related to eval.l using Fixed forms
   - Need to ensure emit-x86.l can handle these types

2. **Investigate emit-c.l in root** - Priority 2
   - Compare with core/compiler/emit-c.l
   - Determine which is the intended implementation
   - Document findings before making any moves

3. **Hold Phase 2** - Until build is working
   - Don't move any more files until we understand the dependencies
   - The build must work after each change

### Root Cause Analysis
The build failure appears to be because:
1. eval.l uses Fixed forms (Fixed<let>, Fixed<if>, etc.)
2. The emit system doesn't have gen methods for <fixed> type
3. This suggests a mismatch between what eval.l generates and what emit expects

## Files Still in Root (not moved)
- emit-c.l - Multimethod C backend (needs investigation)
- emit-clean.l - Backend selection logic
- backend-selection.l - Environment variable backend selection
- boot.l, eval.l - Core files (should stay)

## Conclusion
Phase 1 cleanup was successful and the test files are now properly organized. However, we've uncovered a build system issue that must be resolved before continuing with Phase 2. The discovery of emit-c.l being a sophisticated multimethod implementation rather than old code means we need to be more careful about what gets archived.