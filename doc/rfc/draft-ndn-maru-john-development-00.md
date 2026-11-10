# draft-ndn-maru-john-development-00: Development Driven by JOHN Plans

**Status:** DRAFT
**Corpus:** red (spec-first: the checks named below are the acceptance criteria)
**Category:** Standards-Track
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies how Maru's development is driven by JOHN: a development specification is a JOHN program, a
plan, whose capabilities say what is being built, what each builds on and which checks would show it works. The
checks' results are recorded as evidence, the evidence scores the actions the plan allows, and the best of them are
the next work. It is written for coding agents that take work from the plans, for whoever writes a plan, and for
whoever changes `john-eval.l`, `check/parallel.l` or `notes/plan/`.

## Motivation

`notes/plan/` holds three plans (`tree-matching.john`, `ksworld.john`, `render.john`), `observe.l` asks their checks,
`record` appends the answers to an evidence file, and `next.l` replays the evidence and asks JOHN for a plan. It is not
part of the development loop:

- Evidence is recorded only when someone runs `notes/plan/record`, which runs the whole suite again (`WholeSuite`) to
  learn what `make check` had already learned and thrown away. At the time of writing (November 2026) every plan's
  evidence is about older code: tree-matching's last record is from 2026-11-04, ksworld's and render's from 2026-11-06.
- Evidence about older code blocks planning outright: `next.l` answers `next: notes/plan/record full` until every
  answer is current, and any edit to the tree makes every answer stale.
- Nothing ranks the work. JOHN finds some order that respects `builds-on`; a regression, a check that keeps failing
  and a capability nobody has tried all weigh the same.
- `plan_evidence` asserts only that `next.l` exits 0, so it passes on stale evidence, unfinished capabilities and
  regressions alike, and `render.john` names a case, `ksworld_render`, that `check/check.l` no longer has.

This document makes the plans the driver: `make check` records evidence as it runs, evidence orders the work rather
than blocking it, JOHN answers what to do next, and several agents can take work from several plans at once.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **plan** — a JOHN program `notes/plan/NAME.john` with a `Team` object `T`, a class `Capability`, an action
  `build Capability` and a goal `deliver`, as `tree-matching.john` has today.
- **ledger** — a plan's evidence file: `notes/plan/evidence.john` for `tree-matching`, `notes/plan/NAME-evidence.john`
  for any other plan. Its statements are events `CHECK do observed ANSWER.`
- **check** — an instance of the plan's `Check` group: a `Case` (a case in `check/check.l`), a `Measure`, a `Grammar`
  or a `Law`.
- **current** — said of an answer whose `tree` is the hash `notes/plan/tree-hash` gives for the code as it stands.
- **results file** — what `make check` writes in its own directory: the tree it ran against and each case's outcome.
- **frontier** — the steps a plan's rules allow `T` to take toward `deliver` from the current world, each with the
  score of the world it leads to, best first.
- **lane** — a plan, as the unit of work one agent prefers. An agent in lane NAME takes NAME's frontier first.
- **hotspot** — a callable of the current code whose cyclomatic complexity is over 10, as `erosion.l` measures it,
  with its mass (CC x sqrt(SLOC)): what erosion is made of.
- **overflow** — the other plans' frontiers, which a lane takes from when its own is empty.

## Specification

This document defines: the results file and how `make check` writes it; how a run's results become evidence in every
ledger; what "done" and "ready" require of evidence; the `choices` statement and the frontier it answers; how a plan
scores steps from its evidence; how a plan minimizes erosion; `total`; lanes and overflow in `next.l`; and the rule that keeps plans naming real cases. It
does NOT define JOHN's semantics beyond `choices` (owned by `draft-ndn-maru-john-session-00` and `doc/john.md`), the
evidence values a law can answer (owned by `check/law.l` and `plan_evidence`), or coordination between agents beyond
what the frontier's order gives (see Out of Scope).

**The plan is the specification.** What counts as done, ready or urgent is a qualification or a heuristic in the plan
file, never a rule in `next.l` or `observe.l`. A change to what the next work is MUST be expressible as a change to a
plan, so the plan, read alone, says why the next work is next.

**Done needs current evidence; ranking uses all of it.** An answer about older code never makes a capability done, and
never stops the frontier from being answered.

**Recording runs nothing twice.** A case `make check` ran is never run again to record it.

### Data model

