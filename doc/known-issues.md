# Known not to work (verified on arm64 macOS)

- No 32-bit x86 code links or runs on macOS (dropped in 10.15; Rosetta is
  x86_64-only). That rules out `make test` (`emit.l` emits IA32 only; emitting
  and `cc -arch i386 -c` work, linking fails), `eval32` and its targets, and
  the demos that run i386 code in-process: `test-call.k`, `test-elf.l`,
  `test-mach-o.l`, `assembler.k`. On arm64 they first fail at
  `mprotect: Permission denied` (eval.c:2497).
- Neither evaluator eliminates tail calls, and a stack overflow is an unguarded
  segfault, the one failure `recover.l` can't yet catch. On the default 8 MB stack `eval` overflows between 2,000 and 4,000 nested
  tail calls, and `eval2` between 4,000 and 7,000.
- `eval2.c` was hand-edited upstream; nothing here regenerates it.
- On `eval`, closures made in a loop's body share its variables, and its `let`s: `(list-do x '(1 2 3) (push fs (lambda () x)))`
  answers 3 three times (`eval2` and `eval3` give each its own). Make such a closure in a function of its own, as
  `ksworld-source.l`'s `ks-primitive-function` does; an audit (2026-11-07) found no other closure in the tree outliving its loop.
- Cross-compiling: ir2 sizes follow the host's `osdefs.k`. Since that change
  (to fix the C backend on 64-bit hosts), `ir-gen-x86.k` emits 64-bit layouts
  on a 64-bit host, which is wrong for its 32-bit target.
- tpeg's actions read no float literal (`tpeg.g`'s `sexpr` has integers only: `-> (* 1.0 n)` stops the grammar's parse);
  compute a float in a Maru function the action calls.
- `test-peg.l` loops forever on every platform: `peg.l`'s `definitions` rule
  matches empty input, so the parser never advances.
- `make test-emit` runs `emit.l` as a shell script; use
  `./eval emit.l test-emit.l`.
- `net/*.osdefs` are Linux-only (`linux/tcp.h`, `linux/if_tun.h`).
- `maruby.l` is an early start on Ruby: `1 < 2` yields `t`; there's no
  `nil`, `true`, `false`, strings or arrays; variables can't be read in
  expressions; the `block` rule is unused, so no blocks.
- Gezira/GL demos need `libnile` and `libglfw` built from `../nile`.
- The SDL2 example (`./eval3 libsdl2.k`, a window to draw lines in) needs
  SDL2 and SDL2_gfx; without SDL2_gfx it stops at `could not load: libSDL2_gfx`.
