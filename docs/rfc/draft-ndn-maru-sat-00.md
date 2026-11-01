# draft-ndn-maru-sat-00: A SAT Solver for Maru, with Checked Proofs and JOHN Planning

**Status:** DRAFT
**Corpus:** red (spec-first — evidence is the acceptance criteria)
**Category:** Experimental
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies a Boolean satisfiability (SAT) solver for Maru. It is written in irl and
runs as native code through ir2, and it proves every "no solution" answer with a DRAT proof that
a separate checker verifies. It also specifies an encoding of JOHN planning problems, numbers
and lists included, into the solver's clauses, so that `satisfy` can plan by satisfiability as
well as by search. It is written for whoever plans with JOHN, and for the laws search that will
use the same solver next.

## Motivation

JOHN's evaluator (`john-eval.l`) plans by searching possible worlds level by level. Merging
worlds that reach the same state brought a consistent four-disk Towers of Hanoi within reach,
but the search remains exponential in the plan's length. Samimi's measurements in M-2009-001
show the alternative: the brute-force JOHN planner hadn't solved Hanoi4 after two hours, while
MiniSat solved the same problem's clauses in 9 seconds.

The memo's encoding covers only programs whose values are all objects (numbers are spelt `One`,
`Two` ...). The x86 register allocator, the memos' one complete program with real numbers and
lists, is out of its reach. The laws search needs the same solver for a different reason: a
`PROVED` law should rest on an answer that can be checked, not on trust in a solver.

This document provides the solver, its proofs and their checker, and the JOHN encoding. It does
so now because the typed stack (irl, ir2) can express a solver today. Each later backend runs
the solver unchanged: first ir2's C backend, then a native arm64 backend.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **variable** — a Boolean unknown, numbered from 1.
- **literal** — a variable (`v`) or its negation (`-v`), written as a nonzero integer.
- **clause** — a disjunction of literals; satisfied when one of them is true.
- **formula** — a conjunction of clauses, as written in a DIMACS CNF file.
- **solver** — the irl program that decides a formula: SAT with an assignment, or UNSAT.
- **assignment** — a truth value for every variable, as the solver reports it for SAT.
- **proof** — the DRAT lines the solver writes while deciding a formula: each line adds a
  clause it learned or deletes a clause it no longer uses.
- **checker** — the irl program, separate from the solver, that decides whether a proof
  shows the formula UNSAT.
- **encoder** — the Maru code that turns a JOHN program and a plan length into a formula.
- **bound** — a limit that makes the encoding finite: a number's width in bits, a list's
  greatest length, a qualification's unrolling depth, a plan's greatest length.
- **sort** — what kind of value a JOHN property holds: a number, a name, or a list of some
  sort.

## Specification

This document defines the solver, its programming interface, its proofs, the checker, the
grammars that read formulas and proofs, the grammar blocks in irl that those grammars need,
and the encoding of JOHN planning into formulas. It does NOT define JOHN's language or its
search (`john.g`, `john-eval.l`, and the reconstruction they follow), irl beyond its grammar
blocks, ir2 or its backends, or how the laws search will use the solver (Out of Scope).

**The solver is typed Maru.** The solver and the checker are irl programs, compiled through
`compile-irl.l` and ir2 like any typed program. Neither is C written by hand, and neither
calls a solver that exists outside the tree.

**Nothing is taken on trust.** The checker verifies every UNSAT answer against the formula it
reads itself. Maru code checks every SAT answer against the formula's clauses. The evaluator
replays every plan the encoding yields before reporting it.

**A proof covers the formula, not the program.** A checked proof shows that the encoder's
clauses have no solution. That is not the same as showing the JOHN program has no plan: the
encoder could be wrong, or a plan could need larger bounds. So every "no solution" names its
bounds, and the encoder is cross-checked against the search wherever the search finishes.

**The checker is simpler than the solver.** It shares no code with the solver beyond reading
literals. An error in the solver therefore can't hide behind the same error in the checker.

**Formats are grammars.** DIMACS and the proof format are read by grammars, written once with
their semantic actions in the target language, never by a lexer written out by hand. This is the
tree's own rule ("prefer a DSL or grammar over writing code out"), and how Pepsi
(`test-pepsi.l`) carries target code through its grammar.

### Data model

