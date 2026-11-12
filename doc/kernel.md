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
  a switch in 306ffb0, 2011: on in eval.c, off in eval2.c and eval3.c). `kernel-tagged-int` is 0, boxed as eval3 is
  built, unless the build defines it 1 before `kernel.k`. `(if-tagged-int TAGGED BOXED)` picks a branch at compile time,
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

## The reader (`kernel-reader.k`)

- **`k_readExpr`** is eval3's `readExpr` (eval3.c:694). It reads integers (decimal, negative, `0x` hexadecimal),
  doubles (a `.` or an `e` after the digits), strings with every escape (`k_readChar`: named, `\u` and four hex digits,
  `\x` and up to two, up to three octal), characters (`?c`), symbols, lists with a dot, `'`, `` ` ``, `,` and `,@`,
  `[ ]` and `{ }` as `(bracket …)` and `(brace …)`, and comments. It answers `k_done` at the end of the input or before
  a closing delimiter, as eval3 answers `DONE`.
- **Character classes** are chartab.h's flags, kept as one string of '0' + the flags for each of 0 … 127.
- **Symbols** are interned as eval3 interns them: by binary search in a sorted array (`k_intern`, eval3.c:533).
- **Source positions**: `k_beginSource`, `k_advanceSource` (each line) and `k_endSource` keep the current
  `(path . line)`, and every pair the reader makes takes it (`k_newPairFrom`).
- `k_initReader` makes the symbol table and the symbols the reader reads specially, and roots them.

## Environments, expand, encode, eval and apply (`kernel-eval.k`)

- **Environments are alists**, as eval3's (eval3.c:440-520). A namespace's head is a binding whose tail is the
  namespace itself (`k_findEnvironment`). `k_findVariable` finds a name's binding, the global namespace's through
  eval3's cache of 2003 slots by the name's address. `k_findNamespaceVariable` looks only in env's own namespace,
  `k_lookup` answers the value, and `k_define` puts a new binding `(name . value)` at the front of the namespace, after
  its head, and answers it.
- **`k_expand`** (eval3.c:1150) applies a `<form>`'s function to the unevaluated arguments, and a symbol's form to
  the symbol, then expands the result again, giving it the source of what it replaced. `(set (NAME args…) value)`
  becomes `(set-NAME args… value)`. `quote`'s argument isn't expanded.
- **`k_encode`** (eval3.c:1212) warns once about each name bound nowhere, and about a call whose arguments don't
  match its global `<expr>`'s formals. eval3 runs it only with `-g`.
- **`k_eval`** (eval3.c:1545): undefined, long, double, string, form, subr and fixed are themselves; a symbol is its
  binding's value, or a fatal "undefined variable"; a pair applies its head, a `<fixed>`'s function to the arguments
  unevaluated, anything else to the arguments evaluated (`k_evlist`). Each pair is pushed on the trace stack that a
  fatal error prints. Any other type is a fatal "cannot eval", as in eval3, whose `*evaluators*` hook is commented out.
- **`k_apply`** (eval3.c:1611): an `<expr>` binds its formals (a rest formal takes the remaining arguments) onto the
  environment it closed over and evaluates its body; a `<fixed>` applies its function; a `<subr>` is called through
  its `imp` with `(arguments env)`; any other type through its `*applicators*` entry, with itself first, or is a fatal
  "cannot apply".
- **`k_initEval`** makes the global namespace and binds `*globals*`, `*expanders*`, `*encoders*`, `*evaluators*`,
  `*applicators*`, `*backtrace*`, `*input*` and `*output*` in it, as eval3's main does, and roots them.
- **Fatal errors** print the message and its objects, then `*backtrace*`'s answer if it is bound, or else the trace
  stack with each expression's source, and exit.

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
- **An empty `[]` or `{}` reads as `(bracket)` or `(brace)`.** eval3 crashes on them: `newPairFrom` reads the source
  of nil. The kernel's source of nil is nil, the Null Object choice.
- **The reader's errors print to stdout** and exit, as its fatal errors will until the REPL's error handling (Task 6).
- **eval's fatal errors and encode's warnings print to stdout**, until the printer has a stream (Task 6); eval3
  writes them to stderr.
- **A foreign `<subr>`** (one with a `sig`, made by eval3's `subr` through libffi) is a fatal error in `k_apply` until
  Task 5 decides the FFI.
- **The undo log isn't there yet.** eval3's `define` and `set` note what they change in it; Task 5 decides it with
  the primitives.
- **A failed type check is fatal**, as eval3's is, until the REPL's error handling comes (Task 6). Each failure is
  counted and its ids kept (`type_check_failures`, `type_check_expected`, `type_check_actual`). A driver that clears
  `type_check_fatal` has `get` answer 0 and `put` write nothing instead.

## Checks

- `kernel_native` (`check/kernel.l`, on eval2): each unit in `check/kernel/` is compiled natively after maru-gc.k
  and kernel.k, and its main runs in a child, once with integers boxed and once tagged.
- `kernel_c` (`check/check.l`): the same units through ir-gen-c.k and the C compiler, in both modes.
- `check/kernel/longs.k` asserts round trips through `k_newLong` and `k_getLong` at 0, ±1, ±42, 2^62 − 1, 2^62,
  −2^62, −2^62 − 1, INT64_MAX and INT64_MIN. Each is a `<long>` and an `isLong`, and it is an odd word just when the
  kernel is tagged and the value fits. A symbol isn't an `isLong`. `boxed?` is false for nil and an odd word, true for
  a pair, a symbol and a boxed long. Through the object level, `get` of an odd word
  answers its value and `put` to one fails its type check.
- `check/kernel/objects.k` asserts:
  - each type's id;
  - a pair's string head (its characters and size) and long tail;
  - a double, a symbol's characters, an array of 100, and an expr's three fields;
  - a subr called through its `imp`, natively too;
  - a list of 2,000 rooted pairs summing correctly with a collection on every allocation (`gc_frequency` 1).
- `check/kernel/eval.k` reads `check/kernel/eval.txt`, expands and evaluates each expression in the global namespace
  and dumps its value, on the poisoning collector with a collection on every allocation. The drivers compare the
  lines with `check/kernel/eval.expected`, what `./eval3 -b boot2.l` prints for the same expressions: a closure kept
  past its caller, recursion 1,000 deep, a `<form>` expanding both ways, `let` and `set`, an `*applicators*` entry
  applying a `<long>`, and `quote`. Its subrs and fsubrs (`+`, `-`, `<`, `cons`, `car`, `form`, `set-array-at`,
  `quote`, `lambda`, `if`, `set`, `let`, `define`) are minimal stand-ins for Task 5's, each called through its `imp`,
  natively too. maru-gc.k's "N collections" progress lines are left out of the comparison until kernel-gc.k replaces
  it.
- `check/kernel/lists.k` prints four structures with `k_print` and `k_dumpln`: a list of a string with `"` and `\`,
  a symbol, a negative long, a double, nil, an array with a hole, a dotted pair and an empty array; a string with a
  tab; a binding. The drivers compare them with what `./eval3 -b boot2.l` prints for the same structures, byte for
  byte, on the poisoning collector, with a collection on every allocation. It also asserts an array grown to 100
  with nil between, an insert, an append, `car`/`cdr` of a non-pair, `cadr` and `caddr`.
