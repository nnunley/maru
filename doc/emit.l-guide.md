# emit.l - Maru Code Generation Engine

## Overview

`emit.l` is the code generation backend for the Maru compiler. It transforms Maru expressions (the AST) directly into target code through a sophisticated **polymorphic dispatch system**. The same instruction sequences can generate different output formats (x86 assembly, C code, etc.) by overriding emit methods.

## Architecture

### Four-Layer Architecture

```
┌─────────────────────────────────────┐
│  Backend Abstraction Layer         │  ← emit methods (overrideable)
├─────────────────────────────────────┤
│  Code Generation Pipeline          │  ← gen methods, compiler state
├─────────────────────────────────────┤  
│  Instruction Definition System     │  ← define-emit, multimethod dispatch
├─────────────────────────────────────┤
│  Operand Definition System         │  ← define-operand, type system
└─────────────────────────────────────┘
```

### Data Flow

```
Maru Expression → gen() → Instruction Sequence → emit() → Target Code
     ↓              ↓           ↓                   ↓         ↓
  <pair>,        TI32,       [LOAD, ADD,         x86 asm   "movl $42,%eax"  
  <variable>,    GI32,        SUB, STORE]        or C      "_acc = LONG(42);"
  <string>       LI32,                           
                 LABEL
```

## Core Components

### 1. Operand Type System

Four operand types encapsulate different value representations:

#### `TI32` - Temporary/Stack Variables
```lisp
(TI32 offset)  ; Stack slot at offset from frame pointer
```
- **Usage**: Local variables, function parameters, intermediate values
- **Printing**: 
  - x86: `"offset(%esp)"` 
  - C: `"_tmp4"` (calculated from offset)

#### `GI32` - Global Variables  
```lisp
(GI32 name)    ; Global variable by name
```
- **Usage**: Global symbols, function names
- **Printing**: Direct symbol name

#### `LI32` - Literal Integers
```lisp
(LI32 value)   ; Immediate integer constant
```
- **Usage**: Compile-time constants
- **Printing**: 
  - x86: Direct value
  - C: `"LONG(value)"` (tagged integer)

#### `LABEL` - Code Labels
```lisp
(LABEL name)   ; Code label for jumps/calls
```
- **Usage**: Control flow targets, function addresses
- **Printing**: Mangled label name with prefix

### 2. Instruction Definition System

#### Instruction Declaration
```lisp
(define-instruction LOAD)  ; Creates <LOAD> type and LOAD instance
```

#### Emit Method Definition
```lisp
(define-emit (LOAD LI32)      ; Multimethod: LOAD instruction + LI32 operand
  (println "  movl $" $1 ",%eax"))  ; $1 = first operand
```

**Critical**: Operands must be **separate arguments** to println, not inside quotes:
```lisp
;; CORRECT:
(println "  movl $" $1 ",%eax")

;; WRONG (causes syntax errors):
(println "  movl $"$1",%eax")
```

### 3. Code Generation Pipeline

#### Compiler State (`<compiler>`)
```lisp
(define-structure <compiler> (
  level           ; Compilation nesting level
  param-counter   ; Parameter stack offset counter
  arg-counter     ; Argument preparation counter  
  arg-limit       ; Maximum arguments used
  tmp-counter     ; Temporary variable counter
  tmp-limit       ; Maximum temporaries used
  temps           ; Free temporary list
  epilogue        ; Function exit label
  asm             ; Instruction array
  pc              ; Program counter
))
```

#### Two-Phase Generation

**Phase 1: Instruction Generation**
- `gen` methods walk Maru expressions
- Instructions accumulate in `(<compiler>-asm comp)` array
- Resource usage tracked (temporaries, arguments)

**Phase 2: Code Emission**  
- Calculate stack frame sizes with alignment
- Adjust stack offsets for all operands
- Emit prologue/epilogue with correct frame size
- Emit accumulated instructions

#### Memory Layout
```
Stack Growth (downward)
├─ Function Parameters  (negative offsets)
├─ Saved Frame Pointer  
├─ Local Variables      (positive offsets)
├─ Argument Preparation (arg-counter)
└─ Temporary Variables  (tmp-counter)
```

