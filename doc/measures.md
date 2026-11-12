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
  its own reader (`erosion-read-file`): a `.g` file by tpeg, to one `(grammar-define …)` form; a script `tpeg-repl.l`
  reads (`#!./eval tpeg-repl.l`) by it, its forms and blocks where `tpeg-repl.l --forms`, run in a child process, says they
  lie (`erosion-spans.g`), and not the input a block takes, which only running it finds; any other by Maru's. Measuring a script runs it again, and a script that fails as it runs stops the check rather
  than be measured in part; a file it reads with `tpeg-read-file` is measured as a file of its own (`check/tpeg-cases.l`).
  And `maru-forms.g` (`maru-forms.l`) walks each top-level form once, each list entered once and decided by its
  head, for its complexity (one for each decision, each cond clause but an else, each `and` or `or` operand past the first; a
  template's decisions belong to the code it makes; cond clauses testing one variable against distinct constants, `(= x 1)`,
  `(= x 'k)`, are one lookup, a decision once), its forms, the verbose patterns in it (each ending its list, so a longer list
  goes on to the general case) and the variables it binds. `tpeg-forms.g`, its child, walks a grammar's form: each rule is a
  callable, each node of its tree a form, and a decision each repetition and predicate and, in a choice, each alternative
  tried in turn after the first, those led by distinct literals (a string's first character, an object, a list pattern's
  literal head) tried at once as one lookup on the next element, a decision if it has two keys or more. An action, a predicate's expression and a
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
