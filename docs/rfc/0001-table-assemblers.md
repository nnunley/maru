# RFC 0001: Table-Driven Encoders for x86, x86-64 and A64, and an In-Process Code Region

**Status:** PUBLISHED
**Category:** Standards-Track
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies the instruction encoders Maru's native back ends
will emit through, and the means to run what they emit inside the
evaluator. Each instruction set is described once, as rows in its vendor
manual's own notation, and the rows are the encoder. The rows cover every
instruction form needed to compile Maru's typed IR (`ir2`), including
floating point and SIMD, for 32-bit x86, x86-64 and A64. Both evaluators
gain C-ABI foreign calls, and an executable code region written in Maru on
top of them, so compiled code runs in-process on arm64 and, under Rosetta,
x86-64. It is written for whoever implements the encoders and for whoever
designs the back ends that use them.

## Motivation

Maru's typed compiler reaches machine code only through `ir-gen-c.k` and a C
compiler. Its one native encoder, `asm-x86.k`, is generated from C
preprocessor macros (`gen-asm-x86.k`), covers 32-bit x86 only, and has no
floating point. At the time of writing (October 2026):

- The `refactor-main` arm64 back-end drafts emit assembly that does not
  assemble, because they copied x86 assumptions (stack arguments, global
  addressing) into arm64.
- The spike behind this design (`spike/asm/`, branch `table-asm`) encodes
  from vendor-notation rows: its A64 rows match `clang` on 266 of 266 sample
  instructions and round-trip cleanly; its x86 rows match `clang` on 536 of
  536, with two round-trip failures from unsigned fields encoded as signed.
  It has no floating point or SIMD on either set.
- `eval2`, on which the typed compiler runs, cannot call C: its `subr` and
  `ffcall` are commented out (`eval2.c` lines 1666–1760 and 2794 on), and its
  byte accessors were dropped. `eval`'s `native-call` makes heap memory
  executable with `mprotect`, which macOS on Apple Silicon refuses.

So no Maru-compiled code runs without a C compiler, and nothing Maru encodes
runs on this Mac. This document provides the encoders and the code region
the native back ends need; the back ends and their architecture-neutral
intent layer are a separate specification that builds on this one.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **ISA** — one of three instruction sets: `x86` (32-bit x86, protected
  mode), `x64` (x86-64, 64-bit mode) and `arm64` (Armv8-A A64), named as the
  instruction set's files are.
- **row** — one line of a `.spec` file: an encoding in the vendor manual's
  notation, then the instruction it encodes with its operand kinds.
- **form** — a mnemonic with a list of operand kinds, such as
  `ADD r/m32, imm8` or `FADD Vd.4S, Vn.4S, Vm.4S`. A row encodes one form.
- **encoder** — the code that encodes an instruction with a row.
- **field** — the bits of an encoding that hold one operand's value.
- **placeholder** — the operand `(reloc)`, standing for a value fixed later.
- **assembly buffer** — the growable byte buffer an encode writes to, with
  the address its first byte will have.
- **code region** — memory that holds executable code, allocated and
  switched between writable and executable by the evaluator.
- **host evaluator** — `eval` or `eval2` built for the machine it runs on;
  a **cross evaluator** is one built for another architecture the host can
  run, under `bin/<arch>/`.
- **coverage table** — the list of forms each ISA needs so that every
  `ir2` operation on every IR type, and its SIMD counterpart, can be
  compiled.

## Specification

This document defines the row notation and its meaning for three ISAs; the
encoders and their single interface; field patching; decoding of
row-described instructions; the coverage table; C-ABI foreign calls in
`eval2`; and the code region. It does NOT define how `ir2` operations become
instruction sequences (the intent layer, owned by the back-end
specification); decoding of code no row describes, length decoding and
foreign-code checks (the disassembler specification); writing executables
or running code in virtual machines (the running-code specification); or
moving `emit.l` and the demos onto these encoders (the migration
specification).

**The rows are the encoder.** Each form is written once, in its manual's
notation, and nothing else states its encoding: no hand-written encoder
function, field layout or opcode constant exists outside the rows.

**One interface for every ISA.** A caller never branches on the ISA to
encode, patch or query; the ISA is an argument.

