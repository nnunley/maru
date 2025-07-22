# ARM64 Backend Implementation for Maru Compiler

## Overview

This document describes the implementation of a native ARM64 assembly code generator for the Maru compiler. The ARM64 backend replaces the previous x86-only copy-paste implementation with proper ARM64 instruction generation.

## Architecture

### Register Allocation Strategy

The ARM64 backend follows the ARM64 Procedure Call Standard (AAPCS64):

- **X0-X7**: Parameter/result registers
- **X8**: Indirect result location register  
- **X9-X15**: Temporary registers
- **X16-X17**: Intra-procedure-call scratch registers
- **X19-X28**: Callee-saved registers
- **X29**: Frame pointer (FP)
- **X30**: Link register (LR)
- **SP**: Stack pointer

### Calling Convention

**Function Prologue**:
```assembly
stp x29, x30, [sp, #-16]!  ; Save frame pointer and link register
mov x29, sp                ; Set up frame pointer
sub sp, sp, #framesize     ; Allocate stack space
```

**Function Epilogue**:
```assembly
mov sp, x29               ; Restore stack pointer
ldp x29, x30, [sp], #16   ; Restore frame pointer and link register
ret                       ; Return
```

## Implementation Details

### Core Components

#### 1. Register Definitions
- **64-bit registers**: X0-X30, SP, XZR
- **32-bit views**: W0-W30, WZR
- **Floating-point**: S0-S31 (32-bit), D0-D31 (64-bit)

#### 2. Instruction Generation

**Load Operations**:
```
IR-INT8   → ldrb w0, [location]
IR-INT16  → ldrh w0, [location] 
IR-INT32  → ldr  w0, [location]
IR-INT64  → ldr  x0, [location]
```

**Store Operations**:
```
IR-INT8   → strb w0, [location]
IR-INT16  → strh w0, [location]
IR-INT32  → str  w0, [location] 
IR-INT64  → str  x0, [location]
```

**Arithmetic Operations**:
```
add: ldr x1, [rhs]; add x0, x0, x1
sub: ldr x1, [rhs]; sub x0, x0, x1
```

**Comparison Operations**:
```
eq: cmp x0, x1; cset x0, eq
```

#### 3. Control Flow

**Conditional Branches**:
```
cmp x0, #0
b.eq label     ; Branch if equal
b.ne label     ; Branch if not equal
```

**Function Calls**:
```
blr x0         ; Branch with link to register
```

#### 4. Memory Operations

**Address Calculation**:
```
add x0, x29, #offset    ; Frame-relative addressing
```

**Indirect Access**:
```
ldr x0, [ptr]          ; Load from pointer
str x0, [ptr]          ; Store to pointer
```

#### 5. Literal Handling

**Immediate Values**:
```
mov w0, #value         ; 32-bit immediate
mov x0, #value         ; 64-bit immediate
```

**String/Float Literals**:
```
adrp x0, label@PAGE    ; Get page address
add  x0, x0, label@PAGEOFF  ; Add page offset
```

### Supported IR Operations

#### Core Operations
- ✅ **Literals**: integers, floats, strings
- ✅ **Variables**: get-var, set-var  
- ✅ **Arithmetic**: add, sub, mul, div
- ✅ **Comparison**: eq, ne, lt, le, ge, gt
- ✅ **Control Flow**: if, while, return
- ✅ **Functions**: calls, prologue/epilogue
- ✅ **Memory**: struct members, address-of
- ✅ **Data Types**: int8/16/32/64, float32/64, pointers

#### Struct Operations
- ✅ **Member access**: `struct.member`
- ✅ **Member assignment**: `struct.member = value`
- ✅ **Address-of**: `&struct.member`
- ✅ **Struct copying**: via memcpy calls

#### Advanced Features  
- ✅ **Local variables**: frame-relative addressing
- ✅ **Function parameters**: AAPCS64 compliant
- ✅ **Return values**: register/memory based
- ✅ **Type casting**: width conversions

