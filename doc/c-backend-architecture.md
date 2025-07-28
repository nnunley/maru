# C Backend Architecture Analysis and Redesign

## Current Architecture Problems

The Maru C backend currently has a fundamental abstraction mismatch. It's forced to work through an assembly-oriented instruction set, leading to non-idiomatic C code generation.

### The Two-Level Architecture

1. **High-level `gen-` functions** (in emit-base.l):
   - `gen-if`, `gen-while`, `gen-let` - control flow
   - `gen-definition` - top-level definitions
   - These generate assembly-like instructions

2. **Low-level `emit` instructions** (in emit-*.l):
   - `(emit LOAD TI32)`, `(emit ADD TI32)`, etc.
   - `(emit BF LABEL)`, `(emit BR LABEL)` - branches
   - `(emit DEFLABEL LABEL)` - labels
   - Assembly-oriented, assuming registers and jumps

### The Problem

The C backend tries to translate assembly instructions to C:

```lisp
;; gen-if generates:
(gen comp BF label-a)      ; Branch if false
(gen comp BR label-b)      ; Branch
(gen comp DEFLABEL label-a) ; Define label

;; C backend must translate these to:
"if (!_acc) goto label_a;"
"goto label_b;"
"label_a:"
```

This forces C to use:
- `goto` statements for control flow
- An accumulator variable `_acc` to simulate registers
- Temporary variables like `_tmp0` to simulate stack
- Label-based control flow instead of structured programming

## Current C Output Example

```c
oop test_function(oop _param0) {
  oop _acc = nil;
  oop _arg0 = nil;
  oop _tmp0 = nil;
  
  _acc = _param0;
  _tmp0 = _acc;
  _acc = LONG(42);
  if (_acc == nil) goto _L_1;
  _acc = _tmp0;
  goto _L_2;
_L_1:
  _acc = LONG(0);
_L_2:
  return _acc;
}
```

## Proposed Architecture

### Assembly Backends (x86, ARM64)
Continue using the current two-level architecture:
- `gen-` functions generate abstract instructions
- `emit` methods translate to assembly

### C Backend
Override the `gen-` functions to generate C directly:

```lisp
(define-method gen-if <c-compiler> (expr comp)
  (emit-write "if (")
  (gen-c-expr (cadr expr) comp)
  (emit-writeln ") {")
  (gen-c-block (caddr expr) comp)
  (when (cdddr expr)
    (emit-writeln "} else {")
    (gen-c-block (cdddr expr) comp))
  (emit-writeln "}"))
```

This would generate:
```c
if (param0) {
  return param0;
} else {
  return 0;
}
```

## Benefits of Proper Abstraction

1. **Idiomatic C Code**: Natural C constructs instead of goto-based flow
2. **Better Optimization**: C compilers can better optimize structured code
3. **Readable Output**: Generated C is maintainable and debuggable
4. **Simpler Backend**: No need to simulate assembly in C
5. **Type Safety**: Can leverage C's type system properly

## Implementation Strategy

1. Create new C-specific gen methods:
   - `gen-c-if`, `gen-c-while`, `gen-c-let`
   - `gen-c-expr` for expression evaluation
   - `gen-c-block` for statement blocks

2. Remove assembly instruction definitions from emit-c.l:
   - No more `(define-emit (BR LABEL) ...)`
   - No more accumulator-based arithmetic

3. Generate proper C constructs:
   - Use C's expression evaluation
   - Use return statements instead of accumulator
   - Use local variables with meaningful names
   - Use C operators directly

## Example: Proper C Backend

```lisp
;; Instead of generating: _acc = LONG(getLong(_acc) + getLong(_tmp0));
;; Generate: result = a + b;

(define-method gen-binary-op <c-compiler> (op arg1 arg2 comp)
  (let ((temp (new-c-temp comp)))
    (emit-write "long " temp " = ")
    (gen-c-expr arg1 comp)
    (emit-write " " (c-operator op) " ")
    (gen-c-expr arg2 comp)
    (emit-writeln ";")
    temp))
```

## Migration Path

1. Start with high-value functions: `gen-if`, `gen-while`
2. Add C-specific expression generation
3. Gradually remove assembly instructions
4. Update test suite to verify idiomatic output
5. Benchmark to ensure no performance regression

This architecture respects the language's design while generating code appropriate to each target platform.