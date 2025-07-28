#!/bin/bash
# Phase 2: Backend file consolidation - Archive superseded implementations
# This script archives proof-of-concept files that have been superseded

set -e  # Exit on error

echo "=== Maru Cleanup Phase 2: Backend File Consolidation ==="
echo "This script will archive superseded proof-of-concept backend files"
echo "No files will be deleted, only moved to archive/"
echo

# Create archive directory
echo "Creating archive directory for multimethod development..."
mkdir -p archive/backends/multimethod-development

# Create README for the archive
cat > archive/backends/multimethod-development/README.md << 'EOF'
# Multimethod Backend Development Archive

This directory contains proof-of-concept and experimental implementations
that led to the final multimethod backend dispatch system.

## Archived Files

### Proof of Concept Files
- `emit-c-proper.l` - Early proof-of-concept for proper C generation
- `gen-c-proper.l` - Proof-of-concept for gen-level C generation
- `gen-multimethod.l` - Experimental multimethod conversion of gen functions
- `emit-c-multimethod.l` - Early attempt at multimethod emit

### Evolution Path
1. Initial recognition of abstraction mismatch (emit-c with assembly instructions)
2. Proof-of-concept for proper C generation (emit-c-proper.l, gen-c-proper.l)
3. Experimental multimethod approach (gen-multimethod.l)
4. Early multimethod implementation (emit-c-multimethod.l)
5. Final implementation (backend-dispatch.l) - kept in core/compiler/

The final solution uses clean multimethod dispatch with backend objects,
providing proper abstraction for each target language.
EOF

echo "Archiving superseded backend files..."

# Files to archive from core/compiler/
backend_files=(
    "core/compiler/emit-c-proper.l"
    "core/compiler/gen-c-proper.l"
    "core/compiler/gen-multimethod.l"
    "core/compiler/emit-c-multimethod.l"
)

# Archive each file if it exists
archived_count=0
for file in "${backend_files[@]}"; do
    if [ -f "$file" ]; then
        echo "  Archiving $file"
        mv "$file" archive/backends/multimethod-development/
        ((archived_count++))
    else
        echo "  Warning: $file not found (may have been archived already)"
    fi
done

echo
echo "=== Root Directory Cleanup ==="

# Handle emit-clean.l and backend-selection.l
echo "Analyzing root directory files..."

# Check emit-clean.l
if [ -f "emit-clean.l" ]; then
    echo "  emit-clean.l appears to be an early backend selection implementation"
    echo "  Moving to archive as it's superseded by backend-dispatch.l"
    mv emit-clean.l archive/backends/multimethod-development/
    ((archived_count++))
fi

# Check backend-selection.l  
if [ -f "backend-selection.l" ]; then
    echo "  backend-selection.l contains environment variable selection logic"
    echo "  Moving to archive - this functionality should be in backend-dispatch.l"
    mv backend-selection.l archive/backends/multimethod-development/
    ((archived_count++))
fi

# Handle old emit-c.l
if [ -f "emit-c.l" ]; then
    echo "  emit-c.l is the old assembly-style C backend"
    echo "  Moving to archive/backends/emit-c-variants/"
    mkdir -p archive/backends/emit-c-variants
    mv emit-c.l archive/backends/emit-c-variants/emit-c-assembly-style.l
    ((archived_count++))
fi

echo
echo "=== Summary ==="
echo "Archived $archived_count backend-related files"
echo "Created documentation in archive/backends/multimethod-development/"
echo

echo "=== Verification ==="
echo "Remaining files in core/compiler/ related to emit:"
ls core/compiler/emit*.l core/compiler/gen*.l core/compiler/backend*.l 2>/dev/null || echo "None found"
echo

echo "=== Next Steps ==="
echo "1. Run 'make clean && make' to ensure build still works"
echo "2. Verify backend-dispatch.l has all needed functionality"
echo "3. Update any references to moved files"
echo "4. Consider adding environment variable support to backend-dispatch.l"
echo
echo "Phase 2 cleanup complete!"