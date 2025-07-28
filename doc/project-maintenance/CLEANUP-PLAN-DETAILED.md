# Maru Project Cleanup Plan - Implementation Details

## Phase 1: Safe Cleanup Operations (Conservative)

### 1.1 Create Archive Structure

First, create organized archive directories:

```bash
mkdir -p archive/development-tools
mkdir -p archive/backends/emit-c-variants
mkdir -p archive/backends/threaded
mkdir -p archive/backends/experimental
mkdir -p archive/documentation/summaries
mkdir -p archive/documentation/analysis
mkdir -p archive/tests/obsolete
mkdir -p archive/experiments/root-level
```

### 1.2 Root Directory Cleanup

**Development and Analysis Tools** (Move to archive/development-tools/):
- `discover-system.l`
- `explore-globals.l` 
- `metacircular-discovery.l`
- `eval-introspection.l`
- `show-externs.l`

**Test and Experimental Files** (Move to archive/experiments/root-level/):
- `simple-test.l`
- `port-dispatch-concept.l`
- `mach-o-writer.l` (prototype)

**Analysis Files** (Move to doc/analysis/):
- `eval2-features-analysis.l`
- `eval2-utf8-integration-plan.l`

**Backend Selection Files** (Keep, but consolidate):
- Keep: `backend-selection.l` (working implementation)
- Archive: `emit-backend-selection-patch.l`, `test-backend-selection.l`

### 1.3 Redundant emit-c File Cleanup

**Core Implementation Files** (Keep):
```
emit-c.l (root) - Main C backend
core/compiler/emit.l - Main backend with selection
```

**Redundant Backend Files** (Move to archive/backends/):
```bash
# emit-c variants in core/compiler/
core/compiler/emit-c-*.l → archive/backends/emit-c-variants/
core/compiler/emit-*backend*.l → archive/backends/
core/compiler/emit-threaded*.l → archive/backends/threaded/
core/compiler/emit-unified.l → archive/backends/
core/compiler/emit-new.l → archive/backends/
core/compiler/emit-modular.l → archive/backends/
```

**Experimental Files** (Already in archive/experimental/ - organize better):
```bash
# Group threaded experiments
archive/experimental/emit-c-threaded*.l → archive/backends/threaded/
archive/experimental/*threaded*.l → archive/backends/threaded/
```

### 1.4 Documentation Consolidation

**Summary Documents** (Merge into single files):
```bash
# Implementation summaries
*-COMPLETE.md → doc/implementation/
*-SUMMARY.md → doc/summaries/
IMPLEMENTATION-SUMMARY.md → doc/implementation/overview.md
```

**Analysis Documents**:
```bash
*-ANALYSIS.md → doc/analysis/
VPRI-MARU-ANALYSIS.md → doc/analysis/vpri-comparison.md
NILE-MARU-ANALYSIS.md → doc/analysis/nile-integration.md
```

**Design Documents**:
```bash
*-DESIGN.md → doc/design/
C-THREADED-INTEGRATION-DESIGN.md → doc/design/threaded-integration.md
```

### 1.5 Test File Organization

**Archive Obsolete Tests**:
```bash
# Move clearly obsolete tests
tests/archive/ → archive/tests/obsolete/
tests/threaded-c/ → archive/tests/threaded/ (keep 2-3 essential)
```

**Consolidate Backend Tests**:
```bash
# Keep essential backend tests, archive duplicates
tests/backends/test-emit-c*.l → Keep test-emit-c.l, archive others
tests/emit-c/ → Keep directory but reduce redundancy
```

## Phase 2: Structural Improvements

### 2.1 Build Directory Creation

```bash
mkdir -p build/generated
mkdir -p build/objects
mkdir -p build/temp

# Move generated files
*.o → build/objects/
*.dSYM → build/temp/
eval2.c → build/generated/ (update Makefile)
```

### 2.2 Tool Organization

```bash
mkdir -p tools/analysis
mkdir -p tools/build
mkdir -p tools/development

# Move analysis tools
archive/development-tools/*.l → tools/analysis/

# Move build scripts
*.sh → tools/build/
mkosdefs → tools/build/
```

### 2.3 Clean Up Generated/Temporary Files

