# The arm64 encoder as a tree grammar, and lowering staged by composing two grammars (design)

Status: draft for the user's approval, 2026-11-21. No code. Follows `2026-11-20-staged-native-lowering-design.md`
(sites), within A1 of `2026-11-19-nile-native-on-eval.md`. Choices the user has not made are marked "my call".

## Intent, and why

The user, on `native-arm64.g`'s `intent` rule once it had an action form: "the intent syntax you created looks a lot
like a maru tree grammar". It does. An action such as `` `((ADD (x ,d) (x ,a) (x ,b))) `` is a tree with typed holes,
and a row of `arm64.spec`, `ADD Xd, Xn, Xm`, is a pattern over the same tree. Today the two meet through machinery
that is neither: the `arm64-sites` macro (`asm-arm64.l`, "sites") builds a representative instruction (X0, W0, 0),
asks `asm-candidate-rows` for rows, records shape keys, and at run time guards keys, walks a memo trie
(`arm64-memo-step`) and on a miss runs `arm64-encode-row` through per-kind binders.

The proposal: write the encoder as a tree grammar whose rules are the rows, make the template's kinds that grammar's
operand rules, and let the action form compose the two as the lowering grammar loads. What is left to run is the
part of the encoder that depends on the operands' values. This is Piumarta's chain of grammars, where "each stage's
output template visibly matches the next stage's input pattern" (`notes/sources/piumarta-2010-peg-based-transformer.md`,
whose §6 also says a JIT needs output expressions that build instruction words from bit fields), with the second
stage partially evaluated against the first. A note on the citation the plans use: `notes/sources/piumarta-2011-…`
places staged evaluation in oecm §3.2 and §6 and has §5.1 as grounding, and records the claim as asserted, not shown.

## Goals

- One definition of each operand kind, as a grammar rule, read by both the template and the row.
- Native images byte for byte as today (`check/native-images.l`, `native_sites`, `tpeg_direct`, `native_nile`).
- Lowering faster on `eval2` and `eval3`, each step kept only if `ab-cpu` says so (the existing keep rule).
- Less machinery: representatives, shape-key guards, the SP-or-register split and the float-width macro go.
- Code that carries to the kernel unchanged: residuals are plain Maru (`car`, `cdr`, a cache lookup, `|`, `<<`).

## Non-goals

- Parity with the C back end from this design alone. See "What it can and cannot buy".
- x86-64. `native-x64.g` and `asm-x86.l` are not touched, so their output is unchanged. See "x86-64".
- Replacing `asm-table.l`. It stays the general encoder, the patcher (`asm-patch`) and the decoder.
- NEON rows through operand rules. They are in the grammar by an escape (below), which lowering never reaches.

## Anti-goals

