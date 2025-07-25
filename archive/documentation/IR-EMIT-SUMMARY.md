# IR-Based Emit Implementation Summary

## What We Discovered

### 1. Current emit.l Architecture
- **Does NOT use the IR system** - it's a direct code generator
- Generates assembly-like operations (TEXT, DATA, SECTION, etc.)
- Has been extended with ARM64 support
- Originally generated x86 assembly, now can target multiple architectures

### 2. Two Parallel Code Generation Paths
Maru has two separate approaches to code generation:

#### Direct Generation (emit.l)
- Lower-level, direct assembly/C generation
- Used by the current bootstrap process
- Generates eval2.c

#### IR System (ir.k, ir-gen-*.k)
- Higher-level intermediate representation
- Multiple backend targets (C, x86, ARM64, LLVM IR)
- More structured approach
- Uses Maru's class system with inheritance

### 3. Key Challenges for IR-Based emit.l

#### Language Mismatch
- IR system is written in `.k` files (Maru syntax)
- emit.l is written in `.l` files (S-expression syntax)
- Loading .k files from .l files requires careful setup

#### Type System Requirements
- IR system uses `define-class` with inheritance
- Simple `define-structure` doesn't support the inheritance needed
- Would need to use Maru's full object system

#### Missing Functions
- `array-last` - easily added
- `array-append-all` - easily added
- Various other utility functions

### 4. Simplified IR Approach
We created `emit-ir-simple.l` demonstrating a simplified IR approach that:
- Uses basic structures without inheritance
- Shows the conversion pipeline: S-expr → IR → C
- Works within the constraints of .l file syntax

### 5. Conclusions

#### Why Current emit.l Doesn't Use IR
1. **Historical**: emit.l predates the IR system
2. **Bootstrap**: Need simple, direct generation for bootstrap
3. **Complexity**: IR system adds layers that aren't needed for basic compilation

#### Benefits of IR-Based Approach
1. **Multiple Targets**: Easy to add new backends
2. **Optimization**: Can perform IR-level optimizations
3. **Cleaner Abstraction**: Separates parsing from code generation
4. **Type Safety**: Better type checking at IR level

#### Implementation Path
To create a full IR-based emit.l:
1. Port IR structures to use Maru's class system in .l syntax
2. Implement IR builders for all Maru constructs
3. Create backend selector for different targets
4. Integrate with existing compilation pipeline

## Recommendation

For now, the existing emit.l serves its purpose well for bootstrapping. An IR-based version would be valuable as:
- A parallel implementation for experimentation
- A cleaner architecture for adding new features
- A path toward better optimization

But it shouldn't replace the current emit.l until it's proven stable and can successfully bootstrap the entire system.