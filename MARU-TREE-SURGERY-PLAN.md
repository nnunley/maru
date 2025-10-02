# Maru Tree Surgery Plan: Complete Archaeological Evolution

## Vision: Complete Lineage from Single File to Modern System

Create a complete archaeological record showing Maru's evolution from Ian Piumarta's original single-file implementation through VPRI's complete system to your modern enhancements.

## Current State Analysis

### Existing Resources
```
✅ version-2.1 branch    - Early Ian Piumarta release
✅ version-2.4 branch    - Official 77-file release (canonical)
✅ Current system        - Your enhanced organization + features
🔍 VPRI complete system  - 106 files (github.com/damelang/nile)
❌ v1.0 single file      - Missing (1750 lines from Ian's site)
```

### Missing Archaeological Layers
1. **v1.0 Single File** - Ian's original 1750-line implementation
2. **VPRI Complete** - The 106-file final VPRI system
3. **Evolution bridges** - Intermediate steps showing progression

## Complete Evolution Timeline

```
v1.0-single-file         # Ian's original (1750 lines, 1 file)
├── v1.1-bootstrap-split  # First separation: C runtime + Lisp boot
├── v2.0-compiler-birth   # Self-hosting capability emerges
├── v2.1-early-release    # Ian's first public multi-file release
├── v2.4-canonical        # Official 77-file system
├── v2.5-vpri-complete    # VPRI final (106 files) - THE COMPLETE SYSTEM
├── v3.0-organization     # Your directory restructuring
├── v3.1-cross-platform   # MARU_TARGET_ARCH system
├── v3.2-modern-features  # Port streams, PEG enhancements
└── v4.0-future          # JIT, advanced capabilities
```

## Tree Surgery Implementation Plan

### Phase 1: Resource Acquisition (Your Assistance Needed)

#### 1.1 Ian's Original Single File (v1.0)
**Your Task**: Download and provide the original single file

**Sources to Try**:
```bash
# Internet Archive
https://web.archive.org/*/piumarta.com/software/maru/

# Academic repositories
# GitHub archaeological search
# Direct Ian contact if possible
```

**Expected Structure**:
```c
// Target: ~1750 lines containing:
// - Complete evaluator in C
// - Embedded Lisp bootstrap as C string  
// - Garbage collector
// - Multi-method dispatch
// - Self-compilation capability
```

**File Naming**: Please save as `maru-1.0-original.c` when found

#### 1.2 VPRI Complete System
**My Task**: Clone from github.com/damelang/nile

```bash
git clone https://github.com/damelang/nile.git temp-nile
cp -r temp-nile/compilers/maru/maru vpri-complete/
```

### Phase 2: Branch Creation Strategy

#### 2.1 Create Evolution Branches
```bash
# Start from main branch as current state
git checkout main
git branch -b archaeological-timeline

# Create all evolution branches (empty initially)
git checkout --orphan v1.0-single-file
git checkout --orphan v1.1-bootstrap-split  
git checkout --orphan v2.0-compiler-birth
git checkout --orphan v2.1-early-release
git checkout --orphan v2.4-canonical
git checkout --orphan v2.5-vpri-complete
git checkout --orphan v3.0-organization
git checkout --orphan v3.1-cross-platform
git checkout --orphan v3.2-modern-features
git checkout --orphan v4.0-future
```

#### 2.2 Tag Strategy
```bash
# Each branch gets a corresponding tag for releases
git tag v1.0.0-single-file v1.0-single-file
git tag v1.1.0-bootstrap-split v1.1-bootstrap-split
git tag v2.0.0-compiler-birth v2.0-compiler-birth
git tag v2.1.0-early-release v2.1-early-release  
git tag v2.4.0-canonical v2.4-canonical
git tag v2.5.0-vpri-complete v2.5-vpri-complete
git tag v3.0.0-organization v3.0-organization
git tag v3.1.0-cross-platform v3.1-cross-platform
git tag v3.2.0-modern-features v3.2-modern-features
```

### Phase 3: Archaeological Population