- `check/kernel/reader.k` reads `check/kernel/read.txt` and dumps each datum, on the poisoning collector with a
  collection on every allocation. The drivers compare the lines with `check/kernel/read.expected`, what
  `./eval3 -b boot2.l` prints for the same file (its last line, `[] {}`, aside: eval3 crashes on it). The fixture has
  each literal kind, INT64_MAX, INT64_MIN and 2^62, doubles from `-2.5e-3` to `4.0e18`, every string escape,
  characters, symbols, dotted, quoted and bracketed lists, comments, and a list nested 200 deep.
- `law_objects`, in both modes (`check/laws/objects.law`, its programs in `objects-programs.law`, its model in `objects-model.l`):
  generated programs over the kernel's 13 types and two of the driver's own (`<knot>`, and `<pixel>`, an atom).
  - **Tagged**, a long a constructor makes is an immediate: the model holds it as a Maru integer, equal to another by
    value, with no field to `look` at or `set` (the driver skips the unchecked accessors on a word not `boxed?`), `get` of
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
    collector's own blocks; there the model's distinct values are what catch a wrong field.
- `law_objects_native`: the same law in both modes natively. law.l runs on eval2, `check/laws/objects-native.l`
  compiles the driver once with native.l, and each program runs in a forked child with the program on its stdin
  (`native-run-main-status`, check/native-run.l). Making it found a bare `(return)` in the driver that only C
  accepted. It is slow: the driver's generated dispatch takes about 60 s to compile natively, beyond the kernel's 30,
  as native compile time grows faster than a function's size. So check-quick leaves it out.
