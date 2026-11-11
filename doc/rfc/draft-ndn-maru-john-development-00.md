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
- **ledger** — a plan's evidence file, `notes/plan/NAME.answers`: a serialized JOHN chain of worlds, one Maru form per
  line, each a world (the action that made it and what it wrote) or a declaration.
- **history** — what a property of an object was at each time of the chain: its writes, in order of time.
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
ledger; how a JOHN chain of worlds is written and read back, with each property's history; what "done" and "ready"
require of evidence; the `choices` statement and the frontier it answers; how a plan
scores steps from its evidence; how a plan minimizes erosion; `total`; lanes and overflow in `next.l`; and the rule that keeps plans naming real cases. It
does NOT define JOHN's semantics beyond `choices`, `was`, `over time` and serialization (owned by `draft-ndn-maru-john-session-00` and `doc/john.md`), the
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

RECORD WorldLine:                   -- a ledger line: (world (ACTOR ACTION ARG...) ((OBJECT PROPERTY VALUE) ...))
    action   : List                 -- the step that made the world: tree_lists observed (value passed (tree "T"))
    writes   : List of (Symbol, Symbol, Value)   -- every write the action made, in the order it made them

RECORD MakeLine:                    -- a ledger line: (make CLASS NAME VALUE ...), a declaration; it moves no time
    class    : Symbol
    name     : Symbol
    values   : List of Value        -- the class's properties, in order

ENUM ValueForm:                     -- how a JOHN value is written in a ledger
    atom                            -- a name, a number or a string, as Maru's reader reads it
    list                            -- (list V ...)
    fields                          -- (value KIND (FIELD V) ...): passed(tree: "T") is (value passed (tree "T"))

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
| `MARU_RETIRE_AFTER` | whole number | `20` | commits a `retired NAME.` stays in its plan before recording drops the name's lines |
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

After `make check` writes a results file, and unless `MARU_RECORD` is `0`, every plan's ledger MUST gain one world
for each `Case` C the plan declares that the run passed or failed, and none for any other case: the world the step
`C observed passed(tree: "T")` (or `failed`) makes, with the writes the plan's `observed` action gives it, so
`(world (C observed (value passed (tree "T"))) ((C evidence (value passed (tree "T")))))`. A run with `complete` true
and every outcome passed MUST also add the world of `WholeSuite observed passed(tree: "T")` to every plan that declares
the measure `WholeSuite`. Worlds are appended in the order the run's outcomes finished. [R-run-records]
Measures, grammars and laws are not cases of `check/check.l`; `notes/plan/record` still asks them, and MUST NOT run a
`Case` whose current answer the ledger already holds. A `make check` that a probe runs sets `MARU_RECORD=0`, since
`record` writes that probe's answer itself.

```maru-check @R-run-records
plan_record
```

