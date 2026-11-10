# Maru's object system, as implemented

This describes the object system as the code in this tree implements it (main at d29d40b; the files cited here are unchanged from the branch base 8ab7552). Where the code is the only definition, the text says what the code does. It does not say what the code should do. Citations are `file:line` in this tree.

Three evaluators run the system:

- `eval` (eval.c, loads `boot.l`). It has tagged integers and `Variable`, `Env` and `Context` as C objects.
- `eval2` (eval2.c) and `eval3` (eval3.c). Both load `boot2.l`. Neither has tagged integers nor the three environment objects in C.

The boot files load at startup (eval.c:3375, eval2.c:3652, eval3.c:3672) unless `-b` is given.

Probe method: `make` in the worktree, then small scripts run as `./eval FILE`, `./eval2 FILE`, `./eval3 FILE`. The scripts lived in a temporary directory outside the tree and are not kept. Every probe quoted here was rerun on 2026-11-06. Output is quoted with terminal escape codes removed. Where a result is quoted for only one evaluator, the others did the same unless stated. Type numbers in quoted output depend on what the script defined before: each script defined `<pt>` (or the type named) first unless stated, so `<pt>` is 18 in `eval` and 15 in `eval2` and `eval3`. The probes of worlds (3.10) load `recover.l`, which needs `make arm64.g.l x86.g.l abi.g.l stub-arm64.g.l stub-x64.g.l` first, and read the undo log's size with `(subr "maru_undo_log_size" ">l")`, as check/laws/gc-model.l:80 does.

---

## 1. The model in brief

1. Every heap object is a GC block. Its header holds an integer `type` (eval.c:35, gc.c:41-61). The collector never reads it.
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
- `getType` returns `Undefined` (0) for nil (eval.c:115-119, eval2.c:136, eval3.c:139). The tagged variant is at eval2.c:134 and eval3.c:137, compiled out there.
- `eval` defines `TAG_INT` as 1 (eval.c:32). `getType` returns `Long` for any word with bit 0 set (eval.c:116). `newLong` tags a value when its shifted word fits and boxes it otherwise (eval.c:182). `isLong` accepts either form (eval.c:181).
- `eval2` and `eval3` have `TAG_INT` commented out (eval2.c:36, eval3.c:37). Every `Long` is a heap block with a `bits` field.

Probe, all three evaluators: `(type-of 3)` printed `2`, and `(type-of (* 1099511627776 4))` printed `2`.

### 2.2 The header and the type field

The GC header is defined in gc.c:41-61. Its last member is `GC_APP_HEADER`, which each evaluator defines:

- `eval.c:35`: `int type; unsigned int length;`. `length` holds the length a `Data` was made with.
- `eval2.c:39-43`: `int type;` (plus `printing` in debug builds). No length.
- `eval3.c:40-44`: `int type; unsigned int length;`.

`setType` writes the field (eval.c:113). `getType` reads it (eval.c:115-119). `_newBits` allocates a block with `GC_malloc_atomic`, so the collector does not scan it. `_newOops` uses `GC_malloc`, so it does (eval.c:158-159). What the collector does with a scanned block is in 9.3.

### 2.3 The kinds

The C enum gives the built-in kinds: eval.c:77, eval2.c:86-89 and eval3.c:87-90. The numbers are what `type-of` returns.

| No. | Kind | eval | eval2 / eval3 |
|---|---|---|---|
| 0 | Undefined (nil) | yes | yes |
| 1 | Data | yes | yes |
| 2 | Long | yes | yes |
| 3 | Double | yes | yes |
| 4 | String | yes | yes |
| 5 | Symbol | yes | yes |
| 6 | Pair | yes | yes |
| 7 | _Array (the raw slot block) | yes | yes |
| 8 | Array | yes | yes |
| 9 | Expr | yes | yes |
| 10 | Form | yes | yes |
| 11 | Fixed | yes | yes |
| 12 | Subr | yes | yes |
| 13 | Variable | yes | commented out (eval2.c:88, eval3.c:89) |
| 14 | Env | yes | commented out |
| 15 | Context | yes | commented out |

The C structs (eval.c:79-92; eval2.c:93-106; eval3.c:96-109) give each kind's slots. Two differ between evaluators:

- `Expr`: `{name, defn, ctx, profile}` in eval.c:86 and `{name, definition, environment, profile}` in eval2.c:100 and eval3.c:103.
- `Symbol`: `{bits}` in eval.c:83 and `{bits, flags}` in eval2.c:97 and eval3.c:100.

Kinds and structure types share one space of integers. In `eval`, 13 to 15 are kinds. In `eval2` and `eval3` those kinds don't exist, and `%allocate-type` gives 13 to the next structure the boot file defines, `<selector>` (3.1). So one number can name a C kind in one evaluator and a Maru structure in another: type numbers are per evaluator.

### 2.4 Data

`newData(len)` allocates an atomic block and stores `len` in the header (eval.c:172-178). The `data` primitive is at eval.c:2412-2417 and is registered at eval.c:3129. `data-length` returns the stored length (eval.c:2419-2424). A `Data` prints as `<data[N]>` (eval.c:823-829).

`data` takes a length only if its argument is an integer, and makes a zero-length `Data` otherwise, with no message (eval.c:2415, eval3.c:2705). Probe, `eval` and `eval3`: `(data 'x)` printed `<data[0]>` with `data-length` `0`, and `(data 2.5)` printed `<data[0]>`.

`eval2` has no length in the header, no `data` primitive and no `data-length`; `data` is undefined there (see 9.14). `eval3` has both (eval3.c:2702, 2709, 3421-3422).

### 2.5 Slots and allocation

