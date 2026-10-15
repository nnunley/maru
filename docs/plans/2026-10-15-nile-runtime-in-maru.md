# Nile Runtime in Typed Maru: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Nile programs compiled through Maru run end to end on arm64 macOS and x86-64 Linux, on a Nile runtime written in typed Maru.

**Architecture:** The runtime lives in the `nile` fork at `runtimes/maru/`, mirrors the C runtime file for file, and compiles with the test or kernel code in one `eval2 ir-gen-c.k maru.k …` run, then `cc -pthread`. Every check is a case in `maru`'s `check/check.l`, which reaches the runtime through the `nile/` submodule. Nile's compiler moves to `eval2` with `boot2.l` on `maru`'s `main`.

**Tech Stack:** Typed Maru (`maru.k`, `ir2.k`, `ir-gen-c.k`) under `eval2`; untyped Maru under `eval` for `check/check.l`; POSIX threads; clang/cc with ThreadSanitizer; git submodules; `gh`.

**Spec:** `docs/rfc/draft-ndn-nile-runtime-in-maru-01.md`. Read it before any task. Requirement IDs below (`[R-…]`) are its markers.

## Global Constraints

- Every requirement uses the RFC's exact values: `BLOCK_SIZE` 512, `CHUNK_MAX_LEN` 16, `INPUT_QUOTA` 5, `INPUT_MAX` 10.
- The runtime is typed Maru calling libc and pthreads through `extern`. No C in `runtimes/maru/` except test drivers for the C-target path.
- No spinning, no spin locks, no atomics: `pthread_mutex_*` and `pthread_cond_*` only.
- Each commit that changes the source line count adds a `check/lines` entry with its delta and reason, so `./eval check/check.l lines` passes after every commit.
- Commit messages are Conventional Commits. No `Co-Authored-By` or other Claude attribution (a hook blocks it).
- Work happens on short-lived branches (`nile-runtime` in `maru`, `maru-runtime` in the forks), merged into `main` and deleted when done; no stale branches. Push `main` and the forks' branches as work lands.
- A task is done when its `maru-check` cases print `PASS` and `make check` stays green. `~/.claude/skills/authoring-rfcs/rfc-run --expect docs/rfc/draft-ndn-nile-runtime-in-maru-01.md` keeps reporting "red as declared" until Task 11, after which the RFC's `**Corpus:**` line is removed and it reports green.
- Runs on arm64 macOS by default. Task 12 repeats `make check` on `ndn.lan` (x86-64 Linux, fish shell).

## Review Focus

1. **`nile_sync` with nothing launched.** Expected: it returns at once. Test: `nile_startup` check calls sync before any pipeline (Task 6).
2. **`nile_shutdown` while workers are waiting on their condition variables.** Expected: every worker wakes and joins; no hang. Test: startup check with 8 workers, under the 120 s `run` limit (Task 6).
3. **A pipeline fed zero elements.** Expected: prologue and epilogue still run once; output is the epilogue's alone. Test: `nile_prefix` test feeds an empty stream as its second case (Task 8).
4. **An input whose length is not a multiple of the kernel's quantum.** Expected: the runtime reports `BAD_ARG` from `nile_Process_feed`, never splits an element. Test: `nile_limits` third case (Task 7).
5. **Output exactly filling a buffer at end of stream.** Expected: no empty trailing buffer is passed downstream and nothing is lost. Test: `nile_reverse` uses an element count that fills whole buffers exactly (Task 9).

---

### Task 1: Forks, submodules and the line count across repositories

**Requires the author's go-ahead before Step 1:** it creates two public GitHub repositories under `nnunley`.

**Implements:** [R-lines]

**Files:**
- Create: `.gitmodules` (submodules `nile/`, `gezira/`)
- Modify: `check/check.l:214` (the `lines` case), `check/lines`, `CLAUDE.md` (the `lines` paragraph)
- In the `nile` fork: create `.gitattributes`

**Interfaces:**
- Produces: `nile/` and `gezira/` submodules on branch `maru-runtime`; the `unused` attribute.

