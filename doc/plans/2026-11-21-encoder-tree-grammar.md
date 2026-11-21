# Encoder Tree Grammar Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (the user chose native execution for
> this work) to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** arm64's encoder as a tree grammar whose rules are the rows of `arm64.spec`, and `arm64-sites` a specialiser
that composes lowering's templates with it as the grammar loads, leaving residual code (guards, then one OR of
shifted fields) in place of today's representatives, shape keys and memo; every native image the same.

**Architecture:** Operand rules (one per operand kind, hand-written) in a parent grammar; the rows' rules generated
from `arm64.spec` by a Maru build step and registered with `grammar.l` as data. `asm_grammar` holds the compiled
grammar equal to `asm` over `asm_table`'s arm64 stream. The specialiser reads rule definitions (never compiles or
interprets them per instruction) and writes plain Maru, which `arm64-sites` expands to. Then the old site machinery
goes, the memo with it.

**Tech Stack:** Maru: `compile-tpeg.l`, `grammar.l`, `asm-table.l`, `asm-arm64.l`, `native.l`, `native-link.l`,
`check/check.l`.

**Spec:** `doc/plans/2026-11-21-encoder-tree-grammar-design.md` (approved 2026-11-21).

## Global Constraints

- Native images byte for byte as today: `check/native-images.l` against the reference, `native_sites` (on/off),
  `native_image`, `native_ir2`, `tpeg_direct`, `native_ir2_x64`.
- `asm`'s refusal text unchanged; a hole a residual can't take answers the symbolic form for `asm`.
- Code in Maru languages (`.l`, `.k`, `.g`), never C. Dispatch by type, `hash.l` tables, no alists for new lookups.
- `./eval` resolves a function's globals when it is defined: run `maru-refactor order-check` on every Maru file a
  task changes, and across `hash.l asm-table.l asm-arm64.l stub.l native.l native-link.l` in load order.
