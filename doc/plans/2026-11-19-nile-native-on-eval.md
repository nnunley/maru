# Nile loaded natively, around the kernel

## Intent

Untyped Maru loads a Nile program and runs its kernels as native code in its own process. Kernels are composed into
pipelines in Maru Lisp, and the records Maru holds (a process, a kernel's parameters, an image) are Maru objects, read
by field.

The grounded kernel (`doc/kernel.md`, the evaluator in typed Maru on the object level) is where this lands. Once the
kernel is the running evaluator, typed and untyped Maru share one object model, one heap and one set of type ids.
Nile's runtime and Gezira are then more typed Maru, compiled in the same process, and no bridge between two worlds is
needed. Today's evaluators can't do that, so this plan does now only what carries over to the kernel unchanged, and
builds nothing the kernel will make unnecessary.

## Where things stand

- **The library path.** `gezira.nl` goes through Nile's Maru back end to typed Maru (`build/gezira.k`, 341K). Then
  `ir-gen-c.k` and `maru.k` on `eval2` turn it into C (11.6 s for the runtime and Gezira together, measured
  2026-11-19), and `cc` builds `build/gezira.dylib`. `gezira-maru.l` opens it with `dlopen` and states eleven
  signatures by hand.
  - `gezira-api.k` fixes the pipelines (`gezira_fill`, `gezira_fill_image`, `gezira_fill_clipped` and the
    image-clipped one) in typed code. Untyped Maru can't compose kernels.
  - Handles are longs, so Maru can't read a process.
- **The native path has a bug.** `native.l` compiling the same unit on `eval2` ran past 84 CPU-minutes without
  finishing. The researchers' tools compiled units like this quickly, and the C back end takes 11.6 s on the same
  front end, so this is a defect, not a cost. What is known:
  - A C-level sample (`sample`, 10 s, a minute into the runtime alone) puts about 73% of the time in the collector:
    `GC_mark`, `GC_default_mark_function`, `GC_sweep` and `GC_malloc`. Interpretation is about 16%. `memset` and
    `set-string-at` are also visible.
  - The runtime without `nile-builtins.k` gets through the front end in 3.6 s of CPU, then stops on a reference into
    the missing builtins. With `nile-builtins.k` (41K, with the largest functions: Zip, DupZip, SortBy), the runtime
    doesn't finish in 10 minutes.
  - The collector paces itself by the live object count (`GC_collectAndPace`), which keeps marking proportional to
    allocation unless a few very large objects dominate the live heap.
  - Candidates, not yet tested:
    - `asm-table.l` keeps one tagged word per code byte in one growing array, which is marked whole on every
      collection.
    - `native-link.l`'s `native-form-text` builds text by repeated `concat-string`, which is quadratic.
    - Something per function in `native-gen.k` or the arm64 lowering may be superlinear in the function's size.
- **The kernel** boots `boot2.l` and runs `repl.l` and `test-repl.l` as `eval3` does, with the 55 primitives those
  files use, measured. It has no `subr` (no FFI), no byte, int32 or float accessors, and no undo log. Its 13 built-in
  types and their ids are its own. RecoverableErrors, Interrupts, KernelCollector and Utf8Text are next in
  `notes/plan/kernel.john`.
- `maru.k` and `native.l` run on `boot2.l` (on `eval2`), the boot file the kernel already loads. `code-region.l` reaches
  `mmap`, `dlsym` and `pthread_jit_write_protect_np` through `subr`.
- `eval`'s collector is single-threaded, stop-the-world and non-moving (`gc.c`), and so is `maru-gc.k`'s, which the
  kernel uses. An object doesn't move, and only one thread may allocate.

## Goals

- The native path compiles the Nile runtime and Gezira in time comparable to the C back end.
- Nile's kernel constructors, `pipe`, `feed`, `sync`, `startup` and `shutdown` are callable from Maru, and pipelines
  (including the clipping stages `ksworld-render.l` builds) are composed in Maru Lisp. `gezira-api.k`'s fixed pipelines
  go away.
- The records Maru holds are Maru objects of their own types (`define-object`), read by field.
- On the kernel, a Nile program is compiled in-process and called without any signature written by hand.
- The same pixels throughout: `gezira_image`, `gezira_maru`, `gezira_scene` and `ksworld_pixels` keep their
  assertions.

## Non-goals

- Self-describing libraries and a loader that rebuilds types and signatures from them (the first draft of this plan).
  They bridge the C evaluator to typed code, and the kernel removes that gap.
- Making the C evaluators compile typed Maru in-process. `eval` keeps using the library path until the kernel replaces
  it.
- New Nile semantics. The 2016 Gezira source and the runtime in `nile/runtimes/maru` are used as they are.

## Anti-goals

- Treating the native path's time as a performance target. It's a bug, and it's found before anything depends on it.
- Worker threads allocating in Maru's heap, or reading an object the collector may free.
- C written by hand (`maru-runtime-in-maru-languages`).

## Approaches

1. **Around the kernel (chosen).**
   - Fix the native path first.
   - On today's library path, do only what carries over: Nile's records as objects, pipelines composed in Maru, and
     the threads rule.
   - Then move Nile onto the kernel, where compiling in-process removes the bridging.
2. **Self-describing libraries for `eval` (the first draft).** Ruled out: a description string, a loader and type ids
   bound at load exist only because the C evaluator and typed code are separate worlds. The kernel joins them.
3. **Wait for the kernel entirely.** Ruled out: the objects, the pipelines in Maru and the threads rule don't depend on
   the kernel. Doing them now on the library path tests them against the pixel checks we already have, and the kernel
   inherits them unchanged.

## Part A: now, on today's evaluators

### A1. The native path's bug

- Find it with `superpowers:systematic-debugging`. Reduce a builtin (Zip or SortBy) to the smallest function that
  shows the growth, then time it at two sizes to establish the curve.
- Profile at Maru's level. `eval2`'s `-p` profiler is commented out (`eval2.c:3269`, `3617`) while `eval`'s works.
  Restoring it in `eval2` is part of the step, since it is the tool that names the Maru function.
- The fix goes in Maru (`native-gen.k`, `native.l`, `asm-*.l` or `native-link.l`), never in the collector's pacing to
  hide it.
- Check `native_nile`: `native.l` compiles the Nile runtime and `build/gezira.k` in one unit on `eval2` within a bound
  set from the C back end's time (a small multiple of it, set once the curve is known), on the check's own budget.
  `native_ir2`'s programs still pass.

### A2. Pipelines composed in Maru

- The runtime's entry points (kernel constructors, `pipe`, `feed`, `sync`, `startup`, `shutdown`) and Gezira's kernel
  constructors are exported from the library. `gezira-api.k` keeps only what isn't a pipeline: the image's helpers
  (`gezira_image_new`, `gezira_pixel`, `downsample`, `premultiply`).
- `gezira-maru.l` composes each pipeline `gezira.l`'s selectors need, the clipping stages included. Its signatures stay
  hand-written, in that one place, until Part B removes them.
- `gezira_maru`, `gezira_scene` and `ksworld_pixels` keep their assertions. Lines and erosion get ledger entries.

### A3. Nile's records as Maru objects

- The process handle, a kernel's parameters and the image become `define-object`s in the runtime, allocated with `new`
  through the unit's `gc_malloc`. In a library opened by `eval`, that resolves to `eval`'s exported `GC_malloc`
  (`SOCFLAGS` links with `dynamic_lookup`).
- Their fields are ints, floats and pointers into Nile's own heap, never Maru references, so they are `atom`.
- **Ids on today's evaluators.** A library can't fix a host's type ids, so each object type's id is a global that
  `gezira-maru.l` sets once, beside its signatures, from the type it defines. This is the one bridge Part A keeps, and
  Part B deletes it.
- Untyped Maru reads fields through accessors `gezira-maru.l` defines. A float field may need a primitive. If so, it is
  written in a Maru language.
- **Threads.** Only the evaluator's thread allocates Maru objects: constructors, `pipe` and `startup` are called from
  Maru. Workers never call `gc_malloc`. Stream buffers, the scheduler's queues and every field the workers write stay
  in Nile's heap (the memory `nile_startup` is given). A worker reads a Maru object only while Maru keeps it reachable,
  and the handle's object holds the Nile process, never the reverse. `feed` keeps its argument reachable until
  `sync`.
- Check: the A2 checks pass with a collection on every allocation (`GC_collect_every`), which shows the objects
  survive and nothing is freed under a worker.

## Part B: on the kernel

B builds on the kernel's BootsAndRepl (done) and comes after RecoverableErrors and Interrupts, already planned. A
library load that fails, or a Nile error, should unwind to the REPL, not kill it. B doesn't wait for KernelCollector:
`maru-gc.k`'s collector suffices.

### B1. The kernel runs `maru.k` and `native.l`

- Measure the primitives they use as the Primitives capability measured `boot2.l`'s: a counting run plus a read of
  the source. The kernel gains exactly those, `subr` (the FFI) presumably among them, since `code-region.l` needs
  `mmap` and the JIT write protection.
- Check: the kernel compiles `check/native/add.k` in-process and runs it, giving `native_ir2`'s Task 1 answer.

### B2. Compiled code called as the kernel's own

- A compiled unit's functions become `<subr>`s whose `imp` is the native entry. The calling convention comes from the
  compiler's own types (`*maru-exports*`), held in the same process, so no signature text exists anywhere.
- A unit's `define-object` types are the kernel's types: the ids are the kernel's own, assigned as the unit is
  compiled, so nothing is bound at load. A3's id globals and A2's hand-written signatures are deleted.

### B3. Nile on the kernel

- `text-layout.nl`, compiled in-process on the kernel, lays its four glyphs out as `nile_text_layout` does: (0,0)
  (3,0) (6,0) (0,1), on 1 and 8 workers, with a pipeline composed in Maru.
- Then Gezira: `gezira.l`'s selectors on the kernel give `gezira_maru`'s and `gezira_scene`'s pixels.

### B4. Keeping compiled units

- With A1 fixed, compiling Gezira should take seconds, but not at every start-up. A compiled unit is kept as a shared
  library written by Maru itself (`exe.l`, extended to `MH_DYLIB` and `ET_DYN`), so `cc` leaves the build.
- The library carries the unit's declarations (exports and object types), written and read by the kernel alone. It is
  a cache's index, one program talking to itself, not a bridge. It is reused only while its source is unchanged.
- Check: the second run loads the kept library without compiling, and gives the same pixels.

## Checks and docs

- `native_nile` (A1) in `doc/native.md`. A2 and A3 change what `gezira_maru` asserts, in `doc/nile.md`. B's checks are
  in `doc/kernel.md`, and `exe.l`'s shared objects in `doc/assemblers.md`.
- `notes/plan/render.john` gains NativeNileCompiles, PipelinesInMaru and NileObjects. `notes/plan/kernel.john` gains
  KernelCompiles, KernelCallsCompiled, NileOnKernel and KeptUnits, with their `builds-on`.

## Left to the builder

- Accessor names, and how A2 exports the runtime's entry points.
- The `native_nile` bound, once A1 has the curve.
- Whether a float field needs a primitive.

## Open

- **A running process's own state as Maru objects.** The plan makes handles and parameters objects, and keeps what
  workers write in Nile's heap, because both collectors are single-threaded. Putting a running process's state in
  Maru's heap would need the collector to stop the workers (a safepoint in Nile's scheduler) or those objects pinned
  while scheduled. Left until B3 works.
