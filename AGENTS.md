# Maru

## What this is

Dan Amelang's Maru as of 2012-12-24 (`ac07e5e`), as used for Nile, on top of
Ian Piumarta's 2.4 release, with Kurt Stephens' fork merged in. Kurt's merge
adds only `maruby.l`; his other changes are in the history, not the code.
`ac07e5e` is Piumarta's own commit `e8356c4` (less `.hg_archival.txt`); his
history behind it (from 2010-10-30) and his 2013 commits after it (to
2013-11-12: label and goto, keyword `make`, `eval3`, the SDL2 example) are
merged in, from attila-lendvai/maru's `piumarta` branch. A replace ref grafts
`e8356c4` under `ac07e5e` for log and blame; fetch it with
`git fetch origin 'refs/replace/*:refs/replace/*'`.

The layout is flat, as upstream intended: `require` and `load` resolve
relative to the current directory, so run everything from the repo root.

## The goal, and its core reference

The end goal is to synthesize the rest of VPRI's work into something that runs on modern
machines. [tinlizzie.org](https://tinlizzie.org/), the archived VPRI site, is a core reference
for that: the papers (`/VPRIPapers/`) and the top-down system's own dump (`/dbjr/`, including
the KSWorld `.pp` bundles). Keep third-party texts in `~/pkm`, not in this tree, with one exception: `ksworld/` is
KSWorld's own source, every KS class as Frank's image last had it (`ksworld/README.md` says where it comes from), kept
here as the reference for the KSWorld work. Its `.st` files aren't counted in `lines`.

## Other history (tags)