**Nothing above the encoder sees bits.** Field positions, scaling, split
fields and sign handling stay inside the rows; callers deal in operands and
values.

**Run what you encode.** Every encoding the coverage table requires is
also executed somewhere in `make check` on a host that can run it.

### Files

| File | Contents | Counted |
|---|---|---|
| `asm-table.l` | The interface (`asm`, `asm-forms`, `asm-patch`, `asm-decode` …), rows indexed by mnemonic, the assembly buffer | yes |
| `x86.spec` | x86 and x64 rows: SDM vol. 2 opcode column, 64-bit and compat/legacy validity columns, instruction column | yes |
| `x86.g`, `x86.g.l` | Grammar reading `x86.spec`; its compiled parser | yes; derived |
| `asm-x86.l` | x86/x64 operand kinds, operand size, ModRM/SIB, REX, VEX, operand slots, encoder and decoder (indexed by opcode byte) | yes |
| `arm64.spec` | A64 rows: encoding diagram from bit 31 to 0, then assembler syntax | yes |
| `arm64.g`, `arm64.g.l` | As for x86 | yes; derived |
| `asm-arm64.l` | A64 fields, arrangements, operand binding, encoder and decoder | yes |
| `asm-coverage.spec` | The coverage table | yes |
| `code-region.l` | The code region, in Maru, over `subr` | yes |
| `eval2.c` | `subr`, `ffcall`, `subr-name`, `byte-at`, `set-byte-at` restored and extended | yes |

The `lines` check MUST count `.spec` files. [R-spec-counted] Rows are code;
without this they escape the budget.

```maru-check @R-spec-counted
lines
```

### Data model

```
RECORD Row:
    isa         : ISA
    mnemonic    : Symbol
    kinds       : List of OperandKind   -- e.g. (r/m32 imm8), (Vd.4S Vn.4S Vm.4S)
    encoding    : the row's opcode column or bit diagram, parsed
    modes       : Set of Mode           -- x86.spec rows: valid in x64, in x86, or both
    unsigned    : Boolean               -- the row's immediate is unsigned (`u` marker)

RECORD AsmBuffer:
    bytes       : growable byte array
    origin      : Integer               -- address the first byte will have
    pc          : Integer               -- origin + bytes written

RECORD FieldReport:                     -- one per placeholder or target operand
    position    : Integer               -- the operand's index in the instruction
    offset      : Integer               -- the instruction's byte offset in the buffer
    row         : Row                   -- the row that encoded it
    instruction : Instruction           -- as given, placeholders included

ENUM ISA:
    x86         -- 32-bit protected mode, `x86.spec` rows valid in 32-bit mode
    x64         -- 64-bit mode, `x86.spec` rows valid in 64-bit mode
    arm64       -- A64, `arm64.spec`
```

**Instruction syntax.** An instruction is `(MNEMONIC operand...)`. Registers
are their names (`EAX`, `R12D`, `XMM3`, `YMM15`, `X0`, `W7`, `SP`, `XZR`,
`S0`, `D31`, `Q2`). An A64 vector register carries its arrangement:
`(V 3 4S)` is `V3.4S` (Maru reads `4S` as `4` and `S`, so this is the list
`(V 3 4 S)`: register, lane count, element size), and `(V 3 S 1)` is lane
`V3.S[1]`. Immediates and branch
targets are integers; targets are absolute addresses. x86 memory is
`(mN disp base index scale)` with `N` the access size (`m` for any, as for
`LEA`), and `RIP` as base on x64 meaning RIP-relative; A64 memory is
`(off Xn imm)`, `(pre Xn imm)`, `(post Xn imm)` or `(reg Xn Xm extend
amount)`; an A64 shift or extension is `(LSL n)`, `(SXTW n)` and so on.
`(data byte...)` is a fragment emitted unchanged on every ISA.

### Row semantics

A row means what its manual's notation means, plus the rules below and
nothing else.

**Every ISA**
- Rows are read when the instruction set's file loads and interpreted at
  each encode. No source file is generated. (Compiling each row into a
  specialised encoder at load is left for when encoding speed matters.)
- Of the rows whose form matches an instruction's operands, the one giving
  the shortest encoding encodes it, and among equals the first in file
  order; with an open placeholder, the one with the widest field. File
  order only orders equivalent encodings (aliases before what they alias);
  it never decides which operation an instruction is.