- **Different bytes.** A hole whose value is not of its kind, or that no row takes, answers the symbolic form, as a
  site does today (`arm64-site-encode`'s last line).
- **A changed refusal.** `asm-place` stays the only source of "asm: no arm64 row for …; forms: …".
- **Operand kinds written twice for good.** Binders and operand rules coexist only until question 3 is answered.
- **A grammar interpreted per instruction.** The encoder grammar is specialised at load. It is run only by its check.

## The encoder grammar

**A row becomes a rule.** Each row of `arm64-rows` gives one rule; a mnemonic's rule is the ordered choice of its
rows' rules in file order. A sketch, in tpeg's notation (the names are illustrative: tpeg's identifiers are a letter
then letters and digits, so `ADD.1`, `Xd|SP` and `B.open` need other spellings):

```
ADD.1 = `( 'ADD Xd|SP:d Xn|SP:n imm12:i ) -> (| 0x91000000 (| d (| (<< n 5) (<< i 10)))) ;
ADD.3 = `( 'ADD Xd:d Xn:n Xm:m )          -> (| 0x8B000000 (| d (| (<< n 5) (<< m 16)))) ;
ADD   = ADD.1 | ADD.2 | ADD.3 | ADD.4 ;
LDR.1 = `( 'LDR Xt:t `( 'off Xn|SP:n imm12x8:i ) ) -> (| 0xF9400000 (| t (| (<< n 5) (<< i 10)))) ;
```

The constant is the row's `value` (its literal bits, already computed where `arm64-rows` is defined). Each named
field becomes `(<< v shift)`, the shift `arm64-plan` computes today. A joined field (`immhi:immlo`) is split by the
action, as `arm64-put-ref` splits it. The rule's result is the word. Each rule keeps its row object as an
annotation, because `label-data` and `asm-patch` need the row itself.

**An operand kind becomes an operand rule.** A rule takes one operand and answers its field value, or fails. These
are written once by hand (about fifteen, one per `define-arm64-binder`), in a parent grammar the rows' rules extend:

```
x     = .:r &-> (arm64-x r) -> (arm64-x r) ;      # X0..X30: the number, through arm64-register-entry's cache
Xd    = x | 'XZR -> 31 ;                           # a row's Xd
Xd|SP = x | 'SP  -> 31 ;                           # a row's Xd|SP
n     = .:v &-> (long? v) -> v ;
imm12x8 = n:v &-> (arm64-scaled 'imm 12 8 v) -> (arm64-scaled 'imm 12 8 v) ;
```

A rule fails with `()`, never with a value: 0 is a field value (X0, an immediate 0, EQ), and `compile-tpeg.l`'s header
warns that 0 is false in typed Maru, so a residual tests for `()` and nothing else.
`w`, `s`, `d`, `c` (and `invcond`), `lsl`, and the memory forms `off`, `pre`, `post` follow the same way. A field kind
is one rule per distinct (tag, width, scale), named for it, since a rule with parameters costs argument cells
(`source-parser-arguments`). Kinds whose value needs state across operands (the arrangement `T`,
`arm64-bind-arrangement`) get no operand rule. A row that uses one becomes an escape rule: any operands, a predicate
that calls `arm64-encode-row` on that row. So every mnemonic's choice is whole, and the grammar equals `asm` on every
row, while only the kinds lowering uses are rules (my call).

**The choice among rows equals `asm-select`'s.** Three cases, each read from `asm-best-row`:

- *No open placeholder.* arm64 registers `fixed-width`, so `asm-best-row` stops at the first candidate that encodes.
  Candidates are in file order and hold every row that encodes (`asm_table` asserts it), so `asm`'s answer is the
  first row of the mnemonic, in file order, that encodes. That is the ordered choice above.
- *An open placeholder, `(reloc)`.* `asm-best-row` takes the row with the largest `(hi - lo) / step` from
  `arm64-field-range`, the first among equals (its test is a strict `<`), and skips a row with no range. For arm64
  that size is `2^w - 1` whatever the pc, so the order is static. A mnemonic with such rows gets a second rule,
  `B.open`, `CBZ.open`, `ADR.open`: the same row rules, sorted by that size, stable, rangeless rows left out.
- *A sized placeholder, `(reloc N)`.* Not open. First fit, the operand rule matching only a field N bits wide, as
  `arm64-value-binder` does.

**Refusal.** A mnemonic's rule that fails says nothing. The caller hands the symbolic form to `asm`, which refuses.

**The pc.** A parser field. Lowering specialises at pc 0, as `arm64-site-encode` encodes at 0, and a numeric
PC-relative operand in a template stays a load-time error, as `arm64-site-make` makes it today.

**Where it lives** (my call). A build step writes the rows' rules from `arm64.spec`, as `arm64.g.l` is made; the spec
stays the one source. `asm-arm64.l` registers the rules with `grammar.l` as data (`grammar-register`) and does not
compile them: lowering needs only their definitions. The check compiles them. `native-image.l` still loads with no
grammars. Load order is today's: `asm-arm64.l` before `stub.l` and `native.l`, since `./eval` resolves a function's
globals when it is defined and the residuals name functions of `asm-arm64.l`.

## Composition

The action form stays `intent <arm64-sites>`, and the templates stay as written. What `arm64-sites` does changes: it
becomes a specialiser of the encoder grammar against a template (a new function beside `compile-tpeg.l`, reading
rules through `grammar-rule`). For each instruction of the template, as the lowering grammar loads:

1. The mnemonic is literal, so the mnemonic's rule is chosen now (the `.open` rule if an operand is `(label ,l)`).
2. A literal operand (`SP`, `16`, `(post SP 16)`, `(LSL 16)`) is matched against each row's operand rule now. A row
   it fails is dropped; a row it passes has the field folded into the constant.
3. A hole, `(x ,d)`, names an operand rule; `(f d ,r)` names `d`, `(f s ,r)` names `s`, and `(mem ,place)` names a
   rule `mem`, a list `off` of a base (`x` or `SP`) and `n`. A **leaf** is a rule that tests one element itself (`x`,
   `w`, `d`, `s`, `n`, a literal). A row is kept only if its operand rule and the hole's rule share a leaf, position
   by position inside a list (`Xd` and `Xd|SP` share `x` with the hole `x`; `Wd` and `imm12` share none). This
   replaces the representative and `arm64-accepts`: X0's shape passed exactly the rows that take an X register.
4. The hole's own rule runs first, once, as the guard today's shape key is. Then each kept row's rule is reduced
   given what the hole's rule proved: `Xd` given `x` is `x`'s value, and `imm12` given `n` leaves the range test.
   Where the hole's rule is a union, the row's residual tests its own leaf (`Dd` tests `d`).
5. The residual is the kept rows in order, then the symbolic form.

For `` `((ADD (x ,d) (x ,a) (x ,b))) `` rows 1, 2 and 4 are dropped, and the residual is, in effect:

```
(let ((dn (arm64-x d)) (an (arm64-x a)) (bn (arm64-x b)))
  (if (and dn an bn) (arm64-site-word-bytes (| 0x8B000000 (| dn (| (<< an 5) (<< bn 16))))) (list 'ADD d a b)))
```

For `(LDR (x ,r) (mem ,place))` the residual takes `place` apart with `car` and `cdr`, finds its base through
`Xn|SP`, and tests the offset against `imm12x8`; when that fails it tries the next row or answers the symbolic form.
For `(B (label ,l))` every other operand is literal, so `B.open`'s one row gives a constant
`(label-data BYTES POSITION ROW INSN l)`, the same tuple `arm64-label-site-encode` gets from `asm-select`, which
`native-place-form` places and `asm-patch` patches through ROW as now. POSITION is the label operand's index in the
template, known at load, which is what `arm64-encode` reports for it. `CBZ (x ,r) (label ,l)` builds INSN from `r`.

A rule outside the class the specialiser reduces (the escapes) is left as a call of the row's encoder at run time.
That is always correct, only slower, so the specialiser can grow kind by kind.

**A second composition, later** (my call to stage it): `reg:d` then `(x ,d)` runs `stub-reg` and then `x`, two
lookups with a symbol between them. Both are pure rules of one element, so they compose into one cached function
from `s0` to 9. It needs the action form to see the pattern's bindings, which `tp-through-form` does not pass today.

| | Today's site | Composed |
|---|---|---|
| Rows chosen | load, by a representative and `arm64-accepts` | load, by which operand rules reach the hole's |
| Literal operands | bound again on every miss | folded into the constant at load |
| Guard | each operand's `arm64-shape-key` compared | the hole's rule, whose answer is the field value |
| Encode | `arm64-encode-row`: a `vals` array, binders, a shift loop | one expression of `\|` and `<<` |
| Memo | a trie walk by multimethod, every time | none, if the spike below says so |
| No fit | the symbolic form, to `asm` | the same |

## Floats, memory, constants, labels

- **Float widths.** `FMOV`'s rows already order `Wd,Sn` / `Sd,Wn` / `Xd,Dn` / `Dd,Xn`. A hole kind may be a union,
  `f = d | s` and `r = x | w`, so `(FMOV (f ,f0) (r ,a))` keeps both rows, and the first that fits is `asm`'s.
  `native-arm64-fsites` and `native-arm64-at-width` go. A representative could not say "either".
- **SP or a register.** `arm64-insn-site-code` makes two sites and picks by the base, only because SP's shape key
  differs from X0's. Every memory row's base in `arm64.spec` is `Xn|SP`, one rule, so one residual serves both. The row is the same:
  both of today's sites draw from the mnemonic's rows in file order, as the one residual does.
- **Far and unaligned accesses.** `native-arm64-access` and `native-arm64-far?` stay. They choose instructions, which
  is lowering's job, not the encoder's. Moving them into `native-arm64.g` as ordered alternatives is the next step
  this opens (the access helpers are about 20% of lowering), and it is not designed here.
- **Constants.** `arm64-constant`'s four templates are unchanged. `(LSL 16)` is literal, so `hw` is folded; what runs
  is `x` on the register and `imm16`'s range test. Always four instructions, as now: shorter sequences would change
  the bytes.
- **Labels.** As under Composition. `label-data`, `native-place-form`, `native-assemble` and `asm-patch` are unchanged.

## Replaces and keeps

| Goes | Stays |
|---|---|
| `arm64-site-representative`, `<arm64-site>`'s rows and keys, `arm64-site-make`, `arm64-site-encode` | `arm64.spec`, `arm64.g`, `arm64-rows`, rows as objects |
| the `(mem ,place)` split, `native-arm64-fsites` | the template syntax and `intent <arm64-sites>` |
| `<arm64-memo>` and `arm64-memo-step`, if measured slower (question 1) | `*arm64-sites*` and `--no-sites`, as the check's switch |
| `arm64-label-site-encode`'s run-time `asm-select` | `(data …)`, `(label-data …)`, `native-link.l` |
| | `asm-table.l` whole; plans and binders, for `asm`, `asm-patch` and the fallback (question 3); decoding |
| | `arm64-shape`, `arm64-accepts`, `arm64-shape-key`, for the candidate table |

## What it can and cannot buy

Gezira on `eval2`. The figures I was given as the quiet machine's best: front end 2.8 s, symbols 0.27 s, lowering
5.8 s, assembly 1.8 s, tail 0.7 s. The perf ledger's nearest row (`perf-trend`, 2026-11-21 09:49, c54fd2b with
changes, load 2.18): 2.8, 0.26, 6.6, 1.9, and 9.5 s for the image whole. The profile shares I was given, which I read
as shares of lowering: sites' own work 22%, access helpers 20%, generic dispatch 14%, streaming `intent*` 8%,
`stub-reg` 5%.

