# eval.k IR Compilation Process

You're absolutely correct - I was fixing the C code directly when I should be showing how the IR code generator would work properly. Let me explain the proper compilation process.

## The IR Compilation Pipeline

The compilation of eval.k works through these stages:

### 1. Parsing and Type Analysis (maru.k)

When eval.k is loaded with `compile-begin`/`compile-end`, the maru.k compiler:

```lisp
;; eval.k source
(define-function maru-cons ((head maru-value) (tail maru-value)) -> maru-value
  (let ((pair MPair* (cast MPair* (maru-alloc MARU-PAIR (sizeof MPair)))))
    (set (cast MValue* pair).data (cast void* pair))
    (set pair.head head)
    (set pair.tail tail)
    (cast maru-value pair)))
```

### 2. IR Generation

The maru.k compiler transforms this into IR:

```lisp
<ir-function maru-cons
  parameters: (head tail)
  type: <ir-function-type (maru-value maru-value) -> maru-value>
  body: <ir-let pair
          <ir-cast MPair* <ir-call maru-alloc MARU-PAIR <ir-sizeof MPair>>>
          <ir-seq
            <ir-set-member <ir-cast MValue* pair> data <ir-cast void* pair>>
            <ir-set-member pair head head>
            <ir-set-member pair tail tail>
            <ir-cast maru-value pair>>>>
```

### 3. IR Analysis Issues

The IR analyzer would detect a problem here:
- `maru-alloc` returns a `MValue*` with the tag already set
- We're trying to cast it to `MPair*` and use it directly
- This is a type confusion in the original eval.k

### 4. Correct eval.k Code

The eval.k code should actually be:

```lisp
(define-function maru-cons ((head maru-value) (tail maru-value)) -> maru-value
  (let* ((val MValue* (cast MValue* (maru-alloc MARU-PAIR (sizeof MValue))))
         (pair MPair* (cast MPair* (gc-malloc (sizeof MPair)))))
    (set val.data (cast void* pair))
    (set pair.head head)
    (set pair.tail tail)
    (cast maru-value val)))
```

### 5. Correct IR Generation

This would generate proper IR:

```lisp
<ir-function maru-cons
  parameters: (head tail)
  type: <ir-function-type (maru-value maru-value) -> maru-value>
  body: <ir-let* ((val <ir-cast MValue* <ir-call maru-alloc MARU-PAIR <ir-sizeof MValue>>>)
                  (pair <ir-cast MPair* <ir-call gc-malloc <ir-sizeof MPair>>>>)
          <ir-seq
            <ir-set-member val data <ir-cast void* pair>>
            <ir-set-member pair head head>
            <ir-set-member pair tail tail>
            <ir-cast maru-value val>>>>
```

### 6. C Code Generation (ir-gen-c.k)

The ir-gen-c.k backend would then generate:

```c
maru_value maru_cons(maru_value head, maru_value tail) {
    MValue* val = (MValue*)maru_alloc(MARU_PAIR, sizeof(MValue));
    MPair* pair = (MPair*)gc_malloc(sizeof(MPair));
    val->data = (void*)pair;
    pair->head = head;
    pair->tail = tail;
    return (maru_value)val;
}
```

## The Key Insight

The IR system would catch type errors during compilation that I was fixing manually in the C code. This demonstrates the value of the typed IR system:

1. **Type Safety**: The IR type checker would catch the incorrect memory layout
2. **Correct Code Generation**: Each backend (C, x86, ARM64) would generate correct code
3. **Optimization Opportunities**: The IR optimizer could inline small functions

## How ir-gen-c.k Works

The C backend walks the IR tree and generates appropriate C code:

```lisp
(define-method generate <ir-let*> (backend)
  (print "{\n")
  (dolist (binding bindings)
    (generate-type (binding-type binding) backend)
    (print " ")
    (print (binding-name binding))
    (print " = ")
    (generate (binding-init binding) backend)
    (print ";\n"))
  (generate body backend)
  (print "}\n"))
```

## Conclusion

The proper compilation flow is:
1. Fix the type errors in eval.k
2. Let maru.k compile it to typed IR
3. Let ir-gen-c.k generate correct C code from the IR
4. The generated C code would be correct by construction

This is why the .k system exists - to catch these kinds of errors at compile time rather than runtime!