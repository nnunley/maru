# VPRI 10K Line Constraint - Maru Reduction Plan

## Current State: 46,503 lines (4.6x over budget)

## Target: ≤10,000 lines for understandable system

## Essential Core (6,421 lines)
```
boot.l          1,042 lines  # Bootstrap
eval.l          1,697 lines  # Evaluator  
emit.l          1,053 lines  # Code generator
ir.k              833 lines  # IR definitions
parser.l          866 lines  # PEG parser
eval.k            930 lines  # Runtime support
                ─────────────
TOTAL:          6,421 lines  # Within budget!
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
- ❌ PEG enhancements beyond basic parser
- ❌ Port streams (use simple I/O)
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

## Result: VPRI-Compliant Maru (~8,000 lines)

### Final Core Structure:
```
boot.l           1,042 lines  # Bootstrap only
eval.l           1,697 lines  # Single evaluator
emit.l           1,053 lines  # C backend only  
ir.k               833 lines  # Essential IR
parser.l           866 lines  # Basic PEG parser
eval.k             930 lines  # Runtime support
osdefs.k           200 lines  # OS definitions
buffer.l           150 lines  # Basic I/O
gc.l               300 lines  # Garbage collector
misc support     1,000 lines  # Remaining essentials
                ─────────────
ESTIMATED:       8,071 lines  # ✅ Under 10K!
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

### ✅ KEEP (Essential for metacircular compiler):
- Bootstrap process (`boot.l`)
- Self-hosting evaluator (`eval.l`) 
- Code generation (`emit.l` - C backend only)
- Basic parsing (`parser.l`)
- Runtime support (`eval.k`)
- Memory management (`gc.l`, `buffer.l`)

### ❌ REMOVE (Nice-to-have but not essential):
- Multiple architecture backends (ARM64, x86 assembly)
- JIT compilation infrastructure  
- Networking stack
- UTF8 processing
- Advanced PEG features
- Port streams system
- Multiple evaluator variants
- Experimental compiler backends
- Documentation and test infrastructure

## Success Criteria

1. **Line count**: ≤10,000 lines total
2. **Self-hosting**: Can compile itself
3. **Bootstrap**: Can generate eval2 from eval.l
4. **Portability**: Runs on major platforms via C backend
5. **Understandability**: Single person can comprehend entire system

This achieves Alan Kay's vision of a personal computing system that fits in your head.