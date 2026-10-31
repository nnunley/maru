# Laws and Rules — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Maru gains a rule-and-law language whose rules generate, check and enumerate inputs, and whose laws test `cexpr.g`, Nile and the rule system itself, all in Maru.

**Architecture:** A first-order logic engine (`rules.l`) runs one rule set in three modes; higher-order rules expand into it. A generator walks tpeg grammar records (`grammar-gen.l`). Law files (`check/laws/*.law`) are parsed by `law.g`, which inherits `cexpr.g`, and run by `check/law.l`, which prints one outcome line per law. Nile's compiler, moved onto this tree's Maru, is the Nile reference.

**Tech Stack:** untyped Maru (`eval`), tpeg grammars on `text-parser.l`, `check/check.l`.

**Spec:** `docs/rfc/draft-ndn-maru-laws-and-rules-00.md`. The spike that measured it is `notes/spikes/laws/` (README there); port from it, don't copy it blind.

## Global Constraints

- Everything runs in Maru: no shell, C compiler or host tool inside a law, the engine or the runner. The one exception the spec allows is forking a reference that exits on its first error (`fork`/`waitpid`/`_exit` via `subr`, as `check/check.l` does).
- Every change in line count gets a `check/lines` entry with its delta and reason. `notes/` is not counted.
- Branch worktree per task group, fast-forward to main, delete the branch. No commit attribution. RFC edits are `docs(rfc): …`; Nile submodule commits are made in `nile` first, then the pointer. Pushing the `nnunley/nile` fork is public: confirm with the user first.
- Never run two `check/check.l` processes at once.
- Maru reads `?x` as a character; logic variables are `$x` internally (the law compiler maps lower-case names to them).
- `eval` resolves free globals when a closure is created: define a function before any function that calls it. `eval.c:372` notes broken escape analysis for nested lambdas with free variables; the spike hit an unexplained `undefined variable` in a closure inside `cond`, so when one appears, split the function rather than chase it.
- Defaults (spec Configuration): `size` 3, `trials` 100, `seed` 42, `starved_ratio` 20. Builtin numerals: `0 1 2 0.5 10` plus numbers the law file mentions.

## Review Focus

1. A generated sentence that crashes `eval` (as `0xq` did) kills the run; the runner prints `law NAME:` before evaluating a law, so the last line names it. Test in Task 6.
2. A goal no rule can satisfy (`expr(env, Boolean, e)` with no Boolean rule) is `STARVED`, not a hang or a pass. Test in Task 6.
3. A filler goes into a template as text: `{x} * c` with `x` = `a + b` parses as `(+ a (* b c))`. Rules that need grouping write it, as the Nile rules do. Test in Task 5, and the RFC says so (Task 1).
4. Non-ASCII operators (`√ ∧ ≤ ¬`) survive filling and parsing. Test in Task 9.
5. A malformed law file fails with its line number, before any law runs. Test in Task 5.

---

### Task 0: Nile's compiler on this tree's Maru (prerequisite)

Execute Task 3 of `docs/plans/2026-10-15-nile-runtime-in-maru.md` as written (its Task 2 is done: `boot2_strings` exists). It restores `print-structure.l`, runs Nile's compiler on `eval2`/`boot2.l`, deletes `nile/compilers/maru/maru/` and adds case `nile_compile`. The vendored copy is marked `unused`, so the `lines` total doesn't drop; the repository loses 34,840 lines and the Boehm GC dependency (`gceval`), whose arm64 build failure was only Homebrew's `/opt/homebrew` prefix.

### Task 1: Amend the RFC [R-reference-verdicts] [R-template-holes]

**Files:** `docs/rfc/draft-ndn-maru-laws-and-rules-00.md`.

- [ ] **Step 1:** Replace "moving Nile onto this tree's Maru is also when its fatal errors become values, so the Nile laws run in-process" with: Maru has no non-local exit, so a reference that exits on error runs forked until one exists; the extension point is a non-local exit in `eval.c` and `eval2`, listed under Out of Scope.
- [ ] **Step 2:** Under Templates, add that a filler is inserted as text and grouping is the template author's (Review Focus 3).
- [ ] **Step 3:** `rfc-lint` exits 0; two-key commit `docs(rfc): …`.

