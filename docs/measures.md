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
- `erosion` (`check/erosion.l`, `erosion-run.l`, `docs/plans/2026-11-08-erosion-metrics.md`): SlopCodeBench's erosion and verbosity
  (Orlanski et al., NeurIPS 2026), per mille, over Maru's `.l` and `.k` files in the `lines` check's set, held to `check/erosion`'s
  ledger as `lines` is to `check/lines`: each metric equals the sum of its entries (`erosion-ledger.g`), so a rise or a fall is
  written down with its reason. Erosion is the share of complexity mass, CC x sqrt(SLOC), held by callables (each top-level
  definition, nested lambdas counted in it) of CC over 10; verbosity the share of source lines a verbose pattern
  (`erosion-verbose.g`) flags or a clone covers, a list of at least 12 atoms met twice once its definition's variables are
  renamed to one placeholder (`erosion-binders.g`), keyed by a 61-bit hash of its renamed form. CC counts decisions
  (`erosion-complexity.g`, a table of decision forms), and source lines leave out blanks and comments (`erosion-lines.g`).
  `maru-lines.g` reads each file to the forms Maru's own reader makes, which the run checks, each list's first pair holding a
  `<source-span>` (file, first and last line) in its source where `eval.c`'s reader holds `(path . line)`. Eight files that
  don't read whole (they change language partway, or are broken: `compile.l`) aren't measured, and must still fail to read.
  The fixtures are worked out by hand: CC 1, 2, 4 and 3 for a line, an if, a cond and an and; erosion 0 at CC 10 and all of it
  at 11; each rule's example flagged and its plain form not; a clone at exactly 12 atoms and none at 11.