## Testing

### Test Suite

The ARM64 backend includes comprehensive tests:

#### test-arm64.k
- **Arithmetic operations**: add, subtract
- **Comparison operations**: equality testing
- **Struct operations**: member access/assignment
- **Function calls**: parameter passing, return values

#### test-ir2.k  
- **Point struct**: x/y coordinates
- **Member operations**: set/get struct fields
- **Printf integration**: string formatting
- **Return values**: integer results

### Verification

The backend generates valid ARM64 assembly that:
- ✅ **Follows AAPCS64**: correct calling convention
- ✅ **Uses proper instructions**: ARM64 opcodes only
- ✅ **Handles all data types**: integers, floats, pointers
- ✅ **Manages stack correctly**: aligned, safe access
- ✅ **Supports debugging**: readable assembly output

## Comparison with x86 Backend

| Feature | x86 Backend | ARM64 Backend |
|---------|-------------|---------------|
| **Registers** | %eax, %ebx, %ecx, %edx | x0-x30, proper allocation |
| **Calling Convention** | x86 cdecl | ARM64 AAPCS64 |
| **Stack Management** | %esp/%ebp based | x29/sp based |
| **Instruction Set** | x86 opcodes | ARM64 opcodes |
| **Memory Model** | Complex addressing | Load/store architecture |
| **Floating Point** | x87/SSE mixed | NEON unified |

## Integration

### Build System

To use the ARM64 backend:

```bash
# Generate ARM64 assembly
./eval2 ir-gen-arm64-new.k maru.k source.k > output.s

# Assemble and link (on ARM64 systems)
as -arch arm64 -o output.o output.s
ld -o output output.o -lSystem
```

### Makefile Integration

```makefile
test-arm64: eval2 .force
	./eval2 ir-gen-arm64-new.k maru.k test-arm64.k > test-arm64.s
	as -arch arm64 -o test-arm64.o test-arm64.s  
	ld -o test-arm64 test-arm64.o -lSystem
	./test-arm64
```

## Performance Characteristics

### Code Quality
- **Efficient instructions**: Uses ARM64 native operations
- **Register usage**: Minimal register pressure
- **Stack management**: Aligned, minimal overhead
- **Memory access**: Load/store optimized

### Optimization Opportunities
- **Register allocation**: Could implement graph coloring
- **Instruction scheduling**: Could reorder for pipeline efficiency  
- **Constant folding**: Could optimize literal operations
- **Dead code elimination**: Could remove unused variables

## Future Enhancements

### Short Term
- **SIMD support**: NEON vector instructions
- **Optimization passes**: Peephole optimizations
- **Better register allocation**: Graph coloring algorithm
- **Instruction scheduling**: Pipeline-aware ordering

### Long Term  
- **Advanced optimizations**: Loop unrolling, inlining
- **Debug information**: DWARF debugging support
- **Profile-guided optimization**: Runtime feedback
- **Cross-compilation**: Generate ARM64 on other platforms

## Error Handling

The backend provides comprehensive error reporting:

```
error: cannot generate literal type: <unknown-type>
error: cannot load indirect: <unsupported-type>  
error: cannot store indirect: <unsupported-type>
```

All unsupported operations are caught at compile time with descriptive error messages.

## Conclusion

The ARM64 backend provides a complete, native code generator for the Maru compiler targeting ARM64 systems. It replaces the previous x86-only implementation with proper ARM64 assembly generation, supporting all major language features while following ARM64 architectural best practices.

The implementation demonstrates:
- **Complete feature coverage**: All IR operations supported
- **Architectural compliance**: Follows ARM64 standards
- **Code quality**: Generates efficient assembly
- **Maintainability**: Clean, documented implementation
- **Extensibility**: Ready for future enhancements

This ARM64 backend enables Maru programs to run natively on ARM64 systems including Apple Silicon Macs, ARM64 Linux systems, and other ARM64 platforms.