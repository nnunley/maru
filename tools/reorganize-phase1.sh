#!/bin/bash
# Maru Project Reorganization - Phase 1 Implementation Script
# This script creates the new directory structure and provides guidance for migration

set -e  # Exit on error

echo "=== Maru Project Reorganization - Phase 1 ==="
echo "This script will create the new directory structure."
echo "File movement should be done carefully using git mv."
echo ""

# Check if we're in the maru directory
if [ ! -f "boot.l" ] || [ ! -f "emit.l" ]; then
    echo "ERROR: This script must be run from the maru root directory"
    exit 1
fi

echo "Creating new directory structure..."

# Create core directories
mkdir -p core
mkdir -p src/{features,backends,lib}
mkdir -p build/{generated,binaries,intermediates}
mkdir -p tests/{unit,integration,regression,experiments,fixtures}
mkdir -p experiments
mkdir -p tools/{bootstrap,analysis,migration}
mkdir -p examples/{basic,advanced,tutorials}

# Create feature subdirectories
mkdir -p src/features/port-streams/{tests,examples,docs}
mkdir -p src/features/peg-compiler/{tests,examples,docs}
mkdir -p src/features/dotted-access/{tests,examples,docs,debug}
mkdir -p src/features/multimethod/{tests,examples,docs}

# Create backend subdirectories
mkdir -p src/backends/c-backend/variants
mkdir -p src/backends/threaded-backend/variants
mkdir -p src/backends/ir-backend/variants

# Create test subdirectories
mkdir -p tests/unit/{core,emit,eval,lib}
mkdir -p tests/integration/{bootstrap,features}

# Create experiment organization
mkdir -p experiments/{debug-scripts,analysis-scripts,validation-scripts}
mkdir -p experiments/{2023-10-emit-legacy,2023-11-emit-split,2023-12-mini-eval}
mkdir -p experiments/{2024-01-eval-threading,2024-01-simple-variants}

# Create documentation structure
mkdir -p doc/architecture/{arm64,x86,cross-compilation}
mkdir -p doc/{development,api,historical}

echo "✅ Directory structure created successfully!"
echo ""

# Create .gitignore for build directory
cat > build/.gitignore << 'EOF'
# Ignore all generated files
*
!.gitignore
!README.md
EOF

echo "✅ Created build/.gitignore"

# Create README files for key directories
cat > core/README.md << 'EOF'
# Core Compiler Components

This directory contains the stable, production-ready core of the Maru compiler.

## Files

- `boot.l` - Bootstrap definitions and core language constructs
- `emit.l` - Current stable code emitter
- `eval.l` - Current stable evaluator
- `eval.k` - Compiled evaluator
- `buffer.l` - Buffer management
- `gc.l` - Garbage collector
- `osdefs.l` - Operating system definitions

## Guidelines

- Only stable, well-tested code belongs here
- Changes require thorough testing with bootstrap
- Maintain backward compatibility
- Document any breaking changes
EOF

cat > src/README.md << 'EOF'
# Active Development

This directory contains code under active development.

## Structure

- `features/` - New features being developed
- `backends/` - Code generation backend variants
- `lib/` - Library extensions

## Guidelines

- Each feature should have its own subdirectory
- Include tests and documentation with features
- Use STATUS.md to indicate development state
- Move to core/ only when stable and tested
EOF

cat > experiments/README.md << 'EOF'
# Experimental Code

This directory contains experimental code and prototypes.

## Organization

- Use date-prefixed directories (YYYY-MM-description)
- Include README in each experiment explaining purpose
- Archive rather than delete failed experiments
- Document lessons learned

## Guidelines

- Experiments should not affect core functionality
- Use git branches for version control
- Clean up successful experiments by moving to src/
EOF

cat > tests/README.md << 'EOF'
# Test Suite

Comprehensive test suite for the Maru compiler.

## Structure

- `unit/` - Unit tests for individual components
- `integration/` - Integration tests
- `regression/` - Regression test suite
- `experiments/` - Experimental test code
- `fixtures/` - Test data and helpers

## Running Tests

```bash
# Run all tests
make test

# Run specific test suite
./eval tests/unit/core/test-boot.l
```

## Guidelines

- Write tests for all new features
- Add regression tests for bug fixes
- Keep tests focused and fast
- Document complex test scenarios
EOF

echo "✅ Created README files for main directories"
echo ""

# Create migration checklist
cat > MIGRATION-CHECKLIST.md << 'EOF'
# Maru Reorganization Migration Checklist

## Phase 1: Foundation ✅
- [x] Create directory structure
- [x] Create .gitignore for build/
- [x] Create README files
- [ ] Backup current state (git tag)
- [ ] Create migration branch

## Phase 2: Core Files
- [ ] Move boot.l → core/boot.l
- [ ] Move emit.l → core/emit.l  
- [ ] Move eval.l → core/eval.l
- [ ] Move eval.k → core/eval.k
- [ ] Move buffer.l → core/buffer.l
- [ ] Move gc.l → core/gc.l
- [ ] Move osdefs.l → core/osdefs.l
- [ ] Update load paths in boot.l

## Phase 3: Feature Organization
- [ ] Move port stream files to src/features/port-streams/
- [ ] Move PEG files to src/features/peg-compiler/
- [ ] Move dotted access files to src/features/dotted-access/
- [ ] Update require/load paths

## Phase 4: Backend Consolidation
- [ ] Identify current production emit version
- [ ] Move emit variants to src/backends/
- [ ] Archive obsolete versions
- [ ] Update Makefile

## Phase 5: Test Organization
- [ ] Move unit tests to tests/unit/
- [ ] Move integration tests to tests/integration/
- [ ] Create test runner for new structure
- [ ] Verify all tests pass

## Phase 6: Cleanup
- [ ] Move generated files to build/
- [ ] Delete temporary files (after backup)
- [ ] Update .gitignore
- [ ] Update all documentation

## Phase 7: Validation
- [ ] Bootstrap works: make clean && make
- [ ] All tests pass: make test
- [ ] Cross-platform builds work
- [ ] Documentation is current

## Important Reminders
- Use `git mv` to preserve history
- Test after each major change
- Update imports atomically
- Document all changes in MIGRATION-GUIDE.md
EOF

echo "✅ Created MIGRATION-CHECKLIST.md"
echo ""

echo "=== Next Steps ==="
echo "1. Review the created directory structure"
echo "2. Create a git tag for current state: git tag pre-reorganization"
echo "3. Create a new branch: git checkout -b reorganization"
echo "4. Start moving files according to MIGRATION-MAPPING.md"
echo "5. Use MIGRATION-CHECKLIST.md to track progress"
echo ""
echo "Remember:"
echo "- Use 'git mv' to preserve history"
echo "- Test frequently during migration"
echo "- Update import paths as you go"
echo ""
echo "Good luck with the reorganization!"