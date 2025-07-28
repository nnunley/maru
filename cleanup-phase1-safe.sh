#!/bin/bash
# Phase 1: Safe cleanup - Move test files from root to organized locations
# This script only moves files, preserving all functionality

set -e  # Exit on error

echo "=== Maru Cleanup Phase 1: Test File Organization ==="
echo "This script will move test files from root to tests/recent/"
echo "No files will be deleted, only reorganized."
echo

# Create target directory
echo "Creating tests/recent directory..."
mkdir -p tests/recent

# Create README for the directory
cat > tests/recent/README.md << 'EOF'
# Recent Test Files

This directory contains test files from the multimethod backend dispatch development.

## Test Files

- `test-backend-check.l` - Basic backend checking
- `test-c-backend.l` - C backend tests
- `test-minimal.l` - Minimal test cases
- `test-first-half.l` - Partial emit testing
- `test-simple-c.l` - Simple C generation
- `test-arm64-emit.l` - ARM64 emit testing
- `test-arm64-emit-simple.l` - Simplified ARM64 tests
- `test-c-proper.l` - Proper C generation tests
- `test-c-proper-simple.l` - Simplified proper C tests
- `test-c-multimethod.l` - Multimethod C backend tests
- `test-gen-multimethod.l` - Gen multimethod tests
- `test-backend-dispatch.l` - Backend dispatch system tests
- `test-multimethod-comprehensive.l` - Comprehensive multimethod tests

These tests were created during the development of the multimethod backend
dispatch system and demonstrate various aspects of the implementation.
EOF

echo "Moving test files..."

# Array of test files to move
test_files=(
    "test-backend-check.l"
    "test-c-backend.l"
    "test-minimal.l"
    "test-first-half.l"
    "test-simple-c.l"
    "test-arm64-emit.l"
    "test-arm64-emit-simple.l"
    "test-c-proper.l"
    "test-c-proper-simple.l"
    "test-c-multimethod.l"
    "test-gen-multimethod.l"
    "test-backend-dispatch.l"
    "test-multimethod-comprehensive.l"
)

# Move each file if it exists
moved_count=0
for file in "${test_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  Moving $file to tests/recent/"
        mv "$file" tests/recent/
        ((moved_count++))
    else
        echo "  Warning: $file not found (may have been moved already)"
    fi
done

echo
echo "=== Summary ==="
echo "Moved $moved_count test files to tests/recent/"
echo "Created README.md in tests/recent/"
echo

# Verification
echo "=== Verification ==="
echo "Files now in tests/recent/:"
ls -la tests/recent/*.l 2>/dev/null | wc -l
echo

echo "=== Next Steps ==="
echo "1. Run 'make clean && make' to ensure build still works"
echo "2. Run 'make test' to verify tests still pass"
echo "3. Review tests/recent/README.md for accuracy"
echo "4. Consider running cleanup-phase2.sh for backend file consolidation"
echo
echo "Phase 1 cleanup complete!"