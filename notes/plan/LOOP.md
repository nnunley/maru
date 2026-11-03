# The stage 1 evidence loop

Goal: `notes/plan/tree-matching.john`'s goal is green, which is stage 1 of
`docs/rfc/draft-ndn-maru-typed-tree-matching-00.md`. Background on approach and pitfalls, not a task list:
`docs/plans/2026-11-03-tree-matching-stage-1.md`. Its Global Constraints do bind.

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
  state, `in-*` over `<text-parser>`'s fields. Report it; don't reopen it.
- `Speed` fails and you can't see how to fix it without changing what's specified.
- Something outside the plan's Global Constraints has to change.

## Rules

- Never edit `notes/plan/evidence.john` by hand; only `record` writes it.
- Be a good neighbour: other agents share this machine. Use `nice`, and a `timeout` on anything that might loop, since an evaluator
  with no tail calls can hang or overflow silently. Never kill a process you didn't start, and never use a broad `pkill`.
- Work only in `.worktrees/tpeg-trees`, on branch `tpeg-trees`. Don't push, and don't merge to `main`.
- Commits carry no attribution lines.

## Notes from iterations
- Iteration 1 (Selectors): `input.l` is written (the `in-*` selectors, with methods for nil, pairs, strings, `<data-stream>`, longs), and `text-parser.l` requires it. Scoreboard after the change: Speed green (484 ms main, 522 ms here); Selectors, Source, Lists, Args, Apply, Memos, Literals, Calc and Suite red. Nothing else is green.
- Selectors is blocked by the checks, not by `input.l`, so this is a stop-and-report:
  1. `check/tpeg-try.l` defines `<countdown>`'s `in-head` with `nth`, which only `boot2.l` defines. `./eval` fails loading it ("undefined variable: nth"), and every `tree_*` case loads it, so they all fail under `eval`.
  2. `boot2.l`'s `nth` on a pair is 1-based (`(nth l 0)` and `(nth l 1)` are both the first element), but the countdown's positions are 0-based. Under `eval3`, the non-countdown expectations of `check/tpeg-selectors.l` all pass (the scratch copy with the countdown lines removed prints `tpeg selectors ok`), and the countdown ones fail: `a user's type` gets (97 97), not (97 98).
  3. `eval2` has no `data` primitive: its Data type is a stub (`eval2.c`), so `data-stream` (from `data-stream.k`) fails at `bytes-of`. `tree_selectors` runs on `eval2`, so it can't pass without a change to `eval2.c` (forbidden by the Global Constraints) or to the check.
- Decision for the next iteration: the check or `boot.l`/`boot2.l` need a change first. Options for a human: define `nth` in `boot.l` as well, make the countdown 1-based or use `list-ref`-style 0-based access, and give `eval2` a `data` (or make `bytes-of` a string on eval2). Don't work around these in `input.l`.
- `input.l` details the next iteration should know: `in-span` and `in-after` are defined in that order, since `eval` resolves names when a selector's default body is defined. `in-after` on a list walks tails from `a` and counts the end as after. `arg-cell` is not in `input.l` yet; it belongs with Task 4 (arguments), where it is used.
- `text-parser.l` now loads `input.l` and so `data-stream.k` at every `compile-tpeg.l` run. The measured text-path cost was about 8% (Speed, 484 vs 522 ms in the final record), inside the 15% budget. The first record run read 1515 ms during load from other agents.
- `check/lines` has a +73 entry for `input.l` (72 lines) and the `require` in `text-parser.l`.
