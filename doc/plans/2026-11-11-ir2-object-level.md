# ir2 Object Level Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Typed Maru (maru.k, then ir2) can declare Maru objects and use them as objects: allocate in a type's family,
read and write a field by type and name, take an object's type, and test it. No word offsets appear in the source.

**Architecture:** maru.k gains `define-object` and a few forms. ir2 gains an `oop` type, object struct types, and
four instructions under one base class `<ir-object-insn>`. While types are checked, each instruction builds a
`lowered` tree from existing ir2 instructions in today's layout: eval.l's `<header>` with its type word at -1, and
allocation through `gc_malloc`/`gc_malloc_atomic`. native-gen.k and ir-gen-c.k each get one delegating method per
selector on the base class, so their output doesn't change. A later generator (WasmGC, step 3) handles the
instructions itself and ignores `lowered`.

**Tech Stack:** Maru: maru.k on eval2, ir2.k, native-gen.k (arm64/x86-64), ir-gen-c.k. The checks are check/native.l
and check/check.l.

**Spec:** `/Users/ndn/.claude/plans/i-think-my-oldest-whimsical-scott.md`, Direction step 1. Grounding: objmod
(TR-2006-003-a) §3 and barebloc (M-2007-005-a), both in `~/pkm/raw/vpri`.

## Global Constraints
- Behaviour doesn't change. Every existing check stays green: `native_ir2`, `ir2`, `repl` and the full `make check`
  (run under `caffeinate -i`, one suite at a time).
- The lowered layout is exactly eval.l's. The type id is the word at index -1 of the object (`<header>`'s `type`).
  nil (0) has type `<undefined>`. An odd word has type `<long>`. Objects with pointer fields come from `gc_malloc`,
  atoms from `gc_malloc_atomic`.
- Runtime pieces are written in Maru languages, never in C.
- No `oop-at`, `indir` or casts appear in code that uses the object forms.
- Format code for reading. Don't pack lines (check/lines and the erosion check measure them honestly).
- Work in `.worktrees/ir2-objects` on branch `ir2-objects`. Make a checkpoint commit at each green task.

## Review Focus
1. **A field name the type doesn't have.** `(<pair>-hed x)` has no accessor and fails like any undefined name, but a
   hand-written `(object-slot <pair> hed x)` must fail at compile time with "no such field", naming the type and the
   field. Pinned in Task 1.
2. **Assigning a non-oop value to an oop field, or the reverse.** It must fail with "type mismatch in member
   assignment", as ir-set-member does today. Pinned in Task 1.
3. **An operand with side effects is evaluated once.** `(object-type (next!))` and the address computation in `new`
   must not repeat the call. Lowering binds a temporary. Pinned in Task 3.
4. **`new` for a type declared later in the unit.** Declaration order must not matter, the same as `define-struct`.
   Pinned in Task 2.
5. **Two objects declared with the same type id.** This is an error at declaration, naming both. Pinned in Task 2.

---

### Task 1: The `oop` type, object types, and field access

**Files:**
- Modify: `ir2.k`: add `<ir-oop-type>` near `<ir-pointer-type>` (ir2.k:70), `<ir-object-type>` near
  `<ir-struct-type>` (ir2.k:98), and the base `<ir-object-insn>` with `<ir-object-slot>` and `<ir-set-object-slot>`
  near `<ir-member>` (ir2.k:495).
- Modify: `maru.k`: `oop` in the type map (maru.k:17 block); `define-object` near `define-struct` (maru.k:287); form
  compilers `object-slot` and `set-object-slot` in `maru-compile-form-map` (maru.k:179).
- Modify: `native-gen.k`: delegating methods on `<ir-object-insn>` for `native-allocate`, `native-lower` and
  `native-address`.
- Modify: `ir-gen-c.k`: a delegating method on `<ir-object-insn>` for `ir-gen-c`. `<ir-oop-type>` prints as `void *`.
- Create: `check/native/objects.k`
- Modify: `check/native.l`: a new block for objects.k.

