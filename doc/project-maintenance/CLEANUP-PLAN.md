# Maru Project Cleanup Plan

## Overview
Systematic cleanup of development artifacts, redundant files, and organization improvements.

## **SAFE** - Ready for immediate cleanup:

### 1. Test Files (Root Directory)
**Files to archive:**
- `test-*.l` (11 files) → Move to `tests/emit-c/`
- `demo-*.l` (5 files) → Move to `examples/demos/`
- `*-demo.l` files → Move to `examples/demos/`

### 2. Design Documents (Root Directory)  
**Files to organize:**
- `emit-c-*.l` design files (9 files) → Move to `doc/design/emit-c/`
- `define-structure-*.l` (3 files) → Move to `doc/design/structures/`
- `*-vs-*.l` comparison files → Move to `doc/design/analysis/`

### 3. Verification Files
**Files to archive:**
- `verify-*.l` files → Move to `tests/verification/`
- `improved-*.l` files → Move to `doc/design/improvements/`

### 4. Redundant Documentation
**Files to consolidate:**
- Multiple README files with overlapping content
- Duplicate analysis documents in different locations

## **MODERATE RISK** - Requires validation:

### 5. Experimental Files
**Files to evaluate:**
- `archive/experimental/` - 80+ files, many likely obsolete
- `core/compiler/emit-*.l` variants (20+ files)
- Test files in `tests/archive/` with unclear status

### 6. Backend Implementations
**Files to consolidate:**
- Multiple `emit-c.l` variants in different directories
- ARM64 backend files with similar functionality
- X86 backend implementations

## **HIGH RISK** - Keep as-is:

### 7. Core System Files
**Never modify:**
- `boot.l`, `eval.l`, `emit.l` (main system)
- `lib/` directory (runtime libraries)
- `Makefile` and build system
- `CLAUDE.md` (project documentation)

## Recommended Actions

### Phase 1: Safe Reorganization
1. Create new directory structure:
   ```
   doc/design/
     emit-c/
     structures/
     analysis/
     improvements/
   examples/demos/
   tests/
     emit-c/
     verification/
   ```

2. Move files according to categories above
3. Update any references in documentation
4. Test build system still works

### Phase 2: Archive Cleanup  
1. Review `archive/experimental/` contents
2. Identify truly obsolete files
3. Move to timestamped archive or delete
4. Clean up test duplicates

### Phase 3: Documentation Consolidation
1. Merge redundant README files
2. Create comprehensive index
3. Remove outdated analysis documents
4. Update CLAUDE.md with new structure

## Safety Measures
- **Backup**: Full git commit before any changes
- **Incremental**: One category at a time
- **Validation**: Test build after each phase
- **Rollback**: Keep original structure documented

## Expected Benefits
- **Clarity**: Easier navigation for new contributors
- **Maintenance**: Reduced confusion about which files are current
- **Performance**: Fewer files in root directory
- **Organization**: Logical grouping by purpose

## Risk Assessment
- **Low**: File moves and documentation updates
- **Medium**: Archive cleanup and deduplication  
- **Zero**: No modification of core system files