- `oopAt` and `oopAtPut` (eval.c:305-320; eval2.c:326-342; eval3.c:335-351) work only when the object is non-nil, not a tagged integer, and not atomic, and the index is inside `GC_size / sizeof(oop)`. Otherwise `oopAt` returns nil and `oopAtPut` stores nothing and returns nil. Nothing is reported.
- `GC_size` is the size of the block the allocator handed out, which can be larger than the size asked for. `GC_malloc` splits a free block only if it is at least the request plus a header plus one word (gc.c:210, 240); otherwise the whole block is used. It zeroes the whole block (gc.c:254). So the bound `oopAt` checks is the block's size, not the structure's, and depends on which free block the allocator found (see 3.7 and 9.2).
- `allocate type size` (eval.c:2632-2638) returns `_newOops(type, size * sizeof(oop))`. It returns nil silently when either argument is not a `Long` (eval.c:2635-2636).
- `allocate-atomic type bytes` (eval.c:2640-2646) is the same, for atomic blocks.
- `oop-at obj i` and `set-oop-at obj i v` (eval.c:2648-2664) call `oopAt` and `oopAtPut`. `set-oop-at` also records an undo entry first (eval.c:2662; see 3.10).
- `long-at` and `set-long-at` read and write a raw C `long` at byte offset `i * sizeof(long)` (the `accessor(long, ...)` expansion at eval.c:2491 of the macro at eval.c:2451-2482). `checkRange` (eval.c:2440-2449) checks the offset against a `Data`'s length or the block's size, but takes a `Long` argument as a raw address with no check (eval.c:2442). They record no undo entry. They exist only in `eval` (eval.c:3145-3146; commented out at eval2.c:3417-3418 and eval3.c:3437-3438).

### 2.6 type-of

`type-of` returns `newLong(getType(x))` (eval.c:2058-2062; eval2.c:2317-2321; eval3.c:2327-2331). A type is therefore a plain integer; there is no separate type object. For a structure type `T`, `(type-of instance)` is `T`'s integer.

### 2.7 The C printer

`doprint` (eval.c:811; eval2.c:875; eval3.c:884) switches on the kind. Its default branch (eval.c:966-977) looks up the name of the type in `%type-names`. If there is a name it prints it, and otherwise it prints `<type=N>`. Instances of structures therefore print as their type name, with no fields (see 5.1).

### 2.8 Evaluation and application

`eval` in eval.c (1280-1323):

- Undefined, Long, Double and String evaluate to themselves (eval.c:1284-1288).
- A `Pair` evaluates its head. If the head is `Fixed`, the function gets the unevaluated tail (eval.c:1293-1294). Otherwise the tail is evaluated and `apply` is called (eval.c:1295-1300).
- A `Variable` reads its value (eval.c:1304-1310).
- Any other kind goes to the default (eval.c:1311-1320), which looks up the `*evaluators*` table by type. If there is an entry, it is applied to the object. If not, the object is returned. So `Form`, `Subr`, `Fixed`, and instances of user types with no entry in `*evaluators*`, evaluate to themselves.

`eval` in eval2.c and eval3.c differs:

- Undefined, Long, Double, String, Form, Subr and Fixed evaluate to themselves, listed explicitly (eval2.c:1538-1546; eval3.c:1547-1555).
- A `Symbol` is looked up in the environment (eval2.c:1561-1565; eval3.c:1570-1574).
- Any other kind is fatal: `cannot eval (N): OBJ` (eval2.c:1574; eval3.c:1583). `*evaluators*` is not read.

Probe: `(eval car)` printed `car`, `(eval if)` printed `Fixed<if>` and `(eval (form ()))` printed `Form((), ())` in all three. `(eval (new <pt> 1 2))` printed `<pt>` in `eval` and `error: cannot eval (15): <pt>` in `eval2` and `eval3`.

`apply` (eval.c:1337-1414):

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
- `boot2.l:433-445` defines the same list without `<variable>`, `<env>` and `<context>`. So the first type after the built-ins is 16 in `eval` and 13 in `eval2` and `eval3`. The boot files then define `<selector>` and `<generic>`, so the first user type is 18 in `eval` and 15 in `eval2` and `eval3`.

Probe: in `eval`, `(name-of-type 13)` printed `<variable>`. In `eval2` and `eval3` it printed `<selector>`, and `<variable>` is unbound (`eval: undefined variable: <variable>`). `<selector>` printed `16` in `eval` and `13` in `eval2`, and `<generic>` `17` and `14`.

### 3.2 A type is an integer

`define-structure` binds the name to the integer (boot.l:366-375; boot2.l:374-383 is the same). Probe: `<pt>` printed `18` in `eval` and `15` in `eval2` and `eval3`, and `(type-of <pt>)` printed `2`, the `<long>` type. Predicates such as `long?` compare with `=` (boot.l:417).

### 3.3 define-structure

`define-structure name (fields...)` (boot.l:366-375; boot2.l:374-383). At expansion time:

1. It allocates a type number (boot.l:367).
2. It checks for duplicate field names (boot.l:369, `sanity-check-structure-fields`, boot.l:319-327). Probe: `(define-structure <dup> (a a))` printed `error: field 'a' multiply-defined in structure: <dup> (a a)`.
3. It records the size and field list in `%structure-sizes` and `%structure-fields`.
4. It expands to `(let () (define name type) accessors... type)`.

Because the number is allocated before the check, a rejected definition still uses one up, and `%type-names` holds its name. Probe, with `recover.l` loaded and a handler that declines, so it runs where the error happened: `%last-type before: 27`, then `%last-type in handler: 28 name: <dup>` in `eval` (24 and 25 in `eval2` and `eval3`). `define-class` checks first and allocates after (boot.l:398-399).

It records no base, so `%structure-bases` has no entry for the type. There is no root class in the boot files: `<object>` is undefined (probe: `(defined? '<object>)` gave `()`).

### 3.4 Field layout

- Slot `i` holds field `i`, in the order of the field list (boot.l:344-356; `%make-accessors`, boot.l:363-364).
- A subtype's field list is its base's fields followed by its own (boot.l:397, `concat-list`). Base fields therefore keep their offsets in subtypes. Probe: with `(define-class <pt3> <pt> (z))`, `(<pt>-x q)` and `(<pt>-y q)` gave `1` and `2` on a `<pt3>` instance, and `%structure-fields` of `<pt3>` was `(x y z)`.
- Size is the number of fields (`list-length`, boot.l:368 and 401), and `allocate` asks for that many pointer-sized slots (eval.c:2637).
- Fields are oops. `new` stores with `set-oop-at` (see 3.7).
- A field whose name starts with `_` gets a `T-F` accessor that uses `long-at` (`%accessor`, boot.l:342; boot2.l:350). That is a raw-word accessor, while `new` stores tagged oops and `self.F` (3.8) reads with `oop-at`. See 9.3.
- The built-in structures name their raw C fields with `_` (`<long>` `(_bits)`, `<string>` `(size _bits)`, `<subr>` `(_name _imp _sig _profile)`, boot.l:417-427). Their accessors use `long-at` too, so in `eval2` and `eval3` they fail: `(<long>-_bits 3)` gave `eval: undefined variable: long-at`. In `eval`, `(<string>-_bits "ab")` printed a raw pointer (`31075944912`), and `(<long>-_bits 3)` exited with status 139 and no output: `checkRange` took the tagged 3 as an address (eval.c:2442).

