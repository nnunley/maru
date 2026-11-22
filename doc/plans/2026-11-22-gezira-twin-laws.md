# Gezira twin laws Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generated chains of Gezira's kernels, run by the C build and the native image in one process, their outputs
held within a relative band, through the law engine, failures shrunk.

**Architecture:** a typed-Maru twin driver (`check/gezira-twin.k`) compiled into a C library and into `native_nile`'s
image runs a chain as a Nile pipeline on a float buffer; a Maru support file (`check/laws/gezira-twin.l`) loads both
builds, describes each kernel's types and parameters, generates inputs from (n, seed), and answers whether the builds
agree; `check/laws/gezira-twin.law` generates typed chains by rules and states one law per value type and bridge.

**Tech Stack:** typed Maru (ir-gen-c.k and native-gen.k), Maru on eval (the law runner `check/law.l`), `.law` files.

**Spec:** `doc/plans/2026-11-22-gezira-twin-laws-design.md` (approved 2026-11-22).

## Global Constraints

- Band: relative 1e-5 of the larger magnitude, absolute floor 1e-6; never widened to make a change pass.
- Element counts must be equal; a count difference is printed, not hidden.
- About 30 s of CPU inside `native_nile` for the suite's run; a longer sweep by hand.
- Chains of length 1 to 6 in the suite; fixed seeds.
- Runtime code in Maru languages only; nothing in `nile/` or `gezira/` (submodules) changes: the driver lives in
  `check/`.
- Commit at green with `check/lines` and `check/erosion` entries; Conventional Commits; no AI attribution.

## Review Focus

1. A kernel no generated chain reaches: it passes vacuously. Pinned in Task 2 (the coverage line: every kernel number
   run at least once, or the case fails naming it).
2. A twin that compares a build with itself (both handles the same library): every law passes. Pinned in Task 1 (the
   handles differ, and the perturbed twin is refuted).
3. Parameters out of a kernel's domain (a stroke width of 0, a texture size of 0) make both builds misbehave alike and
   prove nothing, or loop. Pinned in Task 2 (each kernel's parameter generator keeps its range; a chain's run is
   bounded by its output capacity and refused past it).
4. Streams whose length crosses the runtime's buffer for the element size. Pinned in Task 2 (the lengths domain per
   element size, as `check/laws/runtime.law` lists them).
5. Four workers: output order may be the runtime's to choose for some kernels. Pinned in Task 2 (one and four workers;
   where a kernel's output order may vary, the law compares after sorting elements, and says so).

---

### Task 1: The twin driver and one law

**Files:**
- Create: `check/gezira-twin.k` (typed Maru): `gezira_twin_run`
- Create: `check/laws/gezira-twin.l` (Maru support): loading both builds, `twin`, `twin_perturbed`
- Create: `check/laws/gezira-twin.law`: the first laws
- Modify: `Makefile` (`build/gezira-twin.c` and `build/gezira-twin.$(SO)` beside `build/gezira.$(SO)`, the same
  inputs plus `check/gezira-twin.k`; added to `CHECK_LIBS`), `check/check.l` (`native-nile-inputs` adds
  `check/gezira-twin.k`; `native_nile` runs the law file with the image)

**Interfaces:**
- Produces, in `check/gezira-twin.k`: `(gezira_twin_run init chain steps params input count out capacity)` → the
  number of output floats, or -1 if they would pass capacity; `chain` an int array of kernel numbers, `steps` its
  length, `params` the kernels' parameters as floats in chain order, `input` count floats, `out` capacity floats. A
  compositor step's second stream is the next count floats of `params`' tail after its own parameters (the driver runs
  the chain in segments split at compositors and interleaves the colours).
