# evalm - Multi-Method Evaluator Usage Guide

## Overview

The `evalm` binary is a working demonstration of multi-method dispatch for evaluation in Maru. It provides an interactive REPL that shows how type-based method dispatch works without using switch statements.

## Quick Start

```bash
# Start the interactive REPL
./evalm

# You'll see a prompt like:
evalm> 

# Try these examples:
evalm> 42
=> 42

evalm> "hello"
=> "hello"

evalm> (+ 1 2 3)
=> 6

evalm> (quote foo)
=> foo

evalm> (if 1 'yes 'no)
=> yes

# Get help
evalm> :help

# See dispatch tables
evalm> :methods

# Run demonstration
evalm> :demo

# Exit
evalm> :quit
```

## Architecture

The evalm system demonstrates:

- **Multi-method dispatch**: Each type has its own evaluation method
- **O(1) lookup**: Methods found via array index, not switch statements
- **Extensible design**: New types can be added without changing core evaluator
- **Clean separation**: Each type's logic stays with that type

## Key Features

1. **Type-based dispatch**: 
   - Numbers → `mm-eval-number`
   - Strings → `mm-eval-string` 
   - Symbols → `mm-eval-symbol`
   - Pairs (lists) → `mm-eval-pair`

2. **No giant switch statements**: Each type has its own method

3. **Extensible**: New types can be added by registering new methods

## Commands

- `:help` - Detailed help information
- `:demo` - Run demonstration of different types
- `:methods` - Show registered dispatch methods
- `:explore` - Comprehensive guide to Maru introspection and reflection
- `:quit` - Exit the REPL (now properly exits without looping)

## Implementation Details

The evalm system uses two dispatch tables:
- `*eval-methods*` - For evaluation dispatch
- `*print-methods*` - For pretty-printing dispatch

Each type ID maps to its corresponding method function, providing O(1) dispatch without conditional logic.

## Comparison to Traditional Approach

**Traditional (switch-based):**
```lisp
(define-function eval (obj)
  (cond
    ((number? obj) ...)
    ((string? obj) ...)
    ((symbol? obj) ...)
    ((pair? obj) ...)
    (else ...)))
```

**Multi-method (dispatch-based):**
```lisp
(define-function mm-eval (obj env)
  (let* ((type-id (type-of obj))
         (method (array-at *eval-methods* type-id)))
    (method obj env)))
```

The multi-method approach is cleaner, more extensible, and follows the Open/Closed Principle.

## Exploring Maru's Reflection System

The `:explore` command provides a comprehensive guide to Maru's introspective capabilities:

### Type Inspection Functions
- `(type-of obj)` - Returns numeric type ID (0=undefined, 2=long, 4=string, 5=symbol, 6=pair, etc.)
- `(pair? obj)`, `(symbol? obj)`, `(string? obj)` - Type predicates
- `(defined? sym)` - Check if a symbol is defined

### Data Structure Introspection  
- `(car obj)`, `(cdr obj)` - Access pair elements
- `(length obj)` - Get length of lists/arrays
- `(dump obj)` - Debug dump showing internal structure

### Evaluation System Access
- `(eval expr)` - Evaluate expressions dynamically
- `(expand expr)` - Show macro expansions
- `(apply fn args)` - Dynamic function application

### Memory and Object Inspection
- `(address-of obj)` - Get memory addresses
- `(oop-at obj i)` - Access object internals
- `(subr-name fn)` - Get names of built-in functions

### Examples
```lisp
evalm> (type-of 42)
=> 2

evalm> (type-of "hello")  
=> 4

evalm> (dump (cons 'a 'b))
=> [shows internal structure]

evalm> (defined? 'undefined-symbol)
=> ()

evalm> (subr-name +)
=> " +"
```

This makes evalm not just a multi-method demonstration, but also a powerful tool for exploring Maru's internals interactively.