# Native code from ir2

Typed Maru compiled to arm64 and x86-64 in process, code images, and the JIT.

## Checks

- `native_ir2` (`check/native.l`): typed Maru compiled to native code in this process
  (`doc/rfc/draft-ndn-maru-native-ir2-00.md`, plan `doc/plans/2026-11-06-native-ir2.md`): `native.l` (on `eval2`, which
  runs `maru.k`) compiles a unit through `native-gen.k`, the generator `maru.k` drives in place of `ir-gen-c.k`, to
  architecture-neutral intents on ir2's frame slots; `native-arm64.g` lowers them by tree matching to arm64 forms, with
  `abi.spec`'s registers; `native-link.l` encodes them into a code region; and each function is called by address
  through `subr`. So far: parameters, literals (an integer literal an `int` can't hold is a `long`, `ir-integer-type`, so a cast or a global it initialises keeps all 64 bits: it was cut to 32; beside an `int` operand, though, ir2 still narrows it to an `int`, which C keeps whole and native code cuts), add, subtract, negate, return; `if` (with or without a value), `while`, `and`,
  `or`, `not` and every comparison (integers signed, pointers unsigned), on slots of 1, 2, 4 and 8 bytes; `* / %`, the
  bitwise operations and shifts (C's signed results), integer and pointer casts, struct fields through a pointer or an
  indexed element, indexing and `addressof`, each place reached through its address in a register. A conditional
  branch is a short branch over `B`, so its reach is `B`'s. Globals live in a zeroed block the image owns, set by an
  `__init` function run at install; externs resolve through `dlsym`, string literals are copied out of Maru's heap, and
  calls follow the AAPCS64 with Apple's rules (stack arguments at natural alignment, variadic ones in 8-byte slots,
  structs of integers and pointers, 16 bytes or fewer, in registers, and none after a struct that spills). A named argument is passed as its
  parameter's type (zero to a pointer is the whole pointer), a float with no parameter is promoted to double, and a
  function type with no prototype (`()` or `(...)` alone) is called as if it had one. A struct by value goes in general
  registers, which is C's rule only for integers and pointers, at most 16 bytes, a multiple of 4: any other by value,
  argument or result (over 16 bytes, a floating member anywhere in it, a size not a multiple of 4), is refused naming it,
  its size and the function, until C's conventions for it are written; so is a label ir2 never declared (an `if`'s
  branch). Each call's stack arguments must fit the area the frame keeps for them (8 bytes a scalar, a struct's size rounded to 8), which the
  lowering checks. `label` and `goto`, direct or computed, lower to labels and branches, each label its scope's own (two
  functions, or two sibling lets, may each have a `done`); a value of type label takes a pointer's slot.
  `check/native/calls.k` (ten arguments, `printf` with ints, doubles and a float, a global), `zero-global.k`,
  `check/ir2.k`, `maru-label.k` and `maru-test.k`'s primes and structs run their `main` in a forked child and print what
  they do under `cc`; the child sets its JIT pages executable first (`pthread_jit_write_protect_np` is per thread, and a
  forked one may start with them writable: an instruction abort at the code's entry).
  Floats stay as bits in slots and integer registers and visit `abi.spec`'s `fscratch` registers to be operated on
  (`fop`, `fcompare`, `convert`), and travel in its `fargs` and `fresult`; a literal is its double's bits, worked out in
  Maru (normal numbers and zero; a subnormal, infinite, NaN or `-0.0` literal is an error). A write
  stores at the size of the place it writes, so zero (an `int`) written to a pointer clears all of it. A frame beyond an
  immediate's reach is made from X29, and a slot a load's scaled offset doesn't reach (too far, or not a multiple of the
  access) has its address made in X15. Each unit starts from maru.k's own declarations, as maru.k
  compiles once a process. `check/native/floats.k`, `labels.k`, `structs.k` (12 and 16 bytes both ways, C's `ldiv`, a
  spill after seven longs, 8-byte pieces at slots 4 past a multiple of 8), `stack.k` (ints past the eighth argument,
  from C too), `frame.k` (a frame of 9760 bytes), `maru-check.k`'s six sections, `maru-gc.k`'s eleven reports
  (as `maru_gc` asks them) and `check/gc.k` pass natively, and the refusals fail naming what they refuse. Results are
  held to each program's own assertions and stated outputs, never to `ir-gen-c.k`'s. A struct of floats is passed in
  general registers, not as the AAPCS64's homogeneous aggregate. Children (`check/native-child.l`) write to the check's
  own directory, have 120 s, and leave by `_exit`, an error too (exit would move the loader's shared input).
- `native_ir2_x64`: the same programs lowered to x86-64 by `native-x64.g` (System V, `native-x64.l`'s actions: slots
  RSP-relative, R11 holding the callee, AL a variadic call's vector count, floats through `fscratch` by MOVQ and MOVD,
  float equality checking PF), run under Rosetta through `bin/x86_64/eval2` as a smoke test only; the real run is
  `native_ir2` on an x86-64 host (ndn.lan). Where `bin/x86_64/eval2` isn't built it prints `SKIP`.
- `native_image` (`check/native-image-save.l`, `check/native-image.l`): a unit compiled natively is a code image, a
  Maru form (`native-link.l`'s `native-image-of`) naming the instruction set and system it was made for, which loading
  checks before anything is installed: position-independent code, then a table of 8-byte slots through
  which it reaches each global, C function and string literal (ADR to the slot, then a load), the functions' offsets
  and the globals' sizes. `native-save` writes one on `eval2`; `native-image.l` alone (no maru.k, no grammars) loads one
  on any evaluator, filling the table (globals' storage, `dlsym`, string bytes) before installing and running `__init`.
  `native-install` is loading the image held in memory. `add.k` and `flow.k`, saved on `eval2`, give Tasks 1 and 2's
  answers on `eval` and `eval3`; `image.k`'s global, `strlen` and string reach them through the table; and an image
  for the other instruction set, or the other system, is refused. The host is uname's whole names (arm64 or aarch64,
  x86_64; Darwin, Linux), and any other is refused. A string literal must be ASCII.
- `jit_run` (`check/jit-run.l`): code assembled into a code region runs
  in-process through the C ABI on each evaluator the host has (arm64, and
  x86-64 under Rosetta through `bin/x86_64/eval2`).
