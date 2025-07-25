# evalm - Complete Multi-Method Evaluator Guide

## Overview

The `evalm` binary is a fully functional multi-method evaluator REPL that demonstrates advanced dispatch techniques in Maru. It provides both an interactive demonstration of multi-method concepts and a comprehensive guide to Maru's introspective capabilities.

## Quick Start

```bash
# Start the interactive REPL
./evalm

# Exit cleanly (fixed - no more infinite loops!)
evalm> :quit
```

## Key Features

### 1. Multi-Method Dispatch Demonstration
- **O(1) Dispatch**: Uses array lookup instead of switch statements
- **Type-Based Routing**: Each type has its own evaluation method
- **Extensible Architecture**: New types can be added without modifying core evaluator
- **Clean Separation**: Each type's logic isolated in its own method

### 2. Interactive Commands

| Command | Description |
|---------|-------------|
| `:help` | Detailed help and architectural explanation |
| `:demo` | Live demonstration of multi-method dispatch |
| `:methods` | Show current dispatch table status |
| `:explore` | **NEW**: Comprehensive Maru introspection guide |
| `:quit` | **FIXED**: Properly exits without looping |

### 3. Maru Introspection System Guide

The `:explore` command provides a complete reference to Maru's reflective capabilities:

#### Type System Exploration
- `type-of` function returns numeric type IDs
- Type constants: 0=undefined, 2=long, 4=string, 5=symbol, 6=pair, etc.
- Type predicates: `pair?`, `symbol?`, `string?`, `long?`, `fixed?`

#### Data Structure Inspection
- Access functions: `car`, `cdr`, `cadr`, `caddr`
- Length and indexing: `length`, `array-at`, `string-at`
- Debug output: `dump` for internal structure viewing

#### Evaluation System Access
- Dynamic evaluation: `eval`, `expand`, `apply`
- Environment inspection: `defined?`
- Function introspection: `subr-name`, `address-of`

#### Memory and Object System
- Allocation: `allocate`, `allocate-atomic`
- Object access: `oop-at`, `set-oop-at`
- Memory addresses: `address-of`

#### Output and Debugging
- Print functions: `print`, `dump`, `warn`, `format`
- Rich debugging information available

## Architecture Comparison

### Traditional Approach (Switch-Based)
```lisp
(define-function eval (obj)
  (cond
    ((number? obj) ...)
    ((string? obj) ...)
    ((symbol? obj) ...)
    ((pair? obj) ...)
    (else ...)))
```

### Multi-Method Approach (Dispatch-Based)
```lisp
(define-function mm-eval (obj env)
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (method obj env)))
```

**Advantages of Multi-Method Approach:**
- **Performance**: O(1) dispatch vs O(n) conditionals
- **Maintainability**: Each type's logic is isolated
- **Extensibility**: New types added without changing core
- **Open/Closed Principle**: Open for extension, closed for modification

## Supported Expressions in evalm Demo

The evalm environment supports these expressions for demonstration:

```lisp
42                    # Self-evaluating numbers
"hello"               # Self-evaluating strings
(+ 1 2 3)            # Arithmetic operations
(quote foo)          # Quoted symbols
(if condition then else) # Conditional expressions
(cons 1 2)           # Pair construction
```

## Full Maru Introspection (Use ./eval)

For complete access to Maru's introspective features, use the main Maru REPL:

```bash
# Start full Maru REPL
./eval

# Try introspection functions
(type-of 42)                    # => 2
(type-of "hello")               # => 4
(dump (cons 'a 'b))            # Shows internal structure
(subr-name +)                  # => " +"
(defined? 'undefined-symbol)   # => ()
```

## Implementation Details

### Dispatch Tables
- `*eval-methods*`: 32-element array mapping type IDs to evaluation methods
- `*print-methods*`: 32-element array mapping type IDs to printing methods
- O(1) lookup performance via direct array indexing

### Method Registration
```lisp
(mm-register-eval-method MM-LONG mm-eval-number)
(mm-register-eval-method MM-STRING mm-eval-string)
(mm-register-eval-method MM-PAIR mm-eval-pair)
# etc.
```

### Type Constants
```lisp
(define MM-UNDEFINED 0)
(define MM-LONG 2)
(define MM-STRING 4)
(define MM-SYMBOL 5)
(define MM-PAIR 6)
```

## Benefits Demonstrated

1. **Clean Architecture**: Each type has its own method, following single responsibility
2. **Performance**: O(1) dispatch eliminates conditional overhead
3. **Extensibility**: New types can be added without touching existing code
4. **Maintainability**: Changes to one type don't affect others
5. **Debuggability**: Easy to trace which method handles which type

## Files Created

- `evalm` - The executable binary (script launching eval + evalm.l)
- `evalm.l` - The multi-method evaluator implementation
- `EVALM-USAGE.md` - Basic usage guide
- `EVALM-COMPLETE-GUIDE.md` - This comprehensive guide

## Use Cases

### Learning Multi-Method Dispatch
Use evalm to understand how type-based dispatch works without the complexity of switch statements.

### Exploring Maru Internals
Use the `:explore` command to learn about Maru's introspective capabilities and then experiment in the full Maru REPL.

### Understanding Language Implementation
See how a practical evaluator can be built using clean, extensible architecture principles.

### Performance Analysis
Observe the difference between O(1) dispatch and traditional conditional evaluation.

## Next Steps

This implementation demonstrates core concepts. Production systems could extend it with:

- More sophisticated type systems
- Method combination strategies
- Multiple dispatch (dispatching on multiple arguments)
- Dynamic method registration
- Performance monitoring and optimization

The evalm system successfully bridges theory and practice, showing how multi-method dispatch can create cleaner, more maintainable, and more performant language implementations.