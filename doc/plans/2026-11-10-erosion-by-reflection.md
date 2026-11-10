# Erosion by Reflection Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Measure erosion and verbosity from what the system holds, each definition answering its own source, line count
and tokens through Maru methods, in one walk over raw forms, replacing the source-reading framework the check has now.

**Architecture:** `source.l` records, as `load` evaluates each top-level form, a `<source>` (file, lines, raw form) for
what the form defined, in a weak identity table keyed by that object (types, being numbers, in an array beside
`%type-names`). Selectors with a method per kind of object answer `source-text`, `line-count`, `source-tokens`,
`source-form` and `sources`; a `<source>` is a token stream tree grammars walk. Files that run at top level are read without
evaluating and their definitions lifted into records answering the same selectors. `maru-forms.g` walks raw forms once,
each node decided by its head, computing complexity, atoms, clone hashes, binders and verbose flags together.

**Tech Stack:** Maru (`eval`, `eval2`, `eval3`), tpeg text and tree grammars, `hash.l`'s weak identity tables.

**Spec:** this document's Design section, from the design consultation of 2026-11-09 and the user's rulings: "sources can
be introspected from the object representation within maru. a <foo> class should include a maru method to provide the
sources and line count. And sources should be iterable as the tokenized, symbolic version of itself"; "use the weak table,
raw forms". Background: `docs/plans/2026-11-08-erosion-metrics.md` (the metrics), `docs/plans/2026-11-09-grammar-engine.md`
(suspended, superseded for erosion by this plan).

## Design

