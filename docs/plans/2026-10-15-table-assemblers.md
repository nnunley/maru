# Table-Driven Encoders and Code Region: Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Encoders for A64, x86-64 and 32-bit x86, described once as vendor-notation rows and covering every `ir2` operation with FP and SIMD, plus C-ABI calls and an in-process code region so encoded code runs inside `eval2` on arm64 and, under Rosetta, x86-64.

**Architecture:** `asm-table.l` owns loading rows, compiling each into an encoder, the assembly buffer and the one interface (`asm`, `asm-forms`, `asm-patch`, `asm-decode`); `asm-a64.l` and `asm-x86.l` register their ISAs with it. Checks drive every row's samples through `clang` and `/usr/bin/objdump`, decode them back, and run code in a `MAP_JIT` region reached through `eval2`'s restored `subr`. The spike in `spike/asm/` is the starting point and is deleted as its pieces are promoted.

**Tech Stack:** Untyped Maru (`boot.l` under `./eval`, `boot2.l` under `./eval2`), `text-parser.l`/`compile-tpeg.l` grammars, libffi, `/usr/bin/clang` and `/usr/bin/objdump`, Rosetta 2.

**Spec:** `docs/rfc/0001-table-assemblers.md` (branch `table-asm`). Requirement IDs below (`[R-…]`) are its markers.

## Global Constraints

- The rows are the encoder: no encoding, field layout or opcode constant outside `x86.spec` and `a64.spec`, except the general rules in `asm-x86.l`/`asm-a64.l` that the RFC's "Row semantics" lists (ModRM/SIB/REX/VEX, arrangements, logical and FP immediates).
- One interface: `(asm isa buffer insn)`, `(asm-forms isa mnemonic)`, `(asm-patch isa buffer report value)`, `(asm-decode isa bytes pc)`, `(asm-buffer origin)`, with `isa` one of `a64`, `x64`, `x86`. No caller branches on the ISA.
- `asm-table.l`, `asm-a64.l` and `asm-x86.l` load and give identical results under `./eval` and `./eval2 -b boot2.l`.
- Reference bytes come from `/usr/bin/clang -c` and `/usr/bin/objdump -s -j <section>` only (`__text` for Mach-O targets, `.text` for ELF): `-target arm64-apple-macos`, `-target x86_64-pc-linux` and `-target i386-pc-linux`, x86 sources starting `.intel_syntax noprefix`.
- Work order: A64 scalar integer and FP, A64 NEON, x64 scalar integer and FP, x64 SSE, x64 AVX2, x86. The foreign-call and code-region tasks sit after A64 scalar, because running code is the priority.
- Every commit passes `./eval check/check.l lines`, with a `check/lines` entry (delta and reason) for each change in counted lines; spike lines removed are a negative entry.
- Conventional Commits; no Claude attribution. Branch `table-asm`, merged into `main` and deleted when the plan is done.
- `~/.claude/skills/authoring-rfcs/rfc-run --expect docs/rfc/0001-table-assemblers.md` reports "red as declared" until Task 12 removes the `**Corpus:**` line, then green.

## Review Focus

