# Assemblers and executables

Table-driven encoders for x86, x86-64 and arm64, and `exe.l`'s executables with no toolchain.

## The candidate table

`asm-attempt` no longer encodes an instruction against every row of its mnemonic. `asm-table.l` keys a candidate
list on the mnemonic and each operand's shape (a register and its class, a memory operand's form, a number), and the
encoder tries only those rows, in file order, with the same shortest-or-widest choice as before. A list is built on
first use for each (mnemonic, shapes) and kept per instruction set. An instruction set registers its shape and accept
functions with its rows (`arm64-shape`/`arm64-accepts`, `x86-shape`/`x86-accepts`); both are conservative, so every
row that can encode an instruction is a candidate. A kind whose test reads the value takes every number. When no
candidate fits, the full scan runs, and a refusal's error text is unchanged. Arm64 has a fixed width and no open
placeholder, so the first fitting row ends the search; the other instruction sets keep scanning.

A new instruction set with no shape and accept functions gets the full scan. Its rows alone do not build the table,
since the table has to know what each kind accepts; that is per-ISA code, as encode and decode already are.

## Checks

- `asm_x86` (`check/asm-x86.l`): the x86 assembler that make generates from
  `gen-asm-x86.k` (C preprocessor encoding macros, read by a grammar) encodes as
  `clang -target i386` does. Change the spec, never `asm-x86.k`.
- `asm_interface` (`check/asm-interface.l`): the one encoder interface
  (`asm`, `asm-forms`, `asm-decode`, refusals) answers the same way for arm64
  and x64, under both evaluators.
- `asm_rows_arm64`, `asm_rows_x64`, `asm_rows_x86` (`check/asm-rows.l`): every
  row of `arm64.spec` or `x86.spec`, sampled in every operand position (and
  every NEON arrangement), assembles to the bytes clang gives and decodes
  back to them; unencodable operands are refused.
- `asm_table` (`check/asm-table.l`): the candidate table answers as the full scan does, for every row's samples (each
  number in turn a placeholder) and every refusal, with the same bytes, reports and error text, and a refusal writing
  nothing; every row that encodes an instruction is among its candidates; over the whole stream the table tries fewer
  encodes than the scan (arm64, x64 and x86, under `eval`, and arm64 and x86 under `eval2`).
- `asm_coverage` (`check/asm-coverage.l`): every form in `asm-coverage.spec`
  has a row, and every operation `ir2.k` declares, on every type, is named
  there for each instruction set.
- `asm_patch` (`check/asm-patch.l`): a placeholder patched later gives the
  same row's bytes for the final value; one past the field's range is refused.
- `exe` (`check/exe.l`): `exe.l` writes executables with no compiler, linker or codesign, for `linux-i386`, `linux-x64`,
  `linux-arm64`, `macos-arm64` and `macos-x64`, from an assembly buffer, as `code-region.l` runs one in-process. ELF is
  static; Mach-O keeps dyld and signs itself ad hoc (`sha256.l`, FIPS 180-4's vectors). On Linux a program makes system calls; on
  macOS the stable interface is `libSystem`, so a program imports `write` and `exit` through slots in `__DATA` that dyld fills. Each program prints a message
  and exits 42, the bytes are the same from all three evaluators, and each runs where it can: natively, under Rosetta,
  or in Colima's Linux VM, and a target with nowhere to run says so. One piece of arm64 code returns 42 from a file and
  through the JIT.
