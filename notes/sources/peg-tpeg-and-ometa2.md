# peg, tpeg and OMeta 2: what differs and how they relate (read 2026-11-03)

Sources: this tree's `peg.g`, `tpeg.g`, `peg-compile.l`, `compile-tpeg.l`, `parser.l`, `text-parser.l`
and their history; https://tinlizzie.org/ometa/ometa2.html and `OMeta2-rc.sar` (2009); OMeta/JS
`ometa-base.js` and `bs-ometa-optimizer.txt`; Warth's thesis (VPRI TR-2008-003). Local copies are in
`~/pkm/raw/vpri/` and `~/development/ometa/`.

## Two directions

The user's reading (2026-11-03): Piumarta worked bottom up, designing a kernel and back end for the VPRI
goals. Warth worked top down, assuming a high-level system that could run those goals. Nothing read here
states this, but the artifacts fit it. COLA, Maru and ir2 go down to machine code; OMeta is hosted on
Squeak and JavaScript, and is where KScript's compiler was written. The reports end in 2012 with the two
unjoined, and joining them is roughly what this repository is for.

Ideas did cross. Maru's `peg` matches structures (2011) after OMeta, and has memoization and left recursion
(February 2012) after Warth's 2008 paper. OMeta 2's consumed-by operator is, in Warth's words, "inspired by
a similar feature in Ian's COLA parser framework". So `tpeg` wasn't waiting for Warth's work, which was
published before Maru's PEG began. Why it exists isn't stated anywhere found.

## peg and tpeg

History: `peg` matches structures from 2011-02-17 (`861ee1c`), with memoization and left recursion from
2012-02-13 (`1c46096`, `cc49afe`). `tpeg` starts 2012-08-13 (`bac3529` "add text-only peg scaffold",
`4be1f08` "add text-only parser grammar"), derived from `peg.g`. `tpeg.l` is still built by `compile-peg.l`.

| Feature | `peg` | `tpeg` | Known by |
|---|---|---|---|
| Input | Any stream; one rule ran on a string and a list | Text | tested `peg`, read `tpeg` |
| List patterns | Yes, but a prefix matches | Parses them; the compiler stops | tested |
| Object literals | Yes | No compile rule | tested `peg`, read `tpeg` |
| Rule arguments | Pushed onto the stream, read by `.:a .:b` | Named, passed as function arguments | tested |
| Inline `{ }` grammars | Yes, with `repl.l` | No; separate compile step | tested `peg`, read `tpeg` |
| Source positions on lists | Yes | `set-list-source` does nothing | read |
| Hex in actions | `0x10` is 16 | `0` then a call to rule `x10` | tested |
| Grammar objects, static analysis | `<grammar>`, `$consumes-input?`, `$recursive-from?` | None | read |
| Generator | List-pattern rules in `peg.g` | `record-case` in `compile-tpeg.l` | read |
| `~"message"` | No | Yes | read |
| Memos | `notes` on each token | Array indexed by position | read |
| Speed on `tpeg.g`, same output | 721 ms | 269 ms | measured once on `eval` (hyperfine, 5 runs) |

The `tpeg` generator can't be written as rules because `tpeg` lost list patterns. That loss, not the
generator's style, is what to fix. Whether tokens explain the speed gap hasn't been profiled.

## OMeta 2

- Arguments are prepended to the input: `apply: aRule withArgs: args` makes a new `OM2Stream` cell for
  each. OMeta/JS's `_applyWithArgs` prepends whatever the rule's function doesn't declare.
- `form:` requires the nested match to reach `end`, and keeps one stream per value in `om2streams`, so
  re-entering a value reuses its memos. A stream is a memoizable table of data; `parser.l`'s `notes` and
  `text-parser.l`'s array are the same idea.
- `<...>` returns a sub-sequence of the input's own species; `@<...>` returns start and end indices.
- `^rule` calls the super-grammar's rule, with arguments if given: `^rrr(a1. a2)`.
- Rules are `=`, actions `[...]` or `-> [...]`, predicates `?[...]`, and list patterns `{ }`.
- The DBjr documents `ometaCalc-*.lbox` use it (`notes/sources/grammars/dbjr-ometacalc-*.ometa`), and the
  2012 report's KScript compiler is in it: about 450 lines of parser and back end, and 170 of expander.

## Warth's optimizer (`bs-ometa-optimizer.txt`)

A null pass rewrites every node, its `trans` choosing a rule from the node's tag with `apply`. `setHelped`
records a change and `optimize` fails without one. Passes inherit and override: `BSSeqInliner` once per rule,
then `(BSAssociativeOptimization | BSJumpTableOptimization)*`. His TODOs: stop the seq inliner when `seq` is
overridden, and add factoring. The thesis (§2.3.2) reports left factoring and jump tables.

## What of it

`docs/rfc/draft-ndn-maru-typed-tree-matching-00.md` builds on this. Thesis §2.5 suggests list patterns over
"objects that are not actually lists", after Wadler's views, which is the uniform stream interface.