- `native.l`'s load must not bring in `compile-tpeg.l`; `native-image.l` still loads with no grammars.
- A step that should be faster is kept only if `ab-cpu --require-ac` says so (interleaved, best and median, on the
  `native_nile` loader's lowering, `--metric-regex '^lower (\d+) ms'`, and on `maru-check.k` for `eval3`).
- Each task ends at green with ledger entries (`check/lines`, `check/erosion`) and a Conventional Commit, no AI
  attribution. Restore `notes/plan/*.answers` after checks; never commit them.
- Timings only on AC power with low-power mode off (`pmset`; the tools' `--require-ac`), and recorded with `--ledger`.
- Maru edits that move or add definitions go through `maru-refactor`; no inline Python edit scripts.

## Review Focus

1. **A row dropped wrongly by "shares a leaf"** while a later kept row also fits: the bytes change. Expected: the kept
   rows include every row `asm-candidate-rows` gives today's representative, in order. Pinned in Task 3.
2. **XZR, SP or a W register in an `x` hole**, and an immediate at a field's edge. Expected: the residual answers the
   symbolic form or the bytes `asm` gives. Pinned in Task 3 (native-sites cases).
3. **A label row whose field range ties another**: `asm-best-row` keeps the first among equals. Expected: `.open`
   rules sorted stably. Pinned in Task 2 (`asm_grammar` over placeholder variants).
4. **A NEON or arrangement row** in a mnemonic's choice. Expected: its escape rule calls `arm64-encode-row`, so the
   grammar equals `asm` on every row. Pinned in Task 2.
5. **Load order on `eval`**: `catch` and `recover` run sites on `eval` through `stub.l`. Expected: they pass after
   every task. Pinned in each task's gates.

---

### Task 1: Operand rules

**Files:**
- Create: `arm64-operands.g` (grammar `<arm64-operands> : <source-parser> ()`), built to `arm64-operands.g.l` by make.
- Modify: `Makefile` (the `.g.l` rule and `check`'s prerequisites), `asm-arm64.l` (helper functions the rules call).
- Test: `check/arm64-operands.l`, case `arm64_operands` in `check/check.l`.

**Interfaces:**
- Produces: one rule per distinct operand kind info (`arm64-kind-info`'s tag and parameters): a rule of one element
  answering the field value, or failing (never answering `()` as a value; 0 is a value). Names are letters and
  digits: the register kinds by class and SP/ZR kind (`xr`, `xsp`, `xzr`, `wr`, `wsp`, `wzr`, `sr`, `dr`, …), the
  number kinds by tag, width and scale (`imm12`, `imm12s8`, `simm9`, `pcrel26s4`, …), `cond`, `invcond`, `lsl`
  forms, memory lists `off`, `pre`, `post` over a base rule and an offset rule. `(arm64-operand-rule info)` answers
  a kind info's rule name. Values bind exactly as the binders do (same `arm64-scaled`, `arm64-cond-code` calls).
- Consumes: `arm64-kind-info`, `arm64-register-entry`, `arm64-scaled`, `arm64-cond-code`, `arm64-bitmask`.

- [ ] **Step 1: Write `check/arm64-operands.l`**: for every arm64 row's sample operands (`check/asm-samples.l`'s
  `arm64-samples`) and every operand position, the position's rule answers what the position's binder puts in its
  field (bind into a fresh `vals`, read the field), or fails where the binder fails; prints `arm64 operands ok`.
- [ ] **Step 2: Run it; see it fail** (no grammar yet).
- [ ] **Step 3: Write `arm64-operands.g`** and the make rule; rules that need state across operands (arrangements)
  are left out, by name in a comment.
- [ ] **Step 4: Gates** `arm64_operands asm_table asm_rows_arm64 lines erosion`; commit
  `feat(asm-arm64): operand kinds as tree-grammar rules`.

### Task 2: The rows' rules, and asm_grammar

**Files:**
- Create: `gen-arm64-rules.l` (Maru: reads `arm64-rows`, writes `arm64-rules.g`, grammar `<arm64-rules> :
  <arm64-operands> ()`), generated `arm64-rules.g` and `arm64-rules.g.l` (both ignored, made by make).
- Create: `check/asm-grammar.l`; case `asm_grammar` in `check/check.l`.
- Modify: `Makefile`, `.gitignore`, `asm-arm64.l` (`arm64-row-word`), `doc/assemblers.md`.

**Interfaces:**
- Produces: for row index K, rule `rowK = `( 'MNEMONIC op:a … ) -> (arm64-row-word K a …)`, a memory operand a nested
  list pattern; a row whose kinds include one with no operand rule becomes `rowK = .:i &-> (arm64-encode-row ROW (cdr
  i) 0) -> …` matched on the whole instruction (the escape). Per mnemonic, `mnMNEMONIC = rowK | rowL | …` in file
  order, and where rows take a placeholder, `openMNEMONIC` sorted by field size `2^w - 1` descending, stable,
  rangeless rows omitted. `(arm64-row-word K vals…)` ORs row K's value with each field shifted, joined fields split
  as `arm64-put-ref` splits them. `(arm64-rule-row name)` answers a row rule's row (an identity table).
- `asm_grammar`: over `check/asm-table.l`'s arm64 stream (samples, placeholder variants, refusals), the compiled
  grammar's mnemonic rule (or `open…` for an open placeholder) on the instruction answers `asm-attempt`'s word and
  row, and fails where `asm-attempt` refuses. Prints `asm grammar ok`; times itself (expected seconds).

- [ ] **Step 1: Write `check/asm-grammar.l`**; run, see it fail (no rules).
- [ ] **Step 2: Write `gen-arm64-rules.l` and the make rules.**
- [ ] **Step 3: Run `asm_grammar`**; every disagreement is a generator bug: fix the generator, never the check.
- [ ] **Step 4: Decide** the suite placement from its time: in `check` if under ~10 s, else a hand-run case like
  Gezira's comparisons (the user's question 7); ledger the ruling.
- [ ] **Step 5: Gates** `asm_grammar arm64_operands asm_table lines erosion`; commit
  `feat(asm-arm64): the encoder as a tree grammar of arm64.spec's rows`.

### Task 3: The specialiser behind arm64-sites, for instructions without labels

**Files:**
- Create: `arm64-specialise.l` (loaded by `asm-arm64.l` after the rules are registered).
- Modify: `asm-arm64.l` (`arm64-insn-site-code` calls the specialiser for instructions with no `label` hole).
- Test: `check/native-sites.l` (cases), a kept-rows check in `check/arm64-kept-rows.l` run by `native_sites`.

**Interfaces:**
- Consumes: the rules as data through `grammar.l` (`grammar-of`, rule definitions), indexed once into identity
  tables by name (never `grammar-rule`'s list search per lookup); `arm64-rule-row`.
- Produces: `(arm64-specialise mnemonic specs) -> code`, the residual: holes' own rules run first (the guard), kept
  rows' reductions in file order, then `(cons mnemonic ops)`. A row is kept if each position's operand rule shares a
  leaf with the hole's rule (or matches the literal, which is folded into the constant). Residual code uses only
  `car`, `cdr`, cache lookups, `long?`, `arm64-scaled`, `|`, `<<`, `arm64-site-word-bytes`.
- Kept-rows check: for every template the grammars hold (each `arm64-sites` expansion records its mnemonic and specs
  in a table while `*arm64-sites-record*` is set), the kept rows include today's `asm-candidate-rows` for the
  representative, in order.

- [ ] **Step 1: Add the native-sites cases** (Review Focus 2: XZR, SP and W9 in an `x` hole; ADD's immediate edges;
  LDR at offsets 0, 8, 32760, 32768, 12, -8) and the kept-rows check; run; the kept-rows check fails (no specialiser).
- [ ] **Step 2: Implement `arm64-specialise`** for kinds x, w, n, lsl, c, f d/s and `(mem SHAPE ,p)`.
- [ ] **Step 3: Gates** `native_sites native_ir2 native_image catch recover tpeg_direct asm_grammar lines erosion`,
  images against the reference; `order-check`.
- [ ] **Step 4: Measure** with `ab-cpu --require-ac` against the task's base; keep only if faster.
- [ ] **Step 5: Commit** `perf(asm-arm64): sites are residuals of the encoder grammar`.

### Task 4: Label instructions

**Files:** Modify `arm64-specialise.l`, `asm-arm64.l` (`arm64-label-site-code` uses the `open…` rules).

**Interfaces:** a template with `(label ,l)` specialises the mnemonic's `open…` rule: POSITION is the label's index,
ROW the first kept row, INSN built from the template with `(reloc)`; the residual is `(label-data BYTES POSITION ROW
INSN l)` with BYTES folded where every other operand is literal. Replaces the run-time `asm-select`.

- [ ] **Step 1:** a native-sites case: a `CBZ` and `B` template's `label-data` equals `arm64-label-site-encode`'s.
  Run; see it fail if the old path is still reached (assert the residual carries no `asm-select` call).
- [ ] **Step 2: Implement**; gates as Task 3 plus `asm_patch`; measure; commit
  `perf(asm-arm64): label sites specialised from the open rules`.

### Task 5: Union kinds and one memory rule

**Files:** Modify `arm64-specialise.l`, `native.l` (fsites), `asm-arm64.l` (the `(mem ,place)` split).

**Interfaces:** hole kinds `f` (d | s) and `r` (x | w), each kept row testing its own leaf; `(mem ,place)` one rule
(`off` over `xsp` and a number), so `arm64-insn-site-code`'s SP-or-register split and `native-arm64-fsites`,
`native-arm64-at-width` go; `native.l`'s float helpers write `(f ,r)` and `(r ,a)` directly.

- [ ] **Step 1:** native-sites cases for `f` and `r` at both widths and a `mem` hole with SP and X10; run.
- [ ] **Step 2: Implement**, rewrite the float helpers, delete the split and fsites; gates; measure; commit
  `refactor(native-arm64): union kinds and one memory rule replace the width and base splits`.

### Task 6: Deletions

**Files:** `asm-arm64.l`.

- [ ] **Step 1: Delete** `<arm64-memo>`, `arm64-memo-step` (the multimethod: the user approved its deletion,
  2026-11-21), `arm64-memo-node`, `arm64-site-emit`, `arm64-site-encode`, `arm64-site-make`, `arm64-site-new`'s keys,
  `arm64-site-representative`, `arm64-label-site-encode`'s `asm-select` path; keep `*arm64-sites*`, `--no-sites`,
  `data`, `label-data`. `order-check`; `git grep` shows no users left.
- [ ] **Step 2: Gates** as Task 3; images; full `ab-cpu` comparison against the plan's first commit on lowering and
  on the whole compile; commit `refactor(asm-arm64): the site memo, representatives and keys go`.

### Task 7: Close

- [ ] **Step 1:** `doc/native.md`, `doc/assemblers.md`, `doc/grammars.md` describe the encoder grammar and the
  specialiser; the citation fix (oecm §3.2 and §6 for staged evaluation) in the plans that cite §5.1.
- [ ] **Step 2:** the full suite on a quiet machine on AC, nothing beside it.
- [ ] **Step 3:** whole-branch review by a fresh reviewer with this plan's Review Focus; fix Critical and Important
  test first.
- [ ] **Step 4:** report the phases (`maru-native-phases --ledger -n 3`) and `perf-trend` to the user.

The `reg` composition (the design's "second composition") is not in this plan: it needs the action form to see a
pattern's bindings, and it waits for the register-allocation design (the user's third item), which changes what
lowering's registers are.