- **Where time goes today** (measured: `eval -p`, phase timers, the consultation's reading): a fresh parser per list for the
  verbose rules (~94,000 lists), four or five walks per form, the tree read twice (`maru-lines.g`, then Maru's reader as an
  oracle). Wildcards cost little once a list is entered. The redesign reads once with the C reader, walks once, and makes no
  parser per list.
- **What loading keeps already:** every pair `read` makes carries `(path . line)`, kept through expansion. An `<expr>` keeps
  its expanded body (on `eval`, encoded: `Fixed<if>`, `<variable>`); `<form>`, `<selector>` (methods by type),
  `%type-names`/`%structure-fields`/`%structure-bases`, `grammar.l`'s grammars, `*loaded*`.
- **Missing, which this plan records:** a definition's raw form, its first and last lines, the file's text, comments and
  token boundaries. Definitions an action makes (pepsi's `eval` of built forms) have no source and answer none.
- **Raw forms, not expanded bodies:** expansion makes every `when` a false `empty-let`, adds 1 to complexity per `assert`
  (115 in the tree), and moves clone sizes through generated names (`_list_`). Complexity alone survives expansion.

## Global Constraints

- Everything in Maru languages; no C change (the weak table, not a field on `eval`'s C `struct Expr`); no shell tools inside
  the analysis.
- Any form `boot.l` and `boot2.l` share keeps one text in both (`boot_forms`).
- Every new behaviour runs on `eval`, `eval2 -b boot2.l` and `eval3 -b boot2.l` unless a task says otherwise.
- Grammars, structured once, then small analyses over the structure; no wildcard-walk of raw forms per analysis.
- `check/erosion`'s ledger must equal the metrics after every task that touches them; a move gets an entry saying why.
- `check/lines` gets an entry for every change in line count, saying why lines were added.
- Readable forms, never packed lines.

## Review Focus

1. A definition redefined later (a second `define-function f`): its source is the latest, never a list of both.
2. A file whose reading stops partway (it changes language, `test-pepsi.l`; or it's broken, `compile.l`): what was read
   answers its sources, the rest is one opaque `<source>` that counts its lines and defines nothing.
3. A data form of tens of thousands of atoms (`fonts.k`): tokenizing and the walk loop along spines, never a frame per
   element.
4. What erosion measures is the `lines` set's files, never what loading touched: a derived file (`*.g.l`) or one outside the set
   that a load reads defines things with sources, and none of it is counted; and a form that defines several things (a
   form expanding to several `define`s, a grammar whose rules become methods) has its lines counted once, not once per
   definition.
5. Symbols as `eval.c` reads them (`<pair>`, `*globals*`, `%eax`, `$rule`, `.long`, `a,b`): the tokens rebuild the same forms.

---

### Task 0: Measure before changing

**Files:**
- Create: `erosion-measure.l`
- Modify: `docs/plans/2026-11-10-erosion-by-reflection.md` (this file's Baseline section)

**Interfaces:**
- Produces: `./eval erosion-measure.l FILE...` prints CPU milliseconds per stage of today's check (read, code lines,
  complexity, binders, clone scan, verbose findings) and the count of rule invocations per grammar rule.

- [ ] **Step 1:** Write `erosion-measure.l`, timing each stage with `(subr "clock" ">l")` and counting rule calls by wrapping
  `source-parser-invoke-rule` and `text-parser-invoke-rule` around the existing `erosion.l` functions.
- [ ] **Step 2:** Run it on the erosion case's file set (Low Power Mode off; say so) and on the 40 files of
  `check/erosion.l`'s timing set, once with `-O` (unchecked accessors) to bound the type-check share.
- [ ] **Step 3:** Record the numbers in a Baseline section of this plan, and commit:
  `git commit -m "erosion: measured where its time goes, before reflection replaces it"`

### Task 1: Tokens and forms from text

**Files:**
- Create: `maru-tokens.g`, `maru-forms-from-tokens.g`, `source-tokens.l`
- Test: `check/source-tokens.l`

**Interfaces:**
- Produces: `(define-structure <token> (kind text start end line))`, kind one of `open close symbol number string char quote
  quasiquote unquote unquote-splicing comment`; `(source-text-tokens text)` → an array of `<token>`;
  `(tokens-forms tokens)` → the forms `read` makes from that text, each list's source `(path . line)` as `read` sets it.

- [ ] **Step 1: Write the failing tests** in `check/source-tokens.l`:
  `(map <token>-kind (array->list (source-text-tokens "(f 'x) ; c\n")))` is
  `(open symbol quote symbol close comment)`; a symbol token's text for each of `<pair> *g* %eax $rule .long a,b` is that
  text; and for every file named on the command line, `(tokens-forms (source-text-tokens (contents-of-file-named f)))` is
  `equal` to `(find-and-read f)`.
- [ ] **Step 2:** Run `./eval check/source-tokens.l boot.l hash.l fonts.k`; expected: fails, `source-tokens.l` not found.
- [ ] **Step 3:** Write `maru-tokens.g`, a text grammar after `peg.g`'s lexical rules (`symfirst symrest*` as two class
  matches a character, no rule call a character), `eval.c`'s escapes, `?c` characters and `0x` numbers; and
  `maru-forms-from-tokens.g`, a tree grammar over the token array (`sexpr = open items close | atom | quote sexpr …`, dotted
  pairs as `eval.c` reads them); `source-tokens.l` loads both.
- [ ] **Step 4:** Run the tests over every `.l` and `.k` file in the `lines` check's set except the eight that don't read
  whole; expected: `source tokens ok`.
- [ ] **Step 5:** Register `source_tokens` in `check/check.l` on all three evaluators, add the `check/lines` entry, commit.

### Task 2: Sources answered by what loading made

**Files:**
- Create: `source.l`
- Modify: `boot.l`, `boot2.l` (`load`: one hook, the same text in both)
- Test: `check/source.l`, fixture `check/source/defs.l`

**Interfaces:**
- Consumes: Task 1's `source-text-tokens`, `<token>`.
- Produces: `(define-structure <source-file> (path text starts tokens))`, `(define-structure <source> (file first last form))`;
  `*load-hook*` in both boots, called `(*load-hook* path form value)` after `load` evaluates each top-level form;
  selectors `source-of` (object → `<source>` or `()`), `source-text`, `line-count`, `source-tokens`, `source-form`, `sources`,
  with methods for `<expr>`, `<form>`, `<selector>` (`sources` its own and each method's), `<long>` (a type, through
  `%type-sources`), `<grammar>`, `<grammar-rule>`, and `<source>` itself; `<source>` answers `input.l`'s `in-enter` (1),
  `in-start`, `in-head` (a `<token>`), `in-tail`, `in-at-end` over its tokens.

- [ ] **Step 1: Write the failing tests:** `check/source/defs.l` defines a function `f` over three lines with a comment line
  inside, a form `g`, a selector `s` with methods on `<pair>` and `<long>`, a structure `<foo>`, and a grammar;
  `check/source.l` loads `source.l` then the fixture, and asserts: `(line-count f)` is 2 (the comment line doesn't count);
  `(source-form f)` is `equal` to the fixture's raw `(define-function f …)`; `(line-count <foo>)` and `(source-text <foo>)`;
  `(map line-count (sources s))` has three entries (the selector, two methods); re-reading `(source-text x)` through
  `tokens-forms` gives `(source-form x)` for each; `(parse-source <tok-kinds> $all (source-of f))` walks its tokens;
  defining `f` again makes `(source-form f)` the second definition.
- [ ] **Step 2:** Run `./eval check/source.l`; expected: fails, `source.l` not found.
- [ ] **Step 3:** Add `*load-hook*` to `load` in both boots (`(define *load-hook* ())`; after `(pval expr)`,
  `(and *load-hook* (*load-hook* name expr value))`); write `source.l`: the hook records a `<source>` for a top-level form
  whose head is a definer (`define`, `define-function`, `define-form`, `define-selector`, `define-method`,
  `define-structure`, `define-class`, `define-apply`, and tpeg's grammar definitions), keyed in a weak identity table by the
  object the form left defined (`%type-sources` for a type); first and last lines from the form's pairs (the last, the
  greatest line any pair in it was read on); the file's text kept once per file.
- [ ] **Step 4:** Run it on all three evaluators; expected: `source ok`.
- [ ] **Step 5:** Register `source` in `check/check.l`, document in CLAUDE.md, add the `check/lines` entry, commit.

### Task 3: Definitions lifted from files that only run

**Files:**
- Create: `source-lift.g`, a tree grammar over a file's raw top-level forms
- Modify: `source.l`
- Test: `check/source-lift.l`

**Interfaces:**
- Consumes: Task 1 (`tokens-forms`), Task 2 (`<source>`, the selectors).
- Produces: `(define-structure <definition> (kind name type params source))`; `(source-file path)` → `<source-file>`, read
  without evaluating; `(file-definitions path)` → the `<definition>`s its forms define (head-dispatched: one rule per definer,
  nested `(let () …)` bodies entered), each answering Task 2's selectors (this, not loading, is erosion's route: the files it measures run programs, conflict
  and need particular evaluators, so it reads them; loading answers the same selectors, which the tests hold equal); a
  file whose reading stops partway answers its read
  definitions and one opaque `<source>` for the rest (lines counted, no definition).

- [ ] **Step 1: Write the failing tests:** for `check/source/defs.l`, `(file-definitions …)` names `f g s <foo>` and the
  grammar, with the same line counts Task 2's loaded objects answer; for `test-pepsi.l`, the definitions before its grammar
  block and an opaque remainder whose line count is the rest's; a form defining two functions is counted once in the
  file's lines; for `compile.l`, a refusal naming the line it can't read
  past.
- [ ] **Step 2:** Run; expected: fails, `file-definitions` undefined.
- [ ] **Step 3:** Implement `source-lift.g` and `file-definitions` in `source.l`.
- [ ] **Step 4:** Run on all three evaluators; expected: `source lift ok`.
- [ ] **Step 5:** Register `source_lift`, add the `check/lines` entry, commit.

### Task 4: Metrics in one walk over raw forms

**Files:**
- Create: `maru-forms.g` (tree grammar, parent `<source-parser>`, field `binders`)
- Modify: `erosion.l`, `erosion-run.l`, `check/erosion.l`, `check/check.l` (the erosion case), `check/erosion`
- Delete: `maru-lines.g`, `maru-lines.l`, `erosion-complexity.g`, `erosion-binders.g`, `erosion-verbose.g`, `erosion-lines.g`

**Interfaces:**
- Consumes: Tasks 1–3 (`file-definitions`, the selectors, tokens).
- Produces: `maru-forms.g`'s `form` rule answering `(cc atoms hash)` for a raw form, verbose flags recorded with their
  spans, binders gathered in the field, each list entered once and decided by its head; `erosion-of` taking `<definition>`s
  (or loaded objects) and their `<source-file>`s, answering the same `<erosion-metrics>`.

- [ ] **Step 1: Write the failing tests:** every existing fixture in `check/erosion.l` (CC 1, 2, 4, 3; erosion at CC 10 and
  11; each verbose rule's example and plain form; the 12-atom clone boundary; rest parameters; quasiquote; the ledger)
  through the new path, plus: `(line-count d)` for each fixture definition equals the old `erosion-lines.g` count, and a
  verbose finding inside a 20-element list is reported once.
- [ ] **Step 2:** Run; expected: fails on the new entry points.
- [ ] **Step 3:** Write `maru-forms.g` and rewrite `erosion.l` over it; delete the files listed above; the erosion case
  measures through `file-definitions`, and the eight skipped files become read definitions plus opaque remainders
  (`compile.l` alone refused).
- [ ] **Step 4:** Run `make check CHECKS="erosion lines"`; expected: the ledger matches, or the only moves are the files
  newly measured, each given a `check/erosion` entry saying so; record the case's CPU time against Task 0's baseline.
- [ ] **Step 5:** Run the full suite (one at a time, `caffeinate -i make check`), document in CLAUDE.md, commit.

## Not in this plan

Scope-aware renaming (on `eval`, `<variable>` identity in encoded bodies could replace renaming by name); the grammar
engine's CST, handoff and dry parse (`docs/plans/2026-11-09-grammar-engine.md`, suspended); the classes-and-slots experiment.