- This design addresses the 22% and the 14%, and with the second composition the 5%: at most about 2.5 s of about
  12 s. How much of that it recovers is **unmeasured**.
- The memo is the risk. Of Gezira's 103,227 forms 7,272 are distinct, so most emits are memo hits that allocate
  nothing. A residual allocates its `(data …)` list each time. It wins only if a few cache lookups and shifts beat a
  trie walk. An ADD site cost 25 µs before the memo (28cffcf); the residual's cost is **unmeasured**.
- The front end alone equals the C route's 2.7 s, so parity needs everything after it to cost what `cc` does, 0.1 to
  0.4 s. This design cannot do that. What it opens: the helpers as rules, `intent*` without a stream, and a residual
  that writes its word into the buffer, joining lowering and assembly. All **unmeasured**, none designed here.

## Verification

- **Byte identity**, unchanged: `native_sites` (every unit's image with and without sites, and its site cases: SP in
  an `x` hole, ADD's immediate edges, near, register-based, unaligned and far accesses), `native_image`, `native_ir2`,
  and by hand with `native_nile`'s loader for Gezira. `tpeg_direct` and `native_ir2_x64` hold `compile-tpeg.l` and x64.
- **New, `asm_grammar`**: over `check/asm-table.l`'s arm64 stream (every row's samples, each number in turn a
  placeholder, the refusals), the compiled encoder grammar answers as `asm-attempt` does: the same word, the same row
  for a placeholder, failure where `asm` refuses. It runs on the stream path, which nests lists and takes predicates
  today, so the engine needs nothing for it. Its time is **unmeasured**; I expect seconds.