- [ ] **Step 1:** `gh repo fork damelang/nile --clone=false` and `gh repo fork damelang/gezira --clone=false`. Expected: `nnunley/nile` and `nnunley/gezira` exist.
- [ ] **Step 2:** `git submodule add https://github.com/nnunley/nile.git nile` and the same for `gezira`; in each, `git switch -c maru-runtime`.
- [ ] **Step 3:** In `nile/.gitattributes`, mark `viz/** compilers/js/** compilers/st/** runtimes/c/** runtimes/js/** examples/c/**` as `unused`, with a one-line comment saying what `unused` means.
- [ ] **Step 4:** Run `./eval check/check.l lines`. Expected: FAIL, because the count does not yet include submodules (the sum is unchanged).
- [ ] **Step 5:** Change the counting command to list files from `git ls-files --recurse-submodules` plus `git ls-files -o --exclude-standard`, still excluding `:!notes`, and filter out both `derived` and `unused` (`git check-attr --stdin derived unused`, keep lines where both are `unspecified`; run `check-attr` inside each submodule for its own files).
- [ ] **Step 6:** Add one `check/lines` entry for bringing in Nile and Gezira, with the counted delta and the reason ("Nile's compiler and prelude and Gezira's kernels, the Frank-level stack the 20k budget covers").
- [ ] **Step 7:** Run `./eval check/check.l lines`. Expected: `PASS lines`.
- [ ] **Step 8:** Commit in `nile` (`chore: mark code outside the Maru stack as unused`), then in `maru` (`build: add the nile and gezira forks as submodules and count their lines`). Push the forks' `maru-runtime` branches.

### Task 2: `boot2.l` gains the string and number operations Nile's compiler needs

**Implements:** [R-boot2-strings]

**Files:**
- Modify: `boot2.l` (definitions added near its other string functions)
- Create: `check/boot2-strings.l`
- Modify: `check/check.l` (case `boot2_strings`), `check/lines`

**Interfaces:**
- Produces, in `boot2.l`: `(string-copy str [start [length]])`, `(string-compare a b [start [length]])` returning <0/0/>0, `(long->string n [radix])`, `(string->long str [radix])`, with `eval.c`'s semantics, plus any further entries Task 3 discovers.

The full set `eval2` dropped and `boot2.l` lacks is: `allocate-atomic array-compare byte-at char-at data data-length double->string double-at fixed? getb int-at int64-at long->string long-at longdouble-at longlong-at native-call pointer-at putb save set-*-at short-at string->long string-compare string-copy subr subr-name symbol-compare times warn wchar-at`. Only those Nile's compiler path uses are added; the first two known are `string-copy` (`nile-ast-nodes.l`, `text-parser.l`) and `string-compare` (`text-parser.l`).

- [ ] **Step 1: Write the failing test** `check/boot2-strings.l`, run under `./eval2 -b boot2.l`. It asserts, and prints `boot2 strings ok` only if all hold:
  - `(string-copy "abcdef" 2 3)` = `"cde"`; `(string-copy "abc")` = `"abc"`; `(string-copy "abc" 1)` = `"bc"`
  - `(string-compare "abc" "abd")` < 0; `(string-compare "abc" "abc")` = 0; `(string-compare "xabc" "abc" 1 3)` = 0 when the start applies to the first argument, as in `eval.c` (read `subr_string_compare` to confirm the argument order before writing this line)
  - `(long->string 255)` = `"255"`; `(long->string 255 16)` = `"ff"`; `(string->long "-42")` = -42; `(string->long "ff" 16)` = 255
- [ ] **Step 2:** Add case `boot2_strings` to `check/check.l`: runs `./eval2 -b boot2.l check/boot2-strings.l`, asserts the last line is `boot2 strings ok`. Run `./eval check/check.l boot2_strings`. Expected: FAIL with `undefined variable: string-copy`.
- [ ] **Step 3:** Define the four functions in `boot2.l` in Maru, using `string-at`, `set-string-at`, `string-length` and `string` (allocation) that `boot2.l` already has.
- [ ] **Step 4:** Run `./eval check/check.l boot2_strings`. Expected: `PASS boot2_strings`. Run `make check`. Expected: all pass.
- [ ] **Step 5:** `check/lines` entry; commit `feat(boot2): define string-copy, string-compare and number conversions in Maru`.

### Task 3: Nile's compiler on `eval2`/`boot2.l` and Maru `main`

**Implements:** [R-compiler-boot2] (its `nile_text_layout` evidence completes in Task 11)