### 4. Expression Compilation (`gen` methods)

#### Arithmetic Expressions
```lisp
(define-function generate-binary (op args comp)
  (let ((tmp (gen-tmp (cadr args) comp)))    ; Evaluate right operand first
    (gen (car args) comp)                    ; Evaluate left operand  
    (free-temp comp tmp)                     ; Free temporary
    (gen comp op tmp)))                      ; Apply operation
```

**Why right-first?** Maintains correct evaluation order for nested expressions:
```lisp
(+ (f) (g))  ; Must call f() first, but need g()'s result in temp
```

#### Control Flow

**If Statements:**
```lisp
(gen-if expr comp)
  condition → BF else_label → then_code → BR end_label 
           → else_label: → else_code → end_label:
```

**While Loops:**
```lisp
(gen-while expr comp)  
  BR test_label → body_label: → body_code 
               → test_label: → condition → BT body_label
```

#### Function Calls
```lisp
(gen function-call comp)
  1. Evaluate arguments → store in temps
  2. MOVE temps to argument slots (left to right)
  3. CALL with argument count
  4. Result in accumulator register
```

### 5. Backend Abstraction

#### x86 Assembly Backend (default)
```lisp
(define-emit (ADD TI32)
  (println "  addl " $1 ",%eax"))
```

#### C Code Backend (emit-c.l)
```lisp
(define-emit (ADD TI32)  
  (c-indent) (println "_acc = LONG(getLong(_acc) + getLong(" $1 "));"))
```

**Same instruction sequence, different output!**

## Instruction Set Reference

### Arithmetic Operations
- `NEG` - Negate accumulator
- `ADD TI32` - Add temporary to accumulator  
- `SUB TI32` - Subtract temporary from accumulator
- `MUL TI32` - Multiply accumulator by temporary
- `DIV TI32` - Divide accumulator by temporary
- `AND TI32` - Bitwise AND with temporary
- `OR TI32` - Bitwise OR with temporary  
- `XOR TI32` - Bitwise XOR with temporary

### Comparison Operations
- `LT TI32` - Less than comparison
- `LE TI32` - Less than or equal
- `EQ TI32` - Equality comparison
- `NE TI32` - Not equal comparison  
- `GE TI32` - Greater than or equal
- `GT TI32` - Greater than comparison
- `SLA TI32` - Shift left arithmetic
- `SRA TI32` - Shift right arithmetic

### Control Flow
- `BR LABEL` - Unconditional branch
- `BF LABEL` - Branch if accumulator false (zero/nil)
- `BT LABEL` - Branch if accumulator true (non-zero/non-nil)
- `CALL LABEL` - Call function by label
- `CALL long` - Call function by address (accumulator)

### Data Movement
- `LOAD LI32` - Load immediate integer
- `LOAD LABEL` - Load label address
- `LOAD GI32` - Load global variable  
- `LOAD TI32` - Load temporary variable
- `STORE TI32` - Store accumulator to temporary
- `STORE GI32` - Store accumulator to global
- `ADDR GI32` - Load address of global
- `ADDR TI32` - Load address of temporary
- `MOVE TI32 TI32` - Copy between temporaries

### Memory Access
- `CHR-AT TI32` - Load character at offset
- `SET-CHR-AT TI32 TI32` - Store character at offset  
- `OOP-AT TI32` - Load object at offset
- `SET-OOP-AT TI32 TI32` - Store object at offset

### Meta Operations
- `TEXT` - Switch to code section
- `DATA` - Switch to data section
- `DEFLABEL LABEL` - Define label
- `COMMENT pair` - Generate comment
- `ENTER long` - Function prologue
- `LEAVE long` - Function epilogue

## Integration with Maru

### Bootstrap Compilation
```lisp
(compile-begin)              ; Set up compilation environment
  (define-function foo ...)  ; Function definitions
  (define main ...)          ; Main function
(compile-end)                ; Process all definitions
```

#### What happens:
1. `compile-begin` creates new environment level
2. Functions compile to `<expr>` objects with definition  
3. `compile-end` calls `gen-env` to process all definitions
4. `gen-definition` compiles each function with emit.l

