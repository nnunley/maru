# Maru

## What this is

Dan Amelang's Maru as of 2012-12-24 (`ac07e5e`), as used for Nile, on top of
Ian Piumarta's 2.4 release, with Kurt Stephens' fork merged in. Kurt's merge
adds only `maruby.l`; his other changes are in the history, not the code.

The layout is flat, as upstream intended: `require` and `load` resolve
relative to the current directory, so run everything from the repo root.

## Other history (tags)

`refactor-main` (the 2025 reorganization, with unfinished ARM64 experiments
in `core/compiler/ir-gen-arm64*.k`), `amelang-nile` (Dan's repo for Nile),
`linear-main`, `kurt/*`, and releases `v1.0-original`, `maru-1.0`,
`maru-2.1` … `maru-2.4`, `maru-last-vpri`, `v2.5-vpri-complete`.

## Build

    make    # eval, eval2, osdefs.k, and eval32 where -m32 links (not macOS)

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

`check/check.l` (untyped Maru, built on boot.l's `unit-test`) runs each demo and
asserts what it computes; `make check CHECKS="NAME…"` runs selected cases, after
building what is stale. Libraries and grammars that checks open are built by make into
`build/` (`CHECK_LIBS`, failures ignored so the other checks still run), and a check asserts
`make -q` on what it opens; `make clean` removes `build/`. Run cases through make, not
`./eval check/check.l` directly: no case names the derived files it needs (`law.g.l`, `cexpr.g.l` …), so a
direct run in a fresh or stale tree fails on a missing or old grammar.
Typed checks are ir2 programs in `check/` (`ir2.k`, `gc.k`), as upstream's
`maru-check.k` is.

- `osdefs`: `osdefs.k` agrees with the compiler's predefined macros.
- `pepsi`: the Smalltalk-like language's FFT peaks at bins 2 and 6.
- `recursion`: left-recursive PEG grammars match as expected and build a
  left-associative tree.
- `peg_compose` (`check/peg-compose.l`, `check/peg-lr.l`): grammars that
  call each other's rules keep their memos apart, an inherited rule calls an
  override, and a left-recursive entry rule grows, in `parser.l` and
  `text-parser.l`.
- `repl`: a language defined at the REPL prints a correct multiplication
  table and `nfibs(15)`.
- `pegen`: a generated PEG matcher stops at the first unmatched character.
- `earley`: Earley parsing of `1+2*3` respects precedence.
- `maruby`: Ruby arithmetic and method calls.
- `maru_test`: a program compiled through the ir2 C backend computes primes
  and struct arithmetic.
- `asm_x86` (`check/asm-x86.l`): the x86 assembler that make generates from
  `gen-asm-x86.k` (C preprocessor encoding macros, read by a grammar) encodes as
  `clang -target i386` does. Change the spec, never `asm-x86.k`.
- `ir2` (`check/ir2.k`): sizes, alignment and struct padding match `osdefs.k`;
  pointer offsets of any integer width move by bytes at full pointer width.
- `core_forms` (`check/core-forms.l`): arithmetic, comparison and logical
  forms give the same values untyped and through `maru.k`.
- `zero_global` (`check/zero-global.k`): a global declared with no
  initialiser, `(define (name T))`, starts at zero, for a scalar and a struct.
- `maru_check`: upstream's own ir2 test, `maru-check.k`, passes all sections.
- `maru_gc`: the GC written in Maru allocates 2.56M cells, collects, and
  frees everything.
- `maru_gc_coalesce` (`check/gc.k`): its allocator grows the heap when needed
  and merges adjacent free chunks.
- `text_parser`: `text-parser.l` matches a string literal that ends at the
  end of its input.
- `cexpr_forms` (`check/cexpr-forms.l`): `cexpr.g` parses C's expressions,
  with C's precedence, to Maru forms.
- `john_forms` (`check/john-forms.l`): `john.g` (inheriting `cexpr.g`) and `john.l` read
  JOHN, Samimi's VPRI planning language, as reconstructed in
  `~/pkm/wiki/synthesis/john-language-reconstruction.md`: the three complete programs in
  `check/john/` (Hanoi4, the puzzle and x86 register allocators) to 31, 47 and 33
  statement forms. A keyword argument is one primary and sends chain on after it
  (`a at: (i) length = 2`), `+` ends a keyword send, and a name is an infix relation
  if a `rel-qualify` anywhere in the program declares it (`it smaller Surface`; the
  program is read twice). `for some X` (ours) is `for any X`; over a class it means the
  class's instances, a rule for evaluation, not parsing.
- `john_run` (`check/john-run.l`): `john-eval.l` runs JOHN programs by searching possible
  worlds level by level, each action's effects all read from the world it starts in (a
  swap). It solves Towers of Hanoi in the fewest moves, 3 for `check/john/hanoi2.john` and
  7 for `hanoi3.john` (both ours, after the memo's Hanoi2 tables), and reports the worlds
  it looked at. Qualifications take the first clause whose guard holds (`sorted`), a
  class is its instances in `for every`, `for some` and `select`, and a name, property
  or qualification nothing defines is an error. An `action-optimization` narrows an
  action's arguments and a `goal-optimization` the actions each world tries, so the memo's
  x86 allocator (`check/john/x86-allocator.john`) finds a plan in 6 steps, one a split, and
  its allocation fills every live range slot by slot. Lists count from 1 (`at:`, `to:`,
  `from:`). The puzzle allocator, asked to satisfy its goal, stops at
  `unknown name: live-vars`, the memo's slip for `each live-vars`. Heuristics score a
  world: with `set-opt max-time-ahead H`, every H levels the next move toward the
  best-scoring world is certain and the other branches are dropped, so the maze
  (`check/john/maze.john`, ours) is solved looking at fewer worlds, and a dead end that
  scores better is committed to (the incompleteness RN-2008-003 admits). With
  `set-opt two-player-game [ A, B ]` the opponent makes only its best-scoring replies:
  Nim from 3 is won only if Black blunders, from 4 always. Ours, not the memos':
  `set-opt merge-worlds yes` drops a world whose state (every property of every object)
  was reached before, so Hanoi3 looks at 8 worlds at its last level instead of 1086 and
  a consistent Hanoi4 (`check/john/hanoi4-ours.john`) is solved in 15 moves; a commit
  forgets the states seen on the branches it drops. Time is the chain of worlds:
  `at time t E` reads an earlier world, and a later t gives the values over the possible
  worlds that far ahead (RN-2008-003). Ours, after McCarthy's Elephant: an expression
  may read earlier times (`at time T E`, `for some time T after A up to B do P`) and ask
  which action made a world (`X did reserve`), an action may be an event with no
  effects, and `X do act` runs one action now. So the airline
  (`check/john/airline.john`) keeps no record of reservations: a passenger has one if a
  request made while the flight had room wasn't cancelled since. An expression can't
  read the future. Qualifications are kept per world. `hanoi4.john` as printed is
  inconsistent (`Peg1` supports `B`, which sits on `C`).
- `irl`: `irl.g` (inheriting `cexpr.g`) and `compile-irl.l` turn `test.irl`
  into a `.k` program that `maru.k` compiles and that prints what it should;
  `?:` with branches of different types (`check/irl-errors.irl`) stops ir2 at
  a type mismatch in the `if` (`check/irl-errors.l` records it in Maru).
- `irl_library` (`check/irl-library.l`): `compile-irl.l --library A.irl B.irl` reads
  several irl files to one program with no `main` (a top-level statement is an error), and
  `export f;` keeps a function visible; make builds the library (`build/irl-lib.dylib`), which
  untyped Maru opens by its path in the tree and calls by address. `cast(e, type)` and
  `sizeof(type)` read to maru.k's own forms.
- `sat_proof` (`check/sat-proof.l`): every UNSAT answer from `sat-decide` carries a DRAT
  proof (`sat.irl` writes each learned clause, and `0` at the refutation), which
  `drat-check.irl` verifies forward (a lemma RUP, or else RAT on its first literal) against
  the formula it reads itself through `dimacs.irl`'s grammars, else `E_PROOF`. It rejects a
  proof without its final `0`, an empty one, a lemma that doesn't follow (naming its line), and
  one that deletes what it needs. Proofs go to `/tmp/maru-sat`, never through a symbolic link.
- `sat_core` (`check/sat-core.l`): `sat.irl`, a CDCL solver behind IPASIR (`sat_init`,
  `sat_add`, `sat_assume`, `sat_solve` answering 10, 20 or 0, `sat_val`, `sat_failed`), in
  `build/sat.dylib`. `sat.l`'s `sat-decide` solves a formula on a fresh solver and checks
  the model against every clause (`E_MODEL`). It answers satisfiable and unsatisfiable
  formulas, clauses added between solves, and assumptions with the ones a refutation used.
- `sat_dimacs` (`check/sat-dimacs.l`): `dimacs.irl`'s grammar block `<cnf>`, built into
  `build/sat.dylib` (opened by `sat.l`), reads DIMACS CNF and names the first bad line: a
  literal above V or twice in a clause, too few or too many clauses, no header, a count over
  2^30. `sat-write-dimacs` round-trips through `dimacs_load`.
- `irl_grammar` (`check/irl-grammar.l`): a tpeg grammar calls another grammar's rule as `p-r`
  (compiled by `compile-tpeg.l` to a parser of `<p>` on the same input). In irl,
  `grammar { <G> : <parent> (fields) rules }` is tpeg's own syntax, read through that foreign
  call. Its matching is tpeg's own: `irl-grammar.l` lowers `compile-tpeg.l`'s `value-pe`
  output to typed Maru over `text-parser.k`, a struct `G` (string, limit, position, result,
  span, the fields) and one function per rule, `G_rule(self)`, actions maru.k forms copied in
  unchanged. A child's inherited rules call its overrides; a left-recursive rule, lists and
  strings are errors naming the rule.
- `law_engine` (`check/rules-test.l`): `rules.l`'s one rule set generates, checks and
  enumerates alike; a recursive rule never applies at size 0; unification has an occurs
  check; the `in`, `number` and `=` builtins work as specified; schemas, relation
  parameters and facts read from a function expand to first-order rules, and an unknown
  relation is rejected.
- `law_cexpr` (`check/law-compile-test.l`, `check/laws/cexpr.law`): `law.g` (inheriting
  `cexpr.g`) and `law-compile.l` read the RFC's example law file to rule, let, set and
  law items. A template's holes fill by text with no grouping added (`{x} * c` with
  `a + b` parses to `(+ a (* b c))`), and `{{` is a literal brace. An error fails naming
  its line, and an unbound hole is `E_TEMPLATE_PARSE`. `cexpr.law` holds `?:` to the
  right, `-` to the left and a comment to a blank, over `cexpr.primary` sentences
  generated from `cexpr.g`'s records, at least 80% accepted (a sentence counts when the
  parser stops at its end with `)` after it). The false `{a}-({b}-{c})`
  (`check/laws/fixtures/minus-right.law`) is refuted for seed 42.