**Files:**
- Restore: `print-structure.l` (from `git show f6671da^:print-structure.l`)
- In `nile`: delete `compilers/maru/maru/` (the 2012 copy) and its `unused` line; mark `compilers/maru/nile-gen-code-c.l`, `nile-builtins-c.l` and `nile-to-c-compiler.sh` `unused`; modify `compilers/maru/nile-to-maru-compiler.sh` and whatever `compilers/maru/*.l` the port needs
- Modify: `boot2.l` (further dropped operations the port finds), `check/boot2-strings.l` (an assertion per added operation), `check/check.l` (case `nile_compile`), `check/lines`, `CLAUDE.md` (Verify list: `boot2_strings`, `nile_compile`)

**Interfaces:**
- Consumes: Task 2's `boot2.l` functions.
- Produces: `nile/compilers/maru/nile-to-maru-compiler.sh MODULE FILE.nl`, which runs `$MARU/eval2 -b $MARU/boot2.l -L $MARU/ -L <compiler dir>/ <compiler dir>/nile-compiler.l <compiler dir> maru MODULE FILE.nl`. `MARU` defaults to `<compiler dir>/../../..` when that directory contains `boot2.l`, else the script exits 2 with `set MARU to a maru checkout`.

- [ ] **Step 1: Write the failing test.** Case `nile_compile`: compiles `nile/examples/text-layout.nl` twice per target, once with the old path (`./eval -b boot.l -L ./ …` on the same compiler files, kept only inside this check as the oracle) and once with the new script; asserts the Maru-target outputs are byte-identical.
- [ ] **Step 2:** Run `./eval check/check.l nile_compile`. Expected: FAIL at `undefined variable: string-copy` (until Task 2 lands) or the next missing definition.
- [ ] **Step 3:** Port: restore `print-structure.l`; rewrite the two scripts as above; for each failure, add the missing operation to `boot2.l` (with an assertion in `check/boot2-strings.l`) or adapt the compiler file. No compiler file uses `*env*` or `Variable`/`Env` objects (checked 2026-10-15), so expect library gaps, not dialect rewrites.
- [ ] **Step 4:** Run `./eval check/check.l nile_compile boot2_strings`. Expected: both PASS. `make check` green.
- [ ] **Step 5:** `check/lines` entries (restored `print-structure.l`; `boot2.l` additions). Commit in `nile`: `refactor(compiler): run on maru main under eval2 and find maru through MARU`; in `maru`: `feat: run Nile's compiler on eval2 and boot2.l`.

### Task 4: One interface definition: `nile.k` and `sizeof_vars`

**Implements:** [R-one-interface]

**Files:**
- In `nile`: move `runtimes/c/nile.k` to `runtimes/maru/nile.k` and complete it; modify `compilers/maru/nile-gen-code-maru.l:107` (constructor emission); create `runtimes/maru/test/interface.k`
- Modify: `check/check.l` (case `nile_interface`), `check/lines`

**Interfaces:**
- Produces: `nile.k` declaring every call in the RFC's "Public interface" and "The kernel interface" tables. The constructor is `(nile_Process (nile_Process_t * nile_Process_t * int int int nile_Process_work_function_t nile_Process_work_function_t nile_Process_work_function_t) *)` — parent, in_quantum, out_quantum, sizeof_vars, prologue, body, epilogue. `nile_Process_pipe` takes two processes. Status values `NILE_STATUS_OK` 0, `NILE_STATUS_OUT_OF_MEMORY` 1, `NILE_STATUS_BAD_ARG` 2, `NILE_STATUS_SHUTTING_DOWN` 3 as `define-constant`s.
- Produces: the Maru generator emits `sizeof_vars` as the fourth argument: `(sizeof struct <cname>_vars)` when the kernel has variables, else `0`. Confirm `maru.k`'s `sizeof` syntax against `maru-compile-sizeof` before writing it.

