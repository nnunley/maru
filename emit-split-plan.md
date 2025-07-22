# emit.l Splitting Plan

## Overview
Split emit.l into three logical components:
1. **emit-core.l** - Core structures, utilities, and abstract code generation
2. **emit-asm-x86.l** - x86 assembly code generation
3. **emit-c.l** - C code generation (future implementation)

## File Structure

### emit-core.l
- Core structures (<extern>, <variable>, <env>, operands, instructions)
- Utility functions (align, mangle-label, temp-label-name)
- Abstract emit infrastructure (define-emit macro, generic emit)
- High-level code generation (gen methods for forms, expressions)
- Compiler structure and state management

### emit-asm-x86.l
- All x86-specific emit methods (TEXT, DATA, ENTER, LEAVE, etc.)
- x86 instruction implementations (ADD, SUB, MUL, DIV, etc.)
- x86-specific operand types if any
- Platform-specific sections (MACH, WIN32)

### emit-c.l
- C code generation backend (to be implemented)
- Would emit C code instead of assembly
- Similar structure to emit-asm-x86.l but outputs C

## Benefits
1. **Modularity** - Clear separation of concerns
2. **Extensibility** - Easy to add new backends (ARM, LLVM, etc.)
3. **Maintainability** - Easier to understand and modify
4. **Reusability** - Core can be shared across backends

## Implementation Steps
1. Create emit-core.l with shared structures and high-level generation
2. Create emit-asm-x86.l with x86-specific emit methods
3. Update emit.l to require both files
4. Test to ensure functionality is preserved
5. Eventually replace emit.l with a loader that selects appropriate backend