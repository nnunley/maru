# The grounded kernel

Maru's evaluator written in typed Maru through ir2, on the object level (doc/ir2-objects.md), aligned on eval3.c
(Piumarta, 2013). It runs natively and through C. The plan is doc/plans/2026-11-12-kernel-on-eval3.md. Its grounding is
oecm (TR-2011-002) §5.1, which keeps the grounded part minimal (dispatch from type to meaning, and the `<subr>` call),
and colaswp (RN-2006-001-a) §6.1, which reimplements the static layer one level up. eval, eval2 and eval3 stay as
the oracles.

`kernel.k` loads the sections in eval3's order, after maru-gc.k less its main. Only the objects are written so far.

## Objects (`kernel-objects.k`)

- **Types.** eval3's 13 built-in types (eval3.c:87) carry boot2.l's fields (boot2.l:425–437). The ids, 0 … 12, are
  the kernel's own. They are not read from the host running maru.k: the contract is with the boot file the kernel
  loads, which declares its built-in types in the same order.
- **Atoms** (no field the collector traces) are `<data>`, `<long>`, `<double>`, `<symbol>` and `<subr>`.
- **Characters.** A string's and a symbol's characters are `wchar_t` (four bytes here), as eval3 keeps them.
  - A string's live in managed memory: `gc_malloc_atomic`, kept alive through the string's `bits` field.
  - A symbol's are malloc'd and never freed, as eval3's `wcsdup` leaves them.
- **Constructors**: `k_newData`, `k_newLong`/`k_getLong`, `k_newDouble`/`k_getDouble`, `k__newString`,
  `k_newStringC`, `k_newSymbolC`, `k_cons`, `k_newArray`, `k_newExpr`, `k_newForm`, `k_newFixed` and `k_newSubrC`.
  Each is eval3's, `k_`-prefixed; `C` marks one that takes a C string, widened as eval3's `mbs2wcs` widens it.
- **Integers are boxed or tagged**, chosen when the kernel is compiled, as eval3's `TAG_INT` chooses (Piumarta made it
  a switch in 306ffb0, 2011: on in eval.c, off in eval2.c and eval3.c). `kernel-tag-int` is 0, boxed as eval3 is
  built, unless the build defines it 1 before `kernel.k`. `(if-tag-int TAGGED BOXED)` picks a branch at compile time,
  and only that branch is compiled.
  - Tagged, `k_newLong` makes a value whose top two bits agree an odd word, `(x << 1) | 1`, and boxes any other
    (eval3.c:207–214).
  - `k_getLong` reads either through the object level, which untags an odd word itself (doc/ir2-objects.md).
  - `k_isLong` is `object-is <long>`, which an odd word is in either mode.
- **A `<subr>`'s `imp`** is a function pointer of `(arguments env)`, called through the field.

## Lists, arrays and the printer (`kernel-lists.k`)

- **Lists**: `k_car`, `k_cdr` (nil for a non-pair) and their compositions, as eval3.c:165.
- **Arrays**: `k_arrayLength`, `k_arrayAt` (nil past the end), `k_arrayAtPut`, `k_arrayAppend` and `k_arrayInsert`.
  Written past its end, an array's capacity doubles until the index fits, as eval3.c:297.
- **The printer**: `k_doprint` with `k_print`, `k_dump` and `k_dumpln`, eval3's text for its 13 types. `dump` writes
  strings as the reader reads them back, and a binding whose tail is its own list prints as `<name>`.
- **Pointer steps are in bytes**, as ir2's arithmetic is (ir2.k:872), so a step over a character or an element is
  written with `sizeof`.

## Departures from eval3

- **The collector is maru-gc.k**, not gc.c, until the plan's step 2a ports gc.c's design as `kernel-gc.k` (per-object
  length, ephemerons, heap limits).
- **Every constructor writes every field.** eval3 leaves a pair's `source` and an expr's `name` to its zeroed memory;
  the kernel writes nil there. So nothing it reads was left as allocated, which `law_objects` holds it to, and a
  WasmGC struct, made with all its fields, needs.
- **`k_cons`, `k_newForm` and `k_newFixed` root their arguments** while they allocate. eval3 leaves that to its
  callers.
- **New array capacity is filled with nil**, where eval3 has it from zeroed memory (the poisoning collector would
  leave the sentinel).
