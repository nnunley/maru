# Assemblers and executables

Table-driven encoders for x86, x86-64 and arm64, and `exe.l`'s executables with no toolchain.

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
