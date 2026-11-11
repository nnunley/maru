# Nile and Gezira

Nile's compiler on Maru, its runtime in typed Maru, Gezira, and the runtime's laws and schedules.

## Checks

- `nile_compile` (`check/check.l`): `nile/compilers/maru/nile-to-maru-compiler.sh`
  runs Nile's compiler on `eval2` and `boot2.l`, and writes the same Maru
  for `nile/examples/text-layout.nl` as `eval` and `boot.l` do.
- `nile_text_layout` (`check/check.l`): `text-layout.nl`, compiled by `nile-to-maru-compiler.sh` as module `text_layout`,
  runs through the Maru runtime (`nile/runtimes/maru/test/text-layout.k`) with 1 and 8 workers and lays four glyphs out
  as (0,0) (3,0) (6,0) (0,1).
- `gezira_vector` (`check/gezira-vector.k`, `check/gezira/vector-kernels.nl`): Gezira's `Vector` arithmetic, run. Two kernels
  appended to `gezira.nl` add vector pairs and a number to a vector through Nile's Maru back end and the runtime, and the
  sums are vector sums: `(1, 2) + (10, 20)` is `(11, 22)`, `(1, 2) + 5` is `(6, 7)`. A departure from the 2016 source: its
  `u:Vector + v:Vector` answered `(x1 + y1, x2 + y2)`, each vector's own components summed (`(3, 30)` here); the fork
  (`gezira` on `maru-runtime`) answers `(x1 + x2, y1 + y2)`. No kernel of Gezira's own adds two vectors, so nothing it draws
  changes (its compiled kernels are byte for byte the same either way), and this case is the rule's only check.
- `gezira_image` (`check/check.l`): `gezira/nile/gezira.nl`, Gezira in the 2016 Nile dialect, compiled by Nile's Maru back end
  and built with the runtime, with `nile/runtimes/maru/gezira-image.k` (the ARGB32 composite) renders a 40 by 30 rectangle at
  (10.5, 20) through TransformBeziers, ClipBeziers, Rasterize and ApplyTexturer: full pixels red, edge columns half covered, the
  rest white, on 1 and 4 workers (`nile/runtimes/maru/test/gezira-image.k`).
- `gezira_maru` (`check/check.l`, `check/gezira-maru.l`): the Gezira library `build/gezira.dylib` (make builds it from
  `gezira/nile/gezira.nl` and the runtime) through `gezira-maru.l`'s `<gezira-maru>` selectors renders the `gezira_image`
  rectangle with a matrix, on 1 and 4 workers. `gezira_scene` (`check/gezira-scene.l`) draws `check/ksworld/scene.pp`
  the same way.
- `nile_laws` (`check/laws/runtime.law`, `check/laws/runtime.l`): through the batch driver `nile/runtimes/maru/test/law-runtime.k`,
  built with text-layout.nl's module, every law by exhaustion over lengths 0, 1, 2, 3, 5, 60 to 62, 121 to 123, 244 and 245
  (a buffer holds 122 floats: one and two buffers crossed for streams of floats and of pairs) and seeds 1 and 7. The
  built-ins hold to their definitions on 1, 4 and 8 workers (pass is the identity, reverse reverses and twice is the identity,
  dupcat is its input twice, dupzip interleaves it with itself, sort orders keys and permutes its pairs: 78 cases each), and
  give on 4 and 8 workers what they give on one (260). text-layout.nl's own conditions, at line widths 5, 12 and 30 (234
  each): MakeWords' words partition the glyphs (runs of one style as wide as their glyphs, past one glyph at most the width,
  each run's first glyph splitting from the word before, the initial empty word output only when the first glyph splits from
  it); InsertLineBreaks keeps the words, a word continuing a line is style 1 or fits, and a break comes only before a word not
  of style 1 that doesn't fit after the line before it; and each glyph's point is the width of the glyphs before it on its line
  and the line's number. All three stages agree on 4 and 8 workers with one (468). Glyph styles and widths come from a
  linear congruential sequence, so neither style's runs have a fixed length. A no-op InsertLineBreaks fails `breaks_fit`, one
  that breaks before every word `breaks_maximal`, MakeWords without its width split `words_partition`, and PlaceWords
  without its line feed or its return to the margin `points_placed`. The driver exits 2 on a missing or unknown mode or a
  worker count outside 1 to 64. `make check-sweep` runs the file once on each evaluator.
- `nile_schedules` (`check/laws/runtime-schedules.law`): the runtime's contracts over schedules. The batch driver takes a
  schedule as its fifth argument: a number seeds `nile-sync.k`'s scheduler, under which the threads take turns (one at a
  time; at every `nile_lock` the runnable thread of highest priority runs, a thread's priority dropping below every other's
  at change points: PCT, Burckhardt et al.), and `pct:P0,P1,.../C1,C2,...` gives that schedule in full. A run keeps the
  contracts when no buffer with data is dropped for want of a consumer, no process is queued while it runs or after it was
  freed, every block is back in a heap after the sync and no schedule runs out of runnable threads (`nile_dropped`,
  `nile_requeued`, `nile_unreturned`, `nile_deadlocks`; the driver prints them last, and lists the live processes when
  blocks stay out). The law generates the PCT schedule term (three or more priorities, three change points up to 400) and
  claims, in the law file, that the contracts are all 0 and the output is one worker's, for text-layout's three stages and
  the built-ins, and for a kernel that reroutes in its body as Nile's → substitution does (Gezira's `StrokeOneSide`;
  `test/reroute-kernels.k`, over `0 .. 1499` rerouting at 750, thirteen buffers): TESTED 1000 each, never PROVED, as a
  schedule is one interleaving of very many. Every wakeup decides and claims in one critical section
  (`nile_Process_claim_locked`), and a reroute decides in the section that clears the process's body, so a process is
  never woken or removed twice, nor acted on after another waker freed it. With the races fixed on
  2026-11-06 put back, 1000 trials refute the funnel's lost wakeup and a kernel saving its input position in a buffer handed
  in since, and the schedule that exposes each is kept in the law file as a value (`found`: words at seeds 1144 and 98)
  and checked by exhaustion, PROVED for just those schedules; each race put back fails its own. A change to the scheduler
  or runtime moves what a seed gives (the claims did: the earlier seeds stopped exposing anything), so then put each race
  back and find its schedule anew. The double queue has none: put back on the claiming runtime, 22500 schedules found
  nothing, so only `nile_Process_claim_locked`'s test holds it. Enumerating every schedule within two preemptions, or two
  delays of a round robin, found none of the races.

Not yet described here (each has a comment above it in `check/check.l`): `nile_dupcat`, `nile_interface`, `nile_leaks`, `nile_limits`, `nile_oom`, `nile_osdefs`, `nile_prefix`, `nile_recip`, `nile_reroute`, `nile_reverse`, `nile_sort`, `nile_startup`, `nile_zip_stream`, `gezira_many`, `gezira_oom`.
