# Erosion Attribution Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A report that says how a change moved erosion and verbosity, callable by callable, splitting each metric's move
into what the change's edits did and what the tree's shifting total did.

**Architecture:** One tpeg grammar, `diff.g`, reads the change: git's unified diffs and `jj diff --git`'s through its
`diff` rule, jj's conflict markers through its `conflicted` rule, sharing the body lines and one parametric marker rule. Only the changed measured files are measured at the base; the base's whole-tree values are its
ledger's. `erosion-attribute.l` matches callables, marks the edited ones, attributes, and prints; `erosion-vcs.l` gets
the change and the base's files from git or jj through `spawn.l`, following the submodules.

**Tech Stack:** Maru (`eval`), tpeg text grammars, `erosion.l` and `maru-forms.l`, `spawn.l`, git, jj 0.45.

**Spec:** `doc/rfc/draft-ndn-erosion-attribution-00.md` (approved 2026-11-19). Every `[R-]` marker it holds is named by a
task below.

## Global Constraints

- Advisory: the report writes no file and fails nothing; its exit status is 0 whenever it could read the change.
  `[R-advisory]`
- Programs start with fixed arguments, never through a shell (`spawn.l`). `[R-no-shell]`
- Edited move + share move = whole move, in the integers `check/erosion` uses: the edited part truncated as the check
  truncates, the share the rest. `[R-attribution-sums]`
- Only a hunk's added and removed lines count, never context lines; diffs are asked for with `--unified=0`.
- Maru languages, not C; grammars, not cond chains, for reading text and walking trees; definitions in dependency order
  (a global used by a function is defined above it).
- Every source-line change gets a `check/lines` entry and every metric move a `check/erosion` entry, with its reason.

## Review Focus

1. A change that deletes a file holding an eroded callable: the callable is removed, edited, and the move is negative.
   Test in Task 3.
2. A file renamed and edited in one change: its callables match across the rename. Test in Task 3.
3. A path git quotes (`"a/x y.l"`, with C escapes): read as the path it names. Test in Task 1.
4. No change at all: the report says so, prints zero moves, exits 0. Test in Task 6.
5. A base revision that doesn't exist: an error naming it, no report, a non-zero exit (the change couldn't be read).
   Test in Task 6.

---

## Setup

