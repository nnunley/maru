# Nile loaded natively on eval

## Intent

Untyped Maru (`eval` with `boot.l`) loads a compiled Nile program and runs its kernels as native code in its own
process. The Nile program's kernels are composed into pipelines in Maru Lisp, and the records untyped Maru holds are
Maru objects, read by field. A Nile program is a library that describes itself, and loading it is discovery, not a
binding written by hand. No code image is involved: the library is an ordinary shared object (`.dylib`, `.so`).

## What happens today

- `gezira/nile/gezira.nl` goes through `nile-to-maru-compiler.sh` to typed Maru (`build/gezira.k`). Then `ir-gen-c.k` and
  `maru.k` on `eval2` turn it into C, and `cc` builds `build/gezira.dylib` (Makefile, `build/gezira.$(SO)`).
- `gezira-maru.l` opens the library with `dlopen` and states each entry point's signature by hand, eleven
  `gezira-entry` calls. Nothing checks those strings against the code. A wrong one is a wrong call at run time.
- The entry points are fixed in `nile/runtimes/maru/gezira-api.k`: `gezira_fill`, `gezira_fill_clipped`,
  `gezira_fill_image`, and so on. Each one builds its pipeline (TransformBeziers, ClipBeziers, Rasterize, a
  composite) in typed code. So untyped Maru can't compose kernels, and a new pipeline means a new entry point in C's
  terms.
- Handles are longs: an init process, an image address. Untyped Maru can't read a process or a kernel's state.
- `check/library-mode.l` already opens a library built from typed Maru with no `main`, and calls its exports. It too
  states their signatures by hand.

Pieces this plan relies on, checked in the tree:
- `eval` exports its collector: `GC_malloc`, `GC_malloc_atomic`, `GC_add_root` and others are global symbols (`nm -gU
  eval`). Libraries link with `-undefined dynamic_lookup -flat_namespace` (`SOCFLAGS`), so a library's `GC_malloc`
  resolves to the evaluator's own.
- `subr` passes and answers `float` and `double` (`f`, `d`), besides `i`, `l`, `p` and `s`, so kernel constructors that
  take floats can be called.
- The collector is single-threaded, stop-the-world, non-moving mark and sweep (`gc.c`). An object doesn't move, so a
  native pointer to it stays valid while the object is reachable. Only one thread may allocate.
- Typed Maru declares Maru objects (`define-object`, `new`, fields by name; `doc/ir2-objects.md`) and allocates them
  through the unit's `gc_malloc`. An `atom` object holds no references the collector traces.
- `maru.k` keeps what a unit exports, with types (`*maru-exports*`, `*maru-types*`, `*maru-structs*`).

## Goals

- `eval` loads a Nile program's library by name and gets a callable for each export, with its signature taken from the
  library, never written by hand.
- Kernel constructors, `pipe`, `feed`, `sync`, `startup` and `shutdown` are callable from untyped Maru. A pipeline such
  as `gezira-library.l`'s (TransformBeziers, ClipBeziers, Rasterize, a composite) is built in Maru Lisp.
