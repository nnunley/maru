# Register allocation for native-gen.k: design

Status: draft for approval, 2026-11-21. Branch nile-native-eval (A1: native imaging of Nile and Gezira on eval2).

## Intent

The native route should cost what the C route costs, so the test suite stops waiting minutes for native compiles. The
user wants register allocation to buy both compile time and run time, compile time first: "both, but compile time
first". They chose to do it in two steps ("3, write the design"): keep single-use temporaries in registers now, and
build a full allocator later on top of that, with the JOHN allocator (`check/john/x86-allocator.john`) as its spec.
Behaviour checks come before any change to generated code: "Having behavior based tests that check for equivalent
results, like the pixel comparison, is key."

## Where things stand

- `native-gen.k` gives every value a frame slot (`native-allocate`). Each operation loads its operands into scratch
  registers `s0`, `s1` … (`native-into`), operates, and stores its result from `s0` (`native-out`). Nothing in it names
  a machine register; `native-arm64.g` and `native-x64.g` map `s0`… through `stub-reg` to abi.spec's `scratch` row
  (arm64 X9 X10 X11 X12 X16; x64 R10 R9 R8 RCX R11).
- Measured on Gezira's 335 functions (`maru-intent-redundancy --slots`, 2026-11-21): loads and stores are about 54% of
  69,036 intents. Of 18,850 slots, 10,321 are written once and read once, 9,828 of those in the same basic block, and
  9,767 with no call between the write and the read. Those same-block temporaries carry 52.9% of all loads and stores.
  The most of them alive at once in a block: 0 in 1,892 blocks, 1 in 900, 2 in 430, 3 in 41, 4 in 6, 5 to 8 in 27,
  9 or more in 9 (the most, 12, in `gezira_CompositeSoftLight_body`); 3 registers cover 3,263 of 3,305 blocks. 5,576
  slots are tied to calls and parameters (arguments, call targets, results, `params`, `address`), 858 are read more
  than once, and 1,748 are never read (411 of them in `__init`). maru-check.k is similar (50.8% of loads and stores).
- In ir2's tree an instruction's value is an operand of one parent, so most values have one consumer by construction.
  The exceptions are variables (a `get-var` reads the variable's slot, any number of times), a `let`'s value (its
  last operand's slot), `set-var` (the variable's slot), and values that join after control flow (an `if`'s result,
  written on each branch).
- The behaviour check exists (commits 8c218b9, 2432acb, 7415103): `native_nile` saves natively compiled Gezira's image
  and draws `check/gezira-pixels.l`'s scenes with it, on one worker and four, each pixel's channels within 1 of the C
  library's (`check/gezira-pixels-compare.l`, which prints each scene's differing pixels and largest difference).
  Byte-identical images no longer judge this work: the generated code is meant to change.
- Phases of Gezira's native compile on eval2 (`maru-native-phases`, 2026-11-21, AC): front end 2.82 s, symbols 0.27 s,
  lowering 5.22 s, assembly 1.20 s; 106,211 forms, 412,908 bytes. The C route takes 2.7 s with cc.

## Goals

1. Step 1: a value written once and read once in its own block, with no call between, never touches the frame. It is
   computed into a register and read from it. A value never read is not stored. Lowering and assembly get fewer
   intents and forms to handle, and the code runs faster.
2. Step 2: a linear-scan allocator for what step 1 leaves (variables, values read more than once, values alive across
   blocks or calls), its allocations meeting the JOHN allocator's constraints. This is mostly a run-time gain.
3. Each step kept only if `ab-cpu` says the compile got faster (step 1) or, for step 2, the compile got no slower and
   the generated code faster on a measured run, interleaved, on AC, recorded with `--ledger`.

## Non-goals

- Changing ir2, maru.k or the C back end.
- Passing call arguments or results in registers without slots (the calling-convention slots stay; a later design).
- Instruction scheduling, peepholes, or copy coalescing beyond what each step states.
- x86 (32-bit) generators (`ir-gen-x86.k`).

