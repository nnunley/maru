# The check runner

`check/check.l` and `check/parallel.l`: selecting cases, running them in parallel, and their scratch directories.

The runner and the checks start every program directly, never through a shell (`doc/plans/2026-11-11-check-without-shell.md`).
`spawn.l`'s `<command>` names a program and its arguments (`argv`, each one string, never split or expanded), its
input (`in`, else `/dev/null`), where its output and errors go (`out`, `err`), what it changes in the environment (`env`,
a name with no value taken out), its directory (`dir`) and its wall and CPU limits; the child sets them with `open`,
`dup2`, `setenv`, `chdir`, `alarm` and `setrlimit`, then `execvp`s. `check.l`'s `run`, `run-status`, `run-cpu-status`,
`fails-saying` and `quiet-run` (no output on standard error, as a driver that leaked no block) take a `<command>` or an
argument list. What the shell did is Maru now: a redirection is a command's `out`, a glob `files-ending`, `cd` a
command's `dir`, `printf`, `cat` and `grep -v` into a file Maru writing it, and the `lines` and erosion checks' file lists
`counted-files` (`git ls-files` in each of `.`, `nile` and `gezira`, `git check-attr --stdin` given the names as a file).
`spawn.l` also has what code that only needs a little uses: `program-status` and `program-output` (a program's status, and
what it wrote), `exists?` (`access`, no program), `make-directory`, `remove-tree`, `darwin?` (which names a shared library
`.dylib`) and `find-program` (the first runnable file, not a directory, of that name on `PATH`). `erosion.l`, `sat.l`,
`png.l`, `gezira-maru.l`, `ksworld-pp.l` (its `curl`), `notes/plan/plan-world.l` and the check programs use them in place of
`system`. `spawn.l` reads `osdefs.k` (the `open` flags, the pointer size), so what loads it needs `make` to have measured
this machine first, as `make check` does. A program that can't be started says so on its standard error and exits 127.
`notes/plan/probes.l`, which only `notes/plan/observe.l` loads and no check runs, still starts its probes through a shell:
its commands are the plan's own data (a probe's `command` property), so it changes with the plan's format. `check/jobs.l` runs `(name . command)` entries, and `parallel.l`, `sweep.l` and `temp.l` start `rm` and `mkdir` as
programs. A program that is itself a script (Nile's `nile-to-maru-compiler.sh`, `colima ssh … sh -c` in the VM) is
still a program, started directly.

## Checks

Not yet described here (each has a comment above it in `check/check.l`): `check_tmp`, `unmatched`.
