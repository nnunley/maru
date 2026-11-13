# draft-ndn-maru-check-selection-00: Running Only the Checks a Change Touches

**Status:** DRAFT
**Corpus:** red (spec-first: the checks named below are the acceptance criteria)
**Category:** Standards-Track
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies how `make check` runs only the cases a change could affect. While a case runs, every file Maru
reads is recorded, and a case is run again only when one of those files has changed, its own definition has, or its
last run can't vouch for it. `make check-all` runs every case and is required before a merge. It is written for whoever
changes `check/check.l`, `check/parallel.l`, the boot files or the Makefile, and for agents running the suite.

## Motivation

`make check` runs all 120 cases of `check/check.l`, four at a time. At the time of writing (November 2026) a full run
takes many minutes of wall time, `erosion` alone about 96 s of CPU, and most edits touch one unit: a change to
`john-eval.l` reruns the PNG decoder's fixtures, the assemblers' tables and Nile's schedules, none of which read it.
`make check-quick` leaves out the slowest cases by name, so it skips cases a change does touch and runs cases it
doesn't. The evidence plans (`draft-ndn-maru-john-development-00`) see the same waste from the other side: any edit
makes every answer stale, though most answers are about code the edit left alone.

This document gives each case a record of the files it read, runs a case only when that record says it could have
changed, and keeps a full run, which also checks the records, as the gate before a merge.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **case** — one `(check "NAME" …)` form of `check/check.l`, run by `check/parallel.l`.
- **input** — a file in the checkout (the repository or its submodules `nile/` and `gezira/`) that a case's run read
  and did not write first.
- **inputs log** — the file `MARU_INPUTS` names, to which every evaluator a case's run starts appends the paths it reads.
- **partial** — said of a case's run that did something the inputs log can't see: it started a program that isn't an
  evaluator, or bound a native function that opens files.
- **record** — what the runner keeps about a case's last run: its outcome, whether it was partial, its inputs with
  their git blob hashes, the digest of its definition and the `MARU_*` settings it ran under.
- **carried** — said of a case the run skipped: its outcome is its record's, and nothing it read has changed.
- **selected run** — `make check` (and `make check-quick`): cases are run or carried by the rule below.
- **full run** — `make check-all`: every case runs.

## Specification

This document defines how a case's inputs are logged, what makes a run partial, the records and where they live, when
a case runs and when it is carried, what a full run checks, and what the results file says about carried cases. It does
NOT define what a case asserts (owned by each unit's doc), how the results become evidence (owned by
`draft-ndn-maru-john-development-00`, which this document extends for carried outcomes), or anything outside the
checkout: the toolchain, system headers and the network are not inputs.

**Sound before cheap.** A case is carried only when its record shows nothing it could have read has changed. Whatever
the log can't see makes the run partial, and a partial case always runs: a skipped case that would have failed is a
failure nobody sees.

**Maru logs, not the operating system.** Inputs are what Maru's own readers report, so selection works the same on
every host and on bare metal, with no tracing tools and no privileges.

### Data model

```
RECORD CaseRecord:
    name        : String                  -- the case's name in check/check.l
    outcome     : passed | failed          -- its last run's
    partial     : yes | no
    definition  : String                  -- digest of its (check ...) form and check.l's shared forms
    settings    : List of (String String)  -- every MARU_* variable and its value, sorted
    inputs      : List of (String String)  -- (path blob-hash), path relative to the checkout, sorted

ENUM Disposition:
    RAN         -- the case ran in this run
    CARRIED     -- the case was skipped; its outcome is its record's
```

**Field constraints:** a blob hash is what `git hash-object` gives for the file's content. A path names a file in the
checkout; a file the run wrote before reading it, and any file outside the checkout, is never an input.

### Configuration

| Key | Type | Default | Description |
|---|---|---|---|
| `MARU_CHECK_ALL` | flag | unset | set by `make check-all`: every case runs, every record is rewritten |
| `MARU_INPUTS` | path | unset | set by the runner for each case; unset, nothing is logged |
| records file | path | `/tmp/maru-check/<checkout>/inputs` | beside `times` and `results`; `MARU_CHECK_TMP` moves the directory |

The records live with the checkout's other run files, not in the repository: they describe this checkout's last runs,
and a fresh checkout, with none, runs everything.

**Resolution precedence** for whether a case runs (highest first):

