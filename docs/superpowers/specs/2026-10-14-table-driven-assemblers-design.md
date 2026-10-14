# Table-driven assemblers and disassemblers (x86, A64)

## Goal

Each instruction set is described once, in its vendor manual's own notation,
and that description is both the assembler and the disassembler. The two are
inverse: disassembling any program and assembling the result gives back the
same bytes.

This replaces `gen-asm-x86.k`, which reads C preprocessor macros through a
grammar that gives them Maru meaning wherever C and Maru disagree (the `#`
operator is dropped, the comma operator becomes `let`, and macros become
functions), together with the generated `asm-x86.k`, the hand-written
`dsm-x86.k`, and `asm-common.k`. It is also the model for the A64 backend on
the roadmap.

## Non-goals

- Describing every instruction's operands. Rows are added as the compilers
  need them. Every other instruction still disassembles and reassembles, as a
  data fragment of exactly its own bytes (see Unknown fragments), so partial
  coverage limits what the disassembly says, never whether it is correct.
- Assembler text syntax (AT&T or Intel) as input. Instructions are Maru
  data. A printer for Intel syntax exists only for the clang check.
- Object-file formats. The caller owns the output buffer, labels and
  relocations. The encoder reports where each operand's field landed, so the
  caller can patch it later (see Interface).
- Run-time speed. The encoders are compiled while loading. Encoding the 21,009
  instructions `emit.l` produces for `eval.l` is estimated at about 0.24 s,
  against 1.46 s for `emit.l` itself (spike: 5.2x slower per instruction than
  `asm-x86.k`).

## Design

### Files

| File | What it is | Counted |
|---|---|---|
| `asm-table.l` | Shared: loads rows, compiles encoders while loading, dispatches by mnemonic (first matching row wins), decode loop | yes |
| `x86.spec` | x86 rows: Intel SDM vol. 2 opcode column, then instruction column | yes |
| `x86.g` | Grammar: `x86.spec` to rows, and `x86-map.spec` to length rules | yes |
| `x86.g.l` | Compiled from `x86.g` by `compile-tpeg.l`, as `osdefs.g.l` is | derived |
| `asm-x86.l` | x86 operand kinds, operand size, ModRM/SIB, row compiler, decoder | yes |
| `x86-map.spec` | x86 instruction lengths: SDM vol. 2 Appendix A opcode maps, cells in the map's own operand notation | yes |
| `a64.spec` | A64 rows: Arm ARM encoding diagram (bit 31 to 0), then assembler syntax | yes |
| `a64.g`, `a64.g.l` | As for x86 | yes, derived |
| `asm-a64.l` | A64 fields, operand binding, row compiler, decoder | yes |

The `lines` check must count `.spec` files: add `spec` to its extension
pattern, or the rows would escape the budget. The compiled grammars `x86.g.l`
and `a64.g.l` get Makefile rules (as `osdefs.g.l` has), `.gitignore` entries,
and `derived` entries in `.gitattributes`.

The rows are parsed while loading. In the spike, parsing plus compiling took
about 64 ms over a bare `eval`. If that becomes a problem, make can write the
parsed rows to a derived file, which cuts the load to about 17 ms.

### Interface

    (x86 X 'ADD 'EAX 5)                       ; encode one instruction
    (x86-decode bytes pc)  =>  (instruction . rest)
    (a64 X 'STP 'X29 'X30 '(pre SP -32))
    (a64-decode word pc)   =>  instruction

The caller defines `(_B X byte)` to emit a byte and `(_PC X)` to give the
address of the next byte, both before loading, because Maru resolves globals
when a function is defined.

Operands are Maru data:
- registers are their names (`EAX`, `X0`, `SP`, `XZR`);
- immediates and branch targets are numbers (targets are absolute addresses);
- x86 memory is `(m32 disp base index scale)`, tagged `m8`, `m16` or `m32`
  by its size, or `m` for any size (as for `LEA`);
- A64 memory is `(off Xn imm)`, `(pre Xn imm)` or `(post Xn imm)`;
- an A64 shift is `(LSL n)`.

Any operand that holds a 32-bit field (an immediate, a branch target, or a
memory displacement such as `(m32 (reloc) () () 1)`) may instead be
`(reloc)`, a value known later. It matches only 32-bit forms and encodes as
zero. Each call to `x86` or `a64` returns the field of every immediate,
target and displacement operand as `(position offset width relative?)`. Here
`position` is the operand's index and `offset` is the byte offset within the
instruction, so a caller can record relocations and patch them in place.

