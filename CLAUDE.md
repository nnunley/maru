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

    make eval eval2 osdefs.k    # not plain `make`: it builds eval32 with -m32

## Verify

    make check

`check/check.sh` runs each demo and asserts what it computes
(`sh check/check.sh NAME…` runs selected cases):

- `pepsi`: the Smalltalk-like language's FFT peaks at bins 2 and 6.
- `recursion`: left-recursive PEG grammars match as expected and build a
  left-associative tree.
- `repl`: a language defined at the REPL prints a correct multiplication
  table and `nfibs(15)`.
- `pegen`: a generated PEG matcher stops at the first unmatched character.
- `earley`: Earley parsing of `1+2*3` respects precedence.
- `maruby`: Ruby arithmetic and method calls.
- `maru_test`: a program compiled through the ir2 C backend computes primes
  and struct arithmetic.
- `ir2_sizes`, `ir2_pointers`: ir2 agrees with the C compiler on type sizes,
  `long` width, and pointer arithmetic (scaled by element size, like C).
- `maru_gc`: the GC written in Maru allocates 2.56M cells, collects, and
  frees everything.

## Known not to work

- `emit.l` emits 32-bit x86 only, so `make test` (self-compile) can't run on
  arm64.
- ir2 takes type sizes from the host (`osdefs.k`), so cross-compiling isn't
  supported: `ir-gen-x86.k` (32-bit) gets 8-byte pointers on a 64-bit host.
- `test-call.k` fails with `mprotect: Permission denied` on macOS.
- `test-peg.l` and `test-message.l` don't run via `repl.l`; `make test-peg`
  is unverified.
- `check-maru` names `maru-nfibs.k`, which doesn't exist upstream.
- `maruby.l` is an early start on Ruby: syntax for classes, `def`, operators
  and calls, but `1 < 2` yields `t`, and there's no `nil` and no blocks.

## Roadmap

1. An `ir-gen-arm64.k` backend beside `ir-gen-c.k` and `ir-gen-x86.k`.
2. Carry over refactor work from `refactor-main` case by case, with tests.