## Anti-goals

- A pixel outside the band, or a native_ir2 program answering differently: a wrong allocation is a failure however
  fast it compiles.
- An allocation pass that costs more compile time than the loads and stores it removes.
- Loosening the pixel band to make a change pass. The band is for rounding (fused multiply-add), 1 per channel.
- Runtime code in C.

## Approaches considered

1. Single-use temporaries in registers: no liveness analysis; about half the loads and stores go. Leaves variables and
   values across blocks in slots.
2. Full linear-scan allocation now: live ranges for every value, callee-saved registers, splitting. Little more
   compile-time gain than 1 (858 multi-read slots against about 10,000 single-use ones), a liveness pass to pay for,
   and most of its gain at run time.
3. 1 now, 2 later on top of it (chosen). The cheap step takes most of the compile-time win first, as the user's order
   asks; the allocator then handles only what step 1 leaves.

## Step 1: held values

### Which values are held

A value is held (kept in a register, given no slot) when all of these hold, decided in `native-allocate`'s walk:

- it is an instruction's own value, consumed by its parent: not a variable read, a `let`'s value, a `set-var`, a
  function's value, or a value written on more than one path (an `if`'s result, `logand`/`logor`);
- its consumer reads it from a register: an operand of an operation, a comparison, a cast, an address computation, a
  load or store through an address, a branch condition, a return value. Not a call argument, a call target, a struct
  copy, `params` or `result`, which keep their slots in this step;
- nothing between its computation and its use evaluates a call: no later sibling operand of the same parent, lowered
  after it and before the parent's use, contains a call (calls clobber the registers values are held in);
- a held register is free for it. Registers are handed out as a stack in lowering order (an operand's registers are
  released when its parent consumes them), so the most held at once is the tree's depth of pending operands. When none
  is free, the value gets a slot as today. The probe's histogram says this is rare (42 of 3,305 blocks need more than
  three).

A value whose instruction has no consumer (a statement's result, `__init`'s assignment results) gets no slot and no
store; its instruction still runs for its effects.

### Held registers

- Intents gain a second register class, `h0`, `h1` …, beside `s0`, `s1` …. A held value lives in one `h` register
  from its producer's last intent to its consumer's.
- abi.spec gains a `held` row per ISA, mapped by `stub-reg` as `scratch` is. A held register must be one no intent's
  lowering touches except as that held value: not abi.spec's `scratch`, not the registers lowering names itself
  (arm64: X15 for far accesses, X17 and X0 in calls; x64: RAX and RDX in division and calls), and caller-saved, so no
  save in `enter`. Arguments registers qualify between calls, since no held value spans a call and `params` runs
  before any. Candidates: arm64 X13 X14 and argument registers from X7 down; x64 RSI RDI and argument registers not in
  `scratch`. (The exact lists are the builder's, under that rule.) x64 has only RSI and RDI under it (RAX and RDX are
  division's and calls', the rest `scratch`), so x64 holds two and the excess take slots: 83 of 3,305 Gezira blocks
  need more than two. *(Builder check; my call: two on x64 rather than callee-saved registers saved by `enter`.)*
- A held integer narrower than 8 bytes is normalised when it is produced, as the slot did it: today a store
  truncates and a load sign-extends, and arithmetic between them is 64-bit, so a held int32 would otherwise keep high
  bits and compare, divide, shift or branch differently. A new intent, `(extend size r)`, sign-extends r's low size
  bytes in place (arm64 SXTW/SXTH/SXTB; x64 MOVSXD/MOVSX), emitted for a held integer of size under 8 unless its
  producer already normalises it (a load, a comparison, a literal). A held float needs none: operations on it read only
  its low 32 bits, as they read a slot's. *(Builder check; my call: extend at production, rather than holding only
  8-byte values or making each operation width-aware.)*