**Interfaces:**
- Produces:
  - Source form `(define-object <name> id ((field type) ...))`, plus `atom` as an optional fourth element. `id` is
    evaluated in the host when the form is expanded, so constants such as osdefs values work. The form defines the
    accessor forms `(<name>-field x)` → `(object-slot <name> field x)` and `(set-<name>-field x v)` →
    `(set-object-slot <name> field x v)`, so `(set (<name>-field x) v)` works through Maru's `set`.
  - The ir2 type `oop`, an `<ir-oop-type>` (a subclass of `<ir-pointer-type>` whose referent is void).
  - `(ir-declare-object-type ir name id members atom?)` returns an `<ir-object-type>`. That class is a subclass of
    `<ir-struct-type>` with the extra fields `id` and `atom`, so `ir-finalise-structs` lays it out unchanged.
  - The instruction constructors `(ir-object-slot type-name field value)` and
    `(ir-set-object-slot type-name field value init)`. Every `<ir-object-insn>` has the field `lowered`, set by its
    `ir-check-type`.
  - `*maru-objects*`, an array of `(name id atom? . members)` that `compile-namespace` declares before any binding.

- [ ] **Step 1: Write the failing check.** `check/native/objects.k`: declare `(define-object <pair> 19 ((head oop) (tail oop)))` and
  `(define-object <long> 3 ((bits long)) atom)`. Functions taking a raw buffer as `oop`:
  - `(define-function pair-swap void ((p oop)) ...)` swaps head and tail through the accessors;
  - `(define-function long-bits long ((n oop)) (return (<long>-bits n)))`.
  In check/native.l, add the block: calloc 4 words; write 11 and 22 at byte offsets 0 and 8; call `pair-swap`; then
  `(expect "pair fields swap" (list (byte-at buffer 0) (byte-at buffer 8)) '(22 11))` and
  `(expect "long bits" ((fn image 'long-bits "p>l") buffer) 22)`.
- [ ] **Step 2: Run it and see it fail.** Run `./eval2 check/native.l 2>&1 | tail -3`. Expected: an error naming `define-object`
  (undefined).
- [ ] **Step 3: Implement.**
  - ir2.k: the classes above.
  - `ir-check-type` for `<ir-object-slot>` builds
    `lowered = (ir-member field (ir-cast (ir-pointer-to (ir-object type-name)) value))` and checks it.
    `self.type` is the member's type.
  - The set form likewise uses `ir-set-member`.
  - A missing type gives `(error "no such object type: " name)`. A missing field gives the "no such field" error that
    ir-member already raises.
  - maru.k: `define-object` appends to `*maru-objects*` and returns the accessor `define-form`s. `compile-namespace`
    declares the objects next to `*maru-structs*`.
  - Generators: each delegating method is `(selector self.lowered gen ...)`. If the check names some other selector
    that is missing, add the same one-line delegation for it.
- [ ] **Step 4: Run it and see it pass.** Run `./eval2 check/native.l 2>&1 | tail -1`. Expected: `native ok`.
- [ ] **Step 5: Pin Review Focus 1 and 2.** Add `check/native/objects-bad-field.k`, which uses `(object-slot <pair> hed p)`, and
  `objects-bad-assign.k`, which does `(set (<long>-bits n) n)` with an `oop` n. In check/native.l, expect
  `native-compile-file` to signal errors containing "no such field" and "type mismatch". Wrap the call with `catch`,
  as check/catch.l shows. Run it. Expected: `native ok`.
- [ ] **Step 6: Commit.** `git add ir2.k maru.k native-gen.k ir-gen-c.k check/native/objects*.k check/native.l` with the
  message "ir2 objects: the oop type, object types, fields by type and name".

### Task 2: `new`, an object in its type's family

**Files:**
- Modify: `ir2.k`: `<ir-object-new>`.
- Modify: `maru.k`: the form compiler `new` (only for a name declared by `define-object`; otherwise it is an ordinary
  call).
- Modify: `check/native/objects.k` and `check/native.l`.

**Interfaces:**
- Consumes: `<ir-object-type>` and its `id`/`atom` (Task 1); `gc_malloc` and `gc_malloc_atomic`, resolved by name in
  the unit, as maru-gc.k defines them (maru-gc.k:141 and 184).
- Produces: `(ir-object-new type-name)` of type `oop`. Its `lowered` binds a temporary `o` to
  `(gc_malloc (sizeof struct T))` (`gc_malloc_atomic` when `atom`), does `(set-indir (cast o long *) -1 id)`, and
  yields `o`. Build the `ir-let` the way `maru-compile-let` does.

- [ ] **Step 1: Write the failing check.**
  - In objects.k, add `(define-function make-pair oop ((h oop) (t oop)) ...)` using `new` and the setters, and
    `(define-function box long ((n long)) ...)`, which makes a `<long>`, sets `bits` and returns `(<long>-bits b)`.
  - Declare `(define-object <late> 20 ((x long)))` *after* a function that does `(new <late>)` (Review Focus 4).
  - In check/native.l, splice maru-gc.k without its main in front of objects.k, as the gc.k block does
    (check/native.l, end). Call `gc_initialise`, then `make-pair` with 5 and 7. Expect that the word before the
    result is 19, read as `(byte-at (- p 8) 0)`; that the head and tail are 5 and 7; and that `(box 42)` is 42.
  - A second unit declares two objects with id 19 and expects an error containing "duplicate object type id"
    (Review Focus 5).
