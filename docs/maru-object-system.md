# Maru's object system, as implemented

This describes the object system as the code in this tree implements it (main at d29d40b; the files cited here are unchanged from the branch base 8ab7552). Where the code is the only definition, the text says what the code does. It does not say what the code should do. Citations are `file:line` in this tree.

Three evaluators run the system:

- `eval` (eval.c, loads `boot.l`). It has tagged integers and `Variable`, `Env` and `Context` as C objects.
- `eval2` (eval2.c) and `eval3` (eval3.c). Both load `boot2.l`. Neither has tagged integers nor the three environment objects in C.

The boot files load at startup (eval.c:3375, eval2.c:3652, eval3.c:3672) unless `-b` is given.

Probe method: `make eval eval2 eval3` in the worktree, then small scripts run as `./eval FILE`, `./eval2 FILE`, `./eval3 FILE`. The scripts lived in a temporary directory outside the tree and are not kept. Output is quoted with terminal escape codes removed. Where a result is quoted for only one evaluator, the others did the same unless stated.

---

## 1. The model in brief

1. Every heap object is a GC block. Its header holds an integer `type` (eval.c:35, gc.c:41-61).
2. `nil` is the C null pointer and has type 0 (`Undefined`). In `eval`, a word with bit 0 set is a small integer and is typed `Long` (eval.c:32, 116). In `eval2` and `eval3` every integer is a boxed `Long`.
3. A type is an integer. Built-in types take the numbers given by the order of their definitions in the boot file. User types take the next free number from `%allocate-type` (boot.l:303-307).
4. A structure is a block of `size` slots. Slot `i` holds field `i`. Accessors `<T>-field` are macros (Form objects) that expand to `oop-at` on a type-checked object.
5. `define-class` gives a type a base. `inherits-from` follows the base chain. Only the three-argument form is in the boot files; methods are added separately.
6. A selector is a Maru structure (`<selector>`) with a table of methods indexed by type number. Calling it dispatches on the type of its first argument only, then walks the base chain, then uses the selector's default.
7. A multimethod (`define-multimethod`) is a set of nested tables, one level per argument, with exact type matches only.
8. `print` calls the `do-print` selector for each argument. The C printer does not.
9. Special forms are C primitives marked `Fixed`. Macros are `Form` objects. Closures are `Expr` objects.
10. The evaluators disagree in several places. Section 9 lists them with probe output.

---

## 2. Objects in C

### 2.1 Immediates and nil

- `nil` is `((oop)0)` (eval.c:75, eval2.c:84, eval3.c:85).
- `getType` returns `Undefined` (0) for nil (eval.c:116-118, eval2.c:131-135, eval3.c:134-138).
- `eval` defines `TAG_INT` as 1 (eval.c:32). `getType` returns `Long` for any word with bit 0 set (eval.c:116). `newLong` tags a value when its shifted word fits and boxes it otherwise (eval.c:182). `isLong` accepts either form (eval.c:181).
- `eval2` and `eval3` have `TAG_INT` commented out (eval2.c:36, eval3.c:37). Every `Long` is a heap block with a `bits` field.

Probe, all three evaluators: `(type-of 3)` printed `2`, and `(type-of (* 1099511627776 4))` printed `2`.

### 2.2 The header and the type field

The GC header is defined in gc.c:41-61. Its last member is `GC_APP_HEADER`, which each evaluator defines:

- `eval.c:35`: `int type; unsigned int length;`. `length` holds the length a `Data` was made with.
- `eval2.c:39-43`: `int type;` (plus `printing` in debug builds). No length.
- `eval3.c:39-44`: `int type; unsigned int length;`.

`setType` writes the field (eval.c:113). `getType` reads it (eval.c:116-118). `_newBits` allocates a block with `GC_malloc_atomic`, so the collector does not scan it. `_newOops` uses `GC_malloc`, so it does (eval.c:158-159).

### 2.3 The kinds

The C enum gives the built-in kinds. The numbers are what `type-of` returns.

| No. | Kind | eval.c | eval2.c / eval3.c |
|---|---|---|---|
| 0 | Undefined (nil) | 77 | 86 |
| 1 | Data | 77 | 86 |
| 2 | Long | 77 | 86 |
| 3 | Double | 77 | 86 |
| 4 | String | 77 | 86 |
| 5 | Symbol | 77 | 86 |
| 6 | Pair | 77 | 86 |
| 7 | _Array (the raw slot block) | 77 | 86 |
| 8 | Array | 77 | 86 |
| 9 | Expr | 77 | 86 |
| 10 | Form | 77 | 86 |
| 11 | Fixed | 77 | 86 |
| 12 | Subr | 77 | 86 |
| 13 | Variable | 77 | commented out |
| 14 | Env | 77 | commented out |
| 15 | Context | 77 | commented out |

The C structs (eval.c:79-92; eval2.c:94-104) give each kind's slots. Two differ between evaluators:

- `Expr`: `{name, defn, ctx, profile}` in eval.c:86 and `{name, definition, environment, profile}` in eval2.c:100 and eval3.c:103.
- `Symbol`: `{bits}` in eval.c:83 and `{bits, flags}` in eval2.c and eval3.c.

