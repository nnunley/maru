# Design Document: eval.k - A Typed, IR-Based Maru Evaluator

## Executive Summary

This document describes the design of `eval.k`, a reimplementation of Maru's evaluator using the typed, IR-based compilation infrastructure. Following Ian Piumarta's vision of "open, extensible composition models" (VPRI TR-2011-002), eval.k demonstrates how a dynamic language evaluator can be implemented within a statically-typed framework while preserving the metacircular elegance and extensibility that defines Maru.

## 1. Theoretical Foundation

### 1.1 Piumarta's Principles

From "Open, Extensible Composition Models" (2011), we draw these key insights:

1. **Continuous Spectrums**: Rather than viewing static/dynamic typing as a dichotomy, we position eval.k on a spectrum where dynamic behavior emerges from static foundations.

2. **Level Shifting**: The ability to move between abstraction levels is crucial. eval.k operates at the boundary between Maru's dynamic semantics and IR's static compilation.

3. **Metacircular Escape**: While eval.l achieves metacircularity through interpretation, eval.k achieves it through compilation, demonstrating Piumarta's concept of "grounding" abstract computation in concrete implementation.

4. **Composition Over Monolithic Design**: eval.k is built through composition of orthogonal features using Maru's multi-method dispatch and layered architecture.

### 1.2 STEPS Project Goals

Consistent with the STEPS project's goal of implementing a complete system in under 20,000 lines, eval.k aims for:
- Minimal implementation size
- Maximum expressiveness
- Clear separation of concerns
- Self-describing behavior

## 2. Architecture Overview

### 2.1 Layered Design

```
┌─────────────────────────────────────┐
│        Application Layer            │
│    (User programs, boot.l, etc.)    │
├─────────────────────────────────────┤
│         Dynamic Layer               │
│    (S-expressions, environments)    │
├─────────────────────────────────────┤
│         eval.k Core                 │
│  (Type bridge, evaluator logic)     │
├─────────────────────────────────────┤
│      IR Compilation Layer           │
│    (Type checking, optimization)    │
├─────────────────────────────────────┤
│       Backend Generation            │
│    (C, x86, ARM64, LLVM-IR)       │
└─────────────────────────────────────┘
```

### 2.2 Type System Bridge

The core innovation is a universal value representation that bridges dynamic and static worlds:

```lisp
;; Universal value type that can hold any Maru value
(define-struct <maru-value> (
  (tag <maru-type-tag>)
  (data <maru-value-data>)
))

;; Type tags mirror eval.l's type system
(define-enum <maru-type-tag>
  maru-undefined  ; 0
  maru-data      ; 1
  maru-long      ; 2
  maru-double    ; 3
  maru-string    ; 4
  maru-symbol    ; 5
  maru-pair      ; 6
  maru-array     ; 8
  maru-expr      ; 9
  maru-form      ; 10
  maru-fixed     ; 11
  maru-subr      ; 12
  maru-variable  ; 13
  maru-env       ; 14
  maru-context   ; 15
)

;; Union type for value data
(define-union <maru-value-data> (
  (as-long     int64)
  (as-double   double)
  (as-pointer  void*)
  (as-pair     <maru-pair>*)
  (as-array    <maru-array>*)
  (as-expr     <maru-expr>*)
  (as-env      <maru-env>*)
))
```

## 3. Multi-Method Dispatch Architecture

Following Maru's philosophy of extensible behavior through multi-methods, eval.k uses generic functions for all core operations:

### 3.1 Type Checking and Conversion

```lisp
;; Generic function for type checking
(define-generic maru-type-of (obj))

;; Specialized methods for each representation
(define-method maru-type-of <maru-value>* ((obj <maru-value>*)) -> <maru-type-tag>
  (if (maru-tagged-int? obj)
      maru-long
    obj.tag))

;; Tagged integer optimization (following eval.l)
(define-function maru-tagged-int? ((obj <maru-value>*)) -> bool
  (& (cast int64 obj) 1))

(define-function maru-tag-int ((value int64)) -> <maru-value>*
  (cast <maru-value>* (| (<< value 1) 1)))
```

