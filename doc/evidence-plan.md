# The evidence plan

Development is driven by JOHN plans (`doc/rfc/draft-ndn-maru-john-development-00.md`). Each plan,
`notes/plan/NAME.john`, says what is being built, what each capability builds on and which checks would show it works:
`tree-matching` is stage 1 of typed tree matching, `ksworld` the headless KSWorld work (its first capability is that the
dbjr documents can be fetched), `render` Nile, Gezira and KSWorld drawn in a window. `MARU_PLAN=NAME` picks one;
`tree-matching` if unset.

`./eval notes/plan/observe.l [full]` asks a plan's checks (cases, measures, and every tree grammar compiled live on each
evaluator, reading its language); `notes/plan/record [full]` records the answers; `./eval notes/plan/next.l` shows
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
  plan retires it. Every `make Case NAME` in every plan names a case `check/check.l` has. `next.l` runs on the plan as it
  stands.