- `law_rules` (`check/law.l`, `check/laws/fixtures/`): the runner prints one line per
  law, `law NAME:`, then `TESTED n`, `PROVED n`, `REFUTED x=v ... seed=s` (shrunk;
  the seed reproduces it), `STARVED k of n`, `VACUOUS` or `INCONCLUSIVE status=s input=...`
  (a reference crashed). A file with no `under test:` line is `E_NO_UNDER_TEST`, a goal
  domain must bind its last argument (`E_BINDING`), and a grammar domain must name a
  registered language (`E_GRAMMAR`) and can't be exhausted (`E_EXHAUST`).
  `law NAME: mutants of R by exhaustion size n. L, ...` judges each mutant of the rules
  R reaches at the least size its rule appears: `PROVED n` if each fails a named law,
  else `REFUTED k of n survive` (`fixtures/adequacy.law`). `let numerals = [1, 2]`
  replaces `number`'s numerals (`fixtures/numerals.law`). The mutant focus follows where a law
  uses the relation (`reach.law`), and a reference's answers are kept by name and text
  (`refs.law`). `.law` files count toward `lines`.
- `law_nile` (`check/laws/nile.law`, `check/laws/nile-reference.l`): rules for
  well-typed Nile expressions, with operator facts read from `nile/compilers/prelude.nl`,
  are sound (Nile's own resolver and type checker, forked per question, accept what they
  generate), checked by themselves, all used, and agree with Nile on expressions that
  ignore types. Nile's resolver crash on `ϫ():ρ` / `forall_`
  (`fixtures/nile-crash.law`) is `INCONCLUSIVE`. `nile-adequacy.law`: every one of the
  69 mutants of the expr rules fails sound or agree.