- [ ] **Step 1: Write the failing test.** Case `nile_interface`: generates `test/interface.k`'s call list from every `(extern NAME)` in `nile.k` (a program storing each function's address in an array of `void *` and printing the count), builds it with `nile-build` once Task 7 lands (until then, asserts only the generator part below), and asserts it links and prints the number of externs; asserts the generated Maru for `text-layout.nl` contains `(nile_Process parent 2 3 (sizeof struct text_layout_MakeWords_vars)`.
- [ ] **Step 2:** Run it. Expected: FAIL (the generator emits no `sizeof`).
- [ ] **Step 3:** Complete `nile.k`; change the Maru generator.
- [ ] **Step 4:** Run `./eval check/check.l nile_interface nile_compile`. Expected: both PASS (`nile_compile` still compares old and new dialects, which share the generators).
- [ ] **Step 5:** `check/lines`; commit in `nile`: `feat(runtime): make nile.k the interface and pass sizeof_vars`; in `maru`: `test: check the Nile interface`.

### Task 5: pthread types from `nile.osdefs`, and the build helper

**Implements:** [R-opaque-pthread]

**Files:**
- In `nile`: create `runtimes/maru/nile.osdefs`, `runtimes/maru/nile-sync.k`, `runtimes/maru/test/osdefs.k`, `runtimes/maru/test/osdefs.c`
- Modify: `check/check.l` (helper `nile-build`, case `nile_osdefs`), `check/lines`

**Interfaces:**
- Produces: `nile.osdefs` with `header pthread.h`, `type mutex pthread_mutex_t`, `type cond pthread_cond_t`, `type thread pthread_t`, `sizes mutex cond thread`, built to `nile.osdefs.k` with `maru`'s `compile-osdefs.l` exactly as `system.osdefs` is (its `.c` is temporary). It defines `sizeof-mutex`, `alignof-mutex` and the rest.
- Produces, in `nile-sync.k`: `(define-form define-opaque (name ctype) …)` expanding to `(define-struct name ((w0 long) … (wK long)))` with `K = sizeof-ctype / 8 - 1`, calling `error` naming the type when the alignment exceeds 8 or the size is not a multiple of 8; structs `nile_Mutex`, `nile_Cond`, `nile_OSThread`; externs for `pthread_mutex_init/destroy/lock/unlock`, `pthread_cond_init/destroy/wait/signal/broadcast`, `pthread_create`, `pthread_join`; and `(nile_lock (void struct nile_Mutex *))`, `nile_unlock`, `nile_wait (cond, mutex)`, `nile_signal`, `nile_broadcast`.
- Produces, in `check/check.l`: `(nile-build NAME FILES CFLAGS)` → path of the binary. It builds `nile.osdefs.k` if absent, runs `./eval2 ir-gen-c.k maru.k nile/runtimes/maru/nile.osdefs.k <runtime files> FILES > tmp/NAME.c` and `cc -pthread -fno-builtin -w CFLAGS -o tmp/NAME tmp/NAME.c`. The runtime file list is a variable `nile-runtime` that later tasks append to, in order: `nile-sync.k nile-heap.k nile-deque.k nile-thread.k nile-process.k nile-kernel.k nile-builtins.k`.

- [ ] **Step 1: Write the failing test.** `test/osdefs.k` prints `(sizeof struct nile_Mutex) (sizeof struct nile_Cond) (sizeof struct nile_OSThread)` on one line; `test/osdefs.c` prints `sizeof (pthread_mutex_t)` etc. the same way. Case `nile_osdefs` asserts the two lines are equal (on arm64 macOS both print `64 48 8`).
- [ ] **Step 2:** Run. Expected: FAIL (no `nile.osdefs`).
- [ ] **Step 3:** Write `nile.osdefs`, `nile-sync.k`, `nile-build`.
- [ ] **Step 4:** Run `./eval check/check.l nile_osdefs`. Expected: PASS.
- [ ] **Step 5:** `check/lines`; commit in both repos: `feat(runtime): pthread types sized from nile.osdefs`.

### Task 6: Heap, deque, worker pool, startup and shutdown

**Implements:** [R-startup]

**Files:**
- In `nile`: create `runtimes/maru/nile-heap.k`, `nile-deque.k`, `nile-thread.k`, `test/startup.k`
- Modify: `check/check.l` (case `nile_startup`), `check/lines`

