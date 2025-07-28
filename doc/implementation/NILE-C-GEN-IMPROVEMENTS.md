# Nile C Generation Improvements for Maru

## Overview

Dan Amelang's Nile compiler demonstrates several sophisticated C code generation techniques that could improve Maru's emit.l. Here's an analysis of the key improvements that could be pulled up to Maru's C generation system.

## 1. Structured Code Generation Environment

### Nile's Approach
```lisp
(define-structure <nile-gen-code-env>
  (module-name bindings out-port indentation next-cvar-num cvars))
```

Nile uses a structured environment object that encapsulates:
- Output port management
- Variable tracking
- Indentation control
- C variable allocation

### Benefits for Maru
- **Clean separation**: Code generation state isolated from global state
- **Port-based output**: Already integrated with Maru's port system
- **Automatic indentation**: Consistent C code formatting
- **Variable management**: Track C variables systematically

### Implementation for Maru
```lisp
(define-structure <c-gen-env>
  (out-port indentation bindings temp-counter label-counter))

(define-method out <c-gen-env> args
  (port-indent self.out-port self.indentation)
  (apply port-write (cons self.out-port args)))
```

## 2. Template-Based Code Generation

### Nile's Approach
Nile uses a template file (`nile-process-template.c`) with placeholders:
```c
typedef struct {
[[ (name type) in pvars
   `type` `name`;
]]
} `prefix`_`pname`_vars_t;
```

### Benefits for Maru
- **Readable templates**: C code structure visible
- **Flexible substitution**: Easy to modify generated code patterns
- **Maintainable**: Changes to C output don't require Lisp code changes

### Implementation for Maru
Could use Maru's existing quasi-quote mechanism more effectively:
```lisp
(define c-function-template
  '(function-type function-name (params...)
    {
      declarations...
      body...
      return result;
    }))
```

## 3. Multi-Pass Code Generation

### Nile's Approach
```lisp
; First pass: collect all variables
(map-with gen-code vardecls env_)
; Second pass: generate code using collected info
(list-do (name . type) (cvars env_)
  (out env type" "name";\n"))
```

### Benefits for Maru
- **Forward references**: Can handle mutual recursion
- **Optimization opportunities**: Analyze before generating
- **Type inference**: Collect type info before emission

## 4. Systematic Variable Allocation

### Nile's Approach
```lisp
(define-method alloc-cvar <nile-gen-code-env> (type)
  (let ((cvar (format "v_%d" self.next-cvar-num)))
    (set self.next-cvar-num (+ self.next-cvar-num 1))
    (set self.cvars (cons (cons cvar type) self.cvars))
    cvar))
```

### Benefits for Maru
- **Unique naming**: No variable name conflicts
- **Type tracking**: Know variable types for casts
- **Lifetime management**: Track variable scope

### Implementation for Maru
```lisp
(define-method alloc-temp <c-gen-env> (type)
  (let ((name (format "t%d" self.temp-counter)))
    (inc self.temp-counter)
    (bind self name type)
    name))
```

## 5. Clean Method Dispatch for Code Generation

### Nile's Approach
```lisp
(define-method gen-code <nile-numexpr> (env)
  (list (string->double self.number)))

(define-method gen-code <nile-ifstmt> (env)
  (let ((cval (car (gen-code self.condition env))))
    (out env "if ("cval")\n")
    ...))
```

### Benefits for Maru
- **Type-based dispatch**: Each AST node knows how to generate its code
- **Composable**: Complex expressions built from simple ones
- **Extensible**: Easy to add new node types

## 6. Header/Source File Separation

### Nile's Approach
```lisp
(define-function nile-gen-code-for-header-file (ast module-name)
  ...)
(define-function nile-gen-code-for-source-file (ast module-name)
  ...)
```

### Benefits for Maru
- **Standard C practices**: Proper .h/.c separation
- **Linking support**: Clean external interfaces
- **Incremental compilation**: Only recompile changed files

## 7. Built-in Operations as Data

### Nile's Approach
```lisp
(define nile-builtin-opdefs (list
  (cons "√a:Number  : Number" 
        (lambda (env a r) (out env r" = sqrtf ("a");\\n")))
  (cons "a:Number ≤ b:Number : Boolean" 
        (lambda (env a b r) (out env r" = "a" <= "b";\\n")))))
```

### Benefits for Maru
- **Declarative**: Operations defined as data
- **Pattern matching**: Type signatures included
- **Easy to extend**: Add new operations without code changes

## Recommendations for Maru

1. **Adopt Environment Objects**: Replace global state in emit.l with structured environments
2. **Use Port-Based Output**: Leverage Maru's port system for cleaner output generation
3. **Implement Multi-Pass Generation**: Analyze before generating for better code
4. **Add Template Support**: For complex C patterns like struct definitions
5. **Systematic Variable Management**: Track types and lifetimes properly
6. **Separate Headers**: Generate proper .h/.c file pairs

## Implementation Priority

1. **High Priority**: Environment objects and port-based output (foundation for other improvements)
2. **Medium Priority**: Multi-pass generation and variable management
3. **Low Priority**: Template system and header separation (can be added incrementally)

## Example Refactoring

Current Maru emit style:
```lisp
(define-emit (IF test consequent alternate)
  (emit test)
  (print "  cmpq $0, %rax")
  (print "  je .L" label)
  ...)
```

Improved style using Nile patterns:
```lisp
(define-method emit-c <if-expr> (env)
  (let ((test-var (emit-c self.test env))
        (label (gen-label env)))
    (out env "if (!" test-var ") goto " label ";\n")
    (push-indent env)
    (emit-c self.consequent env)
    (pop-indent env)
    (out env label ":\n")
    (emit-c self.alternate env)))
```

## Conclusion

Dan's Nile compiler demonstrates mature C code generation techniques that would significantly improve Maru's emit.l. The key insight is treating code generation as a structured transformation with proper state management, rather than ad-hoc printing. These improvements would make Maru's C backend more maintainable, extensible, and capable of generating higher-quality C code.