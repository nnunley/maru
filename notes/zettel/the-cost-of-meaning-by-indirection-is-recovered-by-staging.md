---
title: "The cost of attaching meaning through data is recovered by compiling the dispatch ahead of use"
source: "../sources/piumarta-2011-open-extensible-composition-models.md"
created: 2026-10-14
schema_version: 1
links: [assembler-coverage-should-cost-rows-not-code, type-indexed-tables-make-every-composition-replaceable]
---

# The cost of attaching meaning through data is recovered by compiling the dispatch ahead of use

Attaching meaning through data (tables indexed by type, rows of an encoding table) makes a system open and small, but every use pays for a lookup and a generic interpretation step. Piumarta measured this: Maru's compiler ran 30% slower on the extensible, table-dispatching evaluator than on a conventional one. His answer was not to remove the indirection but to stage it, compiling the dispatch ahead of use so that the run-time path is specialised. He gave that as the reason the open composition mechanism exists, while noting the recovery itself lay beyond the paper; reviewers flagged that it was asserted, not shown.

The table-driven assembler spike for the Maru rebuild (2026-10-14) gives a measured instance of the same trade:

| Encoder | Encoding cost vs. generated encoder functions |
|---|---|
| Rows interpreted at run time | 13.6× slower |
| Each row compiled to a specialised lambda when loaded | 5.2× slower |
| Hand-specialised data representations (not built) | would close more of the gap |

The data stays the only source either way; staging changes only when the interpretation happens.

The general rule: keep meaning in data for openness and size, and buy back speed by compiling the data, rather than by hand-writing the specialised code.

Source: Piumarta 2011, *Open, extensible composition models* (VPRI TR-2011-002), §5.4 and §6 (primary; the recovery claim is unproven there); Maru rebuild table-driven assembler spike, 2026-10-14 (measured instance; see `docs/superpowers/specs/2026-10-14-table-driven-assemblers-design.md`).
