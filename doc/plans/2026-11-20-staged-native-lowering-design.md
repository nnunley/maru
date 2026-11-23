# Staged native lowering: rules that choose their rows once (design)

Status: draft for the user's approval, 2026-11-20. Part of A1 in `doc/plans/2026-11-19-nile-native-on-eval.md`.

## Why

A1's goal is native imaging of the Nile runtime and Gezira on `eval2` within 3 times the C back end's CPU: about 8 s
against its 2.7 s. Today it takes about 32 s, profiled with `eval2 -P` on 2026-11-20 (106,211 instruction forms):

| Phase | CPU | Samples |
|---|---|---|
| front end (`maru.k`) | 3.0 s | ~12% |
| symbols (`native-symbols`) | 0.25 s | ~3% |
| lowering (`native-arm64.g` over each function's intents) | 11.9 s | ~39% |
| assembly (`native-assemble` → `asm`) | 15.2 s | ~45% |
| the image's bytes and function table (`native-image-of`'s tail), outside the phases above | ~1.7 s | |

The front end is the C back end's own front end, so it stays. Everything else has to fit in about 5 s.

The cost is the algorithm, not one hot spot. Each instruction goes through two interpreters in turn, and the second
rediscovers what the first knew:
- **Lowering:** the grammar enters each intent as a stream (`source-parser-stream-of`, `stream-tail`, `stream-at`
  take about two-thirds of lowering's samples), tries its alternatives, and builds a symbolic form such as
  `(ADD X0 X1 X2)`.
- **Assembly:** `asm-table.l` takes the form apart again. It keys the operands' shapes, finds candidate rows, binds
  each row through `arm64-bind-plan`'s chain of conditions, and encodes the word.

The rule `(op add d a b) -> ((ADD ,d ,a ,b))` can only ever mean one row, ADD with three X registers, yet the row is
found again for every instruction. Of 103,227 forms only 7,272 are distinct, and of 69,036 intents 11,179.

Choosing the row when the grammar is built is staged evaluation, evaluation as a series of partial evaluations (oecm
§3.2, claimed in §6 to recover the cost of the evaluator's indirection; `notes/sources/piumarta-2011-open-extensible-composition-models.md`
records the claim as asserted, not shown; §5.1 is grounding, cited here before 2026-11-21 by mistake). The kernel plan already has it as Task 7 (`doc/plans/2026-11-12-kernel-on-eval3.md` on the
kernel branch, 17ea055; Binders and LoweringSites in its `notes/plan/assembler.john`). This design does Task 7 now, on
this branch, and adds the lowering half Task 7 left out, since lowering is 39% here.

## Goals

- `native_nile`'s bound tightened from 16 to 3: native imaging within 3 times the C back end's CPU, in the same case.
- Every native image the same, byte for byte, as today's: the Gezira unit's, and `native_ir2`'s and `native_image`'s
  units.
- Work that carries over to the kernel unchanged (the plan's rule for Part A): Task 7's sites and binders, and a tree
  grammar compiler that every tree grammar benefits from.

## Non-goals

- x86-64. `native-x64.g` keeps today's path. Its rows aren't compiled plans yet (Task 7's Open note).
- The front end's 3 s, and `eval2` itself.
- Hand-written assembly. `asm-table.l` stays the general encoder, and `asm_table`'s stream keeps testing it.
- Erasing accessor checks (a later pass in the metacircular environment, per the user on 2026-11-20).

## Anti-goals

- **A cache in place of the algorithm.** Remembering each form's bytes or each intent's lowering was measured as an
  option. It would reach about 3.5 times, short of the goal, and it doesn't carry over to the kernel.
- **Rules written twice.** `native-arm64.g` stays the one place the lowering is written. Nothing hand-writes a second
  dispatch table beside it.
- **A changed refusal.** An instruction a site can't encode reaches `asm` as today and is refused with today's
  message.
- **Different bytes** under any input. A site that isn't sure falls back to the symbolic form.

## Approaches

1. **Cache by form and by intent.** Each distinct form is encoded once and its bytes copied after that; each distinct
   intent is lowered once, except `branch-if`/`branch-unless`, whose labels must be fresh. Small and local, but every
   instruction still pays for hashing a whole form or intent, and the estimate is 9 to 10 s, about 3.5 times.
   Ruled out: it misses the goal and doesn't carry over.
2. **Staged rules (chosen).** Lowering rules dispatch on the intent's head and match their list directly, and each
   rule's rows are resolved when the grammar is built, so a rule emits its bytes. Estimated at 6 to 7 s, about 2.5
   times. The user chose this on 2026-11-20 ("yes, write the design" after the comparison).
3. **Hand-written lowering in Maru** (a `case` on the intent's head, emitting words). Fastest to write, but it is the
   second copy of the rules this design refuses, and it works against the grammar engine's direction
   (`doc/plans/2026-11-09-grammar-engine.md`). Ruled out.

## The design

### Part 1: Binders (Task 7, step 1, as written there)

`arm64-bind-plan` picks each operand kind's handling through one chain of conditions (CC 71, the assembler's highest).
When a row is compiled, each operand kind's plan becomes a binder of its own: `arm64-plan-kind` answers a function of
`(plan op vals pc)` with its slots closed over. The plan's binder is the dispatch, and encoding no longer tests the
kind. This is dispatch by type, and it speeds every encode, including `asm`'s general path that sites fall back to.

Gate, from Task 7 step 1: the same bytes and reports for every arm64 sample, placeholder variants included (the sweep
over `check/asm-table.l`'s stream). `asm_table`, `asm_rows_arm64`, `asm_patch` and `asm_coverage` pass.
`arm64-bind-plan`'s CC 71 leaves erosion's time sinks, ledgered. It is committed on its own, with Task 7's message
"asm-arm64: each operand kind binds through its own compiled binder".

### Part 2: List patterns matched directly (the lowering half)

`compile-tpeg.l` compiles a list pattern by entering the list as a stream on the parser (`tp-list-pattern`), so that
memos and backtracking work inside it. Most tree patterns don't need that. A **direct pattern** is a list pattern
whose items are each one of:
- a quoted atom;
- `.` or `.:name`;
- a rule applied to one element, where the rule is itself direct, e.g. `reg = .:r -> (stub-reg 'arm64 r)`;
- with nothing after them but the list's end.

A direct pattern compiles to a check of the list's length and atoms, then `car`/`cdr` bindings, with a direct rule's
action applied to its element. No stream is made and nothing is memoised. A pattern that isn't direct compiles as
today. `tp-choice`'s head dispatch (36b3b9b) already narrows the alternatives, so a choice of direct patterns becomes
the head's dispatch followed by one direct match.

This lives in the tree grammar compiler, not in `native-arm64.g`. Every tree grammar with such patterns gains,
erosion's `maru-forms.g` among them, and the grammar stays the one source. Every `native-arm64.g` intent rule is
direct.

**What a direct match does** (my call, keeping today's semantics):
- A direct pattern tests everything first: the list's length, its atoms, and each direct sub-rule's own tests. Only
  when all of them pass does it bind, apply the sub-rules' actions to their elements, and run the alternative's
  action. That action runs once, exactly as a successful stream match runs it.
- On failure nothing has run. The choice falls through to its next alternative, as today.
- A sub-rule is direct only if its action has no side effects (`reg`'s `stub-reg` is a lookup). An alternative's own
  action may have side effects (`native-arm64-enter` sets the frame), because it runs only after the match succeeds,
  as today.
- Memos are skipped only inside direct patterns. Nothing in them is matched twice at one position, so there is
  nothing to remember.

Gate: a new check, `tpeg_direct`, holds every tree grammar in the tree to the same results both ways, `native-x64.g`
included. Part 2 changes the compiler `native-x64.g` shares, so x64's output must stay the same even though x64 gets
no sites (my call). For the two native grammars that means the same forms for every intent of the Gezira unit and of
`native_ir2`'s units. `native_ir2_x64` and the existing tree grammar checks pass unchanged.

### Part 3: Lowering sites (Task 7, steps 2 to 7)

A **site** is a lowering rule's output form whose mnemonic is fixed and whose operands' kinds the rule declares: X
register, W register, slot offset, constant. Its candidate rows are resolved once, when the grammar is built, and kept
with the rule. At run time the rule binds its operands' values into those rows' plans, using Part 1's binders, and
emits the four bytes as `(data b0 b1 b2 b3)`, which `asm` already passes through.

- **Declaring kinds.** A rule's registers come through `reg` (`stub-reg`), so they are X registers unless the rule
  says otherwise. How a rule declares a W register, a slot offset or a constant is the builder's choice: Task 7 says
  only that the site carries "the operand kinds it declares". It must be read from `native-arm64.g` or the helpers it
  calls, not from a second table.
- **Rules that compute their forms** (`native-arm64-load`, `-store`, `-call`, `-enter`, `-params`, `-result`,
  `-copy`, `-address`, `-fop`, `-fcompare`, `-convert`, `arm64-constant`). The helper's mnemonics are its sites. A
  choice that depends on a value, such as whether an offset fits, is narrowed to the site's two or three rows when the
  grammar is built and settled at run time among those.
- **Every operand kind a row's plan binds can appear in a site** (my call): registers, shifts (`MOVK`'s `(LSL 16)`),
  addressing modes (`enter`'s `(pre SP -16)`, `leave`'s `(post SP 16)`, `(off base n)`), conditions (`CSET`) and
  immediates. A site binds its operands through Part 1's binders with the chosen row's plan, so any kind those
  binders handle works. The declared kinds serve only to choose the rows when the grammar is built.
- **Float intents** (`fop`, `fcompare`, `convert`) are sites too (my call). Their width and kind are among a closed
  set (32 or 64 bits, the float operations), so each combination resolves its row or two when the grammar is built.
  This keeps the choice narrow, as Task 7 asks.
- **Not sites.** Branches, `(label L)` operands, `branch-if`/`branch-unless` (fresh labels), a far slot offset taking
  the X15 path if it can't be resolved, and anything a site can't encode. These keep today's path, the symbolic form
  through `asm`. The 5% is measured: 5,555 of the Gezira unit's 103,227 forms carry a label. It assumes every other
  form is a site, so a kind left out raises it, and `native_sites` reports the share each run.
- **Order, from Task 7.** The failing check first. Then `op` intents, then `load` and `store`, then the remaining
  intents `asm_coverage` lists. A step is kept only if the whole compile is faster on both `eval2` and `eval3` (best
  of five interleaved runs, CPU time by `clock`).
- **The check** (Task 7 step 2, extended): `native_sites` compiles `maru-gc.k`, `maru-check.k`, `check/ir2.k` and the
  Gezira unit with sites on and off. The images must be byte for byte the same, and each must run as `native_ir2`
  asks. "Off" exists only for this check.

### Part 4: The image's tail, if still needed

`native-image-of` copies the buffer into a list byte by byte (412,908 bytes), then builds the function table. If the
total is still over 3 times after Part 3, this is next: the list is built from the buffer in one pass, or
`native-form-text` reads the buffer's bytes directly. Measured first, kept only if it pays.

### Closing A1

Timing (my call):
- A step is kept on best of five interleaved runs, CPU time, as Task 7 says.
- A1 closes on `native_nile`'s own ratio: both back ends timed in the same case by `/usr/bin/time -p`, never a
  constant 2.7 s. It must hold under 3 on three runs on a quiet machine.
- Then the bound becomes 3. A1 closes with the full suite green and a whole-branch review. The doc changes go in `doc/native.md`,
`doc/assemblers.md`, `doc/grammars.md` (direct patterns), `render.john`'s `NativeNileCompiles`, and the plan's A1
section.

## Estimate (to be measured, not promised)

Per intent: about 15 µs of interpreted work on `eval2` (head dispatch, direct match, two or three `stub-reg`s, one
word assembled from its fields, one `data` form). That is about 1 s of lowering. Passing `data` forms through `asm`
adds about 0.5 s, and the 5% left on the general path, sped up by Part 1, adds about 1 s. With the front end (3 s),
symbols (0.25 s) and the image's tail (1.7 s, or less after Part 4), the total is 6 to 7.5 s, or 2.3 to 2.8 times.
The margin under 3 is thin, so Part 4 and the accessor checks on derived types (about 9% of samples, mostly the
parser's, which Part 2 removes) are the reserves.

## Constraints

- Code in Maru languages (`.l`, `.k`, `.g`), never C. `eval2.c` doesn't change.
- Dispatch by type, and tables from `hash.l`. No alists for new lookups.
- Each step is a checkpoint commit at green, with ledger entries in `check/lines` and `check/erosion`.
- Long runs under `caffeinate -i`, one suite at a time. Timings by CPU time (`clock`, or `/usr/bin/time -p`).
- Byte identity of native images is the oracle for this work (images are machine code, so identical bytes are the
  behaviour), alongside running them.

## The kernel plan

This work does Task 7's steps on this branch. The kernel worktree has uncommitted work that isn't this session's to
touch, so its plan file isn't edited from here (my call). This branch's commits and ledgers record the work. When the
kernel branch takes main, its owner marks Task 7's steps as done there, citing this design.

## Left to the builder

- How a rule declares an operand's kind (Part 3), within "read from the grammar or its helpers, not a second table".
- How a site's rows are kept with the rule (in the compiled grammar, or a table keyed by rule built at load).
- The exact boundary of "direct" in Part 2, so long as every `native-arm64.g` intent rule falls inside it and nothing
  outside it changes behaviour.
- Whether `tpeg_direct` runs both compilations in one process or compares saved results.