- [ ] **Step 2: Run it and see it fail.** Run `./eval2 check/native.l 2>&1 | tail -3`. Expected: an error naming `gc_malloc` as
  called with an object type, or `new` as undefined.
- [ ] **Step 3: Implement `<ir-object-new>`** as in Interfaces. Check for a duplicate id in `ir-declare-object-type`.
- [ ] **Step 4: Run it and see it pass.** Run `./eval2 check/native.l 2>&1 | tail -1`. Expected: `native ok`.
- [ ] **Step 5: Commit** with the message "ir2 objects: new, in the type's family, in eval.l's layout".

### Task 3: `object-type` and `object-is`

**Files:**
- Modify: `ir2.k`: `<ir-object-type-of>`.
- Modify: `maru.k`: the forms `object-type` and `(object-is <name> x)` → `(= (object-type x) id)`.
- Modify: `check/native/objects.k` and `check/native.l`.

**Interfaces:**
- Consumes: `<ir-object-type>` ids. `<undefined>` and `<long>` must be declared in the unit. If either is missing,
  report `(error "object-type needs <undefined> and <long> declared")`.
- Produces: `(ir-object-type-of value)` of type `long`. Its `lowered` binds a temporary `x`, then gives
  `(if (= x 0) undefined-id (if (& x 1) long-id (indir (cast x long *) -1)))` as one value-producing `ir-if`.

- [ ] **Step 1: Write the failing check.**
  - objects.k: declare `(define-object <undefined> 0 ())`. Add `(define-function type-of-arg long ((x oop)) (return (object-type x)))`
    and `(define-function is-pair long ((x oop)) (return (object-is <pair> x)))`.
  - Add a counter `calls` and `(define-function next oop () (set calls (+ calls 1)) (return (make-pair 0 0)))`, with
    `(define-function once long () (let (((t long) (object-type (next)))) (return (+ calls (* 0 t)))))` (Review Focus 3).
  - check/native.l: expect `type-of-arg` of 0, 7 (odd) and a fresh pair to be `'(0 3 19)`; `is-pair` of a pair and of 0
    to be `'(1 0)`; and `once` to be 1.
- [ ] **Step 2: Run it and see it fail.** Run `./eval2 check/native.l 2>&1 | tail -3`. Expected: `object-type` undefined.
- [ ] **Step 3: Implement** as in Interfaces.
- [ ] **Step 4: Run it and see it pass.** Run `./eval2 check/native.l 2>&1 | tail -1`. Expected: `native ok`.
- [ ] **Step 5: Commit** with the message "ir2 objects: object-type and object-is, nil and tagged words as eval.l has them".

### Task 4: The same unit through C, the doc, and the suite

**Files:**
- Create: `check/objects.k`, a C-run program (as check/ir2.k is). It holds maru-gc.k's functions (spliced by
  check.l, like the native block) and objects.k's functions, and a `main` that runs every Task 1–3 assertion,
  printing `objects ok` or `FAIL <what>`.
- Modify: `check/check.l`: `(check "ir2_objects" ...)` next to `"ir2"` (check.l:745), building with `ir2-build`.
- Create: `doc/ir2-objects.md`, the unit doc (per doc/ convention). Cover the forms, the lowering, why there is no
  -1 word in source (objmod's "behaviour, not structure"; barebloc's object format with no -1 word), and what a
  generator must do to handle the instructions itself.
- Modify: `AGENTS.md` to index the doc.

- [ ] **Step 1: Write `check/objects.k` and the check.l entry.** Run `./eval check/check.l ir2_objects`. Expected: `PASS`.
  If it fails, that is an ir-gen-c delegation gap: add it and rerun.
- [ ] **Step 2: Write the doc and its AGENTS.md line.**
- [ ] **Step 3: Run the full suite.** Run `caffeinate -i make check 2>&1 | tail -20`. Expected: every check passes, including
  `native_ir2`, `native_ir2_x64` (or its SKIP line), `ir2`, `ir2_objects` and `repl`.
- [ ] **Step 4: Commit** with the message "ir2 objects: through C, documented". Then merge per the branch workflow:
  rebase, fresh review, full suite, fast-forward, push, remove the worktree.