- A check holds the rule: every native unit's lowered forms name an `h` register's machine register only in intents
  that carry that `h` register (a scan of the lowering's output in `native_ir2`'s units and Gezira).

### How lowering changes

- `native-into gen insn s` answers the register the operand is in: its `h` register if held (no intent), else `s`
  after a `load`. `native-out gen insn s` stores only for a slot. A lowering method computes its result into
  `(native-target gen insn s)`, the instruction's `h` register if held, else `s`. Methods use the registers these
  answer instead of fixed `s0`/`s1`; the intents already take any register in each position.
- Operand order is unchanged: operands are lowered in the order they are today, so a held value is consumed by its
  parent after its later siblings are lowered, which the "no call between" rule makes safe.
- `native-arm64.g` and `native-x64.g` accept `h` registers wherever `reg` is matched; the sites' `x`/`r`/`f` holes
  already take any plain register. Floats keep moving through fscratch for operations, as today; a held float value is
  its bits in an `h` register, as a float in a slot is its bits today.

### Step 1's checks and measures

- Behaviour: `native_nile`'s pixel comparison (within 1 a channel, and it prints the differences); `native_ir2` and
  `native_ir2_x64` (every program's answers); `native_image`; `catch` and `recover`. A check that a held value is
  never clobbered is the pixel and program checks themselves, plus the register-use scan above.
- Images change on purpose, so `native_sites`' sites-on against sites-off comparison stays (both sides held the same
  way) and `tpeg_direct` stays (both paths); the reference-image comparisons used during the encoder work are retired
  for this step.
- Expected: `maru-intent-redundancy --slots` on Gezira shows the same-block single-use bucket near zero and loads
  plus stores down by about half; 1,748 never-read slots gone. An estimate, not a measure: about 28% fewer intents,
  and lowering and assembly down by a similar share. `ab-cpu` against the step's base on `maru-native-phases`' lowering
  and the whole compile, three or more each, interleaved, on AC, `--ledger`.

## Step 2: the allocator (its own design, after step 1 lands)

Sketched here so step 1 doesn't block it; its details wait for step 1's measurements.

- What it allocates: what keeps a slot after step 1 that isn't tied to the calling convention: variables, values read
  more than once, values alive across blocks or calls.
- How: linear scan over the function's intents in order, live intervals from a liveness pass over its blocks,
  callee-saved registers (abi.spec's `saved`, saved by `enter` when used) for intervals that cross calls and
  caller-saved ones for those that don't, and splitting an interval when no register is free for all of it, as
  Samimi's allocator splits (`check/john/x86-allocator.john`, VPRI memo M-2009-008 §1).
- The JOHN allocator as spec: its constraints (two intervals that overlap never share a register; an allocation only
  where every point of the interval is free; a split leaves each piece in one register) are written as a checker in
  Maru over the allocator's output for every function of every native unit, and the JOHN model itself is run on small
  units' intervals (it searches, so it is too slow for Gezira) and its allocations compared with the allocator's for
  validity, not equality.
- Kept only if the compile gets no slower and the native code is measurably faster on a run (a native Gezira timing
  beside the pixel check; how to time it is part of that design).

## Open to the builder

- The held register lists per ISA, under the rule above.
- How `native-allocate` learns "no call in a later sibling" (a flag computed bottom-up in the same walk is enough).
- Whether a held value spilled for lack of a register spills at its producer (a slot from the start, as today) or at
  the point the stack overflows; the first is simpler and the probe says it is rare.
- The order of converting lowering methods, provided each commit leaves every check green.

## Risks

- A held value clobbered by an intent's lowering that uses a register the rule missed: wrong pixels or answers. The
  register-use scan and the behaviour checks are the defence.
- The probe's buckets were counted from intents, not from ir2's tree; a value the tree makes single-use may not match
  one the probe counted, so the gain may differ from the estimate.
- x64 has few free registers; if fewer than three qualify there, x64 holds fewer values (correct, smaller gain).