**Safe to Remove** (can be regenerated):
```bash
eval2-*.c (except eval2.c)
*.o files
*.dSYM directories
temp build artifacts
```

## Phase 3: File-by-File Analysis

### 3.1 Root Directory Files Status

**Core Files** (Keep in place):
- `boot.l` - Core bootstrap
- `eval.l` - Main evaluator
- `emit-c.l` - C backend implementation
- `backend-selection.l` - Backend selection logic
- `Makefile` - Build system

**Generated Files** (Move to build/):
- `eval2.c` - Generated evaluator
- `eval` (executable)
- `buffer.c`, `gc.c`, `wcs.c` - Generated C files

**Archive Candidates**:
- `boot2.l` - Secondary bootstrap (experimental?)
- Development tools and analysis files
- Test files and prototypes

### 3.2 Core Directory Analysis

**Keep Structure**:
```
core/
├── compiler/emit.l (main backend)
├── eval.l (keep if different from root)
├── maru.k, osdefs.k (platform files)
└── Other essential core files
```

**Archive Redundant**:
- Multiple emit-* variants
- Experimental compiler files
- Duplicate implementations

## Phase 4: Implementation Steps

### Step 1: Create Backup
```bash
# Create comprehensive backup before any changes
tar -czf maru-cleanup-backup-$(date +%Y%m%d).tar.gz .
```

### Step 2: Create New Structure
```bash
# Create all needed directories
mkdir -p {archive,tools,doc}/{development-tools,backends,analysis,design}
mkdir -p build/{generated,objects,temp}
```

### Step 3: Safe Moves (Files we're confident about)
```bash
# Move obvious development artifacts
mv discover-system.l archive/development-tools/
mv explore-globals.l archive/development-tools/
mv metacircular-discovery.l archive/development-tools/
mv eval-introspection.l archive/development-tools/
mv show-externs.l archive/development-tools/

# Move prototypes
mv mach-o-writer.l archive/experiments/
mv port-dispatch-concept.l archive/experiments/

# Move test files
mv simple-test.l archive/experiments/
```

### Step 4: Documentation Consolidation
```bash
# Move analysis docs
mv eval2-features-analysis.l doc/analysis/
mv eval2-utf8-integration-plan.l doc/analysis/

# Consolidate summaries
mv *-SUMMARY.md doc/summaries/
mv *-COMPLETE.md doc/implementation/
mv *-ANALYSIS.md doc/analysis/
```

### Step 5: Backend Cleanup
```bash
# Archive redundant backend files
mv core/compiler/emit-c-*.l archive/backends/emit-c-variants/
mv core/compiler/emit-*backend*.l archive/backends/
mv core/compiler/emit-threaded*.l archive/backends/threaded/
```

### Step 6: Test Cleanup
```bash
# Archive obsolete tests
mv tests/archive/* archive/tests/obsolete/
# Keep tests/backends/, tests/emit-c/ but reduce redundancy
```

## Validation Steps

After each phase:

1. **Verify Build System**:
   ```bash
   make clean && make eval
   ./eval boot.l
   ```

2. **Test Core Functionality**:
   ```bash
   ./eval simple-test.l  # If kept
   make eval2
   ./eval2 boot.l
   ```

3. **Validate Backend Selection**:
   ```bash
   MARU_EMIT_BACKEND=c ./eval core/compiler/emit.l core/eval.l > test.c
   ```

## Risk Mitigation

1. **Incremental Changes**: Implement one section at a time
2. **Backup Strategy**: Full backup before starting
3. **Git Commits**: Commit each logical group of changes
4. **Testing**: Validate build/functionality after each phase
5. **Rollback Plan**: Keep backup and git history for rollback

## Success Criteria

- Root directory reduced from 74 to <20 items
- Clear separation of active vs. archived code
- Build system continues to work
- All essential functionality preserved
- Improved project navigability
- Organized documentation structure

## Files Recommended for Immediate Archival

**High Confidence** (very safe to move):
- Development/analysis tools in root
- Experimental prototypes
- Duplicate backend implementations
- Obsolete test files
- Redundant documentation

**Medium Confidence** (need validation):
- Some emit-c variants
- Secondary bootstrap files
- Test file consolidation

**Keep for Review** (need investigation):
- Files referenced by Makefile
- Core implementation files
- Currently working backends