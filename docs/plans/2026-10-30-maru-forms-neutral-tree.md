# Maru Forms as the Neutral Tree — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `cexpr.g` and irl produce Maru forms that `maru.k` compiles, and `ir.k` is gone.

**Architecture:** `cexpr.g` gets C's full precedence ladder and emits core forms. irl's grammar emits forms plus three front-end markers (`irl-let`, `irl-struct`, top-level placement), which a pass in `compile-irl.l` expands before printing a `.k` program. `./eval2 ir-gen-c.k maru.k` compiles that program. `maru.k` gains zero-initialised globals.

**Tech Stack:** Maru (`eval`, `eval2`), tpeg grammars on `text-parser.l`, `maru.k` → ir2 → C, `check/check.l`.

**Spec:** `docs/rfc/draft-ndn-maru-forms-as-neutral-tree-00.md` (markers `[R-front-end-forms]`, `[R-core-forms]`, `[R-extension-forms]`, `[R-handoff-file]`, `[R-cexpr-forms]`, `[R-irl-via-maru]`, `[R-ir-retired]`, and `[R-zero-global]`).

## Global Constraints

- Every change in line count gets a `check/lines` entry with its delta and a reason (the `lines` check fails otherwise).
- Work on a branch worktree (`git worktree add -b <name> ../<name> main`, then `git submodule update --init`), fast-forward to main, delete the branch and worktree, push main.
- No commit attribution lines. RFC edits are `docs(rfc): …` commits; code commits use the repo's imperative style.
- Generated `*.g.l` files are not checked in; the `check` target in the Makefile builds them.
- Never run two `check/check.l` processes at once: each one deletes `/tmp/maru-check` first.
- Equality is `=`, logical negation `not`, and `?:` is `if` (RFC Field constraints).

## Review Focus

1. Operators that share a prefix with no spaces between them (`a<<b`, `a<=b`, `a&&b`, `a||b`, `a!=b`) must lex as the longer operator. The test is a `cexpr_forms` row.
2. A comment or line break inside an expression (`a /* c */ + b`) must give the same form as without it. The test is a `cexpr_forms` row.
3. A negative literal next to binary minus (`a - -1`) must be `(- a -1)`. The test is a `cexpr_forms` row.
4. A global whose initialiser is computed must be set before the first top-level statement after it runs. `test.irl`'s `fun := &printf`, followed by `fun("world\n")`, covers this in the `irl` check.
5. `?:` with branches of different types gives ir2's type-mismatch error, not wrong C. The test is a `check/irl-errors` case in Task 5.

---

### Task 1: Amend the RFC to what the probes found — done

Done before execution began (commit "docs(rfc): document where the namespaces disagree…"): the truth table and the condition rule under `[R-core-forms]`, the rule for global initialisers, `[R-zero-global]` with evidence `zero_global`, and the irl rows for imports, computed initialisers and struct literals.

### Task 2: Zero-initialised globals in maru.k [R-zero-global]

**Files:** Modify `ir2.k` (`ir-check-type <ir-define>`, lines 618–626) and `ir-gen-c.k` (`ir-gen-initialisation`, around lines 326–345); create `check/zero-global.k`; modify `check/check.l` (case `zero_global`, beside `ir2`).

**Interfaces:** Produces the `(define (name T))` typed form, used by Task 5.

- [ ] **Step 1: Failing test.** `check/zero-global.k` defines `(define-struct Pair ((a int) (b int)))`, `(define (zero-pair struct Pair))` and `(define (zero-int int))`. Its `main` prints `zero global ok` only if both start at 0, and if `zero-pair`'s `a` reads 5 after `(set-member zero-pair a 5)`. Case `zero_global` builds it with `ir2-build` and asserts that last line.
- [ ] **Step 2:** `./eval check/check.l zero_global` fails with `statement has no value`.
- [ ] **Step 3:** When the initialiser is an `<ir-nop>`, `ir-check-type <ir-define>` declares the global and makes no `<ir-set-var>`, and `ir-gen-initialisation` emits nothing for it. C zero-initialises file-scope objects, so the declaration alone is the zero.
- [ ] **Step 4:** `./eval check/check.l zero_global ir2 maru_check maru_test maru_gc` all PASS.
- [ ] **Step 5:** Add a ledger entry and commit.