```
RECORD ResultsFile:                 -- $CHECK_TMP/results, written by check/parallel.l
    tree     : String               -- notes/plan/tree-hash at the start of the run, 12 hex digits
    complete : Boolean              -- every case of check/check.l ran (no CHECKS selection)
    outcomes : List of Outcome      -- one per case that ran, in the order they finished

RECORD Outcome:
    case     : String               -- the case's name in check/check.l
    passed   : Boolean

RECORD Choice:                      -- one entry of a frontier
    plan     : String               -- the plan's NAME
    step     : String               -- john-step-text of the step: "T build ListPatterns"
    score    : Number               -- john-score of the world the step leads to, for T's goal deliver
```

**Field constraints:** `tree` is exactly what `notes/plan/tree-hash` prints, less its newline. A case appears in
`outcomes` at most once.

### Configuration

| Key | Type | Default | Description |
|---|---|---|---|
| `MARU_PLAN` | plan NAME | `tree-matching` | the plan `record`, `observe.l` and `next.l` read when no lane is given |
| `--lane NAME` (`next.l`) | plan NAME | `MARU_PLAN` | the plan whose frontier `next.l` answers first |
| `MARU_RECORD` | `0` or `1` | `1` | whether `make check` records its results in the ledgers; `0` leaves the ledgers untouched |
| heuristic weights | whole numbers in each plan | 10000, 1000, 100, 10 (see below) | how much a regression, a failure, an older pass and an untested check weigh |
| erosion weight | whole number in each plan | 1 | how much a unit of hotspot mass left unsimplified costs |

`tree-matching` stays the default because existing scripts and notes name it. `MARU_RECORD` defaults to on because a
run that isn't recorded is the waste this document removes; it exists for runs whose results shouldn't count, such as
a check of the recorder itself.

**Lane resolution** (highest first): `--lane NAME`; `MARU_PLAN`; `tree-matching`.

### Results and evidence

`check/parallel.l` MUST write the results file when the run ends, with the tree taken before the first case started,
and MUST compare it with `notes/plan/tree-hash` when the last case ends. If they differ, it MUST write no results file
and say so on standard error. [R-results-file]
A result is evidence about the code it ran against, so a run whose code changed under it is evidence about no code.

```maru-check @R-results-file
check_results
```

After `make check` writes a results file, and unless `MARU_RECORD` is `0`, every plan's ledger MUST gain one event
`C do observed passed(tree: "T").` or `C do observed failed(tree: "T").` for each `Case` C the plan declares that the
run passed or failed, and none for any other case. A run with `complete` true and every outcome passed MUST also add
`WholeSuite do observed passed(tree: "T").` to every plan that declares the measure `WholeSuite`. [R-run-records]
Measures, grammars and laws are not cases of `check/check.l`; `notes/plan/record` still asks them, and MUST NOT run a
`Case` whose current answer the ledger already holds.

```maru-check @R-run-records
plan_record
```

Each ledger MUST be marked `merge=union` in `.gitattributes`. [R-ledger-union]
Lanes append to the same ledgers on different branches; a union merge keeps every lane's events, and an event's order
only matters within one run, which one branch holds.

```maru-check @R-ledger-union
plan_evidence
```

### Done, ready and stale

A plan MUST qualify `Check holds` only for an answer that is good and current, and `Capability proven` only when the
capability shows at least one check and every one holds; `ready` is every `builds-on` done, as `tree-matching.john`
has them today. [R-done-current]

```maru-check @R-done-current
plan_frontier
```

`next.l` MUST answer the frontier whatever the evidence's age: an answer that isn't current MAY lower or raise a
step's score through the plan's heuristics, and MUST NOT stop the answer. [R-stale-ranks]
With several agents and lanes, a blocking rule would stop every agent on every edit.

```maru-check @R-stale-ranks
plan_frontier
```

### The `choices` statement

A session MUST accept `choices O G.`, where O names an object and G one of its goals, and MUST answer O's frontier for
G from the current world: every step `john-children` gives (each step's rules holding, through G's
goal-optimizations as `satisfy` would use them), one line per step, best first, as `STEP  score N`, then
`choices: K.` with K the number of steps. A step's score is `john-score` of the world it leads to. Steps with equal
scores MUST keep the order `john-children` gives them, so the answer is the same every time for the same plan and
evidence. With no step allowed it answers `choices: 0.` [R-choices]
`choices` neither moves time nor searches: it is one level of what `satisfy` explores, ranked by what the plan says
matters.

```maru-check @R-choices
john_session
plan_frontier
```

### Scoring from evidence

A plan MUST say what makes a step urgent through qualifications on `Capability` and `heuristic` lines for
`Team deliver`. Because exactly one capability is `planned` in a world one step from the current one, a heuristic
counts the planned capabilities with a quality, `(select all Capability by which planned = yes and which Q = yes)
size`, and weighs it. Every plan MUST define these four, and MAY add others: [R-plan-heuristics]