### Definition Types

#### Functions (`<expr>`)
```lisp
(define-function add (a b) (+ a b))
```
Generates complete function with prologue/epilogue, parameter setup, stack frame.

#### Constants (`<long>`, `<string>`)  
```lisp
(define pi 3.14159)
```
Generates data definitions in appropriate sections.

#### External Functions (`<extern>`)
```lisp
(define printf (extern 'printf))  
```
Generates stub entries for dynamic linking.

## Creating New Backends

### Step 1: Override Emit Methods
```lisp
;; Override arithmetic for new target
(define-emit (ADD TI32)
  (my-target-add-instruction $1))
```

### Step 2: Override Operand Printing  
```lisp
;; Change how operands print
(define-method do-print <TI32> ()
  (print "reg[" (<TI32>-offset self) "]"))
```

### Step 3: Override Definition Generation
```lisp  
;; Change function definition format
(define-method gen-definition <expr> (name comp)
  (my-target-function-header name)
  ;; ... standard compilation ...
  (my-target-function-footer))
```

### Step 4: Override Environment Processing
```lisp
;; Change file structure 
(define-function gen-env-mytarget (env)
  (my-target-file-header)
  ;; ... process definitions ...  
  (my-target-file-footer))
```

### Example: C Backend (emit-c.l)
The C backend demonstrates all these techniques:
- Uses `oop` typedef instead of raw values
- `LONG()`/`getLong()` macros for tagged integers  
- `_acc` variable instead of `%eax` register
- Function signatures with proper C types
- Complete C file structure with headers

## Debugging Guide

### Common Issues

#### 1. String Concatenation Errors
**Symptom**: Syntax errors, "unexpected character" 
**Cause**: Operand variables inside quoted strings
**Fix**: Separate operands as println arguments
```lisp
;; Wrong:
(println "movl $"$1",%eax")  

;; Right:  
(println "movl $" $1 ",%eax")
```

#### 2. Missing Function Errors
**Symptom**: "function not defined"
**Cause**: Instructions used before definition
**Fix**: Ensure `define-emit` comes before use

#### 3. Unbalanced Parentheses  
**Symptom**: EOF errors, "unexpected end of input"
**Cause**: Complex nested expressions  
**Fix**: Careful parenthesis counting, use editor matching

#### 4. Wrong Operand Types
**Symptom**: Method not found, dispatch errors
**Cause**: Using wrong operand type with instruction
**Fix**: Match operand types to instruction expectations

### Debugging Tools

#### Instruction Tracing
```lisp
(define-function optimised () 0)  ; Enable debug output
```
Generates DEFLABEL and COMMENT instructions for tracing.

#### Manual Testing
```lisp
;; Test individual instructions
(emit LOAD (LI32 42))
(emit NEG)  
(emit STORE (TI32 8))
```

#### Source Location Tracking
```lisp
(set *label-source* (cons "filename.l" 123))
```
Labels include source file and line number.

## Performance Considerations

### Current Limitations
- **No register allocation**: Simple stack-based approach
- **No peephole optimization**: Direct instruction mapping  
- **No instruction selection**: One operation = one instruction
- **Linear temporary allocation**: No sophisticated reuse

### Optimization Opportunities  
- **Better temporary reuse**: Implement proper liveness analysis
- **Instruction combining**: Recognize patterns like load+add
- **Register allocation**: For targets with multiple registers
- **Constant folding**: Evaluate compile-time constants

### Design Trade-offs
- **Correctness over performance**: Simple, reliable generation
- **Extensibility over optimization**: Easy to add new backends  
- **Bootstrap compatibility**: Must compile itself

## Conclusion

emit.l demonstrates sophisticated compiler architecture:
- **Polymorphic dispatch** enables multiple backends
- **Deferred generation** allows optimization  
- **Clean abstraction layers** separate concerns
- **Metacircular design** supports self-compilation

The C backend proves the architecture works - the same instruction sequences that generate x86 assembly can generate equivalent C code by simply overriding the emit methods. This makes emit.l a powerful foundation for targeting multiple platforms and code generation strategies.