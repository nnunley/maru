# Maru Codebase Cleanup & Bootstrap Enhancement Design

## Executive Summary

This design preserves the elegant original bootstrap architecture while enabling progressive enhancement through composition, multi-method dispatch, and grammar generation. The plan establishes a clear multi-level bootstrap progression that maintains backward compatibility while providing modern development capabilities.

## Design Principles

### 1. Bootstrap Preservation & Enhancement
- **Preserve**: Original bootstrap cycle (boot.l → emit.l → eval.l)
- **Enhance**: Progressive bootstrap levels (eval2, boot2, ir2) for advanced features
- **Enable**: Clear upgrade paths between bootstrap levels

### 2. Portable C Bootstrap
- **Generate**: Self-contained C files for any platform
- **Eliminate**: Dependency on native binaries for system exploration
- **Maintain**: Original C evaluator as foundation

### 3. Composition Over Complexity  
- **Prefer**: Multi-method dispatch for clarity and extensibility
- **Use**: Grammar generation for domain-specific languages
- **Apply**: Composition patterns from existing tests (repl.l integration)

## Current Bootstrap Analysis

### Level 0: Original Bootstrap (Preserved)
```
eval (C) → boot.l → emit.l → eval.l → self-hosting system
```
**Status**: Core foundation, must be preserved exactly
**Files**: `eval.c`, `boot.l`, `core/compiler/emit.l`, `eval.l`

### Level 1: Enhanced Bootstrap (In Progress)
```
eval2 (C) → boot2.l → enhanced emit → eval.l + extensions
```
**Status**: Partially implemented, needs completion
**Files**: `eval2`, `core/bootstrap/boot2.l`, enhanced emit systems
**Enhancements**: Color error messages, UTF-8 support, improved diagnostics

### Level 2: Advanced Bootstrap (Planned)
```
eval3/ir2 → boot3.l → IR-based emit → full modern system
```
**Status**: Components exist, needs integration
**Files**: `core/compiler/ir2.k`, advanced emit variants, enhanced libraries
**Features**: IR-based code generation, FFI integration, JIT capabilities
**Note**: Multi-method dispatch is already in Level 0 (original Ian Piumarta design)

## Multi-Level Bootstrap Architecture Design

### Bootstrap Level 0: Foundation (Original)
```
Purpose: Minimal self-hosting compiler
Files:   eval.c, boot.l, core/compiler/emit.l, eval.l
Target:  Academic/research use, minimal system
Status:  Preserved exactly as original Dan/Ian design
```

**Capabilities**:
- Core Lisp evaluation
- Multi-method dispatch system (selectors + multimethods)
- Basic code generation to C
- Self-hosting compilation
- PEG parsing foundation

**Guarantees**:
- Always builds from scratch
- No external dependencies
- Academic clarity maintained
- Original semantics preserved

### Bootstrap Level 1: Enhanced (Improved UX)
```
Purpose: Developer-friendly system with modern UX
Files:   eval2, boot2.l, enhanced emit variants, eval.l+
Target:  Active development, experimentation
Status:  Needs completion and integration
```

**Enhancements over Level 0**:
- Color error messages with ANSI codes
- UTF-8 string support
- Improved error diagnostics
- Better REPL experience
- Port streams integration
- Pretty printing system

**Bootstrap Process**:
```lisp
;; From Level 0
./eval boot.l             ; Load basic system
(load "core/compiler/emit-enhanced.l")  ; Enhanced code generation
(compile-level-1)         ; Generate eval2.c
;; Build eval2, then:
./eval2 boot2.l          ; Load enhanced system
```

### Bootstrap Level 2: Modern (Full Feature Set)
```
Purpose: Production-ready system with all modern features
Files:   eval3/ir2, boot3.l, multi-method emit, full libraries
Target:  Production applications, language research
Status:  Components exist, needs architecture
```

**Enhancements over Level 1**:
- Advanced IR-based code generation (`core/compiler/ir2.k`)
- Grammar generation capabilities  
- FFI system integration (`lib/dlopen.k`)
- Cross-platform architecture support
- JIT compilation capabilities
- Full library ecosystem
- Enhanced multi-method system (builds on original)

