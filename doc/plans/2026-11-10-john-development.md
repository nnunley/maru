# Development Driven by JOHN Plans: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `make check` records its results as JOHN evidence in every plan's ledger, and `next.l` answers, per lane,
the steps each plan allows, ranked by what the evidence and erosion say.

**Architecture:** `check/parallel.l` writes a results file; `notes/plan/record-run.l` turns it into worlds of each plan's
chain, written by `john-serialize` as Maru forms and read back by `john-deserialize` with `read`, with a history per
property. Plans qualify each check's state from `its evidence over time`, weigh steps with heuristics (one using
`total` over hotspots), and `choices` answers the ranked frontier, which `next.l` prints lane first.

**Tech Stack:** untyped Maru on `eval` (`john-eval.l`, `john.g`, `check/*.l`), `sh` (`notes/plan/record`,
`notes/plan/tree-hash`), make.

**Spec:** `doc/rfc/draft-ndn-maru-john-development-00.md`. Read it first; requirement IDs below are its `[R-…]`.

## Global Constraints

- Run everything from the repository root; run checks through make (`make check CHECKS="NAME…"`), never `./eval check/check.l`.
- Every change in source line count gets an entry in `check/lines` (`+N reason`); every change in erosion or
  verbosity one in `check/erosion`. Run `make check CHECKS="lines erosion"` before each commit.
- Each new check, or change to what one asserts, goes in its unit's `doc/<unit>.md` in the same commit, and the case
  name in that unit's line in `AGENTS.md`.
- Ledger lines are Maru forms read by `read`; nothing in a ledger is evaluated. No hand-written C.
- Format code for reading, one form per line where Maru code in the tree does; never pack lines to save `check/lines`.
- Dispatch by type (`define-selector`/`define-method`), not `cond` chains on types.
- One full suite at a time on this machine, under `caffeinate -i`; `MARU_CHECK_JOBS` stays at its default.
- Commit at each green step; no attribution lines in commit messages.
- Ledger forms (RFC Formal Grammar): `(world (ACTOR ACTION ARG…) ((OBJECT PROPERTY VALUE) …))`,
  `(make CLASS NAME VALUE…)`; a value is an atom, `(list V…)` or `(value KIND (FIELD V)…)`.
- Default weights: `regressing` 10000, `failing` 1000, `aging` 100, `untried` 10, erosion 1.
- Output lines, exactly: `STEP  score N` (two spaces), `choices: K.`, `next: PLAN: STEP  score N`,
  `then: PLAN: STEP  score N`, `nothing left to build`; results file `tree T`, `complete yes|no`, `NAME passed|failed`.

## Review Focus

1. A ledger line naming a check a plan dropped: with `retired NAME.` it is skipped and reported; without, reading fails
   naming the ledger and line (a misspelling stays an error). Tests in Tasks 3 and 4.
2. A `make check` interrupted, or whose tree changed: no results file, or none complete, and nothing recorded; a
   results file without its `complete` line is refused. Tests in Tasks 1 and 5.