Each ledger MUST be marked `merge=union` in `.gitattributes`. [R-ledger-union]
Lanes append to the same ledgers on different branches. A branch is a world sprouted from main's, and a merge is its
commit (Warth's worlds, 2011, §2.2), which is safe when nothing the branch wrote depended on what it read: recording an
answer reads no earlier answer, so lanes' worlds commute. A union merge keeps each side's lines in their order, so
times relative to others of the same lane stay right; between lanes, which ran at once, no order was ever defined. So
no quality a plan defines MAY depend on the order of two answers recorded by different lanes; the states below read the
set of answers.

```maru-check @R-ledger-union
plan_evidence
```

A session MUST be able to write its chain of worlds, from world 1 to the current world, as ledger lines
(`john-serialize`), and to read such lines back (`john-deserialize`) into worlds whose writes are the lines' own,
evaluating nothing: an action's consequence is what it wrote then, and a plan edited since doesn't rewrite its past.
A ledger MUST be read by Maru's reader (`read`), never by `john.g`. A world's time is its position in the chain read
back, never a number stored in it, so a merge can't make two worlds claim one time. `make` lines are declarations,
entered in world 0 before the worlds, as a session enters them. The possible worlds past the current one are not
written: search makes them again, as RN-2008-003 has it. A line that is neither form, or that names an object, action,
property or kind the plan doesn't declare and hasn't retired (below), MUST fail naming the ledger and the line.
[R-ledger-forms]
A ledger grows with every run and is read whenever anyone asks what's next. At the time of writing `john.g` reads about
13 ms a line, twice (a relation can be used before its `rel-qualify`), so a ledger of 1380 events took 41 s to read;
Maru's reader reads 19,800 lines of the same events in 0.08 s.

```maru-check @R-ledger-forms
john_session
plan_evidence
```

Reading a chain back MUST also give each object's property its history, so that reading a property at any time of the
chain finds the write in force then without walking the worlds between (a search of the history, logarithmic in its
length), and so that `E over time`, with E a property read `X p`, answers the distinct values X's p has held from world
0 to the current time, in the order each first appeared, from the history alone, and `E was V` answers `E is V` with E's
property read as it was just before its last write, with no earlier value answering no. [R-history-index]
A world holds only its own writes and finds the rest through its parent (RN-2008-003 §4), which is right for search,
where chains are short, and slow for a ledger thousands of worlds long: each read of a property written early walks
them all. A history per property is Reed's object history (1978, §3.3), a function from time to version; the chain
keeps its single time, and each property its own points of change.

```maru-check @R-history-index
john_session
plan_evidence
```

Recording MUST drop a world whose action and writes equal those of a world earlier in the ledger, and a `make` line
equal to an earlier one, keeping the first; nothing else is dropped but what retirement drops. [R-ledger-dedupe]
The same answer about the same code, recorded on two branches, is one event, and Elephant's journal is "virtual": what
is never referred to need not be kept. A later world moves to an earlier time, and the order of the rest stays.

```maru-check @R-ledger-dedupe
plan_record
```

A plan MAY declare `retired NAME.` for an object it no longer has, a check dropped or renamed. Reading a ledger MUST
skip, and keep in the file, every world whose action or writes name a retired object and every `make` line making one;
`next.l` MUST say how many it skipped and for which names (`skipped 3 events about retired: tree_old`). Recording MUST
drop those lines from the ledger once the plan has declared `retired NAME.` for at least `MARU_RETIRE_AFTER` commits:
the commits on the current branch since the first that holds the declaration in the plan file (`git rev-list --count
C..HEAD`); a retirement not yet committed has none. Once they are dropped the declaration MAY go too. [R-retired]
Feedback edits plans, and dropping or renaming a check is such an edit; its old answers are history about a check that
no longer exists, which shouldn't stop the plan from loading, nor be deleted by hand from a file only recording writes.
Naming the retired objects keeps a misspelled name failing, and the delay lets branches that still record the old name
merge before its lines go. Commits, not pushes, because a checkout can count only its own history.

```maru-check @R-retired
plan_evidence
plan_record
```

### Done, ready and stale

A plan MUST qualify a check's states from what its world holds: its latest answer, `its evidence`, and its last good
answer, `its last-good`, which the `observed` action writes with a good answer
(`its evidence = Answer and its last-good = Answer if Answer is Good`), as this table gives them, and `Capability proven`
only when the capability shows at least one check and every one holds; `ready` is every `builds-on` done, as
`tree-matching.john` has it today. [R-done-current]

| State | The check's answers |
|---|---|
| `holds` | the latest answer is good, for the current tree |
| `failing` | the latest answer is neither good nor untested, for the current tree |
| `regressed` | `failing`, and some earlier answer was good |
| `stale` | the latest answer is for another tree |
| `untested` | no answers |

A state is about the check now, so it reads the current value, not every answer the check has had: a later answer for
the current tree replaces an earlier one, and a check fixed on this tree holds. Only runs in this checkout answer for its
tree, and a merge makes a new tree, so union-merged answers from other lanes are stale until a run here answers them. What a state needs from the
past is kept in the world by the action that learns it, as JOHN keeps all state (RN-2008-003 §4), not worked out again
from the history at each ask: `regressed` stays until the check holds again, however many failing runs come between.
`E was V` (KScript's previous value, `x'`, TR-2013-002 §3.2, read per property) asks the value before the last write,
and `over time` every value; neither is needed for a state.

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
| `regressing` | is `regressed` | 10000 |
| `failing` | is `failing` and not `regressed` | 1000 |
| `aging` | is `stale` | 100 |
| `untried` | is `untested` | 10 |

Regressions come first because they break what was done; then what is known to fail, whose cause is closest at hand;
then what passed once and only needs confirming; then what nobody has tried. A plan changes the order by changing a
weight, not `next.l`.

```maru-check @R-plan-heuristics
plan_frontier
```

### Erosion

Every plan MUST minimize erosion. Recording the plan's `Measure` `Erosion` runs `erosion-run.l --hotspots` over the
`lines` check's files, which prints every callable over CC 10, not only the ten heaviest, since a partial total would
understate erosion. For each, the ledger gains a line
`(make Hotspot H_TREE_FILE_LINE "callable" "file" LINE CC MASS "T" no)`, with FILE's non-alphanumerics as `_` and MASS
CC x sqrt(SLOC) rounded to a whole number, after the measure's own world. A `make` moves no time, so each hotspot is a
fact of world 0, `planned` no. A plan qualifies `Hotspot current` as its tree being the
current tree's, MUST declare `action Team simplify Hotspot consequence Hotspot planned = yes.`, allowed only for a
current hotspot not yet planned, and MUST carry
`heuristic Team deliver W minimize total (select all Hotspot by which planned = no and which current = yes) by which mass.`
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
    -- Step 1: the plans are notes/plan/*.john; ledgers are NAME.answers
    plans = sort(names of notes/plan/*.john)
    IF lane NOT IN plans: FAIL E_UNKNOWN_LANE
    -- Step 2: the lane first, then the others by name
    out = []
    FOR p IN [lane] + (plans - [lane]):
        world = john-deserialize(p.answers) after p.john, Now = tree-hash
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
| ledger line naming a dropped check | `(world (tree_old observed …) …)` after `tree_old` left the plan | Reading fails naming the line; declare `retired tree_old.` in the plan |
| bad ledger line | `(world (tree_lists observd (value passed (tree "504c17079996"))) ())` | Reading the plan fails naming the ledger and line; fix or drop the line |
| ledger not writable | a read-only checkout | `make check` reports it and still exits by its cases' outcome |

## Formal Grammar

```abnf
results-file   = tree-line complete-line *outcome-line
tree-line      = %s"tree " 12HEXDIG LF
complete-line  = %s"complete " ( %s"yes" / %s"no" ) LF
outcome-line   = case-name SP ( %s"passed" / %s"failed" ) LF
case-name      = 1*( %x61-7A / DIGIT / "_" )

ledger-line    = ( world-line / make-line ) LF
world-line     = %s"(world (" name SP name *( SP value ) ") (" [ write *( SP write ) ] "))"
write          = "(" name SP name SP value ")"
make-line      = %s"(make " name SP name *( SP value ) ")"
value          = string / number / name / list-value / fields-value
list-value     = %s"(list" *( SP value ) ")"
fields-value   = %s"(value " name *( SP field ) ")"
field          = "(" name SP value ")"
string         = DQUOTE *( %x20-21 / %x23-5B / %x5D-7E / "\" ( DQUOTE / "\" / "n" ) ) DQUOTE

total-expr     = %s"total" 1*SP set-expr 1*SP %s"by" 1*SP expr
set-expr       = %s"all" 1*SP name / "(" expr ")" / name
expr           = 1*( %x20-7E )   ; a JOHN expression, as john.g reads it
over-time      = expr 1*SP %s"over" 1*SP %s"time"
retired-stmt   = %s"retired" 1*SP name "."
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
into laneq, and a claim would be a line in the ledger, as `check/john/airline.john` keeps reservations.

**Parallel planning.** JOHN planning several steps in one world. JOHN takes one action a step, in its search and in its
SAT encoding; the frontier gives several agents work without changing that. Extension point: `choices`.

**CBOR serialization.** A second encoding of the same chain, CBOR (RFC 8949), whose definite-length items let a
reader skip a world without reading it, and which is smaller. Extension point: `john-serialize` writes forms whose
shapes (lists, names, numbers, strings, a tagged value with fields) map one to one onto CBOR arrays, text and tags; a
`.answers.cbor` made from the text ledger, untracked, would serve as a cache. Tracking the CBOR instead takes a
`textconv` diff and a merge driver in `.gitattributes`, configured in every clone (by `make`, say).

**Cross-plan dependencies.** A capability in one plan building on one in another. Extension point: a `builds-on` naming
`PLAN:Capability`, read by `next.l`.

## Alternatives Considered

**Why not rank the frontier in Maru code in `next.l`?** It is quicker to write, but what makes work urgent would live
outside the plan, so a person's feedback about priorities would change code rather than the specification.

**Why not push the frontier into laneq now?** It gives exclusive hand-out at once, but brings a Python tool into the
loop and a ledger the plans don't otherwise need; it remains the extension point for claims.

**Why not keep stale evidence as a blocker?** It is the strictest reading of "evidence about the code as it stands",
but every edit makes every answer stale, so with several lanes nobody could ever be told what to do. Done still needs
current evidence; only the ranking uses older answers.

**Why not keep the ledger as JOHN statements and make `john.g` faster?** Reading in one pass, with relations resolved
after parsing, would halve the cost and help every JOHN program, but even one pass is about a thousand times slower
than Maru's reader, and a ledger is data, which needs none of JOHN's syntax. A faster `john.g` is worth doing for its
own sake.

**Why not a binary format such as CBOR, or a LevelDB-like store, as the ledger?** The cost was parsing JOHN, not
text: Maru's reader reads a ledger in milliseconds. Git can diff and merge a binary ledger through `.gitattributes`
(`diff=` with a `textconv` command that decodes it, `merge=` with a driver that decodes both sides, takes their union,
dedupes and encodes), but those drivers are set in each clone's own git configuration, not in the repository, and run
Maru; a clone without them, or a merge made on a forge's server, sees conflicting binary files. `merge=union` is built
into git and needs nothing. What LevelDB offers, an append-only log with one entry per key, is
what appending and deduplicating give. A CBOR encoding beside the text remains open (see Out of Scope).

**Why not drop answers no state reads?** Keeping per check only the current tree's answers and one good answer about
older code would hold a ledger to about two lines a check, but would cut the history `at time` and `did` read. Reading
is cheap enough that every event is kept until size is shown to matter.

**Why not facts in world 0, with no time?** The states read only the set of answers, but history queries (`regressed`
through `at time`, `observed-within`) need the order a lane recorded them in, which only worlds keep.

**Why not have `make check` run `notes/plan/record`?** `record` asks every check, measures and grammars included, so
the suite's cases would run twice. Recording from the results file runs nothing.

## Security Considerations

A plan `load`s Maru files and its probes run commands (`Measure`'s `command`), so a plan is code with the trust of the
rest of the tree; nothing here reads a plan or ledger from outside the repository. Ledgers are written by `make check`
from outcomes it computed, never from case output, so a case can't write an answer. A ledger is read by `read`,
which evaluates nothing, so a ledger line is never code. Feedback reaches a plan only as a
commit a person can read. Agents taking work from `next.l` act on the tree as they already do; the frontier names
steps of the plan, never commands.

## Compatibility

`next.l` stops answering `next: notes/plan/record full` and answers the frontier instead; scripts that grep for that
line change. The ledgers move from `evidence.john` and `NAME-evidence.john` to `NAME.answers`: each plan's existing evidence is
replayed once and its chain written by `john-serialize`. The plans keep their `observed` action and their history
readings, and their states read `its evidence` and `its last-good`. `make check` writes the results file and appends to the ledgers, so a run leaves tracked files modified,
committed with the code they're about (`notes/plan/LOOP.md`'s rule). `MARU_RECORD=0` restores the old behavior for a
run. The existing plans gain the four qualities and their heuristics, and `render.john` its case names corrected.
`MARU_PLAN` keeps its meaning.

## References

- `draft-ndn-maru-john-session-00`: JOHN as a session, which `choices` joins.
- `draft-ndn-maru-typed-tree-matching-00`: the stage `tree-matching.john` plans.
- `doc/john.md`, `doc/evidence-plan.md`: JOHN and the evidence plan as they stand.
- `notes/plan/LOOP.md`: the loop's rules.
- Samimi, H. et al., RN-2008-003, the JOHN memo (`~/pkm`).
- Warth, A. et al., Worlds: Controlling the Scope of Side Effects, 2011 (`~/pkm/raw/vpri/warth-2011-worlds.txt`).
- Reed, D. P., Naming and Synchronization in a Decentralized Computer System, 1978 (`~/pkm/raw/vpri/`).
- McCarthy, J., Elephant 2000, 1990 draft (`~/pkm/raw/mccarthy/`).
- RFC 8949: CBOR, for the extension in Out of Scope.
- BCP 14 (RFC 2119, RFC 8174); ABNF (RFC 5234, RFC 7405).