- Produces, in `check/laws/gezira-twin.l`: the kernel table `twin-kernels`, each `(number name in-type out-type
  param-generator)`; `(twin chain n seed workers)` → 0 when both builds' outputs have the same count and every float is
  within the band, else 1 (and prints the first difference); `(twin_perturbed chain n seed workers)` → the same, with
  the native side's first parameter moved by 1e-3, for the self-test; the builds from `NILE_TWIN_LIB` (the C library's
  path) and `NILE_TWIN_IMAGE` (the native image's).

- [ ] **Step 1: Write the failing law file** `check/laws/gezira-twin.law`, `under test: twin, twin_perturbed`, with:
  `law twin_transform_points: all n: number(n), s: seed(s). twin([transform_points], n, s, 1) = 0` (TESTED, 50 trials)
  and `law twin_detects: all n: number(n), s: seed(s). twin_perturbed([transform_points], n, s, 1) = 1` restricted to
  n above 0 (PROVED over its small domain).
- [ ] **Step 2: Run** `env NILE_TWIN_LIB=build/gezira-twin.dylib NILE_TWIN_IMAGE=IMAGE ./eval check/law.l
  check/laws/gezira-twin.l check/laws/gezira-twin.law`. Expected: fails (nothing defines `twin`).
- [ ] **Step 3: Implement** the driver, the Makefile rules, the support file's loading, table entry for
  `TransformPoints`, input generation from (n, seed), and `twin`/`twin_perturbed`.
- [ ] **Step 4: Run** it again. Expected: `law twin_transform_points: TESTED 50` and `law twin_detects: PROVED …`.
- [ ] **Step 5: Wire** into `native_nile` (after the pixel comparison, with `law-file-holds`, the expected lines
  listed), run `make check CHECKS="native_nile lines erosion"`, commit `test(native): a twin of Gezira's C and native
  builds, by the law engine`.

### Task 2: Every kernel, in chains per value type

**Files:** Modify `check/gezira-twin.k` (every kernel's constructor by number), `check/laws/gezira-twin.l` (every
kernel's types and parameter generator, edge values, lengths per element size, the coverage tally),
`check/laws/gezira-twin.law` (chains and laws), `check/check.l` (the expected lines).

**Interfaces:** Consumes Task 1's `twin` and table shape. Produces the rules `bezier_chain`, `point_chain`,
`color_chain`, `number_chain` (each a list of kernels of that type, length 1 to 6, built by a recursive rule over
facts `kernel_type(k, in, out)`) and `bridge_chain` (Bezier to EdgeSample to SpanCoverage to PointCoverage to Point,
`Rasterize`, Point to Number); `(twin_coverage)` → the kernel numbers no case has run, printed.

- [ ] **Step 1: Write the failing laws:** `twin_bezier`, `twin_point`, `twin_color`, `twin_number`, `twin_bridge`,
  each `all c: TYPE_chain(c), n: number(n), s: seed(s), w: workers(w). twin(c, n, s, w) = 0`, TESTED, the trials
  chosen to fit the budget; and a last law `twin_covered: twin_coverage() = []`.
- [ ] **Step 2: Run** the law file. Expected: the new laws fail on unknown kernels, and `twin_covered` lists them.
- [ ] **Step 3: Implement** every kernel's entry (all 76, the compositors with their second stream), the edge
  values (0, -0, ±1, 1e-30, 1e30, alpha 0 and 1, coordinates on whole and half pixels, identity and singular
  matrices), and the lengths per element size crossing the runtime's buffer (122 floats a buffer, as runtime.law
  says), with parameter generators that keep each kernel in its domain.
- [ ] **Step 4: Run** it. Expected: every law TESTED, `twin_covered: PROVED`; the CPU time under 30 s (`/usr/bin/time
  -p`). A REFUTED law is a finding: shrunk, printed, investigated before anything else (systematic debugging), and
  never answered by widening the band.
- [ ] **Step 5: Gates and commit** (`native_nile`, `nile_laws`, `law_rules`, `lines`, `erosion`):
  `test(native): Gezira's kernels in generated chains, twinned between the builds`.

### Task 3: Gezira's algebra

"add them as a fourth task": laws against mathematics, which catch bugs both builds share (the twin can't), run on
the native build through the same driver. Each law states its band (the twin's) or says it is exact.

**Files:** Create `check/laws/gezira-algebra.law` (support: `check/laws/gezira-twin.l`, which gains `run`, one
build's output for a chain, and matrix helpers); modify `check/check.l` (`native_nile` runs it, expected lines).

**Interfaces:** Consumes Task 1's driver and Task 2's kernel table and generators. Produces `(run chain n seed
workers)` → the native build's output floats; `(near a b)` → whether two float lists agree within the band; `(same a
b)` → exact equality; matrix generators (invertible, identity) and `(compose m n)`, `(invert m)`.

- [ ] **Step 1: Write the failing laws:**
  - transforms as a group: `transform_compose` (TransformPoints M then N is near TransformPoints of N·M),
    `transform_identity` (the identity matrix's output is the same as its input, exact), `transform_inverse` (M then M⁻¹
    is near the input), and the same three for `TransformBeziers`;
  - compositing: `over_associative` ((a over b) over c is near a over (b over c), premultiplied colours),
    `over_identity` (transparent over a, and a over transparent, the same as a, exact), `clear_absorbs`,
    `src_dst_project`, and `separable_commutes` for each blend mode symmetric in its definition;
  - coverage: `coverage_translates` (a whole-pixel translation moves the coverage, the same values), `coverage_additive`
    (two disjoint rectangles' coverage sums is near their union's), `reverse_involution` (ReverseBeziers twice is the
    same as the input, exact);
  - gradients: `gradient_affine` (a linear gradient's projection of a mid-point is near the mid-point of the
    projections);
  - its own refutation check: `algebra_detects`, the composition law stated with N·M swapped for M·N on non-commuting
    matrices, REFUTED.
- [ ] **Step 2: Run** `env … ./eval check/law.l check/laws/gezira-twin.l check/laws/gezira-algebra.law`. Expected:
  fails on the undefined `run`, `near`, `compose`.
- [ ] **Step 3: Implement** the helpers and generators.
- [ ] **Step 4: Run** it. Expected: each law TESTED or PROVED as stated, `algebra_detects` REFUTED; a law that fails
  is a finding about Gezira or the native build (checked against the C build with the twin before it is called
  either), never answered by widening a band; within the 30 s budget with Task 2's laws.
- [ ] **Step 5: Gates and commit:** `test(native): Gezira's algebra (transforms, compositing, coverage) as laws`.

### Task 4: Close

- [ ] **Step 1:** `doc/laws.md` and `doc/native.md` describe the twin laws (the driver, the band, the chains, the
  coverage law, how to run a longer sweep by hand).
- [ ] **Step 2:** the full suite on a quiet machine on AC.
- [ ] **Step 3:** whole-branch review by a fresh reviewer with this plan's Review Focus; fix Critical and Important
  test first.
- [ ] **Step 4:** report to the user, then resume `doc/plans/2026-11-21-register-allocation.md` at Task 2.
