# Erosion and verbosity, ratcheted

The user, 2026-11-08: "we write the slopbench erosion metrics, and add them to our checks", option (b): a ratchet.

## Why

SlopCodeBench (Orlanski et al., NeurIPS 2026, arXiv 2603.24755) measures how code written by agents degrades over
iterations. Agent code averaged 0.68 erosion and 0.32 verbosity against 0.31 and 0.11 for human repositories, and erosion
rose in 80% of agent trajectories. Most of this tree is agent-written. A ratchet catches a rise when it happens, and makes
each one a decision with a reason, as `check/lines` does for size. The paper finds erosion predicts cost rather than
pass rates, so this guards maintainability, not correctness.

## The metrics, as the paper defines them

- **Erosion.** A callable's mass is `CC(f) × √SLOC(f)`, its cyclomatic complexity times the square root of its source
  lines. Erosion is the share of all mass held by callables with `CC > 10` (Radon's bound):
  `Σ [CC(f) > 10] · mass(f) / Σ mass(f)`.
- **Verbosity.** `|rule-flagged lines ∪ clone lines| / LOC`: lines a verbose-pattern rule flags, together with lines inside
  duplicated code, each counted once, over all source lines.

## What carries over to Maru, and what is ours

- **Files.** The `lines` check's set, limited to Maru's s-expression files (`.l`, `.k`): 38.8k of the tree's 45k lines
  that aren't C. Grammars (`.g`), irl and the C evaluators need readers of their own and come later.
- **Callables.** Each top-level `define-function`, `define-method`, `define-form`, `define-selector`, `define-apply` and
  `define` of a `lambda`. A `lambda` inside one counts toward it, not separately (ours: Radon scores closures apart).
- **Cyclomatic complexity.** 1, plus one for each `if`, `when`, `unless`, `while` and loop form (`for`, `list-do`,
  `array-do`, `hash-do` …), each `cond` clause but an `else`, and each operand of `and` and `or` past the first. The
  decision forms are a table, data rather than code.
- **SLOC.** A callable's lines that hold something besides blanks and a comment.
- **Clones.** A subtree of at least 12 atoms that occurs twice or more, compared after renaming every variable its
  definition binds (parameters, `let`s, loop variables) to one placeholder: a type-2 clone, where what a variable is called
  doesn't matter. Names a definition doesn't bind, its own name among them, stay. Every line of every occurrence counts.
  Renaming goes by name over the whole definition, not by scope: a parameter named `list` renames the definition's calls
  of `list` too. That is an approximation until grammars see environments (the grammar-engine work: handoff between
  grammars, decorators around them, reflection on them).
- **Rules.** Maru's own verbose patterns, as a tree grammar with one rule per pattern, each with a test that it flags its
  example and passes the plain form. To start: `(if c 't ())` for `c`, `(if c () 't)` for `(not c)`, `(let () x)` with
  one body form, `(not (not x))`, a `cond` of one clause and an `else` for an `if`, and `(= x ())` for `(not x)`. The
  paper's 137 Python rules don't transfer; ours grow as patterns are found.

## How it's built

- **Reader.** A text grammar (`maru-lines.g`) reads Maru source to forms that know their first and last lines: Maru's own
  reader keeps positions only inside the C evaluators. It reads strings and their escapes, characters, comments,
  quote, quasiquote and unquote. A file it can't read fails the check, naming the file and line.
- **Walking.** Complexity, clones and the rules walk those forms with tree grammars (`<source-parser>`), not `cond` chains.
- **The check, `erosion`.** It computes both, per mille, over the tree and per file, and prints the totals and the ten
  callables of greatest mass. `check/erosion` is a ledger like `check/lines`: lines of `erosion +N reason` and
  `verbosity -N reason`. The check fails unless each metric equals its ledger's sum, so a rise, and a fall too, is
  written down with its reason. The ledger starts at today's values, with one entry saying so.

## Tests

- The reader against Maru's own `read` on every `.l` and `.k` file: the same forms.
- Complexity of small functions worked out by hand: a straight line 1, an `if` 2, a `cond` of three clauses and an
  `else` 4, `(and a b c)` 3.
- Erosion and verbosity of fixture files with known answers, including the boundary at CC 10 and 11.
- Each rule flags its example and passes the plain form; clones are found across files and renamed variables, and a
  subtree of 11 atoms isn't one.
- The ratchet: a fixture tree whose metric moved without an entry fails, with one it passes.

## Not in this item

Grammars, irl and C; fixing the tree to lower the numbers; per-file ratchets.
