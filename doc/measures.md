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
  verbosity (Orlanski et al., NeurIPS 2026), per mille, counted in forms, over Maru's `.l` and `.k` files in the `lines` check's set
  (`check/erosion-files`, less `check/erosion-unread.l`'s),
  held to `check/erosion`'s ledger as `lines` is to `check/lines`: each metric equals the sum of its entries (`erosion-ledger.g`), so
  a rise or a fall is written down with its reason. A form is a list outside quoted data (a quoted datum, its `(quote ...)` too, is
  none; `()` is NIL, an atom, as in McCarthy's paper and Maru's `pair?`, though a tpeg list pattern enters it as an empty
  list, so a form is a pair; a backquote or comma is the reader's syntax, though the lists under it are forms). Erosion is the share of
  complexity mass, CC x sqrt(forms), held by callables of CC over 10, each a definition `source.l` reads from the file
  (`source-lift.g`, [Sources](source.md)), one inside a `(let () ...)` on its own, nested lambdas counted in it; verbosity the share
  of forms a verbose pattern flags or a clone covers, each counted once, a clone being a list of at least 12 atoms met twice once
  its definition's variables are renamed to one placeholder, keyed by a 61-bit hash of its renamed form. Each file is read by
  Maru's own reader, and `maru-forms.g` (`maru-forms.l`) walks each top-level form once, each list entered once and decided by its
  head, for its complexity (one for each decision, each cond clause but an else, each `and` or `or` operand past the first; a
  template's decisions belong to the code it makes), its forms, the verbose patterns in it (each ending its list, so a longer list
  goes on to the general case) and the variables it binds. Eight files that don't read whole (they change language partway, or
  are broken: `compile.l`) aren't measured, and must still fail to read. The fixtures are worked out by hand: CC 1, 2, 4 and 3 for
  a line, an if, a cond and an and; forms counted in definitions, lets, templates and quoted data; erosion 0 at CC 10 and all of
  it at 11; each rule's example flagged and its plain form not; a clone at exactly 12 atoms and none at 11; a finding inside a
  clone counted once. The case takes about 41 CPU seconds, from 102 when it read text through a grammar
  (`doc/plans/2026-11-10-erosion-by-reflection.md`'s Baseline).
  `./eval erosion-run.l --hotspots FILE…` prints only each callable over CC 10, `hotspot NAME FILE LINE CC MASS`, mass
  rounded to a whole number, for the evidence plans to minimize (`doc/evidence-plan.md`); the case asserts it on a
  fixture's CC 11 callable and not its CC 10 one.