### 3.5 Accessors and type checks

For each field `F` of structure `T`, `define-structure` and `define-class` make a macro named `T-F` through `%make-accessors` (boot.l:363-364).

- Safe accessors (`%make-safe-accessor`, boot.l:344-349) expand to `(oop-at (%typecheck T self) i)`.
- Unsafe accessors (`%make-unsafe-accessor`, boot.l:351-356) expand to `(oop-at self i)`.
- `%typecheck type object` (boot.l:334-338) accepts an object whose type is `type` or inherits from it. Otherwise it errors with `type check failed for field accessor: expected N <T> got M <X>`.

The choice is made once, when the boot file loads: `%make-accessor` is bound to the unsafe version when `(optimised)`, the `-O` count (eval.c:2682-2689), is greater than 0 (boot.l:358-361). Every accessor made afterwards uses that choice, whatever `(optimised)` says later. Probe, without `-O`: `(optimised 1)`, then `(optimised)` printed `1`, then a fresh `(define-structure <pt> (x y))` and `(<pt>-x 5)` still gave `type check failed for field accessor: expected 18 <pt> got 2 <long>` (`expected 15` in `eval2` and `eval3`).

With `-O` the accessors check nothing, in all three. Probes, `./eval -O` and the same in `eval2` and `eval3`:

- `(<pt>-x (cons 7 8))` printed `7`: the pair's head, read as field 0.
- `(set (<pt>-x 5) 1)` printed `()`, and nothing was reported.
- `(<pt>-x 5)` printed `()`.
- An explicit `(%typecheck <pt> 5)` still errors: `type check failed for field accessor: expected 18 <pt> got 2 <long>`.

Accessors are macros, not functions. Probe: `(println "A14 accessor as value: " <pt>-x)` printed `Form(Expr.<pt>-x=(*env* self), ())` in `eval` and `Form(Expr.<pt>-x=(self), ())` in `eval2` and `eval3`. A variable can hold one: `(define acc <pt>-x)` then `(acc p)` printed `1` in all three, because `acc` is then bound to the same Form and the expander finds it (eval.c:1020-1030). What fails is using one as a function value, as `map` and `apply` do (9.11).

`set` on an accessor works through the expander. In `expand` (eval.c:1034-1041; eval2.c:1154-1161), a `(set (head ...) v)` form whose place has already been expanded takes the expanded head's name and calls `set-<name>`. An accessor expands to `oop-at` or `long-at`, so the place becomes `set-oop-at` or `set-long-at`. There is no `set-<T>-<field>` function. Probe: `(defined? 'set-<pt>-x)` gave `()`, and `(set (<pt>-x p) 42)` then `(<pt>-x p)` gave `42`.

### 3.6 define-class and inheritance

`define-class name base (fields...)` (boot.l:395-411; boot2.l:413-429):

- `base` is evaluated at expansion time.
- `fields` becomes the base's fields followed by the new ones (boot.l:397).
- It records the size, the field list and `%structure-bases[type] = base`.
- It appends the new type to `%structure-derivatives[base]` (boot.l:405-407; boot2.l:423-425).
- It expands to the same shape as `define-structure`.

`%structure-derivatives` is written and never read. Grep finds no reader in the boot files, the C code, or the `.k` files outside `define-class.l` and `test-pepsi.l`, which write it too.

`inherits-from type base` (boot.l:329-332; boot2.l:337-340) is reflexive and walks `%structure-bases`. Predicates in the code use it, for example `ir-type?` (ir2.k:23). Predicates that compare with `=`, such as `long?`, `expr?` and `selector?`, match exact types only.

Only the three-argument `define-class` is in the boot files. A fourth argument is an error. Probe: `(define-class <foo> <object> (x y) (foo (x y) (set self.x x)))` printed `error: too many arguments applying Expr.define-class=(*env* name basis fields) to (<foo> <object> (x y) (foo (x y) (set self.x x)))` in `eval` and the same with `(name basis fields)` in `eval2` and `eval3`.

No constructor is generated. Callers use `new` or `make`.

### 3.7 new and make

`new type inits...` (boot.l:377-383; boot2.l:385-390) expands to:

```
(let* ((_type_ T) (_self_ (allocate _type_ (array-at %structure-sizes _type_))))
  (set-oop-at _self_ 0 init0) ... _self_)
