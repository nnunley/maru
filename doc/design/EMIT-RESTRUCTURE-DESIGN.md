# Maru Emit System Restructuring Design

*Following TODO guidance: "split emit.l into emit-common.l, emit-386.l, emit-c.l"*

## Overview

This design restructures the monolithic `emit.l` (1044 lines, 119 emit definitions) into a clean, multi-method based architecture that follows Maru's design principles of elegance, extensibility, and proper separation of concerns.

## Current Architecture Analysis

### Problems with Current emit.l
- **Monolithic**: Single 1044-line file mixing target-independent and target-specific code
- **Backend Switching**: Runtime backend switching via global variables (`*emit-backend*`)
- **Code Duplication**: Similar patterns repeated across ARM64, C, and x86 backends
- **Maintainability**: Changes require touching a massive file
- **Extensibility**: Adding new targets requires deep knowledge of the entire system

### Current Structure
```
emit.l (1044 lines)
├── Core data structures (20%)
├── Target-independent compilation logic (40%)
├── ARM64-specific emit methods (20%)  
├── C backend stubs (10%)
├── x86 legacy code (5%)
└── Backend switching logic (5%)
```

## Design Principles

### Maru Philosophy Alignment
1. **Metacircular Elegance**: Use Maru's own multi-method system for compilation
2. **Structure-Based Design**: Proper use of structures and classes
3. **Minimal Complexity**: Each component has single responsibility
4. **Composable Architecture**: Backends can be mixed and extended
5. **Self-Describing**: The compiler describes itself using its own constructs

### Multi-Method Dispatch Strategy
```lisp
;; Generic compilation methods
(define-generic emit-instruction (backend instruction))
(define-generic emit-data (backend data-type value))
(define-generic emit-function-prologue (backend function-info))

;; Backend-specific implementations
(define-method emit-instruction c-backend (instr) ...)
(define-method emit-instruction x86-backend (instr) ...)
(define-method emit-instruction arm64-backend (instr) ...)
```

## New Architecture Design

### File Structure
```
core/compiler/
├── emit-common.l      # Target-independent compilation logic
├── emit-c.l          # C code generation backend
├── emit-x86.l        # x86 assembly backend  
├── emit-arm64.l      # ARM64 assembly backend
└── emit.l            # Main entry point and backend coordination
```

### Backend Object System

#### Backend Base Class
```lisp
(define-structure <backend> 
  (name symbol)           ; 'c, 'x86, 'arm64
  (output-port port)      ; Where to emit code
  (state alist)          ; Backend-specific state
  (features list))       ; Supported features

;; Generic backend interface
(define-generic backend-initialize (backend))
(define-generic backend-finalize (backend))
(define-generic backend-supports-feature? (backend feature))
```

#### Specific Backend Classes
```lisp
;; C Backend
(define-structure <c-backend> <backend>
  (indent-level long)
  (in-function? boolean)
  (temp-counter long)
  (includes list))

;; Assembly Backends  
(define-structure <x86-backend> <backend>
  (register-state alist)
  (stack-offset long)
  (labels list))

(define-structure <arm64-backend> <backend>
  (register-state alist)
  (stack-offset long)
  (labels list))
```

## Component Specifications

### emit-common.l - Core Compilation Logic

#### Responsibilities
- Target-independent AST traversal
- Temporary variable management
- Environment handling
- Control flow compilation
- Function calling conventions (abstract)

#### Key Components
```lisp
;;; CORE DATA STRUCTURES (unchanged)
(define-structure <variable> (name value env index))
(define-structure <environment> (parent level offset bindings))
(define-structure <compiler> (level temps args))

;;; GENERIC COMPILATION INTERFACE
(define-generic compile-expression (backend expr compiler))
(define-generic compile-statement (backend stmt compiler))
(define-generic compile-function (backend func compiler))

;;; TARGET-INDEPENDENT COMPILATION LOGIC
(define-function gen-tmp-prog (prog comp backend))
(define-function gen-let (expr comp backend))
(define-function gen-if (expr comp backend))
(define-function gen-while (expr comp backend))
;; ... other gen-* functions become target-independent

;;; COMPILER COORDINATION
(define-function encode-with-backend (backend expr))
```

