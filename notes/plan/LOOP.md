# The evidence loop

How development is driven by the plans is `doc/rfc/draft-ndn-maru-john-development-00.md`, and how the pieces work is
`doc/evidence-plan.md`; where this file differs from them, they win. `tree-matching.john` is stage 1 of
`doc/rfc/draft-ndn-maru-typed-tree-matching-00.md` (background, not a task list: `doc/plans/2026-11-03-tree-matching-stage-1.md`).

The plan says what each `Capability` is (`what`, `where`), what it builds on (`builds-on`) and what would show it works (`shown-by`). A `Check` is anything the system can be asked: a `Case` in `check/check.l`, a `Measure` (a program's exit status), a `Grammar` (compiled live on each evaluator, reading its language) or a `Law`. John objects ask through messages `notes/plan/probes.l` defines.

Each iteration, with fresh eyes:

1. `./eval notes/plan/next.l [--lane NAME]` prints what's done in the plan, what isn't and why, and the frontier: every step the plans allow, scored, your lane's first. It runs nothing.
2. Take the top step of your lane, and as much as naturally goes with it: a `build` or a `simplify`. Read a failing check's log in `/tmp/maru-plan/` or `/tmp/maru-check/`.
3. Change the code until the step's checks pass, keeping earlier ones green. `make check` records what it ran in each plan's ledger; `notes/plan/record` asks what it doesn't (measures, grammars, laws), `notes/plan/record full` everything, `./eval notes/plan/observe.l NAME…` just the checks named.
4. Add `check/lines` and `check/erosion` entries as needed: `make check CHECKS="lines erosion"` names the delta.
5. Commit, code and the ledgers (`notes/plan/NAME.answers`) together, with a prose message saying what changed and why; feedback that changed a plan is quoted in it (AGENTS.md).
6. Report: what's green now, what you learned, and anything the next iteration should know. Add that to the end of this file too.

An answer counts for the code it ran against, named by `notes/plan/tree-hash` (tracked files and untracked source files, here and in the submodules, without the ledgers and docs). Answers about older code don't block anything: they make a capability `aging`, which ranks below a regression or a failure, and a capability is `proven` only with answers about the code as it stands.

Probes run only from `observe.l`. The plan's rules read `evidence`, never `observe`, so loading the ledger and planning run nothing.

## Stop and report, without working around it

- A check looks wrong, or could only pass by changing it. The checks and the expected values were fixed before the code. Never
  weaken, delete or edit a check to make it pass; report what you think is wrong and why. Dropping or renaming one is a plan
  change (`retired NAME.`), made for a reason someone gave.
- The evidence seems to say a decision in an RFC is wrong. Report it; don't reopen it.
- `TextMatchingSpeed` fails and you can't see how to fix it without changing what's specified.
- Something outside the plan's Global Constraints has to change.

## Rules

- Never edit a ledger by hand; `make check`, `record` and `notes/plan/replay.l write` write them.
- Be a good neighbour: other agents share this machine. Bound heavy runs, one full suite at a time, and put a `timeout` on anything
  that might loop, since an evaluator with no tail calls can hang or overflow silently. Never kill a process you didn't start, and
  never use a broad `pkill`.
- Work in a worktree under `.worktrees/`, on its own branch; merging follows AGENTS.md.
- Commits carry no attribution lines.

## Notes from iterations

**The plan says what it means (after iteration 9).** Requirements became capabilities with named relationships, and events name the check that answered. The old evidence named only a requirement, so it couldn't say which of a requirement's checks had failed, and was deleted. Names in older notes below (`Req`, `Selectors`, `Args`, `Suite`, `notes/plan/record`) are from before this. Planning from no evidence at all takes about 45 s even with `merge-worlds`. `at time N` far ahead printed nothing within 30 s and is not explained yet.

**Evidence is prior worlds (after iteration 9).** `passed` and `failed` set a requirement's `done`, so each check run is a world in John's chain, and `at time T` reads an earlier one. `next.l` is one program now. `evidence.john` is how the chain persists, since John keeps worlds in memory. **On text, parameters stay arguments of a rule's method:** `nile-grammar.g` uses them, and only `<source-parser>` puts them on the input.

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
- Iteration 5 (Args, stage 1 Task 4 under the design). Scoreboard after it: **Selectors, Source, Lists, Args and Speed
  green**; Interleave, Apply, Memos, Literals, Calc and Suite red. Speed from the record run: `main 329 ms, here 323 ms`.
  `make tpeg.l` (forced with `make -B tpeg.l`, output unchanged in git), `lines`, and the text-side checks `text_parser`,
  `peg_compose`, `irl_grammar`, `john_forms`, `law_cexpr`, `cexpr_forms`, `irl` and `sat_dimacs` pass.
- What landed:
  - `compile-tpeg.l`: `tp-parameters` turns a rule's `:a :b` into `(match-all (assign-result a (match-any)) …)` at its
    start, so the parameters are `.:a` reads of the input; the method takes no arguments (`compile-value` and
    `compile-effect` both changed). A call with arguments goes through `tp-call-args`, which is an error on text.
  - `source-parser.l`: `source-parser-arguments` builds one cell per argument (`new <cell>` with its tail already set to the
    next argument, the last one to the caller's current cell). `source-parser-invoke-rule` sets the position to that chain,
    calls the rule with `self` alone, and restores the saved cell on failure, for every call, args or not.
    `source-parser-invoke-rule-simply` is still an alias of it, so it no longer drops arguments.
  - `check/lines` +21 for this delta.
- Decisions made here, which the RFC doesn't spell out (a human may want to look at them):
  - On success, the caller continues from the callee's final cell. If the callee leaves argument cells unread, they stay in
    front of the caller's input. No check covers this; `tree_args` only has calls whose arguments are all consumed.
  - Parameters on `<text-parser>` are an error naming the rule, not only calls with arguments. The RFC names calls. A
    parameter on text has no argument to receive, so it was refused rather than left to fail at run time. No text grammar
    in the tree declares parameters, so nothing changed.
  - Argument cells have `end` nil, so a nil argument (`{nilarg ()}`) is an ordinary element, as the check expects.
- Not covered by a check: the text refusal of calls with arguments (and of parameters) has no case. I confirmed it by hand
  with scratch grammars through `./eval compile-tpeg.l`: it stops with `rule start calls other with arguments, which needs
  a grammar on <source-parser>` and `rule other has parameters, which needs a grammar on <source-parser>`. The RFC asks
  for it under R-instances, which maps to `tree_source`, and `tree_source` doesn't exercise it. A human may want a case.
- Gotchas for the next iteration:
  - `make tpeg.l` says "up to date" when only compile-tpeg.l changed; `make -B tpeg.l` forces it.
  - Maru has no `begin` here; use `(let () …)` (the first attempt failed for that reason).
  - `compile-value` now sets `*tp-rule*` before it computes the body, so the errors name the right rule.
  - Next: Interleave (`tree_interleave`, log `/tmp/maru-plan-Interleave.log`). Its check runs `./eval tpeg-repl.l
    check/tpeg-interleave.l`, which needs the block forms `{ <x> : … }`, `{ rules }` and `{ rules expression }` from `tpeg.g`
    and a REPL reader that hands back its position; none of that is in the tree yet. Apply after it, and it needs `{apply x}`
    and `{super r x}`, which `tpeg.g` doesn't parse yet.
- Iteration 6 (Args and Interleave, stage 1 Task 4's refusal and the block forms). Scoreboard after it, from the record run:
  **Selectors, Source, Lists, Args, Interleave and Speed green**; Apply, Memos, Literals, Calc and Suite red. Speed:
  `main 323 ms, here 309 ms` (an earlier run in this iteration read `main 277 ms, here 303 ms`, so the spread is load, not code).
  `make tpeg.l` (forced with `make -B tpeg.l`, no diff), `lines`, `text_parser`, `peg_compose`, `irl`, `irl_grammar`, `john_forms`,
  `law_cexpr`, `cexpr_forms`, `sat_dimacs` pass.
- What landed:
  - Args: `literal.g` (`start = 'x ;` on `<text-parser>`) compiled silently, because `value-pe` and `effect-pe`'s `match-object`
    clause had no guard. `tp-object-literal` (compile-tpeg.l) errors naming the rule, the same wording as the other refusals. The
    `match-class` and `match-string` one-character branches still emit `match-object` on text, and must.
  - Interleave: `tpeg-repl.l` (new, 68 lines) is the reader. It requires `compile-tpeg.l` with `compile-tpeg-definitions-only`
    set, so the argument loop doesn't run, reads with a `<tpeg>` parser over the file, and evals each form at once, as repl.l
    does. `grammar-define`, `grammar-extend`, `grammar-eval` are `define-form`s there. A `{ rules expr }` block's expression
    becomes `start` on a fresh child `<tpeg-block>` of the running grammar, and `tpeg-match-rest` runs it on a `text-parser-for-on`
    sharing the reader's string, copying the position in and out. So the hand-back is a position copy, not a shared object.
  - compile-tpeg.l (+33): `tp-definition-forms` (selectors and methods for a class), `tp-derives?` (walks `%structure-bases`,
    which ends at nil for `<text-parser>`), `tp-source-type`, `tpeg-define-rules` (sets `*tpeg-source*` from the class's
    ancestry and evals the forms), `tpeg-define` and `tpeg-load` (a `.g` file in process). `parse-and-compile-grammar` still
    decides source-ness by the parent's symbol, and its output is byte-identical to HEAD's (checked with cmp on
    `check/tpeg-mini.g`, `check/tpeg-lists.g` and `tpeg.g`).
  - `check/lines`: +101 for the new file and the compile-tpeg.l delta (the lines check named 101).
- Decisions the RFC doesn't spell out (a human may want to look):
  - The running grammar is the last one a block defined or extended (`*tpeg-running*`); a file starts on `<tpeg-running>`, a
    `<text-parser>` child. Rules-only blocks enrich it, so a later block overrides `word` and `_` stays, as the check expects.
  - A block's expression is a child class per block, so it doesn't replace a `start` rule on the running grammar.
  - `tpeg-load` lives in compile-tpeg.l, not tpeg-repl.l, because `check/tpeg-apply.l` loads only compile-tpeg.l.
- Gotchas for the next iteration:
  - `defined?` takes the symbol's value (`(defined? parent)`), not a quoted symbol inside a variable.
  - `tp-derives?` needs `(tp-source-type)`, which is nil until source-parser.l is loaded. tpeg-repl.l requires it; the file path
    (`./eval compile-tpeg.l X.g`) doesn't, and still uses the symbol compare.
  - Redefining `<tpeg-block>` each time is deliberate: a new type per expression block, so no method from an old block survives.
  - `peg.g` is refused by `compile-tpeg.l` (it calls a rule with arguments). That predates this iteration: it's peg syntax,
    compiled by compile-peg.l, not a tpeg grammar.
  - Next: Apply (`check/tpeg-apply.l`). It fails at `undefined variable: $apply`, because tpeg.g has no `apply` or `super`:
    `{apply t}` parses as `(match-rule apply t)`. `tpeg-load` already exists. Then Literals: `check/tpeg-literals.l` fails at
    `undefined variable: $x10`, so the action's `0x10` isn't read as hex (the RFC's "Grammar features" says this is the current
    behaviour, but the check expects 16). `tree_parse_complete` runs in the same Literals record, after `tree_literals`, so it hasn't
    been seen green yet. Log: `/tmp/maru-plan-Apply.log` and `/tmp/maru-plan-Literals.log`.
- Iteration 7 (Apply: `{apply x}` and `{super r x}`, then Literals). Scoreboard from the record run:
  **Selectors, Source, Lists, Args, Interleave, Apply, Literals and Speed green**; Memos, Calc and Suite red. Speed:
  `main 292 ms, here 299 ms` (the earlier run read `main 279 ms, here 303 ms`). `make -B tpeg.l` passes (no diff),
  `lines`, `text_parser`, `peg_compose`, `irl`, `irl_grammar`, `john_forms`, `law_cexpr`, `cexpr_forms`, `sat_dimacs` and
  `tree_text_refuses` pass.
- What landed:
  - `source-parser.l` (+21): `source-parser-apply self prefix name . args` runs the rule the name finds on the object's type
    (its own method, or the nearest parent's, through `<selector>-inherit`); a name with no selector, or no rule, fails the
    match. `source-parser-super self prefix parent name . args` runs the rule as `parent` defines it. Both call
    `source-parser-invoke-rule`, so arguments are cells on the input as for any call.
  - `compile-tpeg.l` (+22): `tp-named-call` turns `(match-rule apply x …)` and `(match-rule super r …)` into those calls, in
    value mode (prefix `$`) and effect mode (`$$`). `super`'s parent is `(array-at %structure-bases *tp-class*)`, evaluated at
    run time, where `*tp-class*` is the class the rule is defined in (set in compile-value and compile-effect). A rule named
    `apply` or `super` is an error at compile time. On text, both are refused by rule name (`tp-by-name`), as calls with
    arguments are, and a bare `{apply}` or `{super}` with no name is refused too.
  - `tpeg.g` (+3): `sexpr` reads `sinteger` as peg.g does, so `0x10` is 16 and `-0x10` is -16 (`tpeg.l`'s fixed point holds).
    The RFC's "Actions read hexadecimal literals" paragraph still describes the old reading (`0x10` as `0` then a call);
    I did not edit the RFC. A human should update that sentence.
  - `text-parser.l` (+11): `set-list-source` copies each pair's source from the source list, as `parser.l`'s does. It was a
    no-op `define-form`, so the `<pair>-source` checks failed.
  - `check/lines`: +43 (Apply) and +14 (Literals) entries.
- Checked by hand, not by a case: a grammar with `apply = …` stops with `rule name apply is reserved by {apply} and {super}`;
  a text grammar with `{apply x}` stops with `rule start calls by apply, which needs a grammar on <source-parser>`. No check
  file covers either, and I did not edit `check/tpeg-*`; a human may want cases for them.
- Gotchas for the next iteration:
  - `(array-at %structure-bases X)` is the parent of X; `super` relies on it being defined for the class at run time, so a
    grammar's class must be defined before its rules are called (it always is through `tpeg-load` or the file path).
  - `<selector>-methods`, `<selector>-inherit` and `selector?` are used by `source-parser.l`; they come from boot2.l's
    selector structure, but `tpeg-try.l` already uses `<selector>-name` under `./eval`, and the Apply check passes under all
    three evaluators.
  - `make -B tpeg.l` prints the `diff`, which is silent on success; check its exit status, not the output.
  - Next: Memos (`tree_memo`, `check/tpeg-memo.l`, which exits 35584 under `./eval`; log `/tmp/maru-plan-Memos.log`) and Calc
    (`tree_calc`, `check/tpeg-calc.l`, exits 256; log `/tmp/maru-plan-Calc.log`). The record log doesn't show the cause of
    either yet; read the case itself before the log. Memos is the RFC's "memos are on the stream" design, so it is the one
    most likely to meet a decision in the RFC; Calc needs Memos per the plan (`Calc Memos Args`).
- Iteration 8 (Memos, stage 1 Memos under the design; Calc stopped on its check). Scoreboard from the record run:
  `Selectors yes`, `Source yes`, `Lists yes`, `Args yes`, `Interleave yes`, `Apply yes`, `Memos yes`, `Literals yes`,
  `Calc no`, `Speed yes`, `Suite no`. The Speed line: `main 280 ms, here 300 ms` (the `hyperfine` summary read `+7.1%`).
  `tree_memo` passes on all three evaluators. `make -B tpeg.l` exits 0 with no diff; `lines` passes with the +108 entry;
  `peg_compose`, `text_parser`, `irl_grammar`, `john_forms`, `law_cexpr`, `cexpr_forms`, `irl`, `sat_dimacs`,
  `tree_text_refuses` and `tree_parse_complete` pass.
- What landed:
  - `source-parser.l` (+103 net) requires `text-parser.l` for `<memo>`, `put`, `get` and the states. `<source-parser>` gained
    a `streams` field, and `source-parser-stream-of` keeps one stream per value on the parser (an alist, looked up by identity);
    `source-parser-for` and the list pattern (compile-tpeg.l, one line) both go through it.
  - `source-parser-invoke-rule-plain` is the call with no memo, and `source-parser-invoke-rule-simply` and
    `source-parser-invoke-args` are aliases of it. Generated calls with arguments use the plain call, so arguments are never memoized.
  - `source-parser-invoke-rule-with-memo` and `-with-recursion` answer a no-argument call from the cell's memo (`<cell>-memo`,
    an alist keyed by the rule's base name, `source-parser-memo-key`: its selector name without `$` or `$$`).
  - `source-parser-choose` sets `source-parser-invoke-rule` to one of the three. `text-parser.l`'s `peg-enable-memoisation`,
    `peg-enable-recursion` and `peg-disable-memoisation` call it through `peg-choose-source`, by name, so text-parser.l doesn't
    need source-parser.l loaded, and the source switch follows the text one. The default is plain, as text's default is simple.
- Decisions the RFC doesn't spell out (a human may want to look at these):
  - **Left-recursion sentinel.** The RFC says a growth pass stops when it "fails or doesn't advance, by cell identity". Pure
    identity isn't enough: in `sum = sum:a 'plus .:b | .:n` on `1 plus 2 plus 3`, the pass that falls back to the base
    alternative ends at the first cell, which is not the current answer's cell, so identity alone grows forever. OMeta2's
    `apply:` stops also when a pass ends where the seed pass ended (`sentinel`), and that is what is implemented, with the
    identity test as well. The RFC text should say so. This is the one place where the RFC's wording is short of the evidence.
  - **Memo key and effects.** `sum` in value mode and `counted` in effect mode are different selectors, but one rule. The memo
    is keyed by the base name, and holds the value's answer. An effect call (`$$r`) runs the value selector (`$r`) in memo mode,
    because an effect's answer has no result, and `twice = &counted counted` must run `counted` once. So under memoisation an
    effect builds results it would not build otherwise; the matching is the same. Check `tree_memo` requires one run, not a
    particular result, so this is a choice, not something the check forces.
  - **Calls by name aren't memoized.** `{apply x}` and `{super r}` pass a method, not a selector, and `super`'s rule has the
    same name as the override, so a name key would collide. They run plain. A left-recursive rule reached only through `apply`
    or `super` therefore has no growth; no check covers this.
  - **Argument cells and memos.** A no-argument rule's answer depends only on the suffix from its cell, so a memo on the caller's
    cell stays valid when a callee reads the caller's input through argument cells. The argument cells are new cells with no
    memo, so they start empty on every call. A rule with arguments writes no memo at all.
  - **Lookup cost.** Both the per-value streams and the cell memos are alists, looked up with `assq` (identity). That's linear in
    the number of values or rules at one cell. Speed doesn't measure the source path, but a big source with many distinct
    sublists will pay for it. A table would fix it if there's a hash primitive in boot.l/boot2.l (none found).
- Calc: **stopped on its check, not a code failure.** `check/tpeg-calc.g` (a `check/tpeg-*` file, so not edited) has
  `identifier = spaces [a-zA-Z] [a-zA-Z0-9]* @$:n -> n`. In `tpeg.g`, `@` and `$` are postfix conversions on the repetition before
  them, so `@$:n` takes the span of `[a-zA-Z0-9]*` only, and the first letter is dropped: on text `parse-string <calc> $identifier
  "abc"` gives `"bc"`. The check expects `(+ a (* b 2))` and gets `(+ "" (* "" 2))`. The text path is unchanged by this
  iteration, so the grammar is the cause. Evidence that the rest of Calc is right: a scratch copy in the scratchpad with
  `identifier = spaces ([a-zA-Z] [a-zA-Z0-9]*) @$:n -> n` (`tpeg-calc-fixed.g`), and `calc-fixed.l` (the check with its
  grammar load pointed at the copy) prints `tpeg calc ok` under `./eval`, `./eval2 -b boot2.l` and `./eval3 -b boot2.l`.
  A human should fix `check/tpeg-calc.g` (or confirm the intended reading) before Calc can go green.
- Also a stop-and-report: the Calc check calls `source-parser-invoke-args`, which didn't exist. I added it as the name for the
  plain call with arguments (see above). That is a new name, not a check edit, but a human may want the check to use the
  name the RFC gives.
- Not done this iteration: foreign rules on `<source-parser>` (`[R-foreign-proxy]`; `p-r` still stops compilation on source with
  "not generated on <source-parser> yet"); a compile-time refusal of left recursion with arguments (`[R-param-left-recursion]`,
  no check covers it); `memo-all`. `stream-memo` returns the cell's memo alist, not a table as the RFC's signature says.
  `tree_memo` covers memo hits, growth, and one stream per value, but not `{apply}`/`{super}` memo behaviour, nor the
  argument-cell case.
- Gotchas for the next iteration:
  - `(= a b)` on structs is identity (checked: `(= x y)` on two distinct `<s>` is nil). `assq` is identity too.
  - `(string-at "$" 0)` against a symbol's first character works. A `?$` char literal didn't compare equal to 36 here, so don't use it.
  - `peg-choose-source` finds `source-parser-choose` by name at run time, so a text-only program has no source switch to set.
    `source-parser.l`'s `source-parser-invoke-rule` default is plain until one of the three peg-* functions runs, as on text.
  - Next: Calc once `check/tpeg-calc.g` is fixed by a human (the grammar, not the code, is the cause). Then `notes/plan/record full`
    for Suite, which needs Calc and Speed too. Logs: `/tmp/maru-plan-Memos.log` and `/tmp/maru-plan-Calc.log`.
- Iteration 9 (Args and Foreign, then `record full`). Scoreboard from the full record: **Selectors, Source, Lists, Args,
  Interleave, Apply, Memos, Foreign, Literals, Calc and Speed green; Suite red**. Speed: `main 5839 ms, here 5794 ms`
  (the `record` run before it read `main 5828 ms, here 5884 ms`). The Speed absolute numbers are about twenty times the
  earlier iterations' ~300 ms, and both trees read the same, so suspect the measurement (john.l, the `.g.l` cache or load),
  not the change. A reviewer should look before trusting the 15% comparison as a timing.
- What landed:
  - Args: `tp-check-parameters` (compile-tpeg.l) refuses, on source, a rule with parameters that reaches itself through its
    left calls. `tp-left-calls`, `tp-nullable?` and `tp-left-recursive?` follow irl-grammar.l's `irl-left-recursive?`, and run
    on the rule's body before `tp-parameters` wraps it (the wrapper's `assign-result` is not nullable, so it would hide the
    left calls). The error names the rule and says "left-recursive". `tree_text_refuses` passes.
  - Foreign: `p-r` on source is generated by `tp-foreign-call`, which on text still emits `text-parser-invoke-rule-in`, so
    text output is unchanged. `source-parser.l` (+24) adds `<proxy>` (one field, unused, so the proxy's source is a value),
    `in-at-end`, `in-head` and `in-tail` on it (a proxy's position is the caller's cell, its tail a proxy of the caller's
    tail), and `source-parser-invoke-rule-in`, which keeps one foreign object per type on the caller's `foreign` alist, as
    text does, and resets its position to a fresh proxy on each call. On success the caller's position is the target of the
    foreign object's cell. `tree_foreign` passes on all three evaluators.
  - `check/lines`: +75 for both deltas.
- Suite is red at `law_nile`, and it is not Foreign or Args. `make check` stops at its first failing case, so the cases after it
  (`nile_compile`, `ir2`, `irl_library`, `maru_gc`, and the rest listed below) did not run in this record. The failure:
  `error: rule atIndentation has parameters, which needs a grammar on <source-parser>` from `./eval check/law.l` with
  `check/laws/nile.law`. `nile/compilers/maru/nile-grammar.g` (the submodule, at cd2cef3) is `<nile-parser> : <text-parser>`
  and declares `atIndentation :i`, `elseif :i` and `else :i`, and calls `{atIndentation i}` with arguments. Iteration 5
  (7478493) refuses both on text, as the RFC asks for calls ("a call with arguments ... on <text-parser> MUST stop"). The
  iteration-5 notes said no text grammar in the tree declares parameters; that was true of the tree, not of the submodule.
  This is a decision to put to a human, not a fix to make here: either the Nile grammar moves to `<source-parser>` (a change in
  the nile fork, outside this worktree and the Global Constraints), or the RFC's text refusal is reconsidered. Do not weaken
  `law_nile` or `tree_text_refuses`.
- Cases after `law_nile` in the Suite, not yet run under this record: sat_john sat_proof sat_core sat_dimacs irl_grammar
  irl_library irl asm_patch maru_test core_forms asm_x86 ir2 zero_global maru_check maru_label maru_gc maru_gc_coalesce
  boot2_strings nile_compile (lines passes). Run them by name (`make check CHECKS="..."`) to see which are green.
- Gotchas for the next iteration:
  - `make check CHECKS=lines` names the delta as "add an entry for N"; the entry is a `+N reason` line at the end of `check/lines`.
  - The `record` runs `make` with `-k`, so derived `.g.l` files rebuild when `compile-tpeg.l` changes; `git status` may show
    them only if they are tracked (they are not in this tree's status).
  - `tree_foreign` runs `check/tpeg-foreign.l` through `./eval`, `./eval2 -b boot2.l` and `./eval3 -b boot2.l`; the foreign
    grammar `<sb>` is built by make (`build/tpeg-foreign-sb.g.l`), so run `make check CHECKS=tree_foreign` rather than the file.
  - `define-structure` with one field works on all three evaluators; I did not test a zero-field structure.