### Task 2: `cexpr.g` hex digits, and the crash `0xq` exposed

**Files:** `cexpr.g` (`higit`), the crashing primitive (find it), `check/cexpr-forms.l`.

- [ ] **Step 1: Failing rows** in `check/cexpr-forms.l`: `"0xff"` → `255`, `"0xFF"` → `255`. A separate assertion runs `./eval` on a one-line file parsing `0xq` with `$expression` and requires an exit status other than 139 (it parses as `0` followed by unparsed input, or fails to parse).
- [ ] **Step 2:** `./eval check/check.l cexpr_forms` fails (exit 139 on the `0xq` assertion).
- [ ] **Step 3:** Find why `make-number 16` over `q` segfaults (superpowers:systematic-debugging); fix the cause, then make `higit = [0-9A-Fa-f]`.
- [ ] **Step 4:** `cexpr_forms irl lines` PASS; ledger entry; commit.

### Task 3: The engine, `rules.l` [R-rules-three-modes] [R-size-bound] [R-occurs-check] [R-builtins]

**Files:** create `rules.l`, `check/rules-test.l`; modify `check/check.l` (case `law_engine`, which later also runs `check/laws/engine.law`).

**Interfaces — Produces:**
- A rule is `(name conclusion premise…)`; a rule set is a list of rules. Logic variables are symbols starting `$`.
- `(rules-generate rules goal size)` → a value for the goal's last argument, or `()`.
- `(rules-holds? rules goal size)` → non-nil when the goal holds.
- `(rules-enumerate rules goal size)` → every distinct value of the goal's last argument.
- `(rules-seed n)`; `(rules-fired)` → names of rules used in successful derivations since the last seed.
- Builtins: `(in x t list)` (the law syntax `x: t in list`), `(number n)`, `(= a b)`.

- [ ] **Step 1: Failing test** `check/rules-test.l` prints `rules ok` only if: the three modes agree on a two-rule relation (every generated value is in the enumeration, and holds); at size 0 a recursive rule never applies; unifying `$x` with `(f $x)` fails; `(in a t [a: Number])` binds `t` to `Number`; `(number n)` enumerates exactly `0 1 2 0.5 10`; the same seed gives the same first value twice. Case `law_engine` asserts its last line.
- [ ] **Step 2:** `./eval check/check.l law_engine` fails (no `rules.l`).
- [ ] **Step 3:** Port the engine from `notes/spikes/laws/logic.l` (occurs check included) with rule sets passed explicitly, not global, so mutants (Task 10) swap them.
- [ ] **Step 4:** `law_engine` PASS; ledger; commit.

### Task 4: Higher-order rules [R-higher-order-expansion] [R-facts-from-source]

**Files:** modify `rules.l`; extend `check/rules-test.l`.

**Interfaces — Produces:** `(rules-expand items)` → a first-order rule set. Items: `(rule name (param…) conclusion premise…)`, `(fact goal)`, `(schema var (value…) item)`, `(facts (relation…) function)`. A relation parameter applied as `($r x)` is specialised per relation passed, named `relation[passed]`, carrying the passed goal's arguments.

- [ ] **Step 1: Failing assertions:** a schema over `"+" | "-"` yields two facts; `list_of(expr(env, t), es)` expands to one specialised `list_of` whose enumeration at size 2 matches a hand-written first-order version; a parameter applied to an unknown relation is rejected with `E_UNKNOWN_RELATION`; `facts` from a function returning a fact of an unlisted relation is rejected.
- [ ] **Step 2–4:** fail, implement, PASS; ledger; commit.

### Task 5: Law files: `law.g` and the compiler to forms [R-template-holes] [R-hole-kinds]

**Files:** create `law.g`, `law-compile.l`; modify `Makefile` (`law.g.l` rule; `check` prerequisites); create `check/laws/fixtures/syntax.law`, `check/law-compile-test.l`.