The code uses `spawn.l`, which is on `check-noshell` (stacked on #32's `dd1cf06`). Before Task 1:

- [ ] Rebase `check-noshell` onto `tpeg-inline` (`bc60a04`, #32's latest); resolve conflicts in `check/check.l`,
  `check/lines`, `check/erosion` and `erosion.l` (keep both sides; the ledgers get re-summed entries); run
  `caffeinate -i make check` in `.worktrees/check-noshell`. Expected: `all checks passed`.
- [ ] Rebase `erosion-attribution` (this RFC and plan) onto the rebased `check-noshell`.

## File Structure

| File | Responsibility |
|---|---|
| `diff.g` (create) | one tpeg text grammar: a unified diff to `<file-diff>`s (`diff`), a file's text to common lines and `<conflict>`s (`conflicted`) |
| `erosion.l` (modify) | `<callable>` gains `last`, `flagged`; grammar rules get line spans |
| `erosion-files.l` (create) | the measured file list and the unread list, moved out of `check/check.l` |
| `erosion-attribute.l` (create) | matching, edited callables, attribution, conflicted files, the report |
| `erosion-vcs.l` (create) | the change and the base's files from git or jj, submodules followed |
| `erosion-attribute-run.l` (create) | the command: `./eval erosion-attribute-run.l [REV]` |
| `erosion-run.l` (modify) | `--attribute REV`: on a ledger mismatch, the report after its own lines |
| `check/erosion-attribution.l` (create), `check/erosion-attribution/` (create) | fixtures for the unit `erosion_attribution` |
| `check/check.l`, `Makefile`, `doc/measures.md`, `AGENTS.md` (modify) | the unit, `make erosion-report`, docs |

---

### Task 1: One grammar for diffs and conflicts

**Files:** Create `diff.g`, `check/erosion-attribution.l`, `check/erosion-attribution/git.diff`,
`check/erosion-attribution/jj.diff`, `check/erosion-attribution/conflict.l`. Modify `check/check.l` (unit
`erosion_attribution`), `erosion-attribute.l` (create, with the readers).

**Interfaces:**
- Produces: `(define-structure <hunk> (old-start old-count new-start new-count lines))`, `lines` each `(- text)`,
  `(+ text)` or `(" " text)`; `(define-structure <file-diff> (old-path new-path status hunks submodule))`, `status`
  one of `modified added deleted renamed submodule`, `submodule` `(old-commit . new-commit)` or `()`;
  `(define-structure <conflict> (index of sides))`; `(define-structure <side> (kind label lines))`, `kind` one of `diff
  snapshot base`, a diff side's `label` `(from . to)` and its `lines` like a hunk's, a snapshot's or base's `lines`
  plain text; `(read-diff text) -> list of <file-diff>` (entry rule `diff`); `(read-conflicts text) -> list` of
  strings (common lines) and `<conflict>`s (entry rule `conflicted`); `(conflict-sides text) -> list of (label .
  side-text)`, each side's whole file: the common lines with that side's lines in every conflict (a diff side's ` `
  and `+` lines). A read that stops partway is an error naming the line.
- `diff.g`'s shared rules: `body_line` (a hunk's and a diff side's lines), `marker :c` (seven of `c`, by a rule `ch :c =
  .:x &-> (= x c)`; every jj marker is `{marker ?<}` … `{marker ?\}`), `any_marker` (one of the six), `rest`, `eol`.
  Inside a conflict, `body_line` and `plain_line` are guarded by `!any_marker`.

- [ ] **Step 1: Write the fixtures and failing tests.** `git.diff` holds, in order: a modified `a.l` with two hunks, one
  header `@@ -3 +3,2 @@` (omitted count); a new file `b.l` (`new file mode`, `--- /dev/null`); a deleted `c.g`; a
  rename `d.l` to `e.l` with one hunk; `Binary files a/p.png and b/p.png differ`; a line `\ No newline at end of
  file`; a quoted path `diff --git "a/x y.l" "b/x y.l"`; and `nile` as `-Subproject commit 1111…` / `+Subproject
  commit 2222…`. `jj.diff` is `jj diff --git` output for one modified file. `conflict.l` holds two conflicts, one with a
  diff and a snapshot side (the markers captured from jj 0.45 in the RFC's design), one 3-sided with a base, and a
  content line `+++++++ text` in an ordinary hunk of `git.diff`. Tests:

```
(expect "statuses" (map <file-diff>-status (read-diff git)) '(modified added deleted renamed modified modified submodule))
(expect "omitted count is 1" (<hunk>-old-count (cadr (<file-diff>-hunks (car files)))) 1)
(expect "no-newline marker counts on neither side" <the hunk's line count> <its header's counts>)
(expect "quoted path" (<file-diff>-new-path quoted) "x y.l")
(expect "rename" (list (<file-diff>-old-path r) (<file-diff>-new-path r)) '("d.l" "e.l"))
(expect "submodule commits" (<file-diff>-submodule s) '("1111…" . "2222…"))
(expect "+++++++ is content in a diff" <a (+ "++++++ text") line in its hunk>)
(expect "jj's git format" (map <file-diff>-new-path (read-diff jj)) '("f.l"))
(expect "two conflicts, 2 and 3 sides" (map (lambda (c) (list-length (<conflict>-sides c))) conflicts) '(2 3))
(expect "kinds" (map <side>-kind (<conflict>-sides (car conflicts))) '(diff snapshot))
(expect "a diff side's label is from and to" (<side>-label first) '("vrqksnlt 1f769a2f \"base\"" . "nkzqsnom 2af2415a \"one\""))
(expect "a diff side's lines are a hunk's" (<side>-lines first) '((- "b") (+ "B1")))
(expect "each side's file" (conflict-sides small) '(("nkzqsnom 2af2415a \"one\"" . "a\nB1\nc\n") ("xxkslomr 1fa76d66 \"two\"" . "a\nB2\nc\n")))
(expect "a read that stops names where" (try (read-diff "diff --git a/x b/x\ngarbage\n") …) 'refused)
```

- [ ] **Step 2:** `make check CHECKS="erosion_attribution"`. Expected: FAIL, `read-diff` undefined.
- [ ] **Step 3:** Write `diff.g` (a `<text-parser>` grammar, the RFC's Formal Grammar, the markers by `marker :c`) and
  the three functions (load with `tpeg-load`, parse the whole text, fail with the position on a partial parse, as
  `erosion-parse-text` does).
- [ ] **Step 4:** `make check CHECKS="erosion_attribution"`. Expected: `PASS erosion_attribution`.
- [ ] **Step 5:** Commit: `feat(erosion): one grammar for unified diffs and jj's conflicts`. `[R-one-grammar]
  [R-diff-read] [R-jj-git] [R-conflict-read]`

### Task 2: Each callable's lines and flagged forms

**Files:** Modify `erosion.l`, `check/erosion.l`.

**Interfaces:**
- Produces: `(define-structure <callable> (name path line last cc forms flagged))`: `line`, `last` the first and last
  line of its definition (`<source>`'s `first` and `last` for a Maru definition; for a grammar rule, the lines its
  text spans, found by running tpeg's `$definition` over the file's text and noting the parser's position before and
  after each); `flagged` the forms in its own form a verbose pattern or clone covers (`erosion-covered-forms` over the
  callable's form). A flagged form inside no callable is in no callable's `flagged`. `(erosion-of sources)` unchanged
  in its metrics.

- [ ] **Step 1: Failing tests** in `check/erosion.l`:

```
(expect "a definition's first and last line" (map (lambda (c) (list (<callable>-line c) (<callable>-last c))) (callables-of "(define-function f ()\n  1)\n\n(define-function g () 2)\n")) '((1 2) (4 4)))
(expect "a rule's lines" (map (lambda (c) (list (<callable>-line c) (<callable>-last c))) (grammar-callables "a = \"x\"\n  | \"y\" ;\nb = a ;")) '((2 3) (4 4)))
(expect "a callable's flagged forms" (map <callable>-flagged (callables-of "(define-function f (x) (not (not x)))\n(define-function g () 1)")) '(2 0))
```

(The grammar fixture's first line is the `<g> : <text-parser> ()` header `grammar-text` adds.)

- [ ] **Step 2:** run `./eval check/erosion.l`; Expected FAIL. **Step 3:** implement. **Step 4:** `make check
  CHECKS="erosion"`; Expected PASS, the ledger unmoved (the metrics don't change). **Step 5:** commit
  `feat(erosion): each callable's lines and flagged forms`.

### Task 3: Matching, edited callables, attribution

**Files:** Modify `erosion-attribute.l`, `check/erosion-attribution.l`.

**Interfaces:**
- Consumes: `<callable>` (Task 2), `erosion-of`, `erosion-read-file`, `erosion-ledger`.
- Produces: `(define-structure <change> (path old-path base-text current-text added removed))`, `added`/`removed` the
  line numbers of added and removed lines; `(define-structure <move> (path name edited cc-before cc-after forms-before
  forms-after flagged-before flagged-after))`; `(define-structure <attribution> (erosion verbosity moves rebuilt))`,
  `erosion` and `verbosity` each `(base now whole edited share)` per mille; `(attribute changes tree-now base-ledger)
  -> <attribution>`, `tree-now` an `<erosion-metrics>`, `base-ledger` `(erosion . verbosity)` or `()`.

Decisions this task carries (the RFC's, made concrete):
- A change's texts are measured by writing each to a scratch file at its own relative path (under `MARU_CHECK_TMP`,
  else `/tmp/maru-attribution-PID/`) and reading it with `erosion-read-file`.
- Callables match on `(path name)` with `old-path` for the base side; same-named ones in order.
- Base values: the ledger's when `base-ledger` is given and its erosion equals the rebuilt erosion (eroded mass and total
  mass add up per callable, so the rebuilt erosion is exact); otherwise the rebuilt values, and `rebuilt` is true.

- [ ] **Step 1: Failing tests**, each change built in the test from texts:

```
(expect "an edited callable crossing 10" <move of f: cc 10 -> 11, edited t>)
(expect "edited + share = whole, erosion and verbosity" (let ((e (<attribution>-erosion a))) (= (caddr e) (+ (cadddr e) (car (cddddr e))))) 't)
(expect "a callable two lines below an edit isn't edited" <move absent or edited ()>)
(expect "a deleted file's eroded callable is removed, edited, the move negative" …)
(expect "rename and edit: matched across the rename" <one move with path "e.l", not an add and a remove>)
(expect "an unedited callable whose clone partner was added moves share, and is named" <move edited ()>)
(expect "a ledger that doesn't hold is rebuilt from, and says so" (<attribution>-rebuilt a) 't)
```

- [ ] **Step 2:** run; Expected FAIL. **Step 3:** implement `attribute` per the RFC's pseudocode. **Step 4:** run;
  Expected PASS. **Step 5:** commit `feat(erosion): attribute a change's moves to its edits and to share`.
  `[R-measure-changed] [R-match] [R-edited] [R-attribution-sums]`

### Task 4: The report

**Files:** Modify `erosion-attribute.l`, `check/erosion-attribution.l`.

**Interfaces:**
- Produces: `(attribution-report a) -> list of strings`; `(attribution-ledger-entries a) -> list of strings`, one per
  metric whose whole move isn't 0, in `check/erosion`'s form: `erosion +3 edits: f (CC 9 to 12), g; share -1`.

Report lines, in order: `erosion BASE -> NOW: whole W, edited E, share S` (and `verbosity …`), `rebuilt from the
changed files: the base's ledger doesn't hold` when `rebuilt`; then one line per move, edited first, by mass moved:
`edited a.l f: CC 9 -> 12 (crossed 10), forms 40 -> 52, flagged 0 -> 2`; then `ledger:` and the drafted entries.

- [ ] **Step 1: Failing tests:** the report of Task 3's fixture equals the expected lines exactly; a drafted entry reads
  with `erosion-ledger` to its whole move; the report function writes no file (`check/erosion` unchanged, no new file
  in the fixture directory).
- [ ] **Steps 2–4:** fail, implement, pass. **Step 5:** commit `feat(erosion): the attribution report and drafted
  ledger entries`. `[R-report] [R-advisory]`

### Task 5: Conflicted files, side by side

**Files:** Modify `erosion-attribute.l`, `check/erosion-attribution.l`.

**Interfaces:**
- Consumes: `conflict-sides` (Task 1), `attribute` (Task 3).
- Produces: `(attribute-conflicted path base-text text tree-now) -> list of (label . <attribution>)`: each side's text
  attributed against the conflict's base as a change of its own (its added and removed lines from a line diff of base
  and side, by `diff.g`'s reading of `diff -U0`'s output run through `spawn.l`).

- [ ] **Step 1: Failing test:** Task 1's `conflict.l` gives one attribution per side, labelled as jj labels them; a
  side that adds an eroded callable shows it edited, the other side doesn't.
- [ ] **Steps 2–4.** **Step 5:** commit `feat(erosion): conflicted files attributed side by side`. `[R-conflict-sides]`

### Task 6: git and jj, submodules, the command

**Files:** Create `erosion-vcs.l`, `erosion-files.l`, `erosion-attribute-run.l`. Modify `check/check.l` (use
`erosion-files.l`), `Makefile` (`erosion-report`), `check/erosion-attribution.l`.

**Interfaces:**
- Produces: `(vcs-kind) -> 'jj | 'git` (`jj` if `.jj/` exists, `MARU_VCS` overriding); `(vcs-changes rev) -> list of
  <change>` and conflicted paths; `(vcs-ledger-at rev) -> text or ()`; `(measured-files)` and `erosion-unread`, moved
  from `check/check.l` unchanged.
- Commands, each through `spawn.l`: git `diff --unified=0 --no-color --no-ext-diff REV --`, `ls-files -o
  --exclude-standard` (untracked measured files are added), `show REV:PATH`, `ls-tree REV nile` (the submodule's
  recorded commit), and in the submodule `git diff --unified=0 COMMIT` and `git show COMMIT:PATH`; jj `diff --git
  --from REV --to @`, `file show -r REV PATH`, and git inside submodules. A measured file whose text holds `<<<<<<<
  conflict` is conflicted.
- `erosion-attribute-run.l [REV]`: measures the tree now (`measured-files`, `erosion-of`), gets the changes, prints
  `attribution-report` (and each conflicted file's sides), exits 0; with no change, prints `no change against REV`;
  with a revision that doesn't exist, prints `erosion: no revision REV` and exits 1.

- [ ] **Step 1: Failing tests** in `check/erosion-attribution.l`, on a git repository made in the scratch directory
  (`git init`, two commits, a submodule added with `git -c protocol.file.allow=always submodule add`, then an edit in
  each): the changes name the superproject's file and the submodule's file with the submodule's directory prefixed; an
  untracked measured file is `added`; a bad revision is refused; with jj on `PATH`, the same edits in a `jj git init
  --colocate` repository give the same changes (skipped, saying so, without jj).
- [ ] **Steps 2–4.** Also `make check CHECKS="lines erosion"`: `measured-files` lists what `counted-files` listed.
  **Step 5:** commit `feat(erosion): changes from git and jj, submodules followed; make erosion-report`.
  `[R-submodules] [R-no-shell] [R-advisory]`

### Task 7: The erosion check prints the report; docs; ledgers

**Files:** Modify `erosion-run.l`, `check/check.l`, `check/erosion.l`, `doc/measures.md`, `AGENTS.md`, `check/lines`,
`check/erosion`.

- [ ] **Step 1: Failing test** in `check/erosion.l`: `erosion-run.l --ledger FIXTURE --attribute HEAD` over a fixture
  whose ledger doesn't match prints its own mismatch line and then a line beginning `erosion ` from the report.
- [ ] **Step 2:** run; Expected FAIL. **Step 3:** `--attribute REV` in `erosion-run.l`: on a mismatch, call the report
  with the metrics already measured (no second measurement); `check/check.l`'s erosion unit passes `--attribute HEAD`
  (`@-` under jj). **Step 4:** run; Expected PASS.
- [ ] **Step 5:** docs: `doc/measures.md` (the report, its unit, the RFC), `AGENTS.md` (unit `erosion_attribution`
  under Line count and erosion). Ledgers: `make check CHECKS="lines erosion"`, entries with reasons; the report itself
  drafts the erosion entry.
- [ ] **Step 6:** `caffeinate -i make check` alone. Expected: `all checks passed`. Commit `feat(erosion): a failing
  erosion check names its cause`. `[R-check-prints]`

## Coverage

`[R-one-grammar]` `[R-diff-read]` `[R-jj-git]` `[R-conflict-read]` 1 · `[R-measure-changed]` `[R-match]` `[R-edited]`
`[R-attribution-sums]` 3 · `[R-report]` 4 · `[R-advisory]` 4, 6 · `[R-conflict-sides]` 5 · `[R-submodules]`
`[R-no-shell]` 6 · `[R-check-prints]` 7.