- An immediate is signed unless its row is marked `u`. A negative value for
  an unsigned field, or any value outside a field's range, is an error, never
  truncated. [R-field-range]

```maru-check @R-field-range
asm_rows_x86
asm_rows_arm64
```

**x86 and x64** (`x86.spec`)
- Operand kinds are the SDM's (vol. 2, 3.1.1.3), plus `r64`, `r/m64`,
  `m64`, `imm64`, `xmm`, `xmm/m32`, `xmm/m64`, `xmm/m128`, `ymm`,
  `ymm/m256`.
- Opcode tokens are the SDM's: hex bytes, `+rb` `+rw` `+rd`, `/r`, `/0`–`/7`,
  `ib` `iw` `id` `io`, `cb` `cd`, `REX.W +`, `REX +`, the mandatory prefixes
  `66`, `F2`, `F3` written before `0F`, and the VEX prefix written as the SDM
  writes it (`VEX.256.66.0F38.W0 58 /r`), with `VEX.vvvv` taken from the
  operand the row names `vvvv`.
- Each row carries the SDM's two validity columns (`V`, `I`, `NE`); an
  encoder for `x86` uses rows valid in 32-bit mode and an encoder for `x64`
  rows valid in 64-bit mode.
- The operand size is the widest register or memory operand; 16-bit emits
  `66`. An immediate narrower than the operand size is sign-extended.
- The row's columns are tab-separated: opcode, instruction, and the two
  validity columns.
- `o32` sets a 32-bit operand size where no operand shows one (64-bit in
  64-bit mode, where such rows default to 64 bits); `u` marks an unsigned
  immediate (`INT imm8`, `RET imm16`, `OUT imm8`, shift counts, shuffle and
  compare selectors).
- An immediate is read modulo its row's operand size before matching:
  `ADD EAX, 0xFFFFFFFF` is `ADD EAX, -1`, as the processor sees it.
  Displacements and branch offsets are signed only.
- `c` marks two sources that commute, which the encoder swaps when that
  allows the two-byte VEX prefix; `cp` marks a compare whose sources commute
  when its predicate is symmetric (imm8 & 3 is 0 or 3).
- Where an operand goes (ModRM.reg, ModRM.rm, VEX.vvvv, or the opcode's low
  bits) follows from the row: under a `/digit` registers go to rm (in a VEX
  row the first to vvvv); under `/r` the first register goes to reg, a VEX
  row's second register ahead of the r/m operand to vvvv, and others to rm.
- A memory-only operand (`m`, `m32` …) never takes ModRM mod 11; that
  encoding belongs to another row.
- ModRM, SIB and displacement are canonical: no displacement when 0 (except
  an `EBP`/`RBP`/`R13` base, which takes disp8 0), disp8 when it fits,
  otherwise disp32; SIB only when an index or an `ESP`/`RSP`/`R12` base
  requires it; on x64 a bare 32-bit address takes a SIB with no base.
- REX is emitted when the row asks (`REX.W`), when a register is R8–R15 or
  XMM8–XMM15, or when `SPL` `BPL` `SIL` `DIL` appear; `AH` `CH` `DH` `BH`
  cannot be encoded with REX, and such a match fails. Rows the SDM marks
  `d64`/`f64` need no `REX.W`.
- VEX replaces REX: the two-byte `C5` form when `VEX.X`, `VEX.B` and `VEX.W`
  are zero and the map is `0F`, otherwise the three-byte `C4` form.

**A64** (`arm64.spec`)
- Each row is 32 bits; loading fails on any row that is not.
- Fields are the diagram's names: `Rx` is 5 bits, `immN` N bits, any other
  field `name:width`.
- An operand names the field it fills: `Xd` fills `Rd`; `#imm12*8` is a byte
  offset stored divided by 8; an `s` prefix (`#simm7`) sign-extends;
  `pc+simm26*4` is a branch target relative to the instruction; `Xn|SP` reads
  register 31 as `SP`, otherwise it is `XZR`/`WZR`.
- A field split across the diagram (`immhi:immlo` in `ADR`/`ADRP`) is one
  operand value, divided between its parts high bits first.
