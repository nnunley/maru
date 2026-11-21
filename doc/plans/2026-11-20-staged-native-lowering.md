# Staged Native Lowering Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Native imaging of the Nile runtime and Gezira on `eval2` within 3 times the C back end's CPU (`native_nile`'s
bound from 16 to 3), every native image the same byte for byte.

**Architecture:** Three changes, each kept only if it pays:
1. Each arm64 operand kind binds through its own compiled binder (Task 7 step 1 of the kernel plan).
2. Tree grammars match fixed-shape list patterns with `car`/`cdr` instead of entering a stream.
3. Lowering rules and helpers name their instructions as sites, whose rows are chosen when the grammar is loaded, so
   they emit `(data b0 b1 b2 b3)`.

The general path (`asm`) stays for everything a site can't take.

**Tech Stack:** Maru: `eval2`, `eval3`, `compile-tpeg.l`, `asm-table.l`/`asm-arm64.l`, `native.l`/`native-link.l`,
`check/check.l`.

**Spec:** `doc/plans/2026-11-20-staged-native-lowering-design.md` (approved 2026-11-20). Kernel plan Task 7:
`doc/plans/2026-11-12-kernel-on-eval3.md` on the kernel branch (17ea055); read it there, don't edit it.

## Global Constraints

- Code in Maru languages (`.l`, `.k`, `.g`), never C. `eval2.c` doesn't change.
- Dispatch by type, and tables from `hash.l`. No alists for new lookups.
- Each step is a checkpoint commit at green, with ledger entries in `check/lines` and `check/erosion`.
- Long runs under `caffeinate -i`, one suite at a time. Timings by CPU time (`clock`, or `/usr/bin/time -p`).
- Byte identity of native images is the oracle for this work, alongside running them.
- x86-64 gets no sites, but `native-x64.g`'s output must stay the same (it shares `compile-tpeg.l`).
- A refusal's message is unchanged: anything a site can't encode reaches `asm` as a symbolic form.
- A step is kept only if the whole compile gets faster on both `eval2` and `eval3`. That means `maru-check.k`'s
  compile, best of five interleaved runs, CPU by `clock`, plus the Gezira unit on `eval2`.
- Never touch the root checkout (/Users/ndn/development/maru) or the kernel worktree. Use `git -C` with absolute paths,
  never `git stash`. Commits carry no AI attribution. Restore `notes/plan/*.answers` after checks; never commit them.

## Review Focus

1. **A register whose shape differs from the site's declared kind** (SP or XZR where an X register was declared, a W
   register in an X site). Expected: the site falls back to the symbolic form, so the bytes match `asm`'s. Pinned in
   Task 4.
2. **An immediate out of a site's rows' range** (a slot offset past 4095×size, a negative or unaligned offset, a
   constant needing MOVK). Expected: today's helper logic still picks the far path; a site that binds no row falls
   back. Pinned in Tasks 4 and 5.
3. **A list element that isn't a list**, where a direct pattern expects one: a symbol, a string (`in-enter` holds for
   strings, which stream as characters), or `()`. Expected: the same result as the stream path. Pinned in Task 3.
4. **An alternative whose action has side effects, after an earlier alternative failed partway** (the `enter` intent
   sets `native-arm64-frame`). Expected: the action runs once, only for the alternative that matched. Pinned in
   Task 3.
5. **A grammar that overrides `in-same` or `in-enter`.** Expected: direct matching calls the same selectors the
   stream path does, so the override still governs. Pinned in Task 3.

---

### Task 1: Images by unit, and the reference taken before any change

**Files:**
- Create: `check/native-images.l`
- Modify: `check/check.l` (factor the native_nile loader into `native-nile-loader`, returning its path)

