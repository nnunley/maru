# Table-driven assembler spike (2026-10-14)

Throwaway code behind `docs/superpowers/specs/2026-10-14-table-driven-assemblers-design.md`,
committed so it is not lost. Each file is promoted into the tree, with checks, or
removed, by that spec's plan. Nothing here is used by the build.

Run from the repo root; each script takes this directory as its first argument.

| Files | What they are |
|---|---|
| `x86.spec`, `x86.g` | IA-32 rows in the Intel SDM's opcode-table notation, and the grammar that reads them |
| `arm64.spec`, `arm64.g` | A64 rows as the Arm ARM's encoding diagrams, and their grammar |
| `*.g.l` | Parsers generated from the `.g` files (derived) |
| `x86.l` | Encoder and decoder that interpret the x86 rows |
| `x86-pre.l`, `x86-fast.l` | Variants of `x86.l` (rows preprocessed at load; a faster interpreter) measured for speed |
| `x86-gen.l` | Compiles each row into a specialised encoder while loading (the design the spec chose) |
| `arm64.l` | Encoder and decoder that interpret the A64 rows |
| `xcheck*.l`, `cmp.sh` | Encode sample operands for every x86 row, compare with `clang -target i386`, decode and re-encode |
| `axcheck.l`, `acmp.sh` | The same for A64 against `clang -target arm64-apple-macos` |
| `run.l` | Assembles a program into a multiboot image for `qemu-system-i386` (A..Z on COM1) |
| `arun.l`, `afib-main.c` | Assembles `fib(n)` with the A64 rows and runs it from C |
| `jit.c` | Runs A64 words from a `MAP_JIT` region on macOS |
| `enc-*.l`, `load-*.l`, `t0.l`, `at0.l`, `dump.l`, `ebp.l` | Timing and probe scripts |

State when committed (2026-10-15, arm64 macOS):

    ./eval spike/asm/axcheck.l spike/asm && sh spike/asm/acmp.sh
      266 instructions, 0 round-trip failures; 266 compared, 0 differ
    ./eval spike/asm/xcheck.l spike/asm && sh spike/asm/cmp.sh
      536 instructions, 2 round-trip failures (INT -5 decodes as INT 251);
      536 compared, 0 differ

`cmp.sh` and `acmp.sh` need `llvm-objcopy` (Homebrew `llvm`).
