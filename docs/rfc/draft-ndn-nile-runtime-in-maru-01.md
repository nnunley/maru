# draft-ndn-nile-runtime-in-maru-01: A Nile Runtime in Typed Maru

**Status:** DRAFT
**Corpus:** red (spec-first: the checks named below are the acceptance criteria)
**Category:** Standards-Track
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies a runtime for Nile's new kernel interface, written in
Maru's typed Lisp and calling libc and pthreads through `extern`
declarations. It keeps the design of Nile's C runtime (a worker pool with
per-worker queues and chunk heaps) and replaces its spin locks with POSIX
mutexes and condition variables, so that it runs on arm64 as well as
x86-64. It also moves Nile's compiler onto Maru's newer dialect and makes
`nile.k` the single definition of the runtime interface. Nile kernels reach
machine code only through the Maru stack: typed Maru, Maru's IR and, until
Maru's own back ends exist, `ir-gen-c.k`. It is written for
whoever implements the runtime and for whoever plans the Gezira and
windowed-demo work that follows it.

## Motivation

Nile's `master` has two code generators, one emitting C and one emitting
typed Maru. Both target a new kernel interface, which Amelang declared in
Nile commit `aa3e179` (2012-12-21, "The new Nile runtime API has landed.
Implementation forthcoming.") in `runtimes/c/nile.h`, and in
`runtimes/c/nile.k` for Maru. The implementation never landed.

At the time of writing (October 2026), checked on 2026-10-15:

- Nile's compiler runs on `eval` and `boot.l` and compiles
  `examples/text-layout.nl` to 672 lines of typed Maru.
- `eval2` with `maru.k` and `ir-gen-c.k` compiles that to 1,008 lines of C,
  which compiles cleanly for x86-64.
- Linking fails: `nile_PassThrough`, `nile_Process_advance_input` and the
  rest of the new interface are undefined.
- The old C runtime implements only the old interface, and only on x86: it
  uses `_mm_pause`, `xchg` and `mfence`. Built for x86-64 and run under
  Rosetta, it runs the C-target kernels in `examples/c/text_layout.c` and
  prints 29 lines.
- `nile.h` is half old and half new. It declares the new kernel calls, but
  keeps the old `nile_Process (p, quantum, sizeof_vars, …)` and buffer-based
  work-function types, and so disagrees with `nile.k`.
- Under `eval2` with `boot2.l`, Nile's compiler loads and stops while
  compiling its grammar with `undefined variable: string-copy`, one of the
  primitives `eval2` dropped.

So no Nile program compiled through Maru runs anywhere, and nothing runs
Nile on arm64. This document provides the missing runtime, a single
definition of its interface, and the compiler port needed to build against
Maru's `main`. It is the first of three steps toward the windowed Nile
demos: (1) this runtime and `text-layout.nl` end to end; (2) Gezira's
kernels through Maru, rendering a scene to an image file that matches the
old C runtime's; (3) typed GLFW 3 and GL bindings and the snow demo, in a
window on both hosts.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **runtime** — the code this document specifies, in the `nile` fork at
  `runtimes/maru/`.
- **C runtime** — Nile's existing runtime in `runtimes/c/`, kept as the
  reference implementation.
- **kernel** — a Nile process definition compiled to a constructor plus up
  to three work functions.
- **process** — one running instance of a kernel, allocated from one block.
- **work function** — a function `(p, in, i, m, out, j, n) → status` that
  the runtime calls for a process's prologue, body or epilogue.
- **block** — a fixed-size, `BLOCK_SIZE`-aligned piece of the caller's
  memory. Every process and every buffer occupies exactly one block.
- **chunk** — a linked run of up to `CHUNK_MAX_LEN` free blocks, the unit in
  which workers pass free memory between their heaps.
- **buffer** — a block holding stream data: floats in `[head, tail)` and a
  fixed capacity.
- **quantum** — the number of floats in one stream element, which differs
  per kernel input and output.
- **variable record** — a kernel's state, the struct `<kernel>_vars` that
  Nile's Maru code generator emits, stored in its process's block after the
  process record.
- **worker** — one of the `nthreads` threads `nile_startup` starts.
- **liaison** — the calling thread, which joins the pool as an extra member
  with its own queue.
- **quota** — the number of buffers a process's input may hold before its
  producer stops (`INPUT_QUOTA`).
- **Maru target** — the typed Maru that Nile's code generator
  `nile-gen-code-maru.l` emits. Nile's other generator,
  `nile-gen-code-c.l`, is outside the stack and unused.
- **reference output** — the 29 lines `text_layout` prints on the C
  runtime.

## Specification

This document defines the runtime: its public interface, its scheduling,
memory and synchronisation, and its errors. It also defines how Nile and
Gezira enter the `maru` repository, how Nile's compiler runs on Maru's
`main`, and the checks that hold all of this in place. It does NOT define
Gezira's kernels, image I/O or window bindings; those belong to the second
and third steps named in Motivation. It does NOT define native code
generation; the runtime and the kernels compile through Maru's IR and
`ir-gen-c.k` until Maru's own back ends replace it.

**Same design as the C runtime.** Every structure, queue discipline,
critical section and quota in the C runtime has a counterpart in the
runtime, and only the synchronisation primitives change, so the two can be
compared piece by piece.

**One definition of the interface.** `nile.k` declares every public call,
and the runtime, its tests and every kernel compile against it.

**The Maru stack only.** Nile kernels reach machine code only through typed
Maru and Maru's IR. Nile's C code generator, its C runtime and a C header
are not part of the build.

**No spinning.** A thread with nothing to do waits on a condition variable.

**No unlocked shared reads.** Every read of shared state happens under the
lock that owns it, because arm64 does not give the ordering the C runtime
relies on.

### Repositories

- `nile` and `gezira` MUST be forked to the author's GitHub account and
  added to `maru` as submodules at `nile/` and `gezira/`, each pinned to a
  commit.
- The `nile` fork MUST run Nile's compiler on `maru`'s `main` tree,
  under `eval2` with `boot2.l`, and MUST NOT carry its own copy of Maru:
  the copied tree at `compilers/maru/maru/` is removed. The fork's
  compiler scripts find Maru through a `MARU` variable that defaults to
  the enclosing checkout when `nile` sits at `maru/nile/`; a standalone
  `nile` checkout sets `MARU` to a `maru` checkout and otherwise stops
  with a message naming the variable. A submodule of `maru` inside `nile`,
  inside `maru`, would nest one more copy of each per round of
  `git clone --recursive`.
- At the time of writing, every file in Nile's copy of Maru, from Nile
  `master` and its `nile_maru` branch, is in `main`'s 2012 base (`ac07e5e`)
  with no difference beyond whitespace, and every later difference is a
  deliberate change on `main`. The one exception, `print-structure.l`
  (removed from `main` in `f6671da` as unreferenced, which Nile's compiler
  loads), MUST be restored to `main`.
- The `nile` fork MUST mark code outside the stack with an `unused`
  attribute in `.gitattributes`: `viz/`, `compilers/js/`, `compilers/st/`,
  `runtimes/c/`, `runtimes/js/`, `examples/c/`, and the C code generator
  (`compilers/maru/nile-gen-code-c.l`, `nile-builtins-c.l`,
  `nile-to-c-compiler.sh`). `runtimes/c/` stays in the tree as the
  reference implementation.

### Files

The runtime's files mirror the C runtime's.

| File | Replaces | Contents |
|---|---|---|
| `nile.osdefs` | `nile-platform.h` | Size and alignment of `pthread_mutex_t`, `pthread_cond_t` and `pthread_t`, read from `pthread.h` on the build machine |
| `nile-sync.k` | `nile-sleep.h`, spin locks | `extern` declarations for `pthread_mutex_*`, `pthread_cond_*`, `pthread_create`, `pthread_join`; lock, unlock, wait, signal |
| `nile-heap.k`, `nile-deque.k` | `nile-heap.h`, `nile-deque.h` | Blocks and chunks cut from the caller's memory; linked queues of nodes |
| `nile-thread.k` | `nile-thread.h` | The worker pool |
| `nile-process.k` | `nile-process.c` | The process record, scheduler states, pipes, gates and quotas |
| `nile-kernel.k` | *new* | The kernel interface |
| `nile-builtins.k` | `nile-builtins.c` | PassThrough, Capture, Reverse, SortBy, DupZip, DupCat and Funnel as kernels against the kernel interface |
| `nile.k` | already exists | Every public declaration (see "Public interface") |
| `test/*.k` | `runtimes/c/test/*.c` | The checks' kernels and drivers |

### Data model

```
RECORD Block:                       -- BLOCK_SIZE bytes, BLOCK_SIZE-aligned
    next        : Block | None      -- free-list link while free
    eoc         : Block             -- last block of this block's chunk
    i           : Integer           -- position within the chunk, 1..CHUNK_MAX_LEN

RECORD Process:                     -- occupies one Block
    thread      : Worker            -- worker that last ran it
    lock        : Opaque(pthread_mutex_t)
    heap        : Block | None      -- this process's private free blocks
    input       : Deque of Buffer   -- buffers waiting to be consumed
    in_quantum  : Integer           -- floats per input element
    out_quantum : Integer           -- floats per output element
    sizeof_vars : Integer           -- bytes in the variable record
    prologue    : WorkFunction | None
    body        : WorkFunction | None
    epilogue    : WorkFunction | None
    state       : ProcessState
    producer    : Process | None
    consumer    : Process | None
    gatee       : Process | None    -- process that waits for this one to finish
    parent      : Process
    -- the variable record follows, in the same block

RECORD Worker:                      -- one per thread, liaison included
    lock        : Opaque(pthread_mutex_t)
    wake        : Opaque(pthread_cond_t)
    private_heap: Block | None
    public_heap : Block | None      -- chunks other workers may steal
    q           : Deque of Process  -- runnable processes
    index       : Integer
    status      : Status
    osthread    : Opaque(pthread_t)

ENUM ProcessState:
    NOT_BLOCKED
    BLOCKED_ON_PRODUCER
    BLOCKED_ON_CONSUMER
    BLOCKED_ON_GATE

ENUM Status:
    OK
    OUT_OF_MEMORY
    BAD_ARG
    SHUTTING_DOWN
```

| State | Meaning |
|---|---|
| `NOT_BLOCKED` | On a worker's queue, or running. |
| `BLOCKED_ON_PRODUCER` | Input used up and producer not finished. Requeued when the producer appends a buffer or finishes. |
| `BLOCKED_ON_CONSUMER` | Consumer's input at quota. Requeued when the consumer drops below quota. |
| `BLOCKED_ON_GATE` | Waiting for its gater to finish. Requeued when the gater is removed. |

**`Opaque(T)`** is a run of `long` fields whose total size is `sizeof (T)`
from `nile.osdefs`. Typed Maru has no array types, so an `(opaque T)` form
expands to `size / 8` `long` fields. The build MUST fail if `T`'s alignment
exceeds 8 or its size is not a multiple of 8, so the assumption is checked
rather than silent. [R-opaque-pthread]

```maru-check @R-opaque-pthread
nile_osdefs
```

### Configuration

| Key | Type | Default | Description |
|---|---|---|---|
| `BLOCK_SIZE` | Integer | `512` | Bytes per block |
| `CHUNK_MAX_LEN` | Integer | `16` | Blocks per chunk passed between workers |
| `INPUT_QUOTA` | Integer | `5` | Buffers a process's input holds before its producer stops |
| `INPUT_MAX` | Integer | `2 × INPUT_QUOTA` | Hard limit on a process's input buffers |

All four are the C runtime's values, kept so that the two runtimes can be
compared. They are compile-time constants; this document defines no
run-time configuration.

`BLOCK_SIZE` is one size for every block because one size makes the
allocator a push and a pop on a free list, with no splitting, coalescing or
fragmentation, and because any block can then serve any request, which is
what lets workers move chunks between heaps. It bounds a stalled pipeline's
memory at about `INPUT_QUOTA × BLOCK_SIZE` per process. Its 512-byte
alignment is not used to find a block from an interior pointer; it keeps
blocks on separate cache lines. Two limits follow from it:

- The variable record gets the block after the process record, about 400
  bytes on a 64-bit host. Gezira's largest kernel, `OffsetBezier`, has 19
  variables, about 150 bytes.
- A buffer holds the block after its header, about 118 floats. A stream
  element larger than that cannot be buffered at all.

### Public interface

`nile.k` MUST declare every call below, and the runtime MUST define every
call `nile.k` declares, so that a kernel or test compiled against `nile.k`
alone links. [R-one-interface] The `nile.h` in Nile's C runtime is half old
and half new, and nothing in the stack uses it.

```maru-check @R-one-interface
nile_interface
```

Calls marked "as C" behave as the C runtime's call of that name.

| Call | Meaning |
|---|---|
| `nile_startup (memory, nbytes, nthreads) → p` | Cuts `memory` into blocks, starts `nthreads` workers, makes the caller the liaison, and returns the root process. Returns 0 if `memory` is too small for the workers' records plus one chunk per worker. |
| `nile_shutdown (p) → memory` | Stops and joins the workers and returns the caller's memory. As C. |
| `nile_sync (p)` | The liaison runs queued processes while any exist, then waits on a condition variable until the count of gated pipelines reaches zero. |
| `nile_status (p) → Status`, `nile_error (p) → bool` | As C. |
| `nile_print_leaks (p)` | As C. |
| `nile_Process_pipe (p1, p2) → p1` | Connects `p1`'s output to `p2`'s input. Takes two processes: the C runtime's variadic form cannot be declared in typed Maru, and Nile's runtime TODO asks for the two-argument form. |
| `nile_Process_feed (p, data, n)` | As C, except that it sets `BAD_ARG` and feeds nothing when `n` is not a whole number of the process's input elements. |
| `nile_Process_gate (gater, gatee)` | As C. |
| `nile_Process_pipeline (ps, n) → p` | As C, built from two-argument pipes. |
| `nile_Process_launch (ps, nps, data, ndata)` | As C. |
| `nile_PassThrough`, `nile_Capture`, `nile_Reverse`, `nile_SortBy`, `nile_DupZip`, `nile_DupCat`, `nile_Funnel`, `nile_Funnel_pour` | The C runtime's built-ins, with the signatures `nile.k` gives them, as kernels against the kernel interface. |
| The kernel interface | Below. |

### The kernel interface

The interface is inferred from what Nile's two code generators emit;
neither the header nor the generators document its semantics.

| Call | Meaning |
|---|---|
| `nile_Process (parent, in_quantum, out_quantum, sizeof_vars, prologue, body, epilogue) → p` | Allocates a process from one block. A work function argument of 0 means none. A missing body means: pass input through, then remove this process. |
| `nile_Process_memory (p) → vars` | The variable record: the rest of `p`'s block after the process record. |
| work function `(p, in, i, m, out, j, n) → status` | Called with the head input buffer as `in[i..m)` and the current output buffer as `out[j..n)`. |
| `nile_Process_advance_input (p, &in, &i, &m) → stop` | Called when `i == m`. Frees the used-up buffer and returns 0 with `in/i/m` moved to the next buffer when there is one. Returns nonzero, which makes the kernel save its state and stop, when the input is used up or the consumer is at quota. The process records which. |
| `nile_Process_advance_output (p, &out, &j, &n)` | Called when `j == n`. Hands the full buffer to the consumer and moves `out/j/n` to a fresh buffer. |
| `nile_Process_prefix_input (p, &in, &i, &m)` | Called when `i == 0` before pushing a value back onto the input (Nile's `<<`). Puts a new, empty buffer in front of the current one and sets `i` to its end. |
| `nile_Process_return (p, i, j, status) → status` | The kernel's last call. Saves the input buffer's new head and the output buffer's new tail; the runtime then acts on why the kernel stopped, as C: back-pressure, out of input (block on the producer, or run the epilogue and remove the process if the producer has finished), or out of memory. |
| `nile_Process_reroute (p, i, j, sub) → status` | Saves `i` and `j`, then places the pipeline `sub` between `p` and its consumer. `p` passes its remaining input through and removes itself, as C's `swap` does. |

The prologue runs once before the first input, with an empty `in`. The
epilogue runs once after the last input. Both run even when the stream is
empty. Both use the work-function
signature and the same output calls.

A buffer's capacity MUST be rounded down to a whole number of the
producer's output quantum, so an element is never split across buffers.

`nile_Process_advance_output` MUST NOT fail, because generated code calls it
in the middle of a statement. If no block is free, it marks every worker
`OUT_OF_MEMORY` and points `out` at a scratch block, so the write completes
and is discarded; the next `nile_Process_advance_input` stops the kernel.

Nile's Maru code generator MUST pass `sizeof_vars`: the size of the
kernel's variable struct, or 0 when the kernel has none. The C runtime's
`nile_Process` took this argument, and the generators dropped it; restoring
it is one argument in `nile-gen-code-maru.l`, which already emits the
struct. It lets the
runtime check the record against the block, and copy it when a process is
cloned.

`nile_Process` MUST return 0 and set `BAD_ARG` when `sizeof_vars` exceeds
the room left in a block after the process record. [R-vars-fit]
Without the check, a large kernel overwrites the next block silently.

```maru-check @R-vars-fit
nile_limits
```

`nile_Process` MUST return 0 and set `BAD_ARG` when `in_quantum` or
`out_quantum` exceeds a buffer's capacity in floats. [R-element-fits]
Without the check, a kernel over large elements loops forever: no buffer
ever holds one whole element.

```maru-check @R-element-fits
nile_limits
```

### The worker pool

1. `nile_startup` starts `nthreads` workers, and the liaison joins as an
   extra member. New pipelines start on the liaison's queue.
2. A worker pushes runnable processes on its queue's tail and takes the
   most recent from the tail, usually the consumer it has just fed.
3. An idle worker steals from the head of other workers' queues, trying
   victims alternately above and below its own index, with the liaison's
   queue last.
4. Each worker has a private and a public chunk heap. A worker that runs
   out of blocks takes a chunk from its own public heap, then steals one
   from another worker's. If no worker has a chunk, every worker is marked
   `OUT_OF_MEMORY`.
5. A worker with nothing to run and nothing to steal waits on its
   condition variable. Queueing a process on any worker signals one waiting
   worker.

### Concurrency rules

- Each spin lock in the C runtime MUST become one `pthread_mutex`: one per
  process and one per worker. Each critical section MUST keep the extent it
  has in the C runtime.
- Every read of shared state MUST happen under the lock that owns it. The C
  runtime reads some shared fields without locks, for example
  `producer->state`, `p->input.n` and `t->q.n` before stealing. That is
  mostly safe under x86's memory ordering and not under arm64's. The
  implementation plan MUST include an audit that lists each such read and
  where it moves under its lock.
- A thread SHOULD hold at most one mutex at a time. Where the audit finds a
  place that needs two, the order MUST be upstream process before
  downstream, and process before worker.
- No thread spins. The C runtime's doubling pause loops and its semaphore
  are replaced by condition variables.
- The runtime MUST be free of data races under ThreadSanitizer. [R-no-races]

```maru-check @R-no-races
nile_tsan
```

### Nile's compiler on `boot2`

Nile's compiler MUST run on `eval2` with `boot2.l` from `maru`'s `main`,
so that Nile's compiler, its kernels and the runtime all build with one
Maru dialect. [R-compiler-boot2] Leaving it on `eval` with `boot.l` would
tie Nile to both dialects, and a later merge of the dialects would break it
without warning.

```maru-check @R-compiler-boot2
nile_text_layout
```

`boot2.l` MUST define, in Maru, the string and number operations `eval2`
dropped and Nile's compiler uses: `string-copy`, `string-compare`,
`long->string`, `string->long` and any others the port finds.
[R-boot2-strings] The port starts from the first failure,
`undefined variable: string-copy` while compiling `nile-grammar.g`, and
continues until `text-layout.nl` compiles; forms that rely on `*env*` are
adapted along the way.

```maru-check @R-boot2-strings
boot2_strings
```

### Checks

The C runtime's tests print results to be read, and fail only on errors or
leaks. Each is ported to typed Maru and asserts its result. Each check is a
case in `check/check.l`, built through the existing `ir2-build` path, and
runs on arm64 macOS and, on `ndn.lan`, natively on x86-64 Linux.

Startup, sync and shutdown MUST work with 1, 2 and 8 workers, with no error,
no leaked blocks, and `nile_shutdown` returning the caller's memory.
[R-startup]

```maru-check @R-startup
nile_startup
```

`Reverse` on numbered elements MUST output the input reversed, element by
element. [R-reverse]

```maru-check @R-reverse
nile_reverse
```

`SortBy` field 1 then field 0 MUST output the input sorted on (field 0,
field 1), with nothing lost or duplicated. [R-sort]

```maru-check @R-sort
nile_sort
```

`DupCat` with two pass-throughs MUST output the input twice, in order.
[R-dupcat]

```maru-check @R-dupcat
nile_dupcat
```

Many pipelines of many stages of a hand-written reciprocal kernel MUST each
produce the sum a direct computation gives. [R-recip]

```maru-check @R-recip
nile_recip
```

A kernel that pushes values back at a buffer's start MUST see them come out
in order across the buffer boundary. [R-prefix]

```maru-check @R-prefix
nile_prefix
```

A kernel that reroutes to a sub-pipeline partway through MUST produce the
expected mix of output from before and after. [R-reroute]

```maru-check @R-reroute
nile_reroute
```

A run with too little memory MUST set `nile_error` and stop without
crashing. [R-oom]

```maru-check @R-oom
nile_oom
```

`nile_recip` and `nile_sort` with 2 and 8 workers MUST match the one-worker
result. [R-threads]

```maru-check @R-threads
nile_threads
```

`examples/text-layout.nl`, compiled by Nile's compiler on `main` to the Maru
target and run on the runtime, MUST print the reference output.
[R-text-layout-maru]

```maru-check @R-text-layout-maru
nile_text_layout
```

The check changes the compiler, the code generator and the runtime at once
relative to the reference output. A mismatch is traced by comparing the
generated typed Maru kernels with `examples/c/text_layout.c` (the C runtime's
kernels for the same program), kernel by kernel, and by the runtime's own
checks above, which do not involve the compiler.

The reference output is produced once from the C runtime, built for x86-64
and run under Rosetta, and written into the check, with the command that
produced it beside it. Because `nile_text_layout` runs Nile's compiler on
`main`, it also fails `make check` if `main` loses something the compiler
needs.

### Line accounting

The `lines` check MUST count `maru`, `nile` and `gezira` under the same
rules: files marked `derived` or `unused` in either repository's
`.gitattributes` do not count. `check/lines` MUST get one entry for bringing
Nile in and a separate one for the runtime, each with its reason, so that a
runtime much larger than the C runtime is visible. [R-lines]

```maru-check @R-lines
lines
```

Estimates, descriptive only:

| Part | Lines |
|---|---|
| Nile's compiler (`compilers/maru`, Maru target only) and prelude | about 1,460 |
| `print-structure.l`, restored | about 60 |
| `boot2.l` additions for the port | about 100 |
| The runtime | about 2,000 (the C runtime is about 2,000 lines of C) |
| Checks | about 300 |
| Total added | about 3,900 |

That brings the stack to about 31,000 lines against the soft 20,000-line
budget.

### Errors

| Error | Example | Recovery |
|---|---|---|
| `OUT_OF_MEMORY` | every chunk in use | Every worker's status is set; kernels stop at their next `advance_input`; `nile_sync` returns; the caller sees `nile_error` and can shut down. |
| `BAD_ARG` | a variable record or element larger than a block allows | `nile_Process` returns 0 and the status is set; the constructor's caller sees 0. |
| `SHUTTING_DOWN` | a call after `nile_shutdown` began | As C. |
| Opaque type unrepresentable | `pthread_mutex_t` alignment above 8 | The build fails, naming the type. |
| `nile_startup` given too little memory | `nbytes` below one chunk per worker | Returns 0; nothing is started. |

## Out of Scope

**Block sizing by element size.** Blocks sized to the stream's element
size, or several block sizes in multiples of a cache line, instead of one
512-byte size. Nile is not limited to graphics: a kernel over tensors
larger than about 118 floats per element cannot run at all on one block
size, and `[R-element-fits]` only reports it. Excluded because it brings
back the allocator trade-offs one size avoids (per-size free lists, chunk
stealing per size), and this runtime stays comparable with the C runtime.
Extension point: `BLOCK_SIZE` and the heap in `nile-heap.k`, with
`[R-element-fits]` as the check that changes.

**Array types in typed Maru.** `(array T n)` in `maru.k` and `ir2`.
Excluded because it changes the typed compiler. Extension point: the
`(opaque T)` form, whose `long` field runs become arrays once arrays exist.

**Kernels with several input or output streams**, such as the 2011 report's
Fibonacci circuit. Nile's design has one input and one output per kernel.
No seam exists in the kernel interface.

**Writing the runtime in Nothing.** Nothing has a grammar in
`notes/sources/grammars/` but no compiler, and its grammar has no way to
call C. Extension point: none until a Nothing compiler exists.

**Native code generation.** Compiling kernels and the runtime to arm64 or
x86-64 machine code with Maru's own back ends, in-process or to object
files. Excluded because those back ends do not exist yet: the table-driven
assembler spec (2026-10-14) covers x86 rows that are checked and A64 rows
that are not written, and the `ir-gen-arm64.k` drafts on `refactor-main`
emit code that does not assemble. Extension point: the back-end argument of
the build (`ir-gen-c.k` today); the runtime and kernels are ordinary typed
Maru and do not change when it does.

**Performance beyond the C runtime's.** Extension point: the configuration
table.

## Alternatives Considered

**Why not port the C runtime to arm64 in C?** It would replace `xchg` and
`mfence` with C11 atomics and be quicker to write, but the runtime is the
kind of code Maru exists to express, and the line budget counts it either
way. The author asked for the runtime in Maru.

**Why not keep spin locks, using atomics?** Spin locks with arm64 barriers
reproduce the C runtime's timing most closely, but they burn cores while
idle and need memory-ordering reasoning per site. Mutexes and condition
variables make each site's ordering the library's job and let
ThreadSanitizer check it.

**Why not a simpler design, such as one global run queue?** It would be
smaller, but it could not be compared with the C runtime piece by piece,
and the per-worker queues are what keep a producer and its consumer on one
core.

**Why not also build `text-layout.nl` through Nile's C code generator?** A
second path differing only in the code generator would separate generator
bugs from runtime bugs, but it brings Nile's C target and a generated C
header into the stack. The stack is Maru's; comparing generated kernels by
hand covers the rare mismatch.

**Why not allocate pthread objects separately and store pointers?** It is
simpler to declare, but adds an allocation per lock and cleanup at
shutdown, and changes the C runtime's memory layout.

**Why not keep Nile's compiler on `eval` and `boot.l`?** That ties Nile to
both dialects, and a dialect merge could break it with only
`nile_text_layout` to notice after the fact.

**Why not size each process's block to its variable record?** It needs a
general allocator or size classes, which the Out of Scope entry on block sizing
extension covers; passing `sizeof_vars` and checking it is enough for every
known kernel.

**Why not keep the variadic `nile_Process_pipe`?** Typed Maru cannot
declare a variadic function.

## Security Considerations

The runtime runs inside the caller's process, on memory the caller
provides, and executes only compiled kernels the caller links in, so it
adds no trust boundary. Two accidents it could cause, it now prevents: a
variable record or element larger than a block would overwrite the
neighbouring block, and `[R-vars-fit]` and `[R-element-fits]` turn both
into `BAD_ARG`. Data races are memory corruption by another route;
`[R-no-races]` checks for them. The `nile` and `gezira` submodules are
pinned to commits in forks the author controls, so a change upstream does
not reach the build unreviewed.

## Compatibility

- Nile's C runtime is unchanged and stays as the reference, with its own
  `nile.h`. Kernels from the updated Maru generator pass `sizeof_vars` and
  do not link against it; it never implemented the new interface anyway.
- Nile's C code generator still exists in the fork, marked unused; it is
  not updated for `sizeof_vars`.
- Nile's compiler moves from `eval`/`boot.l` to `eval2`/`boot2.l`, and
  from its 2012 copy of Maru to `maru`'s `main`. A standalone `nile`
  checkout now needs a `maru` checkout, named by `MARU`.
- The `lines` check counts the submodules, so its total rises by about
  3,900 lines over this work, each accounted for in `check/lines`.

## References

- RFC 2119, RFC 8174: BCP 14 key words.
- POSIX.1-2017 (IEEE Std 1003.1-2017), `pthread_mutex_*`, `pthread_cond_*`:
  https://pubs.opengroup.org/onlinepubs/9699919799/
- Nile, commit `aa3e179` (2012-12-21), `runtimes/c/nile.h` and
  `runtimes/c/nile.k`: https://github.com/damelang/nile
- Nile's C runtime, `runtimes/c/`: the reference implementation this
  design follows.
- Nile's runtime TODO, `runtimes/c/TODO`: the two-argument pipe.
- `CLAUDE.md` roadmap items 1 and 4, and the 20k line budget.
- Table-driven assemblers and disassemblers (x86, A64):
  `docs/superpowers/specs/2026-10-14-table-driven-assemblers-design.md`.
- STEPS 2011 report, on Nothing running the Nile runtime:
  `notes/sources/`.