**Interfaces:**
- Consumes: `cexpr.g`'s `expression` (inherit, as `irl.g` does); Task 4's item forms.
- Produces: `(law-file-read path)` → items: Task 4's rule items plus `(let name value)`, `(set Name (member…))`, `(under-test name…)`, `(reference name param…)`, `(defaults (key . n)…)`, `(law name bindings conditions claim method size)`. A template is `(template lang text)`. `(template-fill lang text bindings)` → text, `{{`/`}}` → braces; `(template-parse lang text)` parses with the language's registered class and rule (`(template-language 'cexpr <cexpr> 'expression)`, `'nile <nile-parser> 'expr`).

- [ ] **Step 1: Failing test** `check/law-compile-test.l` (case `law_cexpr` for now): the spec's Formal Grammar example (minus `facts … from`) reads to the expected items; `{x} * c` filled with `a + b` parses to `(+ a (* b c))` (Review Focus 3); `{{ x }}` fills to `{ x }`; a file with an error on line 3 fails with `line 3` in the message (Review Focus 5); a hole whose variable has no binding is `E_TEMPLATE_PARSE` naming the template.
- [ ] **Step 2–4:** fail, implement (holes are filled by text; their kind comes from the variable's domain, never the parser), PASS; ledger; commit.

### Task 6: The runner `check/law.l` and its outcomes [R-law-outcomes] [R-weak-laws] [R-reference-verdicts]

**Files:** create `check/law.l`, fixture law files `check/laws/fixtures/{tested,proved,refuted,starved,vacuous,inconclusive,crash}.law`; case `law_rules` (fixtures part).

**Interfaces — Produces:** `./eval check/law.l FILE…` prints, per law, `law NAME:` (flushed before evaluation, Review Focus 1) then one of `TESTED n`, `PROVED n`, `REFUTED x=v … seed=s`, `STARVED k of n`, `VACUOUS`, `INCONCLUSIVE status=s input=…`. A reference returns `accept`, `reject` or `(crash status)`; anything else is a crash. Seeds: `seed` plus the law's position in the file.

- [ ] **Step 1: Failing case** `law_rules` runs each fixture and asserts its exact outcome word, and for `refuted.law` (claim `a - b = b - a` over `number`) that the reported values are the smallest failing pair under shrinking (numbers shrink toward 0; rule-built values by regeneration at smaller sizes) and that re-running with the printed seed reproduces it. `starved.law` asks a goal no rule satisfies (Review Focus 2). `vacuous.law`'s claim names nothing on its `under test:` line. `inconclusive.law`'s reference returns `(crash 139)`. `crash.law` calls `(exit 7)`; the last output line starts `law boom:`.
- [ ] **Step 2–4:** fail, implement (port the law loop from `notes/spikes/laws/meta.l`; `STARVED` after `trials × starved_ratio` draws), PASS; ledger; commit.

### Task 7: `check/laws/engine.law` [R-engine-laws]

**Files:** create `check/laws/engine.law`; case `law_engine` also runs it.

- [ ] **Step 1:** Laws, with terms from rules (atoms, `lvar`, pairs, as `notes/spikes/laws/m9.l`): `unify(a, b) = s ⇒ walk*(a, s) == walk*(b, s)` (TESTED); unify is symmetric in success; generate ⇒ holds and generate ∈ enumerate for a toy relation (PROVED at size 2). The engine's builtins are exposed to laws as `unify`, `walk_all`, `holds`.
- [ ] **Step 2:** Mutation check, by hand once: removing the occurs check makes the run fail (crash or REFUTED); restore.
- [ ] **Step 3:** `law_engine` PASS; ledger; commit.

### Task 8: `grammar-gen.l` and `check/laws/cexpr.law` [R-grammar-domain] [R-grammar-acceptance] [R-template-holes] [R-hole-kinds]

**Files:** create `grammar-gen.l`, `check/laws/cexpr.law`; case `law_cexpr` also runs it.

**Interfaces — Produces:** `(grammar-domain class paths)`; `(grammar-sentence domain rule fuel)` → text the compiled parser accepts in full, or `()` after 50 tries; `(grammar-acceptance domain rule n fuel)` → `(accepted . n)`. Fuel is split among a sequence's parts; spent fuel takes cheap alternatives that can't reach the rule being expanded (`notes/spikes/laws/gen.l`).

- [ ] **Step 1:** `cexpr.law`: over `a, b, c, d, e: cexpr.primary`, `` `a?b:c?d:e` == `a?b:(c?d:e)` ``; `` `a-b-c` == `(a-b)-c` ``; `` `a /* x */ + b` == `a + b` ``; and a deliberately false law in a fixture, `` `a-b-c` == `a-(b-c)` ``, REFUTED. The runner reports acceptance for each grammar domain; `law_cexpr` asserts `primary` acceptance is at least 80% (spike: 92%).
- [ ] **Step 2–4:** fail, implement, PASS; ledger; commit.

### Task 9: The Nile reference and `check/laws/nile.law` [R-rule-set-laws] [R-facts-from-source] [R-reference-verdicts] [R-template-holes]

**Files:** create `check/laws/nile-reference.l`, `check/laws/nile.law`; case `law_nile`.

**Interfaces:**
- Consumes: Task 0's Nile compiler on this tree's Maru; Tasks 3–6.
- Produces: `(nile-accepts text type)` → verdict, forked per call, the wrapper `\f(a:Number, b:Number, p:Boolean, q:Boolean) : T` with the body indented four spaces; `(nile-signatures)` → `infix`/`prefix` facts read from `nile/compilers/prelude.nl` through Nile's grammar.

- [ ] **Step 1:** `nile.law` is the spec's example with `facts infix, prefix from nile_signatures`, plus laws sound, generate-checks (TESTED), coverage (every rule fired), agree against looser rules `uexpr` (TESTED, 0 disagreements), and a law that `√(a) ≤ a` style non-ASCII expressions round-trip (Review Focus 4). A fixture law feeds `ϫ():ρ` / `forall_` to a definition-level reference and must be `INCONCLUSIVE`, not a rejection (Nile's resolver crash).
- [ ] **Step 2–4:** fail, implement, PASS; ledger; commit.