```
RECORD Solver:                     -- one per formula; created by sat_init
    clauses     : ClauseStore       -- the formula's clauses and the learned ones
    watches     : WatchLists        -- for each literal, the clauses watching it
    trail       : Integer*          -- literals assigned, in order, with decision levels
    activity    : Real*             -- per variable, for choosing the next decision
    assumptions : Integer*          -- literals assumed for the next sat_solve only
    proof       : ProofSink | None  -- where proof lines go, if anywhere

RECORD ProofLine:
    kind        : ProofKind
    literals    : Integer*          -- a clause, without its terminating 0

ENUM ProofKind:
    ADD         -- the clause follows from the clauses before it
    DELETE      -- the clause is no longer used

ENUM Answer:                        -- sat_solve's result, numbered as IPASIR numbers them
    SAT     = 10
    UNSAT   = 20
    UNKNOWN = 0                     -- interrupted by the conflict limit

ENUM Sort:
    NUMBER      -- a two's-complement integer of sat-width bits
    NAME        -- any name the program uses, objects of every class and words like empty,
                -- yes and no alike, encoded by its index in one numbering of all names
    LIST        -- at most sat-list-length elements of one sort, lists included, and a length
```

**Field constraints:** a literal is a nonzero integer whose absolute value is at most the
number of variables. A clause holds no literal twice. A proof line's literals follow the same
rules.

### Configuration

| Key | Type | Default | Description |
|---|---|---|---|
| `planner` | `search` \| `sat` | `search` | How `satisfy` plans |
| `sat-width` | Integer | `16` | Bits in a number |
| `sat-list-length` | Integer | `16` | The greatest length of a list |
| `sat-unroll` | Integer | `16` | How deep a recursive qualification unrolls |
| `sat-proof-dir` | Path | `/tmp/maru-sat` | Where proofs are written |
| `sat-conflicts` | Integer | `1000000` | Conflicts before `sat_solve` answers `UNKNOWN` |

The defaults have reasons:
- `planner` stays `search`, so existing programs keep the memos' behaviour.
- `sat-width` 16 holds every number in the x86 allocator, whose largest is 22, with room for
  sums and differences.
- `sat-list-length` 16 holds its 12-slot register banks.
- `sat-unroll` 16 covers `repeatn:` to 12.
- The plan length is bounded by the evaluator's existing time limit (16 steps), not by a new
  key.

**Resolution precedence** (highest first):

1. `set-opt KEY VALUE` in the program
2. The default above

### Behavior

#### The solver

The solver MUST present the IPASIR interface:
- `sat_init()` creates a solver.
- `sat_add(s, lit)` adds a literal to the clause being built; 0 ends the clause.
- `sat_assume(s, lit)` assumes a literal for the next solve only.
- `sat_solve(s)` answers 10, 20 or 0.
- `sat_val(s, lit)` returns `lit` if it is true in the assignment, `-lit` if not.
- `sat_failed(s, lit)` reports whether an assumption was used to show UNSAT.
- `sat_release(s)` frees the solver.

Clauses MAY be added between solves. [R-ipasir]

IPASIR is the standard interface of incremental SAT solvers, so Maru's clients are written once.
The laws search will need incremental solving and assumptions, so the interface has both from
the start.

```maru-check @R-ipasir
sat_core
```

The solver MUST be a conflict-driven clause-learning solver:
- two watched literals per clause;
- a clause learned from each conflict, by the first unique implication point;
- non-chronological backjumping;
- variables chosen by decaying activity;
- restarts. [R-cdcl]

The literature's solver design. Each part is what makes such solvers fast enough for planning;
without one of them, Hanoi4's formula takes the minutes JOHN's own MiniSat took (34) rather than
seconds.

```maru-check @R-cdcl
sat_core
```

Every SAT answer MUST be checked, in Maru, against every clause of the formula as it was given,
before any client sees it. An assignment that falsifies a clause is `E_MODEL`. [R-model-checked]

```maru-check @R-model-checked
sat_core
```

The solver and the checker MUST be built from irl through `compile-irl.l` and ir2's C backend
into one shared library, `sat.dylib` (or `sat.so`), in the tree. Untyped Maru loads it from that
path through `dlopen.k`, never from a path a program supplies. [R-native]