- Vector arrangements (`8B` `16B` `4H` `8H` `2S` `4S` `1D` `2D`) set the
  diagram's `Q` and `size` bits as the Arm ARM's arrangement table states;
  the logical-immediate (`N:immr:imms`) and floating-point-immediate (`imm8`)
  encodings are computed from the value as the Arm ARM's pseudocode
  defines.
- Constrained-unpredictable encodings (such as `LDP` with `Rt == Rt2`) are
  not modelled.

### Interface

```
(asm isa buffer instruction)          => list of FieldReport
(asm-attempt isa buffer instruction)  => list of FieldReport | (error . message)
(asm-forms isa mnemonic)              => list of (kinds row)
(asm-patch isa buffer report value)   => buffer
(asm-patch-attempt isa buffer report value) => buffer | (error . message)
(asm-field-range isa row position pc [instruction]) => (lo hi step) | ()
(asm-decode isa bytes pc)             => (instruction . length) | ()
(asm-parse-form isa text)             => (mnemonic kinds) | ()
(asm-buffer origin)                   => AsmBuffer
```

The `-attempt` forms return an error instead of raising it and leave the
buffer unchanged; Maru cannot catch an error, so callers that need to survive a
refusal (the checks, a back end trying alternatives) use them. `asm-decode`'s
`bytes` is an array whose first element is the instruction's first byte.