Number 13 onward is also the first number that `%allocate-type` hands out in `eval2` and `eval3` (see 3.1), so user types overlap the kind numbers only in the sense that both are integers in the same space. Nothing prevents a user type from having a number used by a kind in another evaluator; the numbers are per evaluator.

### 2.4 Data

`newData(len)` allocates an atomic block and stores `len` in the header (eval.c:172-178). The `data` primitive is at eval.c:2412 and is registered at eval.c:3129. `data-length` returns the stored length (eval.c:2421). A `Data` prints as `<data[N]>` (eval.c:823-828).

`eval2` has no length in the header, no `data` primitive and no `data-length`; `data` is undefined there (see 9.14). `eval3` has both (eval3.c:2702, 2709, 3421-3422).

### 2.5 Slots and allocation

- `oopAt` and `oopAtPut` (eval.c:305-321; eval2.c:326-343; eval3.c:335-352) work only when the object is non-nil, not a tagged integer, and not atomic, and the index is inside `GC_size / sizeof(oop)`. Otherwise `oopAt` returns nil and `oopAtPut` stores nothing and returns nil. Nothing is reported.
- `allocate type size` (eval.c:2632-2638) returns `_newOops(type, size * sizeof(oop))`. It returns nil silently when either argument is not a `Long`.
- `allocate-atomic type bytes` (eval.c:2640-2646) is the same, for atomic blocks.
- `oop-at obj i` and `set-oop-at obj i v` (eval.c:2648-2663) call `oopAt` and `oopAtPut`. `set-oop-at` also records an undo entry first (eval.c:2662).
- `long-at` and `set-long-at` read and write a raw C `long` at byte offset `i * sizeof(long)`, after a range check (the `accessor(long, ...)` expansion at eval.c:2491). They exist only in `eval` (eval.c:3145; eval2.c:3417 and eval3.c have them commented out or absent).

### 2.6 type-of

`type-of` returns `newLong(getType(x))` (eval.c:2058-2062; eval2.c:2317-2320; eval3.c:2327-2330). A type is therefore a plain integer; there is no separate type object. For a structure type `T`, `(type-of instance)` is `T`'s integer.

### 2.7 The C printer

`doprint` (eval.c:811; eval2.c:875; eval3.c:884) switches on the kind. Its default branch (eval.c:966-980) looks up the name of the type in `%type-names`. If there is a name it prints it, and otherwise it prints `<type=N>`. Instances of structures therefore print as their type name, with no fields (see 5.1).

### 2.8 Evaluation and application

`eval` (eval.c:1280-1333):

- Undefined, Long, Double, String, Form, Subr and Fixed evaluate to themselves (eval2.c:1543-1549 has the same list, and eval.c:1283-1288 has the first four).
- A `Pair` evaluates its head. If the head is `Fixed`, the function gets the unevaluated tail (eval.c:1290-1292). Otherwise the tail is evaluated and `apply` is called (eval.c:1293-1300).
- A `Variable` reads its value (eval.c:1318-1323).
- Any other kind goes to the `*evaluators*` table, indexed by type (eval.c:1311-1317). Only `eval` reads that table.

`apply` (eval.c:1337-1412):

- `Expr`: binds formals in a new context and runs the body (eval.c:1341-1388).
- `Fixed`: applies the inner function to the unevaluated arguments (eval.c:1389-1391).
- `Subr`: calls the C implementation, or the foreign call path if a signature is set (eval.c:1392-1397).
- Anything else: looks up `*applicators*[type]`. If there is one, it is applied to `(obj . args)`. If not, the evaluator stops with `cannot apply` (eval.c:1398-1411).

So a selector is callable because `define-apply <selector>` (boot.l:516) installs an `Expr` in `*applicators*` at the selector type's index. Probe: `(type-of (array-at *applicators* <selector>))` printed `9`, which is `Expr`, in all three.

---

## 3. Types

### 3.1 Type numbers

- `%type-names` is an array (boot.l:300) and `%last-type` starts at -1 (boot.l:301).
- `%allocate-type name` increments `%last-type`, records the name and returns the number (boot.l:303-307; boot2.l:311-315).
- The built-in structures are defined in this order in boot.l:415-430: `<undefined>` 0, `<data>` 1, `<long>` 2, `<double>` 3, `<string>` 4, `<symbol>` 5, `<pair>` 6, `<_array>` 7, `<array>` 8, `<expr>` 9, `<form>` 10, `<fixed>` 11, `<subr>` 12, `<variable>` 13, `<env>` 14, `<context>` 15. This matches the C enum, but nothing checks it.
- `boot2.l:433-445` defines the same list without `<variable>`, `<env>` and `<context>`. So the first user type is 13 in `eval2` and `eval3`, and 16 in `eval`.

Probe: in `eval`, `(name-of-type 13)` printed `<variable>`. In `eval2` the same name is unbound (`undefined variable: <variable>`). `<selector>` is 16 in `eval` and 13 in `eval2`. `<pt>`, defined first by the user, is 18 in `eval` and 15 in `eval2`.

### 3.2 A type is an integer

`define-structure` binds the name to the integer (boot.l:366-375; boot2.l:374-383 is the same). So `<pt>` evaluates to 18 in `eval`. Probe: `(println "pt type: " <pt>)` printed `18` in `eval` and `15` in `eval2` and `eval3`. `(type-of <pt>)` is `2`, the `<long>` type. Predicates such as `long?` compare with `=` (boot.l:417).

