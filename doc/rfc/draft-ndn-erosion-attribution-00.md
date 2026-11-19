# draft-ndn-erosion-attribution-00: Erosion and Verbosity Attributed to the Changes That Moved Them

**Status:** DRAFT
**Corpus:** red (spec-first: the evidence is the acceptance criteria)
**Category:** Experimental
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies a report that says how a change moved Maru's erosion and verbosity, callable by callable. It
reads the change as a diff (git's unified format, which `jj diff --git` also writes, and jj's conflict markers for a
change with several sides), measures only the files the change touched, before and after, and separates what the
change's edits did from what the shift in the tree's total did. It is written for the model developing Maru and for
whoever reviews its work: the report is advisory, and a gate built on it comes later.

## Motivation

The erosion check (`check/erosion`, `doc/measures.md`) measures the whole tree and holds each metric to a ledger whose
entries say why it moved. That follows SlopCodeBench (Orlanski et al., NeurIPS 2026), which scores whole snapshots at
each checkpoint and compares them; it attributes nothing to a change. Its only diff statistic, relative lines changed
(section 3.1), is no part of either metric.

The tree is developed mostly by a model, and erosion is to go down as it develops. A whole-tree number says that a
commit moved erosion, not which of its edits did. Writing a ledger entry today means finding the cause by hand: on
2026-11-18 a review fix moved erosion from 373 to 400 and the cause was found only by measuring the Maru files and
the grammars apart, about three minutes of CPU for one entry. A move the model can't trace to its own edit at the
moment it makes it is a move it can't steer.

This document provides a report that names the callables a change moved and by how much, and separates that from the
part of the move no edit made.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **base** — the revision a change is measured against: a git commit or a jj revision.
- **change** — the difference between the base and the working copy (or a named revision), as a diff.
- **measured file** — a `.l`, `.k` or `.g` file the erosion check measures (`doc/measures.md`'s set, less its unread
  files).
- **callable** — a definition the erosion check scores: a Maru definition, or a grammar rule (`tpeg-forms.g`).
- **edited callable** — a callable whose lines a hunk of the change overlaps, on the side it belongs to, or one the
  change adds or removes.
- **edited move** — the part of a metric's move that the edited callables' own numbers account for.
- **share move** — the rest of a metric's move: what changing the tree's total, and clones gained or lost by callables
  the change did not edit, account for.
- **side** — one version of a conflicted file in a jj change with several parents.

## Specification

