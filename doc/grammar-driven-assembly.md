# Grammar-Driven Assembly and Disassembly Architecture

**STEPS Implementation: Layered Language Architecture for Universal Assembly Tools**

## Executive Summary

This document outlines the design for extending Maru's grammar-driven architecture to automatically generate assemblers and disassemblers for multiple target architectures. By using IR as a universal intermediate representation, we achieve bidirectional transformations while maintaining the STEPS vision of concise, declarative specifications that generate comprehensive tooling.

## Core Architectural Insight

Instead of direct assembly ↔ machine code mapping, we use IR as the universal hub:

```
High-Level Languages → IR ← Assembly Languages
                      ↓
                Machine Code (Multiple Architectures)
```

**Benefits:**
- Leverages existing IR infrastructure
- Simpler unidirectional transformations
- Universal cross-compilation support
- Automatic disassembly via IR pretty-printing
- Consistent semantics across architectures

## Current Maru Architecture Analysis

### Existing STEPS Layers
1. **Base Evaluator**: eval2.c (generated from eval.l/boot.l)
2. **Self-hosting Bootstrap**: boot.l 
3. **PEG Grammar System**: tpeg.l, peg.l
4. **Language Extensions**: irl.g, irgol.g, assembler.k

### Existing IR System (ir.k)
- **Type System**: `<ir-type>`, `<ir-variable>`, `<ir-insn>` hierarchy
- **Code Generation**: `ir-gen-c` methods for C output
- **Symbol Resolution**: Scoped variable binding
- **Instruction Set**: Comprehensive IR operations (arithmetic, control flow, functions)

### Current Assembly System (assembler.k)
- **Multi-method Dispatch**: Instruction-specific handling
- **Expression Evaluation**: Symbol resolution and relocation
- **Multi-pass Assembly**: Forward reference resolution
- **Target Specific**: x86 instruction encoding

## Proposed Extended Architecture

### New STEPS Layers
1. **Base Evaluator** (unchanged)
2. **Self-hosting Bootstrap** (unchanged)
3. **PEG Grammar System** (unchanged)
4. **Architecture Specification Language** (new - ~200 lines)
5. **Generated Assembly Tools** (new - auto-generated)
6. **Target Language Frontends** (existing + new)

## Architecture Specification Language

### Core Concept
Define instruction sets declaratively, generating both assembly grammars and machine code encoders automatically.

### Specification Format
```lisp
(define-architecture x86-64
  
  ;; Register definitions
  (registers
    (%rax (ir-register 'rax 0 64))
    (%rbx (ir-register 'rbx 3 64))
    (%rcx (ir-register 'rcx 1 64))
    ;; ... all registers
  )
  
  ;; Instruction formats
  (instructions
    ;; Move register to register
    (mov-reg-reg
      (syntax "mov" register:src "," register:dst)
      (ir-form (ir-set dst (ir-get src)))
      (encoding (rex-prefix src dst) (0x89) (modrm src dst)))
    
    ;; Move immediate to register  
    (mov-imm-reg
      (syntax "mov" immediate:imm "," register:dst)
      (ir-form (ir-set dst (ir-lit imm)))
      (encoding (rex-prefix dst) (0xb8 + reg-id dst) (imm32 imm)))
    
    ;; Add registers
    (add-reg-reg
      (syntax "add" register:src "," register:dst)
      (ir-form (ir-set dst (ir-add (ir-get dst) (ir-get src))))
      (encoding (rex-prefix src dst) (0x01) (modrm src dst)))
    
    ;; ... more instructions
  )
  
  ;; Addressing modes
  (addressing-modes
    (register-direct register)
    (memory-indirect "[" register "]")
    (memory-offset "[" register "+" immediate "]")
    ;; ... more modes
  )
)
```

### Generated Artifacts

From each architecture specification, automatically generate:

1. **Assembly Grammar** (e.g., x86.g)
2. **IR→Machine Code Encoder** 
3. **Machine Code→IR Decoder**
4. **IR→Assembly Pretty Printer**
5. **Integration with existing IR pipeline**

## Implementation Design

### Phase 1: IR Extension Framework

#### 1.1 Architecture-Specific IR Instructions
```lisp
;; Extend existing IR with architecture-specific operations
(define-class <ir-register> <ir-variable> (arch-id bit-width))
(define-class <ir-machine-insn> <ir-insn> (opcode encoding))

;; Architecture-specific instruction classes
(define-class <ir-x86-mov> <ir-machine-insn> ())
(define-class <ir-x86-add> <ir-machine-insn> ())
```

#### 1.2 Encoding Methods
```lisp
;; Add encoding alongside existing ir-gen-c methods
(define-method ir-gen-machine-code <ir-x86-mov> (arch)
  (emit-bytes arch (rex-prefix self.src self.dst)
                   0x89
                   (modrm self.src self.dst)))

(define-method ir-gen-assembly <ir-x86-mov> (arch)
  (print "mov " (reg-name self.src) ", " (reg-name self.dst)))
```

#### 1.3 Grammar Generator
```lisp
(define-function generate-assembly-grammar (arch-spec)
  ;; Parse architecture specification
  ;; Generate PEG grammar rules
  ;; Output .g file for compilation with tpeg.l
)
```

### Phase 2: X86-64 Proof of Concept

#### 2.1 X86 Architecture Specification
- Complete x86-64 register set
- Core instruction set (mov, add, sub, mul, call, ret, jmp, etc.)
- Addressing modes (register, immediate, memory)
- REX prefix handling for 64-bit operations

