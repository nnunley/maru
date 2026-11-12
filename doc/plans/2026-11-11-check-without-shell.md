# The check runner without a shell

The user, 2026-11-11: hashbang-style tests rather than shell scripts, "so we don't have to worry about using shell for
them"; both parts chosen (grammar checks as scripts, PR #32; this, the runner).

## Goal

`check/check.l`, `check/parallel.l`, `check/jobs.l` and `check/temp.l` start programs directly: `fork`, the child's
input and output set with `open` and `dup2` (flags from `osdefs.k`, as `check/native-child.l` does), its environment
with `setenv`, its directory with `chdir`, then `execvp` of an argument list. No `/bin/sh -c`, no command strings
parsed by a shell. Programs that are themselves scripts (`nile-to-maru-compiler.sh`, `colima ssh ...`) are still
programs, started directly.

## Design

- `spawn.l`: a `<command>` (made with keyword `make`): `argv`, `in`, `out`, `err` (paths; `err` the same as `out`
  for both in one file; no `in` is `/dev/null`), `env` (an alist added to the environment), `dir`, `wall` and `cpu`
  limits in seconds. `(command-start c)` answers the child's pid; `(command-status c)` starts it and answers the status
  `waitpid` gives. An argument is one string, never split or expanded.
- `check.l`'s `run`, `run-status`, `run-cpu-status` and `fails-saying` take an argument list. Pipelines, `cd ... &&`,
  `>` and the `for` loop become Maru: a program's output read from its file and filtered in Maru, `git check-attr
  --stdin` given its input as a file, a directory set by `dir`.
- `jobs.l` runs entries `(name . command)`, a `<command>` each; `parallel.l` passes `MARU_CHECK_TMP` and drops `MARU_LAW_SEED` and
  `MARU_LAW_TRIALS` through `env`. `temp.l` makes its directory with `mkdir`'s argument list (no shell).
- The `run_limit` unit's cases (exit status, the wall limit) move to the new primitive, with new ones: an argument
  holding `;`, `|`, `$` or a space reaches the program unchanged; `env` reaches the child; `dir` sets its directory;
  `out` and `err` together keep both.

The user, later the same day: all of it in this branch, the checks and the libraries they load too (`erosion.l`,
`sat.l`, `png.l`, `gezira-maru.l`, `ksworld-pp.l` and twelve check programs), so `spawn.l` moved to the root.

## Order

1. `spawn.l` and its cases (TDD), in `run_limit`.
2. `run` and friends on argument lists; every call converted; the pipelines rewritten in Maru.
3. `jobs.l`, `parallel.l`, `temp.l`.
4. Docs (`doc/checks.md`), ledgers, full suite, review, PR stacked on #32.
