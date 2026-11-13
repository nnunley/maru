# The evidence plan

Development is driven by JOHN plans (`doc/rfc/draft-ndn-maru-john-development-00.md`). Each plan,
`notes/plan/NAME.john`, says what is being built, what each capability builds on and which checks would show it works:
`tree-matching` is stage 1 of typed tree matching, `ksworld` the headless KSWorld work (its first capability is that the
dbjr documents can be fetched), `render` Nile, Gezira and KSWorld drawn in a window. `MARU_PLAN=NAME` picks one;
`tree-matching` if unset.

`make check` (and `make check-quick`) records what it ran: when the run ends `check/parallel.l` runs
`notes/plan/record-run.l` on its results file, and each case a plan declares becomes a step of that plan, `C observed
passed(tree: T)` or `failed`, with `WholeSuite` passed too when the run was complete and nothing failed. `MARU_RECORD=0`
records nothing (the probes' own `make check`s set it), and a ledger that can't be written is reported without changing
the run's outcome. `./eval notes/plan/observe.l [full]` asks what `make check` doesn't (measures, and every tree grammar
compiled live on each evaluator, reading its language), leaving out a case whose answer for this code the ledger
already holds, and `notes/plan/record [full]` records its answers; `./eval notes/plan/next.l` shows
what's done and the next step, running nothing. A law's check answers its verdict, with what backs it, and only tested
or proved counts. Planning says `using build`, so under `sat` the evidence is constant. `notes/plan/LOOP.md` holds the
loop's rules and notes.

## Ledgers

A plan's evidence is its ledger, `notes/plan/NAME.answers`: the plan's chain of worlds, one Maru form a line, each
answer the world its `observed` step made, every write of it (`john-serialize.l`, `doc/john.md`):

    (world (tree_lists observed (value passed (tree "504c17079996")))
      ((tree_lists evidence (value passed (tree "504c17079996"))) (tree_lists last-good (value passed (tree "504c17079996")))))

`notes/plan/plan-load.l`'s `(plan-load dir name tree)` reads the plan, makes `Now` the tree, and reads its ledger back
with Maru's `read`, evaluating nothing; a world's time is its place in the file. Ledgers are `merge=union`
(`.gitattributes`), so lanes on different branches each append and a merge keeps both; each lane's worlds keep their
order, and no state reads which of two lanes' answers came last. `notes/plan/tree-hash` leaves the ledgers out of the
code an answer is about.

A check's state reads what its world holds: its latest answer, `its evidence`, and its last good answer, `its last-good`,
which `observed` writes with every good answer:

| State | The check's answers |
|---|---|
| `holds` | the latest answer is good, for the current tree |
| `failing` | the latest answer is neither good nor untested, for the current tree |
| `regressed` | `failing`, and some earlier answer was good |
| `stale` | the latest answer is for another tree |
| `untested` | no answers |

A later answer for the current tree replaces an earlier one. A capability is proven when it shows at least one check and
every one holds.

Recording an answer is a step of the plan: `observed` runs, time moves on, and the world it made, every write of it,
is the line. Reading a ledger evaluates nothing, so when what an action writes changes, the lines already there hold the
old writes: `./eval notes/plan/replay.l` (`MARU_PLAN` picks the plan) says whether the ledger is what the plan's actions
write now, naming the first line that isn't, and `./eval notes/plan/replay.l write` takes each recorded step again and
rewrites it.

A ledger is deduplicated whenever it's written: a world the same as its check's world before it changes nothing and is
dropped, as when one results file is recorded twice or two lanes record the same answer and a union merge keeps both. An
answer that goes back to an earlier one stays, since the latest answer is the check's state. When recording, the lines of
a name retired at least `MARU_RETIRE_AFTER` commits ago (20, counted on this branch from the first commit whose plan
holds `retired NAME.`) are dropped; until then they're skipped and kept.

A ledger line naming an object the plan doesn't declare fails, naming the ledger and the line. A check dropped or renamed
is declared `retired NAME.` in its plan, and its lines are skipped and kept (`render.john` retires `ksworld_render`,
`ksworld_text`, `nile_threads` and `nile_tsan`, planned under names no case has).

## Checks

- `plan_evidence` (`check/plan-evidence.l`): what `check/law.l` prints, read by `notes/plan/law-report.g` to events, one
  a law: tested and proved hold if they're about this code, refuted, starved, vacuous, inconclusive and a law that
  stopped its run don't. A fixture plan and ledger (`check/plan/x.john`, `x.answers`) give each state of the table: one
  holding, one fixed on the tree and holding, one regressed, one regressed after failing twice, one failing and one
  untested on the tree they name, the answered ones stale on another; the same answers in the other order leave the
  latest deciding (other stale, fixed regressed); a line naming a dropped check fails naming the ledger and line, and loads once the
  plan retires it. The fixture's ledger is what its actions write now, a line missing a write `observed` makes is
  named, and every plan's ledger replays to itself. Every `make Case NAME` in every plan names a case `check/check.l` has. `next.l` runs on the plan as it
  stands.
- `plan_record` (`check/plan-record.l`): `record-run.l` over a copy of the fixture plans: a world for each case a plan
  declares and none for one it doesn't, in the results' order; a plan with no ledger gets one, a plan declaring none of
  the cases nothing; the same results twice leave the ledger as after once; `WholeSuite` passed for a complete run with
  no failure, not with one; two lanes' same answer kept once, an answer going back to an earlier one kept; a retired
  name's lines kept while the retirement is younger than `MARU_RETIRE_AFTER` and dropped once it's as old;
  `MARU_RECORD=0` and a missing results file record nothing.