| Quality | Holds when one of the capability's checks… | Weight |
|---|---|---|
| `regressing` | is `regressed` (an earlier answer was good, the latest isn't) | 10000 |
| `failing` | has a latest answer that is neither good nor untested | 1000 |
| `aging` | holds only about older code (`stale`) | 100 |
| `untried` | has never answered (`untested`) | 10 |

Regressions come first because they break what was done; then what is known to fail, whose cause is closest at hand;
then what passed once and only needs confirming; then what nobody has tried. A plan changes the order by changing a
weight, not `next.l`.

```maru-check @R-plan-heuristics
plan_frontier
```

### Erosion

Every plan MUST minimize erosion. The plan's `Measure` `Erosion` runs `erosion-run.l` over the `lines` check's files,
and its answer, recorded like any other, names the code it measured and every hotspot in it; replaying the ledger
makes each hotspot of the current code an object of class `Hotspot` (`callable`, `file`, `cc`, `mass`). A plan MUST
declare `action Team simplify Hotspot consequence Hotspot planned = yes.`, allowed only for a hotspot not yet planned,
and MUST carry
`heuristic Team deliver W minimize total (select all Hotspot by which planned = no) by which mass.`
with W its erosion weight. [R-erosion-minimized]
So `simplify` competes with `build` on the frontier: a step that simplifies a hotspot of mass M scores W x M more than
one that doesn't. With the default weights a hotspot of mass 1000 weighs as a failing check, and the largest in the
tree (`john-eval.l:518`, CC 37 over 37 lines, about 225 at the time of writing) sits between a failing check and an aging one. Hotspots of older code don't
count: erosion is about the code as it stands. That a step really lowered erosion is shown by the `erosion` case and
`check/erosion`'s ledger, as now.

```maru-check @R-erosion-minimized
plan_frontier
```

A session MUST accept `total S by E`, where S is a set (`all C`, a `select`, or a list) and E an expression in which
`which` names each member, as in `select`: its value is the sum of E over S's members, and 0 for an empty S. E MUST
answer a number for every member; any other value is an error naming the member. [R-total]
A heuristic weighs a quantity, and erosion is a sum of masses; without a sum, a plan could only count hotspots.

```maru-check @R-total
john_run
plan_frontier
```

### Lanes and `next.l`

`./eval notes/plan/next.l [--lane NAME]` MUST print, after its account of what is done and why, the lane's frontier
and then the overflow: one line per choice, `next: PLAN: STEP  score N` for the first, `then: PLAN: STEP  score N`
for the rest. The lane's plan comes first; the other plans follow in the order of their names, each in its own
frontier's order. A plan whose every capability is done contributes nothing; when no plan contributes, `next.l`
prints `nothing left to build`. [R-lanes]
Scores of different plans aren't compared, because each plan weighs its own qualities.

```maru-check @R-lanes
plan_frontier
```

```
FUNCTION next(lane) -> List of Choice:
    -- Step 1: the plans are notes/plan/*.john, less the ledgers
    plans = sort(names of notes/plan/*.john not ending in "-evidence")
    IF lane NOT IN plans: FAIL E_UNKNOWN_LANE
    -- Step 2: the lane first, then the others by name
    out = []
    FOR p IN [lane] + (plans - [lane]):
        world = replay(p.john, p's ledger, Now = tree-hash)
        out += [Choice(p, step, score) FOR (step, score) IN choices(world, T, deliver)]
    RETURN out    -- empty: "nothing left to build"

-- Behavior:
--   - runs no check; reads only plans, ledgers and the tree hash
--   - the same plans, ledgers and tree give the same answer
```

An agent MUST take its next work from the first line of `next.l` in its lane. Two agents asking at once can be given
the same step; without a coordination ledger this document accepts that, and lanes make it rare.

### Feedback

Human feedback on the work MUST become a change to a plan: a capability, a check that shows it, a `builds-on`, a
qualification or a weight. The change is committed with the feedback quoted in the commit message. Feedback that can't
be written as a change to a plan is taken back to the person who gave it, and never acted on outside the plan. This is
a rule for agents, with no check: it is enforced by review, and AGENTS.md states it.

### Plans name real checks

Every `make Case NAME` in every plan MUST name a case `check/check.l` defines; `plan_evidence` fails naming each one
that doesn't. [R-plans-name-cases]
A plan that names a missing case can never see its capability done, and nothing else would say why.

```maru-check @R-plans-name-cases
plan_evidence
```

### Errors

| Error | Example | Recovery |
|---|---|---|
| tree changed during the run | a file saved while `make check` runs | No results file; the run's results are recorded nowhere. Run again |
| `E_UNKNOWN_LANE` | `next.l --lane kworld` | Exit 1 naming the lane and the plans there are |
| unknown case in a plan | `make Case ksworld_render untested.` | `plan_evidence` fails naming plan and case; fix the plan |
| `choices` for an unknown object or goal | `choices T delivr.` | The session's error for an unknown name; nothing changes |
| ledger not writable | a read-only checkout | `make check` reports it and still exits by its cases' outcome |

## Formal Grammar

```abnf
results-file   = tree-line complete-line *outcome-line
tree-line      = %s"tree " 12HEXDIG LF
complete-line  = %s"complete " ( %s"yes" / %s"no" ) LF
outcome-line   = case-name SP ( %s"passed" / %s"failed" ) LF
case-name      = 1*( %x61-7A / DIGIT / "_" )

total-expr     = %s"total" 1*SP set-expr 1*SP %s"by" 1*SP expr
set-expr       = %s"all" 1*SP name / "(" expr ")" / name
expr           = 1*( %x20-7E )   ; a JOHN expression, as john.g reads it
choices-stmt   = %s"choices" 1*SP name 1*SP name "."
choice-line    = step 2SP %s"score " number LF
choices-end    = %s"choices: " 1*DIGIT "." LF
next-line      = ( %s"next: " / %s"then: " ) name %s": " step 2SP %s"score " number LF
step           = name *( SP name )
name           = ALPHA *( ALPHA / DIGIT / "-" / "_" )
number         = [ "-" ] 1*DIGIT [ "." 1*DIGIT ]
```

## Out of Scope

**Exclusive claims.** Handing each step to exactly one agent. It needs a coordination ledger, which the plans are not;
chit and laneq are such ledgers. Extension point: `next.l`'s answer, a list of choices, is what a dispatcher would push
into laneq, and a claim would be an event in the ledger, as `check/john/airline.john` keeps reservations.

**Parallel planning.** JOHN planning several steps in one world. JOHN takes one action a step, in its search and in its
SAT encoding; the frontier gives several agents work without changing that. Extension point: `choices`.

**Cross-plan dependencies.** A capability in one plan building on one in another. Extension point: a `builds-on` naming
`PLAN:Capability`, read by `next.l`'s replay.

## Alternatives Considered

**Why not rank the frontier in Maru code in `next.l`?** It is quicker to write, but what makes work urgent would live
outside the plan, so a person's feedback about priorities would change code rather than the specification.

**Why not push the frontier into laneq now?** It gives exclusive hand-out at once, but brings a Python tool into the
loop and a ledger the plans don't otherwise need; it remains the extension point for claims.

**Why not keep stale evidence as a blocker?** It is the strictest reading of "evidence about the code as it stands",
but every edit makes every answer stale, so with several lanes nobody could ever be told what to do. Done still needs
current evidence; only the ranking uses older answers.

**Why not have `make check` run `notes/plan/record`?** `record` asks every check, measures and grammars included, so
the suite's cases would run twice. Recording from the results file runs nothing.

## Security Considerations

A plan `load`s Maru files and its probes run commands (`Measure`'s `command`), so a plan is code with the trust of the
rest of the tree; nothing here reads a plan or ledger from outside the repository. Ledgers are written by `make check`
from outcomes it computed, never from case output, so a case can't write an event. Feedback reaches a plan only as a
commit a person can read. Agents taking work from `next.l` act on the tree as they already do; the frontier names
steps of the plan, never commands.

## Compatibility

`next.l` stops answering `next: notes/plan/record full` and answers the frontier instead; scripts that grep for that
line change. `make check` writes the results file and appends to the ledgers, so a run leaves tracked files modified,
committed with the code they're about (`notes/plan/LOOP.md`'s rule). `MARU_RECORD=0` restores the old behavior for a
run. The existing plans gain the four qualities and their heuristics, and `render.john` its case names corrected.
`MARU_PLAN` keeps its meaning.

## References

- `draft-ndn-maru-john-session-00`: JOHN as a session, which `choices` joins.
- `draft-ndn-maru-typed-tree-matching-00`: the stage `tree-matching.john` plans.
- `doc/john.md`, `doc/evidence-plan.md`: JOHN and the evidence plan as they stand.
- `notes/plan/LOOP.md`: the loop's rules.
- Samimi, H. et al., RN-2008-003, the JOHN memo (`~/pkm`).
- BCP 14 (RFC 2119, RFC 8174); ABNF (RFC 5234, RFC 7405).