### Task 3: core_forms check [R-core-forms]

**Files:** Modify `check/check.l` (a new case after `maru_test`); create `check/core-forms.l`.

- [ ] **Step 1: Write `check/core-forms.l`.** It defines `core-values`, an untyped list of the forms below, and a function that writes `tmp/core-forms.k`. That file holds one `(define-function cN int () (return F))` per form and a `main` that prints each result with `printf "%d\n"`.
  - Value forms (compare the integer): `(+ 2 3)` `(- 7 10)` `(* 6 7)` `(/ 17 5)` `(% 17 5)` `(<< 1 4)` `(>> 64 2)` `(& 12 10)` `(| 12 10)` `(^ 12 10)` `(- 5)` `(~ 5)` `(if (< 1 2) 3 4)`.
  - Truth forms (compare as truth): `(< 1 2)` `(< 2 1)` `(<= 2 2)` `(= 3 3)` `(!= 3 3)` `(>= 1 2)` `(> 2 1)` `(not (< 1 2))` `(and (< 1 2) (< 2 3))` `(or (< 2 1) (< 1 2))`.

  Truth forms are wrapped as `(if F 1 0)` on both sides.
- [ ] **Step 2: Add the case.** Case `core_forms` evaluates each form in-process (untyped), builds the `.k` with `ir2-build`, and asserts that the program's output lines equal the untyped results as strings.
- [ ] **Step 3:** `./eval check/check.l core_forms` PASSes. It should pass without any change to code under test; if it fails, the failing form shows where the namespaces differ, and that difference is a finding for the RFC, not something to paper over.
- [ ] **Step 4:** Add a ledger entry and commit.

### Task 4: cexpr.g ladder and forms [R-cexpr-forms]

**Files:** Modify `cexpr.g`; create `check/cexpr-forms.l`; modify `check/check.l`.

**Interfaces:** Produces these rules for irl to override:
- `primary`, `prefix`, `suffix` and `conditional`;
- `expression`, which by default is `conditional`;
- the levels `logor > logand > bitor > bitxor > bitand > equality > relation > shift > term > factor > unary`.