- `ir_retired`: `ir.k` and irgol are gone, and `irl.g` and `compile-irl.l`
  have no `ir-` form.
- `eval2_subr` (`check/eval2-subr.l`): both evaluators call C through `subr`,
  by name or address, with typed results (`"dd>d"`), variadic calls and raw
  byte access.
- `asm_interface` (`check/asm-interface.l`): the one encoder interface
  (`asm`, `asm-forms`, `asm-decode`, refusals) answers the same way for arm64
  and x64, under both evaluators.
- `asm_rows_arm64`, `asm_rows_x64`, `asm_rows_x86` (`check/asm-rows.l`): every
  row of `arm64.spec` or `x86.spec`, sampled in every operand position (and
  every NEON arrangement), assembles to the bytes clang gives and decodes
  back to them; unencodable operands are refused.
- `asm_coverage` (`check/asm-coverage.l`): every form in `asm-coverage.spec`
  has a row, and every operation `ir2.k` declares, on every type, is named
  there for each instruction set.
- `asm_patch` (`check/asm-patch.l`): a placeholder patched later gives the
  same row's bytes for the final value; one past the field's range is refused.
- `jit_run` (`check/jit-run.l`): code assembled into a code region runs
  in-process through the C ABI on each evaluator the host has (arm64, and
  x86-64 under Rosetta through `bin/x86_64/eval2`).
