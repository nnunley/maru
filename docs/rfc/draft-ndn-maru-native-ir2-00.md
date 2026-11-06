# draft-ndn-maru-native-ir2-00: Typed Maru to Native Code, In-Process, Through Intents

**Status:** DRAFT
**Corpus:** red (spec-first: the checks named below are the acceptance criteria)
**Category:** Standards-Track
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies a back end that compiles typed Maru's IR (`ir2`) to arm64 and x86-64 machine code in the
running Maru process, with no C compiler. `ir2` lowers to architecture-neutral intents, intents lower to instruction
forms by per-architecture tree-matching grammars, the table-driven encoders of RFC 0001 encode them, and the result is
installed in a code region, to be called by address, or written as an executable by `exe.l`. It is written for
whoever implements the back end, and for the Nile runtime and Gezira, which it lets run without `cc`.

## Motivation

Typed Maru reaches machine code today only through `ir-gen-c.k`, which writes C for the host's C compiler. Piumarta's
`ir-gen-x86.k` emits 32-bit x86 assembly text, which a 64-bit host can't use (CLAUDE.md, Known not to work). So:

- The Nile runtime and Gezira (draft-ndn-nile-runtime-in-maru-03) run as a `.dylib` built by `cc`. Building that
  library needed a fix to `ir-gen-c.k`'s library mode, and a running image can't compile a kernel without a C toolchain.
- Bare metal (roadmap 4) has no C compiler at all.
- Everything below `ir2` already exists and is checked: encoders for arm64 and x86 whose every row assembles to the
  bytes clang gives (`asm_rows_*`); a table naming, for every `ir2` operation on every type, the forms each instruction
  set needs (`asm-coverage.spec`, checked by `asm_coverage`); placeholders patched later (`asm_patch`); stubs written
  once as intents and lowered by tree matching (`stub.l`, `stub-arm64.g`, `stub-x64.g`, with calling conventions in
  `abi.spec`); an executable code region (`code-region.l`) and executables written without a linker (`exe.l`).

What is missing is the step from `ir2`'s tree to those intents: instruction selection, frames, calls, data and
externs. This document specifies that step, on the frame-slot model `ir-gen-x86.k` uses and `ir2` already provides.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **ir2** — typed Maru's intermediate representation (`ir2.k`): instructions (`<ir-insn>` and its kinds), types,
  globals, functions, and frames of slots (`<ir-frame>`, `<ir-zone>`, `<ir-location>`).
- **intent** — an architecture-neutral operation on abstract operands: what an instruction must do, not which one.
- **operand** — a frame slot, a scratch register (`s0`, `s1` …), an argument or result position of the calling
  convention, an immediate, or a symbol (a function, global or extern, resolved at link time).
- **lowering grammar** — a per-architecture tree-matching grammar from intents to instruction forms, as `stub-arm64.g`.
- **unit** — the functions and globals of one compilation: what `ir-gen-c.k` turns into one C file.
- **image** — a unit installed in a code region and linked: its functions callable by address.
- **expected result** — what a program asserts or states it prints (`maru-check.k`, `check/ir2.k` and
  `check/zero-global.k` check themselves; other values are written in the checks), and `ir2`'s semantics.

## Specification

This document defines the lowering from `ir2` to intents, the intent vocabulary, the per-architecture lowering, the
link step, the two outputs, and the checks. It does NOT define register allocation beyond scratch registers: every
value lives in its frame slot, as in `ir-gen-x86.k`, and an allocator is a later step (Out of Scope). It does NOT change
`ir2`, the encoders or the code region, which it uses as they are.

**Intents are the boundary.** `ir2`'s lowering knows no architecture; a lowering grammar knows no `ir2`. A new
architecture is a lowering grammar, rows in its `.spec`, and its calling convention in `abi.spec`.

**Native results are held to each program's own assertions.** `ir-gen-c.k` is not the reference: an earlier model
wrote it, and it lowers partly from the wrong level. Each native result is held to the program's expected result, with
`ir-gen-x86.k` (Piumarta) as the design reference, never to `ir-gen-c.k`'s output. `ir-gen-c.k` stays until every check
below passes natively.

### Data model