Today the C backend is ir2's way to native code on arm64. When an arm64 backend exists, the
same `.k` loads into a code region in-process (RFC 0001's region) without a change to the
solver.

```maru-check @R-native
sat_core
```

#### Proofs and the checker

For each UNSAT answer to a solve without assumptions on a fresh solver, the solver MUST write a
DRAT proof: each learned clause added, each discarded clause deleted, ending with the empty
clause. [R-drat]

JOHN's planner uses one solver per plan length, so all its UNSAT answers are of this kind. An
UNSAT answer under assumptions derives no empty clause. Its proof (ending, say, with the clause
of the failed assumptions' negations) is left to the laws document, which needs it.

```maru-check @R-drat
sat_proof
```

The checker MUST read the formula from its DIMACS file, never from the solver's memory. It
MUST then read the proof forward, accepting it only if:
- every added clause follows from the clauses present by unit propagation (reverse unit
  propagation, RUP), or else has a literal on which it is a resolution asymmetric tautology
  (RAT);
- deletions are honoured;
- the empty clause is reached.

Anything else is `E_PROOF`. [R-checker]

A forward check is simpler than DRAT-trim's backward check, and slower. Here the checker is the
thing to trust, so simplicity wins.

```maru-check @R-checker
sat_proof
```

The checker MUST reject a proof with a line dropped, a literal changed, or a clause added that
doesn't follow. These are tested by mutating real proofs. [R-checker-rejects]

```maru-check @R-checker-rejects
sat_proof
```

#### Grammars in irl

`compile-tpeg.l` MUST compile a foreign rule call, `p-r` in a grammar (`(match-rule-in p r)`):
the rule `r` of grammar `<p>`, run on the same input from the same position, with its own memo
table, its result and end position carried back. [R-tpeg-foreign]

`tpeg.g` already reads `p-r`, but only `parser.l` compiled it. It is how one grammar uses
another's rules without copying them, and irl uses it to read grammar blocks with tpeg's own
rules.

```maru-check @R-tpeg-foreign
irl_grammar
```

irl MUST read a grammar block, `grammar <name> : <parent> (fields) { rules }`, in tpeg's own
syntax, through a foreign call to tpeg's `grammar` rule. `compile-irl.l` MUST compile the
block's records to typed Maru:
- each rule becomes a typed function over the input and a position, returning the position
  after its match, or failure;
- `:x` bindings are typed locals;
- `@$#` spans become numbers;
- the grammar's fields are the state its actions share;
- each action (`-> sexpression`) is a maru.k form, copied into the function unchanged.

Rules from `<parent>` that the block doesn't override are inherited. [R-irl-grammar]

The actions are the target language passed through, as Pepsi passes Maru through its method
bodies. A rule's value is a number or a pointer, since typed Maru has no lists, so a grammar
builds structure by its actions' effects. DIMACS does exactly that: a clause's action adds its
literals.

```maru-check @R-irl-grammar
irl_grammar
```

#### DIMACS and the generated instances

DIMACS and the proof format MUST be read by irl grammar blocks in the library: one for formulas,
whose actions add each clause, and one for proofs, whose actions add or delete each line. No
character of either format is read by code written out by hand. [R-formats-grammars]

```maru-check @R-formats-grammars
sat_dimacs
sat_proof
```

The DIMACS grammar MUST:
- accept the `p cnf V C` header, `c` comment lines, and clauses ending in 0;
- reject a literal larger than `V`, a count that disagrees with `C`, or anything else, as
  `E_DIMACS`, naming the line. [R-dimacs]

```maru-check @R-dimacs
sat_dimacs
```

The test instances MUST be generated, each with its answer known by construction:

| Family | Answer |
|---|---|
| Pigeonhole, n+1 pigeons in n holes, n from 2 to 7 | UNSAT |
| n-queens, n from 1 to 8 | SAT, except UNSAT for n = 2 and 3 |
| Random 3-SAT, from a planted assignment | SAT, at four clause-to-variable ratios, seeded |

Each run MUST agree with the known answer, and each UNSAT answer's proof MUST be accepted by
the checker. [R-generated-instances]

Generated instances keep third-party benchmark files out of the public tree, and their answers
don't depend on trusting another solver.

```maru-check @R-generated-instances
sat_dimacs
```

#### JOHN planning by satisfiability

With `set-opt planner sat`, `satisfy` MUST plan by satisfiability and report a plan in the
search's format: `satisfied at time: k` and `satisfied by: [ ... ]`. In place of the search's
`looking …` lines it prints one line per length tried:
`trying k steps (V variables, C clauses): unsatisfiable`, or `… satisfiable`. Among plans of
the least length it MAY find a different one from the search's. Each is a real plan, because
the evaluator replays it. [R-planner-option]

```maru-check @R-planner-option
sat_john
```

An `unsatisfiable` report under `planner sat` MUST name the bounds it holds within: the plan
length tried, `sat-width`, `sat-list-length` and `sat-unroll`. For example, `unsatisfiable
within 16 steps (width 16, lists 16, unroll 16)`. [R-unsat-bounds]

A checked proof covers the clauses. A plan that needs a longer list or a deeper unrolling than
the bounds allow isn't in them, so the report never claims more than they cover.

```maru-check @R-unsat-bounds
sat_john
```

On every JOHN program where the search finishes, the two planners MUST agree on whether a plan
exists and on its least length:
- `hanoi2.john` and `hanoi3.john`;
- the maze;
- the trap breadth-first;
- Nim from 3 and from 4 without minimax.

Each case runs both planners. A program whose search stops with an error is not one where the
search finishes. [R-differential]

The replay checks the plans the encoder finds. Only this comparison checks the encoder's "no
solution" answers, and the plan lengths it skips, against a planner that doesn't share its code.

```maru-check @R-differential
sat_john
```

```
FUNCTION satisfy_by_sat(object, goal) -> Report:
    -- Step 1: sorts and domains, before any clause (E_SORT, E_BOUND)
    sorts := infer_sorts(program)
    -- Step 2: the shortest plan first
    FOR k IN 0 .. time_limit:
        f := encode(program, sorts, object, goal, k)    -- states 0..k, one action per step
        answer, proof := solve(f)
        IF answer = SAT:
            plan := actions_true_in(assignment)
            -- Step 3: the evaluator replays the plan; any difference is a bug, not a result
            IF NOT replay(plan) reaches goal: FAIL E_ENCODING
            RETURN satisfied(k, plan)
        -- UNSAT at length k: the proof is checked before the next length is tried
        IF NOT check(f, proof): FAIL E_PROOF
    RETURN unsatisfiable(time_limit)

-- Behavior:
--   - A plan is reported only after the evaluator has replayed it
--   - Its length is the least length whose formula is SAT, so it is as short as the search's
--   - "unsatisfiable" stands on one checked proof per length tried, and holds only within the
--     bounds the report names
```

The encoder MUST encode a JOHN program as a bounded model, the way CBMC encodes C:
- **State:** every mutable property of every object at every time 0 … k becomes bits.
- **Actions:** every action instance at every step becomes a variable, with exactly one taken
  per step.
- **Effects** at step t read the state at t and write the state at t + 1, as the evaluator's
  worlds do. Everything else carries over (the frame).
- **Rules** constrain the action taken.
- **Action-optimizations** narrow its arguments, as constraints.
- **Goal-optimizations** limit which actions a step takes, as constraints. At a step where no
  goal-optimization's condition holds, every action is allowed (G13), as in the evaluator.
- **The goal** holds at time k. [R-bmc-encoding]

The memo's encoding (M-2009-001, Tables 7-19: equality, determinism, the frame axioms, action
exclusivity) is this encoding's special case, where every sort is an object.

```maru-check @R-bmc-encoding
sat_john
```

Expressions MUST be encoded as circuits over their operands' bits:
- **Numbers:** `+`, `-`, `*`, `/` and the comparisons are two's-complement circuits.
- **Lists:** `+` (append or concatenate), `-`, `size`, `first`, `rest`, `at:`, `to:` and
  `from:` are circuits over elements and length.
- **An unknown index** (`at:`, `to:`, `from:`) is a multiplexer.
- **`for every` and `for some`** become conjunction and disjunction over a collection's bounded
  elements.
- **`select`** is a filter: a mask over the instances.
- **Qualifications** are inlined. A recursive one unrolls to `sat-unroll`, and a branch past the
  depth is unsatisfiable, not true.

The evaluator is the reference semantics. Where it stops with an error (`first` of an empty
list, `at:` past the end, a qualification with no clause that applies, division by zero), the
encoding makes the step impossible, as [R-bounds-forbid] does for overflow.
[R-expression-circuits]

```maru-check @R-expression-circuits
sat_john
```

An operation whose exact result doesn't fit its bound MUST make the step that performs it
impossible, never wrap around or truncate. This covers a number outside `sat-width`, a list
longer than `sat-list-length`, and recursion deeper than `sat-unroll`. [R-bounds-forbid]

A wrapped result would be a plan the evaluator can't replay. Forbidding the step keeps every
SAT plan real. The cost is that a plan needing larger bounds reads as unsatisfiable until the
bounds are raised, so the report names the bounds it used.

```maru-check @R-bounds-forbid
sat_john
```

Every property's sort MUST be inferred before encoding:
- from its initial values in `make`;
- from the values its effects assign;
- for a list, from its elements, so nested lists are allowed.

All names share one sort, so a property can hold a Register in one world and `no` in another
(the x86 allocator's `next-right`), or `empty` beside Variables (its `allocations`). A class or
group is a set of names, so a property ranging over a group (Hanoi's `supporting`) needs nothing
more. A string in `make` is turned into its name before encoding (`"Va" name`). A property that
holds a number in one place and a name or list in another is `E_SORT`, and a constant that
doesn't fit its bound is `E_BOUND`, naming the property. [R-sorts]

```maru-check @R-sorts
sat_john
```

A construct the encoding doesn't cover MUST stop the planner with `E_SAT_UNSUPPORTED`, naming
the construct, never be dropped from the encoding. This covers `two-player-game`,
`max-time-ahead`, and expressions reading earlier times. [R-sat-unsupported]

Heuristics only order the search. The SAT path ignores them, and its plans are shortest anyway.

```maru-check @R-sat-unsupported
sat_john
```

The SAT path MUST solve the consistent Hanoi4 (`check/john/hanoi4-ours.john`) in 15 moves. It
MUST solve the x86 allocator (`check/john/x86-allocator.john`) with a plan whose allocation
passes `john_run`'s slot-by-slot check. Both plans are replayed by the evaluator. [R-john-corpus]

```maru-check @R-john-corpus
sat_john
```

#### Time

Each SAT check (`sat_core`, `sat_proof`, `sat_dimacs`, `sat_john`) MUST finish within the 120
seconds that `check/check.l`'s `run` allows a command. [R-time-budget]

Several agents work on this machine at once, on different projects, so a check's CPU time is
time taken from them, and the suite already runs in minutes. The forward checker and a solver
without clause-database reduction are kept as long as they fit. A check that misses the budget
gets the one optimization it needs (backward checking, clause deletion, a smaller encoding),
never all of them at once.

```maru-check @R-time-budget
sat_core
sat_proof
sat_dimacs
sat_john
```

### Errors

| Error | Example | Recovery |
|---|---|---|
| `E_DIMACS` | a literal 9 under `p cnf 8 3` | Reject the file, naming the line; nothing is solved |
| `E_MODEL` | a SAT assignment falsifying a clause | Report a solver bug with the clause; the answer is not used |
| `E_PROOF` | an added clause that doesn't follow | Report a solver bug with the proof line; the answer is not used |
| `E_ENCODING` | a SAT plan the evaluator can't replay | Report an encoder bug with the plan and the step that differs; nothing is reported as satisfied |
| `E_SORT` | a property set to 3 in `make` and to `[ ]` by an effect | Stop before encoding, naming the property and both sorts |
| `E_BOUND` | `make Flight F 70000` with `sat-width` 16 | Stop before encoding, naming the value and the bound to raise |
| `E_SAT_UNSUPPORTED` | `set-opt two-player-game [ A, B ]` under `planner sat` | Stop before encoding, naming the construct; `planner search` still runs it |
| `E_LIBRARY` | `sat.dylib` not built | Stop, naming the make target that builds it |

## Formal Grammar

The proof format is DRAT's textual form. The DIMACS format is the conventional one, with
the restrictions above.

```abnf
dimacs        = *comment header *( comment / clause )
comment       = "c" *( WSP / VCHAR ) LF
header        = "p" 1*WSP "cnf" 1*WSP count 1*WSP count *WSP LF
clause        = *( *WSP literal ) *WSP "0" *WSP LF
literal       = [ "-" ] count
count         = nonzero *DIGIT
nonzero       = %x31-39
proof         = *proof-line
proof-line    = [ "d" 1*WSP ] *( literal 1*WSP ) "0" LF
```

## Out of Scope

**The laws search.** The laws search will ask the solver whether a law has a counterexample up
to a size, and an UNSAT answer with a checked proof will stand behind `PROVED`. That is excluded
here because it needs a second encoding, of `rules.l`'s rules and laws. Extension point:
[R-ipasir]'s assumptions and incremental clauses, which the laws encoding will use. A later
document specifies it, alongside the laws RFC.

That document will have to keep [R-unsat-bounds]'s distinction: a `PROVED` that rests on an UNSAT
answer holds only within the encoding's bounds. So it states them beside the verdict, as the
laws runner already states a law's size, and the laws encoder needs its own differential check
against the rule engine's enumeration.

**Heuristics and two-player games under SAT.** Encoding a heuristic's preference or minimax into
clauses. Excluded because they change which plan is chosen, not whether one exists; the memo
called the heuristic part non-trivial. Extension point: [R-sat-unsupported] lists them, and a
later document replaces that error with an encoding.

**Time-reading expressions under SAT.** Elephant-style `at time T`, `for some time`, and `did`.
Excluded from the first version, though the bounded model holds every earlier state, so they
fit it naturally. Extension point: [R-expression-circuits], extended to read the state at a
constant or quantified time.

**Memoization and left recursion in typed grammars.** `text-parser.l` memoizes rule results and
grows left-recursive rules; [R-irl-grammar]'s typed functions do neither. Excluded because
DIMACS and the proof format need neither, and both are linear. A left-recursive rule in a
grammar block is an error, never a silent loop. Extension point: [R-irl-grammar]'s generator,
which would add a memo table per rule.

**Optimization (MaxSAT) and model counting.** Finding the best plan by a cost, or counting
plans. Extension point: none in this document; the solver's interface would grow an objective.

**Loading in-process without C.** Running the solver from a code region instead of a shared
library. Extension point: [R-native], once ir2 has an arm64 backend.

## Alternatives Considered

**Why not the memo's grounded encoding alone?** It instantiates every formula for every
combination of objects (M-2009-001), so a value must be an object. Numbers become objects such
as `One` and `Two`, and lists can't be written at all. The x86 allocator, half of this
document's bar, is out of its reach. It survives as [R-bmc-encoding]'s special case.

**Why not lazy SMT (CDCL(T)) with an arithmetic theory?** A theory solver for numbers, called by
the SAT solver as it searches. It handles unbounded numbers, but needs a second solver and its
own explanations. Its UNSAT answers don't reduce to a DRAT proof, which [R-checker] requires.
Bit-blasting keeps one solver and one proof format.

**Why not a finite-domain constraint solver?** Propagators for domains of values, as in
constraint programming. That is a second solving engine beside SAT, with its own correctness
argument and no standard proof. The laws search needs SAT's proofs anyway.

**Why not call MiniSat or CaDiCaL?** It is the fastest route, but it brings C written outside
the tree and a process boundary, against the bare-metal goal and [R-native]. It also asks the
proof checker to vouch for a solver it doesn't share a language with. MiniSat's design (watched
literals, first-UIP learning, activity, restarts) is followed instead: [R-cdcl].

**Why not write it in Nothing?** Nothing (STEPS 2010) has no implementation in the tree. irl
runs today, and both languages target the same neutral tree, so the solver needn't be
rewritten when Nothing arrives.

**Why not DRAT-trim's backward checking, or LRAT proofs?** Backward checking verifies only the
clauses the final conflict needs, which is faster, but its marking and core extraction make the
checker larger than the forward check. LRAT proofs carry hints that make checking trivial, but
the solver would have to record every clause's antecedents. DRAT keeps the solver simple, and
the forward check keeps the checker simple.

**Why not a DIMACS reader written by hand?** A lexer in irl, character by character. One was
started, and stopped: it is the code the tree's rule says to replace with a grammar. A grammar
also states the format once, beside its ABNF, where a lexer hides it in loops.

**Why not run the DIMACS grammar as untyped tpeg, its actions calling the library?** That needs
nothing new, but leaves the formats outside the typed stack, read by the interpreter at every
proof line. A grammar block in irl compiles with the solver into native code, and makes grammars
with typed actions available to every later typed program.

**Why not SATLIB benchmark files?** They are the standard test set, but they are third-party
data, and the public tree keeps third-party files out. Their answers would also rest on other
solvers' agreement. Families generated with answers known by construction test the same paths.

## Security Considerations

The solver adds three inputs that cross a boundary:
- **A DIMACS file.** The reader rejects malformed input, oversized counts and out-of-range
  literals before allocating for them ([R-dimacs]). So a crafted file can't make it write past
  its arrays.
- **The shared library.** It is loaded only from its path in the tree ([R-native]), never from a
  path a program names. A JOHN program therefore can't load code.
- **Proofs.** They are written under `sat-proof-dir`, which a program can set. A program could
  therefore write proof files wherever the user can write. The directory MUST be created if
  missing and MUST NOT be followed through a symbolic link at its last component.

Solving time is bounded by `sat-conflicts`. A formula that doesn't finish within it answers
`UNKNOWN`, which the planner reports and doesn't treat as UNSAT.

## Compatibility

New: `sat.irl` (the solver), `drat-check.irl` (the checker), `dimacs.irl` (the two format
grammars), the encoder, and the `sat.dylib` make target. JOHN programs behave as before unless
they set `planner sat`.

`compile-tpeg.l` gains foreign rule calls ([R-tpeg-foreign]). Existing grammars don't use them,
so their compiled output doesn't change.

irl needs small extensions to build a shared library, each its own change:
- an `export` declaration, so a function isn't `static` in ir2's C output (`maru.k`'s `export`
  already supports it underneath);
- a library mode in `compile-irl.l` with no `main`, since a library's top-level statements
  never run;
- building one library from the solver's and the checker's irl together;
- `cast(e, type)` and `sizeof(type)`, onto `maru.k`'s existing forms, since `struct F` in an
  irl expression is a struct literal;
- grammar blocks ([R-irl-grammar]), with a small typed matching runtime.

The library is opened by its absolute path in the tree, not through `dlopen.k`'s directory
search, so [R-native] holds. A `break` statement in irl would shorten the solver's loops, and
MAY be added. ir2 needs nothing new.

`john-eval.l` changes in two places to match [R-expression-circuits]: `at:` with an index below
1 and `to:` with a negative length become errors, as `at:` past the end already is.

## References

- RFC 0001 (`docs/rfc/0001-table-assemblers.md`): the in-process code region [R-native] will
  use once ir2 has an arm64 backend.
- draft-ndn-maru-forms-as-neutral-tree-00: the shared tree irl and Nothing compile to.
- draft-ndn-maru-laws-and-rules-00: the laws search, the solver's second client.
- Samimi, "Programming as Planning", VPRI Memo M-2009-001 (2009): JOHN-SAT's encoding and
  its Hanoi measurements (`~/pkm/raw/vpri/m2009001_prog_as.txt`).
- Samimi, "JOHN – A Knowledge Representation Language", VPRI RN-2008-003; the reconstruction in
  `~/pkm/wiki/synthesis/john-language-reconstruction.md`.
- Balyo, Biere, Iser, Sinz, "SAT Race 2015" (Artificial Intelligence 241, 2016): IPASIR, the
  incremental interface (https://github.com/biotomas/ipasir).
- Eén, Sörensson, "An Extensible SAT-solver" (SAT 2003): MiniSat's design.
- Marques-Silva, Sakallah, "GRASP" (IEEE Trans. Computers, 1999); Moskewicz et al., "Chaff"
  (DAC 2001): clause learning, watched literals, activity.
- Wetzler, Heule, Hunt, "DRAT-trim" (SAT 2014): the DRAT proof format.
- Clarke, Kroening, Lerda, "A Tool for Checking ANSI-C Programs" (TACAS 2004): CBMC, bounded
  model checking by bit-blasting.
- Kautz, Selman, "Planning as Satisfiability" (ECAI 1992): SatPlan, plans by increasing length.
- DIMACS CNF format: the input format of the DIMACS implementation challenges, as used by the
  SAT competitions (https://www.satcompetition.org/).
