# Simple emit.l Split Approach

## Current Analysis

The emit.l file mixes:
1. Core compiler infrastructure (operands, instructions, compiler state)
2. x86 assembly generation (emit methods)
3. High-level code generation (gen methods)

## Simple Split Strategy

Instead of a major reorganization, we can:

1. **emit.l** - Keep as main file with core infrastructure
2. **emit-x86.l** - Extract only the x86-specific emit methods
3. **emit.l** then requires emit-x86.l at the end

This minimizes changes and risk while still achieving modularity.

## Benefits
- Minimal changes to existing code
- Easy to test (just move emit methods)
- Can extend later with emit-arm.l, emit-c.l, etc.
- Maintains compatibility with existing build system