- The records untyped Maru holds (a process, a kernel's parameters, an image) are Maru objects of their own types, read
  by field like any `define-structure`.
- `gezira-maru.l`'s hand-written signatures and `gezira-api.k`'s fixed pipelines go away. The clipping stages
  `ksworld-render.l` builds become pipelines composed in Maru.
- The same pixels as today: `gezira_image`, `gezira_maru`, `gezira_scene` and `ksworld_pixels` keep their assertions.

## Non-goals

- Code images. `native-image.l` stays for what it does, but Nile doesn't go through it.
- Compiling on `eval`. `maru.k` keeps running on `eval2`, as a build step, the way make builds `build/gezira.dylib`
  now.
- A new Nile compiler or new runtime semantics. The 2016 Gezira source and the runtime in `nile/runtimes/maru` are
  used as they are.

## Anti-goals

- A second statement of any signature or layout. If untyped Maru repeats what the library already says, the plan has
  failed even if the pixels are right.
- Worker threads allocating in Maru's heap or reading objects the collector may free. The collector isn't
  thread-safe, and a race there is a corrupted heap, not a wrong pixel.
- C written by hand. The description, the loader and the bridge are Maru and typed Maru (`maru-runtime-in-maru-languages`).

## Approaches

1. **A library that describes itself, built as today (chosen).** Compile with `ir-gen-c.k`, link with `cc`, and add
   one exported symbol holding the unit's description: its exports' names and types, and its object types' names and
   fields, as Maru form text. A loader in untyped Maru reads the text and defines everything from it.
   - Cost: `cc` stays in the build.
   - What it buys: discovery lands now. Discovery doesn't depend on who writes the library, so the linker can change
     later without touching the loader.
2. **Maru writes the shared object itself.** `native-gen.k` produces the code, and `exe.l`, which already writes
   Mach-O and ELF executables, is extended to write `MH_DYLIB` and `ET_DYN`, carrying the same description.
   - What it buys: no toolchain at all.
   - Cost: it is a linker project in its own right (exports, relocation, dyld's binding of the evaluator's symbols).
   - It comes after 1, as its last step, and the loader stays as it is.
3. **Bindings generated as Maru source at build time** (a `gezira-bindings.l` written by make).
   - Ruled out: the description then lives in a second file that can drift from the library it describes. A library
     that carries its own description can't be out of step with itself.

## The design

### The description

- Every unit compiled in library mode exports `maru_unit_description`, a function answering a C string. The string is
  a Maru form:
  ```
  (unit gezira
    (export gezira_TransformBeziers (nile_Process * nile_Process * float float float float float float))
    ...
    (object <nile-process> atom ((...)))
    ...)
  ```
- `ir-gen-c.k` writes it from what `maru.k` already holds at `compile-end`, so it can't disagree with the code it
  sits beside.
- Types are named in `maru.k`'s terms, not as `subr` letters. The loader maps them to letters (`int` to `i`, `long` and
  `T *` to `l` or `p`, `float` to `f`, `double` to `d`, `char *` to `s`). A type with no letter (a struct passed by
  value) refuses the export, naming it, when the library loads, not when it is called.

### The loader: `native-library.l`, untyped Maru

- `(native-library "build/gezira")` adds the platform's suffix, then calls `dlopen`, `dlsym "maru_unit_description"`
  and `read`.
- For each export it defines a global of that name holding a `subr` with the derived signature.
- For each object type it defines a Maru type and its field accessors (below), and it gives the library the type's id.
- A missing symbol, a description that won't read, or a type with no letter is an error naming the library and the
  export. Nothing is defined in part.
- It runs on `eval`, `eval2` and `eval3`, as `gezira-maru.l` does now.

### Objects

- A record untyped Maru holds is declared in the runtime with `define-object`, and the library allocates it with
  `new`. `new` goes through `gc_malloc`, which resolves to the evaluator's `GC_malloc`, so the object is in Maru's
  heap, typed, and freed when unreachable.
- Nile's fields are ints, floats and pointers into Nile's own heap, never Maru references, so these objects are `atom`.
  The collector doesn't trace them.
- **Type ids are the host's.** A library can't fix an id: `<long>`, `<pair>` and the rest are whatever the evaluator
  booted with, and `define-structure` assigns ids as it runs. So a library's object type takes its id from a global the
  loader sets before the first call. The library declares the type by name, the loader makes the type in the
  evaluator, then it writes the id into the library's global (exported, found by `dlsym`).
  - This is a change to `define-object`, whose id is evaluated when the form is read. Library mode makes the id a
    load-time global.
- **Fields from untyped Maru.** For each field the loader defines an accessor (`<nile-process>-workers`). The accessor
  reads the field at its offset and width from the description, using `byte_bounds`'s raw access, and refuses an object
  of another type. Whether reading a float field needs a new primitive is the builder's to find out. Any new primitive
  is written in a Maru language.