**Interfaces:**
- Consumes: Task 5's sync calls and `nile-build`.
- Produces: `RECORD Block` and `RECORD Worker` from the RFC's data model as structs `nile_Block`, `nile_Thread`; `nile_Heap_push/pop/push_chunk/pop_chunk` matching `runtimes/c/nile-heap.h`; `nile_Deque_push_head/push_tail/pop_head/pop_tail` matching `nile-deque.h`; `nile_Thread_alloc_chunk (t) → Block*` and `nile_Thread_free_chunk (t, c)` with the RFC's steal order; the five public calls `nile_startup`, `nile_shutdown`, `nile_sync`, `nile_status`, `nile_error`, `nile_print_leaks`. `nile_Thread_run (t)` is the worker loop of the RFC's "The worker pool" steps 2–5, with an empty-queue `nile_wait` in place of the C runtime's doubling pause.

- [ ] **Step 1: Write the failing test** `test/startup.k`: for nthreads in 1, 2, 8: allocate 1,000,000 bytes per thread with `malloc`, `nile_startup`, `nile_sync` with nothing launched, assert `nile_error` is 0 and `nile_shutdown` returns the same pointer, then print `startup N ok`. A fourth case passes 100 bytes and prints `startup small ok` if `nile_startup` returns 0. Case `nile_startup` asserts the output is exactly those four lines and `nile_print_leaks` printed nothing.
- [ ] **Step 2:** Run. Expected: FAIL (build error: undefined `nile_startup`).
- [ ] **Step 3:** Implement the three files, following `nile.c`, `nile-thread.h`, `nile-heap.h`, `nile-deque.h` structure for structure. Shutdown sets `SHUTTING_DOWN`, broadcasts every worker's condition variable, joins.
- [ ] **Step 4:** Run `./eval check/check.l nile_startup`. Expected: PASS, well under the 120 s limit.
- [ ] **Step 5:** `check/lines`; commit: `feat(runtime): worker pool with per-worker queues and chunk heaps`.

### Task 7: Processes, the kernel interface, and the limits

**Implements:** [R-recip], [R-vars-fit], [R-element-fits], [R-oom]

**Files:**
- In `nile`: create `runtimes/maru/nile-process.k`, `nile-kernel.k`, the first part of `nile-builtins.k` (PassThrough, Capture, Funnel, `nile_Funnel_pour`), `test/recip.k`, `test/limits.k`, `test/oom.k`
- Modify: `check/check.l` (cases `nile_recip`, `nile_limits`, `nile_oom`), `check/lines`

**Interfaces:**
- Consumes: Task 6's heap and pool.
- Produces: `RECORD Process` as struct `nile_Process` (layout per the RFC; the variable record starts at `nile_Process_memory (p)`); all of the RFC's kernel-interface calls except `prefix_input` and `reroute`; `nile_Process_pipe/feed/gate/pipeline/launch`; `nile_Process_schedule`, `nile_Process_run` internal to the runtime.
- Test kernels are hand-written in typed Maru in the shape the Maru generator emits (`test_Reciprocal_body` with the `(p in i m out j n)` signature).

- [ ] **Step 1: Write the failing tests.**
  - `test/recip.k`: 1,000 pipelines of 7 `Reciprocal` stages (2 reciprocal iterations per element) behind a `Funnel`, each fed the same 1,000 floats from a fixed LCG seed, ending in a `Capture`; asserts each pipeline's sum equals the directly computed sum within 1e-3 relative; prints `recip ok`. Takes the thread count from `argv[1]`, default 1.
  - `test/limits.k`: `nile_Process` with `sizeof_vars` = 512 returns 0 and `nile_status` is `BAD_ARG` (prints `vars-fit ok`); with `in_quantum` = 200 returns 0 with `BAD_ARG` (prints `element-fits ok`); `nile_Process_feed` of 5 floats to a quantum-2 kernel sets `BAD_ARG` (prints `partial-element ok`).
  - `test/oom.k`: startup with one chunk per worker plus 4 blocks, run `recip`'s pipeline; asserts `nile_error` is set and `nile_status` is `OUT_OF_MEMORY`; prints `oom ok`.
  - Cases assert those exact last lines.
- [ ] **Step 2:** Run them. Expected: FAIL (build errors).
- [ ] **Step 3:** Implement, following `nile-process.c` with the new work-function interface replacing `body_t`/`logue_t`; the scheduler states are the RFC's `ProcessState`. Buffer capacity is rounded down to a multiple of the producer's `out_quantum`. `advance_output` never fails (the scratch block on OOM).
- [ ] **Step 4:** Run `./eval check/check.l nile_recip nile_limits nile_oom`. Expected: three PASS. `make check` green.
- [ ] **Step 5:** `check/lines`; commit: `feat(runtime): processes and the new kernel interface`.