#### 3.1 v1.0 Single File (Once You Provide It)
```bash
git checkout v1.0-single-file
# Add the single file you provide
cp /path/to/maru-1.0-original.c .
echo "# Maru v1.0 - Ian Piumarta's Original Single File" > README.md
echo "Complete metacircular compiler in ~1750 lines of C" >> README.md
git add .
git commit -m "Add Ian Piumarta's original single-file Maru implementation

- Complete evaluator, GC, and compiler in one C file
- Self-hosting capability embedded as C strings
- Foundation for all future Maru development
- Historical artifact: birth of Maru metacircular compiler"
```

#### 3.2 v1.1 Bootstrap Split (Reconstruction)
```bash
git checkout v1.1-bootstrap-split
# Create minimal C evaluator + separate boot.l
cat > boot-eval.c << 'EOF'
/* Minimal C evaluator for boot.l - extracted from single file */
#include <stdio.h>
#include <stdlib.h>
// Basic evaluator implementation...
EOF

cat > boot.l << 'EOF'
;; Basic Lisp definitions separated from C
(define-form quote (expression) ...)
(define-form define-form (name args . body) ...)
EOF

cat > Makefile << 'EOF'
boot-eval: boot-eval.c
	gcc -o boot-eval boot-eval.c
EOF
```

#### 3.3 v2.0 Compiler Birth (Reconstruction)
```bash
git checkout v2.0-compiler-birth
# Add emit.l capability - birth of self-hosting
cp ../v1.1-bootstrap-split/* .
cat > emit.l << 'EOF'
;; First code generation capability
;; Enables compilation of eval.l from Lisp
(define-function emit-expression (expr) ...)
EOF
```

#### 3.4 v2.1 Early Release (From Existing Branch)
```bash
git checkout v2.1-early-release
git checkout remotes/github/version-2.1 -- .
git commit -m "Ian Piumarta's maru-2.1 early public release

From: http://piumarta.com/software/maru/maru-2.1.tar.gz
- First multi-file public release
- Early expansion beyond single file"
```

#### 3.5 v2.4 Canonical (From Existing Branch)
```bash
git checkout v2.4-canonical  
git checkout remotes/github/version-2.4 -- .
git commit -m "Ian Piumarta's maru-2.4 canonical release

From: http://piumarta.com/software/maru/maru-2.4.tar.gz
- Official 77-file complete system
- Canonical implementation of Ian's vision
- Complete IR system, assembly generation, PEG parser
- This is the 'official complete Maru'"
```

#### 3.6 v2.5 VPRI Complete (New Discovery)
```bash
git checkout v2.5-vpri-complete
# Copy the 106-file VPRI system
cp -r vpri-complete/* .
git add .
git commit -m "VPRI complete Maru system - final VPRI development

From: github.com/damelang/nile (compilers/maru/maru/)
- 106 files - most complete Maru ever created
- Complete systems programming language
- Networking stack (TCP/IP), graphics (OpenGL), FFI
- Advanced IR system, comprehensive libraries  
- Final state before VPRI closure (2018)
- THIS IS THE CANONICAL COMPLETE SYSTEM"
```

#### 3.7 v3.0 Organization (Your First Enhancement)
```bash
git checkout v3.0-organization
# Apply your directory reorganization to v2.5 base
# Merge your organizational improvements with VPRI complete
git merge v2.5-vpri-complete --strategy=ours --allow-unrelated-histories
# Then apply your directory structure
mkdir -p core/ lib/ arch/ tools/
# Reorganize files according to your structure
```

#### 3.8 v3.1 Cross Platform (Your Architecture System)
```bash
git checkout v3.1-cross-platform
git merge v3.0-organization
# Add MARU_TARGET_ARCH system
# Apply cross-platform enhancements
```

#### 3.9 v3.2 Modern Features (Current Enhanced System)
```bash
git checkout v3.2-modern-features
git merge v3.1-cross-platform
# Add port streams, PEG enhancements, etc.
# This becomes current main branch
```

### Phase 4: Evolution Documentation