### 3.3 define-structure

`define-structure name (fields...)` (boot.l:366-375; boot2.l:374-383). At expansion time:

1. It allocates a type number.
2. It checks for duplicate field names (`sanity-check-structure-fields`, boot.l:319-327). Probe: `(define-structure <dup> (a a))` printed `error: field 'a' multiply-defined in structure: <dup> (a a)`.
3. It records the size and field list in `%structure-sizes` and `%structure-fields`.
4. It expands to `(let () (define name type) accessors... type)`.

It records no base, so `%structure-bases` has no entry for the type. There is no root class in the boot files: `<object>` is undefined (probe: `(defined? '<object>)` gave `()`).

### 3.4 Field layout

- Slot `i` holds field `i`, in the order of the field list (boot.l:344-357; `%make-accessors`, boot.l:363).
- A subtype's field list is its base's fields followed by its own (boot.l:397-412 `concat-list`). Base fields therefore keep their offsets in subtypes. Probe: with `(define-class <pt3> <pt> (z))`, `(<pt>-x q)` and `(<pt>-y q)` worked on a `<pt3>` instance, and `%structure-fields` of `<pt3>` was `(x y z)`.
- Size is the number of fields (boot.l:398-399 via `list-length`), and `allocate` gives that many pointer-sized slots (eval.c:2636).
- Fields are oops. `new` stores with `set-oop-at` (see 3.7).
- A field whose name starts with `_` is accessed with `long-at` (`%accessor`, boot.l:342; boot2.l:350). That is a raw-word accessor, while `new` stores tagged oops. See 9.3.

### 3.5 Accessors and type checks

For each field `F` of structure `T`, `define-structure` and `define-class` make a macro named `T-F` through `%make-accessors` (boot.l:363-364).

- Safe accessors (`%make-safe-accessor`, boot.l:344-357) expand to `(oop-at (%typecheck T self) i)`.
- Unsafe accessors (`%make-unsafe-accessor`, boot.l:344-357) expand to `(oop-at self i)`. The choice is made once, when the boot file loads: `%make-accessor` is the unsafe version when `(optimised)` is greater than 0 (boot.l:358-361). `(optimised)` reads the `-O` count (eval.c:2682-2688).
- `%typecheck type object` (boot.l:334-339) accepts an object whose type is `type` or inherits from it. Otherwise it errors with `type check failed for field accessor: expected N <T> got M <X>`.

Accessors are macros, not functions. Probe: `(println "F1 accessor as value: " <pt>-x)` printed `Form(Expr.<pt>-x=(*env* self), ())` in `eval` and `Form(Expr.<pt>-x=(self), ())` in `eval2` and `eval3`. `(map <pt>-x (list p))` failed with `cannot apply: Form(...)` in all three.

`set` on an accessor works through the expander. In `expand` (eval.c:1034-1040), a `(set (head ...) v)` form whose place has already been expanded takes the expanded head's name and calls `set-<name>`. An accessor expands to `oop-at` or `long-at`, so the place becomes `set-oop-at` or `set-long-at`. There is no `set-<T>-<field>` function. Probe: `(defined? 'set-<pt>-x)` gave `()`, and `(set (<pt>-x p) 42)` then `(<pt>-x p)` gave `42`.

### 3.6 define-class and inheritance

`define-class name base (fields...)` (boot.l:395-412; boot2.l:413-430):

- `base` is evaluated at expansion time.
- `fields` becomes the base's fields followed by the new ones (boot.l:397-398).
- It records the size, the field list and `%structure-bases[type] = base`.
- It appends the new type to `%structure-derivatives[base]` (boot.l:405-407; boot2.l:423-424).
- It expands to the same shape as `define-structure`.

`%structure-derivatives` is written and never read. Grep finds no reader in the boot files, the C code, or the `.k` files outside `define-class.l` and `test-pepsi.l`, which write it too.

`inherits-from type base` (boot.l:329-332; boot2.l:337-340) is reflexive and walks `%structure-bases`. Predicates in the code use it, for example `ir-type?` (ir2.k:23). Predicates that compare with `=`, such as `long?`, `expr?` and `selector?`, match exact types only.

Only the three-argument `define-class` is in the boot files. A fourth argument is an error. Probe: `(define-class <foo> <object> (x y) (foo (x y) (set self.x x)))` printed `error: too many arguments applying Expr.define-class=(*env* name basis fields) to (...)` in `eval` and `error: too many arguments applying Expr.define-class=(name basis fields) to (...)` in `eval2`.

No constructor is generated. Callers use `new` or `make`.

### 3.7 new and make

`new type inits...` (boot.l:377-383; boot2.l:385-392) expands to:

```
(let* ((_type_ T) (_self_ (allocate _type_ (array-at %structure-sizes _type_))))
  (set-oop-at _self_ 0 init0) ... _self_)