**Interfaces:**
- Produces: `./eval2 check/native-images.l [--no-sites] DIR [GEZIRA-LOADER]`. `--no-sites` sets `*arm64-sites*` to
  `()` before `native.l` loads (Task 4 defines it; until then the flag is accepted and does nothing). It writes `DIR/NAME.image` (`native-save`'s text)
  for each unit in `native-image-units`: `maru-gc.k`, `maru-check.k`, `check/ir2.k`, and every `check/native/*.k` that
  `check/native.l` compiles and that compiles without error (the `objects-bad-*` and `objects-duplicate-*` units are
  meant to be refused; they are left out). With a loader, it also writes `DIR/gezira.image`. The last line is
  `images N`.
- Produces: `native-nile-loader` in `check/check.l`, returning the loader path that `native_nile` builds today. Later
  tasks call it.
- Produces: the reference images, made from BASE (the commit this plan starts from), in
  `$TMPDIR/staged-ref/`. They are scratch, not committed.

- [ ] **Step 1: Write `check/native-images.l`** to the interface above. `define dir (pop *arguments*)` before
  `(require "native.l")`, as `check/native-image-save.l` does.
- [ ] **Step 2: Run it at HEAD.** Run `caffeinate -i make -s check CHECKS=native_nile` once. The loader it leaves is
  `/tmp/maru-check/_Users_ndn_development_maru_.worktrees_nile-native-eval/native_nile/native-nile.k`, called LOADER
  below.
  Run: `caffeinate -i ./eval2 check/native-images.l $TMPDIR/staged-head LOADER`
  Expected: last line `images N` with N ≥ 20, and `gezira.image` about 1 MB of text.
- [ ] **Step 3: Take the reference from BASE.** Add a worktree with `git -C <wt> worktree add $TMPDIR/staged-base
  BASE`, copy `check/native-images.l` into it, build `eval2` there, and run Step 2's command with DIR
  `$TMPDIR/staged-ref`. Then remove the worktree.
  Expected: `cmp -r`-equal to `$TMPDIR/staged-head`, file for file, since nothing has changed yet.
- [ ] **Step 4: Commit**
  `git add check/native-images.l check/check.l check/lines check/erosion`, message
  `test(native): images by unit, for comparing native code across changes`.

### Task 2: Binders (Task 7 step 1)

**Files:**
- Modify: `asm-arm64.l:189-306` (`arm64-plan-kind`, `arm64-bind-plan`, `arm64-encode-row`)

**Interfaces:**
- Produces: `(arm64-plan-kind slots k)` answers a **binder**, a function `(lambda (plan op vals pc) …)` answering
  `vals` or `()`. Its slots and sub-binders (for `mreg`, `vlane` and the tag forms) are closed over.
  `<arm64-plan>-kinds` holds binders. `arm64-encode-row` calls `((car kinds) plan op vals pc)`.
  `arm64-bind-plan` is removed.
- Consumes: nothing new.

- [ ] **Step 1: Record the encoder's answers before the change.** Run `./eval check/asm-table.l arm64` with a
  temporary line at its end that prints every stream instruction's `asm-attempt` result. Use the same printing as
  the check's comparison: bytes and reports, or the error. Save the output to `$TMPDIR/sweep-before.txt` and remove
  the line.
  Expected: about 10,000 or more lines.
- [ ] **Step 2: Implement the binders.** One binder maker per tag of today's `arm64-bind-plan` `cond`: reg, vreg,
  vlane, vshl/vshr, bimm, lslimm, fimm, cond, invcond, mreg, imm0, the reloc placeholder (imm, simm, pcrel, pcpage
  with an `arm64-reloc?` operand), imm/simm/pcrel/pcpage/lsl, and the tag pair. Dispatch on the kind's head once, in
  `arm64-plan-kind`. Each binder does exactly what its `cond` arm did. The reloc arm and the value arm of
  imm/simm/pcrel/pcpage are one binder that tests `arm64-reloc?` first, as the `cond` order does.
- [ ] **Step 3: Compare.** Rerun Step 1's sweep to `$TMPDIR/sweep-after.txt`.
  Expected: `cmp` equal.
- [ ] **Step 4: Run the gates.**
  Run: `caffeinate -i make -s check CHECKS="asm_table asm_rows_arm64 asm_patch asm_coverage native_ir2 native_image erosion lines"`
  Expected: all PASS. If erosion moved, the entry says `arm64-bind-plan`'s CC 71 left the time sinks.
- [ ] **Step 5: Images and time.**
  - Run `check/native-images.l` to `$TMPDIR/staged-t2`. Expected: `cmp -r` equal to `$TMPDIR/staged-ref`.
  - Time `maru-check.k`'s compile, best of five interleaved runs, BASE against HEAD, on `eval2` and `eval3`. Expected:
    no slower on either.
- [ ] **Step 6: Commit**, with Task 7's message `asm-arm64: each operand kind binds through its own compiled binder`
  in Conventional form: `perf(asm-arm64): each operand kind binds through its own compiled binder`. Include the
  ledgers.

### Task 3: List patterns matched directly

**Files:**
- Modify: `compile-tpeg.l:117-133` (`tp-list-pattern`), plus a predicate for direct patterns and direct rules
- Modify: `check/tpeg-lists.g`, `check/tpeg-lists.l` (cases)
- Create: `check/tpeg-direct.l`
- Modify: `check/check.l` (`tpeg_direct` case), `doc/grammars.md`

**Interfaces:**
- Produces: `*tp-direct*`, a global in `compile-tpeg.l`, default `1`. Compiling with it `()` gives today's code. Only
  `tpeg_direct` sets it.
- Produces: a **direct pattern**, a `match-list` whose nested `match-all` items are each one of:
  - `match-object` of an atom;
  - `match-any`;
  - `assign-result` of either of those;
  - `match-rule` (or its `assign-result`) of a **direct rule**, a rule with no parameters whose whole expression is
    `.:v -> EXPR` (one element bound, one action).
  Nothing may come after the last item but the list's end.
- Compiled direct code, for a value `v` in front of the parser:
  1. If `v` is a pair or `()` and `in-enter` holds, walk `v` with `car`/`cdr`.
  2. Test each literal with the same operation `match-object` uses (`in-same`), and test the length exactly.
  3. Only when every test passes, bind the names and apply each direct rule's action to its element. Set
     `self.result` and advance `self.position` as the stream code does.
  4. Otherwise answer `()` with the position unchanged.
  - Any other `v` (a string, an array) takes today's stream code, which is kept in the same expansion.
- Produces: `./eval2 check/tpeg-direct.l`. It builds `native-arm64.g` and `native-x64.g` both ways, lowers every
  intent of the units in `native-image-units` plus the Gezira loader (an argument) both ways, and compares. The last
  line is `tpeg direct ok`.

- [ ] **Step 1: Write the failing cases** in `check/tpeg-lists.g` and `check/tpeg-lists.l`. Each expects the stream
  path's result:
  - `( 'p .:a .:b )` against `(p 1 2)` gives `(1 2)`, and against `(p 1)` and `(p 1 2 3)` fails.
  - A choice of `( 'k .:x ) -> (incr n)` then `( 'k .:x .:y ) -> (incr m)`, against `(k 1 2)`: `n` is 0 and `m` is 1.
    The first alternative's action never ran.
  - A direct pattern against the string `"pq"`, the symbol `p`, and `()` gives the same result as with
    `*tp-direct*` off.
  - A grammar whose `in-same` treats `'any` as matching every symbol matches `( 'any .:x )` against `(zz 1)` both
    ways.
  - The case file prints `direct` once the cases pass, and asserts that the compiled `$p` contains no
    `source-parser-stream-of` when `*tp-direct*` is on.
- [ ] **Step 2: Run them and see the last assertion fail.**
  Run: `caffeinate -i make -s check CHECKS=tree_lists`
  Expected: FAIL on the no-stream assertion only.
- [ ] **Step 3: Implement direct patterns** in `compile-tpeg.l` to the interface above.
- [ ] **Step 4: Write `check/tpeg-direct.l` and its case** in `check/check.l`, after `native_nile`, using
  `native-nile-loader`. Compare the lowered forms per function with `equal`. Report the first differing intent and
  both lowerings if any.
- [ ] **Step 5: Run the gates.**
  Run: `caffeinate -i make -s check CHECKS="tree_selectors tree_source tree_lists tree_args tree_apply tree_memo tree_foreign tree_literals tree_calc tpeg_direct native_ir2 native_ir2_x64 native_image erosion lines"`
  Expected: all PASS, with erosion's numbers unchanged apart from ledgered moves.
- [ ] **Step 6: Images and time.**
  - Run `check/native-images.l` to `$TMPDIR/staged-t3`. Expected: equal to the reference.
  - Time as in Task 2, Step 5. Expected: faster on both evaluators, and lowering's share of the Gezira unit lower than
    11.9 s.
- [ ] **Step 7: Commit**, with `doc/grammars.md` describing direct patterns and the ledgers. Message:
  `perf(tpeg): list patterns of a fixed shape matched directly, without a stream`.

### Task 4: Sites, with the failing check first; `op` and `compare` intents

**Files:**
- Modify: `asm-arm64.l` (site maker and emitter, after the registration section)
- Modify: `native-arm64.g` (the `op` and `compare` rules)
- Create: `check/native-sites.l`
- Modify: `check/check.l` (`native_sites` case)

**Interfaces:**
- Produces: `*arm64-sites*`, a global, default `1`. With it `()`, every site expands to its symbolic form. Only
  `native_sites` sets it, and it must be set before `native.l` loads.
- Produces: the form `(arm64-site MNEMONIC SPEC…)`, a `define-form` in `asm-arm64.l`. Each SPEC is either:
  - a literal operand (a symbol such as `SP`, a number, or a quoted list such as `'(post SP 16)`); or
  - `(KIND EXPR)`, with KIND one of `x` (an X register), `w` (a W register), `n` (a number), `f` (an FP register of
    the width named by a literal `s` or `d`: `(f s EXPR)`), `mem` (a memory operand, whose representative is the
    literal shape passed with it: `(mem (off X0 0) EXPR)`), `lsl` (an `(LSL n)` operand), or `c` (a condition
    symbol, representative `EQ`).
  At expansion, which is when the grammar or helper loads:
  1. A representative instruction is built from each SPEC: X0, W0, 0, S0/D0, the given memory shape, `(LSL 0)`.
  2. The site's candidate rows are resolved with `asm-candidate-rows`.
  3. Each spec's `arm64-shape-key` is recorded.
  4. A site whose rows include a `pcrel` or `pcpage` kind is an error at expansion.
  5. A site with no `(KIND EXPR)` spec encodes once, here, to a constant `(data …)`.

  At run time the site:
  1. computes each variable operand's `arm64-shape-key` and compares it with the recorded one;
  2. tries the rows in order with `arm64-encode-row` at pc 0;
  3. answers `(data b0 b1 b2 b3)` (little-endian, as `arm64-encode` orders them) for the first row that encodes;
  4. answers the symbolic form `(MNEMONIC op…)` when a key differs or no row encodes.
- Produces: the `native_sites` case in `check/check.l`. It runs `check/native-images.l` into `DIR/on`, then again
  with `--no-sites` into `DIR/off`, with the Gezira loader from `native-nile-loader`, and requires `cmp -r` to find
  them equal. Then it runs `./eval2 check/native-sites.l LOADER`, which holds the site cases below and prints the
  share of forms that went through a site (`sites N of M forms`, counted on the Gezira unit). Its last line is
  `native sites ok`.

- [ ] **Step 1: Write `check/native-sites.l` and the `native_sites` case.** Its assertions:
  - every image is the same both ways (the case's `cmp -r`);
  - the site share is above 0;
  - an `arm64-site ADD (x d) (x a) (x b)` with `d` = `SP` answers the symbolic form;
  - `(n v)` in an `ADD` immediate site with v = 4096 and with v = -1 answers the symbolic form, or the same bytes
    `asm` gives;
  - a constant site such as `(arm64-site RET)` answers `(data 192 3 95 214)`.
- [ ] **Step 2: Run it and see it fail.**
  Run: `caffeinate -i make -s check CHECKS=native_sites`
  Expected: FAIL, `arm64-site` undefined.
- [ ] **Step 3: Implement `arm64-site`** to the interface above.
- [ ] **Step 4: Use it in `native-arm64.g`'s `op` rules and `compare`.** For example `(op add reg:d reg:a reg:b) ->
  (list (arm64-site ADD (x d) (x a) (x b)))`. For `compare`, `CMP` and `CSET`'s condition is `(native-arm64-cond c)`,
  a literal symbol per call: `CSET`'s condition is a `(c EXPR)` spec.
- [ ] **Step 5: Run the gates.**
  Run: `caffeinate -i make -s check CHECKS="native_sites tpeg_direct native_ir2 native_image asm_coverage erosion lines"`
  Expected: all PASS.
- [ ] **Step 6: Images and time** as in Task 3, Step 6 (`$TMPDIR/staged-t4`). Keep only if faster on both
  evaluators.
- [ ] **Step 7: Commit**, message `perf(native-arm64): op and compare rules choose their rows once`.

### Task 5: Sites in loads, stores and addresses

**Files:**
- Modify: `native.l:21-60` (`native-arm64-access`, `-load`, `-store`, `-address`, `-piece`)

**Interfaces:**
- Consumes: `arm64-site` with `x`, `w` and `mem` specs (Task 4).
- Produces: each `(list 'LDR r place)`-style form in these helpers becomes an `arm64-site`, one per mnemonic and
  memory shape:
  - `(mem (off X0 0) place)` for a near offset;
  - the far path (X15) as today, with its forms as sites too.
  `native-arm64-far?` still decides near or far, unchanged.

- [ ] **Step 1: Add the assertion** to `check/native-sites.l`: a load at offset 32768 of size 8 (far) and at offset 12
  of size 8 (unaligned) give the same bytes both ways.
- [ ] **Step 2: Run it and see it pass at once.** The sites aren't used yet, so both ways are the same path. Note it
  in the ledger as a guard, not a red test.
- [ ] **Step 3: Convert the helpers.**
- [ ] **Step 4: Gates** as in Task 4, Step 5.
- [ ] **Step 5: Images and time** (`$TMPDIR/staged-t5`). Keep only if faster.
- [ ] **Step 6: Commit**, message `perf(native-arm64): loads, stores and addresses choose their rows once`.

### Task 6: Sites in the remaining intents

**Files:**
- Modify: `native-arm64.g` (`leave`, `return`, `branch-to`, and the `function-address` rule stays as it is, since it
  has a label)
- Modify: `native.l` (`-enter`, `-params`, `-call`, `-result`, `-copy`, `-fop`, `-fcompare`, `-convert`)
- Modify: `stub.l` (`arm64-constant`, for MOVZ/MOVK with `lsl`)

**Interfaces:**
- Consumes: `arm64-site` (Task 4), including the `f`, `lsl` and `c` kinds.
- Produces: every non-branch, non-label form the lowering emits is a site. `native_sites`' share reaches at least 90%
  of the Gezira unit's forms (5,555 of its 103,227 carry a label).

- [ ] **Step 1: Raise `native_sites`' expectation** to a share ≥ 90% for the Gezira unit, and add a float unit
  (`check/native/floats.k`) to the units compared.
- [ ] **Step 2: Run it and see the share assertion fail.**
- [ ] **Step 3: Convert the helpers and rules**, one commit per group if a group fails to pay on its own: frame
  (`enter`, `leave`, `params`, `result`), calls, copies, floats, constants.
- [ ] **Step 4: Gates**:
  `caffeinate -i make -s check CHECKS="native_sites tpeg_direct native_ir2 native_ir2_x64 native_image asm_coverage catch recover erosion lines"`.
  `catch` and `recover` run the stubs that `stub.l`'s `arm64-constant` builds.
  Expected: all PASS.
- [ ] **Step 5: Images and time** (`$TMPDIR/staged-t6`). Keep only if faster.
- [ ] **Step 6: Commit**, with `doc/assemblers.md` and `doc/native.md` describing sites. Message:
  `perf(native-arm64): lowering rules choose their rows once`.

### Task 7: Measure, and the image's tail if needed

**Files:**
- Modify (only if needed): `native-link.l:74-95` (`native-image-of`), `native-link.l:100-117`

**Interfaces:**
- Produces: the phase timings of the Gezira unit, and `native_nile`'s ratio on three quiet runs.

- [ ] **Step 1: Profile.** Run `eval2 -P` and the phase timer over the Gezira loader, as in the design's table.
  Record the five rows in the ledger.
- [ ] **Step 2: Decide.**
  - If `native_nile`'s ratio is under 3 on three runs, go to Task 8.
  - Otherwise, the largest remaining phase is next. If that is `native-image-of`'s tail, build the byte list from the
    buffer in one pass, or have `native-form-text` read the buffer's array directly. Gate it with `native_image`,
    `native_nile` and image identity.
  - If the ratio still isn't under 3, stop and report the table to the user. Don't loosen the goal.
- [ ] **Step 3: Commit** whatever paid, message `perf(native): …` naming it.

### Task 8: Close A1

**Files:**
- Modify: `check/check.l` (`native_nile`: `(* 16 c)` becomes `(* 3 c)`, and the comment states the new figures)
- Modify: `doc/native.md`, `doc/plans/2026-11-19-nile-native-on-eval.md` (A1 marked done, with the figures),
  `notes/plan/render.john` (`NativeNileCompiles`' text)

- [ ] **Step 1: Tighten the bound** to 3 and run `native_nile` three times on a quiet machine.
  Expected: PASS all three times, with the printed ratio under 3.
- [ ] **Step 2: Full suite.**
  Run: `caffeinate -i make -s check`
  Expected: `all checks passed`.
- [ ] **Step 3: Whole-branch review** by a fresh reviewer, with this plan's Review Focus. Fix Critical and Important
  findings test first.
- [ ] **Step 4: Commit**, message `test(native): native_nile within 3 times the C back end; A1 done`. Show the user
  the figures before fast-forwarding main.
