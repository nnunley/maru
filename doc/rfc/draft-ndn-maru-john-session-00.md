# draft-ndn-maru-john-session-00: JOHN as a Session, and Its REPL

**Status:** DRAFT
**Corpus:** red (spec-first: the checks named below are the acceptance criteria)
**Category:** Standards-Track
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies how a JOHN program runs: as a session, one statement at a time, against a knowledge base
and a working memory, the model of Samimi's RN-2008-003 (§15). A file is statements entered into a session, and the
REPL, `john-repl.l`, is the same session read from a prompt. It is written for whoever changes `john-eval.l`, and
for programs (the evidence plan, call by meaning) that run JOHN.

## Motivation

`john-eval.l` runs a whole program at once (`john-run`), reading it twice so that a relation can be used before its
`rel-qualify`, and returns the lines it printed. The memo's JOHN is an interpreter: every example in RN-2008-003 is a
transcript at a `>` prompt, where a definition answers `ok.`, a query its value, and `satisfy` its search. Without
the session, the code's intent is unclear: nothing says which state is the program's knowledge and which is the
world's, when time moves, or what a statement typed after a search sees. This document makes the session the one
way JOHN runs.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **session** — one knowledge base and one working memory, into which statements are entered in order.
- **knowledge base** — what a program declares: classes and groups, enumerations, qualifications, relations, actions,
  rules, goals, optimizations, heuristics, strategies and options (RN-2008-003 §15, "statics").
- **working memory** — the worlds: the current world, and the chain of parents behind it (§15, "dynamics").
- **declaration** — a statement that adds to the knowledge base, or a `make`, which adds an object and its facts
  (its initial property values) to the current world.
- **step** — an action run in a child of the current world, which becomes the current world one time unit on.
- **echo** — what a session answers at the prompt beyond what a statement prints: `ok.` and a step's mutations.

## Specification

This document defines the session, the order in which statements change it, what it answers, and the REPL. It does
NOT define JOHN's grammar (`john.g`), what an expression means, or how a goal is searched (`john-eval.l`, the
`john_run` and `sat_john` checks).

**Time moves only by steps.** No declaration advances time. A session starts at world 0, and everything declared
before the first step is in the knowledge base or in world 0, where `at time 0` reads it.

### Data model

```
RECORD Session:
    knowledge   : KnowledgeBase     -- every declaration so far, in order
    world       : World             -- the current world
    echo        : Boolean = false   -- true at the prompt

RECORD World:
    time        : Integer           -- 0 for a session's first world, parent's + 1 after
    parent      : World | None
    action      : Step | None       -- the step that made it (causingAction, §4)
    writes      : List(Write)       -- the property values set in it; the rest are its parent's
```

### Behavior

`john-begin` MUST start a session with an empty knowledge base and a world at time 0, and `(john-enter form)` MUST
enter one statement, answering the lines it printed. `john-run` MUST be `john-begin` followed by `john-enter` for each
of a program's statements, answering every line, so a file and a prompt run the same code. [R-session-enter]

```maru-check @R-session-enter
john_session
john_run
```

A declaration MUST NOT advance time, and only `do` and a satisfied goal MAY. A `make` writes its facts into the current
world: in world 0 before the first step, and into the world a step reached after it (RN-2008-003 §7 makes `L2` after
`L1` is sorted). `time` alone, as a statement, MUST answer the current world's time. [R-time-by-steps]

```maru-check @R-time-by-steps
john_session
```

With echo on, a declaration MUST answer `ok.`, and every step that moves the current world MUST answer its mutations:
a line `time T: STEP`, then one line per write in that world, `  OBJECT PROPERTY = VALUE`, in the order written. A
satisfied goal answers them for every step of its plan, after `satisfied by: [ ... ]`. Only what the step changed is
shown, as a world holds only its own writes. The memo's transcripts don't show this layout; it is ours. [R-echo]

```maru-check @R-echo
john_session
```

A statement that fails MUST answer the error, naming it, and leave the session as it was before the statement: the
REPL runs each statement in `recover.l`'s `try`, so a failed statement's writes are undone. [R-failed-statement]

```maru-check @R-failed-statement
john_session
```

`./eval john-repl.l [FILE...]` MUST enter each FILE's statements, echo off, then read statements from standard
input, echo on, until it ends. A statement ends at the end of a line whose last character, blanks aside, is `.` or
`?`; until then lines accumulate. The prompt `> ` is printed only when standard input is a terminal, so a transcript
piped in answers just its output. A relation a statement declares stays declared for the statements after it; a
statement read at the prompt is read once, so a relation MUST be declared before it is used there. A file is read
twice, as now. [R-repl]

```maru-check @R-repl
john_session
```

The memo's transcripts are the acceptance tests: `check/john/*.session` holds statements on lines that start with
`> ` and, after each, what it answers. RN-2008-003 §13's circular `opponent` is replayed as printed, and §14's grid of
nine blocks with one departure: the memo's `top-neighbor` reads `which row = its row - 1` yet answers `B3` for `B2`,
which `row + 1` gives, so the transcript has `row + 1`. A counter of ours shows the echo, time and `at time`, and
another the errors. The memo's maze (§4) and sort (§7) need bodies the memo elides (G16) and are later work.

### Errors

| Error | Example | Recovery |
|---|---|---|
| a JOHN error | `> Robot fly.` with no action `fly` | Answer the error; the session is as it was before the statement |
| an unfinished statement | input ends after `> make Player White` | Answer `unfinished statement` and end |

## Formal Grammar

```abnf
session-file = *( input-line *output-line )
input-line   = "> " 1*%x20-7E LF
output-line  = %x21-3D / %x3F-7E *%x20-7E LF
```

An output line is any line that doesn't start with `>`.

## Out of Scope

- **Forgetting worlds.** A session keeps every world the current one descends from, as `at time` reads them. Dropping
  worlds nothing can reach any more, and keeping the evidence plan's ledger to one observation per law and tree, are
  a later draft's.
- **Several sessions at once.** The session's state is the evaluator's globals; one process runs one session.
  `john-begin` is the extension point.
- **A terminal's line editing.** The REPL reads characters; history and editing are the terminal's.

## Alternatives Considered

**Why not keep `john-run` and put a REPL beside it?** Two ways to run a program would drift: the REPL is where
the memo's model is, and a file is just statements typed ahead.

**Why not echo in batch runs too?** Every check reads `john-run`'s lines; `ok.` after each declaration and the
mutations after each step would bury what they assert. At the prompt they are what a person needs.

**Why not refuse a `make` after time has advanced?** The memo makes `L2` after `L1` is sorted (§7).

## Security Considerations

A session runs what it is given: `load "file.l"` loads Maru code, as before, and a statement at the prompt can do
anything a file can. The REPL reads only standard input and the files named on its command line.

## References

- Samimi, H., "JOHN – A Knowledge Representation Language", VPRI RN-2008-003, `~/pkm/raw/vpri/rn2008003_john.txt`.
- `~/pkm/wiki/synthesis/john-language-reconstruction.md` (G-numbered decisions).
- `doc/rfc/draft-ndn-maru-laws-and-rules-00.md` (the evidence plan reads JOHN through a session).