1. **A64 register 31 in every operand position:** `SP` where the row says `|SP`, `XZR`/`WZR` otherwise, and an error when the other one is given. Test: `asm_rows_a64` samples both names in every register position and expects the wrong one to fail (Task 1).
2. **Branch and ADRP targets at the exact ends of their range, and one past.** `B` at ±128 MB, `B.cond` at ±1 MB, `ADRP` at ±4 GB pages: the last value encodes, one beyond errors. Test: `asm_patch` boundary cases (Task 2).
3. **A logical immediate that has no encoding** (`AND X0, X1, #0x5` and other values that aren't rotated runs of ones). Expected: no row matches, the error names the instruction. Test: `asm_rows_a64` negative cases (Task 3).
4. **An x64 instruction mixing a high-byte register with a REX-requiring operand** (`MOV AH, R8B`, `MOV AH, SIL`). Expected: an error, never silent wrong bytes. Test: `asm_rows_x64` negative cases (Task 7).
5. **Installing code that crosses the end of a code region.** Expected: error, nothing copied, region unchanged. Test: `jit_run` negative case (Task 5).

---

### Task 1: `asm-table.l`, the A64 integer rows, and the row check

**Implements:** [R-spec-counted], [R-one-entry] (A64), [R-round-trip] (A64), [R-field-range] (A64)

**Files:**
- Create: `asm-table.l`, `a64.spec` (from `spike/asm/arm64.spec`), `a64.g` (from `spike/asm/arm64.g`), `asm-a64.l` (from `spike/asm/arm64.l`), `check/asm-rows.l`, `check/asm-interface.l`
- Modify: `Makefile` (rule for `a64.g.l` as for `osdefs.g.l`), `.gitignore` (`/a64.g.l`), `.gitattributes` (`a64.g.l derived`), `check/check.l` (`lines` extension pattern gains `spec`; cases `asm_rows_a64`, `asm_interface`), `check/lines`
- Delete: `spike/asm/arm64.spec`, `arm64.g`, `arm64.g.l`, `arm64.l`, `axcheck.l`, `acmp.sh`, `at0.l`

**Interfaces:**
- Produces, in `asm-table.l`:
  - `(asm-buffer origin) → buffer`; `(asm-buffer-bytes b) → array of bytes`; `(asm-buffer-pc b) → origin + length`.
  - `(asm-register-isa name rows encode decode)` — called by each ISA file; `rows` is the list of compiled rows, `encode` is `(lambda (row insn pc) → bytes-list | ())`, `decode` is `(lambda (bytes pc) → (insn . length) | ())`.
  - `(asm isa buffer insn) → reports`, trying rows of `isa` whose mnemonic is `(car insn)` in file order; reports are `(position offset row)` per placeholder or target operand. Error when none matches: `asm: no a64 row for (ADD X0 W1 3); forms: ...`.
  - `(asm-forms isa mnemonic) → ((kinds row) ...)`.
  - `(asm-decode isa bytes pc) → (insn . length) | ()`; `bytes` is an array whose index 0 is the instruction's first byte. (The RFC writes the result as `(instruction . rest)`; `rest` is the length consumed.)
- Produces, in `asm-a64.l`: the `a64` ISA; A64 instruction syntax as the RFC's "Instruction syntax" gives it (`(off X1 16)`, `(pre SP -16)`, `(post SP 16)`, `(LSL 12)`).
- Produces, in `check/asm-rows.l`: `./eval check/asm-rows.l ISA` prints, last, `asm rows ISA: N instructions, D differ, R round-trip failures, E range errors as expected`, and exits nonzero if `D`, `R` or a missing expected error is nonzero.

- [ ] **Step 1: Write the failing tests.**
  - `check/asm-rows.l`, generalising `spike/asm/axcheck.l`: for every row, sample operands as the spike does (every register position, register 31 as both `SP` and `XZR` where legal, immediate edges, branches both ways); print each sample in clang syntax into one `.s` file with labels for branch targets; `clang -target arm64-apple-macos -c`; read `__text` with `/usr/bin/objdump -s -j __text`; compare word by word with our encoding; decode each word with `asm-decode` and re-encode, comparing words. Negative cases: `(ADD X0 X1 4096)` (imm12 out of range), `(ADD XZR X1 1)` where the row reads `SP`, a negative value for an unsigned field — each must raise an error.
  - `check/asm-interface.l` under both evaluators: `(asm 'a64 b '(ADD X0 X1 X2))` writes `20 00 02 8b`; `(asm-forms 'a64 'ADD)` has at least the spike's four forms; `(asm-decode 'a64 #(0x20 0x00 0x02 0x8b) 0)` gives `((ADD X0 X1 X2) . 4)`; prints `asm interface ok`.
  - Cases `asm_rows_a64` (asserts `0 differ, 0 round-trip failures`) and `asm_interface` (runs `check/asm-interface.l` under `./eval` and `./eval2 -b boot2.l`, asserts `asm interface ok` from both).
- [ ] **Step 2:** `./eval check/check.l asm_rows_a64 asm_interface`. Expected: FAIL, `asm-table.l` not found.
- [ ] **Step 3:** Write `asm-table.l`; move the spike's A64 files to `a64.spec`, `a64.g`, `asm-a64.l`, replacing `_B`/`_PC` with the buffer and `a64-decode`'s `(WORD w)` result with `()`; compile each row into an encoder when loading (as `spike/asm/x86-gen.l` does for x86); add the `u` marker to the A64 grammar for unsigned immediates (none of the spike's rows need it yet, but `asm-table.l`'s range check reads it for every ISA).
- [ ] **Step 4:** Run both cases. Expected: PASS, 266 or more instructions, `0 differ`. Then `make check`: green, `lines` counting `.spec`.
- [ ] **Step 5:** `check/lines` entries (promoted lines; the deleted spike files as a negative entry); commit `feat(asm): one table-driven interface, starting with the A64 integer rows`.

### Task 2: Placeholders and patching

**Implements:** [R-patch] (A64)

**Files:** Modify `asm-table.l`, `asm-a64.l`, `a64.spec`; create `check/asm-patch.l`; modify `check/check.l` (case `asm_patch`), `check/lines`.

**Interfaces:**
- Consumes: Task 1's interface.
- Produces: `(reloc)` and `(reloc N)` operands; `(asm-patch isa buffer report value) → buffer`. For A64 the patchable fields are every `imm`/`simm`/`pcrel` operand, including `ADR`/`ADRP`'s split `immhi:immlo` (add `ADR`, `ADRP`, `B.cond` for all 14 conditions, `CBZ`/`CBNZ`, `TBZ`/`TBNZ`, `LDR` (literal) rows here).

- [ ] **Step 1: Write the failing test** `check/asm-patch.l`: for every `a64` row with a patchable field, and for values at both ends of its range and zero, encode with `(reloc)` then `asm-patch` with the value, and compare with encoding the value directly; also: patching one past each end errors and leaves the buffer unchanged; prints `asm patch a64 ok`. Case `asm_patch` asserts it.
- [ ] **Step 2:** Run. Expected: FAIL, `reloc` is not an operand.
- [ ] **Step 3:** Implement: a placeholder matches any row whose field for that operand is patchable, widest field first unless `(reloc N)`; `asm-patch` re-encodes the report's row with the report's operands and the value substituted, at `origin + offset`, and overwrites those bytes.
- [ ] **Step 4:** Run. Expected: PASS; `asm_rows_a64` still PASS with the new rows.
- [ ] **Step 5:** `check/lines`; commit `feat(asm): patch fields through the row that encoded them`.

### Task 3: The coverage table and A64 scalar coverage

**Implements:** [R-coverage] (A64 scalar), [R-field-range] (A64 logical immediates)

**Files:** Create `asm-coverage.spec`; modify `a64.spec`, `asm-a64.l`, `a64.g`; modify `check/asm-rows.l`; create `check/asm-coverage.l`; modify `check/check.l` (case `asm_coverage`), `check/lines`.

**Interfaces:**
- Produces: `asm-coverage.spec`, one form per line: `ISA  CLASS  FORM`, where `FORM` is in the ISA's own `.spec` instruction notation and `CLASS` names what it serves (`add.i32`, `div.u64`, `load.s8`, `cvt.f32.i64`, `call.indirect`, `vadd.f32x4`, …); `#` comments. `(asm-coverage isa) → list of (class form)`.
- `check/asm-coverage.l ISA` asserts every form parses with the ISA's grammar and has a row with equal kinds in `asm-forms`; prints `asm coverage ISA: N forms, 0 missing`.

- [ ] **Step 1: Write `asm-coverage.spec` for `a64` scalar** from the RFC's Coverage list 1 and 3: for every `ir2` operation on `W`/`X` (8 and 16 bits through `LDRB`/`LDRH`/`LDRSB`/`LDRSH`/`STRB`/`STRH` and `SXTB`/`SXTH`/`UXTB`/`UXTH`), `S` and `D`: `ADD` `SUB` `MUL` `SDIV` `UDIV` `MSUB` (mod), `NEG` `MVN` `AND` `ORR` `EOR` (register and logical-immediate), `LSLV` `LSRV` `ASRV` and immediate shifts, `CMP` `CSET` with all conditions, `SXTW`, `MOVZ` `MOVK` `MOVN`, `ADR` `ADRP`, loads/stores of every width with `off`/`pre`/`post`/`reg` addressing, `LDP`/`STP`, `B` `BL` `BR` `BLR` `RET` `B.cond` `CBZ` `CBNZ`; `FADD` `FSUB` `FMUL` `FDIV` `FNEG` `FABS` `FSQRT` `FMIN` `FMAX` `FCMP` `FCSEL` `FMOV` (register, general register, imm8) `SCVTF` `UCVTF` `FCVTZS` `FCVTZU` `FCVT` (S↔D), `LDR`/`STR` of `S` and `D`.
- [ ] **Step 2: Write the failing test** `check/asm-coverage.l`; case `asm_coverage` runs it for `a64`. Run. Expected: FAIL, listing the missing forms.
- [ ] **Step 3:** Add rows for every missing form to `a64.spec`; extend `asm-a64.l` with the logical-immediate (`N:immr:imms`) and FP-immediate (`imm8`) encoders and decoders per the Arm ARM pseudocode (`DecodeBitMasks`, `VFPExpandImm`), and FP registers `S0`–`S31`, `D0`–`D31`; extend `check/asm-rows.l` samples for the new kinds and add the negative case `(AND X0 X1 5)` (no logical-immediate encoding → error).
- [ ] **Step 4:** Run `asm_coverage asm_rows_a64 asm_patch`. Expected: all PASS, `0 missing`, `0 differ`.
- [ ] **Step 5:** `check/lines`; commit `feat(asm): A64 scalar integer and floating-point rows, with the ir2 coverage table`.

### Task 4: Foreign calls in `eval2`

**Implements:** [R-subr]

**Files:** Modify `eval2.c` (uncomment `ffdefault`, `ffcall`, `subr`, `subr-name`, `byte-at`, `set-byte-at` and their table entries; add the extensions), `eval.c` (the same extensions); create `check/eval2-subr.l`; modify `check/check.l` (case `eval2_subr`), `check/lines`.

**Interfaces:**
- Produces, in both evaluators: `(subr NAME-OR-ADDRESS "SIG")`, where `SIG` may end in `>` and one of `i j k l p f d`; calling it returns an integer for `i j k l p`, a double for `f d`; `(byte-at address offset)`, `(set-byte-at address offset byte)` on raw addresses.

- [ ] **Step 1: Write the failing test** `check/eval2-subr.l`, run under both evaluators: `((subr "strlen" "s>l") "maru")` is 4; `((subr "sqrt" "d>d") 2.25)` is 1.5; `((subr "powf" "ff>f") 2.0 3.0)` is 8.0; `((subr "abs" "i") -3)` is 3 (no `>`: integer as today); an address from `((subr "dlsym" "ps>p") RTLD_DEFAULT "labs")` called through `(subr address "l>l")` with -7 gives 7; `set-byte-at`/`byte-at` round-trip through `((subr "malloc" "l>p") 16)`; prints `subr ok`. Case `eval2_subr` asserts `subr ok` from both.
- [ ] **Step 2:** Run. Expected: FAIL under `eval2` with `undefined variable: subr`.
- [ ] **Step 3:** Restore the commented code in `eval2.c`; in both files make `subr` accept a `Long` as the address, parse `>` and the return letter into the prototype, and have `ffcall` use the matching `ffi_type` for the return and box `float`/`double` results as `Double`.
- [ ] **Step 4:** Run `eval2_subr`, then `make check`. Expected: PASS, all green.
- [ ] **Step 5:** `check/lines` (net change, mostly uncommented lines already counted); commit `feat(eval2): restore subr and ffcall, with address and return-type signatures`.

### Task 5: The code region and running A64 code

**Implements:** [R-jit-run] (A64)

**Files:** Modify `system.osdefs` (`integer PROT_READ PROT_WRITE PROT_EXEC MAP_PRIVATE MAP_ANON` and, under `__APPLE__`, `MAP_JIT`) and regenerate `system.osdefs.c`; create `code-region.l`, `check/jit-run.l`; modify `check/check.l` (case `jit_run`), `check/lines`.

**Interfaces:**
- Consumes: Task 4's `subr`, `byte-at`, `set-byte-at`; Task 1's buffer.
- Produces, in `code-region.l`: `(code-region-allocate size) → region` (default size `1048576`), `(code-region-next region) → address` (the next free, 16-byte-aligned address), `(code-region-install region buffer) → address`, `(code-callable address "SIG") → subr`. On macOS `pthread_jit_write_protect_np` and `sys_icache_invalidate` through `subr`; elsewhere `__clear_cache` (linked as `__clear_cache` from libgcc/compiler-rt) and no write-protect toggle.

- [ ] **Step 1: Write the failing test** `check/jit-run.l ISA`, run under `./eval2 -b boot2.l`: assemble at `(code-region-next r)` and install, then call: `add(a, b)` as `"ii>i"` with 40, 2 → 42; `fmul(a, b)` on `S` registers as `"ff>f"` with 1.5, 2.0 → 3.0; the same on `D` as `"dd>d"`; a pointer identity as `"p>p"`; a recursive `fib(n)` that also calls `putchar` (address from `dlsym`) for each letter `A`…`Z` before returning `fib(25)`, as `"i>i"` → prints `ABCDEFGHIJKLMNOPQRSTUVWXYZ`, returns 75025; installing a buffer whose end passes the region's end errors and leaves the region unchanged. Prints `jit run ISA ok`. Case `jit_run` runs it for the host evaluator's ISA (`a64` on arm64).
- [ ] **Step 2:** Run. Expected: FAIL, `code-region.l` not found.
- [ ] **Step 3:** Write `code-region.l`; add the constants to `system.osdefs`, run `make` so `system.osdefs.c` regenerates, and commit the regenerated file as `CLAUDE.md` describes.
- [ ] **Step 4:** Run `jit_run`, then `make check`. Expected: PASS.
- [ ] **Step 5:** `check/lines`; commit `feat(jit): a code region in Maru, running A64 code through subr`.

### Task 6: A64 NEON

**Implements:** [R-coverage] (A64 vector)

**Files:** Modify `a64.spec`, `a64.g`, `asm-a64.l`, `asm-coverage.spec`, `check/asm-rows.l`, `check/jit-run.l`, `check/lines`.

**Interfaces:** Produces vector operands `(V n ARR)` and lanes `(V n T i)` per the RFC, arrangements `8B 16B 4H 8H 2S 4S 1D 2D`.

- [ ] **Step 1:** Add to `asm-coverage.spec` the `a64` vector forms from the RFC's Coverage list 2: packed `ADD` `SUB` `MUL` `NEG` `AND` `ORR` `EOR` `BIC` `NOT` `SSHL`/`USHL` and immediate `SHL`/`SSHR`/`USHR`, `CMEQ` `CMGT` `CMGE` `CMHI` `CMHS`, `SMIN`/`SMAX`/`UMIN`/`UMAX`; `FADD` `FSUB` `FMUL` `FDIV` `FMLA` `FMIN` `FMAX` `FNEG` `FABS` `FSQRT` `FCMEQ` `FCMGT` `FCMGE`; `SCVTF` `UCVTF` `FCVTZS` `FCVTZU` (vector); `DUP` (element and general), `INS`, `UMOV`/`SMOV`, `EXT`, `ZIP1`/`ZIP2`/`UZP1`/`UZP2`/`TRN1`/`TRN2`, `TBL`, `ADDV`, `FADDP`, `FMAXV`/`FMINV`; `LD1`/`ST1` (one to four registers), `LDR`/`STR Q`. Run `asm_coverage`. Expected: FAIL listing the vector forms.
- [ ] **Step 2:** Add the rows, the arrangement rule (`Q` and `size` from the arrangement as the Arm ARM's table states), vector and lane operands, and samples for every arrangement each row allows. Add to `check/jit-run.l` a 4-lane `FMLA` over two float arrays passed as `"ppp>p"`, checked element by element.
- [ ] **Step 3:** Run `asm_coverage asm_rows_a64 asm_patch jit_run`. Expected: all PASS.
- [ ] **Step 4:** `check/lines`; commit `feat(asm): A64 Advanced SIMD rows`.

### Task 7: x64 scalar integer and floating point

**Implements:** [R-one-entry] (x64), [R-round-trip] (x64), [R-patch] (x64), [R-coverage] (x64 scalar), [R-field-range] (x64)

**Files:**
- Create: `x86.spec` (from `spike/asm/x86.spec`, each row gaining the two validity columns), `x86.g` (from `spike/asm/x86.g`), `asm-x86.l` (from `spike/asm/x86.l` and `x86-gen.l`)
- Modify: `Makefile`, `.gitignore`, `.gitattributes` (`x86.g.l`), `asm-coverage.spec`, `check/asm-rows.l` (x64 printer and samples), `check/asm-patch.l`, `check/asm-interface.l`, `check/check.l` (case `asm_rows_x64`), `check/lines`
- Delete: `spike/asm/x86*.l`, `x86.spec`, `x86.g`, `x86.g.l`, `xcheck*.l`, `cmp.sh`, `enc-*.l`, `load-*.l`, `t0.l`, `dump.l`, `ebp.l`

**Interfaces:**
- Produces: ISAs `x64` and `x86` registered from one `x86.spec`, selecting rows by validity column; registers `RAX`…`R15`, `EAX`…`R15D`, `AX`…`R15W`, `AL`…`R15B`, `SPL` `BPL` `SIL` `DIL`, `XMM0`…`XMM15`; memory `(m64 disp base index scale)` with `RIP` as base.

- [ ] **Step 1:** Add `x64` scalar forms to `asm-coverage.spec` (Coverage lists 1 and 3): `ADD SUB IMUL IDIV DIV CQO CDQ NEG NOT AND OR XOR SHL SHR SAR` (immediate and `CL`), `CMP TEST SETcc` (all conditions), `MOVZX MOVSX MOVSXD MOV` (all widths, `imm64`), `LEA` (RIP-relative), `PUSH POP CALL` (rel32 and `r/m64`) `RET JMP Jcc` (rel8, rel32); `MOVSS MOVSD ADDSS ADDSD SUBSS SUBSD MULSS MULSD DIVSS DIVSD SQRTSS SQRTSD MINSS MAXSS MINSD MAXSD UCOMISS UCOMISD CVTSI2SS CVTSI2SD CVTTSS2SI CVTTSD2SI CVTSS2SD CVTSD2SS MOVD MOVQ XORPS ANDPS ANDNPS` (for negate and abs). Write the failing samples: `asm_rows_x64` against `clang -target x86_64-pc-linux`, every register R8–R15 and XMM8–XMM15 in every position, RIP-relative and SIB-without-base addressing, `imm64`; negative cases `(MOV AH R8B)`, `(MOV AH SIL)`. Run. Expected: FAIL, ISA `x64` unknown.
- [ ] **Step 2:** Promote the spike's x86 encoder into `asm-x86.l` with the `x86-gen.l` compile-at-load approach, then add the RFC's x64 rules: validity columns, `REX.W +`, `REX +`, `io`, mandatory prefixes, REX emission and the high-byte conflict, RIP-relative and SIB-without-base, `d64`/`f64` default sizes.
- [ ] **Step 3:** Run `asm_rows_x64 asm_coverage asm_patch asm_interface`. Expected: all PASS with `x64` added to each.
- [ ] **Step 4:** `check/lines`; commit `feat(asm): x86-64 scalar integer and SSE scalar rows`.

### Task 8: Cross evaluators and running x64 code

**Implements:** [R-cross-eval], [R-jit-run] (x64)

**Files:** Modify `Makefile` (targets `bin/x86_64/eval`, `bin/x86_64/eval2` on arm64 macOS when `arch -x86_64 /usr/bin/true` succeeds; `make check` depends on them there), `.gitignore` (`/bin/`), `check/check.l` (`jit_run` runs once per evaluator: host `./eval2`, then each `bin/*/eval2`, passing the ISA that evaluator runs), `check/jit-run.l` (x64 versions of every case), `check/lines`.

- [ ] **Step 1: Write the failing test:** `jit_run` asserts `jit run x64 ok` from `bin/x86_64/eval2` on this Mac. Run. Expected: FAIL, no `bin/x86_64/eval2`.
- [ ] **Step 2:** Add the Makefile rules (same `CFLAGS`/`OFLAGS`/`LIBS` as the host build, plus `-arch x86_64`, output to `bin/x86_64/`) and the x64 cases (System V calling convention: `rdi rsi …`, `xmm0`, 16-byte stack alignment at calls).
- [ ] **Step 3:** Run `make check`. Expected: `jit run a64 ok` and `jit run x64 ok`.
- [ ] **Step 4:** `check/lines`; commit `feat(jit): x86-64 evaluators under bin/x86_64 and running x86-64 code under Rosetta`.

### Task 9: x64 SSE (packed, to SSE4.1)

**Implements:** [R-coverage] (x64 SSE)

**Files:** Modify `x86.spec`, `asm-x86.l` (operand kinds `xmm/m128`), `asm-coverage.spec`, `check/asm-rows.l`, `check/jit-run.l`, `check/lines`.

- [ ] **Step 1:** Add the packed forms (Coverage list 2) for `PS`/`PD` and integer `B`/`W`/`D`/`Q`: `ADD SUB MUL DIV MIN MAX SQRT AND ANDN OR XOR CMPPS/CMPPD` (predicates), `PADD PSUB PMULLD PMINSD PMAXSD PCMPEQ PCMPGT PAND PANDN POR PXOR PSLL PSRL PSRA` (immediate and register), `CVTDQ2PS CVTTPS2DQ CVTPS2PD CVTPD2PS`, `MOVAPS MOVUPS MOVDQA MOVDQU`, `SHUFPS PSHUFD UNPCKLPS UNPCKHPS PINSRD PEXTRD INSERTPS EXTRACTPS BLENDVPS HADDPS PHADDD`, `MOVD MOVQ`. Run `asm_coverage`. Expected: FAIL listing them.
- [ ] **Step 2:** Add the rows and samples; add an x64 4-lane multiply-add to `check/jit-run.l` (as Task 6's A64 one).
- [ ] **Step 3:** Run `asm_coverage asm_rows_x64 jit_run`. Expected: all PASS.
- [ ] **Step 4:** `check/lines`; commit `feat(asm): x86-64 packed SSE rows`.

### Task 10: x64 AVX and AVX2 (VEX)

**Implements:** [R-coverage] (x64 AVX2)

**Files:** Modify `x86.g` (the VEX token `VEX.L.pp.map.W`), `asm-x86.l` (VEX encoding: two-byte `C5` when `VEX.X`, `VEX.B`, `VEX.W` are 0 and the map is `0F`, else three-byte `C4`; `vvvv` from the operand the row names), `x86.spec`, `asm-coverage.spec`, `check/asm-rows.l`, `check/jit-run.l`, `check/lines`.

- [ ] **Step 1:** Add the `V`-prefixed three-operand forms of every Task 9 form at 128 and 256 bits, plus `VBROADCASTSS VPBROADCASTD VPERMPS VPERMD VPERM2F128 VINSERTF128 VEXTRACTF128 VFMADD231PS VFMADD231PD VMASKMOVPS VZEROUPPER`. Run `asm_coverage`. Expected: FAIL.
- [ ] **Step 2:** Add VEX to the grammar and encoder, the rows, and samples with `YMM8`–`YMM15` in every position (forcing `C4`); add an 8-lane `VFMADD231PS` case to `check/jit-run.l` (runs under Rosetta, which supports AVX2 and FMA).
- [ ] **Step 3:** Run `asm_coverage asm_rows_x64 jit_run`. Expected: all PASS.
- [ ] **Step 4:** `check/lines`; commit `feat(asm): x86-64 AVX and AVX2 rows with VEX encoding`.

### Task 11: 32-bit x86

**Implements:** [R-coverage] (x86), [R-round-trip] (x86), [R-patch] (x86), [R-field-range] (x86)

**Files:** Modify `x86.spec` (validity columns already present; `u` on `INT imm8`, `RET imm16`, `OUT imm8`, `ENTER`), `asm-coverage.spec`, `check/asm-rows.l`, `check/asm-patch.l`, `check/check.l` (case `asm_rows_x86`), `check/lines`.

- [ ] **Step 1:** Add `x86` forms to `asm-coverage.spec`: every `x64` scalar integer form valid in 32-bit mode at 8/16/32 bits, `emit.l`'s 28 mnemonics (list them from `./eval emit.l eval.l` output), and scalar SSE/SSE2 as in Task 7. Write `asm_rows_x86` against `clang -target i386-pc-linux`, with `(INT -5)` and `(RET -1000)` as negative cases that must error. Run. Expected: FAIL, the two negative cases encode instead of erroring.
- [ ] **Step 2:** Mark the unsigned rows `u`; add any missing rows.
- [ ] **Step 3:** Run `asm_rows_x86 asm_coverage asm_patch`. Expected: all PASS, `0 round-trip failures` (the spike had 2).
- [ ] **Step 4:** `check/lines`; commit `feat(asm): 32-bit x86 rows, unsigned immediates marked`.

### Task 12: Close out

**Implements:** all markers, corpus green.

**Files:** Delete what remains of `spike/asm/` (`run.l`, `arun.l`, `jit.c`, `afib-main.c`, `README.md`); modify `CLAUDE.md` (Verify list: `asm_rows_a64`, `asm_rows_x64`, `asm_rows_x86`, `asm_patch`, `asm_coverage`, `asm_interface`, `eval2_subr`, `jit_run`; Build: `bin/x86_64/`), `docs/rfc/0001-table-assemblers.md` (remove the `**Corpus:**` line), `check/lines`.

- [ ] **Step 1:** Run `rfc-run --expect` on the RFC after removing the `**Corpus:**` line. Expected: green, 0 failing blocks.
- [ ] **Step 2:** `make check` on this Mac and on `ndn.lan` (where `jit_run` runs `x64` natively and builds no `bin/`). Expected: all PASS on both.
- [ ] **Step 3:** `check/lines`; commit `chore(asm): retire the spike; the encoder checks are the corpus`.

## Requirement coverage

| Requirement | Tasks |
|---|---|
| R-spec-counted | 1 |
| R-one-entry | 1, 7 |
| R-round-trip | 1, 7, 11 |
| R-field-range | 1, 3, 7, 11 |
| R-patch | 2, 7, 11 |
| R-coverage | 3, 6, 7, 9, 10, 11 |
| R-subr | 4 |
| R-jit-run | 5, 8 |
| R-cross-eval | 8 |