#### 2.2 Generated Grammar Example
```peg
# Auto-generated from x86-64 architecture specification

instruction = mov-reg-reg | mov-imm-reg | add-reg-reg | ... ;

mov-reg-reg = "mov"_ register:src ","_ register:dst -> `(ir-x86-mov ,src ,dst) ;
register    = "%rax" -> '%rax | "%rbx" -> '%rbx | ... ;
immediate   = integer ;
```

#### 2.3 Integration with Existing Pipeline
```lisp
;; High-level language → IR → x86 assembly → machine code
(ir-put ir (ir-def 'x 'int (ir-lit 42)))     ; let x := 42
(ir-compile-to-x86 ir)                       ; Generate x86 instructions
```

### Phase 3: Multi-Architecture Support

#### 3.1 Additional Architectures
- **ARM64**: Modern RISC architecture
- **RISC-V**: Open standard RISC architecture  
- **LLVM IR**: Integration with LLVM ecosystem
- **WebAssembly**: Browser and serverless targets

#### 3.2 Cross-Compilation Pipeline
```lisp
;; Single IR → Multiple targets
(let ((ir (compile-irl-file "program.irl")))
  (ir-compile-to-x86 ir "program.x86")
  (ir-compile-to-arm64 ir "program.arm64")
  (ir-compile-to-riscv ir "program.riscv"))
```

#### 3.3 Universal Disassembler
```lisp
;; Machine code → IR → Assembly (any architecture)
(disassemble-x86 binary-data)   ; → IR → x86 assembly
(disassemble-arm64 binary-data) ; → IR → ARM64 assembly
```

### Phase 4: Advanced Features

#### 4.1 IR Optimization Passes
- Dead code elimination
- Register allocation
- Instruction scheduling
- Cross-architecture optimization

#### 4.2 JIT Compilation Support
- Runtime code generation
- Dynamic optimization
- Hot path compilation

#### 4.3 Debugging Integration
- Source-level debugging through IR
- Instruction-level debugging
- Cross-architecture debugging

## Technical Benefits

### 1. STEPS Compliance
Each architecture specification ~200-300 lines generates:
- Assembly parser (~1000+ lines equivalent)
- Machine code encoder (~500+ lines equivalent)  
- Disassembler (~500+ lines equivalent)
- Cross-compilation support (priceless)

### 2. Correctness by Construction
- Single source of truth (architecture specification)
- Automatic consistency between assembly/disassembly
- Type-safe IR prevents many encoding errors

### 3. Retargetability
- New architectures require only specification file
- Automatic toolchain generation
- Consistent interface across all targets

### 4. Integration with Existing Ecosystem
- Leverages all existing IR infrastructure
- Compatible with current high-level language support
- Extends rather than replaces current assembler

## Implementation Roadmap

### Milestone 1: Framework Foundation (2-3 weeks)
- [ ] Extend IR system with architecture-specific instructions
- [ ] Implement architecture specification parser
- [ ] Create grammar generator prototype
- [ ] Basic encoding/decoding framework

### Milestone 2: X86-64 Implementation (3-4 weeks)
- [ ] Complete x86-64 architecture specification
- [ ] Generate and test x86.g grammar
- [ ] Implement core instruction encoders
- [ ] Round-trip testing (assembly → IR → machine code → IR → assembly)

### Milestone 3: Multi-Architecture (4-5 weeks)
- [ ] ARM64 architecture specification
- [ ] RISC-V architecture specification
- [ ] Cross-compilation testing
- [ ] Universal disassembler

### Milestone 4: Advanced Features (3-4 weeks)
- [ ] IR optimization passes
- [ ] JIT compilation support
- [ ] Debugging integration
- [ ] Performance optimization

## Integration with Current Codebase

### Modified Files
- **ir.k**: Extended with architecture-specific instruction classes
- **assembler.k**: Refactored to use IR-based approach
- **Makefile**: Added architecture specification compilation

### New Files
- **arch-spec.l**: Architecture specification language parser
- **generate-arch.l**: Grammar and encoder generator
- **arch/x86-64.arch**: X86-64 architecture specification
- **arch/arm64.arch**: ARM64 architecture specification
- **arch/riscv.arch**: RISC-V architecture specification

### Generated Files
- **x86.g.l**: Generated x86 assembly grammar
- **arm64.g.l**: Generated ARM64 assembly grammar
- **riscv.g.l**: Generated RISC-V assembly grammar

## Risk Assessment and Mitigation

### Technical Risks
1. **IR Abstraction Mismatch**: Some architectural features may not map cleanly to IR
   - *Mitigation*: Extend IR with architecture-specific instruction types as needed

2. **Performance Overhead**: Additional IR layer might impact performance  
   - *Mitigation*: Optimize hot paths, implement direct encoding when needed

3. **Complexity Creep**: System might become too complex despite STEPS goals
   - *Mitigation*: Strict adherence to layer size limits, regular refactoring

### Implementation Risks
1. **Integration Complexity**: Retrofitting existing codebase
   - *Mitigation*: Incremental implementation, maintain backward compatibility

2. **Testing Complexity**: Multiple architectures increase test matrix
   - *Mitigation*: Automated testing, architecture-agnostic test cases

## Conclusion

This design leverages Maru's existing grammar-driven architecture to create a revolutionary assembler/disassembler system. By using IR as the universal intermediate representation, we achieve the STEPS vision of concise specifications generating comprehensive tooling while maintaining architectural elegance and practical utility.

The proposed system would make Maru a unique platform for cross-architecture development, education, and research—a living example of how powerful abstractions can dramatically simplify complex systems.

---

*This document represents the natural evolution of Maru's grammar-driven architecture toward universal assembly tools, maintaining the STEPS principle of "languages as data" while adding practical cross-compilation capabilities.*