### Threads and the heap

- Only the thread that runs the evaluator allocates Maru objects: a kernel constructor, `pipe` and `startup` are
  called from Maru, on that thread. Workers never call `gc_malloc`.
- Stream buffers, the scheduler's queues and every per-process field the workers write stay in Nile's own heap (the
  memory `nile_startup` is given, from `malloc` as now). A worker may read a Maru object only while untyped Maru keeps
  it reachable. The handle's object holds the Nile process, never the other way round, so dropping the handle while the
  pipeline runs is the one way to break this. `sync` before the handle goes is the rule, and the loader's `feed` keeps
  its argument reachable until `sync`.

### What goes away

- `gezira-maru.l`'s eleven `gezira-entry` calls and its `define-structure <gezira-maru>`: the library defines both.
- `gezira-api.k`'s pipelines: `gezira_fill`, `gezira_fill_image`, `gezira_fill_clipped` and the image-clipped one.
  Their composition moves into Maru Lisp. The image helpers (`gezira_image_new`, `gezira_pixel`, `downsample`,
  `premultiply`) stay as exports, since they aren't pipelines.
- `check/library-mode.l`'s hand-written signatures.

## Steps (each a checkpoint commit, each with its check first)

1. **Discovery.** `ir-gen-c.k` library mode writes `maru_unit_description`, and `native-library.l` reads it.
   `library_mode` is rewritten to use no signature of its own and still answers 7, 42 and 5. New cases: a library whose
   description names a type with no `subr` letter is refused at load, naming the export; a missing symbol is refused
   too.
2. **Nile from eval.** `text-layout.nl` is built as a library, and untyped Maru builds MakeWords and InsertLineBreaks
   into a pipeline, feeds the four glyphs and reads (0,0) (3,0) (6,0) (0,1), on 1 and 8 workers: `nile_text_layout`'s
   answer, from `eval`.
3. **Objects.** The process handle and a kernel's parameters become `define-object` atoms with ids bound at load.
   Untyped Maru reads a field by name, and a field of another type's object is refused. Under `MARU_GC_EVERY=1` (or
   the evaluator's `GC_collect_every`), the step-2 pipeline still answers the same, which shows the objects survive
   collection.
4. **Gezira.** `gezira.l`'s selectors are implemented on the loaded library, with pipelines composed in Maru, including
   the clipping stages. `gezira_maru`, `gezira_scene` and `ksworld_pixels` keep their assertions, and
   `gezira-api.k`'s pipelines are deleted. Lines and erosion get their ledger entries.
5. **No toolchain (approach 2).** `native-gen.k` and `exe.l` write the shared object with the same description. Every
   check above passes against it, and `cc` leaves the Nile build.

## Checks and docs

- New check `nile_eval` (steps 2 and 3) in `doc/nile.md`. `library_mode` gets its description in `doc/ir2.md`, which
  today says it isn't described yet.
- `native-library.l` is a unit's piece: `doc/nile.md` for Nile's use, with the loader described where `library_mode`
  is.
- `notes/plan/render.john` gains the capabilities NileDiscovery, NileFromEval, NileObjects and GeziraComposed, each
  with its check, so the plan's frontier sees them.

## Left to the builder

- The description's exact form, provided it reads with Maru's `read` and names types in `maru.k`'s terms.
- How `ir-gen-c.k` emits a long string literal.
- Whether float fields need a primitive.
- The accessor names.

## Open

- **Process state as Maru objects.** This design keeps what the workers write in Nile's heap and makes the handles and
  parameters Maru objects, because the collector is single-threaded. Making a running process's own state a Maru
  object would need either the collector to stop the workers (a safepoint in the scheduler) or the objects to be
  rooted and never freed while scheduled. Both are larger than this plan. The question is whether handles and
  parameters are enough for now.
- A probe is running: `native-gen.k` compiling the Nile runtime and `build/gezira.k` in one unit on `eval2`. Whatever it
  refuses is work for step 5.