1. The case is named (`CHECKS=` or `make check CHECKS=…`): it runs.
2. `MARU_CHECK_ALL` is set: it runs.
3. The selection rule below.

### Logging inputs

Every evaluator (`eval`, `eval2`, `eval3`) MUST, when `MARU_INPUTS` names a file, append to it the path of every file
it opens for reading through `read`, `open`, `load`, `require`, and a function bound with `subr` to `fopen`, one path a
line, as given and made absolute. An evaluator started by a case's run inherits the variable, so a case's log holds
what every evaluator in its run read. [R-inputs-logged]
The logging belongs in the boot files (`boot.l`, `boot2.l`) and Maru, not in C: it wraps the readers Maru already has.

```maru-check @R-inputs-logged
check_select
```

The runner MUST turn a case's log into its inputs: paths inside the checkout, less those the run wrote first. A file
that is built (marked `derived`, or a target of the Makefile, the evaluators among them) MUST count as the sources make
builds it from, transitively, each by its blob hash. Every case MUST also count its definition: the digest of its own
`(check …)` form together with every form of `check/check.l` that isn't a case, so editing one case reruns that case
and editing what the cases share reruns them all. [R-inputs-scope]
A grammar compiled to `john.g.l` is read as `john.g.l`; without the mapping a change to `john.g` would be invisible
until someone rebuilt.

```maru-check @R-inputs-scope
check_select
```

### Partial runs

A case's run MUST be recorded partial when, during it, the runner's `run` or `run-status` or Maru's `system` starts a
command whose program isn't one of the evaluators, or code binds a native function that opens files (`fopen`,
`freopen`, `open`, `openat`, `opendir`) other than through the logged readers, as native code compiled in process does
when it resolves such an extern. A run whose inputs log is missing or unreadable is partial. One command is known: `make -q
TARGET…`, which only asks whether its targets are current, MUST NOT make a run partial, and each target counts as an
input, by the sources make builds it from. [R-partial]
Such a run can read files nobody logs: cc reads the C it is given, git reads the index, a compiled program opens its
fixtures. `lines`, `erosion` and every case that builds with make or cc stay partial, and so always run; the cases that only
assert their libraries are built (`make -q build/…`, at the time of writing four calls in `check/check.l`) don't.

```maru-check @R-partial
check_select
```

### Selecting

In a selected run the runner MUST run a case, rather than carry it, when any of these holds:

1. it has no record;
2. its record's outcome is `failed`, or its record is partial;
3. its definition's digest differs from the record's;
4. its `MARU_*` settings differ from the record's;
5. one of its recorded inputs is missing, or its blob hash differs from the record's.

Otherwise it MUST carry the case: not run it, and report it with its recorded outcome. [R-select]
A failed case always runs so that a fix is seen; a partial one because its record can't vouch for it; settings because a
seed or a job count can change what a case does (`make check-sweep` sets fresh seeds, so it runs everything).

```maru-check @R-select
check_select
```

After a case runs, the runner MUST replace its record with the run's, partial or not; a carried case's record MUST be
left as it was. The records MUST be written as Maru forms, one a case, read back by `read`, written whole and renamed
into place. A records file that is missing or unreadable MUST be treated as empty. [R-records]

```maru-check @R-records
check_select
```

### Reporting carried cases

The runner MUST print every case, run or carried, and say which were carried and how many. The results file
(`check/results.l`) MUST give each case its disposition: a line `NAME OUTCOME` for a case that ran and
`NAME OUTCOME carried` for one carried. `complete` MUST be `yes` when no case was named and every case ran or was
carried. [R-carried]
A carried `passed` is a pass about the tree the run started on, since nothing the case read differs from when it last
passed: the evidence plans record it as an answer for that tree, so an edit doesn't make answers stale for checks it
couldn't reach.

```maru-check @R-carried
check_results
check_select
```

### The full run

`make check-all` MUST run every case and rewrite every record. Before running each case it MUST work out whether a
selected run would have carried it, and if it would have, and the case's outcome now differs from its record's, the full
run MUST fail naming the case: `check_select: NAME went from passed to failed though nothing it read changed`.
[R-check-all]
That is the check on the logging itself: a case carried wrongly is an input nobody logged, or a case that doesn't give
the same answer twice, and either is a finding.

```maru-check @R-check-all
check_select
```

