# Nile runtime in typed Maru

## Goal

Nile programs compiled through Maru run end to end, natively on arm64 macOS
and x86-64 Linux. The runtime they call is written in Maru's typed Lisp and
calls libc and pthreads through `extern` declarations. C appears only as the
compiler's output.

This is the first of three specs toward the windowed Nile demos:

1. **This spec:** the runtime, `text-layout.nl` end to end, and the runtime's
   tests.
2. Gezira's kernels through Maru, with its image kernels in typed Maru. A
   scene renders to an image file that matches the old C runtime's.
3. Typed GLFW 3 and GL bindings, and the snow demo driver in typed Maru:
   snowflakes in a window on both hosts.

## Non-goals

- Kernels with several input or output streams, such as the 2011 report's
  Fibonacci circuit. Nile's design has one input and one output per kernel.
- Writing the runtime in Nothing. Nothing has a grammar here but no compiler,
  and its grammar has no way to call C.
- Native code generation. The runtime compiles through `ir-gen-c.k` and `cc`
  until Maru's native back ends exist.
- Performance beyond the C runtime's. The design stays the C runtime's so the
  two can be compared; tuning comes later.

## Background

Nile's `master` has two code generators, one emitting C and one emitting
typed Maru. Both target a new kernel interface. Amelang declared that
interface in `runtimes/c/nile.h` in commit `aa3e179` (2012-12-21, "The new Nile
runtime API has landed. Implementation forthcoming."), and in
`runtimes/c/nile.k` for Maru. The implementation never landed. The C runtime
still implements the old interface, and it is x86-only: it uses
`_mm_pause`, `xchg` and `mfence`.

Checked on 2026-10-15:

- The Nile compiler runs on `eval` and `boot.l` and compiles
  `examples/text-layout.nl` to 672 lines of typed Maru.
- `eval2` with `maru.k` and `ir-gen-c.k` compiles that to 1,008 lines of C,
  which compiles cleanly for x86-64.
- Linking fails: `nile_PassThrough`, `nile_Process_advance_input` and the
  rest of the new interface are undefined.
- The old C runtime, built for x86-64 and run under Rosetta, runs the
  C-target kernels (`examples/c/text_layout.c`) and prints 29 lines.

## Repositories

- `nile` and `gezira` are forked to the user's GitHub account and added to
  `maru` as submodules at `nile/` and `gezira/`, pinned to commits.
- `maru` gets a `nile` branch whose tree is `for_nile/` from the
  `amelang-nile` tag, keeping that history. In the `nile` fork,
  `compilers/maru/maru/` becomes a submodule of the `maru` fork pinned to that
  branch, replacing the copied tree. The `nile` branch has no `nile`
  submodule, so a recursive clone of `maru` ends after one round.
- Inside `maru`, Nile's compiler runs on `maru` `main`, through `-L`, not on
  the pinned branch. The pinned branch keeps standalone `nile` checkouts
  working.
- **The `nile` branch is fully contained in `main`.** Checked on 2026-10-15:
  every file in Nile's copy of Maru, from Nile `master` and from its
  `nile_maru` branch, is in `main`'s 2012 base (`ac07e5e`) with no difference
  beyond whitespace. Every later difference is a deliberate change on `main`.
  One file is missing: `print-structure.l`, removed from `main` in `f6671da`
  as unreferenced, is required by Nile's compiler. It is restored.
- The `nile` fork marks code outside the stack in `.gitattributes`, the same
  way `maru` marks `derived` files: `viz/`, `compilers/js/`, `compilers/st/`,
  `runtimes/c/`, `runtimes/js/` and `examples/c/`. `runtimes/c/` stays as the
  reference implementation.

## Files

The runtime is in the `nile` fork at `runtimes/maru/`. Its files mirror the C
runtime's, so the two can be compared piece by piece.

| File | Replaces | Contents |
|---|---|---|
| `nile.osdefs` | `nile-platform.h` | Size and alignment of `pthread_mutex_t`, `pthread_cond_t` and `pthread_t` on the build machine, read from `pthread.h`. The runtime treats each as an opaque, aligned block of bytes. |
| `nile-sync.k` | `nile-sleep.h`, spin locks | `extern` declarations for `pthread_mutex_*`, `pthread_cond_*`, `pthread_create` and `pthread_join`; `lock` and `unlock`; sleep and wake on a condition variable |
| `nile-heap.k`, `nile-deque.k` | `nile-heap.h`, `nile-deque.h` | Chunks cut from the caller's memory block; linked queues of nodes |
| `nile-thread.k` | `nile-thread.h` | The worker pool (below) |
| `nile-process.k` | `nile-process.c` | The process record, scheduler states, pipes, gates and back-pressure quotas |
| `nile-kernel.k` | *new* | The kernel interface (below) |
| `nile-builtins.k` | `nile-builtins.c` | PassThrough, Capture, Reverse, SortBy, DupZip, DupCat and Funnel, rewritten as kernels against the new interface |
| `nile.k` | already exists | The typed declarations generated code loads, completed to cover the whole interface |
| `test/*.k` | `runtimes/c/test/*.c` | The tests (below) |

## The worker pool

The design is the C runtime's. Only the synchronisation primitives change.

- `nile_startup(memory, nbytes, nthreads)` starts `nthreads` worker threads.
  The calling thread joins as an extra member, the liaison. New pipelines
  start on its queue, and in `nile_sync` it runs queued processes instead of
  only waiting.
- Each worker has its own run queue. It pushes runnable processes on the tail
  and takes the most recent one from the tail, usually the consumer it just
  fed.
- An idle worker steals from the head of other workers' queues, alternating
  up and down from its own index, with the liaison's queue last.
- Memory is the caller's block cut into chunks. Each worker has a private and
  a public chunk heap, and steals chunks from others when it runs out. If no
  worker has any, every thread is marked out of memory.
- Back-pressure quotas stay as they are: `INPUT_QUOTA` 5, `INPUT_MAX` 10.

## The kernel interface

The interface is inferred from what both generators emit. Neither the header
nor the generators document its semantics.

A buffer is a block of floats with a head and a tail (`[head, tail)` holds
data) and a fixed capacity. Its capacity is rounded down to a whole number of
the producer's output quantum, so an element is never split across buffers.

| Call | Meaning |
|---|---|
| `nile_Process(parent, in_q, out_q, prologue, body, epilogue)` | Allocates a process from one heap block. Any work function may be 0. A missing body means: pass input through, then remove this process. |
| `nile_Process_memory(p)` | The kernel's variables: the rest of the process's block after the process record. Its maximum size is fixed, because generated constructors don't pass a size. The runtime reports an error if a kernel's variable record is larger. |
| work function `(p, in, i, m, out, j, n) → status` | The runtime calls it with the head input buffer as `in[i..m)` and the current output buffer as `out[j..n)`. |
| `nile_Process_advance_input(p, &in, &i, &m)` | Called when `i == m`. Frees the used-up buffer and returns 0 with `in/i/m` moved to the next buffer when there is one. Returns nonzero, which makes the kernel save its state and stop, when the input is used up or the consumer has reached its quota. The process records which. |
| `nile_Process_advance_output(p, &out, &j, &n)` | Called when `j == n`. Hands the full buffer to the consumer and moves `out/j/n` to a fresh one. Never fails, because generated code calls it in the middle of a statement. If memory runs out it marks the runtime out of memory and points `out` at a scratch block, so the write completes and is discarded; the next `advance_input` stops the kernel. |
| `nile_Process_prefix_input(p, &in, &i, &m)` | Called when `i == 0` before pushing a value back onto the input (Nile's `<<`). Puts a new, empty buffer in front of the current one and sets `i` to its end. |
| `nile_Process_return(p, i, j, status)` | The kernel's last call. Saves the input buffer's new head and the output buffer's new tail. The runtime then acts on why the kernel stopped, as the C runtime does: back-pressure, out of input (block on the producer, or run the epilogue and remove the process if the producer has finished), or out of memory. |
| `nile_Process_reroute(p, i, j, sub)` | Saves `i` and `j`, then places the pipeline `sub` between `p` and its consumer. `p` passes its remaining input through and removes itself, as the C runtime's `swap` does. |

The prologue runs once before the first input, with an empty `in`. The
epilogue runs once after the last input. Both use the same signature and the
same output calls.

`nile_Process_pipe` takes two processes. The C runtime's variadic form can't
be declared in typed Maru, and Nile's runtime TODO asks for the two-argument
form.

## Concurrency rules

1. Each spin lock becomes one `pthread_mutex`: each process's lock and each
   worker's lock. Every critical section keeps the extent it has in the C
   runtime.
2. Every read of shared state happens under the lock that owns it. The C
   runtime reads some shared fields without locks, for example
   `producer->state`, `p->input.n` and `t->q.n` before stealing. That is
   mostly safe under x86's memory ordering, but not under arm64's. The plan
   includes an audit that lists each such read and moves it under its lock.
3. A thread holds at most one mutex at a time. If the audit finds a place that
   needs two, the order is: upstream process before downstream, and process
   before worker.
4. No spinning. An idle worker waits on a condition variable, and queueing
   work signals it. The C runtime's doubling spin pauses and its semaphore go.
   `nile_sync` has the liaison work while there is work, then wait on a
   condition variable until the gated-pipeline count reaches zero.
5. Errors behave as in the C runtime: out of memory sets the status on every
   thread, `nile_status` and `nile_error` report it, and work stops cleanly.

## Checks

The C runtime's tests print their results to be read; only errors and leaks
fail them. Each is ported to typed Maru and asserts its result instead.

| Check | Pipeline | Asserts |
|---|---|---|
| `nile_startup` | start, sync and shut down with 1, 2 and 8 workers | no error, no leaked blocks, `nile_shutdown` returns the caller's memory |
| `nile_reverse` | `Reverse` on numbered elements | output is the input reversed, element by element |
| `nile_sort` | `SortBy` field 1, then field 0 | output is sorted on (field 0, field 1), with nothing lost or duplicated |
| `nile_dupcat` | `DupCat` with two pass-throughs | output is the input twice, in order |
| `nile_recip` | many pipelines of many stages of a hand-written reciprocal kernel | each pipeline's sum matches a direct computation |
| `nile_prefix` | a kernel that pushes values back at a buffer's start | pushed values come out in order across the buffer boundary |
| `nile_reroute` | a kernel that reroutes to a sub-pipeline partway through | output is the expected mix of before and after |
| `nile_oom` | a run with too little memory | `nile_error` is set and the run stops without crashing |
| `nile_threads` | `nile_recip` and `nile_sort` with 1, 2 and 8 workers | every run matches the one-worker result |
| `nile_text_layout` | `examples/text-layout.nl` through Nile's compiler on `main`, typed Maru, and this runtime | its 29 lines equal the old C runtime's |
| `nile_tsan` | `nile_threads` and `nile_recip` built with `-fsanitize=thread` | ThreadSanitizer reports no race |

- Each check is a case in `check/check.l`, built through the existing
  `ir2-build` path.
- `nile_text_layout`'s expected lines are produced once from the old C
  runtime, built for x86-64 and run under Rosetta, and written into the check.
  The command that produced them is noted beside them.
- `nile_text_layout` also guards the `nile` branch's contents: it runs Nile's
  compiler on `main`, so a missing dependency fails `make check`.
- On `ndn.lan` the same checks run natively on x86-64.

## Line budget

- The `lines` check counts both repos under the same rules: files marked
  `derived` or outside the stack in either repo's `.gitattributes` don't
  count.
- `check/lines` gets one entry for bringing Nile in and one for the runtime,
  each with its reason.

| Part | Lines (estimate) |
|---|---|
| Nile's compiler (`compilers/maru`) and prelude | about 1,680 |
| `print-structure.l`, restored | about 60 |
| The runtime | about 2,000 (the C runtime is 2,000 lines of C) |
| Tests | about 300 |
| Total added | about 4,000 |

That brings the stack to about 31,000 lines against the soft 20,000 budget.
The runtime's entry is kept separate so that a runtime much larger than the
C version is visible.

## Open questions

None.