#### 4.1 Create README-v*.md for Each Branch
```bash
# For each branch, create comprehensive documentation
README-v1.0.md - The single file miracle
README-v1.1.md - First architectural separation
README-v2.0.md - Birth of self-hosting
README-v2.1.md - First public release
README-v2.4.md - Ian's canonical complete system
README-v2.5.md - VPRI's ultimate Maru (most complete ever)
README-v3.0.md - Modern organization and UX
README-v3.1.md - Cross-platform architecture
README-v3.2.md - Enhanced modern features
```

#### 4.2 Bootstrap Validation Scripts
```bash
# For each branch, create bootstrap test
test-bootstrap-v*.sh scripts that verify:
- Compilation succeeds
- Bootstrap process works  
- Expected functionality present
```

### Phase 5: Integration and Validation

#### 5.1 Evolution Consistency Check
```bash
# Script to verify each branch builds on previous
./validate-evolution.sh - checks that each stage progresses logically
```

#### 5.2 Complexity Metrics
```bash
# Track evolution metrics across branches
./measure-evolution.sh:
- Line count progression
- File count progression  
- Feature capability matrix
- Bootstrap time measurements
```

## Expected Outcomes

### Complete Archaeological Record
```
v1.0: ~1750 lines, 1 file    - The miracle of metacircular minimalism
v1.1: ~2000 lines, 3 files   - Architectural separation emerges
v2.0: ~3000 lines, 5 files   - Self-hosting capability born
v2.1: ~5000 lines, 15 files  - Public multi-file system
v2.4: ~8000 lines, 77 files  - Ian's canonical complete system
v2.5: ~12000 lines, 106 files - VPRI's ultimate complete system ⭐
v3.0: ~12000 lines, organized - Modern UX and organization
v3.1: ~13000 lines, cross-platform - Architecture abstraction  
v3.2: ~15000 lines, enhanced - Current enhanced system
```

### Educational Value
- **Bootstrap Understanding**: See exactly how complexity grows
- **Architectural Evolution**: Watch design decisions unfold
- **Comparative Analysis**: Compare approaches across versions
- **Historical Preservation**: Complete record of metacircular evolution

### Development Benefits  
- **Regression Prevention**: Always have working simpler versions
- **Feature Impact Assessment**: See cost/benefit of each enhancement
- **Complexity Management**: Understand when system became "complex"
- **Design Validation**: Test ideas against multiple evolution stages

## Critical Success Factors

### 1. v1.0 Single File Recovery (Highest Priority)
**Your Action Required**: Locate and provide Ian's original 1750-line file
- This is the **foundation** of the entire archaeological record
- Without it, evolution timeline remains incomplete

### 2. VPRI Integration Recognition
**Key Insight**: v2.5 VPRI (106 files) is the **canonical complete system**
- More complete than even maru-2.4 official release
- Should be the foundation for modern development
- Your v3.x enhancements should build on this, not maru-2.4

### 3. Preserve All Work
- Ian's original minimalism (v1.0-v2.4)
- VPRI's completion (v2.5) 
- Your organizational improvements (v3.x)
- No work is discarded, all becomes part of evolution

## Immediate Next Steps

### For You (User Actions Needed):
1. **Locate Ian's v1.0 single file** from archives/internet/contacts
2. **Confirm VPRI integration strategy** - build v3.x on v2.5 foundation?
3. **Review evolution timeline** - does this match your vision?

### For Me (After You Provide v1.0):
1. **Execute tree surgery** following this exact plan
2. **Create evolution documentation** for each branch
3. **Validate bootstrap progression** across all branches
4. **Complete archaeological timeline** with full lineage

## Success Metrics

✅ **Complete Lineage**: v1.0 → v2.5 → v3.x with no gaps  
✅ **Bootstrap Validation**: Every branch successfully bootstraps  
✅ **Historical Accuracy**: Faithful to Ian's and VPRI's work  
✅ **Educational Value**: Clear progression showing architectural evolution  
✅ **Development Utility**: Useful foundation for ongoing work

This creates a **living museum** of metacircular compiler evolution - the most complete archaeological record of a self-hosting language's development ever assembled.

**Ready to proceed as soon as you provide the v1.0 single file!**