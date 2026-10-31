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
asserts what it computes; `./eval check/check.l NAME…` runs selected cases.
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
- `zero_global` (`check/zero-global.k`): a global declared with no
  initialiser, `(define (name T))`, starts at zero, for a scalar and a struct.
- `maru_check`: upstream's own ir2 test, `maru-check.k`, passes all sections.
- `maru_gc`: the GC written in Maru allocates 2.56M cells, collects, and
  frees everything.
- `maru_gc_coalesce` (`check/gc.k`): its allocator grows the heap when needed
  and merges adjacent free chunks.
- `text_parser`: `text-parser.l` matches a string literal that ends at the
  end of its input.
- `irl`: `irl.g` (inheriting `cexpr.g`) compiles `test.irl` to C that, where
  x86_64 code runs, prints what the program should; `irgol.g` still parses
  `test.irgol`.
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
- `eval2.c` was hand-edited upstream; nothing here regenerates it.
- Cross-compiling: ir2 sizes follow the host's `osdefs.k`. Since that change
  (to fix the C backend on 64-bit hosts), `ir-gen-x86.k` emits 64-bit layouts
  on a 64-bit host, which is wrong for its 32-bit target.
- `test-peg.l` loops forever on every platform: `peg.l`'s `definitions` rule
  matches empty input, so the parser never advances. `compile-irgol.l` no
  longer matches the current `ir.k`.
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
