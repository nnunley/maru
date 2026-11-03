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

**Grammars are live; `--on` is gone (after iteration 4).** A grammar names its parser type by its parent, `<trees> : <source-parser> ()`, and is brought in by importing it. Rules compile in-process, with `.g.l` files as a cache. Read `repl.l` and `test-pepsi.l`:
`tpeg-repl.l` does the same with `compile-tpeg.l`'s generator. `tpeg.g` already reads `{ … }` blocks to `grammar-define`, `grammar-extend` and `grammar-eval`; those forms are what's missing. `tpeg-load` loads a `.g` file in-process, so a child's parent is already known. Notes below that mention `--on` or `<X/source>` are out of date.

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
- Iteration 3 (Selectors and Source, stage 1 Tasks 1 and 2 under the new design). Scoreboard after it: **Source green**,
  Speed green (485 ms main, 510 ms here, +5%); **Selectors red, and it is a check bug, not code** (stop and report):
  - `check/tpeg-selectors.l` line 28: `(expect "a tail is kept" (= d (stream-tail c)) 1)`. `=` returns `t` on all three
    evaluators (`(= 1 1)` prints `t`), so the check can't pass whatever the code does. Wrapping that one expression as
    `(and (= d (stream-tail c)) 1)` makes the whole file print `tpeg selectors ok` on `./eval`, `./eval2 -b boot2.l` and
    `./eval3 -b boot2.l` (a scratch copy in the scratchpad; the check itself is unedited). A human should make that fix.
  - Everything else in `tpeg-selectors.l` already passes with the code as committed.
- What landed: `input.l` is the in-enter/start/at-end/head/tail/same selectors (in-after, in-span, in-limit, in-class gone),
  plus stream cells: `<cell>` (source position end head next memo), `stream-of`, `stream-tail` (built once, then kept),
  `stream-end?`, `stream-head`, `stream-memo`, and `stream-span` (the elements between two cells, for `@`).
  `source-parser.l` (new, requires input.l) defines `<source-parser>` (source position result foreign), `source-parser-for`,
  the match operations over cells, `source-parser-invoke-rule`, and `parse-source`. `compile-tpeg.l --on source` writes
  `(require "source-parser.l")`, `<X/source>` with parent `<P/source>` (or `<source-parser>` for `<text-parser>`), and the
  same templates through `tp-op`, which picks `text-parser-` or `source-parser-`. Text output is byte-identical to HEAD's
  for `check/tpeg-mini.g` (checked with cmp), and `make tpeg.l` passes.
- Gotchas for the next iteration:
  - `define-selector` on an existing selector returns the existing one, so the text and source files can both define `$sum`
    in one process (`tpeg-source.l` loads both). No guard is needed.
  - Foreign calls (`p-r`) on `--on source` stop compilation naming the rule (`tp-foreign-on-source`); the text path is unchanged.
  - Calls with arguments on source are NOT the RFC's semantics yet: `source-parser-invoke-rule-simply` is an alias of
    `source-parser-invoke-rule`, which just applies the rule. Args (stage 1 Task 4) must replace it with the arguments-on-input
    cells, and must also make the text path refuse arguments as R-instances says. That text refusal is not done.
  - `stream-memo` returns `()` and nothing fills it; memos on source are the Memos iteration's work, with
    `text-parser-invoke-rule-with-memo` and `-with-recursion` still text-only. `peg-enable-recursion` doesn't apply to source yet.
  - `stream-tail` of an end cell asks the selector for a position past the end; nothing relies on it, but a later
    iteration should decide what an end cell's tail is.
  - In zsh an unquoted `$ev` holding `./eval2 -b boot2.l` is one word, so loops over evaluators need the commands spelled out.
  - `check/lines` has a +112 entry for this iteration's new and changed lines.
  - Next: Selectors (once the check is fixed), then Lists (stage 1 Task 3, `match-list` and object literals), whose log is `/tmp/maru-plan-Lists.log`.
- Iteration 4 (Lists, stage 1 Task 3 under the design). Scoreboard after it: **Selectors, Source, Lists and Speed green**
  (Speed: main 464 ms, here 488 ms, +5%). Args, Apply, Memos, Literals, Calc and Suite red. `make tpeg.l`, `lines`,
  `tree_selectors`, `tree_source`, `tree_lists`, `text_parser`, `peg_compose`, `irl`, `irl_grammar`, `john_forms`, `law_cexpr`
  and `sat_dimacs` pass. `tree_memo` is red, as before (Memos).
- What landed: `compile-tpeg.l` (+28) has `tp-list-pattern`, which generates a list pattern inline for source. It enters the
  current element when `in-enter` holds, runs the nested pattern from `stream-of` of that element, requires `stream-end?` at its
  end, sets the element as the value on success (value mode only) and always restores the outer cell. On text it errors with
  the rule's name and "needs --on source" (`*tp-rule*`, set by `compile-value` and `compile-effect`). `find-vars-in` recurses
  into `match-list` and accepts `match-object`. `value-pe` and `effect-pe` had no `match-object` clause before, so `'sym`,
  `'0` and `'"str"` didn't compile on either path; they do now, quoted as `',obj`. `tpeg.g` (+1) adds `lparen rparen ->
  (match-all)` to `llist`, so `` `( ) `` parses; `make tpeg.l` still passes.
- Finding for a human: `parse-file` of a grammar stops silently at the first rule it can't parse. Before the `llist` fix,
  `empty = `( ) -> 'none ;` made `compile-tpeg.l --on source` emit only the rules before it, with no error, and the check then
  failed later with `undefined variable: $empty`. Any grammar that doesn't parse all of its text can lose rules this way. A
  parse that doesn't reach the end of the input should be an error; that is a change to `parser.l`/`tpeg.l`'s parse driver,
  which this iteration didn't make (`peg.g`, `parser.l` are outside the plan's constraints to change).
- Gotchas for the next iteration:
  - BSD `sed -i` needs a suffix argument (`sed -i ''`); use the Edit tool for source edits.
  - A generated grammar's selectors are only as current as its `build/*.g.l`. `./eval check/tpeg-lists.l` run by hand reads the
    stale build file (`undefined variable: $empty`); run `make build/tpeg-NAME-source.g.l` first, or go through `make check`.
  - In a `match-list` the nested pattern's `_c_`, `_v_` and `_ok_` are let-bound inside the generated form, so nested lists
    shadow lexically and don't clash; `find-vars` doesn't see them.
  - `tree_memo` (Memos) runs `check/tpeg-memo.l` and exits 35584 under `./eval` today; it stops `make check CHECKS="..."` at
    the first failing case, so run cases that must pass in a separate make call.
  - Next: Args (stage 1 Task 4, arguments on the input). `source-parser-invoke-rule-simply` is still an alias of
    `source-parser-invoke-rule`, which drops arguments; Args must replace it with the arguments-on-input cells, and the text
    path must refuse arguments as R-instances says. Log: `/tmp/maru-plan-Args.log`.
