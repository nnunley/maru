# The check runner

`check/check.l` and `check/parallel.l`: selecting cases, running them in parallel, and their scratch directories.

## The results file

When a run ends, `check/parallel.l` writes `results` in its directory (`/tmp/maru-check/<checkout>/`, or
`MARU_CHECK_TMP`) for the evidence plans to record (`doc/rfc/draft-ndn-maru-john-development-00.md`):

    tree db9d02c2136c
    complete no
    unmatched passed
    lines failed

`tree` is what `notes/plan/tree-hash` printed before the first case started; `complete` is `yes` only when no case was
named (neither `CHECKS=` nor `--quick`); then one line per case, in the order they finished. The tree is taken again
after the last case, and if the code changed in between no file is written, and the run says so on standard error: a
result is evidence about the code it ran against. The file is written whole and renamed into place, so a run stopped
early leaves none. `check/results.l` writes and reads it.

## Checks

- `check_results` (`check/results-test.l`): the file's lines for a run on one tree, read back; `complete` for a
  complete run; no file when the trees differ; a file without its `complete` line refused; and a run of
  `check/parallel.l` (in a directory inside the case's own) writes one naming the tree `tree-hash` gives.

Not yet described here (each has a comment above it in `check/check.l`): `check_tmp`, `unmatched`.