An instruction is `(MNEMONIC operand...)`. A data fragment is
`(data byte...)`. Both encoders emit a fragment's bytes unchanged, and both
decoders produce one for anything no row describes.

### Row semantics

A row means what the manual's notation means, plus these stated rules and
nothing else.

**Both instruction sets**
- Rows are tried in file order, and the first row whose operands match
  encodes. So shorter forms and aliases (`CMP`, `MOV`, `MUL`) come first.
- When loading, each row is compiled with `eval` into a lambda specialized to
  it: its operand tests, literal bytes or bits, and field placement. No source
  file is generated.

**x86**
- Operand kinds are the SDM's (vol. 2, section 3.1.1.3): `r8` `r16` `r32`,
  `r/m8` `r/m16` `r/m32`, `m`, `imm8` `imm16` `imm32`, `rel8` `rel32`, and
  fixed registers.
- Opcode tokens are the SDM's:
  - hex bytes;
  - `+rb` `+rw` `+rd`;
  - `/r` and `/0` to `/7`;
  - `ib` `iw` `id`;
  - `cb` `cd`.
- The operand size is the widest register or memory operand. When `DX` is
  next to another fixed register it is an I/O port address, and doesn't count.
- A 16-bit operand size emits the `66` prefix; the SDM leaves that prefix
  implicit.
- An immediate narrower than the operand size is sign-extended to it.
- Two markers in the opcode column cover what the notation leaves out:
  - `o32` sets a 32-bit operand size where no operand shows one (`PUSH imm8`);
  - `u` marks a row's immediate as unsigned: an interrupt vector, a count or a
    port (`INT`, `RET iw`, `OUT imm8`).
- ModRM, SIB and displacement are canonical: no displacement when it is 0
  (except with EBP as base, which needs disp8), disp8 when it fits, otherwise
  disp32, and SIB only when an index or ESP base requires it.

**A64**
- Each row is 32 bits, and loading fails on any row that isn't.
- Fields are the diagram's names: `Rx` is 5 bits, `immN` is N bits, and any
  other field is written `name:width`.
- An operand names the field it fills:
  - `Xd` fills `Rd`;
  - `#imm12*8` is a byte offset stored as imm12 times 8;
  - an `s` prefix (`#simm7`) means the field is sign-extended;
  - `pc+simm26*4` is a branch target relative to this instruction;
  - `Xn|SP` reads register 31 as SP; otherwise register 31 is XZR/WZR.
- *Constrained unpredictable* encodings, such as `LDP` with `Rt == Rt2`, are
  not modeled. The encoder will emit them, and the clang check leaves them out.

### Unknown fragments

Decoding never fails, and never loses its place.

- **An instruction no row describes** decodes as `(data byte...)` holding
  exactly that instruction's bytes, and decoding continues at the next
  instruction.
  - A64 instructions are all 4 bytes, so an unknown word is
    `(data b0 b1 b2 b3)`.
  - x86 lengths vary, so they come from a second table, `x86-map.spec`. It
    holds the SDM's opcode maps (vol. 2, Appendix A: the one-byte map, the
    two-byte `0F` map, and the three-byte `0F 38` and `0F 3A` maps), each cell
    in the map's own operand notation (`Eb,Gb`, `Ev,Iz`, `Jb`, …). The groups
    whose length depends on ModRM.reg (`F6`/`F7 /0` take an immediate) are
    written as the map writes them.
  - The length decoder reads:
    - the legacy prefixes (`66`, `67` (16-bit ModRM forms), `F2`, `F3`, `F0`,
      segments);
    - the opcode;
    - the ModRM, SIB and displacement implied by the cell's `E`/`M`/`G`
      operands;
    - the immediate implied by its `I`/`J`/`O` operands at the current
      operand and address size.
    - VEX (`C4`/`C5`) and EVEX (`62`) are recognized in 32-bit mode by
      ModRM.mod = 11, as Appendix A states, and their lengths follow from the
      map they select.
  - Instructions the rows describe are delimited by the rows themselves. The
    map is consulted only for the rest.