- **New, while both mechanisms exist**: for every template, the rows the specialiser keeps include the rows
  `asm-candidate-rows` gives today's representative, in the same order. Image identity alone sees only the operands
  the units use.
- **New cases in `check/native-sites.l`**: a union kind (`f`, `r`) at both widths, a `mem` hole with SP and with a
  register, XZR and a W register in an `x` hole, each held to `asm-bytes`.
- **Check time.** This adds the arm64 sweep and removes none. It does nothing for `asm_table`'s x86 and x64 sweeps,
  which are most of the 175 s; how those seconds split across its five runs is not in the perf ledger.

## Measurement

`maru-native-phases --ledger --tag … -n 3` on `native_nile`'s loader for the phases; `ab-cpu --base … --head …
--metric-regex '^lower (\d+) ms'` for a step's keep decision, interleaved, best and median, on `eval2` and `eval3`;
`perf-trend --tool maru-native-phases --unit native-nile --phase lower` for the series, reading `load1` beside each
value. Full runs need a quiet machine.

## Approaches

- **A. The encoder grammar, composed at load (recommended).** As above. One definition of kinds, less machinery,
  unions and one memory rule for free, and the route to the helpers and to x86. Costs a specialiser (new, perhaps
  200 lines) and a spike to prove the residual beats the memo.
- **B. The grammar generated from rows; lowering keeps sites.** The grammar replaces plans and binders as `asm`'s
  encoder, a function per row, and sites call it as they call `arm64-encode-row`. It speeds hand-written assembly
  too (unmeasured), but keeps representatives, keys and the memo, so lowering gains little, and it puts the grammar
  on `asm`'s hot path, which needs the engine to match nested lists and failing rules directly.
- **C. Sites stay; only kinds become rules.** `x`, `w`, `n` are grammar rules that the macro and the binders both
  read. Small and safe. It removes the duplicate kind tables and nothing else: no speed, and the template still
  meets the rows through a representative.

Recommendation: A, entered through its spike. If the spike shows no gain over the memo, do C for the tidiness and
stop, and say so.

## Risks and unknowns, ranked

1. The residual is no faster than a memo hit. Settled by the spike, before anything else is built.
2. "Shares a leaf" keeps a different set of rows than `arm64-accepts` does for some kind. An extra row is harmless
   (first fit among a superset is the same row). A row wrongly dropped changes the bytes whenever a later kept row
   also fits, and `arm64.spec` puts aliases first for that reason. The kept-rows check above is the guard.
3. The specialiser's class of reducible rules grows into a general partial evaluator. Hold it to operand rules:
   a test and a value on one element, a choice of rules and literals, a list of those.
4. Load time: the specialiser runs for every template each time `native.l` loads. Unmeasured; today's macro already
   resolves rows there.
5. Two definitions of the kinds, binders and rules, until question 3 is answered. `asm_grammar` holds them equal.
6. Evaluator differences: the residual must hold on `eval2`, `eval3` and `eval`, as the keep rule asks.

## Constraints

- Code in Maru languages (`.l`, `.k`, `.g`), never C. The rows' rules are written by a Maru script from `arm64.spec`.
- Dispatch by type and `hash.l` tables, no alists: a mnemonic's rule and a rule's row are found in identity tables
  built once (`grammar-rule` searches a list, so the specialiser does not call it per lookup).
- The specialiser reads rule definitions and writes plain Maru. It must not bring `compile-tpeg.l` into `native.l`'s
  load, which today loads only compiled `.g.l` files.
- Definition order: a residual's functions (`arm64-x`, `arm64-scaled`) are defined before any rule or helper that
  holds a residual, since `./eval` resolves a function's globals when it is defined.
- The kernel: this is still its plan's Task 7 (a lowering rule chooses its rows once), with the site's inside
  replaced. Typed Maru through ir2 reaches the same `native-arm64.g`, so nothing kernel-specific is added, and the
  kernel worktree's plan is not edited from here.
- x86-64's output and `asm`'s refusal text do not change. Each step is a commit at green with its ledger entries.

## Left to the builder

- **First, the spike:** the ADD and LDR residuals above, written by hand in place of their sites, timed by `ab-cpu`
  with and without a memo in front. Report before going on.
- The specialiser's home and interface; how a rule carries its row; rule names for field kinds.
- The build step that writes the rows' rules, and whether they are text or tpeg's parsed trees.
- The order after the spike: operand rules and `asm_grammar`; the specialiser behind `arm64-sites`; unions and the
  memory rule; deletions; then the `reg` composition. One commit each, at green, ledgered.
- Load-time error texts for a template's author (a hole with no kind, an unknown kind) may change; `asm`'s may not.

## x86-64

It does not follow yet, for two reasons in the code. `asm-best-row` there takes the shortest of all fits, and an x86
encoding's length depends on the operands (REX, the displacement's size), so its choice is not an ordered choice; a
grammar would need a choice that tries every alternative and keeps the shortest. And x86 rows are interpreted whole
by `x86-encode-row-as-given`, with no plan to turn into a rule's action. Both are tractable and neither is designed
here. Until then `native-x64.g` has no action form, emits symbolic forms, and is encoded by `asm`, unchanged.

## Questions for the user

1. The memo step is a multimethod by your choice, at a measured cost. If the spike shows the residual faster with no
   memo, may `<arm64-memo>` and `arm64-memo-step` be deleted?
2. This cannot reach parity with the C back end alone. Is it worth doing as one step, or should the next design be
   the larger one (helpers as rules, residuals writing into the buffer)?
3. May the encoder grammar later replace plans and binders as `asm`'s arm64 encoder (approach B on top of A), so
   kinds are defined once? Or do binders stay and `asm_grammar` hold the two equal?
4. Do templates keep their kinds as written, `(x ,d)`, or should a kind be inferred where the pattern binds the
   variable through a rule (`reg:d`)?
5. Does the action form stay a macro's name, or should tpeg gain a notation for "this rule's output is that
   grammar's input", after OMeta's foreign rules?
6. Should x86-64 be designed next, or left on `asm` until the kernel needs it?
7. Is a new arm64 sweep in the suite acceptable, given the suite's time, or should it run by hand like Gezira's
   comparisons?
