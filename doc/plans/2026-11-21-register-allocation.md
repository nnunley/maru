# Held values (register allocation, step 1) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** A value written once and read once by its parent operation, with no call between, lives in a register and
never touches the frame; a value nothing reads is not stored.

**Architecture:** `native-allocate` marks such values held and gives each an `h` register by its depth among pending
operands; `native-into`, `native-target` and `native-out` answer and use registers instead of fixed `s0`/`s1`;
abi.spec's new `held` row maps `h0`, `h1` … to machine registers no lowering touches otherwise, and a scan holds that
rule. Behaviour is judged by running code (the pixel band, native_ir2), not by byte-identical images.

**Tech Stack:** typed Maru (`native-gen.k`), Maru (`native.l`, `stub.l`, checks), tpeg lowering grammars, abi.spec.

**Spec:** `doc/plans/2026-11-21-register-allocation-design.md` (approved 2026-11-21). This plan is its step 1 only;
step 2 (the allocator) gets its own design after this lands.

## Global Constraints

- Runtime code in Maru languages only, never C.
- ir2, maru.k and the C back end don't change.
- `native-gen.k` names no machine register: `h` registers are mapped by `stub-reg` from abi.spec, as `s` registers are.
- The pixel band stays 1 per channel; it is never loosened to make a change pass.
- Each step kept only if `ab-cpu` says the compile got faster (interleaved, `--require-ac`, `--ledger`).
- Commit at green, with `check/lines` and `check/erosion` entries; Conventional Commits; no AI attribution.
- Order on `eval`: a function's globals are resolved when it is defined; `maru-refactor order-check` after adding or
  moving definitions.

## Review Focus

1. A held value with a call buried in a later sibling (inside an `if`, a `let` or a `while`): it must take a slot, or
   the call clobbers it. Pinned in Task 2 (`check/native/held.k`, `held_call_in_branch`).
2. More pending operands than `held` registers (Gezira's deepest block needs 12): the excess take slots and the answer
   is right. Pinned in Task 2 (`held_deep`).
3. A float value held as its bits, at both widths, consumed by an operation that moves it through fscratch. Pinned in
   Task 2 (`held_float32`, `held_float64`).
4. A struct-typed value: never held (it moves by `copy`). Pinned in Task 2 (`held_struct_member`).
5. A goto to a label inside a `let` that is itself an operand, with a value held around it. Pinned in Task 2
   (`held_loop_in_operand`).

---

### Task 1: Held registers

**Files:**
- Modify: `abi.spec` (a `held` row per ISA), `stub.l` (`stub-reg-of`), `native.l` (`*native-held-count*`)
- Create: `check/native-held.l` (the register-use scan and the `h` register cases)
- Modify: `check/check.l` (`native_ir2` runs `check/native-held.l`)

**Interfaces:**
- Produces: abi.spec rows `arm64 held X13 X14 X7 X6 X5 X4` and `x64 held RSI RDI` (x64 has two: the design's risk
  clause, "x64 holds fewer values"); `(stub-reg isa 'hN)` answers the Nth of `(abi isa 'held)`;
  `*native-held-count*`, the number of held registers of the ISA `native.l` lowers for (`(stub-isa)`), set before any
  unit compiles; `(native-held-violations unit isa)` in `check/native-held.l`, a list of
  `(function intent form)`: each form (lowered with sites off, symbolic) that names a held machine register its intent
  doesn't carry as that `h` register.

- [ ] **Step 1: Write the failing cases** in `check/native-held.l` (`./eval2 check/native-held.l [LOADER]`, last line
  "native held ok"; sets `*arm64-sites*` to () before `native.l`, as `check/native-images.l --no-sites` does):
  - `(stub-reg 'arm64 'h0)` is `X13`, `(stub-reg 'arm64 'h5)` is `X4`, `(stub-reg 'x64 'h1)` is `RDI`.
  - A hand-built unit runs: `(native-install (new <native-unit> (list (list 'held_sum INTENTS 32)) ()))` where
    INTENTS take two arguments through `params` into slots, load them into `h0` and `h1`, `(op add h2 h0 h1)`,
    `(op mul h0 h2 h1)`, `(result-from h0)`; called by `subr` with 3 and 4 it answers 28.
  - The scan's own case: with arm64's held list taken as `(X9)` (a scratch register, so every load names it), the
    scan of that unit reports at least one violation; with the real list it reports none.
  - The scan over `check/native/*.k`'s units and LOADER (default `maru-check.k`) reports none.
- [ ] **Step 2: Run** `./eval2 check/native-held.l`. Expected: fails at the first `stub-reg` case (h0 maps to a
  scratch register today).
- [ ] **Step 3: Implement** the abi.spec rows, `stub-reg-of`'s `h` names (a name starting `h` indexes `held` as one
  starting `s` indexes `scratch`), `*native-held-count*`, and the scan.
