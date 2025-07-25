# Maru Implementation Plan

## Overview

This document outlines a comprehensive plan to implement the remaining TODO items and restructure the codebase for improved readability and maintainability.

## Phase 1: Codebase Restructuring (Priority: High)

### 1.1 Extract Grammars into Dedicated Directory

**Current State**: Grammar files (.g) are scattered throughout the codebase, including test files and generated grammars.

**Proposed Structure**:
```
grammars/
├── core/
│   ├── peg.g          # Core PEG grammar
│   ├── irgol.g        # IR language grammar
│   ├── irl.g          # IR low-level grammar
│   └── x86.g          # x86 assembly grammar
├── arch/
│   └── arm64.g        # ARM64 assembly grammar
├── lang/
│   ├── utf8.g         # UTF-8 parsing
│   └── unicode/       # Unicode support grammars
│       ├── collation.g
│       └── normalization.g
└── test/
    ├── dc.g           # Desktop calculator example
    └── recursion.g    # Recursion test grammar
```

**Implementation Steps**:
1. Create directory structure
2. Move grammar files with git mv to preserve history
3. Update references in code to new locations
4. Create README.md in grammars/ explaining each grammar

### 1.2 Reorganize Source Code Structure

**Proposed Top-Level Structure**:
```
maru/
├── core/              # Core language implementation
│   ├── eval.c         # Bootstrap evaluator
│   ├── eval.l         # Metacircular evaluator
│   ├── boot.l         # Bootstrap definitions
│   ├── boot2.l        # Extended bootstrap
│   └── emit.l         # Code generator
├── runtime/           # Runtime support
│   ├── gc.c           # Garbage collector
│   ├── buffer.c       # Buffer management
│   ├── utf8.c         # UTF-8 support
│   └── wcs.c          # Wide character support (legacy)
├── ir/                # Intermediate representation
│   ├── ir.k           # IR definitions
│   ├── ir-gen-c.k     # C backend
│   ├── ir-gen-x86.k   # x86 backend
│   ├── ir-gen-arm64.k # ARM64 backend
│   └── ir-gen-llir.k  # LLVM IR backend
├── lang/              # Language extensions
│   ├── maru.k         # Maru syntax support
│   ├── parser.l       # Parser framework
│   └── peg.l          # PEG implementation
├── lib/               # Standard libraries
│   ├── stream.l       # Stream system
│   ├── ffi.k          # Foreign function interface
│   └── debug.l        # Debugging support
├── arch/              # Architecture-specific code
│   ├── x86/
│   └── arm64/
├── grammars/          # Grammar definitions (as above)
├── test/              # Test suite
├── doc/               # Documentation
└── examples/          # Example programs
```

## Phase 2: UTF-8 Integration (Priority: High)

### 2.1 Complete UTF-8 Implementation

**Status**: UTF-8 support files created but not integrated.

**Tasks**:
1. **Update emit.l** to generate UTF-8 string literals instead of wide characters
   - Change L"string" generation to "string"
   - Update character handling functions
   
2. **Regenerate eval2.c** with UTF-8 support
   - Add missing Makefile rule
   - Test metacircular property preserved
   
3. **Update runtime dependencies**
   - Replace wcs.c references with utf8.c
   - Update buffer.c for UTF-8 awareness
   
4. **Comprehensive testing**
   - Create UTF-8 test suite
   - Test with various Unicode scripts (Latin, CJK, Arabic, etc.)

### 2.2 UCS-4 Internal Representation (Optional)

**Consideration**: The TODO mentions UCS-4 internal representation, but current UTF-8 implementation may be sufficient.

**Decision Points**:
- UTF-8 is more space-efficient
- UCS-4 provides O(1) character access
- Current implementation uses UTF-8 throughout

**Recommendation**: Keep UTF-8 for now, document the trade-offs.

## Phase 3: Core Language Features (Priority: High)

### 3.1 Source Location Tracking

**Goal**: Add debugging information to pairs for better error reporting.

**Implementation**:
```lisp
;; Current pair structure
(cons car cdr)

;; Enhanced with source location
(cons car cdr location)
;; where location = (file line column)
```

**Tasks**:
1. Modify pair structure in eval.c
2. Update reader to track locations
3. Enhance error reporting to use location info
4. Update eval.l to preserve locations

