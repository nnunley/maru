# Maru Project Cleanup Plan

## Overview
Project has accumulated 300+ experimental and test files during development. This plan systematically cleans up while preserving essential functionality.

## File Categories

### 🟢 PRESERVE (Core System)
```
boot.l boot2.l eval.l eval2.c port.l trie.k osdefs.k
core/compiler/emit.l core/compiler/emit-c-threaded.l 
CLAUDE.md README.md Makefile
grammars/ lib/ arch/ doc/
```

### 🟡 RELOCATE (Move to tests/ or archive/)
```
# ARM64 test suite (21 files)
test-arm64-*.l → tests/arm64/

# Threaded C test suite (15 files)  
test-threaded-*.l test-emit-c-threaded-*.l → tests/threaded-c/

# Evaluation system tests (18 files)
test-eval*.l test-evalm-*.l → tests/evaluation/

# Backend tests (12 files)
test-c-*.l test-backend-*.l → tests/backends/

# Infrastructure tests (25+ files)
test-simple-*.l test-minimal-*.l → tests/infrastructure/
```

### 🔴 REMOVE (Experimental/Duplicate)

#### Generated C Files (74 files)
```
eval-*.c evalm-*.c test-*.c simple-*.c clean-*.c final-*.c
(Keep only eval2.c and core generated files)
```

#### Executable Files (61 files)  
```
test-* eval-* unified-* simple-* clean-* final-*
(Remove build artifacts)
```

#### Experimental Source Files (100+ files)
```
compile-*.l debug-*.l simple-*.l working-*.l temp-*.l
generate-*.l meta-compile-*.l eval-style-*.l
```

#### Documentation Consolidation (8 files)
```
EVAL-*.md META-*.md TEST-*.md FINAL-*.md IR-*.md
→ Consolidate into comprehensive documentation
```

## Cleanup Strategy

### Phase 1: Safe Moves
1. Create organized test directory structure
2. Move categorized test files to appropriate subdirectories
3. Preserve all functionality while organizing structure

### Phase 2: Generated File Cleanup
1. Remove generated C files except eval2.c and core files
2. Remove executable build artifacts (can be regenerated)
3. Clean up object files and temporary outputs

### Phase 3: Experimental Code Cleanup
1. Archive or remove experimental source files
2. Keep only proven implementations
3. Consolidate multiple attempts into single working versions

### Phase 4: Documentation Consolidation
1. Merge analysis documents into comprehensive guides
2. Create focused documentation for key subsystems
3. Remove redundant documentation files

## Expected Results
- **From 300+ files → ~50 core files**
- **Organized test structure** in tests/ subdirectories  
- **Clean root directory** with only essential files
- **Preserved functionality** with better organization
- **Comprehensive documentation** without redundancy

## Risk Assessment
- **LOW RISK**: All core functionality preserved
- **BACKUP**: Git history maintains full recovery capability
- **TESTING**: Verify core builds work after cleanup
- **ROLLBACK**: Easy to restore from git if needed