```
RECORD Intent:
    op       : Symbol               -- one of the vocabulary below
    width    : 8 | 16 | 32 | 64     -- for loads, stores and integer operations
    signed   : Boolean              -- for loads, divisions, shifts and comparisons
    float    : None | 32 | 64       -- floating-point operations
    operands : list of Operand

RECORD Operand:                     -- one of
    slot     : Integer              -- a frame offset (ir2's <ir-location>)
    scratch  : Integer              -- s0, s1, …: a register the calling convention lets a function clobber
    arg      : Integer              -- the calling convention's nth argument position
    result   : None                 -- the calling convention's result position
    imm      : Integer | Float
    symbol   : Symbol               -- a function, global or extern; a placeholder until linked
    label    : Symbol               -- a branch target in this function

RECORD Unit:
    functions : list of (name, intents, frame size)
    globals   : list of (name, size, alignment, initial bytes)
    externs   : list of name
```

The intent vocabulary, each with its width, sign and float attributes where they apply: `enter` and `leave` (frame
setup and teardown for a frame size), `load` and `store` (between a slot or address and a scratch register), `move`,
`constant`, `address` (of a slot, global or function), the arithmetic, logical and shift operations `ir2` declares,
`compare` (setting a scratch register to 0 or 1), `branch` and `branch-if` (on a scratch register), `label`, `call`
(direct by symbol, or indirect through a scratch register; variadic calls marked, for Apple's arm64 convention) and
`return`, and `convert` (between integer widths, and integer and float). Every operation and type `asm-coverage.spec`
names for `ir2` MUST have an intent that lowers to the forms it lists. [R-intents-cover]

```maru-check @R-intents-cover
native_coverage
```

### Lowering `ir2` to intents

`native-ir2.l` walks a unit as `ir-gen-c.k` does, one method per `ir2` instruction kind, and emits intents. Each value
lives in the frame slot `ir2` allocated for it; an operation loads its operands into scratch registers, operates, and
stores its result. A function's parameters arrive in the calling convention's argument positions and are stored to
their slots by `enter`; its result is moved to the result position before `leave`. `ir2`'s `label` and `goto` become
`label` and `branch`, so `maru_label`'s computed gotos lower too.

The lowering MUST be architecture-neutral: `native-ir2.l` names no register, instruction or calling convention.
[R-neutral]

```maru-check @R-neutral
native_neutral
```

### Lowering intents to instructions

`native-arm64.g` and `native-x64.g` lower intents to instruction forms by tree matching, extending the stubs' grammars,
and take registers and conventions from `abi.spec` (the AAPCS64 with Apple's variadic rule on Darwin; System V on x86-64
Linux and Darwin). A form MUST be one `asm-coverage.spec` lists for that operation and type, so the encoders' checked
rows are the only ones used. [R-checked-rows]

A named argument is passed as its parameter's type, and a float with no parameter is promoted to double, as C does; a
function type with no prototype (`()`, or `(...)` alone) is called as one with a prototype, as C calls it on Apple's
arm64. A struct over 16 bytes by value, as an argument or a result, MUST be refused at compile time, naming the struct
and the function, until the conventions C uses for one (a copy passed by reference, a hidden result pointer) are
written. Each call's stack arguments fit the area at the frame's bottom the lowering of `ir2` reserves (8 bytes a
scalar, a struct's size rounded up to 8: a bound for every convention here), and the lowering checks it.

```maru-check @R-checked-rows
native_coverage
```

### Linking and the outputs

A unit's functions are encoded into one buffer; branches within a function, calls between functions, and addresses of
globals are placeholders patched once every position is known (`asm-patch`). Globals live after the code, in memory
the image owns, with their initial bytes. An extern is resolved when the unit is installed, through `dlsym` in this
process, and called through a table of addresses the image owns. An image names the instruction set and system it was
made for, and loading refuses one made for another before anything is installed.

`(native-install unit)` MUST install a unit in a code region and answer its functions by name, as addresses that
untyped Maru calls with `subr`, exactly as it calls a library's. [R-install]

`(native-executable unit target path)` MUST write a unit with a `main` as an executable for an `exe.l` target, its
externs imported as `exe.l` imports `write` and `exit`. [R-executable]

```maru-check @R-install
native_ir2
```

```maru-check @R-executable
native_exe
```

### Checks

Every ir2 program the C back end runs MUST give its expected result natively, on arm64 here and on x86-64 natively on
`ndn.lan`: `check/ir2.k` (`ir2`), `maru-check.k` (`maru_check`), the primes and structs of `maru_test`,
`check/zero-global.k`, Piumarta's `maru-label.k`, the typed collector (`maru_gc`, `check/gc.k`), and a unit with
externs and a variadic call. [R-same-output]

```maru-check @R-same-output
native_ir2
```

Then the Nile runtime and Gezira, compiled natively and installed in the running image, MUST render `gezira_image`'s
rectangle to the same pixels as their `cc`-built library, and pass the runtime's checks at 1 and several workers.
[R-nile-native]

```maru-check @R-nile-native
native_gezira
```

### Errors

| Error | Example | Recovery |
|---|---|---|
| An `ir2` instruction with no lowering | a kind `native-ir2.l` has no method for | Compilation stops, naming the kind and the function. |
| An intent with no form for an architecture | an operation `asm-coverage.spec` lacks | Compilation stops, naming the intent, width and architecture. |
| An extern not found | a misspelt C function | Installation stops, naming it; nothing is installed. |
| A displacement that doesn't fit | a branch farther than a row's field allows | The encoder refuses it (RFC 0001); a conditional branch is lowered as the inverted test over an unconditional one, whose reach is the widest. |
| A struct over 16 bytes by value | `(define-function f long ((s struct <big>)) …)` | Compilation stops, naming the struct, its size and the function. |
| A literal that can't be written | `-0.0`, a subnormal, an infinity, a NaN | Compilation stops, naming it. |
| An image for another machine | an arm64 image loaded on x86-64, or a Darwin one on Linux | Loading stops, naming both; nothing is installed. |

## Out of Scope

**Register allocation.** Values live in frame slots, with scratch registers only. Extension point: an allocator between
the two lowerings, rewriting slot operands to registers; the JOHN register allocator, with each architecture's register
file as data, is the planned one.

**Optimisation** (folding, peephole, scheduling). Extension point: passes over intents, as tree rewriting grammars.

**Writing shared libraries** (Mach-O dylibs, ELF shared objects). Extension point: `exe.l`'s writers.

**32-bit targets.** `ir-gen-x86.k` stays for i386. Extension point: a lowering grammar for i386.

## Alternatives Considered

**Why not generate assembly text, as `ir-gen-x86.k` does?** It needs an external assembler, the thing the in-process
path removes, and the encoders already check every row against clang.

**Why not lower `ir2` straight to each architecture's instructions?** It is the shape of the `refactor-main` arm64
drafts, which copied x86's assumptions into arm64 and never assembled. Intents keep each architecture's knowledge in
its grammar and tables.

**Why not allocate registers now?** Frame slots make every check's first native run checkable against its expected
result with the fewest moving parts; an allocator is a separate change measured against this one.

**Why not keep the C back end?** It stays until the checks pass; it can't run where there is no C
toolchain, and a running image can't compile with it.

## Security Considerations

Code is written into a code region that is made executable (RFC 0001: writable, then executable, never both on Apple
silicon). Only units compiled in this process are installed; nothing is loaded from outside. An extern resolves through
`dlsym` in this process, as `subr` already does, so no new trust boundary is added.

## Compatibility

`ir-gen-c.k` and `ir-gen-x86.k` are unchanged. Programs and libraries keep building through `cc` until a caller chooses
the native path; the Nile runtime and Gezira move to it when `[R-nile-native]` passes.

## References

- RFC 2119, RFC 8174: BCP 14 key words.
- RFC 0001 (`docs/rfc/0001-table-assemblers.md`): the encoders, placeholders and the code region.
- `asm-coverage.spec`, `abi.spec`, `stub.l`, `stub-arm64.g`, `stub-x64.g`, `exe.l`, `code-region.l`.
- `ir-gen-x86.k` (Piumarta): the frame-slot model this follows; `ir-gen-c.k`: what this replaces, not the reference.
- Arm, "Procedure Call Standard for the Arm 64-bit Architecture" (AAPCS64); Apple, "Writing ARM64 code for Apple
  platforms"; "System V Application Binary Interface, AMD64 Architecture Processor Supplement".
- draft-ndn-nile-runtime-in-maru-03: the runtime this lets run without `cc`.