- **Bytes that aren't instructions** (jump tables and literal pools in a text
  section) can't be told from code by the bytes alone. `x86-decode` and
  `a64-decode` take an optional list of `(offset length)` ranges, and decode
  each range as a single fragment. The Mach-O data-in-code table supplies
  these ranges (clang puts 9 jump tables in i386 `eval.o`'s `__text`).
  Without them, the fragments are still exact, but their boundaries won't
  match a disassembler that knew.
- Callers can write fragments too: `(x86 X 'data 0x0f 0x0b)` emits `UD2`
  without a row for it.

### Bidirectionality

Two properties, checked by `make check`:

1. **Bytes to instructions to bytes is the identity, for any input.** Encoding
   the decoder's output gives back exactly the bytes that were decoded.
   - Anything no row describes decodes as a `(data ...)` fragment (see
     Unknown fragments), which encodes as itself.
   - Where the decoded bytes are not the encoder's own choice, the decoder
     records that choice in the instruction:
     - another row for the same operands (`03 /r` for register to register,
       `81 /0 id` for a small immediate, `rel32` where `rel8` fits) becomes a
       final `(as 03 /r)`, naming that row's opcode column, and the encoder
       uses exactly that row;
     - a non-canonical ModRM (a disp8 of 0, a disp32 that fits in disp8, an
       unneeded SIB) becomes a sixth element of the memory operand listing
       the choices, e.g. `(m32 0 EBX () 1 (disp8))`.
   - A64 has no alternative encodings in this sense. Aliases decode as the
     alias, and the alias row's literal bits make it re-encode identically.
2. **Instructions to bytes to instructions is the identity, up to canonical
   form.** Decoding what the encoder produced gives back the instruction, with
   immediates in canonical form: signed unless the row is `u`, and A64 aliases
   as their alias.

The x86 decoder dispatches on the first opcode byte after any prefix, through
a 256-entry table built while loading. Without it, decoding the evaluator
would try every row for every instruction.

## Checks (`check/check.l`)

These replace `asm_x86` and `check/asm-x86.l`.

- **`asm_x86`**: for every row, the check generates sample operands and
  compares our bytes with `/usr/bin/clang -target i386-pc-linux`, using bytes
  read with `/usr/bin/objdump`.
  - Samples cover every register position, every addressing mode (SIB, no
    base, ESP base, EBP base with displacement 0, negative and 32-bit
    displacements), immediates at the edges of each width, and branches both
    ways in both widths. Branch targets are written as labels so that clang
    resolves them itself.
  - Every sample must also satisfy property 2.
  - The spike's version of this matched 536 of 536.
- **`asm_x86_eval`**: assembles the evaluator's real output and runs it
  through the decoder.
  - `./eval emit.l eval.l` is assembled with `/usr/bin/clang -target
    i386-apple-macos10.6`, and all of `__text` is decoded.
  - No `data` fragment may remain, so the table covers everything this
    compiler emits: 28 mnemonics today.
  - Re-encoding must give `__text` back byte for byte (property 1 on real
    code).
- **`asm_x86_foreign`**: decodes code we didn't write, mostly with
  instructions the rows don't describe.
  - `eval.c` is compiled by `/usr/bin/clang -target i386-apple-macos10.6 -O2`
    three times: plain (about 37,000 instructions, 105 mnemonics, with SSE,
    x87, `cmov` and multi-byte `nop`), with `-mavx2` (VEX), and with
    `-mavx512f` (EVEX).
  - `__text` is decoded with the data-in-code ranges as data.
  - Every instruction boundary must equal `/usr/bin/objdump`'s, so the length
    decoder never loses its place.
  - Re-encoding must give `__text` back byte for byte.
  - The share of instructions decoded as data is printed, not asserted.
- **`asm_x86_run`**: a program that uses calls, branches in both
  directions, push/pop and memory operands must print `A`…`Z` and exit 0,
  natively or in the VM (see Running generated code).
- **`demo_elf`, `demo_mach_o`, `demo_assembler`, `demo_call`**: each demo's
  expected output and exit status under `check/i386.l` (see Demos).
- **`asm_a64`**: the same sample comparison as `asm_x86`, with
  `/usr/bin/clang -target arm64-apple-macos`, including both properties. The
  spike matched 266 of 266.
- **`asm_a64_run`**: a recursive `fib` (pair store/load with pre- and
  post-index, `BL`, `B.LT`) and a 64-bit constant built with `MOVZ`/`MOVK`.
  It must print `fib(0)` … `fib(25)` and `0x123456789abcdef0`, natively or in
  the VM (see Running generated code).
- **`asm_a64_eval`**: decodes every word of `__text` in `eval.c` compiled
  by clang `-O2` for arm64 (on any host; see Host tools) and re-encodes it,
  with the data-in-code ranges as data. The result must be
  identical (property 1 on code clang wrote). Coverage, the share of words
  some row matched, is printed but not asserted until the A64 backend sets
  what has to be covered.

## Demos

`assembler.k`, `test-call.k`, `test-elf.l` and `test-mach-o.l` are ported to
`(x86 X 'MNEMONIC ...)`. They then run on any host. Their code runs
natively where the host can execute it, and in a VM elsewhere (see Running
generated code).

**`check/i386.l`, the i386 VM environment.** It is assembled by the x86
table and written into a multiboot image by Maru, with no linker, as in the
spike. In 32-bit protected mode it provides:
- **Loading.** A Linux i386 ELF (each `PT_LOAD` copied to its `p_vaddr`,
  entry `e_entry`); an i386 Mach-O (each `LC_SEGMENT` to its `vmaddr`, entry
  the `eip` of `LC_UNIXTHREAD`); or a raw code buffer, called at offset 0 with
  cdecl arguments, as `buffer-call` and `native-call` do in-process.
  - Maru appends the payload to the image, and the environment copies it into
    place.
- **System calls through `int 0x80`.** `write(1, buf, len)` goes to COM1, and
  `exit(status)` leaves through `isa-debug-exit`. The ELF uses the Linux
  convention (`EAX`, then `EBX`, `ECX`, `EDX`); the Mach-O uses the BSD one
  (arguments on the stack above a return slot). The loader chooses by format.
- **Externals.** `putchar` and a `printf` that handles `%d` and `%s`, at
  addresses the demos resolve through an `*externs*` list instead of the
  host's `subr` table.
- **Results.** A raw buffer's return value is written to COM1 as
  `=> <decimal>`.

**What each demo must produce** (checked from the COM1 output and the qemu
exit status):

| Demo | Expected |
|---|---|
| `test-elf.l` | Its `a.out` prints `Hello, world`. Its raw program prints `Now run ./a.out for a friendly greeting` |
| `test-mach-o.l` | The same two lines, from its Mach-O `a.out` and its raw program |
| `assembler.k` | Its first program prints `integer 42!` then `Hello, world`. Its Mach-O and raw programs print as above |
| `test-call.k` | Prints `ABCDEFGHIJKLMNOPQRSTUVWXYZ` and `=> 10` (the code returns `putchar`'s last result) |

In all of them, every `exit` must be `exit(0)`.

Changes to the demos themselves:
- `assembler.k` stops calling `(exit 0)` after its first program, and the
  `NOTREACHED` line goes, so its other two programs are exercised.
- Its relocations use `(reloc)` and the returned field offsets, not
  relocation objects passed in place of numbers.
- `test-call.k` prints its listing with `x86-decode`. The check also
  reassembles that listing and requires the same bytes.
- `a.out` files written by `test-elf.l` and `test-mach-o.l` must also
  disassemble under `/usr/bin/objdump` to the instructions `x86-decode`
  reports.

**Byte-for-byte equivalence with the old encoder** is verified once, while
porting, not kept as a check: before `asm-x86.k` is removed, each demo's
output is recorded with it, and the ported demo must produce the same bytes.

The Makefile targets `test-elf`, `test-mach-o` and `test-assembler` run with
`./eval` and the environment, no longer with `eval32`. CLAUDE.md's "Known not
to work" list loses these demos.

## Running generated code

Every check that runs generated code (`asm_x86_run`, `asm_a64_run` and the
demos) does so on every host: natively when the host can execute that code,
and in a qemu VM otherwise. Each check compares a transcript (the text
written, then the exit status), and both ways of running must produce the
same transcript, so the expected values don't depend on the host.

| Code | Native when | Otherwise |
|---|---|---|
| i386, Linux ELF or raw buffer | the host runs Linux on x86 or x86-64 (the kernel runs static i386 ELF and serves `int 0x80`) | `qemu-system-i386` with `check/i386.l` |
| i386 Mach-O (`test-mach-o.l`, `assembler.k`) | never: no current OS loads it | `qemu-system-i386` with `check/i386.l` |
| A64 | the host is arm64: macOS or Linux | `qemu-system-aarch64 -M virt` with `check/a64.l` |

Native runs use executables that Maru writes itself (`exe.l`, below), with no
compiler, linker or `codesign`.

**Native i386.**
- A raw buffer is wrapped by Maru in a static i386 ELF, with no linker and no
  32-bit libc. That ELF supplies `putchar`, `printf` and the result line
  through Linux `write` and `exit`.
- The demos' Linux ELF files run as written.
- A kernel without IA-32 emulation fails the check with that reason. Use
  `ASM_RUN=vm` instead.

**Native A64.**
- On macOS, Maru writes an arm64 Mach-O executable and signs it itself (see
  `exe.l`).
- On arm64 Linux, it writes a static aarch64 ELF.
- System calls:
  - macOS: `svc #0x80` with the number in `x16` (`write` 4, `exit` 1);
  - Linux: `svc #0` with the number in `x8` (`write` 64, `exit` 93).
- `putchar` and the result line are table-assembled code inside the
  executable.

**`exe.l`, writing executables.** This is toolchain code, not check code: the
roadmap's native backend needs it too.
- **Static i386 ELF:** one `PT_LOAD`, the entry point, Linux `int 0x80`.
- **Static aarch64 ELF:** the same shape.
- **arm64 Mach-O for macOS.** The probe in the spike established what the
  kernel accepts on this Mac:
  - Five load commands are required: `__PAGEZERO`, `__TEXT` with `__text`,
    `__LINKEDIT`, `LC_LOAD_DYLINKER` (`/usr/lib/dyld`) and `LC_MAIN`. No
    `libSystem`, symbol table or build version is needed.
  - The kernel kills a fully static Mach-O (`LC_UNIXTHREAD`, no `dyld`) even
    when it is signed, so `dyld` stays.
  - The kernel kills unsigned arm64 code. `exe.l` therefore appends an
    ad-hoc signature itself: `LC_CODE_SIGNATURE` pointing to a SuperBlob
    holding one CodeDirectory. That CodeDirectory has version `0x20400`, the
    `CS_ADHOC` flag, SHA-256 hashes of each 4 KB page up to the signature,
    and the executable segment flagged as the main binary. The probe's
    self-signed file ran (`hello`, exit 42), and `codesign -dv` reports
    `Signature=adhoc`.
  - This needs SHA-256 written in Maru, about 40 lines.

**`check/a64.l`, the A64 VM environment.**
- Maru writes an ELF64 with one segment at `0x40080000`, which `-kernel`
  loads.
- Output goes through the PL011 UART at `0x09000000`.
- Exit is semihosting `SYS_EXIT` (`HLT #0xF000`, with `-semihosting`), which
  becomes qemu's exit status.
- Instructions the A64 rows lack, such as `HLT`, are written as data
  fragments.

**Run programs.**
- `asm_x86_run` prints `A`…`Z` through `putchar`.
- `asm_a64_run` prints `fib(0)` … `fib(25)` and the `MOVZ`/`MOVK` constant
  in hex. The expected text is computed by Maru.

**Host tools for the other checks.**
- The comparison and decoding checks need `clang` (any build with the x86
  and AArch64 targets) and `llvm-objdump`. On macOS these are `/usr/bin/clang`
  and `/usr/bin/objdump`.
- `emit.l` writes Mach-O-flavored assembly. clang assembles it for
  `i386-apple-macos10.6` on any host, since assembling needs no SDK.
- Compiling `eval.c` as test input needs that target's C headers: the macOS
  SDK on macOS. On Linux, use `i386-pc-linux` and `aarch64-linux-gnu`, which
  need 32-bit and aarch64 libc headers (Debian: `gcc-multilib`,
  `libc6-dev-arm64-cross`).
- Data-in-code ranges are Mach-O only. ELF test input is built with
  `-fno-jump-tables` instead.

**Forcing a runner.** `ASM_RUN=vm make check` puts everything in the VMs, and
`ASM_RUN=native` fails where native isn't possible. This way either path can
be exercised on any host. A missing `qemu-system-*` for the VM an
architecture needs fails the check, like any other missing tool.

### Test hosts

| Host | Native | VM | Missing (as of 2026-10-14) |
|---|---|---|---|
| This Mac (Apple Silicon, macOS) | A64 (signed Mach-O, JIT) | i386 | none |
| `ndn.lan` (AMD Ryzen 7 7800X3D, Ubuntu, Linux 6.8 x86_64, `CONFIG_IA32_EMULATION=y`) | i386 (static ELF) | A64 | `qemu-system-aarch64` (package `qemu-system-arm`); aarch64 libc headers (`libc6-dev-arm64-cross`) for `asm_a64_eval` |

`jit_run` on `ndn.lan` also needs x86-64 rows (open question 2).

## Running generated code in-process (JIT)

The encoders write into any buffer, so generated code can also run inside
the evaluator through `native-call`, with no file.

**Today.** `eval.c`'s `native-call` makes the garbage-collected object
holding the code executable with `mprotect`. That has two problems:
- every other object on those pages becomes executable too;
- macOS on Apple Silicon refuses it (`mprotect: Permission denied`).

**Change.** `eval.c` gets a code region, separate from the heap:
- **Allocation.** On macOS, `mmap` with `MAP_JIT`. Elsewhere, an ordinary
  `mmap` that is readable, writable and executable.
- **Writing.** On macOS each thread must make the region writable before
  writing code into it and executable afterwards
  (`pthread_jit_write_protect_np`). Elsewhere this is a no-op.
- **Before calling.** `__builtin___clear_cache` over the written range. ARM
  needs it on every OS, because its instruction and data caches aren't
  coherent. On x86 it compiles to nothing.
- **Interface.** `native-call` stays as it is; it calls with one argument,
  a pointer to the argument array. Maru code that wants to run what it
  assembled asks for code space and copies or assembles into it, in place of
  `buffer-call`'s heap buffer.

The `cc`-built `eval` is ad-hoc signed by the linker without the hardened
runtime, so it needs no JIT entitlement. A probe on this Mac ran the A64
table's `fib` and `big` words from a `MAP_JIT` region (`fib(25) = 75025`,
`0x123456789abcdef0`), and confirmed `mprotect` on heap memory is refused.

Systems that forbid writable-and-executable memory outright (OpenBSD, SELinux
denying `execmem`) would need two mappings of the same pages, one writable and
one executable. That is not done until such a host matters.

**Check `jit_run`.** The `asm_a64_run` or `asm_x86_run` program for the
host's own architecture is assembled into the code region, run through
`native-call`, and must produce the same transcript as the executable does.
In-process code must match the evaluator's own mode:
- an arm64 `eval` runs A64 code;
- an x86-64 `eval` can't call the i386 table's 32-bit code. Covering x86-64
  hosts such as an AMD Linux box needs x86-64 rows (REX prefixes and 64-bit
  operand size in `x86.spec`), which is open question 2.

Until then, `jit_run` fails on x86-64 hosts, as a missing tool would.

The C change counts toward the budget until `emit.l` generates the evaluator
(about 30 lines).

## Removed

- `gen-asm-x86.k`
- `dsm-x86.k`
- `asm-common.k`
- `check/asm-x86.l`
- the `asm-x86.k` Makefile rule, its `check` dependency and its `.gitignore`
  entry
- the CLAUDE.md text describing them

## Line budget

Each step gets its own `check/lines` entry.

| Step | Lines |
|---|---|
| Removed (above) | about −1,060 |
| Spike sizes (x86 rows, grammar, interpreter, compiler) | about 360 |
| A64 rows, grammar, interpreter | about 200 |
| x86 opcode maps (Appendix A grids: about 16 lines per 256-entry map) and length decoder | about 150 |
| Checks | about 150 |
| `check/i386.l` (loader, `int 0x80`, `putchar`, `printf`) | about 150 |
| `check/a64.l` (UART, semihosting exit) | about 50 |
| `exe.l` (static i386 and aarch64 ELF, signed arm64 Mach-O, SHA-256) | about 150 |
| Ported demos | about the same as today |

The x86 table grows to cover the evaluator's 28 mnemonics. The net change is
clearly negative.

## Open questions

1. **Where the `[EBP + 0]` regression is pinned.** Today's `asm-x86.k`
   encodes `[EBP + 0]` as `8b 05` (disp32, address bytes missing); clang gives
   `8b 45 00`. The new `asm_x86` samples cover it, so the replacement fixes
   it. Should it also go into today's `check/asm-x86.l` first, as a failing
   case, before the switch?
2. **x86-64.** Should `x86.spec` gain 64-bit mode in this spec? That means
   REX prefixes, `r64`/`r/m64` and RIP-relative addressing, with the same
   checks. It's needed for `jit_run`, and for native execution of
   evaluator-mode code, on x86-64 hosts. Otherwise it waits for an x86-64
   backend.
