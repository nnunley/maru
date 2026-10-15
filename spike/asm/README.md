# Table-driven assembler spike (2026-10-14)

Throwaway code behind `docs/superpowers/specs/2026-10-14-table-driven-assemblers-design.md`,
committed so it is not lost. Each file is promoted into the tree, with checks, or
removed, by that spec's plan. Nothing here is used by the build.

Run from the repo root; each script takes this directory as its first argument.

The encoders, grammars and cross-checks have been promoted (asm-table.l,
asm-arm64.l, asm-x86.l and the asm_* checks); what remains here is retired
by the assembler plan's last task.

| Files | What they are |
|---|---|
| `run.l` | Assembles a program into a multiboot image for `qemu-system-i386` (A..Z on COM1) |
| `arun.l`, `afib-main.c` | Assembles `fib(n)` with the A64 rows and runs it from C |
| `jit.c` | Runs A64 words from a `MAP_JIT` region on macOS |

State when committed (2026-10-15, arm64 macOS):

    ./eval spike/asm/axcheck.l spike/asm && sh spike/asm/acmp.sh
      266 instructions, 0 round-trip failures; 266 compared, 0 differ
    ./eval spike/asm/xcheck.l spike/asm && sh spike/asm/cmp.sh
      536 instructions, 2 round-trip failures (INT -5 decodes as INT 251);
      536 compared, 0 differ

`cmp.sh` and `acmp.sh` need `llvm-objcopy` (Homebrew `llvm`).