```

It is positional and checks nothing. Its behaviour is set by `allocate` and `set-oop-at`:

- Missing inits leave their fields nil. Probe: `(<pt>-y (new <pt> 1))` printed `()`.
- Extra inits are stored with no message if the block has room for them, and dropped if not. The bound is the block's size (2.5), so the outcome depends on which free block the allocator found. Probe: `(define q (new <pt> 1 2 3))`, then `(oop-at q 2)` and `(oop-at q 3)`: `Q slot 2: ()  slot 3: ()` in `eval`, and `Q slot 2: 3  slot 3: ()` in `eval2` and `eval3`, where the third init went into the block's slack. In every evaluator the declared fields are right: `(<pt>-y (new <pt> 1 2 3))` printed `2`.
- An unregistered type number gives nil, because the size is nil and `allocate` returns nil (eval.c:2636). Probe: `(new 99)` printed `()`.
- `(new <expr>)` makes an `Expr` with all slots nil. Probe: printed `Expr=()`.

`make type inits...` takes keyword pairs in every boot (boot.l, boot2.l): `(make <pt> x: 3 y: 4)` gives fields `(3 4)` on
`eval`, `eval2` and `eval3` (check/boot-forms.l). `%make-field-name` removes the keyword's colon to name the field, and
`%make-make-inits` builds `(set (T-x self) v)` forms inside `with-instance-accessors`. Until 2026-11-07 boot.l kept the
older association form, `(make <pt> (x 3) (y 4))`; Piumarta moved boot2.l to keywords in 2013 (608d514), and boot.l
now follows it.

### 3.8 Fields inside methods: self.field

`make-instance-accessors` (boot.l:493-496; boot2.l:510-513) defines, for each field `F` at index `i`, a form named `self.F` that expands to `(oop-at self i)` (boot.l:495; boot2.l:512). `with-instance-accessors type body...` (boot.l:498-500; boot2.l:515-518) puts those forms in scope with `with-forms`.

`add-method` wraps each method body in `with-instance-accessors` for its type when the method is defined (boot.l:550-552; boot2.l:568-570). So inside a method:

- `self.F` reads or writes slot `i` directly, with no type check.
- `self.F` is always `oop-at`, even for a `_` field, unlike the `T-F` accessor (3.4). Probe, `eval`: with `(define-structure <r> (_n))`, `(define r (new <r> 5))` and a method returning `self._n`, `(<r>-_n r)` printed `11` and the method `5`. In `eval2` and `eval3` the method gave `5` and `<r>-_n` is the `long-at` error.
- Only the fields of the method's type, including inherited ones, are names in scope.
- `(set self.F v)` works, through the same expansion as 3.5.

A method body is evaluated at global scope. `define-method` quotes the body (boot.l:556) and `add-method` builds the lambda with `eval` and no environment (boot.l:552), so names bound around the `define-method` form are not visible in it. Probe: `(define secret 'global)`, then `(let ((secret 'local)) (define-method show <pt> () secret))`, then `(show p)` printed `global` in all three.

Unknown names are an error that depends on the evaluator. See 9.8.

### 3.9 define-class.l (not loaded by default)

`define-class.l` (60-75) redefines `define-class` as `(name base fields . functions)`. Its functions are:

- constructors (`=` and `-` specs, define-class.l:15-33),
- methods as `(selector (args) body...)` (define-class.l:12-13),
- `@`, which defines a `do-print` method printing `{<T> field=value ...}` (define-class.l:1-10).

`assembler.k:22` and `test-call.k:1` require it. Loaded on the command line it works the same in all three evaluators (probe: `{<foo> x=1 y=4}` from `@`, in each). Once loaded, its definition replaces the boot file's `define-class` for the rest of the run.

### 3.10 Objects in a world (recover.l)

`recover.l`'s `try` runs its body in a world (recover.l:56-80): writes through primitives are logged (undo.c, undo.irl), and undone if the body fails. For objects:

- A field write through `set-oop-at`, and so through a `T-F` accessor or `self.F`, is logged (eval.c:2662; eval2.c:2933; eval3.c:2952) and undone. Probe: `(set (<pt>-x p) 99)` then `(error "boom")` inside `try`; afterwards `(<pt>-x p)` printed `1` in all three.
- A `_` field written with `set-long-at` is not logged (2.5). Probe, `eval` only (the others have no `set-long-at`): `<q>` with fields `(_n m)`, `_n` set to 7 and `m` to 0; in a failed world both set to 9; afterwards `_n after failed world: 9  m: 0`.
- `new` logs one entry per init, since each is a `set-oop-at`; `allocate` logs nothing. Probe, each in its own world: `(new <three>) 0, (new <three> 1) 1, (new <three> 1 2 3) 3` in all three. (A first `set` of a `let`-bound local in the world is logged too, so a probe that sets its own counter inside the world counts one more.)
- `define-structure` and `define-class` register their type when they expand, which is before an enclosing `try`'s world is open, and the arrays they write (`%type-names`, `%structure-sizes`, `%structure-derivatives` …) are written from Maru with `set-array-at` at expansion time, outside it. A failed world keeps them. Probe: `(try (let () (define-class <ghost> <pt> (z)) (error "boom")) ...)`; afterwards `%last-type` had gone from 28 to 29 with name `<ghost>`, and `%structure-derivatives` of `<pt>` was `Array<1>(29)` (25, 26 and `Array<1>(26)` in `eval2` and `eval3`). The name `<ghost>` stayed bound in `eval` and was unbound in `eval2` and `eval3`, as recover.l:15 says of definitions.

---

## 4. Selectors and dispatch

### 4.1 define-selector

`define-selector name [formals body...]` (boot.l:536-546; boot2.l:554-564):

- If `name` is already a selector, the form does nothing useful (see 4.7).
- If `name` is bound to something else, it errors: `NAME already defined as non-selector: VALUE`. Probe: `(define spare 5)` then `(define-selector spare)` printed `error: spare already defined as non-selector: 5` in `eval` and `... non-selector: (spare . 5)` in `eval2` and `eval3`.
- The default is `(lambda formals body...)`. With no default, a generated lambda errors with `selector NAME has no method for TYPE: (ARG TYPE...)`. The generated text is at boot.l:543-545.
- The result is `(define name (selector 'name default))` (boot.l:546).

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
- The inherited method is not copied into the child's table. The copy-down line is commented out (boot.l:513).
- With no arguments, `(car args)` is nil, so the call dispatches as `<undefined>`. Probe: a method installed on `<undefined>` with `(<selector>-add-method which <undefined> (lambda args (list 'as-nil args)))` answered `(which)` with `(as-nil ())` in all three. A method from `define-method` is chosen the same way, then fails its own arity, since its first formal is `self`: `error: too few arguments applying Expr.<undefined>.which=(self) to ()`.

Probe, inheritance with three levels (`<a>`, `<b>` inherits `<a>`, `<c>` inherits `<b>`): with a method only on `<a>`, `(f (new <c>))` gave `from-a`. After adding a method on `<b>`, it gave `from-b`. The nearest ancestor wins.

### 4.4 define-method

`define-method selector type (args) body...` (boot.l:554-556; boot2.l:572-574):

1. If `selector` is not defined, it is created with `define-selector`.
2. It expands to `(add-method selector type '(self . args) 'body)`.

`add-method` is itself a selector (boot.l:548-552; boot2.l:566-570). Its method for `<selector>` evaluates the body with `with-instance-accessors` and calls `<selector>-add-method` (boot.l:529-534; boot2.l:547-552). That function names the `Expr` `<T>.selector` if it has no name, and stores it at `methods[T]`.

So methods are `Expr` objects. Probe: `(array-at (<selector>-methods f) <a>)` printed `Expr.<a>.f=(self)`, and the `<b>` method's `<expr>-name` printed `<b>.f`.

The first formal is always `self`.

`define-method` checks only that the name is bound. If it is bound to something that is not a selector, `add-method` is called with that value as its receiver and dispatches on its type. Probe: `(define-method car <pt> () 1)` printed `error: selector add-method has no method for <subr>: (car <long> <pair> <pair>)` in all three.

### 4.5 Tagged integers, nil and other kinds

Dispatch uses `type-of`, so the table index for each kind is the kind number from 2.3:

- nil dispatches as `<undefined>` (0).
- Every integer dispatches as `<long>` (2), whether tagged in `eval` or boxed. Probe: a method on `<long>` returned `a-long` for `(kind 3)` and for `(kind (* 1099511627776 4))` in all three evaluators.
- A method on `<undefined>` is found by nil, and by a call with no arguments (4.3).

A selector with no method and no default errors. The message names the first argument's type and the types of the others (boot.l:543-545). Probe outputs in all three evaluators:

- `(speak 3)`: `selector speak has no method for <long>: (3)`
- `(speak 1.5)`: `... for <double>: (1.500000)`
- `(speak "str")`: `... for <string>: (str)`
- `(speak 'sym)`: `... for <symbol>: (sym)`
- `(speak car)`: `... for <subr>: (car)`
- `(speak (cons 1 2))`: `... for <pair>: ((1 . 2))`
- `(speak ())`: `... for <undefined>: (())`
- `(speak d "x")` with `d` a `<dog>`: `... for <dog>: (<dog> <string>)`

The built-in selectors behave the same way: `length` has methods for `<string>` and `<array>` only (5.2), so `(length (list 1 2))` printed `error: selector length has no method for <pair>: ((1 2))` in all three. Lists use `list-length`.

### 4.6 Multimethods

`define-multimethod name ((T1 a1) (T2 a2) ...) body` (boot.l:691-696; boot2.l:710-714) stores the method in nested arrays, one level per argument (`%add-multimethod`, boot.l:678-689). Dispatch (boot.l:697-708; boot2.l:716-727) indexes by the type of each argument in turn. If the innermost entry is a method, it is applied. Otherwise the generic's default is used.

- Each argument's type must match exactly. There is no walk up the base chain.
- `define-generic name [formals body...]` (boot.l:674-676) always installs a default. With none given, the default is a lambda that errors with `no method in NAME corresponding to: ARGS`.
- `define-multimethod` calls `define-generic` when the name is undefined (boot.l:694), so a generic made either way has a default. The applicator's own error for a generic with no default (boot.l:708, `corresponding to` with no colon) is reached only by a generic made with `(generic name ())` directly.

Probe: `(define-generic plain)` then `(<generic>-default plain)` printed `Expr=args`, and after `(define-multimethod comb ((<a> x) (<a> y)) ...)` with `comb` undefined before, `comb` printed `<multimethod:comb>` with default `Expr=args`, in all three.

Probe: with `(define-multimethod comb ((<a> x) (<a> y)) ...)` and `(define-multimethod comb ((<b> x) (<a> y)) ...)`, `(comb (new <a>) (new <a>))` gave `(aa <a> <a>)` and `(comb (new <b>) (new <a>))` gave `(ba <b> <a>)`. `(comb (new <a>) (new <b>))` errored with `no method in comb corresponding to: (<a> <b>)` in all three: the default's message.

So selectors inherit and multimethods do not. See 9.13.

### 4.7 Redefining a selector

`define-selector` on an existing selector is meant to leave it alone. In `eval` it does not return the selector. boot.l:540 reads `(list 'quote <variable>-value def)`. That is a call to `list` with three arguments, and the middle one, `<variable>-value`, is an ordinary variable reference: it evaluates to the accessor's Form. So the expansion is `(quote #<Form> def)`, which evaluates to the Form. Probe: `(define-selector sel)` a second time printed `Form(Expr.<variable>-value=(*env* self), ())` in `eval`, and `<selector sel>` in `eval2` and `eval3`. boot2.l:558 reads `(list 'quote (cdr def))`, which is correct. The methods survive in all three (probe: a method added before the second call still answered `still-here`).

---

## 5. Printing and other built-in selectors

### 5.1 do-print and do-dump

- `do-print` is `(define-selector do-print (arg) (%print arg))` (boot.l:560; boot2.l:578). `do-dump` calls `do-print` (boot.l:561; boot2.l:579). Both have defaults, so a type without a method prints by the default.
- `print`, `println`, `dump` and `dumpln` call `do-print` or `do-dump` for each argument (boot.l:563-587; boot2.l:581-605).
- Methods exist for `<selector>` (boot.l:591), `<pair>` (boot.l:593 and 608) and `<generic>` (boot.l:672). `do-dump` also has methods for `<string>` and `<array>` (boot.l:589-590).
- A pair's `do-print` prints its elements with `print`, so each element's `do-print` runs too. Probe: with `(define-method do-print <pt> () (print "PT!"))`, `(println (list (new <pt> 1 2)))` printed `(PT!)` in all three.
- The C printer does not call `do-print`, and the evaluators' own error messages use the C printer. Probe, with the same `do-print` method and a `too few arguments` call: `error: too few arguments applying Expr.<pt>.n=(self a) to (<pt>)` in all three.
- An instance with no `do-print` method prints as its type name, with no fields. Probe: `(print (new <pt> 1 2))` printed `<pt>`.
- A block whose type has no name prints as `<type=N>` (eval.c:966-977). Probe: `(allocate 99 1)` printed `<type=99>`.

### 5.2 Other built-in methods

- `length` (boot.l:1017-1018) and `at` (boot.l:1020-1021) are methods for `<string>` and `<array>`.
- `set-at` (boot.l:1023-1024) has methods for `<string>` and `<array>`. Both read the slot and return it; neither stores the value (see 9.10).
- `for-each` (boot.l:779-781) has methods for `<pair>`, `<array>` and `<string>`.
- `add-method` is a selector (4.4).

Each of these is a selector created by `define-method`, with no explicit default. An unmatched type therefore errors with the generated message (4.5).

---

## 6. Special forms, macros and closures as objects

### 6.1 Fixed

A name starting with `.` in the C subr table is registered as a `Fixed` object (eval.c:3255). The `.`-prefixed names are `if`, `and`, `or`, `set`, `let`, `while`, `quote`, `lambda` and `define` (eval.c:3063-3071; the same list in eval2.c:3335-3343 and eval3.c:3354-3362). A `Fixed` receives its arguments unevaluated (eval.c:1293-1294, 1389-1391). Probe: `(type-of if)` printed `11`, and `if` prints `Fixed<if>`.

`fixed?` is defined in `eval` only (eval.c:3093; commented out at eval2.c:3365 and eval3.c:3384). Probe: `(fixed? if)` printed `t` in `eval` and `eval: undefined variable: fixed?` in `eval2` and `eval3`.

### 6.2 Form

`form fn symbol` (eval.c:2130-2133; eval2.c:2391-2394) makes a `Form`. Two fields are used:

- `function`, a macro. `expand` (eval.c:1015-1030) applies it to the call and re-expands the result. In `eval` the macro receives the environment and then the arguments (eval.c:1024: `newPairFrom(env, getTail(expr), expr)`). In `eval2` it receives only the arguments (eval2.c:1146).
- `symbol`, a symbol macro, applied to a bare symbol (eval.c:1044-1054).

`define-form name args body` (boot.l:130-131; boot2.l:131-132) produces `(define name (form (lambda ...)))`. The lambda takes `(*env* args...)` in `eval` and `(args...)` in `eval2` and `eval3`. Probe: `(println define-form)` printed `Form(Expr.define-form=(env name args . body), ())` in `eval` and `Form(Expr.define-form=(name args . body), ())` in `eval2` and `eval3`.

### 6.3 Expr

An `Expr` is a closure: `name`, `defn` (which holds `(env formals . body)`), `ctx` and `profile` (eval.c:86, apply at eval.c:1341-1388). Named functions and methods are `Expr` objects. `define` and `add-method` set the name. An `Expr` prints as `Expr.NAME=(FORMALS)` (eval.c:894-901).

### 6.4 Subr

A `Subr` is a C primitive with a name and implementation (eval.c:89). Its type is 12, and it prints as its name (`car`). A subr with a signature (the typed foreign interface) is applied through `ffcall` (eval.c:1394).

### 6.5 Variable, Env, Context

In `eval` these three are C objects (eval.c:90-92) and the boot file has matching structures (boot.l:428-430). In `eval2` and `eval3` they are commented out in C (eval2.c:88 and 104-106; eval3.c:89 and 107-109), absent from boot2.l's list of structures (boot2.l:433-445), and the functions over them are commented out (boot2.l:452-487). Instead `current-environment` (eval2.c:2312-2315, eval3.c:2322-2325) returns the evaluator's environment, and `with-forms` (boot2.l:494-506) extends it. `with-forms` in `eval` uses the `<env>` structure (boot.l:479-489).

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
| `with-forms` | boot.l:479-489, uses `environment` and `environment-define` | boot2.l:494-506, conses onto the environment |
| `make` syntax | pairs, boot.l:384-394 | keywords with trailing colon, boot2.l:397-411 |
| `define-selector` redefinition | `(list 'quote <variable>-value def)`, boot.l:540 (bug, 4.7) | `(list 'quote (cdr def))`, boot2.l:558 |
| Non-selector error text | prints the value, `5` | prints the pair, `(spare . 5)` |
| `define-form` expansion lambda | `(env args...)` | `(args...)` |
| Tables consulted | all four (6.6) | `*applicators*` only |
| Default of `eval` for other kinds | returns the object (2.8) | fatal `cannot eval` (2.8) |
| `define-class` | 3 arguments; `define-class.l` may replace it | 3 arguments; `define-class.l` may replace it |

Built-ins that exist in one evaluator only (probes):

- `long-at`, `set-long-at`: `eval` only (`eval: undefined variable: long-at` in `eval2` and `eval3`). So every `_` field accessor fails in `eval2` and `eval3`, the built-in types' included (3.4).
- `data`: `eval` and `eval3` (eval.c:3129, eval3.c:3421). In `eval2` it is undefined.
- `data-length`: `eval` and `eval3` (eval.c:3130, eval3.c:3422). Not in `eval2`.
- `fixed?`: `eval` only.
- `current-environment`: `eval2` and `eval3` (eval2.c:3358, eval3.c:3377). Commented out in `eval` (eval.c:3075).

The shared forms (`new`, `make`, `define-structure`, `define-class`, `define-selector`, `define-method`, `define-multimethod`, `%typecheck`, `inherits-from`, `print`) exist in all three with the differences above.

---

## 8. Worked example: ir2.k and maru.k

### 8.1 ir2.k classes

`ir2.k` uses the object system as a class library. The pattern is:

- A base `define-structure` with fields: `<ir-type>` (ir2.k:21, fields name, size, alignment, pointer, function).
- Classes that add no fields, each `(define-class NAME BASE ())` (ir2.k:28-34): `<ir-label-type>`, `<ir-void-type>`, `<ir-scalar-type>` and `<ir-varargs-type>` on `<ir-type>`; `<ir-numeric-type>` on `<ir-scalar-type>`; `<ir-integral-type>` and `<ir-floating-type>` on `<ir-numeric-type>`. So `<ir-scalar-type>` and `<ir-numeric-type>` are not leaves: `<ir-pointer-type>` (ir2.k:70) also inherits from `<ir-scalar-type>`.
- Classes with extra fields: `<ir-pointer-type>` adds `referent` (ir2.k:70), `<ir-function-type>` adds `ret-type` and `arg-types` (ir2.k:85), `<ir-struct-type>` adds `members` and `defined` (ir2.k:98).
- Predicates via `inherits-from`: `ir-type?` (ir2.k:23), `ir-pointer-type?` (ir2.k:70).
- Positional construction with `new`: `(new <ir-pointer-type> (list name '*) sizeof-pointer alignof-pointer () () type)` (ir2.k:75-78). The values are in field order: name, size, alignment, pointer, function, referent.
- Keyword construction with `make`: `(make <ir-struct-type> name: name members: members defined: defined)` (ir2.k:110), the form every boot takes (3.7).
- Printing: `(define-method do-print <ir-struct-type> () (print "{struct "self.name"}"))` (ir2.k:100).
- Selectors with methods per class: `ir-check-type` (ir2.k:311) is dispatched on `<ir-nop>`, `<ir-lit>` and others (ir2.k:356 and following). `(define-selector ir-nop? args ())` (ir2.k:359) gives an explicit empty default, and `(define-method ir-nop? <ir-nop> () 1)` (ir2.k:361) gives the real method.

Because `ir2.k` relies on `make`'s keyword form, it needs `boot2.l`. Under `boot.l` the keyword form fails at the point it runs (3.7).

### 8.2 Typed structs in maru.k

`define-struct` in `maru.k` (maru.k:287-288) is not the object system. It appends `(name . members)` to `*maru-structs*` (maru.k:247, 288) and defines nothing at runtime. `compile-namespace` (maru.k:254-259) turns each entry into `ir-declare-struct-type` (ir2.k:114). That creates an `<ir-struct-type>` (ir2.k:102-112), the compile-time description of a C struct, with its members as `<ir-struct-member>` objects (ir2.k:121).

So typed struct declarations live in the compiler's type table. They get no runtime type number and no accessors in the object system. The `define-structure` at maru.k:1 (for `<extern>`) is the object system, and it is used in the same file.

---

## 9. Undefined or inconsistent behaviour

Each item gives the behaviour, where it comes from, and the probe output that shows it. Probes were run with `./eval`, `./eval2` and `./eval3` from the worktree root.

### 9.1 A second `define-selector` returns a Form in `eval` only

boot.l:540 (see 4.7). Output: `A22 second define-selector: Form(Expr.<variable>-value=(*env* self), ())` in `eval`; `<selector sel>` in `eval2` and `eval3`.

### 9.2 Out-of-range and malformed slot operations fail silently

`oopAt`, `oopAtPut`, `allocate` and `new` return nil with no message (eval.c:305-320, 2632-2638; boot.l:377-383). "Out of range" means outside the GC block, whose size can exceed the structure's (2.5). Probes, identical in all three unless stated:

- `(define q (new <pt> 1 2 3))`, then `(oop-at q 2)`: `()` in `eval`, `3` in `eval2` and `eval3`, where the block had a slack slot (3.7). `(<pt>-y q)` gave `2` in all three.
- `(new <pt> 1)`, then `(<pt>-y ...)`: `()`. The field is nil.
- `(oop-at 5 0)`: `()`.
- `(oop-at p 7)` for a two-slot `p`: `()` in these runs. A larger free block would give a slot 7 to read (`()`, since blocks are zeroed) or write.
- `(set-oop-at p 7 1)`: `()`. Nothing was written.
- `(new 99)`: `()`. No type 99 exists.
- `(allocate 'x 1)`: `()`. The type is not an integer.
- `(oop-at (cons 1 2) 0)`: `1`. `oop-at` reads any non-atomic block, pairs included, by slot index.

### 9.3 Raw-word fields are stored one way and read another, and the collector reads them as pointers

A field named with a leading `_` is read by its `T-F` accessor with `long-at` (boot.l:342; eval.c:2491), but `new` writes with `set-oop-at` (boot.l:381) and `self.F` reads with `oop-at` (boot.l:495). Probe: `(define-structure <q> (_n))` then `(<q>-_n (new <q> 5))` printed `_n: 11` in `eval`, which is the tagged form of 5, not 5; a method reading `self._n` gave `5` (3.8). In `eval2` and `eval3`, `long-at` is undefined, so the accessor fails there (9.14).

The collector knows nothing of `_` fields. gc.c never reads the header's `type`. `GC_mark` (gc.c:374-392) skips a word with bit 0 set and a block already marked, and stops at an atomic block; otherwise the default mark function (gc.c:352-364) treats every non-zero even word in the block as a pointer, from the first word to the end of the block, slack included (2.5). Nothing checks that the word points into the heap. So a raw even number written into a `_` field with `set-long-at` is followed as a pointer at the next collection. Probe, `eval`: `(define-structure <q> (_n))`, `(define q (new <q> 0))`, `(set (<q>-_n q) 4)`, then 200,000 conses: it printed `raw: 4` and exited with status 139. With 5 instead of 4 it printed `raw: 5` and `survived 5`, exit 0. A tagged integer is odd and is skipped, which is why fields written by `new` are safe.

### 9.4 Unchecked accessors under -O fail silently

With `-O`, accessors skip `%typecheck` (boot.l:358-361; `(optimised)` at eval.c:2682). Probes (3.5):

- `(<pt>-x 5)`, without `-O`: `type check failed for field accessor: expected 18 <pt> got 2 <long>` (`expected 15` in `eval2` and `eval3`). With `-O`, in all three: `()`.
- `(<pt>-x (cons 7 8))` with `-O`: `7`, a field read from a pair.
- `(set (<pt>-x 5) 1)` with `-O`: `()`, nothing reported.
- `(optimised 1)` at run time changes nothing: accessors made after it still check.

### 9.5 `make` takes different syntax in each evaluator, and the wrong one gives an unrelated error

See 3.7. Every boot takes `(make <pt> x: 3 y: 4)`; the association form is gone.

### 9.6 An empty explicit default returns nil silently

See 4.1. `(define-selector speak (x))` then `(speak 3)` printed `()` in all three. A selector with no default errors on the same call (4.5). A caller cannot tell a missing method from one that returns nothing.

### 9.7 define-eval, define-expand and define-encode do nothing outside `eval`

See 6.6. Probe, `eval2` and `eval3`: `(define-structure <pt> (x y))`, `(define p (new <pt> 1 2))`, `(define-eval <pt> (obj) 'EVALUATED)`, then `(eval p)`. Output: `error: cannot eval (15): <pt>` (eval2.c:1574; eval3.c:1583). In `eval`, the same program printed `EVALUATED`. The definition itself raised no error in any evaluator.

### 9.8 A free variable that is undefined is an error at a different time

This is not specific to methods. `eval` encodes every expression before running it, and its encoder resolves each free symbol to its variable then, stopping at one it can't find (eval.c:1170-1172). So any `lambda` naming an undefined variable fails when it is defined. `eval2` and `eval3` look symbols up when they are evaluated (eval2.c:1561-1563; eval3.c:1570-1572).

- `(define f (lambda () zz))`, then `(f)`: in `eval` the `define` fails with `undefined variable: zz`. In `eval2` and `eval3` it succeeds, and `(f)` fails with `eval: undefined variable: zz`.
- `(define-method m <pt> () self.zz)`: in `eval` the error comes at the definition, `undefined variable: self.zz`. In `eval2` and `eval3` the definition succeeds, and calling `m` gives `eval: undefined variable: self.zz`.

### 9.9 The C printer ignores do-print

See 5.1. Error messages and `doprint` do not call the `do-print` selector. Probe: with a `do-print` method for `<pt>` printing `PT!`, the arity error printed `to (<pt>)`. `print` and `println` print `PT!`. Two printers give two answers for one object.

Instances print as a bare type name, with no fields, unless a `do-print` method is defined (5.1; probe `<pt>`).

### 9.10 `set-at` does not store

boot.l:1023-1024. The methods for `<string>` and `<array>` are `(string-at self index)` and `(array-at self index)`. The value argument is ignored. Probe, `(define a (array 2))`, `(set-at a 0 5)`, `(at a 0)`: `()` in all three. The string case: with `s` a copy of `"xy"`, `(set-at s 0 (string-at "q" 0))` left `(string-at s 0)` at `120`, which is `x` and not `q`, in all three.

### 9.11 Accessors are macros

`<pt>-x` is a `Form`, not a function (3.5). A variable can hold it and be called as a macro: `(define acc <pt>-x)` then `(acc p)` printed `1` in all three. What fails is using it as a function value. Probes: `(map <pt>-x (list p))` and `(apply <pt>-x (list p))` both gave `error: cannot apply: Form(Expr.<pt>-x=(*env* self), ())` in `eval`. In `eval2` and `eval3` the message repeats the prefix: `error: error: cannot apply: Form(Expr.<pt>-x=(self), ())`.

### 9.12 Derivatives are recorded and never read

`%structure-derivatives` is written at boot.l:405-407 and boot2.l:423-425, and read nowhere (3.6).

### 9.13 Selectors inherit and multimethods do not

Selectors walk the base chain (4.3). Multimethods match each argument exactly (4.6). Probe: `(comb (new <a>) (new <b>))` gave `error: no method in comb corresponding to: (<a> <b>)` in all three, while `(f (new <c>))` found the method on `<a>` (4.3). Both are defined behaviour, but a reader meeting them together should expect different answers.

### 9.14 Built-in names differ between evaluators

- `long-at`: `eval: undefined variable: long-at` in `eval2` and `eval3`.
- `data`: `eval: undefined variable: data` in `eval2`. It works in `eval` and `eval3`.
- `data-length`: undefined in `eval2`.
- `fixed?`: `eval: undefined variable: fixed?` in `eval2` and `eval3`.

### 9.15 Types and integers cannot be told apart

A type is an integer (3.2). Probe, with `<a>` the first type the script defines: `(define-structure <a> (x))` then `(println "T1 type-of <a>: " (type-of <a>) " value: " <a>)` printed `T1 type-of <a>: 2 value: 18` in `eval` (`value: 15` in `eval2` and `eval3`). A selector given the integer 18 dispatches as `<long>`: `(sz 18)` gave `selector sz has no method for <long>: (18)` in all three. `(inherits-from 18 <a>)` printed `t` in `eval` and `()` in `eval2` and `eval3`, because 18 is `<a>` in `eval` and not in `eval2` and `eval3`.

### 9.16 Redefining a structure name leaves old instances failing

Probe, with `<p>` the first type the script defines: `(define-structure <p> (x))`, `(define old (new <p> 1))`, `(define-structure <p> (x y))`, then `(%typecheck <p> old)`. Output: `type check failed for field accessor: expected 19 <p> got 18 <p>` in `eval`, and `expected 16 <p> got 15 <p>` in `eval2` and `eval3`. The numbers depend on what was defined before. The new `<p>` is a new type number, and old instances keep the old number. The code does not say whether this is intended.

### 9.17 `new` on the undefined type gives a non-nil object

`(new <undefined>)` allocates a block of size 0 with type 0, so it is not nil but has the type of nil. Probe: `(new <undefined>)` printed `UNDEFINED` in all three, which is the name of type 0 in the printer.

### 9.18 Define-class with methods fails under the boot files

See 3.6. `define-class` with a constructor and methods, as in the comments of define-class.l:46-58, works only after `define-class.l` has been loaded. The boot files reject it at expansion time.

### 9.19 A failed world keeps the types defined in it

See 3.10. `define-structure` and `define-class` register a type when they expand, outside any world, so a `try` that fails leaves the type number, its name in `%type-names` and its entry in `%structure-derivatives`. A rejected `define-structure` uses up a number too (3.3). Neither is reported.

### 9.20 Method bodies don't see the scope they are written in

See 3.8. A method's body is evaluated at global scope, so `(let ((secret 'local)) (define-method show <pt> () secret))` gave a method answering `global`. A selector's default given to `define-selector` is a lambda in place, and does see it: `(let ((secret 'local)) (define-selector dflt (o) secret))` then `(dflt 3)` printed `local` in all three.

### 9.21 define-method on a bound name that isn't a selector

See 4.4. `define-method` checks that the name is bound, not that it is a selector, so the error comes from `add-method` and names the value's type: `selector add-method has no method for <subr>: (car <long> <pair> <pair>)`. `define-selector` on the same name gives the clearer `already defined as non-selector` (4.1).

---

## 10. Not covered

- The typed side, beyond `define-struct` and the `<ir-struct-type>` objects in 8.2: how `ir2` lays out and emits structs, and how typed code reads fields.
- The foreign-call path (`ffcall`, `proto_t`).
- The undo log beyond what 3.10 shows of objects: commits, nested worlds and throws (see check/laws/gc-model.law).
- The grammar and `.g` files, which do not use the object system.
