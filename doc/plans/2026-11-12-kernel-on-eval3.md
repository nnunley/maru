# The Grounded Kernel Boots boot2.l, Aligned on eval3: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Maru's evaluator kernel, written in typed Maru through ir2 on the object level (doc/ir2-objects.md),
runs natively and through C. It loads `boot2.l` and runs `repl.l test-repl.l` with output identical to
`./eval3 -b boot2.l repl.l test-repl.l`'s.

**Architecture:**
- **The reference is eval3.c**, Piumarta's last iteration (2013): its 13 built-in types, environments as alists
  (boot2.l's namespaces), `expand`/`encode`/`eval`/`apply`, `*applicators*` by type, and its 71 primitives, cut to
  what boot2.l and repl.l use.
- **eval.l** (2010) is precedent only, for how an evaluator is written in Maru: its collector (as maru-gc.k), its
  reader and its root discipline.
- **The kernel owns its type numbering**: eval3's enum, 0 … 12. After loading boot2.l it checks that boot's
  `<undefined>` … `<subr>` equal its own ids.
- **Each section ends with a typed check unit**, run natively in-process (as `native-run-main` does) and through C.
- **The oracle is `./eval3`**, which stays unchanged, as eval and eval2 do (see the spec's Decision).

**Tech Stack:** maru.k on eval2, ir2.k, native-gen.k (arm64), ir-gen-c.k, maru-gc.k, check/native-child.l.

**Spec:** `/Users/ndn/.claude/plans/i-think-my-oldest-whimsical-scott.md`, Direction step 2 (the user, 2026-11-12:
align on eval3.c). Grounding: oecm §5.1 (the grounded part is minimal: dispatch from type to meaning, and the
`<subr>` call), colaswp §6.1 (Pepsi.coke). Step 1: doc/plans/2026-11-11-ir2-object-level.md.

## Global Constraints
- **eval, eval2 and eval3 are not modified or retired.** They are the oracles. The kernel is new files only.
- **eval3.c is the meaning.** Replicate its mechanisms, including alist environments, `fixed`,
  `form`, `*applicators*`, the backtrace stack and the `-b` boot option.
  - **Departures** are stated in doc/kernel.md, each with its reason.
  - eval3's `*evaluators*`, `*expanders*` and `*encoders*` hooks are commented out; the kernel keeps them commented
    out (fatal "cannot eval" for an unknown type). Restoring them as oecm Fig 3 describes is a decision for the user,
    noted in the doc, not taken here.
- **The type contract is with boot2.l, not with the compile host.** Ids are the kernel's own constants, 0 … 12 in
  eval3.c:87's order, never read from eval2. The kernel's own check after boot asserts boot's type variables equal them.
- **nil is the zero word, with behaviour by type** (the user, 2026-11-12, option A of the Null Object pattern;
  colaswp §4.2's `vtblnil`). `<undefined>` has its applicator and dispatch entries like any type. Checked `get`/`put` on
  nil answer nil (0 of the field's type) and touch nothing. Raw `<T>-field` accessors on nil are not safe natively
  (page zero is unmapped); a singleton Null Object for nil is the WasmGC back end's lowering (step 3), and native's
  later if raw access on nil must be safe.
- **Word size from `sizeof`**; eval3 uses `int64_t long_t` (eval3.c:92), which the kernel matches.
- **Objects only through the object level**: `new`, `get`/`put` or `<T>-field`, `object-type`, `object-is`. Every
  `define-object` goes at the top of its file, before any use (doc/ir2-objects.md, "Declaration order").
  `oop-at` appears only inside primitives that are word access by definition.
- **The type names are today's (`long`, `int`, `char`).** Explicit widths are iterated within this loop (laneq #120).
- **Kernel files** are flat: `kernel.k` loads `kernel-objects.k`, `kernel-lists.k`, `kernel-reader.k`,
  `kernel-eval.k`, `kernel-primitives.k` and `kernel-main.k`, after maru-gc.k less its main. Function names follow
  eval3.c's (`eval`, `apply`, `expand`, `encode`, `findVariable`, `define` …) with a `k_` prefix, so each maps back to
  its original.
- New runtime code is Maru languages only. Checks match values in Maru. `make check` stays green, under
  `caffeinate -i`, one suite at a time. Ledger entries go in `check/lines` and `check/erosion`. Each task ends in a
  checkpoint commit.
- Work in `.worktrees/kernel` on branch `kernel`, stacked on `ir2-objects`. Rebase onto main once step 1 merges.

## Review Focus
1. **A garbage collection in the middle of building an object.** Every local holding an object across an allocation
   is rooted (`gc-protect`, as eval3's `GC_PROTECT`). The constructor and reader checks run with `gc_frequency` at 1
   and assert the structures read back intact. Pinned in Tasks 1 and 3.
2. **Integers at the edges**: 0, negatives, `INT64_MAX` and `INT64_MIN` through the reader, the printer and
   arithmetic. Division by zero behaves as eval3's does. Pinned in Tasks 3 and 5.
3. **Doubles**: the reader and printer match eval3 (`1.0`, `4.0e18`, `-2.5e-3`). Pinned in Task 3.
4. **The type contract broken**: a boot file whose built-in declarations are out of order. The kernel names the first
   type whose id differs and stops, before any program runs. Pinned in Task 6.
5. **A `<subr>` called through its `_imp` field natively**: no native check calls through a field yet. Pinned in Task 4.

---

### Task 1: Kernel objects and the collector they live in

**Files:**
- Create: `kernel.k` (load order) and `kernel-objects.k`.
- Modify: `maru-gc.k`: `gc-protect` answers its body's value (eval.l:30), and add `gc-let*` (eval.l:37).
- Create: `check/kernel/objects.k` (a test main) and `check/kernel.l` (the driver, on eval2, like check/native.l).
- Modify: `check/check.l`: `kernel_native` and `kernel_c`.

**Interfaces:**
- Produces, in `kernel-objects.k`:
  - `define-object` for eval3's 13 types with boot2.l's fields (boot2.l:425–437) and the ids 0 … 12. `<long>`,
    `<double>`, `<symbol>` and `<subr>` are atoms, as eval3 allocates them.
  - Constructors `newLong`, `newDouble`, `newString`, `newSymbol`, `cons` (newPair), `newArray`, `newExpr`,
    `newForm`, `newFixed` and `newSubr`, with eval3.c's signatures, `k_`-prefixed, each answering `oop`. Also
    `k_getLong` and `k_getDouble`.
- Produces, in `check/kernel.l`: `(kernel-run name test-file args)`. It concatenates maru-gc.k less its main, the
  kernel's files and `test-file`, compiles them natively, runs `main` in a child, and answers its lines. Also
  `(kernel-c name test-file args)`, the same through `ir2-build`.

- [ ] **Step 1: Write the failing check.** `check/kernel/objects.k`'s main asserts:
  - the ids are 0 … 12 in eval3's order;
  - a pair of a string and a long reads back its head's characters and tail's value;
  - an array grows to 100 elements;
  - with `gc_frequency` at 1, a rooted list of 10,000 pairs still sums correctly (Review Focus 1).

  It prints `kernel objects ok`.
- [ ] **Step 2: Run it and see it fail.** Run `make check CHECKS="kernel_native"`. Expected: FAIL (no kernel.k).
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run it and see it pass.** Run `make check CHECKS="kernel_native kernel_c maru_gc maru_gc_coalesce"`.
  Expected: all pass.
- [ ] **Step 5: Commit** with the message "kernel: eval3's types as objects, on maru-gc.k".

### Task 1b: A law over object access, with a poisoning allocator

The user (2026-11-12): test access patterns with laws, so nothing reads uninitialised memory. The precedent is
`check/laws/gc-programs.law` and `gc-model.law`: generated programs, given a meaning on a Maru model and on real
objects.

**Files:**
- Create `check/laws/objects.law`, `check/laws/objects-model.l` and `check/objects-run.k`. The last is a typed driver
  that runs a generated program's operations through the object level.
- Modify `maru-gc.k`: a constant `gc_poison`. When it is set, `gc_malloc` fills a new body with a sentinel word
  instead of zeroes; atoms are filled too. It is set only in the law's builds and Task 6's poisoned run.
- Modify `check/check.l`: add `law_objects`.

**Interfaces:**
- Programs are sequences of these operations, over the kernel's 13 types and a few user types:
  - `new(T)`;
  - `set(slot, T, field, v)`, `get(slot, T, field)`, `put(...)`;
  - `type_of(slot)`;
  - a `get`/`put` naming the wrong type, with a `type_check_fail` that records and returns;
  - `collect`.
- **The model** (Maru) keeps each object's type and, for each field, written-or-unwritten and its value.
- **The claims:**
  - every compiled read equals the model's;
  - a read of an unwritten field is never made by the program under test: the sentinel never appears in a result;
  - a wrong-type access leaves the model unchanged and answers 0;
  - the C build under `-fsanitize=address` (as `png_asan`) exits 0, which catches reads and writes past an object
    or through nil.
- Generated programs follow doc/laws.md's guidance: rules bounded by size, generating rather than filtering,
  deterministic shrinking within the domain, and `classify` over the operation mix.

- [ ] **Step 1: Write the law and the model.** Run `make check CHECKS="law_objects"`. Expected: FAIL (no driver yet).
- [ ] **Step 2: Implement the driver and `gc_poison`.**
- [ ] **Step 3: Run it and see it pass.** Expected: `law objects:` `TESTED n` with each class share. Also prove the law
  bites: a fixture that reads a field before writing it is `REFUTED` with a shrunk case.
- [ ] **Step 4: Commit** with the message "kernel: a law over object access, on a poisoning collector".

### Task 2: Lists, arrays, the printer

**Files:** Create `kernel-lists.k` and `check/kernel/lists.k`, with a check entry.

**Interfaces:**
- Produces eval3's list and array functions (`car`, `cdr`, `arrayAt`, `arrayAtPut` (growing), `arrayAppend`,
  `arrayInsert` …) and its printer (`doprint`, `print`, `dump`, `println`, `dumpln`) for its 13 types.
- Output is eval3's, byte for byte, including its colour escapes for a named user type (eval3.c:1056–1065).

- [ ] **Step 1: Write the failing check.** Print a nested list holding a string, a symbol, a negative long, a double,
  an empty list and an array. Compare with the text `./eval3 -b boot2.l` prints for the same structure, captured
  once as the expected string.
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run it and see it pass.**
- [ ] **Step 5: Commit** with the message "kernel: lists, arrays, the printer".

### Task 2b: Integers boxed or tagged, chosen when the kernel is compiled

The user (2026-11-12): toggle the representation as eval3's `TAG_INT` does, boxed by default (eval3 as built). The
history: Piumarta made integers "boxed or tagged" a switch (306ffb0, 2011), on in eval.c, off in eval2.c and eval3.c.

**Files:** Modify `kernel-objects.k`, `ir2.k` (checked access to an odd word), `check/kernel.l`, `check/check.l`,
`check/objects-run.k`, `check/laws/objects-model.l`. Create `check/kernel/longs.k`.

**Interfaces:**
- `kernel-tagged-int`: 0 (boxed) unless the build defines it 1 before `kernel.k`; `(if-tagged-int TAGGED BOXED)` picks a branch
  at compile time.
- `k_newLong`, `k_getLong` and `k_isLong` as eval3.c:207-214 in each mode: tagged, a value whose top two bits agree is
  `(x << 1) | 1`, and any other boxes.
- The object level, in both modes: `(get <long> bits x)` of an odd word answers its value; `put` to one fails its type
  check (an immediate has no field).

- [ ] **Step 1: Write the failing checks.** `check/kernel/longs.k`: round trips at 0, ±1, ±42, 2^62 - 1, 2^62, -2^62,
  -2^62 - 1, INT64_MAX and INT64_MIN; tagged, the values that fit are odd words and the rest boxed; boxed, none is odd;
  `object-type` 2 for all; `get` of an odd word, `put` to one refused. Every kernel unit and `law_objects` run in both
  modes; the law's model knows an immediate (no field to look at or set, equal by value).
- [ ] **Step 2: Run them and see them fail.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run them and see them pass**, with `native_ir2 ir2_objects` unchanged.
- [ ] **Step 5: Commit** with the message "kernel: integers boxed or tagged, chosen at compile time".

### Task 3: The reader

**Files:** Create `kernel-reader.k`, `check/kernel/reader.k`, `check/kernel/read.txt` and
`check/kernel/read.expected`.

**Interfaces:**
- Produces `k_read (stream: FILE *) -> oop`, eval3's reader: longs, doubles, strings with escapes, characters,
  symbols (interned as eval3 interns them), quote/quasiquote/unquote/unquote-splicing, and comments.

- [ ] **Step 1: Write the failing check.** The fixture `read.txt` covers:
  - each literal kind;
  - `INT64_MAX` and `INT64_MIN`;
  - nesting 200 deep;
  - every string escape.

  The check prints each datum with `k_dumpln`. The expected output is what `./eval3 -b boot2.l` prints for the same
  file, captured into `read.expected`. It runs with `gc_frequency` at 1 (Review Focus 1, 2 and 3).
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run it and see it pass.**
- [ ] **Step 5: Commit** with the message "kernel: the reader, as eval3 reads".

### Task 4: Environments, expand, encode, eval and apply

**Files:** Create `kernel-eval.k` and `check/kernel/eval.k`.

**Interfaces:**
- Produces `k_findVariable`, `k_lookup`, `k_define` (eval3.c:499–520), `k_expand` (:1150), `k_encode` (:1308),
  `k_eval` (:1545), `k_evlist` and `k_apply` (:1611), with eval3's semantics:
  - alist environments;
  - `<fixed>` taking unevaluated arguments;
  - `<expr>` binding formals onto its closed environment;
  - `*applicators*` for other applicable types;
  - fatal "cannot eval" for unknown types.
- A `<subr>` is called through its `_imp` field, typed as a function pointer. Its signature is eval3's subr
  convention (arguments, env).

- [ ] **Step 1: Write the failing check.** `check/kernel/eval.k`'s main installs a few subrs (`+`, `cons`, `car`) and
  the fsubrs `define`, `lambda`, `let`, `if` and `set` (minimal versions of Task 5's). It then evaluates expressions
  read with `k_read` from a string:
  - a closure kept past its caller;
  - recursion 1,000 deep;
  - a `<form>` macro;
  - an `*applicators*` entry for a user type.
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run it and see it pass**, natively too, which proves the call through `_imp` (Review Focus 5).
- [ ] **Step 5: Commit** with the message "kernel: eval and apply as eval3's, subrs through their _imp".

### Task 5: The primitives boot2.l and repl.l use

**Files:** Create `kernel-primitives.k`, `check/kernel/primitives.k`, `check/kernel/primitives.l` and
`check/kernel/primitives.expected`.

**Interfaces:**
- Produces eval3's primitives that `boot2.l`, `repl.l` and `test-repl.l` use, each a `<subr>` whose `_imp` is a
  typed Maru function. **Measure the list; don't guess it.** Run those files on a kernel that reports every unbound
  name instead of stopping, then write the list into the doc.
- eval3's FFI (`subr` through libffi, `dlextern`) is included only if those files use it. If so, it stays a call
  out to libffi; the kernel doesn't reimplement it.

- [ ] **Step 1: Write the failing check.** `primitives.l` runs each primitive on representative arguments, including
  the integer edges and division by zero (Review Focus 2). Its expected output is
  `./eval3 -b boot2.l check/kernel/primitives.l`'s, captured.
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.** First measure the unbound list.
- [ ] **Step 4: Run it and see it pass.**
- [ ] **Step 5: Commit** with the message "kernel: the primitives boot2.l and repl.l use, as eval3's".

### Task 6: Main and the REPL; boot2.l and the repl test

**Files:**
- Create `kernel-main.k`.
- Modify `check/kernel.l` and `check/check.l`: add `kernel_repl` (native) and `kernel_repl_c`.
- Create `doc/kernel.md` and add its AGENTS.md line.

**Interfaces:**
- Produces `main (argc, argv)`, as eval3's main does: root the globals, take `-b FILE` as the boot file (default
  `boot2.l`), load it, check the type contract (Review Focus 4), load each remaining argument, then run the REPL on
  stdin when none remain.

- [ ] **Step 1: Write the failing check.** `kernel_repl` runs the kernel natively with `-b boot2.l repl.l
  test-repl.l`. It asserts the 10x10 table, the last line `nfibs(15) is 1973`, and that the whole output equals
  `./eval3 -b boot2.l repl.l test-repl.l`'s, line for line. `kernel_repl_c` does the same through C. A boot file
  with two built-in declarations swapped makes the kernel stop, naming the type.
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.** Debug boot2.l's load against `./eval3` by form: the first form whose value differs.
- [ ] **Step 4: Run it and see it pass.** Run `make check CHECKS="kernel_repl kernel_repl_c eval3"`. Also run `kernel_repl` once on the poisoning collector (`gc_poison`): the same output, so the kernel
  reads no field it hasn't written.
- [ ] **Step 5: Write doc/kernel.md**: the sections, each one's eval3.c lines, the departures (word size, anything
  measured, the `*evaluators*` decision), the checks, and the measured primitive list.
- [ ] **Step 6: Run the full suite** with `caffeinate -i make check`, then add the ledger entries. Commit with the
  message "kernel: boots boot2.l and runs repl.l as eval3 does".

### Task 7: Lowering rules choose their arm64 rows once (assembler option 2)

Added 2026-11-12 at the user's request, parked behind Task 6. The kernel is compiled natively, unit after unit and
mode after mode, so compile time is this plan's cost.

**Why.** native-arm64.g knows which instruction each rule means: `(op add d a b) -> ((ADD ,d ,a ,b))`. It emits a
symbolic form, and asm-table.l then rediscovers the row. It classifies each operand, looks up the candidate rows and
tries binding them. Measured on real native compiles (one compile of `maru-check.k`, 12,038 instructions, CPU time):

| | eval2 total | eval2 encoding | eval3 total | eval3 encoding |
|---|---|---|---|---|
| main (d23a382) | 13.2 s | 8.7 s, 722 µs an instruction | 18.1 s | 10.7 s, 887 µs |
| compiled rows | 6.7 s | 2.8 s, 232 µs | 8.3 s | 3.6 s, 299 µs |

The compiled rows are the assemblers branch: candidate table, `<asm-isa>`, shared shapes, `arm64-plan`. Encoding is
still 28–42% of a compile. Staging the choice is oecm §5.1's staged evaluation: the choice depends on meaning, so it
is made before the encoder.

Measured and set aside: shapes and mnemonics as array ids (a0b023f, branch `asm-ids`). They gained about 10% in eval3's
encoding, but on eval2 install grew from about 7.5 s to about 10.7 s over five interleaved runs, with encoding
unchanged, for reasons not found. Option 2 bypasses that lookup anyway.

**Files:** Modify `native-arm64.g`, `asm-arm64.l`, and `native-link.l` if a pre-encoded form needs more than `(data
…)`. Add a check beside `native_ir2`.

**Interfaces:**
- Consumes the compiled rows: `arm64-plan` and `arm64-encode-row`.
- Produces a site per lowering rule: its mnemonic and the operand kinds it declares (an X register, a W register, a
  slot offset). The site's candidate rows are resolved once, when the grammar is built, and kept with the rule. At
  run time the rule binds its operands' values into those rows' plans and emits the four bytes as `(data b0 b1 b2
  b3)`, which `asm` already passes through.
- A value-dependent choice (does an immediate fit?) is narrowed to the site's two or three rows when the grammar is
  built. Branches, label operands and anything a site can't encode keep today's path, the symbolic form through
  `asm`, so a refusal's message is unchanged.
- asm-table.l stays the general encoder for hand-written assembly.

- [ ] **Step 1: Bind by kind, not by a chain of conditions** (the user, 2026-11-12). `arm64-bind-plan` picks each
  operand kind's handling through one chain of conditions (CC 71, the assembler's highest), the shape the old
  `arm64-bind` had, against the rule of dispatch by type. Compile each operand kind's plan into a binder of its own
  when the row is compiled (`arm64-plan-kind` answers a function of `(plan op vals pc)` with its slots closed over),
  so the plan's binder is the dispatch and encoding no longer tests the kind. The gate:
  - the bytes and reports for every arm64 sample, placeholder variants included, are the same as before (the sweep
    over `check/asm-table.l`'s stream, as when the rows were compiled);
  - `asm_table`, `asm_rows_arm64`, `asm_patch` and `asm_coverage` pass;
  - `arm64-bind-plan`'s CC 71 leaves erosion's time sinks, ledgered;
  - one real compile of each unit on eval2 and eval3 (best of five, CPU time) is no slower.
  Commit it on its own, with the message "asm-arm64: each operand kind binds through its own compiled binder", before
  the sites build on it.
- [ ] **Step 2: Write the failing check.** Compile `maru-gc.k`, `maru-check.k` and `check/ir2.k` both ways, sites on
  and off. The two native images must be byte for byte the same, and each must run as `native_ir2` asks (maru-gc.k's
  11 reports, and the rest).
- [ ] **Step 3: Run it and see it fail** (no sites yet).
- [ ] **Step 4: Implement sites** for the `op` intents first, then `load`/`store` (`native-arm64-load`/`-store`,
  where the offset decides the row).
- [ ] **Step 5: Run it and see it pass**, then time one compile of each unit on eval2 and eval3. Use best of five
  interleaved runs, CPU time by `clock()`, with the encoding share measured. Keep the change only if the whole
  compile gets faster on both evaluators.
- [ ] **Step 6: Extend to the remaining intents** the coverage check lists (`asm_coverage`: 248 needs over 254 forms),
  then write it into doc/assemblers.md and doc/native.md.
- [ ] **Step 7: Commit** with the message "native-arm64: lowering rules choose their rows once".

Open: x86-64's lowering (native-x64.g) can take the same sites once arm64's are measured. x86 rows aren't compiled
plans yet, so they need what Task 7 gives arm64 first.

## After this plan (not in it)
- **2a, the kernel's collector (chosen 2026-11-12):** port gc.c's design to Maru as `kernel-gc.k`, replacing
  maru-gc.k inside the kernel; maru-gc.k stays for its own checks. It brings what eval3's memory has and maru-gc.k
  lacks:
  - a per-object `length` in the header, which `data-length` reads;
  - ephemerons and weak keys (`GC_weaken`, `GC_weak_settle`), which hash.l's weak tables need;
  - heap limits, `GC_check_heap`, `GC_collect_every`, realloc and free.
  The `gc_laws` and `gc_model` laws, which hold gc.c today, are pointed at the port, so it inherits their oracle.
  It comes after Task 6 (boot2.l and the repl test need none of it) and before 2b loads the rest of the system.
- **2b:** maru.k on the kernel (on eval3 it needs ir2 loaded first: `./eval3 maru.k` alone stops at `IR-VOID`), then
  maru.k on the kernel compiles the kernel: the evaluator compiling itself, plan 3f.
- **2c:** a standalone native executable for the kernel: the RFC's unimplemented `native-executable`, from exe.l.
- **3:** `ir-gen-wasm.k`.