```

It is positional. Its behaviour is set by `allocate` and `set-oop-at`:

- Missing inits leave their fields nil.
- Extra inits are dropped without a message. Probe: `(define-structure <pt> (x y))` then `(<pt>-y (new <pt> 1 2 3))` printed `2`.
- An unregistered type number gives nil, because the size is nil and `allocate` returns nil (eval.c:2634). Probe: `(new 99)` printed `()`.
- `(new <expr>)` makes an `Expr` with all slots nil. Probe: printed `Expr=()`.

`make type inits...` (boot.l:389-394) takes pairs. `(make <pt> (x 3) (y 4))` gives x 3 and y 4 in `eval`. It builds `(set (T-x self) v)` forms with `%make-make-inits` (boot.l:384-388) inside `with-instance-accessors`.

In `eval2` and `eval3`, `make` (boot2.l:407-412) takes keyword pairs: `(make <pt> x: 3 y: 4)`. `%make-field-name` (boot2.l:397-400) removes the last character of the keyword to get the field name. Probes:

- `eval`, `(make <pt> x: 3 y: 4)`: `string-length: non-String argument: ()` raised inside `concat-symbol`.
- `eval2`, `(make <pt> (x 3) (y 4))`: `string-length: non-String argument: ()` raised inside `string-length`, from boot2.l:399.
- `eval2`, `(make <pt> x: 3 y: 4)`: `make eval2: 3 4`.

### 3.8 Fields inside methods: self.field

`make-instance-accessors` (boot.l:493-496; boot2.l:510-513) defines, for each field `F` at index `i`, a form named `self.F` that expands to `(oop-at self i)`. `with-instance-accessors type body...` (boot.l:498-500; boot2.l:515-517) puts those forms in scope with `with-forms`.

`add-method` wraps each method body in `with-instance-accessors` for its type when the method is defined (boot.l:550-552; boot2.l:568-570). So inside a method:

- `self.F` reads or writes slot `i` directly, with no type check.
- Only the fields of the method's type, including inherited ones, are names in scope.
- `(set self.F v)` works, through the same expansion as 3.5.

Unknown names are an error that depends on the evaluator. See 9.8.

### 3.9 define-class.l (not loaded by default)

`define-class.l` (60-75) redefines `define-class` as `(name base fields . functions)`. Its functions are:

- constructors (`=` and `-` specs, define-class.l:15-33),
- methods as `(selector (args) body...)` (define-class.l:12-13),
- `@`, which defines a `do-print` method printing `{<T> field=value ...}` (define-class.l:1-10).

`assembler.k:22` and `test-call.k:1` require it. Loaded on the command line it works the same in all three evaluators (probe: `{<foo> x=1 y=4}` from `@`, in each). Once loaded, its definition replaces the boot file's `define-class` for the rest of the run.

---

## 4. Selectors and dispatch

### 4.1 define-selector

`define-selector name [formals body...]` (boot.l:536-546; boot2.l:554-564):

- If `name` is already a selector, the form does nothing useful (see 4.7).
- If `name` is bound to something else, it errors: `NAME already defined as non-selector: VALUE`. Probe: `(define spare 5)` then `(define-selector spare)` printed `error: spare already defined as non-selector: 5` in `eval` and `(spare . 5)` in `eval2` and `eval3`.
- The default is `(lambda formals body...)`. With no default, a generated lambda errors with `selector NAME has no method for TYPE: (ARG TYPE...)`. The generated text is at boot.l:541-545.
- The result is `(define name (selector 'name default))` (boot.l:545).

An explicit default with an empty body returns nil silently. Probe: `(define-selector speak (x))` then `(speak 3)` printed `()` in all three.

### 4.2 The selector object

`<selector>` has fields `name`, `methods` and `default` (boot.l:504; boot2.l:522). `methods` starts as an empty array. `selector?` is `(= <selector> (type-of x))` (boot.l:506).

### 4.3 Calling a selector

The applicator is at boot.l:516-520 (boot2.l:534-538). For arguments `args`:

1. Take `T` as `(type-of (car args))`.
2. If `methods[T]` is set, use it.
3. Otherwise `<selector>-inherit` (boot.l:508-514) walks `%structure-bases` from `T` and returns the first method found in `methods`.
4. Otherwise use the default.

It then applies the chosen method to all the arguments.

- Only the first argument chooses the method. Probe: a `<cat>` method with formal `(loud)` was called as `(speak c 'yes)` and printed `cat tom loud=yes`.
- The inherited method is not copied into the child's table. The copy-down line is commented out (boot.l:512).

Probe, inheritance with three levels (`<a>`, `<b>` inherits `<a>`, `<c>` inherits `<b>`): with a method only on `<a>`, `(f (new <c>))` gave `from-a`. After adding a method on `<b>`, it gave `from-b`. The nearest ancestor wins.

### 4.4 define-method

`define-method selector type (args) body...` (boot.l:554-556; boot2.l:572-574):

1. If `selector` is not defined, it is created with `define-selector`.
2. It expands to `(add-method selector type '(self . args) 'body)`.

`add-method` is itself a selector (boot.l:550-552; boot2.l:568-570). Its method for `<selector>` evaluates the body with `with-instance-accessors` and calls `<selector>-add-method` (boot.l:529-534; boot2.l:547-552). That function names the `Expr` `<T>.selector` if it has no name, and stores it at `methods[T]`.

So methods are `Expr` objects. Probe: `(array-at (<selector>-methods f) <a>)` printed `Expr.<a>.f=(self)`, and the method's `<expr>-name` printed `<b>.f`.

The first formal is always `self`.

### 4.5 Tagged integers, nil and other kinds

Dispatch uses `type-of`, so the table index for each kind is the kind number from 2.3:

- nil dispatches as `<undefined>` (0).
- Every integer dispatches as `<long>` (2), whether tagged in `eval` or boxed. Probe: a method on `<long>` returned `a-long` for `(kind 3)` and for `(kind (* 1099511627776 4))` in all three evaluators.
- A method on `<undefined>` is found by nil. Without one, `(speak ())` errors with `no method for <undefined>`.

A selector with no method and no default errors. The message names the first argument's type and the types of the others (boot.l:541-545). Probe outputs in all three evaluators:

- `(speak 3)`: `selector speak has no method for <long>: (3)`
- `(speak 1.5)`: `... for <double>: (1.500000)`
- `(speak "str")`: `... for <string>: (str)`
- `(speak 'sym)`: `... for <symbol>: (sym)`
- `(speak car)`: `... for <subr>: (car)`
- `(speak (cons 1 2))`: `... for <pair>: ((1 . 2))`
- `(speak d "x")` with `d` a `<dog>`: `... for <dog>: (<dog> <string>)`

### 4.6 Multimethods

`define-multimethod name ((T1 a1) (T2 a2) ...) body` (boot.l:691-696; boot2.l:710-715) stores the method in nested arrays, one level per argument (`%add-multimethod`, boot.l:678-689). Dispatch (boot.l:697-711; boot2.l:716-727) indexes by the type of each argument in turn. If the innermost entry is a method, it is applied. Otherwise the generic's default is used. If there is no default, the call errors with `no method in NAME corresponding to ARGS`.

- Each argument's type must match exactly. There is no walk up the base chain.
- `define-generic` gives a default (boot.l:674-676). Without one, nothing is used.

Probe: with `(define-multimethod comb ((<a> x) (<a> y)) ...)` and `(define-multimethod comb ((<b> x) (<a> y)) ...)`, `(comb (new <a>) (new <a>))` gave `(aa <a> <a>)` and `(comb (new <b>) (new <a>))` gave `(ba <b> <a>)`. `(comb (new <a>) (new <b>))` errored with `no method in comb corresponding to: (<a> <b>)` in all three.

So selectors inherit and multimethods do not. See 9.13.

### 4.7 Redefining a selector

`define-selector` on an existing selector is meant to leave it alone. In `eval` it does not return the selector. boot.l:539-540 reads `(list 'quote <variable>-value def)`, which quotes the bare symbol `<variable>-value` and ignores `def`. Probe: `(println "R1 value of second define-selector: " (define-selector sel))` printed `Form(Expr.<variable>-value=(*env* self), ())` in `eval`, and `<selector sel>` in `eval2` and `eval3`. boot2.l:557-558 reads `(list 'quote (cdr def))`, which is correct. The methods survive in all three (probe: a method added before the second call still answered).

---

## 5. Printing and other built-in selectors

### 5.1 do-print and do-dump

- `do-print` is `(define-selector do-print (arg) (%print arg))` (boot.l:560; boot2.l:578). `do-dump` calls `do-print` (boot.l:561; boot2.l:579). Both have defaults, so a type without a method prints by the default.
- `print`, `println`, `dump` and `dumpln` call `do-print` or `do-dump` for each argument (boot.l:563-589; boot2.l:580-605).
- Methods exist for `<selector>` (boot.l:591), `<pair>` (boot.l:593 and 608) and `<generic>` (boot.l:672). `do-dump` also has methods for `<string>` and `<array>` (boot.l:589-590).
- A pair's `do-print` prints its elements with `print`, so each element's `do-print` runs too. Probe: with `(define-method do-print <pt> () (print "PT!"))`, `(println (list (new <pt> 1 2)))` printed `(PT!)` in all three.
- The C printer does not call `do-print`. Error messages use it. Probe, with the same `do-print` method and a `too few arguments` call: `error: too few arguments applying Expr.<pt>.n=(self a) to (<pt>)` in all three.
- An instance with no `do-print` method prints as its type name, with no fields. Probe: `(print (new <pt> 1 2))` printed `<pt>`.
- A block whose type has no name prints as `<type=N>` (eval.c:966-975). Probe: `(allocate 99 1)` printed `<type=99>`.

### 5.2 Other built-in methods

- `length` (boot.l:1017-1018) and `at` (boot.l:1020-1021) are methods for `<string>` and `<array>`.
- `set-at` (boot.l:1023-1024) has methods for `<string>` and `<array>`. Both read the slot and return it; neither stores the value (see 9.10).
- `for-each` (boot.l:779-781) has methods for `<pair>`, `<array>` and `<string>`.
- `add-method` is a selector (4.4).

Each of these is a selector created by `define-method`, with no explicit default. An unmatched type therefore errors with the generated message.

---

## 6. Special forms, macros and closures as objects

### 6.1 Fixed

A name starting with `.` in the C subr table is registered as a `Fixed` object (eval.c:3255-3257). The `.`-prefixed names are `if`, `and`, `or`, `set`, `let`, `while`, `quote`, `lambda` and `define` (eval.c:3063-3071; the same list in eval2.c and eval3.c). A `Fixed` receives its arguments unevaluated (eval.c:1290-1292, 1389-1391). Probe: `(type-of if)` printed `11`, and `if` prints `Fixed<if>`.

`fixed?` is defined in `eval` only (eval.c:3093). Probe: `(fixed? if)` was undefined in `eval2` and `eval3`.

### 6.2 Form

`form fn symbol` (eval.c:2130-2132; eval2.c:2391-2394) makes a `Form`. Two fields are used:

- `function`, a macro. `expand` (eval.c:1015-1030) applies it to the call and re-expands the result. In `eval` the macro receives the environment and then the arguments (eval.c:1024: `newPairFrom(env, getTail(expr), expr)`). In `eval2` it receives only the arguments (eval2.c:1139-1175).
- `symbol`, a symbol macro, applied to a bare symbol (eval.c:1047-1055).

`define-form name args body` (boot.l:130-131; boot2.l:131-132) produces `(define name (form (lambda ...)))`. The lambda takes `(*env* args...)` in `eval` and `(args...)` in `eval2` and `eval3`. Probe: `(println define-form)` printed `Form(Expr.define-form=(env name args . body), ())` in `eval` and `Form(Expr.define-form=(name args . body), ())` in `eval2`.

### 6.3 Expr

An `Expr` is a closure: `name`, `defn` (which holds `(env formals . body)`), `ctx` and `profile` (eval.c:86, apply at eval.c:1341-1388). Named functions and methods are `Expr` objects. `define` and `add-method` set the name. An `Expr` prints as `Expr.NAME=(FORMALS)` (eval.c:894-900).

### 6.4 Subr

A `Subr` is a C primitive with a name and implementation (eval.c:89). Its type is 12, and it prints as its name (`car`). A subr with a signature (the typed foreign interface) is applied through `ffcall` (eval.c:1395).

### 6.5 Variable, Env, Context

In `eval` these three are C objects (eval.c:90-92) and the boot file has matching structures (boot.l:428-430). In `eval2` and `eval3` they are commented out in C (the enum and struct declarations in eval2.c and eval3.c) and in boot2.l (boot2.l:450-490). Instead `current-environment` (eval2.c:2312-2315, eval3.c:2322-2325) returns the evaluator's environment, and `with-forms` (boot2.l:494-506) extends it. `with-forms` in `eval` uses the `<env>` structure (boot.l:479-493).

### 6.6 The four tables

`*expanders*`, `*encoders*`, `*evaluators*` and `*applicators*` are arrays indexed by type number (boot.l:245-248, `define-expand`, `define-encode`, `define-eval` and `define-apply`).

- In `eval`, `expand` (eval.c:1057), `encode` (eval.c:1186), the evaluator default (eval.c:1313) and `apply` (eval.c:1400) all read their table.
- In `eval2` and `eval3`, only `apply` reads `*applicators*` (eval2.c:1662; eval3.c:1671). The other three tables exist, but nothing reads them. Probe in both: `(define-eval <pt> (obj) (quote E))` raised no error, and `*evaluators*` grew without effect.

---

## 7. boot.l and boot2.l

| Topic | boot.l (`eval`) | boot2.l (`eval2`, `eval3`) |
|---|---|---|
| Integers | Tagged (eval.c:32) | Boxed (eval2.c:36, eval3.c:37 off) |
| Built-in structure list | boot.l:415-430, 16 types | boot2.l:433-445, 13 types |
| First user-defined type (after `<selector>` and `<generic>`) | 18 (`<selector>` 16, `<generic>` 17) | 15 (`<selector>` 13, `<generic>` 14) |
| `<expr>` fields | `(name defn ctx profile)`, boot.l:424 | `(name definition environment profile)`, boot2.l:442 |
| Environment | `<env>` and `<variable>` structures, boot.l:428-430 | alist, `current-environment` (eval2.c:2312) |
| `with-forms` | boot.l:479-493, uses `environment` and `environment-define` | boot2.l:494-506, conses onto the environment |
| `make` syntax | pairs, boot.l:384-394 | keywords with trailing colon, boot2.l:397-412 |
| `define-selector` redefinition | `(list 'quote <variable>-value def)`, boot.l:539-540 (bug) | `(list 'quote (cdr def))`, boot2.l:557-558 |
| Non-selector error text | prints the value, `5` | prints the pair, `(spare . 5)` |
| `define-form` expansion lambda | `(env args...)` | `(args...)` |
| Tables consulted | all four (6.6) | `*applicators*` only |
| `define-class` | 3 arguments; `define-class.l` may replace it | 3 arguments; `define-class.l` may replace it |

Built-ins that exist in one evaluator only (probes):

- `long-at`: `eval` only (`undefined variable: long-at` in `eval2` and `eval3`).
- `data`: `eval` and `eval3` (eval.c:3129, eval3.c:3421). In `eval2` it is undefined.
- `data-length`: `eval` and `eval3` (eval.c:3130, eval3.c:3422). Not in `eval2`.
- `fixed?`: `eval` only.
- `current-environment`: `eval2` and `eval3` (eval2.c:3358, eval3.c:3377). Commented out in `eval` (eval.c:3075).

The shared forms (`new`, `make`, `define-structure`, `define-class`, `define-selector`, `define-method`, `define-multimethod`, `typecheck`, `inherits-from`, `print`) exist in all three with the differences above.

---

## 8. Worked example: ir2.k and maru.k

### 8.1 ir2.k classes

`ir2.k` uses the object system as a class library. The pattern is:

- A base `define-structure` with fields: `<ir-type>` (ir2.k:21, fields name, size, alignment, pointer, function).
- Empty leaf classes: `<ir-label-type>`, `<ir-void-type>`, `<ir-scalar-type>`, `<ir-numeric-type>`, `<ir-integral-type>`, `<ir-floating-type>` (ir2.k:28-34). Each is `(define-class NAME BASE ())`.
- Classes with extra fields: `<ir-pointer-type>` adds `referent` (ir2.k:70), `<ir-function-type>` adds `ret-type` and `arg-types` (ir2.k:85), `<ir-struct-type>` adds `members` and `defined` (ir2.k:98).
- Predicates via `inherits-from`: `ir-type?` (ir2.k:23), `ir-pointer-type?` (ir2.k:70).
- Positional construction with `new`: `(new <ir-pointer-type> (list name '*) sizeof-pointer alignof-pointer () () type)` (ir2.k:75-77). The values are in field order: name, size, alignment, pointer, function, referent.
- Keyword construction with `make`: `(make <ir-struct-type> name: name members: members defined: defined)` (ir2.k:110). This is the boot2.l form. Probe: under `eval`, `(make <pt> x: 3 y: 4)` fails inside `concat-symbol` (3.7).
- Printing: `(define-method do-print <ir-struct-type> () (print "{struct "self.name"}"))` (ir2.k:100).
- Selectors with methods per class: `ir-check-type` is dispatched on `<ir-nop>`, `<ir-lit>` and others (ir2.k:356 and following). `(define-selector ir-nop? args ())` (ir2.k:359) gives an explicit empty default, and `(define-method ir-nop? <ir-nop> () 1)` gives the real method.

Because `ir2.k` relies on `make`'s keyword form, it needs `boot2.l`. Under `boot.l` the keyword form fails at the point it runs (3.7).

### 8.2 Typed structs in maru.k

`define-struct` in `maru.k` (maru.k:287-289) is not the object system. It appends `(name . members)` to `*maru-structs*` (maru.k:247, 288) and defines nothing at runtime. `compile-namespace` (maru.k:254-259) turns each entry into `ir-declare-struct-type` (ir2.k:114). That creates an `<ir-struct-type>` (ir2.k:102-112), the compile-time description of a C struct, with its members as `<ir-struct-member>` objects (ir2.k:121).

So typed struct declarations live in the compiler's type table. They get no runtime type number and no accessors in the object system. The `define-structure` at maru.k:1 (for `<extern>`) is the object system, and it is used in the same file.

---

## 9. Undefined or inconsistent behaviour

Each item gives the behaviour, where it comes from, and the probe output that shows it. Probes were run with `./eval`, `./eval2` and `./eval3` from the worktree root.

### 9.1 A second `define-selector` returns a Form in `eval` only

boot.l:539-540 (see 4.7). Output: `R1 value of second define-selector: Form(Expr.<variable>-value=(*env* self), ())` in `eval`; `<selector sel>` in `eval2` and `eval3`.

### 9.2 Out-of-range and malformed slot operations fail silently

`oopAt`, `oopAtPut`, `allocate` and `new` return nil with no message (eval.c:305-321, 2632-2638; boot.l:377-383). Probes, identical in all three:

- `(define-structure <pt> (x y))`, `(new <pt> 1 2 3)`, then `(<pt>-y ...)`: `2`. The third init is dropped.
- `(new <pt> 1)`, then `(<pt>-y ...)`: `()`. The field is nil.
- `(oop-at 5 0)`: `()`.
- `(oop-at p 7)` for a two-slot `p`: `()`.
- `(set-oop-at p 7 1)`: `()`. Nothing is written.
- `(new 99)`: `()`. No type 99 exists.
- `(allocate 'x 1)`: `()`. The type is not an integer.
- `(oop-at (cons 1 2) 0)`: `1`. `oop-at` reads any non-atomic block, pairs included, by slot index.

### 9.3 Raw-word fields are stored one way and read another

A field named with a leading `_` is read by `long-at` (boot.l:342; eval.c:2491). `new` writes with `set-oop-at` (boot.l:381). Probe: `(define-structure <q> (_n))` then `(<q>-_n (new <q> 5))` printed `11` in `eval`, which is the tagged form of 5, not 5. In `eval2` and `eval3`, `long-at` is undefined, so the same expression fails there (9.14).

### 9.4 Unchecked accessors under -O fail silently

With `-O`, accessors skip `%typecheck` (boot.l:358-361; `(optimised)` at eval.c:2682). Probe, `(<pt>-x 5)`:

- Without `-O`, in all three: `type check failed for field accessor: expected 18 <pt> got 2 <long>` (`expected 15` in `eval2` and `eval3`).
- With `-O`, in all three: `()`.

### 9.5 `make` takes different syntax in each evaluator, and the wrong one gives an unrelated error

See 3.7. `(make <pt> (x 3) (y 4))` works in `eval` only. `(make <pt> x: 3 y: 4)` works in `eval2` and `eval3` only. The other syntax fails inside `string-length` or `concat-symbol`, not in `make`.

### 9.6 An empty explicit default returns nil silently

See 4.1. `(define-selector speak (x))` then `(speak 3)` printed `()` in all three. A selector with no default errors on the same call (4.5). A caller cannot tell a missing method from one that returns nothing.

### 9.7 define-eval, define-expand and define-encode do nothing outside `eval`

See 6.6. Probe, `eval2` and `eval3`: `(define-structure <pt> (x y))`, `(define p (new <pt> 1 2))`, `(define-eval <pt> (obj) 'EVALUATED)`, then `(eval p)`. Output: `error: cannot eval (15): <pt>` (eval2.c:1574; eval3.c:1583). In `eval`, the same program printed `EVALUATED`. The definition itself raised no error in any evaluator.

### 9.8 A method naming an unknown field is an error at a different time

`(define-method m <pt> () self.zz)`. In `eval` the error comes at the definition: `undefined variable: self.zz`. In `eval2` and `eval3` the definition succeeds, and calling `m` gives `undefined variable: self.zz`. Method bodies are compiled eagerly in `eval`, and not in `eval2` and `eval3`.

### 9.9 The C printer ignores do-print

See 5.1. Error messages and `doprint` do not call the `do-print` selector. Probe: with a `do-print` method for `<pt>` printing `PT!`, the arity error printed `to (<pt>)`. `print` and `println` print `PT!`. Two printers give two answers for one object.

Instances print as a bare type name, with no fields, unless a `do-print` method is defined (5.1; probe `<pt>`).

### 9.10 `set-at` does not store

boot.l:1023-1024. The methods for `<string>` and `<array>` are `(string-at self index)` and `(array-at self index)`. The value argument is ignored. Probe, `(define a (array 2))`, `(set-at a 0 5)`, `(at a 0)`: `()` in all three. The string case: `(set-at s 0 (string-at "q" 0))` left `(string-at s 0)` at `120`, which is `x` and not `q`, in all three.

### 9.11 Accessors are macros

`<pt>-x` is a `Form`, not a function (3.5). It cannot be passed to `map`, stored in a variable, or applied through `apply`. Probes: `(map <pt>-x (list p))` gave `error: cannot apply: Form(Expr.<pt>-x=...)` in all three. In `eval2` and `eval3` the message repeats the prefix: `error: error: cannot apply: ...` (eval2.c and eval3.c `fatal` text).

### 9.12 Derivatives are recorded and never read

`%structure-derivatives` is written at boot.l:405-407 and boot2.l:423-424, and read nowhere (3.6).

### 9.13 Selectors inherit and multimethods do not

Selectors walk the base chain (4.3). Multimethods match each argument exactly (4.6). Probe: `(comb (new <a>) (new <b>))` gave `error: no method in comb corresponding to: (<a> <b>)` in all three, and `(speak c)` for a `<cat>` with only an `<animal>` method gave the `<animal>` method. Both are defined behaviour, but a reader meeting them together should expect different answers.

### 9.14 Built-in names differ between evaluators

- `long-at`: `undefined variable: long-at` in `eval2` and `eval3`.
- `data`: `undefined variable: data` in `eval2`. It works in `eval` and `eval3`.
- `data-length`: `undefined variable: data-length` in `eval2`.
- `fixed?`: undefined in `eval2` and `eval3`.

### 9.15 Types and integers cannot be told apart

A type is an integer (3.2). Probe: `(define-structure <a> (x))` then `(println "T1 type-of <a>: " (type-of <a>) " value: " <a>)` printed `T1 type-of <a>: 2 value: 18` in `eval`. A selector given the integer 18 dispatches as `<long>`: `(sz 18)` gave `selector sz has no method for <long>: (18)` in all three. `(inherits-from 18 <a>)` printed `t` in `eval` and `()` in `eval2` and `eval3`, because 18 is `<a>` in `eval` and not in `eval2` and `eval3`.

### 9.16 Redefining a structure name leaves old instances failing

Probe: `(define-structure <p> (x))`, `(define old (new <p> 1))`, `(define-structure <p> (x y))`, then `(%typecheck <p> old)`. Output in `eval`: `type check failed for field accessor: expected 22 <p> got 21 <p>`. The new `<p>` is a new type number, and old instances keep the old number. The code does not say whether this is intended.

### 9.17 `new` on the undefined type gives a non-nil object

`(new <undefined>)` allocates a block of size 0 with type 0, so it is not nil but has the type of nil. Probe: `(new <undefined>)` printed `UNDEFINED` in all three, which is the name of type 0 in the printer.

### 9.18 Define-class with methods fails under the boot files

See 3.6. `define-class` with a constructor and methods, as in the comments of define-class.l:46-54, works only after `define-class.l` has been loaded. The boot files reject it at expansion time.

---

## 10. Not covered

- The typed side, beyond `define-struct` and the `<ir-struct-type>` objects in 8.2: how `ir2` lays out and emits structs, and how typed code reads fields.
- The foreign-call path (`ffcall`, `proto_t`), the undo log behind `set-oop-at` (eval.c:2662), and `recover.l`'s use of it.
- Whether the collector scans `_`-prefixed fields as oops. `long-at` writes raw words into a block that `_newOops` allocates scanned (3.4, 9.3). That was not tested.
- The grammar and `.g` files, which do not use the object system.