- [ ] **Step 4: Run** `./eval2 check/native-held.l` and `bin/x86_64/eval2 check/native-held.l` (where built).
  Expected: "native held ok" on both. Add the run to `native_ir2` (and `native_ir2_x64`) in `check/check.l`.
- [ ] **Step 5: Gates and commit.** `make check CHECKS="native_ir2 native_ir2_x64 native_image native_sites native_nile
  catch recover lines erosion"`; commit `feat(native): held registers, h0 h1 …, mapped by abi.spec`.

### Task 2: Held values

**Files:**
- Modify: `native-gen.k` (`native-allocate`, `native-into`, `native-out`, a new `native-target`, every lowering
  method that reads an operand or writes a result)
- Create: `check/native/held.k` (programs exercising held values); modify `check/native.l` (their cases)

**Interfaces:**
- Consumes: Task 1's `h` registers and `*native-held-count*`.
- Produces, in `native-gen.k`:
  - a held instruction's location is `(held K)` (a list, so `ir-location?` is false and `native-slot-of` refuses it);
  - `(native-held? insn)`; `(native-calls? insn)`, whether the subtree evaluates a call, memoised per instruction;
  - `(native-into gen insn s)` answers the register holding insn's value: `hK` with no intent if held, else `s` after
    a `load`;
  - `(native-target gen insn s)` answers where insn's result is computed: `hK` if held, else `s`;
  - `(native-out gen insn r)` stores r to insn's slot, and emits nothing for a held insn (whose result r already is);
  - the generator keeps the depth of pending held values while allocating; a value is held only while the depth is
    below `*native-held-count*`;
  - a new intent `(extend size r)`: sign-extends r's low size bytes in place; `native-arm64.g` lowers it to SXTW, SXTH
    or SXTB and `native-x64.g` to MOVSXD or MOVSX; `native-out` emits it for a held integer narrower than 8 bytes
    unless its producer is a load, a comparison or a literal (the design's narrow-integer rule).
- The rule (the design's "Which values are held"): a producer of its own value (a literal; an arithmetic, bitwise,
  comparison or cast instruction; a memory read through `indir`/`member`; `addressof`; a global's read; `extern`;
  a function's address) whose parent reads it from a register (an operation, comparison, cast, address computation,
  `set-indir`/store through an address, `set-var`'s value, `return`, a branch condition, a computed goto's target),
  not struct-typed, with no later sibling for which `native-calls?` holds, and a held register free. Not held: local
  variable reads, `let`, `set-var`'s own value, an `if`'s or `logand`/`logor`'s value, a call's result, and any value
  consumed by a call (argument or target), `copy`, `params` or `result`.

- [ ] **Step 1: Write the failing cases.** `check/native/held.k` defines, each returning a long or double, and
  `check/native.l` calls them with these answers:
  - `held_expr (a b c)`: `(+ (* a b) (- c a))`; 3 4 5 → 14.
  - `held_call_in_branch (a b)`: `(+ (* a 2) (if (> b 0) (twice b) b))`, `twice` a function of the unit; 5 3 → 16.
  - `held_deep (a)`: 14 operands pending at once, `(+ a (+ a (+ a … (+ a a))))` nested so each left operand waits;
    2 → 30.
  - `held_float32 (x y)` and `held_float64 (x y)`: `(* (+ x y) (- x y))`; 3.0 2.0 → 5.0 at each width.
  - `held_struct_member (p)`: reads two scalar members of a struct through a pointer and adds them; a struct with
    members 7 and 8 → 15.
  - `held_loop_in_operand (n)`: `(+ n (let ((i 0) (s 0)) (label top) … (if (< i n) (goto top)) s))`, the sum 0..n-1
    added to n; 4 → 10.
  - `held_int32_wrap (a b)`, int arguments and int arithmetic: `(< (* a b) 0)` as a long, and `(/ (* a b) 2)`;
    65536 65536 → 0 and 0 (the int32 product wraps to 0); 46341 46341 → 1 and -1073739507 (it wraps negative). A held
    product without its `extend` answers differently.
  - An intents case in `check/native.l`: `held_expr`'s intents hold no `store` and three `load`s (its three arguments'
    slots), and no `load` of a temporary.
