# The Grounded Kernel Boots boot.l: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Maru's evaluator kernel, rewritten in typed Maru through ir2 using the object level (doc/ir2-objects.md),
runs natively and through C. It loads today's boot.l, and runs `repl.l test-repl.l` with output identical to
`./eval`'s.

**Architecture:**
- **Structure** is eval.l's, section by section: collector, objects, lists, reader, environments, eval/apply,
  primitives, REPL. eval and apply dispatch through `*evaluators*`/`*applicators*` by type, as oecm (TR-2011-002)
  Fig 3 has them.
- **Primitives** come from eval.c, for those boot.l needs and eval.l lacks.
- **Objects** use `define-object` with ids taken from the host (`(define-object <pair> <pair> ...)`), so they match
  boot.l's numbering. Fields are never reached by offset.
- **Collector:** maru-gc.k.
- **Each section ends with a typed check unit** run natively (in-process, as `native-run-main` does) and through C.
- **The oracles are `./eval` and `./eval2`**, which stay (see the spec's Decision).

**Tech Stack:** maru.k on eval2, ir2.k, native-gen.k (arm64), ir-gen-c.k, maru-gc.k, check/native-child.l.

**Spec:** `/Users/ndn/.claude/plans/i-think-my-oldest-whimsical-scott.md`, Direction step 2. Grounding: oecm §5.1 (the
grounded part is minimal: dispatch from type to meaning, and the `<subr>` call), colaswp §6.1 (Pepsi.coke). Step 1:
doc/plans/2026-11-11-ir2-object-level.md.

## Global Constraints
- **eval, eval2 and eval3 are not modified or retired.** They are the oracles. The kernel is new files only.
- **eval.l is the structure; eval.c is the meaning** where they differ, because today's boot.l runs on eval.c. Where
  eval.l has a bug, fix it and say so in the doc; don't port it. The known list: `putc` ignores its character (1299);
  `!=` on strings is always true (1263); `format`'s malloc check is misparenthesised (1316); `read_quote` is missing
  its stream (822); `do_print` is missing an argument (566); `fatal1` is given an object for `%s` (1507); a debug line
  is printed on the binary-operator error path (1220); `fprintf` has an extra argument (193); `/` has no
  zero-division check.
- **Word size comes from `sizeof`**, never 4 (eval.l hard-codes 4 at 83, 126, 183, 203, 357, 507, 524 and 1382).
  Integers print with `%ld`.
- **Objects only through the object level.** Use `new`, `get`/`put` or the `<T>-field` accessors, `object-type` and
  `object-is`. Every `define-object` goes at the top of its file, before any use: boot has same-named accessors
  (doc/ir2-objects.md, "Declaration order"). `oop-at` appears only inside the `oop-at`/`set-oop-at` primitives,
  which are word access by definition.
- **The type names are today's (`long`, `int`, `char`).** Explicit widths are iterated within this loop, not first
  (laneq #120).
- **Kernel files** are flat, per the repo layout: `kernel.k` loads the section files `kernel-objects.k`,
  `kernel-lists.k`, `kernel-reader.k`, `kernel-eval.k`, `kernel-primitives.k` and `kernel-main.k`, after maru-gc.k
  less its main. Function names keep eval.l's (`k_read`, `k_eval`, `k_apply` …) so each function maps back to its
  original.
- New runtime code is Maru languages only. Checks match values in Maru. `make check` stays green, under
  `caffeinate -i`, one suite at a time. Ledger entries go in `check/lines` and `check/erosion`. Each task ends in a
  checkpoint commit.
- Work in `.worktrees/kernel` on branch `kernel`, stacked on `ir2-objects`. Rebase onto main once step 1 merges.

## Review Focus
1. **A garbage collection in the middle of building an object.** Every local holding an object across an allocation
   must be rooted (`gc-protect`), or the collector frees or moves under it. A check runs each constructor and the
   reader with `gc_frequency` forced low (collect on every allocation), and asserts the structures read back intact.
   Pinned in Tasks 1 and 3.
2. **Integers at the edges.** Boxed longs at 0, negative values, `LONG_MAX` and `LONG_MIN` through the reader, the
   printer and `+ - * / %`. Division by zero is an error, not a crash. Pinned in Tasks 3 and 5.
3. **Doubles.** boot.l uses `1.0` and `4.0e18`. The reader reads doubles, not `1` followed by the symbol `.0`, and the
   printer prints them as eval.c does. Pinned in Task 3.
4. **An unbound name while loading.** eval.l's `k_encode` is fatal at the first one. The kernel reports it as eval.c
   does, and the REPL goes on. Pinned in Task 4.
5. **A `<subr>` called through its `_imp` field natively.** No native check calls through a field yet. Pinned in Task 4.

---

### Task 1: Kernel objects and the collector they live in

**Files:**
- Create: `kernel.k` (load order), `kernel-objects.k`
- Modify: `maru-gc.k`: `gc-protect` answers its body's value, as eval.l's does (eval.l:30); add `gc-let*` (eval.l:37).
- Create: `check/kernel/objects.k` (a test main), `check/kernel.l` (the driver, on eval2, like check/native.l)
- Modify: `check/check.l`: `(check "kernel_native" ...)` and `(check "kernel_c" ...)`

**Interfaces:**
- Produces, in `kernel-objects.k`:
  - `define-object` for all 16 types, in boot.l's order (boot.l:417–432), with the ids of the host's types and boot's
    fields. `<long>`, `<double>`, `<symbol>` and `<subr>` are atoms.
  - Constructors: `new-<long>`, `new-<double>`, `_new-<string>`, `new-<string>`, `new-<symbol>`, `new-<pair>`,
    `new-<array>`, `new-<expr>`, `new-<form>`, `new-<fixed>`, `new-<subr>`, `new-<variable>`, `new-<env>`,
    `new-base-<context>`, `new-<context>`. Signatures are eval.l's (eval.l:311–465), each answering `oop`.
  - `get_long`, `is_long`, and `get_double` (new).
- Produces, in `check/kernel.l`: `(kernel-run name test-file args)`. It concatenates maru-gc.k less its main,
  `kernel.k`'s files, and `test-file`, compiles them natively, runs `main` in a child, and answers its lines. Also
  `(kernel-c name test-file args)`, the same through `ir2-build`.

- [ ] **Step 1: Write the failing check.** In `check/kernel/objects.k`'s main:
  - assert each id equals eval.c's enum (eval.c:78): `<undefined>` 0 … `<context>` 15;
  - build a pair of a string and a long, and read back its head's characters and tail's value;
  - grow an array to 100 elements;
  - build 10,000 pairs with `gc_frequency` set to 1, and assert a list kept by a root still sums correctly (Review
    Focus 1).

  It prints `kernel objects ok`. check.l's `kernel_native` and `kernel_c` expect that line.
- [ ] **Step 2: Run it and see it fail.** Run `make check CHECKS="kernel_native"`. Expected: FAIL (no kernel.k).
- [ ] **Step 3: Implement** the objects and maru-gc.k's two forms.
- [ ] **Step 4: Run it and see it pass.** Run `make check CHECKS="kernel_native kernel_c maru_gc maru_gc_coalesce"`. Expected:
  all pass, including maru-gc.k's own checks after the `gc-protect` change.
- [ ] **Step 5: Commit** with the message "kernel: objects in boot.l's types, on maru-gc.k".

### Task 2: Lists, arrays, the printer

**Files:** Create `kernel-lists.k`. Extend `check/kernel/objects.k`, or add `check/kernel/lists.k` with a check
entry per file.

**Interfaces:**
- Produces eval.l's `k_car` … `k_caddr`, `k_string_length`, `k_concat`, `k_array_length`, `k_array_at`,
  `k_set_array_at` (which grows), `k_array_append`, `k_array_insert`, `do_print`, `k_print`, `k_println`, `k_dump`,
  `k_dumpln`.
- The printer's output for every type is eval.c's, byte for byte, doubles included.

- [ ] **Step 1: Write the failing check.** Print a nested list holding a string, a symbol, a negative long, a double,
  an empty list and an array. Compare against the exact text `./eval` prints for the same structure, captured
  once and written as the expected string. Insert into the middle of an array.
- [ ] **Step 2: Run it and see it fail.** Expected: FAIL.
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run it and see it pass.**
- [ ] **Step 5: Commit** with the message "kernel: lists, arrays, the printer".

### Task 3: The reader

**Files:** Create `kernel-reader.k` and `check/kernel/reader.k`.

**Interfaces:**
- Produces `k_read (stream: FILE *) -> oop`, eval.l's reader with eval.c's literal syntax:
  - doubles (`1.0`, `4.0e18`, `-2.5e-3`);
  - `#\` characters if boot.l uses them;
  - string escapes;
  - quote, quasiquote, unquote and unquote-splicing, with the stream passed (eval.l:822's bug fixed).
- `intern` keeps eval.l's sorted symbol table.

- [ ] **Step 1: Write the failing check.** The reader's check reads a fixture file `check/kernel/read.txt` covering
  each literal kind, `LONG_MAX`/`LONG_MIN`, nesting 200 deep, and a string with every escape. It prints each datum
  with `k_dumpln`.
  - The expected output is what `./eval` prints for `(map dumpln (read-all "check/kernel/read.txt"))`, captured
    into `check/kernel/read.expected`.
  - It runs with `gc_frequency` at 1 (Review Focus 1, 2 and 3).
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run it and see it pass.**
- [ ] **Step 5: Commit** with the message "kernel: the reader, doubles included".

### Task 4: Environments, expand, encode, eval and apply

**Files:** Create `kernel-eval.k` and `check/kernel/eval.k`.

**Interfaces:**
- Produces `k_env_find_variable`, `k_env_lookup`, `k_env_define`, `k_expand`, `k_encode`, `k_eval`, `k_apply`, and
  `k_apply_expr`, with eval.l's semantics. That includes recycled contexts, `stable` envs, the `(set (f x) v)`
  rewrite, and `<fixed>`/`<form>` inlining.
- Types without a built-in rule go through `*expanders*`, `*encoders*`, `*evaluators*` and `*applicators*`, arrays
  indexed by type, as oecm Fig 3 has them.
- A `<subr>` is called through its `_imp` field, which is typed as a function pointer
  `(oop oop oop) *` (arguments, context).
- An unbound name while loading is reported as eval.c reports it, not fatally (Review Focus 4). eval.l's
  unconditional debug prints in `k_encode` (1025, 1030) are dropped.

- [ ] **Step 1: Write the failing check.** `check/kernel/eval.k`'s main defines three subrs in C-free typed Maru
  (`+`, `cons`, `car`) and the fsubrs `define`, `lambda`, `let`, `if` and `set` (taken from Task 5's set, minimally).
  It then evaluates strings read with `k_read` from a string stream:
  - a closure capturing a variable after its frame is gone (stable env);
  - recursion 1,000 deep;
  - a `<form>` macro;
  - an `*applicators*` entry for a user type;
  - an unbound name, reported, with the next expression still evaluated.
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.**
- [ ] **Step 4: Run it and see it pass**, natively too, which proves the call through `_imp` (Review Focus 5).
- [ ] **Step 5: Commit** with the message "kernel: eval and apply by type, subrs through their _imp".

### Task 5: The primitives boot.l needs

**Files:** Create `kernel-primitives.k` and `check/kernel/primitives.k`.

**Interfaces:**
- Produces eval.l's 68 primitives (eval.l:1588–1655), with the bugs fixed, plus eval.c's for each name today's boot.l
  and repl.l use that eval.l lacks.
- **Measure that list; don't guess it.** Load boot.l, then `repl.l`'s requires, on a kernel that reports every unbound
  name instead of stopping. Implement what it lists. The first known: `%`, `~`, `string-copy`, `address-of`,
  `double->long`, double arithmetic, `string->long`, `data`, `data-length`, `fixed?`, `form?`, and the `X-at` and
  `set-X-at` families boot.l touches.
- **eval.c's undo log** (`undo-begin` …) is included only if boot.l or repl.l call it. If they do, write it in Maru,
  never in C.
- Each primitive is a `<subr>` whose `_imp` is a typed Maru function.

- [ ] **Step 1: Write the failing check.** `check/kernel/primitives.k` runs, for each primitive, the same expressions
  as a fixture `check/kernel/primitives.l`. The expected output is `./eval check/kernel/primitives.l`'s, captured
  into `check/kernel/primitives.expected`. Include the integer edges and division by zero (Review Focus 2).
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.** First measure the unbound list and write it into the doc.
- [ ] **Step 4: Run it and see it pass.**
- [ ] **Step 5: Commit** with the message "kernel: primitives, eval.l's and the ones boot.l needs from eval.c".

### Task 6: REPL and main; boot.l and the repl check

**Files:**
- Create `kernel-main.k`.
- Modify `check/kernel.l` and `check/check.l`: add `kernel_repl` (native) and `kernel_repl_c`.
- Create `doc/kernel.md` and add its AGENTS.md line.

**Interfaces:**
- Produces `main (argc, argv)`, the shape eval.c's main has: root the globals, load `boot.l`, then each argument as a
  file, then the REPL on stdin when no file remains.

- [ ] **Step 1: Write the failing check.** `kernel_repl` runs the kernel natively, with arguments `repl.l
  test-repl.l`, and asserts what the `repl` check asserts: the 10x10 table and the last line
  `nfibs(15) is 1973`. It also asserts that its whole output equals `./eval repl.l test-repl.l`'s, line for line.
  `kernel_repl_c` does the same through C.
- [ ] **Step 2: Run it and see it fail.**
- [ ] **Step 3: Implement.** Debug boot.l's load against `./eval` by form: the first form whose value differs.
- [ ] **Step 4: Run it and see it pass.** Run `make check CHECKS="kernel_repl kernel_repl_c repl"`.
- [ ] **Step 5: Write doc/kernel.md**: the sections, each one's eval.l lines, the departures (each bug fixed, word
  size, eval.c primitives), the checks, and the measured unbound list.
- [ ] **Step 6: Run the full suite** with `caffeinate -i make check`, then add the ledger entries. Commit with the
  message "kernel: boots boot.l and runs repl.l as eval does".

## After this plan (not in it)
- **2b:** the kernel boots `boot2.l` and runs maru.k, with eval2 as the oracle. Then maru.k on the kernel compiles
  the kernel: the evaluator compiling itself, plan 3f.
- **2c:** a standalone native executable for the kernel: the RFC's unimplemented `native-executable`, from exe.l.
- **3:** `ir-gen-wasm.k`.
