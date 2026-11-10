# Erosion by Reflection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Measure erosion and verbosity in forms, not lines, over the forms Maru's own reader makes, in one walk; and have
every definition answer its own source, form and line counts and tokens through Maru methods.

**Architecture:** Erosion reads each file with Maru's C reader (`find-and-read`, 0.13 s for the tree) and walks each
top-level form once with `maru-forms.g`, a tree grammar deciding each list by its head, which answers its complexity, forms,
atoms, clone hash and verbose flags together. Its unit is the form: a list outside quoted data. `source.l` records, as
`load` evaluates each top-level form, a `<source>` (file, lines, raw form) for what the form defined, in a weak identity
table keyed by that object; files that only run are read without evaluating, and their definitions lifted into records
answering the same selectors (`source-form`, `form-count`, `line-count`, `source-text`, `source-tokens`, `sources`).
Tokens are made on demand, one definition at a time, by a text grammar built on `peg.g`'s lexical rules.

**Tech Stack:** Maru (`eval`, `eval2`, `eval3`), tpeg text and tree grammars, `hash.l`'s weak identity tables.

**Spec:** this document's Design section and the user's rulings: "sources can be introspected from the object
representation within maru. a <foo> class should include a maru method to provide the sources and line count. And sources
should be iterable as the tokenized, symbolic version of itself"; "use the weak table, raw forms"; "Erosion should be
counting statements or forms, not lines" (2026-11-10). Background: `docs/plans/2026-11-08-erosion-metrics.md` (the metrics
as first defined, in lines), `docs/plans/2026-11-09-grammar-engine.md` (suspended).

## Design

- **The unit is the form.** A form is a list in source that isn't inside quoted data (`quote`, `'`): code, and code
  templates under quasiquote, but not `fonts.k`'s tables. A callable's mass is CC x sqrt(forms); erosion is the share of
  mass held by callables of CC over 10. Verbosity is the share of a file set's forms that a verbose pattern flags or a clone
  covers (a list of at least 12 atoms met twice, its definition's variables renamed to one placeholder): a flagged or cloned
  list covers itself and the forms inside it, each counted once. Statements in body positions would need every macro's body
  positions, which only loading knows; forms are what reading gives.
- **So erosion needs no text.** Blank lines, comments and line spans mattered only for lines. Maru's C reader makes the
  forms, each pair keeping `(path . line)`, which names where a callable or finding is and nothing more.
- **Where time went** (Baseline): reading through `maru-lines.g` was 44% and the C reader does it 340 times faster; a fresh
  parser per list for the verbose rules (94,610), and four or five walks per form. One reading and one walk replace them.
- **Raw forms, not expanded bodies:** expansion makes every `when` a false `empty-let`, adds 1 to complexity per `assert`
  (115 in the tree), and moves clone sizes through generated names (`_list_`).
- **Sources by reflection:** what loading keeps already (`<expr>`, `<form>`, `<selector>`, types, `grammar.l`'s grammars,
  pairs' `(path . line)`) lacks a definition's raw form and its extent; `source.l` records them.
- **Tokens on demand:** a tpeg text grammar costs about 14 us a character (a first try took 31 s over the tree), so tokens
  are made for one definition when asked, never for the tree. Making text grammars fast (Warth's optimizer passes over
  grammar trees: associative, sequence inlining, jump tables) is a plan of its own, after this one.

## Baseline (Task 0, 2026-11-10, Low Power Mode off)

`./eval erosion-measure.l` over the 293 measured files, CPU milliseconds (`-O`, unchecked accessors, beside each):

| stage | ms | `-O` |
|---|---|---|
| read through `maru-lines.g` | 44810 | 42939 |
| Maru's C reader, the same files (`find-and-read`) | 132 | 134 |
| code lines (`erosion-lines.g`) | 8087 | 8430 |
| callables (`erosion-complexity.g`) | 13297 | 8036 |
| verbose findings (`erosion-verbose.g`, 94,610 lists, a parser each) | 12224 | 7474 |
| binders (`erosion-binders.g`) | 19523 | 11975 |
| clone hashes (`erosion-scan`, plain Maru) | 4153 | 3364 |
| total | 102226 | 82352 |

Reading is 44% of the time and the C reader does it 340 times faster; type checks cost a fifth of the rest. Rule
invocations aren't counted: a grammar's rules take the invoker in force when they're compiled, so wrapping it after loading
counts nothing; the lists the verbose rules enter stand in for them.

## Global Constraints

- Everything in Maru languages; no C change (the weak table, not a field on `eval`'s C `struct Expr`); no shell tools inside
  the analysis.
- Any form `boot.l` and `boot2.l` share keeps one text in both (`boot_forms`).
- Every new behaviour runs on `eval`, `eval2 -b boot2.l` and `eval3 -b boot2.l` unless a task says otherwise.
- Grammars structure once, then small analyses over the structure; no wildcard walk of raw forms per analysis.
- `check/erosion`'s ledger must equal the metrics after every task that touches them; a move gets an entry saying why.
- `check/lines` gets an entry for every change in line count, saying why lines were added.
- Readable forms, never packed lines.

## Review Focus

1. A definition redefined later (a second `define-function f`): its source is the latest, never a list of both.
2. A data form of tens of thousands of atoms (`fonts.k`): no form counted inside its quote, and the walk loops along spines,
   never a frame per element.
3. What erosion measures is the `lines` set's files, never what loading touched: a derived file (`*.g.l`) defines things
   with sources, and none of it is counted; a form that defines several things is counted once.
4. A finding inside a clone, or a clone inside a finding: each form covered once in verbosity, never twice.
5. Symbols as `eval.c` reads them (`<pair>`, `*globals*`, `%eax`, `$rule`, `.long`, `a,b`, `a?`, and `1+` as two tokens): the
   tokens rebuild the same forms.

---

### Task 0: Measure before changing (done, 9153aea)

Timed each stage of today's check; the numbers are the Baseline above.

### Task 1: Metrics in forms, in one walk over the reader's forms

**Files:**
- Create: `maru-forms.g` (tree grammar, parent `<source-parser>`, fields `binders` and `flags`)
- Modify: `erosion.l`, `erosion-run.l`, `check/erosion.l`, `check/erosion` (the ledger), CLAUDE.md's `erosion` entry
- Delete: `maru-lines.g`, `maru-lines.l`, `erosion-lines.g`, `erosion-complexity.g`, `erosion-binders.g`, `erosion-verbose.g`

**Interfaces:**
- Produces: `maru-forms.g`'s `form` rule answering, for a raw form, `(cc forms atoms hash)` and recording each verbose
  finding (rule, list) in `flags`, binders gathered in `binders`, each list entered once and decided by its head, quoted data
  an atom-counted leaf with no forms; `(erosion-of sources)`, sources `((path . forms) ...)`, answering the same
  `<erosion-metrics>` (erosion, verbosity, callables, forms, flagged), each `<callable>` (name path line cc forms).

- [ ] **Step 1: Write the failing tests** in `check/erosion.l`, every fixture by forms: CC 1, 2, 4 and 3 for a line, an if, a
  cond and an `and`; forms 3 for `(define-function f (x) (g x))` (the definition, its parameter list, the call) and 1 for
  `(define x '(a (b c)))` (the quote's lists aren't forms; the quote form itself is one: `(quote ...)` is read as a list, so
  2 with it; state which and assert it); erosion 0 at CC 10 and all of it at 11; each verbose rule's example flagged and its
  plain form not; a clone at exactly 12 atoms and none at 11; a finding inside a clone covering its forms once; the ledger's
  sums; rest parameters and quasiquote as before.
