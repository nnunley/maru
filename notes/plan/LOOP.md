# The stage 1 evidence loop

Goal: `notes/plan/tree-matching.john`'s goal is green, which is stage 1 of
`docs/rfc/draft-ndn-maru-typed-tree-matching-00.md`. Background on approach and pitfalls, not a task list:
`docs/plans/2026-11-03-tree-matching-stage-1.md`. Its Global Constraints do bind, but its tasks predate the current design: where they differ, the RFC's "Parser types and instances", "Streams" and "The input stack" decide.

Each iteration, with fresh eyes:

1. `notes/plan/record` runs the checks, appends evidence, and prints what's green and John's plan. Read it.
2. Take the first thing in the plan, and as much as naturally goes with it. Read the failing check's log.
3. Change the code until that check passes, keeping earlier ones green.
4. `notes/plan/record` again. Add `check/lines` entries as needed: `make check CHECKS=lines` names the delta.
5. Commit, code and `notes/plan/evidence.john` together, with a prose message saying what changed and why.
6. Report: what's green now, what you learned, and anything the next iteration should know. Add that to the end of this file too.

When `Calc`, `Apply`, `Literals` and `Speed` are green, run `notes/plan/record full` to test `Suite`.

## Stop and report, without working around it

- A check looks wrong, or could only pass by changing it. The checks and the expected values were fixed before the code. Never
  weaken, delete or edit a `check/tpeg-*` file or `tree-matching.john`; report what you think is wrong and why.
- The evidence seems to say a decision in the RFC is wrong: arguments on the input, whole-list matching, data separate from
  state, two parser types, memos on the stream, one grammar object with a swapped input. Report it; don't reopen it.
- `Speed` fails and you can't see how to fix it without changing what's specified.
- Something outside the plan's Global Constraints has to change.

## Rules

- Never edit `notes/plan/evidence.john` by hand; only `record` writes it.
- Be a good neighbour: other agents share this machine. Use `nice`, and a `timeout` on anything that might loop, since an evaluator
  with no tail calls can hang or overflow silently. Never kill a process you didn't start, and never use a broad `pkill`.
- Work only in `.worktrees/tpeg-trees`, on branch `tpeg-trees`. Don't push, and don't merge to `main`.
- Commits carry no attribution lines.

## Notes from iterations

**The design changed after iteration 2.** `text-parser.l` is back to `main`'s, pure text. `<source-parser>` in a new `source-parser.l` matches any source through stream cells, with `self.position` holding a cell, so
`value-pe`'s save and restore carry over. `compile-tpeg.l --on source` targets it. `input.l`'s `in-after`, `in-span` and `in-class` go. Notes below from iterations 1 and 2 describe the old shape; their lessons on Maru still hold.

Checks corrected after iteration 1: `<countdown>` no longer uses `nth`, which only `boot2.l` has and which is 1-based there; and the binary cases run where `data` exists, which isn't `eval2`, whose Data type is a stub.
- Iteration 1 (Selectors): `input.l` is written (the `in-*` selectors, with methods for nil, pairs, strings, `<data-stream>`, longs), and `text-parser.l` requires it. Scoreboard after the change: Speed green (484 ms main, 522 ms here); Selectors, Source, Lists, Args, Apply, Memos, Literals, Calc and Suite red. Nothing else is green.
- Selectors is blocked by the checks, not by `input.l`, so this is a stop-and-report:
  1. `check/tpeg-try.l` defines `<countdown>`'s `in-head` with `nth`, which only `boot2.l` defines. `./eval` fails loading it ("undefined variable: nth"), and every `tree_*` case loads it, so they all fail under `eval`.
  2. `boot2.l`'s `nth` on a pair is 1-based (`(nth l 0)` and `(nth l 1)` are both the first element), but the countdown's positions are 0-based. Under `eval3`, the non-countdown expectations of `check/tpeg-selectors.l` all pass (the scratch copy with the countdown lines removed prints `tpeg selectors ok`), and the countdown ones fail: `a user's type` gets (97 97), not (97 98).
  3. `eval2` has no `data` primitive: its Data type is a stub (`eval2.c`), so `data-stream` (from `data-stream.k`) fails at `bytes-of`. `tree_selectors` runs on `eval2`, so it can't pass without a change to `eval2.c` (forbidden by the Global Constraints) or to the check.