### 3.2 Evaluation Multi-Methods

The core evaluator uses multi-method dispatch based on expression type:

```lisp
;; Generic evaluation function
(define-generic maru-eval (exp ctx))

;; Base case - unknown types evaluate to themselves
(define-method maru-eval <maru-value>* ((exp <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  exp)

;; Numbers and strings are self-evaluating
(define-method maru-eval maru-long ((exp <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  exp)

(define-method maru-eval maru-string ((exp <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  exp)

;; Variables require environment lookup
(define-method maru-eval maru-variable ((exp <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (if (maru-global? exp)
      (maru-variable-value exp)
    (maru-lookup-local exp ctx)))

;; Lists trigger function application
(define-method maru-eval maru-pair ((exp <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let ((fn <maru-value>* (maru-eval (maru-car exp) ctx)))
    (if (maru-fixed? fn)
        (maru-apply-fixed fn (maru-cdr exp) ctx)
      (let ((args <maru-value>* (maru-eval-list (maru-cdr exp) ctx)))
        (maru-apply fn args ctx)))))

;; Symbols should not appear in evaluation
(define-method maru-eval maru-symbol ((exp <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-error "symbol in eval?" exp))
```

### 3.3 Application Multi-Methods

Function application also uses multi-method dispatch:

```lisp
;; Generic application function
(define-generic maru-apply (fn args ctx))

;; User-defined functions (expressions)
(define-method maru-apply maru-expr ((fn <maru-value>*) (args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let* ((defn     <maru-value>* (maru-expr-defn fn))
         (env      <maru-value>* (maru-car defn))
         (formals  <maru-value>* (maru-cadr defn))
         (body     <maru-value>* (maru-cddr defn))
         (new-ctx  <maru-context>* (maru-make-context (maru-expr-ctx fn) ctx env)))
    (maru-bind-arguments new-ctx formals args)
    (maru-eval-sequence body new-ctx)))

;; Built-in functions (subrs)
(define-method maru-apply maru-subr ((fn <maru-value>*) (args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let ((imp <subr-implementation>* (maru-subr-implementation fn)))
    (imp args ctx)))

;; Fixed-arity special forms
(define-method maru-apply maru-fixed ((fn <maru-value>*) (args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-apply (maru-fixed-function fn) args ctx))
```

## 4. Memory Management Integration

### 4.1 Garbage Collection Interface

eval.k integrates with the existing garbage collector through IR external functions:

```lisp
;; External GC functions from eval.c
(extern gc_malloc    ((size int64)) -> void*)
(extern gc_push_root ((ptr void**)) -> void)
(extern gc_pop_root  ((ptr void**)) -> void)

;; Type-safe allocation functions
(define-function maru-alloc ((type <maru-type-tag>) (size int64)) -> <maru-value>*
  (let ((obj <maru-value>* (cast <maru-value>* (gc_malloc size))))
    (set obj.tag type)
    obj))

;; GC protection using RAII-style form
(define-form gc-protect (vars . body)
  `(let ()
     ,@(map (lambda (v) `(gc_push_root (addressof ,v))) vars)
     (let ((result (let () ,@body)))
       ,@(map (lambda (v) `(gc_pop_root (addressof ,v))) (reverse vars))
       result)))
```

### 4.2 Root Set Management

The evaluator maintains GC roots for global objects:

```lisp
(define-global symbols     <maru-value>*)  ; Symbol table
(define-global globals     <maru-value>*)  ; Global environment
(define-global evaluators  <maru-value>*)  ; Type-indexed evaluator table
(define-global applicators <maru-value>*)  ; Type-indexed applicator table

(define-function maru-init-roots () -> void
  (gc_push_root (addressof symbols))
  (gc_push_root (addressof globals))
  (gc_push_root (addressof evaluators))
  (gc_push_root (addressof applicators)))
```

## 5. Core Data Structure Implementations

### 5.1 Pairs (Cons Cells)

```lisp
(define-struct <maru-pair> (
  (head <maru-value>*)
  (tail <maru-value>*)
))