- `cross_eval`: on arm64 macOS with Rosetta, `bin/x86_64/eval` and `eval2`
  are built.
- `boot2_strings` (`check/boot2-strings.l`): `boot2.l`'s Maru definitions of
  `string-copy`, `string-compare`, `long->string` and `string->long` behave
  as `eval`'s C primitives do (the cases pass under both evaluators).
- `nile_compile` (`check/check.l`): `nile/compilers/maru/nile-to-maru-compiler.sh`
  runs Nile's compiler on `eval2` and `boot2.l`, and writes the same Maru
  for `nile/examples/text-layout.nl` as `eval` and `boot.l` do.
- `run_limit`: `run` ends a command still running at its limit (120 s; 1 s in
  the check) by an alarm set in the child, through `subr` (no perl or coreutils).
- `lines`: the source line count equals the sum of `check/lines`. Any change
  in line count needs an entry there with its delta, and an entry that adds
  lines must say why. Derived files are marked `derived` in `.gitattributes`
  and not counted, nor is `notes/` (reference copies) or anything marked
  `unused` in the `nile/` and `gezira/` submodules; the C evaluator counts
  until `emit.l` generates it. Tests count. The budget is 20k lines, the
  STEPS target ("a modest 400-page book" one programmer can hold); it is
  soft, so the check reports the total but doesn't fail over it. Prefer a DSL or grammar (as `gen-asm-x86.k` generates
  the x86 assembler) over writing code out, tests included.