- Decision for the next iteration: the check or `boot.l`/`boot2.l` need a change first. Options for a human: define `nth` in `boot.l` as well, make the countdown 1-based or use `list-ref`-style 0-based access, and give `eval2` a `data` (or make `bytes-of` a string on eval2). Don't work around these in `input.l`.
- `input.l` details the next iteration should know: `in-span` and `in-after` are defined in that order, since `eval` resolves names when a selector's default body is defined. `in-after` on a list walks tails from `a` and counts the end as after. `arg-cell` is not in `input.l` yet; it belongs with Task 4 (arguments), where it is used.
- `text-parser.l` now loads `input.l` and so `data-stream.k` at every `compile-tpeg.l` run. The measured text-path cost was about 8% (Speed, 484 vs 522 ms in the final record), inside the 15% budget. The first record run read 1515 ms during load from other agents.
- `check/lines` has a +73 entry for `input.l` (72 lines) and the `require` in `text-parser.l`.
- Iteration 2 (Source, stage 1 Task 2): the runtime over any source. `text-parser.l` gets `text-parser-for-source`,
  `text-parser-at-end`/`-head`/`-tail` (through the selectors, on `<text-parser>`'s fields), `parse-source` (`parse-string`
  calls it), and a selector path in each match function (`-match-any`, `-match-class`, `-match-object`, `-match-char`,
  `-match-string` through the new `text-parser-match-elements`, `-list-from-to`, `-string-from-to` through `in-span`). The text
  path is the old code under `(string? self.string)`, so a string source keeps its direct forms. `text-parser-invoke-rule-in`
  copies `string` and `limit` to the sub-parser on each call.
- The `<data-stream>` selector methods moved out of `input.l` into `input-binary.l` (new), which requires `data-stream.k`, so
  text parsing doesn't load it (checked: `defined? 'data-stream` is nil after `(require "text-parser.l")`). Only
  `check/tpeg-try.l` gained `(require "input-binary.l")`, as the coordinator allowed; no other check file changed.
- Speed, before the move (`input.l` loaded data-stream): main 486 ms, here 523 ms (+7.6%). After the move: main 494 ms,
  here 513 ms (+3.8%). The record run: main 464 ms, here 485 ms (+4.5%). All inside the 15% budget.
- Scoreboard after this iteration: Selectors and Source green, Speed green; Lists, Args, Apply, Memos, Literals, Calc and
  Suite red. `make tpeg.l` passes, and `peg_compose`, `john_forms`, `law_cexpr`, `irl`, `irl_grammar`, `text_parser` pass.
- Gotchas for the next iteration:
  - In a `define-function`, `self.field` isn't resolved (`undefined variable: self.string`). Use `(<text-parser>-string self)`,
    as `text-parser-invoke-rule-in` does. `self.field` works only in `define-method` on `<text-parser>`.
  - In Maru, `unless` is `(or test body)`: it returns the test when true. Use `(when (not ...) ...)` for "do this if not".
  - `make check CHECKS=lines` is what names the delta; a new file needs its own `check/lines` entry, as `input-binary.l` has.
  - The Makefile builds `build/tpeg-lists.g.l`, `tpeg-args.g.l`, `tpeg-apply.g.l`, `tpeg-memo.g.l` and `tpeg-calceval.g.l`,
    which use forms Task 3 onward implement (`match-list`, arguments, memos). Their build failures are ignored (`make -k`), so they
    show only in the record logs, as `Error 1`, not as failures of Source.
  - `text-parser-expected` and `text-parser-context-with` still read the source with `string-at`, so a `match-require` failing on
    a list source will hit a string error instead of its message. Not needed by Source; Task 3 or a later iteration should guard it.
  - `tree_input` isn't registered in `check/check.l`; the selectors case is `tree_selectors`.
  - Next: Lists (Task 3, `match-list` and object literals). The Lists log is `/tmp/maru-plan-Lists.log`.