(define-function maru-cons ((head <maru-value>*) (tail <maru-value>*)) -> <maru-value>*
  (let ((pair <maru-pair>* (cast <maru-pair>* (maru-alloc maru-pair (sizeof <maru-pair>)))))
    (gc-protect (head tail)
      (set pair.head head)
      (set pair.tail tail)
      (cast <maru-value>* pair))))

(define-function maru-car ((obj <maru-value>*)) -> <maru-value>*
  (if (maru-pair? obj)
      (cast <maru-pair>* obj).head
    (maru-nil)))

(define-function maru-cdr ((obj <maru-value>*)) -> <maru-value>*
  (if (maru-pair? obj)
      (cast <maru-pair>* obj).tail
    (maru-nil)))
```

### 5.2 Environments

```lisp
(define-struct <maru-env> (
  (parent   <maru-env>*)
  (level    int32)
  (offset   int32)
  (bindings <maru-array>*)
))

(define-function maru-make-env ((parent <maru-env>*) (level int32) (offset int32)) -> <maru-env>*
  (let ((env <maru-env>* (cast <maru-env>* (maru-alloc maru-env (sizeof <maru-env>)))))
    (gc-protect (parent)
      (set env.parent parent)
      (set env.level (if parent (+ parent.level level) 0))
      (set env.offset offset)
      (set env.bindings (maru-make-array 0))
      env)))
```

## 6. Special Forms Implementation

### 6.1 Lambda (Function Definition)

```lisp
(define-function maru-lambda ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (maru-make-expr args ctx))

(define-struct <maru-expr> (
  (defn <maru-value>*)  ; (env formals . body)
  (ctx  <maru-context>*)
))
```

### 6.2 Define (Variable Definition)

```lisp
(define-function maru-define ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (let* ((var <maru-value>* (maru-car args))
         (val <maru-value>* (maru-eval (maru-cadr args) ctx)))
    (if (maru-variable? var)
        (maru-set-variable-value var val)
      (maru-error "non-variable in define" var))))