### emit-c.l - C Code Generation Backend

#### Responsibilities
- Generate portable, readable C code
- Handle C-specific syntax and semantics
- Manage C includes and declarations
- Proper C identifier mangling

#### Architecture
```lisp
;;; C BACKEND CLASS
(define-structure <c-backend> <backend>
  (indent-level long)
  (in-function? boolean)  
  (temp-counter long)
  (function-decls list)
  (global-decls list)
  (includes list))

;;; C CODE GENERATION METHODS
(define-method compile-expression <c-backend> (expr compiler)
  (case (car expr)
    (+ (emit-c-arithmetic self '+ (cdr expr) compiler))
    (if (emit-c-conditional self expr compiler))
    ;; ... other expressions
    ))

(define-method emit-instruction <c-backend> (instr)
  (case (car instr)
    (MOVE (emit-c-assignment self (cadr instr) (caddr instr)))
    (CALL (emit-c-function-call self (cadr instr) (caddr instr)))
    ;; ... other instructions
    ))

;;; C-SPECIFIC UTILITIES
(define-function c-mangle-identifier (name))
(define-function c-emit-type-declaration (type))
(define-function c-emit-function-signature (name params return-type))
```

#### C Code Generation Examples
```c
// Function compilation
static oop _func_factorial(oop _param_0) {
    oop _tmp_0, _tmp_1, _tmp_2;
    _tmp_0 = _param_0;
    if (long_from_oop(_tmp_0) < 2) {
        return oop_from_long(1);
    }
    _tmp_1 = oop_from_long(long_from_oop(_tmp_0) - 1);
    _tmp_2 = _func_factorial(_tmp_1);
    return oop_from_long(long_from_oop(_tmp_0) * long_from_oop(_tmp_2));
}
```

### emit-x86.l - x86 Assembly Backend

#### Responsibilities
- Generate x86 assembly code
- Manage x86 registers and stack
- Handle x86-specific calling conventions
- Optimize for x86 instruction set

#### Architecture
```lisp
(define-structure <x86-backend> <backend>
  (register-allocator <x86-register-allocator>)
  (stack-frame <x86-stack-frame>)
  (instruction-buffer list))

(define-method compile-expression <x86-backend> (expr compiler)
  ;; Generate x86 assembly for expressions
  )

(define-method emit-instruction <x86-backend> (instr)
  (case (car instr)
    (MOVE (emit-x86-mov self (cadr instr) (caddr instr)))
    (CALL (emit-x86-call self (cadr instr) (caddr instr)))
    ;; ... x86 instructions
    ))
```

### emit-arm64.l - ARM64 Assembly Backend

#### Responsibilities  
- Generate ARM64 assembly code
- Manage ARM64 registers and calling conventions
- Handle ARM64-specific features
- Optimize for Apple Silicon and ARM64 platforms

#### Architecture
```lisp
(define-structure <arm64-backend> <backend>
  (register-allocator <arm64-register-allocator>)
  (stack-frame <arm64-stack-frame>)
  (instruction-buffer list))

;; Similar structure to x86 but ARM64-specific
```

## Multi-Method Dispatch Design

### Generic Interface
```lisp
;;; CORE COMPILATION GENERICS
(define-generic compile-literal (backend value type))
(define-generic compile-variable-ref (backend var))
(define-generic compile-function-call (backend func args))
(define-generic compile-arithmetic (backend op args))

;;; INSTRUCTION EMISSION GENERICS  
(define-generic emit-prologue (backend function-info))
(define-generic emit-epilogue (backend function-info))
(define-generic emit-move (backend dest src))
(define-generic emit-call (backend target args))
(define-generic emit-return (backend value))

;;; BACKEND LIFECYCLE GENERICS
(define-generic backend-initialize (backend output-port))
(define-generic backend-finalize (backend))
(define-generic backend-optimize (backend code))
```

