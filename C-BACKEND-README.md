# Maru C Backend Implementation

## Overview

This directory contains the C backend implementation for the Maru metacircular compiler. The C backend generates portable C code instead of assembly, following the clever two-pass strategy from `emit-gc-c.l`.

## Key Files

### Core Implementation
- **`emit-c.l`** - The comprehensive C backend with two-pass compilation
  - Implements forward declarations to handle circular dependencies
  - Uses `init_globals()` function to initialize global variables
  - Generates clean, readable C code (not assembly instructions)
  - Based on the design from `EMIT-RESTRUCTURE-DESIGN.md`

- **`emit-c-simple.l`** - A simple working C backend for testing
  - Minimal implementation that demonstrates the concept
  - Good for understanding the basic approach
  - Used in `test-maru-to-c-optimized.l`

- **`emit-common-spec.l`** - Backend abstraction specification
  - Defines the multi-method interface for all backends
  - Common structures and generic functions
  - Foundation for backend-independent compilation

### Documentation
- **`EMIT-RESTRUCTURE-DESIGN.md`** - Complete design document for the emit system restructuring
- **`test-maru-to-c-optimized.l`** - Demonstration of optimized C code generation

### Draft/Reference
- **`emit-c-multimethod-draft.l`** - Early draft using multi-methods (has port-format issues)

## Two-Pass Compilation Strategy

The clever strategy from `emit-gc-c.l`:

1. **Pass 1**: Collect all function signatures and global variables
2. **Generate forward declarations** for all functions
3. **Generate global variables** initialized to `nil`
4. **Pass 2**: Generate actual function implementations
5. **Create `init_globals()`** function that sets actual values

This approach solves circular dependency issues in C code generation.

## Example Usage

```lisp
;; Load the C backend
(require "emit-c.l")

;; Generate C code for an environment
(gen-env-c my-environment)
```

## Generated C Code Example

```c
/* Forward declarations */
static oop _add(/* 2 params */);
static oop _factorial(/* 1 params */);

/* Global variables */
static oop _pi = nil;
static oop _answer = nil;

/* Function implementations */
static oop _add(oop _a, oop _b) {
    oop _result = oop_from_long(long_from_oop(_a) + long_from_oop(_b));
    return _result;
}

/* Initialize global variables */
static void init_globals(void) {
    _pi = oop_from_long(3);
    _answer = oop_from_long(42);
}

int main(int argc, char *argv[]) {
    init_globals();
    /* program logic here */
    return 0;
}
```

## Key Features

1. **High-level C generation** - Not assembly instructions in C syntax
2. **Tagged integers** - Uses `LONG(n)` and `getLong(x)` macros
3. **Proper forward declarations** - Handles mutual recursion
4. **Clean initialization** - Avoids circular dependency issues
5. **Readable output** - Generated C is clean and maintainable

## Future Work

- Integration with the main emit system
- Additional C backend optimizations
- Support for more Maru features
- Performance improvements