### 3.2 Namespace Syntax

**Goal**: Implement Foo.bar.baz syntax for namespace access.

**Design**:
```lisp
;; Reader transformation
Foo.bar.baz → (in (in Foo bar) baz)

;; Evaluator handling
(in namespace symbol) → lookup symbol in namespace
```

**Tasks**:
1. Modify reader to recognize dot syntax
2. Implement `in` special form
3. Create namespace data structure
4. Add namespace manipulation functions

## Phase 4: Optimization Features (Priority: Medium)

### 4.1 Constant Folding

**Goal**: Evaluate constant expressions at compile time.

**Examples**:
```lisp
(+ 2 3) → 5
(* 4 (+ 1 2)) → 12
```

**Implementation**:
1. Add constant detection in emit.l
2. Implement folding for arithmetic operations
3. Extend to other pure functions
4. Add optimization flag to control behavior

### 4.2 IR Improvements

**Tasks from TODO**:
1. Remove frame from `<ir>` and move to `<ir-gen>`
2. Separate pools for temps and locals
3. Make register allocation the responsibility of generators

## Phase 5: Backend Completion (Priority: Medium)

### 5.1 Complete x86 Backend

**Current State**: Partially implemented in ir-gen-x86.k

**Tasks**:
1. Complete instruction set coverage
2. Implement calling conventions
3. Add register allocation
4. Create comprehensive test suite

### 5.2 Stream System Port

**Goal**: Port the stream system for I/O abstraction.

**Components**:
1. Stream base class
2. File streams
3. String streams
4. Network streams (future)

## Phase 6: Language Extensions (Priority: Low)

### 6.1 Active Variables

**Goal**: Implement getter/setter methods for variables.

### 6.2 Structure Inheritance

**Goal**: Dynamic inheritance between structures.

### 6.3 Enhanced PEG Features

**From TODO**:
- Optimize PEG for 'select' operations
- Support range syntax in character classes
- PEG IR to S-expression compiler

## Implementation Schedule

### Week 1-2: Codebase Restructuring
- Create new directory structure
- Move files preserving git history
- Update all references
- Create documentation

### Week 3-4: UTF-8 Integration
- Complete emit.l modifications
- Regenerate eval2.c
- Comprehensive testing
- Documentation updates

### Week 5-6: Source Location & Namespaces
- Implement source tracking
- Add namespace syntax
- Testing and documentation

### Week 7-8: Optimizations
- Constant folding
- IR improvements
- Performance testing

### Week 9-10: Backend & Streams
- Complete x86 backend
- Port stream system
- Integration testing

### Week 11-12: Polish & Documentation
- Complete remaining features
- Comprehensive documentation
- Release preparation

## Testing Strategy

### Unit Tests
- Individual feature tests
- Regression test suite
- Performance benchmarks

### Integration Tests
- Metacircular compilation tests
- Cross-backend validation
- Unicode compliance tests

### System Tests
- Large program compilation
- Self-hosting validation
- Performance comparisons

## Documentation Updates

### Technical Documentation
- Update ARCHITECTURE.md
- Create UNICODE.md for UTF-8 design
- Backend development guide
- Optimization guide

### User Documentation
- Getting Started guide updates
- Language reference updates
- Migration guide for wide chars → UTF-8

## Risk Mitigation

### High-Risk Areas
1. **UTF-8 Integration**: May break existing code
   - Mitigation: Comprehensive test suite
   
2. **eval2.c Regeneration**: Must maintain metacircularity
   - Mitigation: Automated validation tests
   
3. **Source Location Tracking**: Memory overhead
   - Mitigation: Optional compilation flag

### Backward Compatibility
- Maintain wcs.c for transition period
- Document breaking changes
- Provide migration tools

## Success Criteria

1. **Restructured Codebase**: Clear, logical organization
2. **UTF-8 Support**: Full Unicode compliance
3. **Enhanced Debugging**: Source location in errors
4. **Namespace Support**: Working dot syntax
5. **Optimizations**: Measurable performance improvements
6. **Complete x86 Backend**: All tests passing
7. **Documentation**: Comprehensive and current

## Conclusion

This plan provides a systematic approach to completing the TODO items while improving code organization. The phased approach allows for incremental progress with regular validation points. Priority is given to foundational changes (restructuring, UTF-8) that enable other improvements.