This document defines the reading of a change (a unified diff, and jj's conflict markers), which callables it edited,
the attribution of each metric's move to edits and to share, and the report. It does NOT define the metrics, which
`doc/measures.md` and `erosion.l` own, nor the ledger's format (`erosion-ledger.g`), nor any gate: a gate that fails a
change is a later document's.

**Measure what changed, once.** Only measured files the change touches are measured at the base; the rest of the tree
counts the same on both sides, so the report never measures the whole tree twice.

**Attribution adds up.** For each metric, the edited move and the share move sum to the whole move. A report whose
parts don't sum is wrong, not approximate.

**Advisory.** The report changes no file and fails nothing. It drafts ledger entries; it never writes them.

### Data model

```
RECORD Hunk:
    old_start   : Integer          -- first line on the base side
    old_count   : Integer = 1      -- lines on the base side; 0 for a pure addition
    new_start   : Integer
    new_count   : Integer = 1
    lines       : List of String   -- each with its leading " ", "-" or "+"

ENUM FileStatus:
    MODIFIED
    ADDED        -- "new file mode", or "--- /dev/null"
    DELETED      -- "deleted file mode", or "+++ /dev/null"
    RENAMED      -- "rename from" and "rename to"

RECORD FileDiff:
    old_path    : String | None
    new_path    : String | None
    status      : FileStatus
    hunks       : List of Hunk

ENUM SideKind:
    DIFF         -- "%%%%%%% diff from:" ... "\\\\\\\ to:": a diff from the base to this side
    SNAPSHOT     -- "+++++++": this side's lines as they are
    BASE         -- "-------": the base's lines, in jj's snapshot style

RECORD Side:
    kind        : SideKind
    label       : String           -- the change id, commit id and description jj writes
    lines       : List of String

RECORD Conflict:
    index       : Integer          -- N of "conflict N of M"
    of          : Integer          -- M
    sides       : List of Side

RECORD CallableMove:
    path        : String
    name        : Symbol
    edited      : Boolean
    cc          : (Integer | None, Integer | None)   -- before, after; None where absent
    forms       : (Integer | None, Integer | None)
    flagged     : (Integer, Integer)                  -- forms a verbose pattern or clone covers
```

**Field constraints:** a hunk's count, when its header omits it, is 1. A path is the one after `a/` or `b/`, as git
writes it, relative to the repository's root.

### Configuration

| Key        | Type     | Default                  | Description                                               |
|------------|----------|--------------------------|-----------------------------------------------------------|
| `REV`      | String   | the working copy's parent | the base: `HEAD` for git, `@-` for jj                    |
| `MARU_VCS` | String   | `jj` if `.jj/` exists, else `git` | which tool reads the change and the base's files |

The working copy against its parent is the default because that is the change the model is making: the report is
for the moment of the edit.

**Resolution precedence** (highest first):

1. `make erosion-report REV=…` or `./eval erosion-attribute.l REV`
2. `MARU_VCS`, for the tool
3. The defaults above

### Behavior

**Reading a change.** `diff.g`, a tpeg grammar, reads a unified diff with git's extended headers into `FileDiff`s:
`diff --git a/P b/Q`, then any of `index`, `old mode`/`new mode`, `new file mode`, `deleted file mode`,
`similarity index`, `rename from`, `rename to`, `copy from`, `copy to`, `Binary files … differ`, then `--- `/`+++ `
and hunks. A hunk header MAY omit a count, which is then 1; a line `\ No newline at end of file` belongs to the line
before it and counts on neither side. [R-diff-read]

The same grammar reads `jj diff --git`'s output, which is git's format. [R-jj-git]

**Reading conflicts.** `jj-conflict.g` reads jj's conflict markers (jj 0.45) into `Conflict`s: `<<<<<<< conflict N of
M`, then sides, then `>>>>>>> conflict N of M ends`. A side is a diff side (`%%%%%%% diff from: LABEL` and
`\\\\\\\        to: LABEL`, then `-`, `+` and ` ` lines), a snapshot side (`+++++++ LABEL`, then lines as they are), or
a base (`------- LABEL`). The lines outside every conflict are common to all sides. A file MAY hold several conflicts,
and a conflict MAY have more than two sides. [R-conflict-read]

**What is measured.** For each `FileDiff` whose old or new path is a measured file, the base's version (`git show
REV:P`, or `jj file show -r REV P`) and the current version are each read by `erosion-read-file`'s reader for the
file (`doc/measures.md`) and walked as the erosion check walks them. A file the change adds has no base version; a
file it deletes has no current one. No other file is read at the base. [R-measure-changed]

**Matching.** A base callable and a current callable are the same callable when they have the same name in the same
file, where a renamed file's old path matches its new one. Two callables of one name in one file match in the order
they appear. A callable with no match was added or removed by the change, and is an edited callable. [R-match]

**Edited callables.** A current callable is edited when a hunk's new-side lines, `new_start` through `new_start +
new_count - 1`, overlap its lines; a base callable is edited when a hunk's old-side lines overlap its lines (a pure
deletion, `new_count` 0, overlaps by its `old_start`). A grammar rule, whose tree carries no lines, is edited when a
hunk overlaps the line range its definition spans in the file's text. [R-edited]

**Attribution.** Let a metric be a ratio `part / whole`: erosion is eroded mass over all mass, verbosity flagged forms
over all forms (`doc/measures.md`). The whole move is the metric's current value less its base value, each per mille
as the erosion check computes it; the current value is the tree's, and the base value is the current tree's with each
changed file's current numbers replaced by its base numbers. The edited move is the edited callables' part after less
their part before, over the current whole. The share move is the whole move less the edited move. [R-attribution-sums]

```
FUNCTION attribute(metric, base_files, current_files, tree_now) -> (whole, edited, share):
    -- Step 1: the tree at the base, from the tree now and the changed files only
    tree_base = tree_now - totals(current_files) + totals(base_files)
    whole = per_mille(metric, tree_now) - per_mille(metric, tree_base)
    -- Step 2: what the edited callables' own numbers did, over the current whole
    edited = 1000 * (part(metric, edited_callables(current_files)) - part(metric, edited_callables(base_files)))
             / whole_of(metric, tree_now)
    -- Step 3: the rest is share, by definition, so the parts sum
    share = whole - edited
    RETURN (whole, edited, share)

-- Behavior:
--   - edited + share = whole, exactly, before any rounding for display
--   - a callable the change did not edit, whose flagged forms moved because a clone partner was added or removed
--     elsewhere, moves share, and the report names it
```

**Conflicted files.** A measured file holding conflict markers is measured once per side: each side's version is the
common lines with that side's lines in each conflict, a diff side applied to the base's lines. Each side is attributed
against the base as a change of its own, and the report gives each side's moves under its label. [R-conflict-sides]

**The report.** The report prints, in order: a line per metric giving the base value, the current value, the whole
move, the edited move and the share move; then a line per callable whose numbers moved, edited ones first, each with
its path, name, complexity before and after, forms before and after, whether it crossed complexity 10, and flagged
forms before and after; then, for each metric that moved, a drafted `check/erosion` entry naming the callables that
moved it most. A callable whose numbers did not move is not printed. [R-report]

**Where it runs.** `make erosion-report` and `./eval erosion-attribute.l [REV]` print the report for the change
against `REV`. When the erosion check fails because the tree's metrics don't match the ledger, it prints the report
for the working copy against `HEAD` (git) or `@-` (jj) after its own lines, so the failure names its cause.
[R-check-prints]

The report never writes `check/erosion` or any other file, and its own exit status is 0 whenever it could read the
change. [R-advisory]

Programs (`git`, `jj`) are started with fixed arguments and the base given as one argument, never through a shell
(`doc/plans/2026-11-11-check-without-shell.md`, `spawn.l`). [R-no-shell]

The requirements above are held by the fixtures of one check, which reads fixed diffs and conflicts from
`check/erosion-attribution/` rather than a live repository:

```maru-check @R-diff-read
erosion_attribution
```

```maru-check @R-jj-git
erosion_attribution
```

```maru-check @R-conflict-read
erosion_attribution
```

```maru-check @R-measure-changed
erosion_attribution
```

```maru-check @R-match
erosion_attribution
```

```maru-check @R-edited
erosion_attribution
```

```maru-check @R-attribution-sums
erosion_attribution
```

```maru-check @R-conflict-sides
erosion_attribution
```

```maru-check @R-report
erosion_attribution
```

```maru-check @R-check-prints
erosion
```

```maru-check @R-advisory
erosion_attribution
```

```maru-check @R-no-shell
run_limit
```

### Errors

| Error                | Example                                              | Recovery                                                    |
|----------------------|------------------------------------------------------|-------------------------------------------------------------|
| `E_DIFF_UNREAD`      | the diff stops matching `diff.g` partway             | Say where, as tpeg's whole-file reader does; no report      |
| `E_BASE_MISSING`     | `git show REV:P` fails for a path the diff modifies  | Report the file as unmeasured at the base; go on            |
| `E_FILE_UNREAD`      | a changed file doesn't read (one of the check's unread files) | Report it as unmeasured on that side; go on        |
| `E_NO_VCS`           | neither `.jj/` nor `.git` is found                   | Say so; no report                                           |

A file the check can't read on one side is reported, not guessed: its callables are left out of both sides, so the
parts still sum over what was measured.

## Formal Grammar

```abnf
diff          = *file-diff
file-diff     = git-header *ext-header [old-new] *hunk
git-header    = %s"diff --git a/" path SP %s"b/" path LF
ext-header    = ( %s"index " / %s"old mode " / %s"new mode " / %s"new file mode " / %s"deleted file mode "
                / %s"similarity index " / %s"rename from " / %s"rename to " / %s"copy from " / %s"copy to "
                / %s"Binary files " ) rest LF
old-new       = %s"--- " side-path LF %s"+++ " side-path LF
side-path     = %s"/dev/null" / ( ( %s"a/" / %s"b/" ) path )
hunk          = %s"@@ -" range SP "+" range SP %s"@@" rest LF *hunk-line
range         = number [ "," number ]
hunk-line     = ( SP / "-" / "+" ) rest LF / %s"\ No newline at end of file" LF
conflicts     = *( common-line / conflict )
conflict      = %s"<<<<<<< conflict " number %s" of " number LF 1*side %s">>>>>>> conflict " number %s" of " number %s" ends" LF
side          = diff-side / snapshot-side / base-side
diff-side     = %s"%%%%%%% diff from: " rest LF %s"\\\\\\\        to: " rest LF *hunk-line
snapshot-side = %s"+++++++ " rest LF *common-line
base-side     = %s"------- " rest LF *common-line
common-line   = rest LF
path          = 1*( %x21-7E )
number        = 1*DIGIT
rest          = *( %x20-7E / %x80-FF )
```

The grammar fixes what the readers accept; `diff.g` and `jj-conflict.g` are tpeg grammars for the same language, and
a line that ends no rule above (a conflict marker of another jj version) is `E_DIFF_UNREAD`.

## Out of Scope

**A gate.** Failing the erosion check when a change raises erosion in callables it edited without a ledger entry naming
them. Excluded because the report comes first, at the user's choice (2026-11-19). Extension point: `[R-check-prints]`'s
failure path, which already has the report in hand.

**History.** Walking commits or a jj stack and scoring each, to find where erosion came from. Excluded as after-the-fact.
Extension point: `attribute` over each revision and its parent; `[R-conflict-sides]` already attributes a merge by side.

**Other diff formats.** `jj diff`'s default color-words output and context diffs (`diff -c`). Extension point: a grammar
beside `diff.g` that reads into the same `FileDiff`s.

## Alternatives Considered

**Why not measure the whole tree at the base and at the working copy, and diff the two?** It needs no hunks, but costs
two full erosion runs (about 80 CPU seconds each at the time of writing) per report, and it can't tell a callable the
change edited from one whose numbers moved only because the tree's total did, which is the distinction the report is for.

**Why not attribute by file, from `git diff --name-only`?** Simplest, but it can't name callables inside a file, and the
model needs the callable to steer.

**Why not attribute verbosity by lines, as the paper counts it?** The erosion check counts forms, not lines
(`doc/measures.md`), and attribution follows the check's own unit.

## Security Considerations

The report reads the repository and runs `git` or `jj` with fixed arguments. The base comes from the person running it
and is passed as a single argument to the tool, never through a shell, so a revision name can't run a command. The diff
and the base's files are read as text by grammars; a file that doesn't read is reported, not executed. Measuring a
tpeg-repl script runs it (`doc/measures.md`), at the base too: a base revision's script is run as the erosion check runs
the current one, so measuring an untrusted revision runs its scripts. The report is for the repository's own history.

## Compatibility

Nothing existing changes, except that a failing erosion check prints more. At the time of writing (November 2026), jj's
conflict markers are those of jj 0.45.1; jj's documented marker styles ("diff" and "snapshot") are both read. A later
jj that changes its markers is `E_DIFF_UNREAD` until `jj-conflict.g` follows it.

## References

- BCP 14 (RFC 2119, RFC 8174).
- RFC 5234 (ABNF) and RFC 7405 (case-sensitive strings).
- POSIX.1-2017, `diff -u`: https://pubs.opengroup.org/onlinepubs/9699919799/utilities/diff.html
- git's diff format: https://git-scm.com/docs/diff-format and https://git-scm.com/docs/git-diff (extended headers)
- jj's conflict markers: https://jj-vcs.github.io/jj/latest/conflicts/
- Orlanski et al., SlopCodeBench (NeurIPS 2026, arXiv 2603.24755): erosion and verbosity, scored on snapshots.
- `doc/measures.md`, `erosion.l`, `tpeg-forms.g`, `spawn.l` in this repository.