## Known not to work (verified on arm64 macOS)

- No 32-bit x86 code links or runs on macOS (dropped in 10.15; Rosetta is
  x86_64-only). That rules out `make test` (`emit.l` emits IA32 only; emitting
  and `cc -arch i386 -c` work, linking fails), `eval32` and its targets, and
  the demos that run i386 code in-process: `test-call.k`, `test-elf.l`,
  `test-mach-o.l`, `assembler.k`. On arm64 they first fail at
  `mprotect: Permission denied` (eval.c:2497).
- Neither evaluator eliminates tail calls, and a stack overflow is an unguarded
  segfault. On the default 8 MB stack `eval` overflows between 2,000 and 4,000 nested
  tail calls, and `eval2` between 4,000 and 7,000.
- `eval2.c` was hand-edited upstream; nothing here regenerates it.
- Cross-compiling: ir2 sizes follow the host's `osdefs.k`. Since that change
  (to fix the C backend on 64-bit hosts), `ir-gen-x86.k` emits 64-bit layouts
  on a 64-bit host, which is wrong for its 32-bit target.
- `test-peg.l` loops forever on every platform: `peg.l`'s `definitions` rule
  matches empty input, so the parser never advances.
- `make test-emit` runs `emit.l` as a shell script; use
  `./eval emit.l test-emit.l`.
- `net/*.osdefs` are Linux-only (`linux/tcp.h`, `linux/if_tun.h`).
- `maruby.l` is an early start on Ruby: `1 < 2` yields `t`; there's no
  `nil`, `true`, `false`, strings or arrays; variables can't be read in
  expressions; the `block` rule is unused, so no blocks.
- Gezira/GL demos need `libnile` and `libglfw` built from `../nile`.

## Roadmap

1. An `ir-gen-arm64.k` backend beside `ir-gen-c.k` and `ir-gen-x86.k`.
2. Carry over refactor work from `refactor-main` case by case, with tests.
   - First: the UTF-8 grammar, `grammars/unicode/utf8.g` on `refactor-main`.
     It was never run. Its actions read the lead byte as hex text, and it
     accepts overlong forms, surrogates and values above U+10FFFF. Restore it
     with RFC 3629's valid ranges and U+FFFD for invalid input, and add a check.
3. Promote the grammars in `notes/sources/grammars/` (transcribed from the
   STEPS reports and papers) into the tree as working grammars, each with a
   check and a `check/lines` entry. TCP first: `net/tcp.k`'s packet handling
   as the 2007/2008 reports' `svc`/`syn`/`req`/`ack` rules.
4. Bare metal: Maru as a bootable live image. The qemu raw-boot
   environments (i386, x86-64 long mode, A64 `virt`: boot, console, memory
   map, exit) are the first step, specified after the encoders
   (RFC 0001, `docs/rfc/0001-table-assemblers.md`) as part C of the 2026-10-14
   assembler design.
5. Nile on Maru: a Nile runtime written in typed Maru (new kernel interface,
   POSIX mutexes, arm64 and x86-64), then Gezira, then the windowed demos.
   Nile and Gezira come in as submodules of forks, and count toward the 20k.
   Spec: `docs/rfc/draft-ndn-nile-runtime-in-maru-01.md`.
   - Array types in `maru.k`/`ir2`, replacing the runtime's `long` field runs.
   - Blocks sized to a stream's element size, so kernels over large tensors
     can run (one 512-byte block size caps an element at about 118 floats).
6. Checks without make or a shell, for the bare-metal image. `check/check.l`
   compiles a stale grammar in-process with `compile-tpeg.l` (each case naming the
   derived files it needs), and `lines` counts the tree in Maru instead of through
   `git ls-files | grep | wc`. Today the cases reach the shell through `run`
   (`system`), and only `make` builds what they need.