- **The printer writes to stdout only**, with `printf`, and doesn't flush: eval3 flushes stdout after each print, but
  the kernel can't name stdout yet, and `fflush(NULL)` would also move a stream another process shares (eval2's own
  reading of a check, which a native check's child inherits). Flushing comes with the kernel's main (Task 6). eval3's `fprint` to another stream, its globals' special
  cases (`<the global environment>`) and `%type-names` for a boot-declared type come with the globals (Task 4); until
  then such a type prints `<type=N>`. `<data[N]>` prints the collector's size (a whole number of words) until
  kernel-gc.k keeps the length asked for.
- **A failed type check is fatal**, as eval3's is, until the REPL's error handling comes (Task 6). Each failure is
  counted and its ids kept (`type_check_failures`, `type_check_expected`, `type_check_actual`). A driver that clears
  `type_check_fatal` has `get` answer 0 and `put` write nothing instead.

## Checks

- `kernel_native` (`check/kernel.l`, on eval2): each unit in `check/kernel/` is compiled natively after maru-gc.k
  and kernel.k, and its main runs in a child, once with integers boxed and once tagged.
- `kernel_c` (`check/check.l`): the same units through ir-gen-c.k and the C compiler, in both modes.
- `check/kernel/longs.k` asserts round trips through `k_newLong` and `k_getLong` at 0, ±1, ±42, 2^62 − 1, 2^62,
  −2^62, −2^62 − 1, INT64_MAX and INT64_MIN. Each is a `<long>` and an `isLong`, and it is an odd word just when the
  kernel is tagged and the value fits. A symbol isn't an `isLong`. Through the object level, `get` of an odd word
  answers its value and `put` to one fails its type check.
- `check/kernel/objects.k` asserts:
  - each type's id;
  - a pair's string head (its characters and size) and long tail;
  - a double, a symbol's characters, an array of 100, and an expr's three fields;
  - a subr called through its `imp`, natively too;
  - a list of 2,000 rooted pairs summing correctly with a collection on every allocation (`gc_frequency` 1).
- `check/kernel/lists.k` prints four structures with `k_print` and `k_dumpln`: a list of a string with `"` and `\`,
  a symbol, a negative long, a double, nil, an array with a hole, a dotted pair and an empty array; a string with a
  tab; a binding. The drivers compare them with what `./eval3 -b boot2.l` prints for the same structures, byte for
  byte, on the poisoning collector, with a collection on every allocation. It also asserts an array grown to 100
  with nil between, an insert, an append, `car`/`cdr` of a non-pair, `cadr` and `caddr`.
- `law_objects`, in both modes (`check/laws/objects.law`, its programs in `objects-programs.law`, its model in `objects-model.l`):
  generated programs over the kernel's 13 types and two of the driver's own (`<knot>`, and `<pixel>`, an atom).
  - **Tagged**, a long a constructor makes is an immediate: the model holds it as a Maru integer, equal to another by
    value, with no field to `look` at or `set` (the driver skips the unchecked accessors on an odd word), `get` of
    its `bits` answering its value, and `put` refused.
  - **The programs** fill four slots raw (`new`) or by a kernel constructor, write fields through the unchecked
    accessors (`set`) or `put`, and read them through the accessors (`look`) or `get`. `get` and `put` name a type of
    their own, so most mismatch, nil included. Programs also ask `object-type` and collect.
  - **The driver**, `check/objects-run.k`, is compiled after maru-gc.k and kernel.k through C under ASan. It runs on
    the poisoning collector: `gc_poison` 0xa5 fills new memory, so a field nothing wrote reads S. A write is made
    distinct by its line, so a write to the wrong field shows.
  - **`agree`**: the driver prints what the model says, line for line, at three collection paces (every allocation,
    every 7th, every 32,768th). That covers raw fields reading S, a checked access's mismatch (it prints
    `F expected actual`, answers 0, writes nothing, and calls `type_check_fail` once with those ids), and objects
    reached only through fields surviving collection. Its classes show the operation mix, and at least 15% of
    programs read an object a constructor made.
  - **`initialised`**: no field of anything a kernel constructor makes reads S, for every constructor and pace.
  - **The bite** (`fixtures/objects-unwritten.law`): over the same programs, "nothing reads S" is refuted, so the
    sentinel does show where a program reads what nothing wrote.
  - **Limits.** ASan sees nil and wild accesses and overruns past a heap block. It can't see an overrun inside the
    collector's own blocks; there the model's distinct values are what catch a wrong field. The law runs through C
    only: the native back end shares `ir-object-lower` with it, and Task 6 runs the REPL natively on the poisoning
    collector.
