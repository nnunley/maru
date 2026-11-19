# Line count and erosion

The `lines` ledger and budget, and the erosion and verbosity metrics.

## Checks

- `lines`: the source line count equals the sum of `check/lines`. Any change
  in line count needs an entry there with its delta, and an entry that adds
  lines must say why. Derived files are marked `derived` in `.gitattributes`
  and not counted, nor is `notes/` (reference copies) or anything marked
  `unused` in the `nile/` and `gezira/` submodules; the C evaluator counts
  until `emit.l` generates it. Tests count. The budget is 20k lines, the
  STEPS target ("a modest 400-page book" one programmer can hold); it is
  soft, so the check reports the total but doesn't fail over it. Prefer a DSL or grammar (as `gen-asm-x86.k` generates
  the x86 assembler) over writing code out, tests included.
- `erosion` (`check/erosion.l`, `erosion-run.l`, `doc/plans/2026-11-10-erosion-by-reflection.md`): SlopCodeBench's erosion and
  verbosity (Orlanski et al., NeurIPS 2026), per mille, counted in forms, over the `.l`, `.k` and `.g` files in the `lines` check's set,
  held to `check/erosion`'s ledger as `lines` is to `check/lines`: each metric equals the sum of its entries (`erosion-ledger.g`), so
  a rise or a fall is written down with its reason. A form is a list outside quoted data (a quoted datum, its `(quote ...)` too, is
  none; `()` is NIL, an atom, as in McCarthy's paper and Maru's `pair?`, though a tpeg list pattern enters it as an empty
  list, so a form is a pair; a backquote or comma is the reader's syntax, though the lists under it are forms). Erosion is the share of
  complexity mass, CC x sqrt(forms), held by callables of CC over 10, each a definition `source.l` reads from the file
  (`source-lift.g`, [Sources](source.md)), one inside a `(let () ...)` on its own, nested lambdas counted in it; verbosity the share
  of forms a verbose pattern flags or a clone covers, each counted once, a clone being a list of at least 12 atoms met twice once
  its definition's variables are renamed to one placeholder, keyed by a 61-bit hash of its renamed form. Each file is read by
  its own reader (`erosion-read-file`): a `.g` file by tpeg, to one `(grammar-define …)` form, or, with no header,
  `(grammar-eval (rule …) ())`: in a file grammars add up, as `test-pepsi.l`'s blocks do, so a headerless file's rules
  (`peg.g`'s, for `<peg>`) join the grammar running when it's loaded; a script `tpeg-repl.l`
  reads (`#!./eval tpeg-repl.l`) by it, its forms and blocks where `tpeg-repl.l --forms`, run in a child process, says they
  lie (`erosion-spans.g`), and not the input a block takes, which only running it finds; any other by Maru's. Measuring a script runs it again, and a script that fails as it runs stops the check rather
  than be measured in part; a file it reads with `tpeg-read-file` is measured as a file of its own (`check/tpeg-cases.l`).
  And `maru-forms.g` (`maru-forms.l`) walks each top-level form once, each list entered once and decided by its
  head, for its complexity (one for each decision, each cond clause but an else, each `and` or `or` operand past the first; a
  template's decisions belong to the code it makes; cond clauses testing one variable against distinct constants, `(= x 1)`,
  `(= x 'k)`, are one lookup, a decision once, up to the first clause that tests something else), its forms, the verbose patterns in it (each ending its list, so a longer list
  goes on to the general case) and the variables it binds. `tpeg-forms.g`, its child, walks a grammar's form: each rule is a
  callable, each node of its tree a form, and a decision each repetition and predicate and, in a choice, each alternative
  tried in turn after the first, those led by distinct literals (a string's first character, an object, a list pattern's
  literal head) tried at once as one lookup on the next element, a decision if it has two keys or more, up to the
  first alternative led by no literal: that one may match anything, so it runs before any key after it is tested, and
  those are tried in turn. A script's spans file is written under `MARU_CHECK_TMP`, which the runner empties, when it is set. An action, a predicate's expression and a
  call's arguments are Maru, walked as code; an object literal is data. The lookups are ours: the paper scores Python
  only and says nothing of how a switch or a dispatch counts, and a choice made on the next element is one decision in
  how it runs, as a jump table makes it (Warth's optimizer, `doc/plans/2026-11-10-erosion-by-reflection.md`). Nine files that don't read whole (they change language partway, or
  are broken: `compile.l`, `check/tpeg-broken.g`) aren't measured, and must still fail to read. The fixtures are worked out by hand: CC 1, 2, 4 and 3 for
  a line, an if, a cond and an and; forms counted in definitions, lets, templates and quoted data; erosion 0 at CC 10 and all of
  it at 11; each rule's example flagged and its plain form not; a clone at exactly 12 atoms and none at 11; a finding inside a
  clone counted once. Grammar fixtures: CC 1, 2 and 3 for a sequence and two and three alternatives tried in turn; 2 for any number of
  distinct literals, a list pattern's literal head among them; a literal met again tried in turn, and strings sharing a
  first character; repetitions and
  predicates, and an action's decisions; a rule's forms, its parameters and an object literal; a script's forms and
  blocks, not its blocks' input, after its own output without a newline; a script that fails refused. The case takes about 82 CPU seconds (60 of them the `.l` and `.k` files, at the load of
  2026-11-11; it was 41 when first measured, from 102 when it read text through a grammar:
  `doc/plans/2026-11-10-erosion-by-reflection.md`'s Baseline). Memoized invokers make the walks slower, not faster: over
  the 41 grammar files the walks call a rule 38,174 times and find a memo 8 times.

- `erosion_attribution` (`check/erosion-attribution.l`, `erosion-attribute.l`, `erosion-vcs.l`, `erosion-files.l`, `diff.g`,
  `doc/rfc/draft-ndn-erosion-attribution-00.md`, `doc/plans/2026-11-19-erosion-attribution.md`): how a change moved
  erosion and verbosity, callable by callable. `diff.g`, one grammar, reads the change: git's unified diff (and `jj diff
  --git`'s) through its `diff` rule, and jj's conflict markers through `conflicted`, a hunk's lines and a diff side's one
  rule, jj's six markers one parametric rule, `marker :c`. Only the changed measured files are measured at the base (`git
  show` or `jj file show`); untracked ones are added, and `nile` and `gezira` are followed into, from the commit the
  superproject records at the base. Callables match by file and name across renames; one is edited when an added or
  removed line falls within its lines. Each metric's move splits into the edited callables' part, over the tree's whole,
  and the share, the rest, so the two sum; the base's values are its ledger's when that ledger holds (its erosion equals
  the base rebuilt from the changed files, exact for erosion), else the rebuilt ones, said so. A changed file's current
  callables are the whole tree's, so a copy of code in an untouched file is the edit's clone; its base callables count
  clones across the tree as it was (clone keys' counts add up file by file: the tree's now, less the changed files' now,
  plus their counts at the base), so a clone that was already there isn't. A changed file the check doesn't count
  (`notes/`, derived, unused) isn't attributed, and one that doesn't read is reported as unmeasured. A conflicted file is
  attributed side by side. The report: each metric's base, now, whole, edited and share; each callable that moved, edited
  first, by mass moved; and drafted `check/erosion` entries naming the edits that moved most. `make erosion-report
  [REV=…]` prints it (`./eval erosion-attribute-run.l [REV]`, `HEAD`, or `@-` under jj); when the erosion check's ledger
  doesn't match, it prints it after its own lines (`erosion-run.l --attribute`), from the metrics already measured. It
  writes nothing. The fixtures are git's and jj's own output: statuses, ranges, omitted counts, a content line of pluses,
  no newline at the end, renames, a path git quotes, a submodule; conflicts of three sides in both marker styles; a
  callable crossing 10, added and removed lines alone, a deleted file, a rename and edit, clones in the file and from an
  untouched one, a ledger that does and doesn't hold, the report's exact lines, conflicted sides, and git and jj
  repositories made in the check with a submodule and an untracked file.