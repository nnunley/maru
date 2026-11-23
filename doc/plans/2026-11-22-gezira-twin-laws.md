# Gezira twin laws Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or
> superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Generated chains of Gezira's kernels, run by the C build and the native image in one process, their outputs
held within a relative band, through the law engine, failures shrunk.

**Architecture:** a typed-Maru twin driver (`check/gezira-twin.k`) compiled into a C library and into `native_nile`'s
image runs a chain as a Nile pipeline on a float buffer; a Maru support file (`check/laws/gezira-twin.l`) loads both
builds, describes each kernel's types and parameters, maps the engine's drawn integers to floats, and answers whether the builds
agree; `check/laws/gezira-twin.law` generates typed chains by rules and states one law per value type and bridge.

**Tech Stack:** typed Maru (ir-gen-c.k and native-gen.k), Maru on eval (the law runner `check/law.l`), `.law` files.

**Spec:** `doc/plans/2026-11-22-gezira-twin-laws-design.md` (approved 2026-11-22).

## Global Constraints

- Band: relative 1e-5 of the larger magnitude, absolute floor 1e-6; never widened to make a change pass.
- Element counts must be equal; a count difference is printed, not hidden.
- About 30 s of CPU inside `native_nile` for the suite's run; a longer sweep by hand.
- Chains of length 1 to 6 in the suite; a fresh seed each run (MARU_LAW_SEED, printed); edge cases exhausted every run.
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
  param-generator)`; `(twin chain ps xs workers)` → 0 when both builds' outputs have the same count and every float is
  within the band, else 1 (and prints the first difference), ps and xs lists of integers the engine drew (parameters
  and input values), each k the float k/16; `(twin_perturbed chain ps xs workers)` → the same, with the native side's
  first parameter moved by 1e-3, for the self-test; `(twin_edges chain workers)` → 0 when both builds agree on every
  edge case of the chain's types (edge values and buffer-crossing lengths, enumerated by the support file), else 1;
  the builds from `NILE_TWIN_LIB` (the C library's path) and `NILE_TWIN_IMAGE` (the native image's).
- Ruling ("Why are we using hardcoded seeds?" … "yes, switch it"): no seed appears in a law. The engine draws the
  cases, its seed fresh each suite run: `native_nile` picks one, passes `MARU_LAW_SEED` (the engine's override) and
  prints it; a REFUTED line carries `seed=s`, which `MARU_LAW_SEED` replays.

- [ ] **Step 1: Write the failing law file** `check/laws/gezira-twin.law`, `under test: twin, twin_perturbed,
  twin_edges`, with rules building `params6` (six numbers) and `points` (a list of number pairs) from `number`, numerals
  `[-2000 .. 2000]`, and: `law twin_transform_points: all ps: params6(ps), xs: points(xs). twin(["TransformPoints"],
  ps, xs, 1) = 0` (TESTED), `law twin_transform_points_edges: twin_edges(["TransformPoints"], 1) = 0` (PROVED), and
  `law twin_detects: all ps: params6(ps), xs: points(xs). twin_perturbed(["TransformPoints"], ps, xs, 1) = 1`
  (TESTED; points is never empty).
- [ ] **Step 2: Run** `env NILE_TWIN_LIB=build/gezira-twin.dylib NILE_TWIN_IMAGE=IMAGE ./eval check/law.l
  check/laws/gezira-twin.l check/laws/gezira-twin.law`. Expected: fails (nothing defines `twin`).
- [ ] **Step 3: Implement** the driver, the Makefile rules, the support file's loading, table entry for
  `TransformPoints`, the integer-to-float mapping, the edge cases, and `twin`, `twin_perturbed`, `twin_edges`; and in
  `check.l` the fresh seed (from `/dev/urandom`), passed as `MARU_LAW_SEED` and printed.
- [ ] **Step 4: Run** it again, and with two different `MARU_LAW_SEED`s. Expected: `twin_transform_points: TESTED n`,
  `twin_transform_points_edges: PROVED 1`, `twin_detects: TESTED n`, on both seeds.
- [ ] **Step 5: Wire** into `native_nile` (after the pixel comparison, with `law-file-holds`, judged by its exit status,
  verdicts printed), run `make check CHECKS="native_nile lines erosion"`, commit `test(native): a twin of Gezira's C and native
  builds, by the law engine`.

### Task 1b: Extremes drawn by the property tester

From the design's "Extremes drawn, not listed". The engine's own changes come first, each test first; then the twin
uses them.

**Files:** Modify `rules.l` (lazy choices, hashed membership, the `float` builtin and its generator), `check/law.l`
(float shrinking), `check/laws/gezira-twin.l` and `.law` (floats, computed lengths, no edge list); create
`check/laws/fixtures/float.law` (+ its support if needed); `check/check.l` (`law_rules` runs the fixture).

**Interfaces:** Produces the domain `float(x)` in law files and rules: x a double holding a float32 value; families
`simple`, `wide`, `boundary`, drawn about a third each; `(rules-float-family x)` → the family name of a value, for the
fixture's classes; the shrink order 0, |x|, the integer part, x with its low half of mantissa bits cleared, x with its
exponent halved toward 0.

- [ ] **Step 1: Failing cases.** `check/laws/fixtures/float.law`: classes over `float(x)` draws, `cover` at least 5%
  each of zero, subnormal (0 < |x| < 2^-126), huge (|x| > 2^100), infinite, near 2^24 (within 4 of it), and the
  rest; a false law `all x: float(x). x < 1000` REFUTED with its shrunk value pinned (expected to shrink to 1024,
  the simplest float32 not below 1000); and a timing case in `check/rules-test.l`: 100 draws of `number(n)` from a
  numerals list of 100,000 take under a second.
- [ ] **Step 2: Run** `./eval check/law.l check/laws/fixtures/float.law` and `./eval check/rules-test.l`. Expected:
  float is unknown; the timing case fails (a full shuffle per draw).
- [ ] **Step 3: Implement** lazy choices and hashed membership, the generator, the domain and its shrinking.
- [ ] **Step 4: Run** the fixture, `law_rules`, `law_engine`, `law_cexpr`, `nile_laws`, `gc_laws` (their pinned and
  status-judged results unchanged).
- [ ] **Step 5: The twin** draws parameters and inputs with `float`, lengths as k × capacity + d (capacity the
  runtime's 122 floats over the element size), and drops `twin_edges`; `twin_detects` keeps a perturbation that a
  float input can't hide (it moves the translation by the band times the largest output, plus 1). Run on two fresh
  seeds; gates; commit `test(laws): a float domain drawn from float32's own structure, and draws that cost their
  tries`.

### Task 2: Every kernel, in chains per value type

**Files:** Modify `check/gezira-twin.k` (every kernel's constructor by number), `check/laws/gezira-twin.l` (every
kernel's types and parameter generator, edge values, lengths per element size, the coverage tally),
`check/laws/gezira-twin.law` (chains and laws), `check/check.l` (the expected lines).

**Interfaces:** Consumes Task 1's `twin` and table shape. Produces the rules `bezier_chain`, `point_chain`,
`color_chain`, `number_chain` (each a list of kernels of that type, length 1 to 6, built by a recursive rule over
facts `kernel_type(k, in, out)`) and `bridge_chain` (Bezier to EdgeSample to SpanCoverage to PointCoverage to Point,
`Rasterize`, Point to Number); `(twin_coverage)` → the kernel numbers no case has run, printed.

- [ ] **Step 1: Write the failing laws:** `twin_bezier`, `twin_point`, `twin_color`, `twin_number`, `twin_bridge`,
  each `all c: TYPE_chain(c), ps: params(c, ps), xs: TYPE_input(xs), w: workers(w). twin(c, ps, xs, w) = 0` (the
  parameters drawn for the chain's kernels), TESTED, beside a `twin_edges` law per chain kind; the trials
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

**Interfaces:** Consumes Task 1's driver and Task 2's kernel table and generators. Produces `(run chain ps xs
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