A merge MUST be preceded by a full run that passes, on the commit being merged; AGENTS.md's Verify section and the
merge steps MUST say so. [R-merge-gate]

```maru-check @R-merge-gate
check_select
```

### Errors

| Error | Example | Recovery |
|---|---|---|
| records unreadable | the file was cut short by a crash | treat as empty: every case runs, records rewritten |
| inputs log missing | a case's evaluator died before writing | the run is partial; the case runs next time |
| blob hash unavailable | `git hash-object` fails | every case runs, as if no records |
| a carried case changed in a full run | an unlogged input, or a case that isn't deterministic | the full run fails naming the case |

## Formal Grammar

The records file, as Maru's reader reads it:

```abnf
records      = *( record LF )
record       = "(case " name SP outcome SP partial SP definition SP settings SP inputs ")"
outcome      = "(outcome " ( %s"passed" / %s"failed" ) ")"
partial      = "(partial " ( %s"yes" / %s"no" ) ")"
definition   = "(definition " string ")"
settings     = "(settings" *( SP "(" string SP string ")" ) ")"
inputs       = "(inputs" *( SP "(" string SP string ")" ) ")"
name         = 1*( ALPHA / DIGIT / "_" )
string       = DQUOTE *( %x20-21 / %x23-5B / %x5D-7E / "\" ( DQUOTE / "\" ) ) DQUOTE
```

## Out of Scope

**Files outside the checkout.** System headers, the C compiler, libffi and SDL change rarely and aren't the code under
test. Extension point: a `toolchain` input naming their versions, added to the definition's digest.

**The network.** A case that fetches (the dbjr documents) does so through `system`, so it is partial and always runs.
Extension point: a fetch through a logged reader, keyed by URL and the fetched content's hash.

**Sharing records between checkouts or machines.** Records describe one checkout's runs. Extension point: the records
file's path, which `MARU_CHECK_TMP` already moves.

**Precise inputs for partial runs.** cc's and git's reads could be learned from their own dependency output
(`cc -MD`). Extension point: [R-partial], whose list of what makes a run partial would shrink.

## Alternatives Considered

**Why not trace the operating system (strace, DTrace, fs_usage)?** It sees every read, but it needs root and an
exception from macOS's system integrity protection, works differently on each host, and depends on tools a bare-metal
Maru won't have.

**Why not declare each case's inputs in `check/check.l`?** The lists would drift from what the cases read, and a
missing entry is exactly the silent skip this document exists to prevent.

**Why not map changed paths to units through `doc/` and AGENTS.md?** Units share files (`boot.l`, the evaluators,
`john-eval.l`), so the map is coarse where it's right and wrong where it's fine.

**Why not make selection a new target and leave `make check` full?** The everyday run is the one worth cutting; a full
run stays one word away, and the merge gate keeps it from being skipped where it matters.

**Why not count a case's definition as all of `check/check.l`?** Every case is defined there, so any edit to any case
would rerun all of them.

## Security Considerations

An evaluator appends to whatever file `MARU_INPUTS` names; the variable comes from the runner or the user, who could
already write that file. The records decide which cases run: someone able to write
`/tmp/maru-check/<checkout>/inputs` can make a selected run skip a case. That directory is the user's own, and the full
run before a merge ignores the records' say over what runs, so a planted record is caught there as a case whose outcome
changed.

## Compatibility

`make check` stops running every case: scripts that read its output for a case that is now carried see it reported as
carried, with its recorded outcome. `make check-quick` keeps leaving out the slowest cases and selects among the rest.
`make check CHECKS=…` runs what it names, as before. The first run in a checkout, and the first after this lands, runs
everything. The results file gains a third word on carried cases' lines; `check/results.l` reads both forms.

## References

- `draft-ndn-maru-john-development-00` — the results file and how the plans record it; this document adds carried
  outcomes to what they record.
- `doc/checks.md` — the runner, its scratch directories, `times` and `results`.
- RFC 5234 — ABNF.
- Bazel's action cache and Gradle's up-to-date checks (https://bazel.build/, https://gradle.org/): skip work whose
  recorded inputs are unchanged; both declare inputs, where this document observes them.
- Gligoric, Eloussi, Marinov, "Practical Regression Test Selection with Dynamic File Dependencies", ISSTA 2015
  (Ekstazi): selects tests by the files each read on its last run, the approach taken here.
