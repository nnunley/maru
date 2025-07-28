# Multimethod Backend Dispatch System

## Overview

The multimethod backend dispatch system provides a clean, extensible architecture for code generation in Maru. It addresses the fundamental abstraction mismatch between assembly-oriented emit instructions and high-level language backends like C.

## Architecture

### Backend Types

```lisp
(define-structure <backend> ())
(define-structure <asm-backend> (<backend>))
(define-structure <c-backend> (<backend>))

(define asm-backend (new <asm-backend>))
(define c-backend (new <c-backend>))
```

### Multimethod Selectors

The system defines multimethod selectors for each major code generation operation:

- `emit-if` - Conditional statements
- `emit-while` - Loop constructs
- `emit-let` - Local variable bindings
- `emit-set` - Variable assignment
- `emit-value` - Literal values
- `emit-expr` - Expression evaluation
- `emit-definition` - Function definitions

### Method Dispatch

Each backend implements these methods differently:

#### Assembly Backend
- Delegates to original gen- functions
- Generates low-level assembly instructions
- Works with labels, branches, and stack operations

#### C Backend
- Generates idiomatic C code directly
- Produces readable, maintainable output
- Handles C-specific constructs (types, declarations, etc.)

## Implementation Details

### Expression Handling

The `emit-expr` method serves as the main dispatcher:

```lisp
(define-method emit-expr <c-backend> (expr comp)
  (cond
    ((not expr) (emit-write "0"))              ; Empty list
    ((or (long? expr) (string? expr) ...)      ; Literals
     (emit-value self expr comp))
    ((pair? expr)                               ; Expressions
     (let ((head (car expr)))
       (cond
         ((= head 'if) (emit-if self expr comp))
         ((= head 'while) (emit-while self expr comp))
         ...
         ;; Binary operations
         ((member? head '(+ - * / < > <= >= = !=))
          (emit-write "(")
          (emit-expr self (cadr expr) comp)
          (emit-write " " (operator->c head) " ")
          (emit-expr self (caddr expr) comp)
          (emit-write ")"))
         ;; Function calls
         (else ...))))))
```

### C Code Generation Examples

#### If Statement
```lisp
(if (> x 0) x 0)
```
Generates:
```c
if ((x > 0L)) {
  x;
} else {
  0L;
}
```

#### While Loop
```lisp
(while (> n 0) (set n (- n 1)))
```
Generates:
```c
while ((n > 0L)) {
  n = (n - 1L);
}
```

#### Let Binding
```lisp
(let ((x 10) (y 20)) (+ x y))
```
Generates:
```c
{
  long x = 10L;
  long y = 20L;
  (x + y);
}
```

#### Function Definition
```lisp
(lambda (x y) (+ x y))
```
Generates:
```c
long add(long x, long y) {
  (x + y);
  return (x + y);
}
```

### Special Handling

#### Main Function
The system recognizes `main` and generates appropriate C signature:
```c
int main(int argc, char **argv) {
  // body
  return 0;
}
```

#### String Escaping
Properly escapes C string literals:
- `\"` → `\"`
- `\n` → `\n`
- Control characters → octal escapes

#### Identifier Mangling
Converts Lisp identifiers to valid C names:
- `my-function` → `my_2Dfunction`
- `array-at` → `array_2Dat`

## Usage

### Basic Usage

```lisp
(require "core/compiler/backend-dispatch.l")

;; Create a compiler instance
(define comp (compiler 0))

;; Generate C code
(emit-expr c-backend '(+ 42 58) comp)

;; Generate assembly
(emit-expr asm-backend '(+ 42 58) comp)
```

### Backend Selection

The system supports multiple backends coexisting:

```lisp
;; Use C backend for main code generation
(emit-definition c-backend function-expr 'my-func comp)

;; Switch to assembly for performance-critical sections
(emit-expr asm-backend critical-expr comp)
```

## Benefits

1. **Clean Abstraction**: Each backend works at its natural abstraction level
2. **Extensibility**: Easy to add new backends (Java, JavaScript, LLVM IR, etc.)
3. **Maintainability**: Backend-specific code is isolated and organized
4. **Type Safety**: Multimethod dispatch ensures correct backend usage
5. **Code Quality**: Generates idiomatic code for each target language

## Future Enhancements

1. **Environment Variable Selection**: Use MARU_EMIT_BACKEND to choose default
2. **Additional Backends**: JavaScript, Java, LLVM IR, WebAssembly
3. **Optimization Passes**: Backend-specific optimizations
4. **Debug Information**: Source location tracking for generated code
5. **Pretty Printing**: Better formatting of generated C code

## Files

- `core/compiler/backend-dispatch.l` - Main implementation
- `test-backend-dispatch.l` - Basic tests
- `test-multimethod-comprehensive.l` - Comprehensive test suite
- `doc/c-backend-architecture.md` - Architecture documentation

## Conclusion

The multimethod backend dispatch system provides a robust foundation for multi-target code generation in Maru. It solves the abstraction mismatch problem elegantly while maintaining backward compatibility with the existing assembly-oriented infrastructure.