### Task 8: Pushing back input and rerouting

**Implements:** [R-prefix], [R-reroute]

**Files:**
- In `nile`: modify `runtimes/maru/nile-kernel.k`; create `test/prefix.k`, `test/reroute.k`
- Modify: `check/check.l` (cases `nile_prefix`, `nile_reroute`), `check/lines`

**Interfaces:**
- Produces: `nile_Process_prefix_input (p, &in, &i, &m)` and `nile_Process_reroute (p, i, j, sub) → status` per the RFC.

- [ ] **Step 1: Write the failing tests.**
  - `test/prefix.k`: a kernel that, for each element `x` at a buffer's start (`i == 0`), pushes back `x + 1000` then reads it again, so output is `x + 1000, x` for buffer-initial elements and `x` otherwise; fed 0..999 (several buffers); asserts the exact expected sequence; prints `prefix ok`. A second case feeds an empty stream to a kernel whose prologue emits `1` and epilogue emits `2`; asserts output `1 2`; prints `empty ok`.
  - `test/reroute.k`: a kernel that passes through elements until it sees `500`, then reroutes to a sub-pipeline that negates; fed 0..999; asserts output `0..499` then `-500..-999`; prints `reroute ok`.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement both calls.
- [ ] **Step 4:** Run `./eval check/check.l nile_prefix nile_reroute`. Expected: PASS.
- [ ] **Step 5:** `check/lines`; commit: `feat(runtime): prefix_input and reroute`.

### Task 9: The remaining built-ins

**Implements:** [R-reverse], [R-sort], [R-dupcat]

**Files:**
- In `nile`: complete `runtimes/maru/nile-builtins.k` (Reverse, SortBy, DupZip, DupCat); create `test/reverse.k`, `test/sort.k`, `test/dupcat.k`
- Modify: `check/check.l` (cases `nile_reverse`, `nile_sort`, `nile_dupcat`), `check/lines`

**Interfaces:**
- Produces: the built-ins with `nile.k`'s signatures, as kernels against the kernel interface, following `nile-builtins.c`.

- [ ] **Step 1: Write the failing tests.**
  - `test/reverse.k`: quantum 2, elements `(k, -k)` for k in 0..N-1 where N fills whole buffers exactly (compute N from the buffer capacity), then a second run with N+1; asserts element-wise reversal for both; prints `reverse ok`.
  - `test/sort.k`: 1,000 elements `(a, b)` from a fixed LCG with `a` in 0..9; `SortBy` field 1 then `SortBy` field 0; asserts sorted on (field 0, field 1) and the multiset of elements unchanged; prints `sort ok`.
  - `test/dupcat.k`: `DupCat` with two PassThroughs on 0..999; asserts output is 0..999 twice; prints `dupcat ok`.
- [ ] **Step 2:** Run. Expected: FAIL.
- [ ] **Step 3:** Implement.
- [ ] **Step 4:** Run `./eval check/check.l nile_reverse nile_sort nile_dupcat`. Expected: PASS.
- [ ] **Step 5:** `check/lines`; commit: `feat(runtime): Reverse, SortBy, DupZip and DupCat`.

### Task 10: Threads, the unlocked-read audit, and ThreadSanitizer

**Implements:** [R-threads], [R-no-races]

**Files:**
- Create: `notes/projects/nile-runtime/unlocked-reads.md`
- In `nile`: modify runtime files the audit names
- Modify: `check/check.l` (cases `nile_threads`, `nile_tsan`), `check/lines`

**Interfaces:**
- Consumes: `test/recip.k` and `test/sort.k` (both take the thread count from `argv[1]`; give `sort.k` that if Task 9 did not).

