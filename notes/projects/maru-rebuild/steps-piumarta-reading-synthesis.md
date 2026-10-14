# What the STEPS reports and Piumarta's papers mean for the Maru rebuild (2026-10-14)

Sources: the 15 notes in `notes/sources/` (STEPS proposal 2006, reports 2007–2012; Piumarta's COLA
white paper 2005, object models 2006 with Warth, OMeta 2007 with Warth, COLA kernel memo 2009, PEG
transformer 2010, both FREECO'11 papers, Maru's project page). Atomic ideas are in `notes/zettel/`.

## The design in one paragraph

Maru is the end of a line that starts with the 2005 COLA design, a system that describes and
implements itself. Meaning is attached through replaceable data: vtables whose `lookup` is a
message, then type-indexed `*evaluators*`/`*applicators*` tables. A small foreign seed grounds the
circle once, and a compiler written in the system ("the level shift") turns the system's
description of itself into machine code. The seed is discarded when the system regenerates itself
byte for byte. Grammars (PEG/OMeta) describe front ends cheaply, and Piumarta showed they can
describe middle and back ends too. The size target throughout STEPS was 20,000 lines of "meaning
code" for all of personal computing, counted down to the system's own bottom.

## What follows for the rebuild

1. **The budget is 20k lines, the STEPS target.**
   - Every STEPS document that states a target says 20,000. No report gives 10,000.
   - CLAUDE.md used to say "VPRI's 10k lines". On 2026-10-14 the user set the budget to 20k, and
     CLAUDE.md and the `maru-line-budget` memory now say so.
   - For scale: the 2012 report's Maru basis is 4,317 lines, and Nile's graphics plus compiler are
     about 1,500 lines. → [[steps-budgeted-20k-lines-of-meaning-code]]
2. **"`emit.l` generates the evaluator" has a precise acceptance test.**
   - Build from the C seed, rebuild with the result, and require byte-identical output. This is
     Maru's own documented process, and Pepsi's before it.
   - It needs a native back end for the host. On this Mac that means A64 (the table spec plus an
     A64 `emit`). On `ndn.lan`, IA-32 code already runs natively.
   - Until then the C evaluator counts, as the 2011 report's "count your own bottom" rule says.
     → [[self-hosting-is-shown-only-by-byte-identical-regeneration]],
     [[a-self-describing-system-must-count-its-own-bottom]]
3. **Shrink the counted C by the "ground as little as possible" rule.**
   - The seed needs type dispatch through the evaluator and applicator tables, primitive
     application, and the primitives. Anything else in `eval.c`'s 8,135 counted lines is a
     candidate to move into `.l`.
   - Next step: audit `eval.c` against that list.
     → [[ground-as-little-of-the-evaluator-as-possible]],
     [[type-indexed-tables-make-every-composition-replaceable]]
4. **Spend DSL effort on back ends.**
   - Parsers cost 130–250 lines in every STEPS example; code generation costs 1,100–1,400, plus a
     621-line assembler.
   - Piumarta's 2010 paper gives a working pattern: a back end as PEG rules over the IR, emitting
     through templates.
   - The table-driven assembler spec fits this, and the 2012 report names the exact saving the
     tables target: about 500 of the assembler's 621 lines covered x86 forms Maru never used. With
     tables, coverage costs rows instead.
     → [[compiler-size-concentrates-in-code-generation-not-parsing]],
     [[one-pattern-matcher-can-implement-every-compiler-stage]],
     [[assembler-coverage-should-cost-rows-not-code]]
5. **Load-time compilation of rows is Piumarta's own answer to indirection cost.** He measured a 30%
   cost for open dispatch and proposed staging to recover it. Our spike (13.6× slower interpreted,
   5.2× compiled at load) is the same trade, measured.
   → [[the-cost-of-meaning-by-indirection-is-recovered-by-staging]]
6. **Our counting ledger fixes the main weakness of the STEPS accounting.** Every STEPS size claim
   we could check depended on an unstated boundary, and some didn't reproduce. `check/lines`
   (a fixed count, `derived` attributes, a reason per delta) is the discipline the reports lacked.
   → [[a-line-count-needs-a-stated-boundary]]

## Open questions this reading raises

- **The original Maru.** Fetch the 1,750-line original (`piumarta.com/software/maru/original/`) and
  diff it against our 2.4-based `eval.l`/`emit.l`/`boot.l`. It's the author's reference for the
  minimal fixpoint.
- **Staging in 2.x.** What "staged evaluation" looked like in Maru 2.x: look for it in
  `ir.k`/`ir2.k`.
- **A reproducible 2012 basis.** The 2012 report's Maru (parser 248, codegen 1,357, assembler 621,
  runtime 1,320, library 771) may correspond to files in our tree. Mapping them would give an
  apples-to-apples count against the 4,317.
