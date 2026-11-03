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