- [ ] **Step 2: Run** `./eval2 check/native.l`. Expected: the programs answer correctly (they do today, through
  slots) and the intents case fails (today `held_expr` stores each temporary).
- [ ] **Step 3: Implement** `native-calls?`, the held decision and depth in `native-allocate`, `native-into`,
  `native-target`, `native-out`, and convert every lowering method to the registers these answer. Operand order stays
  as it is: operands are lowered in today's order, and allocation walks them in the same order, so the depth at
  allocation is the depth at lowering.
- [ ] **Step 4: Run** `./eval2 check/native.l`, `./eval2 check/native-held.l`, and Gezira's pixels:
  `./eval2 check/native-nile.l LOADER IMAGE` then `./eval check/gezira-pixels.l IMAGE > N` and
  `./eval check/gezira-pixels.l > C` and `./eval check/gezira-pixels-compare.l C N`. Expected: "native ok", "native
  held ok", "pixels within 1" (and the differences printed, recorded in the ledger).
- [ ] **Step 5: Measure.** `maru-intent-redundancy --slots --top 0` on Gezira before and after: the same-block
  single-use bucket near zero, loads and stores down. `ab-cpu --base <Task 1's commit> --head . -n 3 --alternate
  --require-ac --ledger --metric-regex '^lower (\d+) ms' --cmd "lower=maru-native-phases --checkout . LOADER"`;
  kept only if faster.
- [ ] **Step 6: Gates and commit.** As Task 1, plus `tpeg_direct`; commit `perf(native-gen): single-use values held in
  registers, not frame slots`.

### Task 3: Values nothing reads

**Files:** Modify `native-gen.k` (`native-allocate`'s `let` and function bodies); `check/native.l`.

**Interfaces:** Consumes Task 2's locations. Produces: an instruction whose value its parent discards (a `let`'s
operand before the last, a function body's statement, `__init`'s assignment results) has location `(unused)`, and
`native-out` emits nothing for it; the instruction still runs.

- [ ] **Step 1: Failing case** in `check/native.l`: a function of `check/native/held.k`, `held_discard (a)`, whose
  body evaluates `(* a a)` as a statement before returning `a`; its intents hold no `store` other than `params`'s, and
  it answers 6 for 6.
- [ ] **Step 2: Run** `./eval2 check/native.l`. Expected: the intents case fails (the discarded product is stored).
- [ ] **Step 3: Implement** the `(unused)` location.
- [ ] **Step 4: Run** `check/native.l`, `check/native-held.l`, the pixel comparison; `maru-intent-redundancy --slots`
  shows the never-read bucket near zero (it was 1,748 slots).
- [ ] **Step 5: Gates, measure as Task 2, commit** `perf(native-gen): a value nothing reads is not stored`.

### Task 4: Close

- [ ] **Step 1:** `doc/native.md` describes held values, the `held` row and `check/native-held.l`; the design's
  status line says step 1 landed, with its measured gain.
- [ ] **Step 2:** the full suite on a quiet machine on AC, nothing beside it.
- [ ] **Step 3:** whole-branch review by a fresh reviewer with this plan's Review Focus; fix Critical and Important
  test first.
- [ ] **Step 4:** report `maru-native-phases --ledger -n 3` on Gezira, the probe's before and after, and the `ab-cpu`
  results to the user; then step 2's design.
