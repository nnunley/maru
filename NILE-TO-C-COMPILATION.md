# How Nile Compiles to C

## Overview

Nile's compilation to C is a sophisticated multi-stage process that leverages Maru's metaprogramming capabilities to transform high-level stream processing code into efficient C code. The compilation preserves Nile's mathematical notation and stream semantics while generating standard C that can be compiled with any C compiler.

## Compilation Pipeline

### 1. Parse Nile Source → AST
Using Maru's PEG parser, Nile source with Unicode mathematical notation is parsed into an AST:

```nile
PlaceWords (b:Point, h:Number) : Word >> (Word, Point)
    x = b.x
    y = b.y
    ∀ W
        >> (W, (x, y))
        if W.s = 2
            x' = b.x
            y' = y + h
        else
            x' = x + W.w
```

### 2. AST Representation
The parser creates Maru objects representing Nile constructs:
- `<nile-processdef>` - Process definitions
- `<nile-vardecl>` - Variable declarations
- `<nile-opexpr>` - Mathematical operations
- `<nile-outstmt>` - Stream output statements
- `<nile-processbody>` - The ∀ loop body

### 3. Type Checking and Resolution
Before code generation, the compiler:
- Resolves variable names
- Checks types
- Validates stream connections
- Ensures mathematical operations are valid

## C Code Generation Strategy

### 1. **Process Structure Mapping**

Each Nile process becomes a C struct and set of functions:

```c
// Nile process variables become a C struct
typedef struct {
    float x;
    float y;
} MyModule_PlaceWords_vars_t;

// Three functions for each process:
nile_Buffer_t *MyModule_PlaceWords_prologue(nile_Process_t *p, nile_Buffer_t *out);
nile_Buffer_t *MyModule_PlaceWords_body(nile_Process_t *p, nile_Buffer_t *in, nile_Buffer_t *out);
nile_Buffer_t *MyModule_PlaceWords_epilogue(nile_Process_t *p, nile_Buffer_t *out);

// Constructor function
nile_Process_t *MyModule_PlaceWords(nile_Process_t *p, float b_x, float b_y, float h);
```

### 2. **Mathematical Operations → C Operations**

The compiler maps Nile's Unicode operators to C:

```lisp
; From nile-builtins-c.l
"√a:Number  : Number"  → r = sqrtf(a);
"a:Number ≤ b:Number"  → r = a <= b;
"a:Number × b:Number"  → r = a * b;
"⌊a:Number⌋"          → r = (int)a; r = (r > a) ? r - 1 : r;
```

### 3. **Stream Operations → Buffer Management**

Nile's stream operations map to buffer operations:

```nile
>> (W, (x, y))  ; Nile stream output
```

Becomes:

```c
// Check if output buffer is full
if (j == n) nile_Process_advance_output(p, &out, &j, &n);
// Output tuple elements
out[j++] = W_w;
out[j++] = W_s;  
out[j++] = W_n;
out[j++] = x;
out[j++] = y;
```

### 4. **The ∀ (foreach) Loop → C While Loop**

The core stream processing loop:

```nile
∀ W
    >> (W, (x, y))
    if W.s = 2
        x' = b.x
        y' = y + h
```

Becomes:

```c
while (status == 0) {
    while (i < m) {
        // Pop input from buffer
        float W_w = in[i++];
        float W_s = in[i++];
        float W_n = in[i++];
        
        // Output to buffer
        out[j++] = W_w;
        out[j++] = W_s;
        out[j++] = W_n;
        out[j++] = x;
        out[j++] = y;
        
        // Conditional update with primed variables
        if (W_s == 2) {
            x_ = b_x;
            y_ = y + h;
        }
        
        // Update state variables
        x = x_;
        y = y_;
    }
    status = nile_Process_advance_input(p, &in, &i, &m);
}
```

## Key Code Generation Techniques

### 1. **Primed Variables**
Nile's primed variables (x') for state updates are handled specially:
- Temporary variables (x_) hold new values
- All updates happen atomically at loop end
- Preserves Nile's synchronous dataflow semantics

### 2. **Type Mapping**
- `Number` → `float`
- `Boolean` → `int`
- Tuples → Multiple sequential values in buffers
- Records → Struct field access

### 3. **Process Composition**
Pipeline connections are compiled to:
```c
process = nile_Process_pipe(process1, process2);
```

### 4. **Memory Management**
- Process state stored in vars struct
- Buffers managed by Nile runtime
- Automatic memory allocation/deallocation

## Example: Complete Compilation

**Nile Source:**
```nile
type Point = (x:Number, y:Number)

TransformPoint (M:Matrix) : Point >> Point
    (a, b, c, d, e, f) = M
    ∀ (x, y)
        >> (ax + cy + e, bx + dy + f)
```

**Generated C (simplified):**
```c
typedef struct {
    float a, b, c, d, e, f;
} MyModule_TransformPoint_vars_t;

nile_Buffer_t *
MyModule_TransformPoint_body(nile_Process_t *p, nile_Buffer_t *in, nile_Buffer_t *out) {
    MyModule_TransformPoint_vars_t *vars = nile_Process_vars(p);
    float a = vars->a, b = vars->b, c = vars->c;
    float d = vars->d, e = vars->e, f = vars->f;
    
    while (!nile_Buffer_is_empty(in) && !nile_Buffer_quota_hit(out)) {
        float x = nile_Buffer_pop_head(in);
        float y = nile_Buffer_pop_head(in);
        
        nile_Buffer_push_tail(out, a*x + c*y + e);
        nile_Buffer_push_tail(out, b*x + d*y + f);
    }
    return out;
}

nile_Process_t *
MyModule_TransformPoint(nile_Process_t *p, 
                        float a, float b, float c, 
                        float d, float e, float f) {
    p = nile_Process(p, 2, sizeof(MyModule_TransformPoint_vars_t),
                     NULL, MyModule_TransformPoint_body, NULL);
    if (p) {
        MyModule_TransformPoint_vars_t *vars = nile_Process_vars(p);
        vars->a = a; vars->b = b; vars->c = c;
        vars->d = d; vars->e = e; vars->f = f;
    }
    return p;
}
```

## Runtime Architecture

The generated C code relies on a Nile runtime (`nile.h`) that provides:

1. **Process Management**
   - Process creation/destruction
   - State variable storage
   - Pipeline composition

2. **Buffer Management**
   - Efficient stream buffering
   - Buffer allocation/deallocation
   - Flow control

3. **Scheduling**
   - Process execution
   - Data flow between processes
   - Multi-threading support

## Optimization Techniques

1. **Buffer Batching**: Processes work on buffers, not individual values
2. **Inline Operations**: Mathematical operations compile to direct C operations
3. **State Caching**: Process variables cached in local C variables
4. **SIMD Potential**: Buffer layout enables SIMD optimization

## Why This Approach Works Well

1. **Clean Mapping**: Nile's dataflow model maps naturally to C's imperative style
2. **Efficiency**: Generated C is close to hand-written performance
3. **Portability**: Standard C works everywhere
4. **Debuggability**: Generated code is readable and debuggable
5. **Integration**: Easy to link with existing C/C++ code

## Conclusion

Nile's compilation to C demonstrates sophisticated code generation using Maru as a metaprogramming platform. The compiler:
- Preserves high-level mathematical notation
- Generates efficient C code
- Maintains stream processing semantics
- Produces readable, maintainable output

This shows how a metacircular language like Maru can be used to build practical compilers for domain-specific languages, bridging the gap between mathematical notation and efficient implementation.