Each level is left-recursive like `term`, and `conditional = logor:c "?"_ expression:a ":" !"=" _ conditional:b -> `(if ,c ,a ,b) | logor`.

- [ ] **Step 1: Failing test.** `check/cexpr-forms.l` loads `text-parser.l` and `cexpr.g.l`, enables recursion, and `dumpln`s `(parse-string <cexpr> $expression S)` for each source S below, one per line. Case `cexpr_forms` compares the lines to the right-hand column. The rows are the RFC's `[R-cexpr-forms]` table, plus:
  - `a<<b` → `(<< a b)`
  - `a<=b` → `(<= a b)`
  - `a&&b||c` → `(or (and a b) c)`
  - `a!=b` → `(!= a b)`
  - `a /* c */ + b` → `(+ a b)`
  - `a - -1` → `(- a -1)`
- [ ] **Step 2:** The case fails: there are no shift, bitwise or logical levels, and defaults print `(name a)`.
- [ ] **Step 3: Rules.**
  - Defaults emit bare symbols and atoms.
  - The operator rules produce `* / % + - << >> < <= > >= = != & | ^ and or`.
  - `"&" !"&"` and `"|" !"|"` keep bitwise operators distinct from logical ones; `"<<"` is tried before `"<="` and `"<"`.
  - `unary = "-"_ unary:a -> `(- ,a) | "~"_ unary:a -> `(~ ,a) | "!" !"=" _ unary:a -> `(not ,a) | suffix`.
  - `suffix` handles calls: `primary:f ("("_ arglist:b ")"_ -> `(,f ,@b) :f)*`.
- [ ] **Step 4:** `cexpr_forms` PASSes. `irl` also still PASSes, since irl overrides its own operator rules until Task 5. Run `make -B cexpr.g.l` first.
- [ ] **Step 5:** Add a ledger entry and commit.

### Task 5: irl produces forms [R-irl-via-maru] [R-extension-forms] [R-handoff-file] [R-front-end-forms]

**Files:** Modify `irl.g`, `compile-irl.l`, `test.irl` (line 1 only), `check/check.l` (case `irl`); create `check/irl-errors.irl`.

**Interfaces:**
- Consumes Task 4's rule names and Task 2's `(define (name T))`.
- Produces `compile-irl.l`, which prints one `.k` program to stdout for the `.irl` file it's given.

- [ ] **Step 1: Failing test.** Case `irl` becomes:
  - `run "irl-gen" "./eval compile-irl.l test.irl > tmp/irl.k"`;
  - `ir2-build "irl" tmp/irl.k`;
  - assert the same nine output lines as today, with no x86_64 gate.

  Change `test.irl` line 1 to `import int(char*, ...) printf;`. It fails, because `compile-irl.l` still evaluates `ir.k` forms.
- [ ] **Step 2: irl.g.** Delete irl's overrides of `factorop`, `termop`, `relop`, `ifexp` and `relation` so `cexpr.g`'s ladder applies, then rewrite the remaining actions to forms per the RFC's irl table:
  - **Types:** a type is a list of type tokens. `T*` appends `*`. `T(A, B)` is `((,@T ,@A ,@B))`, with `...` accepted as the last parameter. `T()` is `((,@T ...))`.
  - **Declarations:** `(name ,@T)`.
  - **`let T i := e;`** emits `(irl-let (i ,@T) e)`.
  - **`struct T(args)`** emits `(irl-struct T args…)`.
  - **Toplevel:** `import` emits `(define (name ,@T [*]) (extern name))`, with `*` appended when `T` is a function type.
  - **`for`, `where` and `finally`** expand exactly as they do today, with forms in place of `ir-*` (`let`/`while`/`set`, `(let () s f)`).
  - **`irl.g`** contains no `ir-`.
- [ ] **Step 3: compile-irl.l.** `(irl-program forms)` does the following, in order:
  1. Expands `irl-let` within each `(let () …)` body, so that the rest of the body nests inside `(let (((i T) e)) …)`.
  2. Expands `irl-struct` from the `define-struct` forms seen so far.
  3. Rewrites `(addressof f)` to `f` for each imported function `f`.
  4. Keeps `define-struct`, `define-function` and constant `define`s at top level. A `define` whose initialiser is computed becomes `(define (name T))` plus `(set name e)`.
  5. Collects every other form, in source order, into `(define-function main int () … (return 0))`.

  It prints each resulting form with `dumpln`.
- [ ] **Step 4:** `./eval check/check.l irl` PASSes on arm64 natively. If a `test.irl` construct has no working mapping, stop and report it rather than changing `test.irl` beyond line 1.
- [ ] **Step 5: Review Focus 5.** `check/irl-errors.irl` contains `int x := 1 < 2 ? 1 : "s";`. The `irl` case asserts that compiling it through `ir2-build` fails, and that its `.err` contains `type mismatch`.
- [ ] **Step 6:** Run the whole suite with `make check`, add a ledger entry, and commit.

### Task 6: Retire ir.k [R-ir-retired]

**Files:**
- Delete `ir.k`, `irgol.g`, `compile-irgol.l`, `test.irgol` and `test-ir.k`.
- Modify the `Makefile` (the `irgol.g.l`, `test-compile-irgol`, `test-ir` and `test-compile-irl` rules, and the `check` prerequisites), `check/check.l` (case `irl`'s irgol assertion; a new case `ir_retired`), and `CLAUDE.md` (Verify list; the "Known not to work" line on `compile-irgol.l`).

- [ ] **Step 1: Failing test.** Case `ir_retired` asserts that `git grep -l 'require "ir.k"'` prints nothing, that `grep -c 'ir-' irl.g compile-irl.l` is 0 for both files, and that none of the five deleted files exists. It fails while they exist.
- [ ] **Step 2:** Delete the files and the rules. Make `test-compile-irl` run the Task 5 pipeline.
- [ ] **Step 3:** `make check` passes. The RFC corpus result for this draft, from `rfc-run docs/rfc/draft-ndn-maru-forms-as-neutral-tree-00.md`, is 0 failing blocks.
- [ ] **Step 4:** Remove the RFC's `**Corpus:**` line, run `rfc-lint` to exit 0, add a ledger entry for the removal (a large negative), and commit. Publishing is a separate decision for the user.