`asm` MUST be the only encoding entry point, and it MUST behave the same way
for every ISA: same buffer, same instruction syntax, same reports and
errors. [R-one-entry] `asm-forms` lists the forms a mnemonic has on an ISA,
so that a table naming forms (the back ends' intent tables) can be checked
against the rows when it loads.

```maru-check @R-one-entry
asm_interface
```

A placeholder matches any row whose field can hold a value fixed later;
among several, the one with the widest field is chosen unless the
instruction says otherwise (`(reloc 8)` asks for an 8-bit field). `asm`
returns a report for every placeholder and every branch-target operand.
`asm-patch` re-runs the reporting row's field placement for the final value
(bit positions, scale, split fields, range, and PC-relativity from the
report's instruction offset) and writes the result over the instruction in
the buffer. For every row with a field a placeholder can stand for, encoding
with a placeholder and then patching MUST produce the same bytes as that
row encodes for the final value directly. [R-patch] (A patch never changes
an instruction's length; a shorter row the value would otherwise choose is
not the comparison.) On x86, placeholders stand for immediates, branch
targets and RIP-relative displacements; a base-plus-displacement address
takes its final value when encoded, since its canonical width depends on
the value.

```maru-check @R-patch
asm_patch
```

`asm-decode` decodes an instruction some row describes, and returns `()`
for anything else; decoding what no row describes is the disassembler
specification's. Decoding what `asm` produced MUST give back the
instruction, with immediates in canonical form (signed unless the row is
`u`) and A64 aliases as their alias. [R-round-trip]

```maru-check @R-round-trip
asm_rows_x86
asm_rows_x64
asm_rows_arm64
```

### Coverage

`asm-coverage.spec` lists, for each ISA, forms in that ISA's row notation,
each with the classes it serves: `OP.TYPE` or `cast.FROM.TO`, a type being
`s8 u8 s16 u16 s32 u32 s64 u64 f32 f64` or a group (`i32`: any value held in
a 32-bit register; `i64`; `s32`; `u32`). The needs are not listed by
hand: the check reads `ir2.k`'s own declarations (`define-unary-arithmetic`
and the rest, with their type predicates) and requires every
(operation, type) pair, every cast, load and store, and control, to be named
by some class. A need met by a sequence names the instructions the sequence
uses (unsigned 64-bit to float on x64 is a shift and `CVTSI2SS`); one met by
a runtime routine names `CALL` (64-bit divide on 32-bit x86, float `mod`).
The forms needed are those that compile:

1. every `ir2` operation (`add` `sub` `mul` `div` `mod` `neg` `com` `not`
   `bitand` `bitor` `bitxor` `shl` `shr` `eq` `ne` `lt` `le` `ge` `gt`,
   loads and stores through `indir`/`set-indir`/`member`, `cast`,
   `addressof`, `call`, `return`, branches for `if`/`while`/`logand`/`logor`)
   on every IR type: integers of 8, 16, 32 and 64 bits, signed and unsigned,
   pointers, `float` and `double`;
2. the packed counterpart of each operation in (1) that the ISA's vector
   extension has, at each vector width in scope, plus broadcast, shuffle and
   permute, lane insert and extract, and horizontal add or reduce;
3. what calls and frames need: the calling convention's argument and return
   registers, stack adjustment, pair store and load (A64), push and pop
   (x86), and indirect calls.

The vector extensions in scope are:

| ISA | Scalar | Vector |
|---|---|---|
| `arm64` | integer, FP (`S`, `D`) | Advanced SIMD (NEON), 64- and 128-bit, all arrangements |
| `x64` | integer, scalar SSE/SSE2 | SSE through SSE4.1 (128-bit); AVX and AVX2 (128- and 256-bit, VEX) |
| `x86` | integer, scalar SSE/SSE2 | none |

Every form in the coverage table MUST have a row, every (operation, type)
need `ir2.k` declares MUST be named by some form's classes, and every row's
sample encodings MUST equal what `clang` produces for the same instruction:
`clang -target arm64-apple-macos` for `arm64`, `-target x86_64-pc-linux` for `x64`,
`-target i386-pc-linux` for `x86`. [R-coverage] Samples cover every register
position, including R8–R15, XMM8–XMM15 and register 31 in both meanings;
every addressing mode; immediates at the edges of each width; branches in
both directions; and every vector arrangement.

```maru-check @R-coverage
asm_coverage
asm_rows_x86
asm_rows_x64
asm_rows_arm64
```

### Work order

The ISAs are built in this order, each complete with its checks before the
next starts: `arm64` scalar integer and FP; `arm64` NEON; `x64` scalar integer
and FP; `x64` SSE; `x64` AVX2; `x86`. A64 comes first because it runs
natively on the development machine (an Apple M3).

### Foreign calls in `eval2`

`eval2` MUST provide `eval`'s `subr` and `subr-name` with the same signature
letters and semantics, by restoring the commented-out code in `eval2.c`,
and two extensions in both evaluators: [R-subr]

- `subr` accepts an address (an integer) in place of a symbol name;
- a signature can end with `>` and a return letter (`i` `j` `k` `l` `p` `f`
  `d`), and `ffcall` then returns that type (a `double` for `f` and `d`);
  without it, the return is an integer as today.

`eval2` MUST also provide `byte-at` and `set-byte-at` on raw addresses, as
`eval` does.

```maru-check @R-subr
eval2_subr
```

### The code region

`code-region.l` is Maru. It allocates, writes and runs code through `subr`
calls to libc, with constants from `osdefs`. The platform-specific calls
(`pthread_jit_write_protect_np`, `sys_icache_invalidate`, `__clear_cache`)
are looked up with `dlsym` and skipped where the system lacks them, so the
file has no platform branches:

```
FUNCTION code-region-allocate(size) -> region:       -- region = (base size next)
    -- MAP_JIT is 0 where osdefs finds no such flag
    RETURN mmap(0, size, PROT_READ|PROT_WRITE|PROT_EXEC,
                MAP_PRIVATE|MAP_ANON|MAP_JIT, -1, 0)
           or error "code region: mmap failed"

FUNCTION code-region-next(region) -> address:     -- next free address, 16-aligned
FUNCTION code-region-fits?(region, buffer) -> boolean

FUNCTION code-region-install(region, buffer) -> address:
    -- buffer was assembled with origin = the address it will occupy
    IF buffer.origin is not inside region with room for its bytes:
        error "code region: buffer origin outside region"
    pthread_jit_write_protect_np(0)          -- macOS only; no-op elsewhere
    copy buffer.bytes to buffer.origin with set-byte-at
    pthread_jit_write_protect_np(1)
    sys_icache_invalidate / __clear_cache over the range
    RETURN buffer.origin

FUNCTION code-callable(address, signature) -> subr:
    RETURN subr(address, signature)              -- e.g. "dd>d" for a double function
```

`osdefs` gains `PROT_READ`, `PROT_WRITE`, `PROT_EXEC`, `MAP_PRIVATE`,
`MAP_ANON` and, on macOS, `MAP_JIT`.

On every evaluator the host can run, a function assembled into the code
region and made callable with `subr` MUST return the right value through the
C ABI, for integer, pointer, `float` and `double` arguments and results, and
a recursive function calling itself and a C function (`write`, through an
address it is given) MUST produce the expected output. [R-jit-run] The
`arm64` case runs on an arm64 evaluator; the `x64` case on an x86-64 evaluator, natively on x86-64 Linux
and under Rosetta on macOS.

```maru-check @R-jit-run
jit_run
```

### Cross evaluators

On arm64 macOS, `make` MUST build `bin/x86_64/eval` and `bin/x86_64/eval2`
with `-arch x86_64` and the same flags as the host evaluators, when Rosetta
is installed. [R-cross-eval] `jit_run` runs once with each evaluator found:
the host's `./eval2`, then each `bin/<arch>/eval2`. The host's own
evaluators stay `./eval` and `./eval2`.

```maru-check @R-cross-eval
jit_run
```

### Configuration

| Key | Type | Default | Description |
|---|---|---|---|
| `code-region-size` | Integer | `1048576` | Bytes per code region; a region that fills is followed by another |

One megabyte holds the coverage samples and the run checks many times over;
a back end compiling the whole runtime allocates further regions as needed.

### Errors

| Error | Example | Recovery |
|---|---|---|
| No row matches | `(asm 'arm64 b '(ADD X0 W1 3))` | Error naming the ISA, the instruction and the forms `asm-forms` lists for the mnemonic; nothing is written |
| Field out of range | `(INT -5)`; a branch farther than `imm19` reaches | No row matches: the error above; nothing is written |
| Patch value out of range | patching an 8-bit placeholder with 300 | Error naming the value, the operand and the instruction; the buffer is unchanged |
| Row invalid at load | an A64 row not 32 bits; an unknown opcode token | Loading stops with an error naming the row, or the grammar's parse failure |
| Symbol not found | `(subr "no_such_fn" "i")` | Fatal, as `eval`'s `subr` is |
| `mmap` fails | out of address space | Error from `code-region-allocate`; no region is returned |
| Buffer outside region | origin not inside the region | Error; nothing is copied |

## Out of Scope

**The intent layer.** The mapping from `ir2` operations to instruction
sequences, per ISA, as data. Excluded because it is the back ends' design.
Extension point: `asm-forms`, against which intent tables are checked, and
the coverage table, which they draw from.

**Disassembly of code no row describes.** Unknown-fragment decoding, the x86
opcode-map length decoder (with VEX/EVEX), the bytes-to-bytes identity on
foreign code, and the `asm_x86_eval`/`asm_x86_foreign`/`asm_arm64_eval`
checks. Extension point: `asm-decode`, which returns `()` today where that
specification will return a `(data ...)` fragment. Source text:
`docs/superpowers/specs/2026-10-14-table-driven-assemblers-design.md`.

**Running code outside the evaluator.** `exe.l` (static ELF, self-signed
Mach-O), the i386, x86-64 and A64 qemu environments, and `ASM_RUN`.
Extension point: the assembly buffer, which those writers consume. Same
source text.

**Migrating the 32-bit users.** Moving `emit.l`'s callers and the four demos
onto `asm 'x86`, and removing `gen-asm-x86.k`, `asm-x86.k`, `dsm-x86.k`,
`asm-common.k`. 32-bit x86 remains a target throughout. Extension point: the
`x86` ISA, which covers `emit.l`'s 28 mnemonics as part of the coverage
table. Same source text.

**Correct sequences for what no instruction does alone.** On x64,
unsigned 64-bit to float and back are sequences around the signed
conversions; on 32-bit x86, 64-bit arithmetic is register pairs and 64-bit
divide a runtime call. The coverage table names the parts; choosing and
checking the sequences is the back end's, which MUST test unsigned 64-bit
conversions at and above 2^63 on every instruction set. Extension point: the
intent layer.

**Placeholders in base-plus-displacement addresses on x86.** Their canonical
width depends on the value. Extension point: a `(reloc 32)` form fixing the
width, through `asm-field-range` and `asm-patch`.

**AVX-512, SVE and SME.** EVEX encoding, masks and 512-bit vectors on x86-64;
scalable vectors on A64. Excluded because neither development host can run
SVE or SME (the M3 has neither), and AVX-512 runs only on `ndn.lan`.
Extension point: new rows and tokens in `x86.spec` and `arm64.spec`, and new
columns in the coverage table.

**Packed SIMD on 32-bit x86.** Extension point: `x86`-valid SSE rows, which
the `x64` rows mostly are already.

**Systems that forbid writable-and-executable mappings** (OpenBSD, SELinux
denying `execmem`), which need two mappings of the same pages. Extension
point: `code-region-allocate` and `code-region-install`.

## Alternatives Considered

**Why not put the code region in C, in `eval.c`, as the 2026-10-14 design
did?** The typed compiler runs on `eval2`, which could not call it, and a C
region carries each OS's details in the seed. With `subr` restored, the
region is a few lines of Maru, the same in both evaluators.

**Why not keep `native-call`'s one-argument convention for compiled code?**
Code compiled from typed Maru follows the C ABI; a one-argument wrapper would
be a second calling convention every back end had to emit.

**Why not report fields as byte offsets and widths?** A64 fields are bit
ranges, scaled and sometimes split (`ADRP`); byte offsets cannot describe
them, and bit ranges would put encoding detail in every caller. Patching
through the row keeps all of it in the rows.

**Why not the caller-defined `_B` and `_PC` hooks of the spike?** Globals
bound before loading allow one output per process and differ between byte
and word ISAs; an assembly buffer passed to `asm` serves every ISA and any
number of outputs.

**Why not put the intent layer in this specification?** It would tie the
assembler's review to back-end decisions not yet made; `asm-forms` is the
seam it needs.

**Why not run x86-64 code on this Mac only through executables under
Rosetta?** That needs `exe.l` and its signer first; an x86-64 evaluator
under Rosetta JITs today (probed: `MAP_JIT`, write, call).

**Why not name cross builds `eval-x86_64`?** Suffixes multiply names in
commands and documentation; `bin/<arch>/` keeps one name per tool.

**Why not leave coverage to the back ends?** Rows would be reviewed
piecemeal inside a larger change, and Nile's float kernels need floating
point that the spike lacks entirely.

## Security Considerations

`subr` lets a Maru program call any C function the process can resolve, with
any arguments, as `eval`'s `subr` already does; restoring it in `eval2`
grants no capability `eval` lacks, and both run only code the user gives
them. The code region is writable and executable: on macOS each thread
toggles between the two (`pthread_jit_write_protect_np`), so a region is
never both at once for that thread; elsewhere it is both, and code that
writes outside its buffer could alter installed code.
`code-region-install` refuses buffers outside the region. The evaluators are
ad-hoc signed by the linker without the hardened runtime, so `MAP_JIT` needs
no entitlement; signing them with the hardened runtime would require the
`com.apple.security.cs.allow-jit` entitlement.

## Compatibility

- The existing assembler (`gen-asm-x86.k`, `asm-x86.k`, `dsm-x86.k`,
  `asm-common.k`) and its `asm_x86` check are unchanged; the new checks use
  new names (`asm_rows_*`).
- `eval2` gains functions it lacked; nothing it had changes. `eval`'s `subr`
  gains the address form and return types; existing signatures mean what
  they did.
- `spike/asm/` is removed; its contents were promoted.
- The row checks need `clang` and LLVM's `objdump` (`llvm-objdump` where
  installed, else `/usr/bin/objdump`, which is LLVM's on macOS).
- Rosetta is deprecated: Apple has said it stays through macOS 27. When it
  goes, `bin/x86_64/` is not built and x86-64 runs only on x86-64 hosts.

## References

- RFC 2119, RFC 8174: BCP 14 key words.
- Intel 64 and IA-32 Architectures Software Developer's Manual, vol. 2
  (instruction set reference; 3.1.1.3 operand notation; 2.3 VEX).
- Arm Architecture Reference Manual for A-profile (A64 encoding diagrams;
  Advanced SIMD; logical and FP immediates).
- `docs/superpowers/specs/2026-10-14-table-driven-assemblers-design.md`:
  the earlier design, source for the disassembler, running-code and
  migration specifications.
- The spike, committed on branch `table-asm` with a README of its measured
  state and removed as it was promoted (see the branch history).
- `docs/rfc/draft-ndn-nile-runtime-in-maru-01.md`: the first user of the
  native back ends.
- libffi: https://github.com/libffi/libffi