3. A plan with no ledger yet: every check reads `untested`, and the first recording creates the file. Test in Task 5.
4. A ledger that starts with a `;` comment or ends without a newline still reads (`read` skips comments). Test in Task 3.
5. A string value holding quotes, backslashes or a newline (a law's counterexample) round-trips through
   `john-serialize` and `read` unchanged. Test in Task 3.

---

### Task 1: The results file [R-results-file]

**Files:**
- Create: `check/results.l`, `check/results-test.l`
- Modify: `check/parallel.l` (tree before the first case, results after the last)
- Modify: `check/check.l` (case `check_results`, beside `check_tmp`)
- Modify: `doc/checks.md`, `AGENTS.md` (check runner line), `check/lines`

**Interfaces:**
- Produces: `(results-write dir tree-before tree-after complete outcomes)` in `check/results.l`: `outcomes` is a list of
  `(name . passed?)` in finishing order; writes `DIR/results` (through `DIR/results.tmp` and a rename) or, if the trees
  differ, removes any `DIR/results`, writes nothing and prints `the code changed during the run: no results` to stderr.
  `(results-read path)` → `(tree complete outcomes)` or `()` for a missing file, error `results: no complete line` for
  a truncated one. `(tree-hash-now)` → the 12-character string `notes/plan/tree-hash` prints.
- Consumes: `run-jobs` (`check/jobs.l`), which already knows each case's outcome; make it answer
  `(failed . outcomes)` or add an outcomes list beside `failed`, in finishing order.

- [ ] **Step 1: Write `check/results-test.l`** asserting: a write with equal trees gives a file whose lines are
  `tree abc123def456`, `complete no`, `unmatched passed`, `pepsi failed`; `results-read` gives back
  `("abc123def456" () (("unmatched" . t) ("pepsi")))`; a write with different trees leaves no file (and removes one
  already there); a file without `complete` fails `results-read` with `results: no complete line`; prints
  `results ok`. Case in `check/check.l`:
  `(check "check_results" (unit-assert (equal (last (run "check_results" "./eval check/results-test.l")) "results ok")) …)`,
  plus a nested run `MARU_CHECK_TMP=$tmp/inner ./eval check/parallel.l check_tmp` (inner directory, so the case's own
  directory isn't wiped) whose `inner/results` names the tree `tree-hash` gives, `complete no` and `check_tmp passed`.
- [ ] **Step 2:** `make check CHECKS=check_results` fails (no `check/results.l`).
- [ ] **Step 3: Implement** `check/results.l`; in `check/parallel.l` take `(tree-hash-now)` before `run-jobs` and after,
  `complete` true only with no names requested (not `--quick`, not a list), and call `results-write` in `check-tmp`.
- [ ] **Step 4:** `make check CHECKS="check_results check_tmp unmatched lines"` passes.
- [ ] **Step 5:** Document in `doc/checks.md` (the results file, what `check_results` asserts); add `check_results` to
  the check runner's line in `AGENTS.md`; `check/lines` entry; commit.

### Task 2: `total` and `choices` in JOHN [R-total, R-choices]

**Files:**
- Modify: `john.g` (reserve `total`, `over`, `choices`; rules below), `john-eval.l`
- Modify: `check/john-run.l`, `check/john-session.l`, `doc/john.md`, `check/lines`

**Interfaces:**
- Produces: expression form `(total S E)` from `total S by E` (S a primary or `all C`; `which` bound to each member, as
  `select` binds it); statement form `(choices O G)` from `choices O G.`; `(john-choices o g)` →
  list of `(step-world . score)` best first, ties in `john-children` order, `using` from `john-using`.
- Consumes: `john-children`, `john-using`, `john-score`, `john-step-text`, `john-say` (`john-eval.l`).

- [ ] **Step 1: Write the tests.** In `check/john-run.l`: over three objects with `mass` 2, 3, 5,
  `total (all Spot) by which mass` is 10; `total (select all Spot by which mass > 2) by which mass` is 8; over an empty
  select, 0; a member whose E is a name fails with an error naming the member. In `check/john-session.l`: a session with
  a heuristic `heuristic T g 10 maximize (select all Box by which planned = yes and which big = yes) size.` and two
  allowed steps answers `choices T g.` with lines `T pick Big  score 10`, `T pick Small  score 0`, `choices: 2.`, the
  current time unchanged; two steps of equal score keep `john-children`'s order; with no step allowed, `choices: 0.`
- [ ] **Step 2:** `make check CHECKS="john_run john_session"` fails on the new assertions.
- [ ] **Step 3: Implement** the grammar rules (`total` in `prefix`, `choices` as a statement), `total` in `john-eval`
  beside `select`, and `john-choices` plus the `choices` statement (scores as `john-score` gives them, which already
  negates minimize; print each with `john-text`).
- [ ] **Step 4:** `make check CHECKS="john_forms john_run john_session sat_john"` passes.
- [ ] **Step 5:** Document both in `doc/john.md` (as ours); `check/lines`; commit.

### Task 3: Serializing a chain, and each property's history [R-ledger-forms, R-history-index, R-retired]

**Files:**
- Create: `john-serialize.l` (requires `john-eval.l`)
- Modify: `john-eval.l` (`<john-world>` gains `history`; `john-lookup` and `john-at-time` consult it), `john.g`
  (`over time`)
- Modify: `check/john-session.l`, `doc/john.md`, `check/lines`

**Interfaces:**
- Produces:
  - `(john-serialize-worlds from to)` → list of ledger forms for the worlds after `from` up to `to` on `to`'s chain,
    oldest first; `(john-ledger-line form)` → its text, one line, read back by `read` to an `equal` form.
  - `(john-value->form v)` / `(john-form->value f)`: atoms as themselves, a list as `(list …)`, a `<john-variant>` as
    `(value KIND (FIELD V) …)`, field names without the colon.
  - `(john-deserialize forms)`: enters `make` forms as declarations, then appends one world per `world` form to the
    current chain with exactly its writes (`john-write`, nothing evaluated), its action as `<john-world>-action`;
    then builds the history. Errors: `ledger LINE: unknown object|action|property|kind NAME` and
    `ledger LINE: not a world or a make`, LINE the form's position from 1 (the caller adds the file). A world whose
    action or writes name a retired object, or a `make` of one, is skipped; `(john-skipped)` → list of
    `(name . count)` skipped by the last `john-deserialize` [R-retired].
  - statement `(retired NAME)` from `retired NAME.`, kept in `*john-retired*`; `john-begin` empties it.
  - `<john-world>-history`: a `hash.l` table by `equal`, key `(object . property)`, value an array of
    `(time . value)` in time order, shared by every world of the chain read back. `john-lookup` on a world with a
    history and time ≤ the chain's end answers by binary search; a world past the chain (a possible world) walks its
    own writes to the chain, then searches.
  - expression `(over-time (send X p))` from `E over time`: distinct values, in order of first appearance, from world 0
    to the evaluating world's time; with no history, it walks the chain.
- Consumes: `john-write`, `john-make`, `john-make-variant`, `<john-variant>` (`john-eval.l`); `hash.l`.

- [ ] **Step 1: Write the tests** in `check/john-session.l`: a session that steps three times (one action writing two
  properties) serializes to three `world` forms whose writes are the actions' own; `read` of their text gives `equal`
  forms; a fresh session with the same program, `john-deserialize`d from them, answers `time.` 3, `at time 1 X p` as
  the original, `X did act` as the original; a string with `"`, `\` and a newline, and `(value refuted (tree "a")
  (counterexample "x=\"p\" y=3"))`, round-trip; a ledger text starting with `; comment` and ending without a newline
  reads; a form naming an undeclared object fails `ledger 2: unknown object Ghost`; after `retired Ghost.` the same
  forms read, the Ghost world skipped, and `(john-skipped)` is `((Ghost . 1))`; after deserializing 2000 worlds,
  cutting the parent of world 2 (`(set (<john-world>-parent w2) ())`) leaves `X p` at the current time and at time 1500
  answering as before (the history, not the chain, answered); `X p over time` gives each distinct value once, oldest
  first, including world 0's.
- [ ] **Step 2:** `make check CHECKS=john_session` fails.
- [ ] **Step 3: Implement** `john-serialize.l`, the history field and its use in `john-lookup` / `john-at-time`, and
  `over time` (a `chain` alternative before `chain name`, `over` reserved).
- [ ] **Step 4:** `make check CHECKS="john_forms john_run john_session sat_john call_by_meaning"` passes.
- [ ] **Step 5:** Document in `doc/john.md`; `check/lines`, `check/erosion` if it moved; commit.

### Task 4: Plans read their ledgers; states from `over time` [R-ledger-union, R-ledger-forms, R-done-current, R-plans-name-cases]

**Files:**
- Create: `check/case-names.l` (the reader `check/parallel.l` has, moved out), `notes/plan/tree-matching.answers`,
  `notes/plan/ksworld.answers`, `notes/plan/render.answers` (converted once; the converter is not kept)
- Delete: `notes/plan/evidence.john`, `notes/plan/ksworld-evidence.john`, `notes/plan/render-evidence.john`
- Modify: `notes/plan/plan-world.l`, `notes/plan/tree-hash` (exclude `notes/plan/*.answers`), `.gitattributes`
  (`notes/plan/*.answers merge=union`), `check/parallel.l`, the three plans, `check/plan-evidence.l`,
  `doc/evidence-plan.md`, `check/lines`

**Interfaces:**
- Produces: `(plan-load dir name tree)`: a fresh session (`john-begin`), `DIR/NAME.john` read, `(make Code Now TREE)`,
  `DIR/NAME.answers` (empty if missing) deserialized; leaves `*john-world*` current. `(plan-names dir)` → sorted names
  of `DIR/*.john`. `plan-ask`, `plan-yes?` as now. `(case-names)` from `check/case-names.l`.
- Each plan declares, replacing `holds`, `stale` and the `at time` `regressed`:

```
qualify Check current-good if for some its evidence over time do (each is Good and each tree = Now tree).
qualify Check current-bad if for some its evidence over time do (not each is Good and not each is untested and each tree = Now tree).
qualify Check older-good if for some its evidence over time do (each is Good and not each tree = Now tree).
qualify Check holds if it current-good = yes and it current-bad = no.
qualify Check failing if it current-bad = yes.
qualify Check regressed if it failing = yes and it older-good = yes.
qualify Check stale if it current-good = no and it current-bad = no and it older-good = yes.
qualify Check untested if for every its evidence over time do each is untested.
```

- [ ] **Step 1: Write the tests** in `check/plan-evidence.l`: a fixture plan and ledger in `check/plan/` (two cases, one
  answered good on tree `aaa`, one good on `bbb` and failed on `aaa`) loaded with `plan-load` at tree `aaa` give
  `holds`, `regressed`; at tree `ccc`, both `stale`; a case good and failed on `aaa` is `failing`, not `holds`;
  the same two lanes' lines interleaved in either order give the same states; a ledger line naming a removed check
  fails `…check/plan/x.answers: ledger 3: unknown object gone`, and with `retired gone.` in the plan loads, its
  states unchanged by the skipped line; every `make Case NAME` in `notes/plan/*.john` is in
  `(case-names)`, else `FAIL plan PLAN names no case NAME`.
- [ ] **Step 2:** `make check CHECKS=plan_evidence` fails.
- [ ] **Step 3: Implement** `plan-load`, `plan-names`, `check/case-names.l`; convert each evidence file by replaying it
  through the old reader once and writing `john-serialize-worlds`; replace the qualifications; fix `render.john`'s
  `ksworld_render` to the case that shows it (`ksworld_rerender` or `ksworld_pixels`: read `check/check.l`'s comments
  and choose the one asserting what the capability says).
- [ ] **Step 4:** `make check CHECKS="plan_evidence lines erosion"` passes, and `./eval notes/plan/next.l` prints what
  it printed before the conversion for each `MARU_PLAN` (done and not done lines unchanged).
- [ ] **Step 5:** Document ledgers, `merge=union`, and the states table in `doc/evidence-plan.md`; `check/lines`; commit.

### Task 5: Recording from `make check`, deduplicated [R-run-records, R-ledger-dedupe, R-retired]

**Files:**
- Create: `notes/plan/record-run.l`, `check/plan-record.l`
- Modify: `Makefile` (`check`, `check-quick`), `notes/plan/observe.l`, `notes/plan/record`, `notes/plan/probes.l`
  (`MARU_RECORD=0` on its `make check`s), `check/check.l` (case `plan_record`), `doc/evidence-plan.md`, `AGENTS.md`
  (JOHN line), `check/lines`

**Interfaces:**
- Produces: `./eval notes/plan/record-run.l RESULTS [DIR]` (DIR defaults to `notes/plan`): does nothing when
  `MARU_RECORD` is `0`; says `no results: nothing recorded` for a missing file; before deduping, drops every line
  naming a name the plan has retired for at least `MARU_RETIRE_AFTER` commits (default 20; `(retired-commits dir
  plan name)` → `git rev-list --count C..HEAD`, C the first commit whose plan file holds `retired NAME.`, from
  `git log --reverse --format=%H -S 'retired NAME.' -- FILE`; 0 when uncommitted) [R-retired]; for each plan in `DIR`, loads it at the
  results' tree, `john-do`es `C observed passed(tree: T)` / `failed` for each declared `Case` in the results, then
  `WholeSuite observed passed(tree: T)` if complete and all passed and the plan declares it, appends the new worlds'
  lines, and dedupes the file. `(ledger-dedupe path)`: rewrites the file keeping the first of each `equal` form, in
  order, comments dropped.
- Consumes: `results-read` (Task 1), `plan-load`, `plan-names` (Task 4), `john-serialize-worlds` (Task 3).
- Makefile recipe shape: run `check/parallel.l`, keep its status, run `record-run.l` on `$(check-tmp)/results`
  unless `MARU_RECORD=0` (record-run.l reads the variable itself), exit with the suite's status; a ledger that can't
  be written is reported and doesn't change the exit status.

- [ ] **Step 1: Write `check/plan-record.l`**: in a copy of `check/plan/` under the case's directory, a results file
  (`tree aaa`, `complete no`, `one passed`, `other failed`, `stranger passed`) adds exactly two worlds to `x.answers`
  (none for `stranger`, which the plan doesn't declare) and none to a plan declaring neither; `complete yes` with all
  passed adds `WholeSuite`; with one failed it doesn't; recording the same results twice leaves the file as after
  once; two ledgers concatenated (a union merge) dedupe to the first of each; with `MARU_RETIRE_AFTER=0` a retired
  name's lines are dropped and with the default (and the retirement uncommitted) kept; a plan with no `.answers` gets one;
  `MARU_RECORD=0` changes nothing; prints `plan record ok`. Case `plan_record`.
- [ ] **Step 2:** `make check CHECKS=plan_record` fails.
- [ ] **Step 3: Implement** `record-run.l`, `ledger-dedupe`, the Makefile hook; change `observe.l` to `john-do` each
  answer and append `john-serialize-worlds` (and skip a `Case` whose current answer the ledger holds), and `record`
  to append and dedupe.
- [ ] **Step 4:** `make check CHECKS="plan_record plan_evidence check_results"` passes, and the three ledgers gained
  worlds for the declared cases among those run, deduplicated.
- [ ] **Step 5:** Document in `doc/evidence-plan.md` (`MARU_RECORD`, when recording happens, dedupe); `plan_record` in
  AGENTS.md's JOHN line; `check/lines`; commit, ledgers included.

### Task 6: Heuristics, the frontier and lanes [R-plan-heuristics, R-stale-ranks, R-lanes]

**Files:**
- Create: `notes/plan/frontier.l`, `check/plan-frontier.l`, fixtures `check/plan/beta.john`
- Modify: `notes/plan/next.l`, the three plans, `check/check.l` (case `plan_frontier`; `plan_evidence`'s
  `next.l` exit-0 assertion stays), `doc/evidence-plan.md`, `AGENTS.md`, `check/lines`

**Interfaces:**
- Produces: `(plan-frontier dir name tree)` → list of `(step-text . score)` from `john-choices T deliver` after
  `plan-load`; `(lane-frontier dir lane tree)` → list of `(plan step-text score)`, lane first then the rest by name;
  error `E_UNKNOWN_LANE: NAME (plans: A, B, C)`. `next.l [--lane NAME]` prints its account (as now) then the lines.
- Each plan adds, with the weights in Global Constraints:

```
qualify Capability regressing if for some its shown-by do each regressed = yes.
qualify Capability failing if for some its shown-by do (each failing = yes and each regressed = no).
qualify Capability aging if for some its shown-by do each stale = yes.
qualify Capability untried if for some its shown-by do each untested = yes.
heuristic Team deliver 10000 maximize (select all Capability by which planned = yes and which regressing = yes) size.
heuristic Team deliver 1000 maximize (select all Capability by which planned = yes and which failing = yes) size.
heuristic Team deliver 100 maximize (select all Capability by which planned = yes and which aging = yes) size.
heuristic Team deliver 10 maximize (select all Capability by which planned = yes and which untried = yes) size.
```

- [ ] **Step 1: Write `check/plan-frontier.l`** over `check/plan/` (alpha with four ready capabilities, one each
  regressing, failing, aging, untried; beta with one ready): `lane-frontier … "alpha"` gives alpha's four in the order
  regressing, failing, aging, untried with scores 10000, 1000, 100, 10, then beta's; lane beta puts beta first; with
  every answer about an older tree, a frontier is still answered (no `record full` line); a plan all done contributes
  nothing; all done everywhere prints `nothing left to build`; `--lane nope` exits 1 with
  `E_UNKNOWN_LANE: nope (plans: alpha, beta)`; a plan with a skipped retired line prints
  `skipped 1 events about retired: gone` before its frontier; the printed lines match `next: alpha: T build R  score 10000` and
  `then: …`. Prints `plan frontier ok`. Case `plan_frontier`.
- [ ] **Step 2:** `make check CHECKS=plan_frontier` fails.
- [ ] **Step 3: Implement** `frontier.l`, the new `next.l` tail (the `record full` branch goes), the plans' qualities and
  heuristics.
- [ ] **Step 4:** `make check CHECKS="plan_frontier plan_evidence plan_record"` passes; `./eval notes/plan/next.l
  --lane ksworld` prints ksworld's frontier first.
- [ ] **Step 5:** Document; `plan_frontier` in AGENTS.md's JOHN line; `check/lines`; commit.

### Task 7: Erosion as something every plan minimizes [R-erosion-minimized]

**Files:**
- Create: `check/erosion-files` (the file list the `erosion` case builds, moved to a script both use)
- Modify: `erosion-run.l` (`--hotspots`), `check/check.l` (`erosion` uses `check/erosion-files`),
  `notes/plan/probes.l` (builtin `erosion-hotspots`), `notes/plan/observe.l` (writes the `make Hotspot` lines),
  the three plans, `check/plan/alpha.john`, `check/plan-frontier.l`, `doc/measures.md`, `doc/evidence-plan.md`,
  `check/lines`

**Interfaces:**
- Produces: `./eval erosion-run.l --hotspots FILE…` prints one line per callable over CC 10, all of them, as
  `hotspot NAME FILE LINE CC MASS` with MASS `CC × sqrt(SLOC)` rounded to a whole number. Ledger line
  `(make Hotspot H_TREE_FILE_LINE "NAME" "FILE" LINE CC MASS "TREE" no)`, FILE's non-alphanumerics as `_`.
- Each plan adds:

```
create Hotspot callable file line cc mass tree planned.
qualify Hotspot current if its tree = Now tree.
action Team simplify Hotspot consequence Hotspot planned = yes.
rule Team simplify is Hotspot current = yes.
rule Team simplify is Hotspot planned = no.
heuristic Team deliver 1 minimize total (select all Hotspot by which planned = no and which current = yes) by which mass.
make Measure Erosion untested "erosion".
```

- [ ] **Step 1: Write the tests**: `check/erosion.l` asserts `--hotspots` over its fixtures prints the CC 11 callable
  and not the CC 10 one, with its mass; in `check/plan-frontier.l`, alpha with a current hotspot of mass 500 and one of
  an older tree orders the frontier failing build (score 500: 1000 less the 500 left unsimplified), then
  `T simplify H_aaa_x_l_3  score 0`, then the aging build (100 − 500, score -400): minimize scores are negated, so
  only differences between steps carry the weights; the older hotspot is never a step.
- [ ] **Step 2:** `make check CHECKS="erosion plan_frontier"` fails.
- [ ] **Step 3: Implement** `--hotspots`, `check/erosion-files`, the probe and observe's `make` lines, the plans' lines.
- [ ] **Step 4:** `make check CHECKS="erosion plan_frontier plan_record lines"` passes; `notes/plan/record full` writes
  hotspot lines and `next.l` lists `simplify` steps among the builds.
- [ ] **Step 5:** Document in `doc/measures.md` and `doc/evidence-plan.md`; `check/lines`; commit.

### Task 8: The feedback rule, the whole suite, and merging

**Files:**
- Modify: `AGENTS.md` (Documentation or a new short section: feedback becomes a plan change, quoted in the commit;
  feedback that can't be is taken back to its giver), `doc/evidence-plan.md`, `notes/plan/LOOP.md` (point at the RFC
  and drop rules it replaces), the RFC's `**Corpus:**` to green once every named check passes

- [ ] **Step 1:** Write the AGENTS.md rule and the LOOP.md changes; `rfc-lint` the RFC with `**Corpus:** green`.
- [ ] **Step 2:** Coverage: `grep -o '\[R-[a-z-]*\]'` over the RFC and this plan give the same set.
- [ ] **Step 3:** `caffeinate -i make check`: every case passes, and the ledgers gained this run's worlds; commit them.
- [ ] **Step 4:** Branch workflow: rebase on main, fresh review of the branch, fixes, full suite again, fast-forward
  main, push, remove the worktree.