### Method Implementation Pattern
```lisp
;; C backend methods
(define-method compile-literal <c-backend> (value type)
  (case type
    (<long> (format (backend-output self) "oop_from_long(~A)" value))
    (<string> (format (backend-output self) "oop_from_string(~S)" value))
    ;; ... other types
    ))

;; ARM64 backend methods  
(define-method compile-literal <arm64-backend> (value type)
  (case type
    (<long> (format (backend-output self) "mov x0, #~A" value))
    ;; ... ARM64-specific literal loading
    ))
```

## Backend Selection and Configuration

### Backend Factory
```lisp
(define-function create-backend (type output-port)
  (case type
    (c (let ((backend (new <c-backend>)))
         (set (<backend>-name backend) 'c)
         (set (<backend>-output-port backend) output-port)
         (backend-initialize backend output-port)
         backend))
    (x86 (create-x86-backend output-port))
    (arm64 (create-arm64-backend output-port))
    (else (error "Unknown backend type: " type))))

;; Global backend registry
(define *available-backends* '(c x86 arm64))
(define *default-backend* 'c)  ; Make C the default for portability
```

### Configuration Interface
```lisp
;; User-facing configuration
(define-function set-compilation-target (target)
  (set *default-backend* target))

(define-function compile-with-backend (backend-type expr)
  (let ((backend (create-backend backend-type (current-output-port))))
    (compile-expression backend expr (compiler 0))
    (backend-finalize backend)))
```

## Migration Strategy

### Phase 1: Extract Common Logic
1. **Create emit-common.l**
   - Move target-independent functions
   - Convert gen-* functions to generic methods
   - Establish backend protocol

2. **Modify existing emit.l**
   - Load emit-common.l
   - Keep current backends as legacy
   - Add backend selection logic

### Phase 2: Implement C Backend
1. **Create emit-c.l**
   - Implement <c-backend> class
   - Port existing C generation code
   - Add proper C code formatting

2. **Test C backend**
   - Compile eval.l with C backend
   - Verify generated C compiles correctly
   - Compare performance with assembly

### Phase 3: Restructure Assembly Backends
1. **Create emit-x86.l and emit-arm64.l**
   - Extract existing assembly generation
   - Implement proper backend classes
   - Add register allocation

2. **Remove legacy code**
   - Delete old monolithic emit.l
   - Update build system
   - Update documentation

### Phase 4: Optimization and Extensions
1. **Backend-specific optimizations**
2. **New backend support** (LLVM IR, WebAssembly)
3. **Performance tuning**

## Implementation Plan

### File Creation Order
1. `emit-common.l` - Core abstractions and generics
2. `emit-c.l` - C backend (primary focus)
3. `emit-x86.l` - x86 assembly backend
4. `emit-arm64.l` - ARM64 assembly backend
5. `emit.l` - New main entry point

### Testing Strategy
1. **Unit tests** for each backend
2. **Integration tests** compiling eval.l
3. **Performance benchmarks** comparing backends
4. **Compatibility tests** across platforms

### Success Criteria
- [ ] C backend generates correct, compilable C code
- [ ] eval.l compiles successfully with C backend
- [ ] Generated code passes all existing tests
- [ ] Assembly backends maintain current functionality
- [ ] New architecture is more maintainable and extensible
- [ ] Documentation reflects new structure

## Benefits of New Architecture

### For Developers
- **Cleaner code organization** - Each backend in separate file
- **Easier maintenance** - Changes isolated to specific backends
- **Better testing** - Individual backend testing
- **Extensibility** - New backends easy to add

### For Users  
- **Portable C generation** - Works on any platform with C compiler
- **Multiple compilation targets** - Choose best backend for use case
- **Better performance** - Backend-specific optimizations
- **Cleaner generated code** - Each backend optimized for its target

### For the Project
- **Follows TODO guidance** - Implements planned architecture
- **Uses Maru idioms** - Multi-methods, structures, clean design
- **Maintainable codebase** - Easier to understand and modify
- **Future-proof** - Ready for new compilation targets

---

*This design follows Maru's principles of metacircular elegance while providing a solid foundation for multiple compilation targets. The multi-method approach leverages Maru's own strengths to create a self-describing, extensible compilation system.*