**Bootstrap Process**:
```lisp
;; From Level 1
./eval2 boot2.l           ; Load enhanced system
(load "lib/multimethod.l") ; Multi-method dispatch
(load "core/compiler/ir2.k") ; Advanced IR system
(compile-level-2)         ; Generate full system
```

## Portable C Bootstrap Strategy

### Problem: Native Binary Dependencies
Current issue: Need platform-specific eval binaries to explore system

### Solution: Generated C Bootstrap Files

#### Level 0 Portable Bootstrap
```c
// eval0-portable.c - Self-contained bootstrap
// Generated from: eval.c + boot.l + emit.l pre-compiled
// Contains: All bootstrap code embedded as strings
// Build: cc -o eval0 eval0-portable.c -lm
// Usage: ./eval0 [file.l]
```

**Generation Process**:
```lisp
;; From working system
(generate-portable-bootstrap "eval0-portable.c"
  :level 0
  :include-files '("boot.l" "core/compiler/emit.l" "eval.l")
  :embed-strings t
  :self-contained t)
```

#### Level 1 Portable Bootstrap  
```c
// eval1-portable.c - Enhanced bootstrap
// Includes: UTF-8, color errors, port streams
// Build: cc -o eval1 eval1-portable.c -lm -lffi
// Usage: ./eval1 [file.l]
```

#### Level 2 Portable Bootstrap
```c
// eval2-portable.c - Full system bootstrap
// Includes: Multi-methods, FFI, IR system, full libraries
// Build: cc -o eval2 eval2-portable.c -lm -lffi -ldl
// Usage: ./eval2 [file.l]  # Full modern Maru
```

### Implementation Strategy
```lisp
(define-function generate-portable-bootstrap (filename level)
  ;; 1. Collect all required source files
  ;; 2. Embed as C string literals
  ;; 3. Generate initialization code
  ;; 4. Create self-contained C file
  ;; 5. Test bootstrap on clean system
  )
```

## Codebase Reorganization Plan

### Phase 1: Preserve & Organize Core
```
maru/
├── bootstrap/              # All bootstrap levels
│   ├── level0/            # Original system (preserved exactly)
│   │   ├── eval.c         # Original C evaluator
│   │   ├── boot.l         # Original bootstrap
│   │   └── emit.l -> ../core/compiler/emit.l
│   ├── level1/            # Enhanced system
│   │   ├── eval2.c        # Enhanced C evaluator  
│   │   ├── boot2.l        # Enhanced bootstrap
│   │   └── emit-enhanced.l
│   └── level2/            # Modern system
│       ├── eval3.c        # Modern C evaluator
│       ├── boot3.l        # Modern bootstrap
│       └── ir2-emit.l     # IR-based code generation
├── core/                  # Stable compiler components
├── lib/                   # Library ecosystem  
├── arch/                  # Platform-specific backends
└── experiments/           # Experimental code (moved from root)
```

### Phase 2: Multi-Method Integration
Based on existing `repl.l` test patterns, integrate multi-method dispatch:

```lisp
;; From test-repl-with-ports.l pattern
;; Multi-method dispatch for code generation
(define-generic emit-code (target expression context))

(define-method emit-code ((target <c-backend>) expr ctx)
  ;; C code generation
  )

(define-method emit-code ((target <ir-backend>) expr ctx)  
  ;; IR-based generation
  )

(define-method emit-code ((target <jit-backend>) expr ctx)
  ;; JIT compilation  
  )
```

### Phase 3: Grammar Generation Enhancement
Create domain-specific grammars for different bootstrap levels:

```lisp
;; Level 0: Minimal grammar (original)
(define-grammar maru-core
  ((expression (or atom list))
   (atom (or symbol number string))
   (list (sequence "(" (zero-or-more expression) ")"))))

;; Level 1: Enhanced grammar (UTF-8, improved syntax)  
(define-grammar maru-enhanced
  (extend maru-core
    ((string (or simple-string utf8-string))
     (error-form (sequence "ERROR:" message)))))

;; Level 2: Modern grammar (full feature set)
(define-grammar maru-modern
  (extend maru-enhanced  
    ((multimethod-def (sequence "define-method" signature body))
     (grammar-def (sequence "define-grammar" name rules)))))
```

## Implementation Roadmap

