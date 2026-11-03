# Frank on macOS, then on bare metal under qemu: a broad plan

A direction to react to, not yet a design. **The goal is to remove Squeak from the stack.** Frank's source and documents
are requirements for extending Maru, not a system to reproduce: nothing here builds a Squeak-like environment. Facts are in
`notes/sources/frank-dbjr-formats.md`. Each milestone is a document
rendering or an interaction that can be checked, and each stage ends in something visible.

## What this asks of Maru

Gathered from the documents and packages. Each is an extension to Maru, or a library on it.

- **A document reader** for `.pp`, then `.siss`. Documents name Squeak classes (`OrderedCollection`, `Interval`, `Form`,
  `FilePath`, `UTF8TextConverter`), which the reader maps to Maru values. They are a file format's vocabulary, not classes to implement.
- **KScript**, as a grammar lowered to Maru forms, including its FRP: `fby`, `when`, `mergeE`, `mapE`, `doE`, `collectE`, `switchColE`,
  `timerE`, lag, and a dependency-ordered tick.
- **An object model for boxes**: `KSBox`, `KSShape`, `KSObject`, with selectors, late-bound slots and streams as slots. The scripts'
  166 selectors are the requirement; those that are really Squeak's (`printString`, `addFirst`, `perform`) become Maru's own, by rewrite if needed.
- **Layout**: simple constraints, horizontal, vertical, line and text flow.
- **Text**: glyph outlines from documents, spans, line breaking, justification, editing.
- **Graphics**: the Nile runtime, Gezira, and a canvas of paths, fills, strokes, gradients and images.
- **Numbers and data**: floats and float arrays, matrices, points, rectangles, colours; Maru has some of these already.
- **Host services**: the seam below.
- **Undo and solvers, later**: Worlds and Cassowary are in the stack, and their use needs a look before they count as requirements.

What Squeak provides that stays out: the image, the VM, Morphic (`KSMorph` only hosts KSWorld in a Morphic window), its class library,
browsers and debugger. Maru's own live environment is a separate matter, on Maru's terms.

## The seam to keep from the start

macOS is one host. Everything above the seam stays identical on bare metal. Host services are selectors, in the sense of
draft-ndn-maru-typed-tree-matching-00:

    framebuffer   a surface, its size, present
    input         pointer, buttons, keys, as events
    storage       read a named document
    time          a clock, a timer
    threads       what the Nile runtime needs to run kernels in parallel

macOS implements these over SDL2 and POSIX; qemu implements them over virtio and timers.

## Frank on macOS

**Depends on:** tree matching stages 1 and 2 for the grammars and lowering; the Nile runtime in Maru (roadmap 5,
draft-ndn-nile-runtime-in-maru-01) for graphics.

1. **Every document loads.** `ksworld-pp.l` reads `.pp`; add `.siss`. All 176 load, with counts checked. `pagesBubble.ks`'s two
   files give equal objects where they should.
2. **KScript as a language.** `kscript.g` follows `KSParser2`'s behaviour, not only the 2012 report. All 215 scripts in the
   documents parse, and a tree grammar lowers them to Maru forms. Behaviour cases follow what `KSEvaluatorTest` covers.
3. **The object runtime, headless.** `KSObject`, `KSBox`, `KSEventStream`, and the dependency evaluator. Every selector the
   scripts use has a method, or is listed as missing, so "how much is left" is a number. Check: a document runs ticks headless
   and its stream values change as they should.
4. **Layout, headless.** `KSSimpleLayout`, `KSVerticalLayout`, `KSHorizontalLayout`, `KSLineLayout`, `KSTextLayout`. Check: box
   bounds of `KSWorld.ks`, against values saved in the document.
5. **Graphics to a file.** Gezira through the Nile runtime, a canvas with `GeziraPath`, fills and strokes, written to an image with
   no window. First picture: `testIndex.ks`, then a page of `KSWorld.ks` with its text.
6. **A window.** SDL2 (`libsdl2.k` exists), events into streams, and the top-level loop of TR-2012-001's Figure 3.

Ladder of demos, each harder: a button; `fileList.ks`; `sawtooth-demo.ks` and `deviation-demo.ks`; a bubble; a page editing
live; `Front page Onward Full v8.ks` rendered as the paper it is.

`.lbox` documents come after: either a separate reader onto the same runtime, or mapped on load. `LObjects` is 345 classes, so
rendering `.lbox` may be worth more than running its behaviour.

## Bare metal under qemu

**Depends on:** the arm64 `emit.l` fixpoint, because C has to leave the bottom. Roadmap 4 and part C of the 2026-10-14
assembler design specify the boot environments. A64 `virt` first, since arm64 is the native target.

1. **Boot and console.** Raw boot, memory map, console, exit code. A `qemu` check prints from Maru and exits.
2. **Maru with no libc.** `maru-gc.k`'s collector on a memory region, no `dlopen` or `subr`, native code linked in. The evaluator
   runs from the image. Roadmap 6 is required here: `check.l` without make or a shell.
3. **The stack without graphics.** The checks run inside qemu: grammars, John, the SAT solver.
4. **Devices.** Timer and interrupts, `virtio-gpu`, `virtio-input`, `virtio-blk`; the host seam's bare-metal side. Nile's threads
   become whatever the kernel provides.
5. **Graphics.** The Nile runtime on bare metal, drawing to the framebuffer.
6. **Frank boots.** The same documents as on macOS, from a disk image.
7. **Network, later.** `virtio-net`, and TCP as rules (roadmap 3) on the binary instance with `structure-diagram.k`. `.siss`
   documents already name `DAVDirectory` and `HttpUrl`, so documents can load from the network as they did.

## Documents are read from the internet

`KSWorld.ks` is a living document at `http://tinlizzie.org/dbjr/KSWorld.ks/index.pp`, as DBjr itself read documents over
`DAVDirectory`. `ksworld-load` already takes a URL, through `curl`.

- **A cache, keyed by content hash.** A fetched document is kept by its SHA-256, so a later run works offline and a change is visible.
- **Checks pin a hash.** A check names the document and hash it expects, and never needs the network if the cache has it. With neither
  network nor cache it reports the document as unavailable, not as passing or failing. A document that changed is reported, and a person
  decides whether to move the pin.
- **The document is untrusted input.** Its scripts become code, so what they can reach has to be limited before anything runs them:
  no `subr`, no file or shell access, and `perform` (in 28 of the 82 `.pp` documents) only over the runtime's selectors.
- **Fetching goes through the host seam,** in place of `curl` through `system`, whose shell command is built from the URL. On bare
  metal it comes after TCP. The site serves plain `http://`, so that needs no TLS.

## Decisions to make

1. **Licensing.** `tinlizzie.org/IA/`'s wiki footer says CC BY 4.0, unless otherwise noted; whether that reaches `/dbjr/` and Frank's code is unclear. We write our own, and nothing of it goes in this repository. Documents are read
   from tinlizzie.org as living documents, as below, so none needs redistributing. Asking Ohshima is still cheap and worthwhile.
2. **A reference run.** Getting the original running, on `ndn.lan` perhaps, gives pixels to compare against. Squeak would be a measuring
   instrument there and nothing more. Worth about a day's try, given how much it would settle; screenshots in the papers are the fallback.