### Task 10: Mutant adequacy [R-rule-set-laws] [R-weak-laws]

**Files:** modify `check/law.l`; extend `check/laws/nile.law`.

**Interfaces — Produces:** law syntax `law adequate: mutants of expr by exhaustion size 1. sound, agree` — the runner builds every mutant (each constant argument of each fact replaced by each other member of its `set`; each fact removed; each premise of each rule removed), and for each runs the named laws by `EXHAUST` over values that use the mutated rule. Outcome `PROVED n` when every mutant fails a law, else `REFUTED` naming the survivors.

- [ ] **Step 1:** Failing: `adequate` over the Nile rules must be `PROVED` with the full mutant count (spike: 42 of 42 at size 1 for 14 facts × 3 operators).
- [ ] **Step 2–4:** fail, implement, PASS; ledger; commit. Also add the formal-grammar line for `mutants of` to the RFC (`docs(rfc):` commit).

### Task 11: Close out

- [ ] **Step 1:** `CLAUDE.md` Verify list: `law_engine`, `law_cexpr`, `law_nile`, `law_rules`, each in one sentence.
- [ ] **Step 2:** `make check` green; `rfc-run docs/rfc/draft-ndn-maru-laws-and-rules-00.md` 0 failing blocks.
- [ ] **Step 3:** Remove the RFC's `**Corpus:**` line; `rfc-lint` exits 0; two-key commit. Publishing is the user's decision.

## Requirement coverage

| Marker | Task |
|---|---|
| R-rules-three-modes, R-size-bound, R-occurs-check, R-builtins | 3 |
| R-higher-order-expansion | 4 |
| R-facts-from-source | 4, 9 |
| R-template-holes | 1, 5, 8, 9 |
| R-hole-kinds | 5, 8 |
| R-grammar-domain, R-grammar-acceptance | 8 |
| R-law-outcomes | 6 |
| R-weak-laws | 6, 10 |
| R-reference-verdicts | 1, 6, 9 |
| R-rule-set-laws | 9, 10 |
| R-engine-laws | 7 |
