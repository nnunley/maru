# emit-c-multimethod-draft.l Status

## Overview

The `emit-c-multimethod-draft.l` file represents a more architecturally sound approach to the C backend using proper object-oriented design with multi-method dispatch. However, it was incomplete and had some issues that prevented it from working.

## Key Features

### 1. Proper OO Architecture
- Inherits from `<backend>` base class
- Uses `define-method` for polymorphic behavior
- Clean separation of concerns

### 2. Multi-Method Definitions
```lisp
(define-method backend-initialize <c-backend> (output-port))
(define-method compile-expression <c-backend> (expr compiler))
(define-method compile-literal <c-backend> (value type))
;; ... many more methods
```

### 3. Backend Class Structure
```lisp
(define-structure <c-backend> <backend>
  (indent-level long)
  (in-function? boolean)
  (temp-counter long)
  (function-decls list)
  (global-decls list)
  (includes list))
```

### 4. Feature Support System
- Backend features list: `'(portable readable debug-friendly)`
- `backend-supports-feature?` method
- Formal lifecycle with `backend-initialize` and `backend-finalize`

### 5. Instruction-Level Support
Includes low-level instruction emission for compatibility with existing IR:
- MOVE, LOAD, STORE
- ADD, SUB, MUL, DIV
- BR, BT, BF (branching)
- CALL, COMMENT

## Issues Fixed

### 1. port-format Missing
The original code used `port-format` which doesn't exist in Maru. Fixed by:
- Adding a simple `port-format` implementation as a TODO
- Converting problematic calls to use `port-write` directly

### 2. String Manipulation
Several string manipulation functions were assumed to exist but don't:
- `string-map` 
- Complex `concat-string` operations
- Generic `->string` conversions

## What's Missing

The multimethod draft lacks:
1. **Two-pass compilation strategy** - No forward declarations handling
2. **init_globals() approach** - No solution for circular dependencies
3. **Environment handling** - Less comprehensive than emit-c-comprehensive.l
4. **Testing** - Never tested against actual Maru code

## Comparison with emit-c-comprehensive.l

| Feature | Multimethod Draft | Comprehensive |
|---------|------------------|---------------|
| Architecture | Clean OO with multi-methods | Procedural functions |
| Two-pass compilation | No | Yes |
| Circular deps handling | No | Yes (init_globals) |
| Port integration | Partial (had errors) | Full |
| Testing | None | Tested and working |
| Extensibility | Excellent | Good |

## Recommendation

The ideal C backend would combine:
1. The clean multi-method architecture from the draft
2. The two-pass compilation strategy from the comprehensive version
3. Proper integration with Maru's port streams
4. Full testing suite

## TODO Items

1. **Implement proper port-format** - Create a real printf-style formatter for ports
2. **Add two-pass compilation** - Integrate the clever strategy from emit-gc-c.l
3. **Test the multimethod version** - Ensure it can compile real Maru code
4. **Merge best features** - Combine multimethod architecture with working implementation

## Current Status

The file has been updated to fix the immediate port-format errors by:
- Adding a simple port-format implementation
- Fixing the concat-string usage in c-emit-comment

However, it still needs the two-pass compilation strategy and thorough testing before it can replace the working emit-c.l (comprehensive version).