```

### 6.3 If (Conditional)

```lisp
(define-function maru-if ((args <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  (if (maru-eval (maru-car args) ctx)
      (maru-eval (maru-cadr args) ctx)
    (maru-eval-sequence (maru-cddr args) ctx)))
```

## 7. Reader and Printer

### 7.1 S-Expression Reader

```lisp
(define-function maru-read ((stream <input-stream>*)) -> <maru-value>*
  (maru-skip-whitespace stream)
  (let ((c int32 (maru-peek-char stream)))
    (cond
      ((= c -1) (maru-eof))
      ((= c ?\() (maru-read-list stream))
      ((= c ?\") (maru-read-string stream))
      ((maru-digit? c) (maru-read-number stream))
      (else (maru-read-symbol stream)))))
```

### 7.2 Pretty Printer

```lisp
(define-generic maru-print (obj port))

(define-method maru-print maru-long ((obj <maru-value>*) (port <output-port>*)) -> void
  (fprintf port "%ld" (maru-unbox-long obj)))

(define-method maru-print maru-string ((obj <maru-value>*) (port <output-port>*)) -> void
  (fprintf port "\"%s\"" (maru-string-data obj)))

(define-method maru-print maru-symbol ((obj <maru-value>*) (port <output-port>*)) -> void
  (fprintf port "%s" (maru-symbol-name obj)))

(define-method maru-print maru-pair ((obj <maru-value>*) (port <output-port>*)) -> void
  (fprintf port "(")
  (maru-print-list obj port)
  (fprintf port ")"))
```

## 8. Bootstrap Process

### 8.1 Stage 1: Core Infrastructure
1. Implement universal value type
2. Create type checking predicates
3. Build memory allocation interface
4. Establish GC root management

### 8.2 Stage 2: Basic Evaluation
1. Implement self-evaluating types (numbers, strings)
2. Add variable lookup
3. Create minimal environment support
4. Test with simple expressions

### 8.3 Stage 3: Function Support
1. Implement lambda and application
2. Add special forms (define, if, let)
3. Create built-in function interface
4. Test with recursive functions

### 8.4 Stage 4: Full Language
1. Add remaining special forms
2. Implement macro support
3. Create reader and printer
4. Add error handling

### 8.5 Stage 5: Self-Hosting Test
1. Load boot.l using eval.k
2. Verify identical behavior to eval.l
3. Compile eval.k through IR system
4. Generate C, x86, and ARM64 versions

## 9. Performance Considerations

### 9.1 Tagged Integer Optimization

Following eval.l, immediate integers use tagged pointers:
- Bit 0 = 1 indicates tagged integer
- Value = pointer >> 1
- Avoids allocation for small integers

### 9.2 Inline Caching

Multi-method dispatch can use inline caching:
```lisp
(define-struct <method-cache> (
  (type <maru-type-tag>)
  (method <method-implementation>*)
))
```

### 9.3 Tail Call Optimization

The IR system can recognize tail positions and generate appropriate jumps rather than calls.

## 10. Extensibility

### 10.1 Adding New Types

New types can be added without modifying core eval.k:

```lisp
;; Define new type tag
(define maru-rational 16)

;; Add evaluation method
(define-method maru-eval maru-rational ((exp <maru-value>*) (ctx <maru-context>*)) -> <maru-value>*
  exp)  ; Rationals are self-evaluating

;; Add print method
(define-method maru-print maru-rational ((obj <maru-value>*) (port <output-port>*)) -> void
  (let ((rat <maru-rational>* (cast <maru-rational>* obj)))
    (fprintf port "%d/%d" rat.numerator rat.denominator)))
```

### 10.2 Custom Evaluators

The evaluator table allows type-specific evaluation:

```lisp
(maru-set-evaluator maru-rational rational-evaluator)
```

## 11. Testing Strategy

### 11.1 Unit Tests
- Test each data type constructor
- Verify type predicates
- Check memory allocation
- Test GC integration

### 11.2 Integration Tests
- Evaluate test suite from eval.l
- Compare results with eval2
- Benchmark performance
- Verify memory usage

### 11.3 Metacircular Test
- eval.k should evaluate itself
- Result should be identical to original
- Demonstrates true self-hosting

## 12. Implementation Timeline

### Phase 1: Foundation (Weeks 1-2)
- Universal value type
- Basic memory management
- Type checking infrastructure

### Phase 2: Core Evaluator (Weeks 3-5)
- Basic evaluation loop
- Special forms
- Function application

### Phase 3: Full Language (Weeks 6-8)
- All data types
- Macro support
- Error handling

### Phase 4: Self-Hosting (Weeks 9-10)
- Reader/printer
- Bootstrap testing
- Performance tuning

### Phase 5: Multi-Backend (Weeks 11-12)
- IR compilation
- Backend testing
- Documentation

## 13. Conclusion

eval.k represents a synthesis of Piumarta's vision for open, extensible systems with modern compilation techniques. By implementing a dynamic language evaluator within a statically-typed framework, we demonstrate that the static/dynamic divide is indeed a false dichotomy. The design leverages Maru's strengths - multi-method dispatch, metacircular architecture, and minimal core - while gaining the benefits of static compilation: type safety, optimization opportunities, and multi-platform support.

This project continues the STEPS tradition of achieving significant functionality with minimal code, showing that a complete, self-hosting evaluator can be implemented clearly and concisely when built on the right abstractions. eval.k is not just a reimplementation but a demonstration of how dynamic language features can emerge from static foundations through careful design and principled layering.

## References

1. Piumarta, Ian. "Open, Extensible Composition Models." VPRI Technical Report TR-2011-002, Viewpoints Research Institute, 2011.
2. Kay, Alan, et al. "STEPS Toward Expressive Programming Systems." Annual Reports 2007-2012, Viewpoints Research Institute.
3. eval.l - Original Maru evaluator implementation
4. maru.k - Typed Maru compiler implementation
5. ir.k, ir2.k - Intermediate representation system