# Maru objects in typed Maru (ir2's object level)

Typed Maru (`maru.k` over ir2) can declare Maru's own objects and use them *as objects*. A unit allocates an object
in its type's family, reads and writes a field by type and name, takes an object's type, and tests it. No word offset
appears in the source. This is step 1 of the plan to rewrite the evaluator's grounded kernel in Maru through ir2
(`doc/plans/2026-11-11-ir2-object-level.md`). Its purpose is to let a back end choose another layout: WasmGC structs
have no word before the object.

## The forms

| Form | Meaning |
|------|---------|
| `(define-object <pair> 19 ((head oop) (tail oop)))` | An object type: its id (evaluated when the form is read) and its fields. Add `atom` last when the collector traces none of them. |
| `oop` | The type of a reference to a Maru object. |
| `(new <pair>)` | A new `<pair>`: its id in the word before it, from the unit's `gc_malloc` (`gc_malloc_atomic` for an atom). |
| `(<pair>-head x)`, `(set (<pair>-head x) v)` | A field, unchecked at run time, as eval.l's raw accessors. `x` must still be an object statically (an `oop`, a `void *` or 0), or it is refused. |
| `(get <pair> head x)`, `(put <pair> head x v)` | A field, once `x`'s type is checked, as eval.l's `get` and `put` check it. On a mismatch they call the unit's `type_check_fail` with the expected and the actual id. The access runs only when the type is right. On a mismatch, should `type_check_fail` return (a handler that recovers, where eval.l's `fatal2` exits), `get` answers 0 of the field's type and `put` writes nothing, so neither touches the wrong object or follows nil. A struct-valued field is refused by both. Like `object-type`, they need `<undefined>` and `<long>` declared. |
| `(object-type x)` | `<undefined>`'s id for nil, `<long>`'s for an odd word, otherwise the id in the word before the object. The unit must declare `<undefined>` and `<long>`. |
| `(object-is <pair> x)` | Whether `x`'s type is `<pair>`, as ir2's boolean. |

## How it is generated

Each form is an ir2 instruction under `<ir-object-insn>` (ir2.k). When its type is checked, it builds `lowered`: the
same meaning in ordinary ir2 instructions, in eval.l's layout. That layout is `<header>`'s type word at index -1,
member access through a cast to the object's struct, and a temporary (`%new`, `%type-of`, `%checked`) so an operand
is evaluated once. `native-gen.k` and `ir-gen-c.k` each have one delegating method per selector on the base class,
so they generate `lowered` and their output is what hand-written word code would give.

A generator that knows objects itself handles the instructions directly and ignores `lowered`. The planned WasmGC
back end is the case in mind.

## Grounding

- objmod (Piumarta and Warth, TR-2006-003-a): an object's behaviour is modelled, and its state is reached through it.
  Units name fields, not offsets.
- barebloc (Kaehler, M-2007-005-a): an object format with no word before the object, the vtable held elsewhere. That
  is the layout a managed back end needs, and this level makes it a back end's choice.
- eval.l: `get`/`put`, `get-type`, `new-oops`/`new-bits`, and nil and tagged integers in `get-type`, all replicated.

## Departures and limits

- **`new`, `get` and `put` are rebound in a unit.** boot's `new` and parser.l's `get`/`put` are forms that would
  expand first. `compile-begin` binds the unit's versions in the unit's own namespace, ahead of its parent's bindings
  (`maru-unit-forms`), and leaves the global ones alone. A unit's `new`, `get` or `put` whose first argument isn't a
  declared object type is compiled as an ordinary call (the unit's own `get`, say). maru.k's `extern` now calls `maru-extern` instead of expanding
  to boot's `new`.
- **Declaration order.** `define-object` generates accessor forms, which shadow boot's accessors for a type of the
  same name (boot has `<pair>-head`). A function written before the declaration still reaches the field by name when
  compiled, except where boot has an accessor of that name. Declare objects first.
- **No `safe` switch.** eval.l can compile its checks away with `safe`. Here the choice is per use: `get` checks,
  `<pair>-head` doesn't.
- **`oop` is a pointer type** (`<ir-oop-type>` under `<ir-pointer-type>`), so pointer operations (`indir`,
  arithmetic, casts) are legal on one. Refusing them is the WasmGC step's job.
- **ir-gen-x86.k has no object methods.** Only native-gen.k and ir-gen-c.k generate the object instructions.
- **The type word is `long`**, the pointer-sized word. ir2 has no explicit pointer-sized integer yet.
- **`subr` gained `>v`** for calling a void function (doc/evaluators.md). The native check calls `pair-swap` with it.

## Checks

- `native_ir2` (`check/native.l`, block "Maru objects"): check/native/objects.k is compiled natively after maru-gc.k
  (less its main) and called by address. It asserts:
  - field swaps and an atom's field on a raw buffer;
  - a new pair's id in the word before it, and its fields;
  - a boxed long;
  - a type declared after its use;
  - `object-type` of nil, an odd word and a pair;
  - `object-is`;
  - `object-type`'s operand evaluated once;
  - `get` and `put` on a pair, `get` of a `<late>` calling `type_check_fail` with 19 and 20, and `get` and `put` on nil with a handler that returns: 0, with nothing read or written.

  It also asserts refusals with their messages: a field the type doesn't have (`objects-bad-field.k`), an `oop`
  written to a `long` field (`objects-bad-assign.k`), `object-type` with no `<undefined>` (`objects-no-undefined.k`),
  two types with one id (`objects-duplicate-id.k`), two with one name (`objects-duplicate-name.k`), and an unchecked
  accessor of a `long` (`objects-bad-operand.k`). A unit's own `get`, called before its definition, is an ordinary call
  (`objects-get-function.k`). The unit spliced after maru-gc.k starts with a form, so a splice cut inside a comment
  would lose it.
- `ir2_objects` (`check/objects.k`): the same unit through `ir-gen-c.k` and the C compiler, its main asserting the
  same values. It prints `objects ok`.
