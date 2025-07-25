# Maru Evolution Timeline Design

## Vision: Archaeological Layers of Bootstrap Evolution

Your intention to create **continuous evolution snapshots** is brilliant - it creates an archaeological record of how a metacircular compiler bootstraps from minimal to sophisticated. This is invaluable for understanding the bootstrap process itself.

## Current State Analysis

### Discovered Evolution Artifacts
```
git log shows:
- c841e59: "Move top-level files to maru-1.0" (2021)
- 5184556: "Moved old maru to maru-1.0" (2013)
- Contains: boot.l, emit.l, eval.l, boot-eval.c - minimal system
```

### Target Evolution Timeline
Based on Ian Piumarta's development and your vision:

```
v1.0    - Single file (1750 lines) from Ian's website
v2.1    - Early expansion (multiple files)
v2.4    - Complete system (77 files) 
v3.0+   - Your enhancements (organization, cross-platform, modern features)
```

## Proposed Branch Evolution Strategy

### Archaeological Layer Structure
```
maru-evolution/
├── v1.0-single-file     # Ian's original 1750-line implementation
├── v1.1-bootstrap-split # Bootstrap files separated  
├── v2.0-basic-expansion # Basic multi-file structure
├── v2.1-early-release   # Ian's first public release
├── v2.4-canonical       # Ian's complete 77-file system
├── v3.0-reorganization  # Your directory structure
├── v3.1-cross-platform  # MARU_TARGET_ARCH system
├── v3.2-threading       # C-threaded experiments
├── v3.3-modern-features # Current enhanced system
└── v4.0-future          # JIT, advanced features
```

### Missing Archaeological Layers

#### 1. **v1.0 Single File** (Missing - Priority 1)
**Source**: Ian's website (1750 lines, complete in one file)
**Contents**: Everything in single .c file - evaluator, GC, compiler
**Significance**: Shows how compact a complete system can be
**Status**: **Need to retrieve from Ian's site or archives**

#### 2. **v1.1 Bootstrap Split** (Can Reconstruct)
**Purpose**: Show transition from single file to boot.l + eval.c
**Demonstrates**: First separation of Lisp code from C runtime
**Files**: `boot-eval.c` (minimal) + `boot.l` (basics)

#### 3. **v2.0 Basic Expansion** (Can Reconstruct)  
**Purpose**: Show addition of emit.l and basic compiler
**Files**: `boot.l`, `emit.l`, `eval.l`, `eval.c`
**Demonstrates**: Birth of self-hosting capability

## Implementation Strategy

### Phase 1: Recovery and Documentation
```bash
# Create evolution branch structure
git checkout -b evolution-timeline

# For each evolution point:
git checkout -b v1.0-single-file  # Retrieve Ian's original
git checkout -b v1.1-bootstrap-split 
git checkout -b v2.0-basic-expansion
# ... etc
```

### Phase 2: Archaeological Reconstruction
For each missing layer, create the minimal system that represents that evolution stage:

#### v1.0 Single File Recovery
```c
// Target: Reconstruct or retrieve Ian's 1750-line single file
// Contains:
// - Complete evaluator
// - Garbage collector  
// - Multi-method dispatch
// - Self-compilation capability
// - All in ~1750 lines of C
```

#### v1.1 Bootstrap Split Demonstration
```
Files:
- boot-eval.c     # Minimal C evaluator (300-500 lines)
- boot.l          # Basic Lisp definitions (100-200 lines)
- Makefile        # Simple build

Purpose: Show separation of C runtime from Lisp definitions
```

#### v2.0 Basic Expansion  
```
Files:
- boot.l          # Core definitions
- emit.l          # Code generation (basic)
- eval.l          # Lisp evaluator
- eval.c          # C runtime
- Makefile

Purpose: Show birth of self-hosting compiler
Demonstrates: boot.l → emit.l → can compile eval.l
```

### Phase 3: Evolution Documentation
For each branch, create:
```
README-v[X.Y].md explaining:
- What changed from previous version
- Why this evolution step was necessary  
- What capabilities were added
- How bootstrap process works at this level
- Line count progression
- Key architectural decisions
```

### Phase 4: Evolution Validation
```bash
# For each branch, verify it bootstraps:
./eval boot.l           # Level 0 bootstrap
(load "emit.l")         # Level 1 capability  
(compile-eval)          # Level 2 self-hosting
# Document bootstrap process at each level
```

## Archaeological Value

### Educational Benefits
1. **Bootstrap Understanding**: See how complexity grows incrementally
2. **Architecture Evolution**: Watch design decisions unfold over time
3. **Trade-off Analysis**: Compare different approaches across versions
4. **Minimal Viability**: Understand what's truly essential vs. enhancement

### Development Benefits  
1. **Regression Prevention**: Always have simpler version to fall back to
2. **Feature Impact**: See exactly what each enhancement costs/provides
3. **Complexity Management**: Understand when system became "too complex"
4. **Design Validation**: Test ideas against multiple evolution stages

### Historical Preservation
1. **Archive Ian's Work**: Preserve complete evolution of his thinking
2. **Document Decisions**: Why certain choices were made at each stage
3. **Preserve Alternatives**: Keep different approaches visible
4. **Enable Research**: Others can study metacircular compiler evolution

## Critical Missing Piece: v1.0 Single File

**Priority 1**: Retrieve Ian's original 1750-line single file implementation
**Sources to try**:
- Internet Archive of piumarta.com/software/maru/
- Academic paper implementations  
- GitHub archives of very early commits
- Direct contact with Ian or VPRI archives

**Fallback**: Reconstruct minimal single-file version from v2.1 by:
- Embedding boot.l as C string
- Inlining emit.l functionality
- Creating single-file bootstrap

## Implementation Timeline

### Week 1: Archaeological Recovery
- [ ] **Retrieve v1.0 single file** from archives or reconstruct
- [ ] **Create branch structure** for evolution timeline
- [ ] **Document current state** as latest evolution point

### Week 2: Early Evolution Reconstruction  
- [ ] **Create v1.1 bootstrap split** from single file
- [ ] **Create v2.0 basic expansion** 
- [ ] **Validate bootstrap** at each level

### Week 3: Official Version Integration
- [ ] **Integrate v2.1 and v2.4** official releases
- [ ] **Document architectural changes** between versions
- [ ] **Create evolution documentation** for each branch

### Week 4: Modern Evolution Mapping
- [ ] **Map your enhancements** as v3.x series
- [ ] **Create future evolution** branch (v4.0)
- [ ] **Complete timeline documentation**

## Success Metrics

**Archaeological Completeness**: Every evolution stage bootstraps successfully  
**Educational Value**: Clear progression from simple to complex  
**Historical Accuracy**: Faithful to Ian's original development  
**Development Utility**: Useful for ongoing development decisions

This creates a **living museum** of metacircular compiler evolution - invaluable for understanding, education, and development.

**Next Critical Step**: Locate and retrieve Ian's original 1750-line single-file implementation to complete the archaeological record.