### Phase 1: Foundation (Weeks 1-2)
- [x] **Analyze current bootstrap levels** ✓
- [ ] **Reorganize experiments** to `experiments/` directory
- [ ] **Create bootstrap/** directory structure
- [ ] **Test original bootstrap** in isolated environment
- [ ] **Generate Level 0 portable C** file

### Phase 2: Enhancement (Weeks 3-4)  
- [ ] **Complete Level 1 bootstrap** (eval2 + boot2.l)
- [ ] **Integrate port streams** with Level 1
- [ ] **Add UTF-8 and color support** to Level 1
- [ ] **Generate Level 1 portable C** file
- [ ] **Test multi-platform bootstrap**

### Phase 3: Modernization (Weeks 5-8)
- [ ] **Design Level 2 architecture** (ir2 + multi-methods)  
- [ ] **Integrate FFI system** with Level 2
- [ ] **Add JIT capabilities** to Level 2
- [ ] **Complete grammar generation** system
- [ ] **Generate Level 2 portable C** file

### Phase 4: Validation (Weeks 9-10)
- [ ] **Test all bootstrap levels** independently
- [ ] **Verify upgrade paths** between levels
- [ ] **Create comprehensive examples**
- [ ] **Update documentation**
- [ ] **Performance benchmarking**

## Composition & Multi-Method Patterns

### From repl.l Integration Pattern
The `test-repl-with-ports.l` shows the intended composition approach:

```lisp
;; Composition: port.l + repl.l + pretty-print.l
(load "lib/stream/port.l")     ; I/O abstraction
(load "lib/pretty-print.l")    ; Formatting
(load "lib/repl.l")           ; REPL functionality

;; Result: Enhanced REPL with port-based I/O
```

### Multi-Method Dispatch for Emit System
Instead of 30+ emit variants, use multi-method dispatch:

```lisp
;; Using Ian Piumarta's original multi-method system from boot.l
(define-generic emit-expression)

;; Multi-method dispatch (original syntax)
(define-multimethod emit-expression ((<c-emit> backend) expr env)
  (c-emit-dispatch expr env))

(define-multimethod emit-expression ((<ir-emit> backend) expr env)  
  (ir-emit-dispatch expr env))

(define-multimethod emit-expression ((<jit-emit> backend) expr env)
  (jit-emit-dispatch expr env))
```

### Grammar Generation for Domain Clarity
Generate specialized grammars instead of complex parsers:

```lisp
;; Generate PEG grammar for specific domains
(generate-grammar 'maru-assembly
  :base 'maru-core
  :extensions '(register-syntax memory-addressing jump-labels))

(generate-grammar 'maru-ir  
  :base 'maru-core
  :extensions '(ssa-form control-flow type-annotations))
```

## Benefits of This Design

### Technical Benefits
1. **Preserves Original**: Level 0 maintains academic clarity
2. **Enables Progression**: Clear upgrade path through levels
3. **Portable Bootstrap**: No platform-specific binaries needed
4. **Composition**: Multi-method dispatch reduces complexity
5. **Grammar Generation**: Domain-specific clarity

### Development Benefits  
1. **Clean Experimentation**: Separate experiments from core
2. **Progressive Enhancement**: Choose appropriate level for task
3. **Backward Compatibility**: All levels remain functional
4. **Modern Features**: Full feature set available in Level 2
5. **Clear Architecture**: Well-defined component boundaries

### User Benefits
1. **Easy Exploration**: Portable C files work anywhere
2. **Appropriate Complexity**: Choose level matching needs
3. **Modern Development**: Full IDE/tooling support in Level 2
4. **Educational Value**: Can study progression from simple to complex
5. **Production Ready**: Level 2 suitable for real applications

## Conclusion

This design preserves the elegant original Maru architecture while enabling it to evolve into a modern, practical programming language. The multi-level bootstrap approach allows users to choose the appropriate level of complexity for their needs, while the portable C bootstrap strategy eliminates platform dependencies.

The emphasis on composition, multi-method dispatch, and grammar generation follows the patterns already emerging in the codebase, creating a coherent evolution rather than revolutionary change.

**Next Steps**: Begin Phase 1 implementation by reorganizing experiments and creating the bootstrap directory structure, followed by generating the Level 0 portable C bootstrap file.