- [ ] **Step 1: Audit.** List every read of shared state in `runtimes/c/` made without its lock (start from `producer->state`, `p->input.n`, `t->q.n`), with file:line, the owning lock, and where the Maru version reads it under that lock. Note any place that needs two locks and confirm it takes them upstream-before-downstream, process-before-worker.
- [ ] **Step 2: Write the failing tests.** Case `nile_threads`: runs `recip` and `sort` with 1, 2 and 8 threads; asserts every run prints its `ok` line and that each program's printed checksum (add one to both tests: the sum of all outputs, `%.6g`) is the same for all thread counts. Case `nile_tsan`: builds both with `-fsanitize=thread -g` through `nile-build`, runs each with 8 threads, asserts exit 0 and no `WARNING: ThreadSanitizer` in stderr.
- [ ] **Step 3:** Run. Expected: they fail until the audit's changes are made, or pass; either way record the result in the audit note.
- [ ] **Step 4:** Make the audit's changes. Run `./eval check/check.l nile_threads nile_tsan`. Expected: PASS.
- [ ] **Step 5:** `check/lines`; commit in both repos: `fix(runtime): read shared state only under its lock` (or `test:` if no runtime change was needed).

### Task 11: `text-layout.nl` end to end, both targets

**Implements:** [R-text-layout-maru], [R-compiler-boot2]

**Files:**
- Create: `check/nile-text-layout.out` (the reference output)
- In `nile`: create `runtimes/maru/test/print.k` (kernel `test_Print (parent, quantum)` printing each element's floats as `%.4f ` and a newline, as `test/nile-print.h`'s `PrintToFile` does), `runtimes/maru/test/text-layout-main.k`
- Modify: `check/check.l` (case `nile_text_layout`), `check/lines`, `docs/rfc/draft-ndn-nile-runtime-in-maru-01.md` (remove the `**Corpus:**` line), `CLAUDE.md` (Verify list entries for every `nile_*` case; remove "Gezira/GL demos need `libnile`…" only if Gezira is not yet affected, otherwise leave it)

**Interfaces:**
- Consumes: Task 3's compiler script, Task 4's interface, every runtime file.
- `text-layout-main.k` ports `examples/c/text-layout-test.c`: same `glyph_metrics`, `LINE_ORIGIN_X/Y` 5, `LINE_WIDTH` 100, `LINE_HEIGHT` 10, 1,000,000 bytes, 1 thread, `test_Print` in place of `nile_PrintToFile`.

- [ ] **Step 1:** Write `check/nile-text-layout.out` from the C runtime under Rosetta: build `examples/c/text-layout-test.c` against `runtimes/c/` with `cc -arch x86_64 -O2 -I runtimes/c -I examples/c runtimes/c/nile.c runtimes/c/nile-process.c runtimes/c/nile-builtins.c examples/c/text-layout-test.c -lpthread` and run it. Expected: 29 lines, the first `5.0000 5.0000 `. Put the exact command in a comment beside the case in `check/check.l`.
- [ ] **Step 2: Write the failing tests.** `nile_text_layout`: compile `text-layout.nl` with the Maru-target script, `nile-build` it with `print.k` and `text-layout-main.k`, run; assert output equals `check/nile-text-layout.out`.
- [ ] **Step 3:** Run both. Expected: FAIL on the first missing piece; fix it in the task that owns it (and say so in the commit).
- [ ] **Step 4:** Run both until PASS, then `make check` and `rfc-run --expect` (now green with the `**Corpus:**` line removed).
- [ ] **Step 5:** `check/lines`; commit: `test: text-layout.nl end to end on the Maru runtime`.

### Task 12: x86-64 Linux

**Implements:** none new; the RFC's statement that every check also runs natively on x86-64.

- [ ] **Step 1:** On `ndn.lan`, clone the `maru` branch with `--recurse-submodules`, `make eval eval2 osdefs.k`, `make check`. Expected: every case PASS. `nile_osdefs` compares only with `test/osdefs.c`'s line, so it holds for glibc's sizes too.
- [ ] **Step 2:** Fix what fails, each in the task area it belongs to, with a commit per fix. Note anything ThreadSanitizer reports only on x86-64.
- [ ] **Step 3:** Record the result in `notes/projects/nile-runtime/unlocked-reads.md` (one line: date, host, all checks passed).

## Requirement coverage

| Requirement | Task |
|---|---|
| R-lines | 1 |
| R-boot2-strings | 2 |
| R-compiler-boot2 | 3, 11 |
| R-one-interface | 4 |
| R-opaque-pthread | 5 |
| R-startup | 6 |
| R-recip, R-vars-fit, R-element-fits, R-oom | 7 |
| R-prefix, R-reroute | 8 |
| R-reverse, R-sort, R-dupcat | 9 |
| R-threads, R-no-races | 10 |
| R-text-layout-maru | 11 |
