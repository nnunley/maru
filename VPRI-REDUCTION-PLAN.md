# VPRI 10K Line Constraint - Maru Reduction Plan

## Current State: 46,503 lines (4.6x over budget)

## Target: ≤10,000 lines for understandable system

## Essential Core - Including PEG Extensibility Infrastructure (8,331 lines)
```
# Core Language System
boot.l           1,042 lines  # Bootstrap
eval.l           1,697 lines  # Evaluator  
emit.l           1,053 lines  # Code generator
ir.k               833 lines  # IR definitions
eval.k             930 lines  # Runtime support

# PEG Extensibility System (ESSENTIAL for Maru's value proposition)
core/parser.l      866 lines  # Stream abstraction & parsing
core/peg.l         159 lines  # PEG class system
core/peg-boot.l    405 lines  # Bootstrap PEG rules  
core/peg-compile.l 136 lines  # Grammar compilation
core/peg-compiler.l 210 lines # Rule compiler
grammars/core/peg.g 50 lines  # Meta-grammar

# Support Infrastructure  
osdefs.k           200 lines  # OS definitions
buffer.l           150 lines  # Basic I/O
gc.l               300 lines  # Garbage collector
misc support       300 lines  # Remaining essentials
                ─────────────
TOTAL:           8,331 lines  # ✅ Under 10K, preserves extensibility!
```

## Elimination Strategy

### Phase 1: Remove Duplicates (Save ~10,000 lines)
- ❌ Delete `core/eval.l` and `original/eval.l` (keep root `eval.l`)
- ❌ Delete `boot2.l` and `core/bootstrap/*` (keep root `boot.l`) 
- ❌ Delete `original/` directory entirely
- **Savings**: ~10,954 lines

### Phase 2: Eliminate Non-Essential Features (Save ~20,000 lines)
- ❌ JIT infrastructure (`lib/dlopen.k`, `lib/libgl.k`, etc.)
- ❌ Networking stack (`net/` directory - 500+ lines)
- ❌ UTF8 system (`core/utf8-complete-system.l` - 228 lines)
- ❌ **Advanced PEG features** (keep core PEG system for extensibility)
  - Archive IR-based compilation experiments (~1,200 lines)
  - TPEG typed variant system
  - PEG debugging and profiling tools
- ❌ Port streams (use simple I/O, can be rebuilt via PEG if needed)
- **Savings**: ~20,000+ lines

### Phase 3: Unify Architecture (Save ~15,000 lines)
- ❌ Keep only ONE architecture backend (C backend for portability)
- ❌ Delete `arch/` directory (ARM64, x86 assembly backends)
- ❌ Delete IR backends (`ir-gen-*.k` files)
- ❌ Consolidate to single `emit.l` C backend
- **Savings**: ~15,000 lines

### Phase 4: Minimize Compiler Variants (Save ~5,000 lines)
- ❌ Delete all `emit-*` variants except core `emit.l`
- ❌ Delete multimethod dispatch system
- ❌ Keep only essential code generation
- **Savings**: ~5,000 lines

## Result: VPRI-Compliant Maru with Full Extensibility (~8,331 lines)

### Final Core Structure:
```
# Core Language System
boot.l           1,042 lines  # Bootstrap only
eval.l           1,697 lines  # Single evaluator
emit.l           1,053 lines  # C backend only  
ir.k               833 lines  # Essential IR
eval.k             930 lines  # Runtime support

# Complete PEG Extensibility System
core/parser.l      866 lines  # Stream abstraction
core/peg.l         159 lines  # PEG classes  
core/peg-boot.l    405 lines  # Bootstrap rules
core/peg-compile.l 136 lines  # Grammar compilation
core/peg-compiler.l 210 lines # Rule compiler
grammars/core/peg.g 50 lines  # Meta-grammar

# Support Infrastructure
osdefs.k           200 lines  # OS definitions
buffer.l           150 lines  # Basic I/O
gc.l               300 lines  # Garbage collector
misc support       300 lines  # Remaining essentials
                ─────────────
ESTIMATED:       8,331 lines  # ✅ Under 10K with full extensibility!
```

## Implementation Steps

1. **Create `minimal-maru/` branch**
2. **Copy only essential files**
3. **Test bootstrap functionality**
4. **Verify self-hosting capability**
5. **Document what was removed**

## VPRI Compliance Benefits

- **Understandable**: 8K lines can be comprehended by one person
- **Maintainable**: Small enough to reason about completely
- **Debuggable**: Issues can be traced through entire system
- **Teachable**: Students can learn entire system architecture
- **Portable**: Simple enough to port to new platforms easily

## What We Keep vs Remove

### ✅ KEEP (Essential for extensible metacircular compiler):
- Bootstrap process (`boot.l`)
- Self-hosting evaluator (`eval.l`) 
- Code generation (`emit.l` - C backend only)
- **Complete PEG extensibility system** (core foundation for language extension)
  - Stream abstraction (`core/parser.l`)
  - PEG class system (`core/peg.l`)
  - Bootstrap rules (`core/peg-boot.l`)
  - Grammar compilation (`core/peg-compile.l`, `core/peg-compiler.l`)
  - Meta-grammar definitions (`grammars/core/peg.g`)
- Runtime support (`eval.k`)
- Memory management (`gc.l`, `buffer.l`)

### ❌ REMOVE (Nice-to-have but can be rebuilt via extensibility):
- Multiple architecture backends (ARM64, x86 assembly)
- JIT compilation infrastructure (can be added via PEG-based extensions)
- Networking stack (can be embedded as DSL)
- UTF8 processing (can be added as grammar extension)
- **Advanced PEG features** (IR compilation, TPEG, debugging tools)
- Port streams system (basic I/O sufficient, can be extended)
- Multiple evaluator variants (use generation evolution instead)
- Experimental compiler backends (C backend + extensibility sufficient)
- Documentation and test infrastructure (can be rebuilt minimally)

## Success Criteria

1. **Line count**: ≤10,000 lines total
2. **Self-hosting**: Can compile itself
3. **Bootstrap**: Can generate eval2 from eval.l
4. **Portability**: Runs on major platforms via C backend
5. **Extensibility**: Can define and use new grammars for language extension
6. **Understandability**: Single person can comprehend entire system including extensibility

## Extensibility Validation

The system must demonstrate that new syntax can be added without core modifications:

```lisp
;; Example: Define SQL-like syntax embedded in Maru
(define-grammar sql-subset
  ((select-stmt (match-sequence 
                  (match-string "SELECT") 
                  (match-rule columns)
                  (match-string "FROM")
                  (match-rule table)))))
                  
;; Use immediately - no rebuild required
(parse-with sql-subset "SELECT name FROM users")
```

This achieves Alan Kay's vision of a personal computing system that fits in your head **and can grow** through principled extension rather than core modification.