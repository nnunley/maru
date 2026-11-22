# Gezira twin laws: design (short)

Status: draft for approval, 2026-11-22. Branch nile-native-eval. A behaviour check to land before step 1's Task 2
(`doc/plans/2026-11-21-register-allocation.md`), the first change to generated code.

## Intent

The pixel check (`native_nile`, `check/gezira-pixels.l`) runs five scenes, mostly plain fills composited Over; most of
Gezira's 76 kernels never run in it, among them `CompositeSoftLight`, whose body needs the most held registers (12).
The user asked for "a twin quickcheck/proptest style run comparing each of the key operations", and then: "try chains of
various lengths of operations on each of the value types for Nile." So: generated chains of Gezira's kernels, run on
generated inputs by the C build and by the native image, their outputs held to each other, failures shrunk.

## Goals

- Every Gezira kernel runs in some generated chain, the compositors each with both inputs varied.
- A chain differs between the builds only by rounding: each output float within a relative band of the other's.
- A failure is shrunk (a shorter chain, a shorter input, plainer numbers) and printed as the chain, its parameters
  and its input, so it can be replayed by hand.
- Deterministic in the suite (fixed seeds), with a longer sweep by hand (more seeds, longer chains).

## Non-goals

- Pixel scenes (the pixel check stays as it is); x64 (arm64 native image only, as `native_nile`).
- Comparing against Gezira's own definitions (the C build is the oracle; both could be wrong together).

## Anti-goals

- A band that hides a wrong value: it is relative, 1e-5 of the larger magnitude with an absolute floor of 1e-6, and
  never widened to make a change pass.
- Most of the suite's time: a budget of about 30 s of CPU inside `native_nile` (the image is already made there).

## Approaches

1. Twin laws through the existing law engine (chosen): `rules.l` generates and shrinks, `.law` files state the laws,
   and one process holds both builds (with commit 8c218b9 a native image binds its own functions, so the C library and
   the image load side by side and are called directly, per case, with no process per question).
2. More pixel scenes, one per blend mode: covers the compositors only, by hand, and judges through rounding to bytes.
3. A twin runner of its own in Maru, with its own generator: duplicates the law engine's generation and shrinking.

## The design

- **Value types and chains.** Each kernel is described once by its input type, output type and parameter types
  (Nile's types as fixed groups of floats: Number 1, Point and Vector 2, Color 4, Matrix 6, Bezier 6, EdgeSample,
  SpanCoverage and PointCoverage 4). A chain is a sequence of kernels whose types meet: a run within one type (Bezier
  to Bezier, Point to Point, Color to Color, Number to Number) or crossing types through the bridges (Bezier to
  EdgeSample to SpanCoverage to PointCoverage to Point, `Rasterize`, Point to Number through the gradients). Chains of
  length 1 to 6 in the suite. A compositor in a chain takes the chain's colours as its first input and a generated
  colour stream as its second, so a colour chain composites one layer after another.
- **The twin driver**, `check/gezira-twin.k` (typed Maru, compiled with Gezira into both builds: a C library beside
  `build/gezira.$(SO)` by make, and the native image `native_nile` already makes): one entry point that takes a chain
  (kernel numbers and their parameters as floats), an input buffer and its element count, builds the chain as a Nile
  pipeline (`nile_Process_pipe`), pours the input (`nile_Funnel_pour`), captures the output, and answers its float
  count, on a runtime of one worker or four. A compositor's second stream is zipped in by the driver.
- **The laws**, `check/laws/gezira-twin.law`: one law per value type's chains and one per bridge, `twin(chain, input,
  workers)` holding, which runs both builds and is true when the element counts are equal and every float is within
  the band. Domains: chains by type (a recursive rule over the kernel table), parameters and inputs by type, with
  ordinary values drawn by seed and edges listed (0, -0, ±1, tiny, huge, alpha 0 and 1, coordinates on pixel edges,
  identity and singular matrices), and stream lengths crossing the runtime's buffer boundaries for the element size
  (as `check/laws/runtime.law` lists them).
- **Where it runs:** `native_nile`, after the pixel check, with the image it made. `doc/laws.md` and `doc/native.md`
  describe it.

## Open to the builder

- How `rules.l` expresses typed chains (a recursive rule is the intent; whatever it needs is the builder's).
- Which kernels need parameters kept in a valid range (a stroke width above 0, a texture size above 0) and how.
- The edge values' exact lists, and the seeds and case counts that fit the budget.

## Risks

- Rounding can change a count near a boundary (a point exactly on a clip edge fused differently): the law then fails
  without a bug. If it happens, the case is printed; the band does not grow to hide it, and how to state such a law is
  decided then.
- Kernels with no output stream (`ApplyTexturer`, `CalculateBounds`, `BeginGradientColor`) are compared through what
  they write or answer instead; the driver says how for each.
