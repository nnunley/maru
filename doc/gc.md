# Garbage collector

The collector in C and the one written in Maru, held to laws over generated graphs and programs.

## Checks

- `maru_gc`: the GC written in Maru allocates 2.56M cells, collects, and
  frees everything.
- maru-gc.k's `gc_frequency` is a variable (collect when the allocations since the last collection reach it), so a
  check can collect on every allocation (`kernel_native`, doc/kernel.md). Its `gc-protect` pops the roots it pushed last
  first; with two or more variables it once popped them in pushed order (`reverse-map` keeps a list's order), which
  `gc_pop_root` refuses as "non-lifo root".
- `maru_gc_coalesce` (`check/gc.k`): its allocator grows the heap when needed
  and merges adjacent free chunks.
- `gc_laws` (`check/laws/gc.law`): over graphs rules generate, in a forked child per question, on every evaluator: what's
  reachable survives and what isn't is freed, sharing and cycles hold, marking can't overflow the stack, the heap's books balance
  (`GC_check_heap`), worlds and throws keep all that, and `(set-heap-limit bytes)` reached is an error that can be recovered from,
  repeatedly, without the reserve creeping, and running out again with no room made is a final exit. Free blocks are in lists by
  size, so a small allocation walks nothing; blocks over a thousand bytes share one list.
- `gc_model` (`check/laws/gc-model.law`, `gc-model-paced.law`): generated programs (writes to a few slots, nested worlds that
  end, fail or are thrown out of, collections) run on real objects and on a pure model, and must agree in everything observable
  (both use `check/laws/gc-programs.law`: the rules that make the programs, and what each means, `model_run` on the model and
  `real_program`, closures over real objects; a model that kept a failed body's writes is refuted),
  with an empty log and balanced heap after; allocation sequences of many sizes; collections every allocation and every seventh.
  A world keeps one record per slot however often it writes it, and a commit hands its parent only what the parent lacks, so a
  loop in a `try` doesn't grow the log, though each call that sets a fresh local still adds a record. Generators are aimed by
  deliberate bugs: reintroduce one and count the seeds that catch it.
  A law file's limit is CPU time (300 s, `RLIMIT_CPU`, with an alarm at four times as long for a run that blocks), and so
  is each question's (`law.l`'s `law-limit`, 60 s, 10 s for Nile's), so cases or agents running beside them can't fail
  them by contention; each run keeps its own output, and a failure prints its
  last lines. Alone, each `gc_model` file takes 45 to 83 s; nearly all of it is the collector marking the heap the
  forked question inherits from the law runner.

Not yet described here (each has a comment above it in `check/check.l`): `gc_image`.