- [ ] **Step 2:** Run `make check CHECKS=erosion`; expected: fails on `<callable>-forms`.
- [ ] **Step 3:** Write `maru-forms.g` and rewrite `erosion.l` over it; `erosion-run.l` reads each file with `find-and-read`
  and keeps the `--unread` list (those files must still fail to read); delete the files listed above.
- [ ] **Step 4:** Run `make check CHECKS="erosion lines"`; the unit changed, so replace `check/erosion`'s entries with one per
  metric saying "measured in forms (2026-11-10)" and its value; record the case's CPU time against the Baseline's 102 s.
- [ ] **Step 5:** Add the `check/lines` entry, update CLAUDE.md's `erosion` entry, commit.

### Task 2: Sources answered by what loading made

**Files:**
- Create: `source.l`
- Modify: `boot.l`, `boot2.l` (`load`: one hook, the same text in both)
- Test: `check/source.l`, fixture `check/source/defs.l`

**Interfaces:**
- Consumes: Task 1's `maru-forms.g` (`form-count`).
- Produces: `(define-structure <source> (file first last form))`; `*load-hook*` in both boots, called
  `(*load-hook* path form value)` after `load` evaluates each top-level form; selectors `source-of` (object to `<source>` or
  `()`), `source-form`, `form-count`, `line-count`, `source-text`, `sources`, with methods for `<expr>`, `<form>`,
  `<selector>` (`sources`: its own and each method's), `<long>` (a type, through `%type-sources`), `<grammar>`,
  `<grammar-rule>`, and `<source>` itself. `line-count` is the lines from first to last that hold more than a comment, read
  from the file's text, kept once per file.

- [ ] **Step 1: Write the failing tests:** `check/source/defs.l` defines a function `f` over three lines with a comment line
  inside, a form `g`, a selector `s` with methods on `<pair>` and `<long>`, a structure `<foo>`, and a grammar;
  `check/source.l` loads `source.l` then the fixture, and asserts: `(line-count f)` is 2; `(form-count f)`;
  `(source-form f)` is `equal` to the fixture's raw `(define-function f ...)`; `(source-text <foo>)`;
  `(map line-count (sources s))` has three entries (the selector, two methods); defining `f` again makes `(source-form f)`
  the second definition.
- [ ] **Step 2:** Run `./eval check/source.l`; expected: fails, `source.l` not found.
- [ ] **Step 3:** Add `*load-hook*` to `load` in both boots; write `source.l`: the hook records a `<source>` for a top-level
  form whose head is a definer (`define`, `define-function`, `define-form`, `define-selector`, `define-method`,
  `define-structure`, `define-class`, `define-apply`, tpeg's grammar definitions), keyed by the object the form left
  defined; its last line the greatest any pair in it was read on.
- [ ] **Step 4:** Run it on all three evaluators; expected: `source ok`.
- [ ] **Step 5:** Register `source` in `check/check.l`, document in CLAUDE.md, add the `check/lines` entry, commit.

### Task 3: Definitions lifted from files that only run, and erosion through them

**Files:**
- Create: `source-lift.g`, a tree grammar over a file's raw top-level forms
- Modify: `source.l`, `erosion.l`
- Test: `check/source-lift.l`

**Interfaces:**
- Consumes: Task 1 (`erosion-of`), Task 2 (`<source>`, the selectors).
- Produces: `(define-structure <definition> (kind name source))`; `(file-definitions path)`: the `<definition>`s the file's
  forms define, read without evaluating (one rule per definer, `(let () ...)` bodies entered), each answering Task 2's
  selectors. This is erosion's route: the files it measures run programs, conflict and need particular evaluators, so it
  reads them; `erosion-of` takes `<definition>`s, and a form defining several things is counted once.

- [ ] **Step 1: Write the failing tests:** for `check/source/defs.l`, `(file-definitions ...)` names `f g s <foo>` and the
  grammar with the form and line counts Task 2's loaded objects answer; a form defining two functions counts its forms once
  in the metrics.
- [ ] **Step 2:** Run; expected: fails, `file-definitions` undefined.
- [ ] **Step 3:** Implement `source-lift.g` and `file-definitions`; `erosion-of` measures through them.
- [ ] **Step 4:** Run on all three evaluators, and `make check CHECKS="erosion source_lift lines"`; the ledger holds.
- [ ] **Step 5:** Register `source_lift`, add the `check/lines` entry, commit.

### Task 4: Tokens on demand

**Files:**
- Modify: `maru-tokens.g` (rewritten on `peg.g`'s lexical rules: inheriting them, rules answering values, no state kept by
  actions), `source-tokens.l`, `source.l` (`source-tokens`)
- Test: `check/source-tokens.l` (exists, its token cases pass on the first version)

**Interfaces:**
- Consumes: Task 2's `<source>`.
- Produces: `(define-structure <token> (kind text start end line))`; `(source-text-tokens text)`; `(tokens-forms tokens)`,
  the forms `read` makes; `(source-tokens x)` for anything with a source; a `<source>` answers `input.l`'s selectors over its
  tokens, so a tree grammar walks them.

- [ ] **Step 1: Write the failing tests:** the existing token cases; `(tokens-forms (source-tokens f))` is `equal` to
  `(source-form f)` for every definition in `check/source/defs.l` and in `boot.l`, `hash.l` and `fonts.k`; a tree grammar
  over `(source-of f)` counts its symbols.
- [ ] **Step 2:** Run; expected: fails on `tokens-forms`.
- [ ] **Step 3:** Rewrite `maru-tokens.g` on `peg.g`'s rules, write `tokens-forms` as a tree grammar over the tokens, and
  the `<source>` input methods.
- [ ] **Step 4:** Run on all three evaluators; record the time for the largest definition in `boot.l`.
- [ ] **Step 5:** Register `source_tokens`, add the `check/lines` entry, commit.

## Not in this plan

Making text grammars fast: Warth's OMeta optimizer (`~/development/ometa/ometa-js/bs-ometa-optimizer.txt`: a null pass,
associative flattening, sequence inlining, jump tables, to a fixpoint) as Maru tree grammars over the rule bodies `grammar.l`
keeps, compiled by `compile-tpeg.l`, held to the unoptimized meaning; a plan of its own after this one. Also: statements in
body positions, a file read partway (`test-pepsi.l`'s grammar block), scope-aware renaming, the grammar engine's CST.