`refactor-main` (the 2025 reorganization, with unfinished ARM64 experiments
in `core/compiler/ir-gen-arm64*.k`), `amelang-nile` (Dan's repo for Nile),
`linear-main`, `kurt/*`, and releases `v1.0-original`, `maru-1.0`,
`maru-2.1` … `maru-2.4`, `maru-last-vpri`, `v2.5-vpri-complete`.

## Build

    make    # eval, eval2, eval3, osdefs.k, and eval32 where -m32 links (not macOS)

`eval3` (Piumarta, 2013) is the third iteration of the bootstrap and `eval2`'s successor: it boots
`boot2.l` too. Piumarta's `eval2` had `subr` commented out, and `eval3` restored it through libffi;
both now share one `subr`.

On arm64 macOS with Rosetta, `make check` also builds `bin/x86_64/eval` and
`bin/x86_64/eval2` (`-arch x86_64`) to run x86-64 code in-process.

`nile/` and `gezira/` are submodules (forks on `nnunley`); clone with
`--recurse-submodules` or run `git submodule update --init`.

`osdefs.k` describes this machine. `compile-osdefs.l` (run by `eval`, which
doesn't need it) turns `system.osdefs` into a C program, `system.osdefs.c`,
that the host compiler builds and runs to measure it. Any other `X.osdefs`
builds the same way; the `.c` and the program are temporary.
ir2 takes the size of each C type (`char` … `long`, pointers) and every
alignment from `osdefs.k`; fixed-width types (`int8` … `int64`) have their
sizes by definition.

## Verify

    make check

`make check` runs the cases four at a time (`check/parallel.l`, `MARU_CHECK_JOBS` to change it), and says which were slowest, in CPU time; `times` in its directory has each case's wall and CPU time in milliseconds, peak memory (bytes on macOS, kilobytes on Linux), disk blocks, minor and major faults, and switches;
`make check-quick` leaves out the slowest, for everyday edits. Everything runs before a merge. `make check-sweep` looks for new
corner cases: the generated laws on fresh seeds, more trials and every evaluator; a failure names its seed, and `MARU_LAW_SEED`
reruns it. A checkout writes under `/tmp/maru-check/` in a directory of its own, so two can run at once.

`check/check.l` (untyped Maru, built on boot.l's `unit-test`) runs each demo and
asserts what it computes; `make check CHECKS="NAME…"` runs selected cases, after
building what is stale. Libraries and grammars that checks open are built by make into
`build/` (`CHECK_LIBS`, failures ignored so the other checks still run), and a check asserts
`make -q` on what it opens; `make clean` removes `build/`. Run cases through make, not
`./eval check/check.l` directly: no case names the derived files it needs (`law.g.l`, `cexpr.g.l` …), so a
direct run in a fresh or stale tree fails on a missing or old grammar.
Typed checks are ir2 programs in `check/` (`ir2.k`, `gc.k`), as upstream's
`maru-check.k` is.

Any change in the source line count needs an entry in `check/lines`, and any change in erosion or verbosity one in
`check/erosion`; see [doc/measures.md](doc/measures.md).

## Documentation

Each functional unit keeps its documentation in `doc/<unit>.md`: what it does, its checks and what each asserts,
where it departs from VPRI's original, and its limits. This file holds only a line per unit, linking to it.

- A new check, or a change in what one asserts, goes in its unit's doc, in the same change as the code.
- A new unit gets its own doc and a line in the list below, with the checks it covers.
- Keep the line here to what the unit is for; the detail belongs in the doc.
- Specifications go in `doc/rfc/` and plans in `doc/plans/`; a unit's doc links to them.

## Functional units

- [The check runner](doc/checks.md): `check/check.l` and `check/parallel.l`: selecting cases, running them in parallel, and their scratch directories. Checks: `check_tmp`, `unmatched`.
- [Evaluators and boot files](doc/evaluators.md): The three evaluators (`eval`, `eval2`, `eval3`), what they share through `boot.l` and `boot2.l`, and their primitives. Checks: `eval3`, `eval2_subr`, `data_length`, `byte_bounds`, `boot_forms`, `equal_selector`, `boot2_strings`, `cross_eval`, `run_limit`.
- [Garbage collector](doc/gc.md): The collector in C and the one written in Maru, held to laws over generated graphs and programs. Checks: `maru_gc`, `maru_gc_coalesce`, `gc_laws`, `gc_model`, `gc_image`.
- [Hash tables](doc/hash.md): `hash.l`'s tables by identity or `equal`, and weak-key tables over the collector's ephemerons. Checks: `hash_table`, `weak_table`.
- [Errors, worlds and unwinding](doc/recover.md): `catch.l`'s native catch and throw, and `recover.l`'s conditions and undo-log worlds. Checks: `catch`, `recover`, `undo_irl`.
- [Grammars and parsing](doc/grammars.md): PEG and tpeg grammars, left recursion, composition, typed tree matching and grammar reflection. Checks: `recursion`, `peg_compose`, `pegen`, `earley`, `text_parser`, `cexpr_forms`, `tree_selectors`, `tree_source`, `tree_lists`, `tree_args`, `tree_args_unread`, `tree_apply`, `tree_memo`, `tree_foreign`, `tree_literals`, `tree_calc`, `tree_interleave`, `tree_text_refuses`, `tree_parse_complete`, `grammar_reflect`.
- [Small languages](doc/languages.md): The Smalltalk-like pepsi, a language built at the REPL, and the start of Ruby. Checks: `pepsi`, `repl`, `maruby`.
- [Typed Maru (ir2) and the C back end](doc/ir2.md): `maru.k`'s typed language, its sizes from `osdefs.k`, and `ir-gen-c.k`. Checks: `osdefs`, `maru_test`, `ir2`, `core_forms`, `zero_global`, `maru_check`, `maru_label`, `exit_status`, `ir_retired`, `library_mode`.
- [Maru objects in typed Maru](doc/ir2-objects.md): `define-object`, `new`, fields by name, `get`/`put` checked, `object-type`, lowered to eval.l's layout. Checks: `ir2_objects`, `native_ir2`.
- [The grounded kernel](doc/kernel.md): Maru's evaluator in typed Maru through ir2, aligned on eval3.c, natively and through C, and a law over its objects. Checks: `kernel_native`, `kernel_c`, `law_objects`.
- [irl](doc/irl.md): The C-like irl language over ir2: programs, libraries and grammar blocks. Checks: `irl`, `irl_library`, `irl_grammar`.
- [Native code from ir2](doc/native.md): Typed Maru compiled to arm64 and x86-64 in process, code images, and the JIT. Checks: `native_ir2`, `native_ir2_x64`, `native_image`, `jit_run`.
- [Assemblers and executables](doc/assemblers.md): Table-driven encoders for x86, x86-64 and arm64, and `exe.l`'s executables with no toolchain. Checks: `asm_x86`, `asm_interface`, `asm_rows_arm64`, `asm_rows_x64`, `asm_rows_x86`, `asm_coverage`, `asm_patch`, `asm_table`, `exe`.
- [JOHN](doc/john.md): Samimi's planning language: parsing, the possible-worlds evaluator, sessions and call by meaning. Checks: `john_forms`, `john_run`, `john_session`, `call_by_meaning`, `plan_evidence`.
- [SAT solving](doc/sat.md): The CDCL solver in irl, DIMACS, DRAT proofs, and JOHN's SAT planner. Checks: `sat_core`, `sat_dimacs`, `sat_proof`, `sat_john`.
- [Laws and rules](doc/laws.md): The rule engine, `.law` files and their runner, and the laws over C expressions and Nile. Checks: `law_engine`, `law_cexpr`, `law_rules`, `law_nile`.
- [KScript and KSWorld](doc/ksworld.md): KScript's evaluator, KSWorld documents headless and in a window, KSWorld's own sources, text and rendering. Checks: `kscript`, `ksworld_headless`, `ksworld_sources`, `ksworld_mouse`, `ksworld_window`, `ksworld_clock`, `gezira_image_fill`, `ksworld_pixels`, `ksworld_rerender`, `ometa2`.
- [PNG](doc/png.md): The PNG decoder and encoder in irl, held to fixtures, hostile input and sanitizers. Checks: `png`, `png_asan`.
- [Nile and Gezira](doc/nile.md): Nile's compiler on Maru, its runtime in typed Maru, Gezira, and the runtime's laws and schedules. Checks: `nile_compile`, `nile_text_layout`, `gezira_image`, `gezira_vector`, `gezira_maru`, `nile_laws`, `nile_schedules`, `nile_dupcat`, `nile_interface`, `nile_leaks`, `nile_limits`, `nile_oom`, `nile_osdefs`, `nile_prefix`, `nile_recip`, `nile_reroute`, `nile_reverse`, `nile_sort`, `nile_startup`, `nile_zip_stream`, `gezira_many`, `gezira_oom`, `gezira_scene`.
- [SDL3](doc/sdl3.md): Typed SDL3 bindings, measured from this machine's headers. Checks: `sdl3_window`.
- [Sources](doc/source.md): What loading defined answers its own source, form and line counts, text and tokens; files read without running them. Checks: `source`, `source_lift`, `source_tokens`.
- [Line count and erosion](doc/measures.md): The `lines` ledger and budget, and the erosion and verbosity metrics. Checks: `lines`, `erosion`.

## Also

- [The evidence plan](doc/evidence-plan.md): `notes/plan/`'s JOHN plans, how their evidence is observed and recorded, and `MARU_PLAN`.
- [Known not to work (verified on arm64 macOS)](doc/known-issues.md): Read before relying on 32-bit x86, tail calls, closures made in a loop on `eval`, or cross-compiling.
- [VPRI's Frank](doc/vpri/index.md): one-page walkthroughs of Frank's parts (OMeta2, KScript and its streams, LObjects, KSWorld, Worlds, Cassowary, Cooperating Languages, Nile, Gezira, ForAll, SISS, Silt, J), sorted by the families of expression STEPS aimed for.
- [Roadmap](doc/roadmap.md): What comes next: the arm64 back end, `refactor-main`'s pieces, the STEPS grammars, bare metal, Nile.
