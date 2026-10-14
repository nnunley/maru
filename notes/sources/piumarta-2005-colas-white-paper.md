# Accessible Language-Based Environments of Recursive Theories — a white paper advocating widespread, unreasonable behaviour (Ian Piumarta, dated 2005-09-30, VPRI RN-2006-001-a)

Source: https://tinlizzie.org/VPRIPapers/rn2006001a_colaswp.pdf (26 pages). The working title of the
system was "ALBERT"; Pepsi and Coke are its two layers.

## A. Classification

Theoretical with a practical aim: a design manifesto and architecture description for a
self-implementing programming system. The author marks it as work in progress, with repetition and
possible inconsistency (title-page footnote).

## B. Unity

A system can be built from two mutually sustaining minimal abstractions — objects with messaging
for representation, and transformations of symbolic structures for meaning — so that it describes
and implements itself completely, from parsing down to native code. Nothing is early-bound, and any
language can be had by mutating the system from within.

## C. Outline of major parts

1. **Goals (§1):** simplicity (self-similarity everywhere), openness (nothing hidden), evolutionary
   programming, user-centred construction.
   - The "Open Future Principle": nothing early-bound.
2. **Conventional languages (§2, Fig. 1):** language and environment as two sealed black boxes.
   FFIs and user-defined primitives are costly and limited to pragmatics.
3. **COLAs (§3).**
   - 3.1 The end-user view (Fig. 2), a chain of pluggable stages: front end, parser, tree compiler,
     virtual processor (abstract to native instructions, with a few cheap optimisations), dynamic
     assembler.
   - 3.2 Modularity: each stage is usable alone and compilable to a C-compatible library. The
     assembler is a single stateless object; the virtual processor allocates monotonically.
   - 3.3 Construction (Fig. 3): a minimal pure object language on the left; ASTs evaluated by
     compilation closures on the right. Back ends can be dynamic, symbolic or static; output follows
     the C ABI.
4. **Representation (§4).**
   - The intrinsic object model: a vtable maps selectors to implementations.
   - Lookup on a cache miss is a real message send (Figs. 4–6), and the vtable is its own vtable.
   - Methods are closures. `bind` = cache, else `vtbl.lookup`, with special vtables for `nil` and
     tagged integers.
   - The vtable pointer sits one word before the object, so foreign objects can be wrapped with
     identity preserved (Fig. 7).
5. **Behaviour (§5, Figs. 8–9):**
   - A tree is evaluated by applying the `transform` property of its type (a symbol) in a context.
   - Atoms emit values; trees without transforms are applications.
   - Namespaces of transforms give context-dependent meaning.
6. **Circular implementation (§6, Figs. 10–13).**
   - Representation implements the methods of meaning, and meaning compiles the methods of
     representation.
   - New languages come by vertical extension or horizontal mutation.
   - 6.1 Bootstrapping in four phases: Pepsi.C++, then Pepsi.pepsi, then Coke.pepsi, then
     Coke.coke.
7. **Unconventional languages (§7, Fig. 14):** everything malleable. Users need artificial points
   of reference, so traditional languages are built inside a COLA as "stable bases".
8. **Conclusion (§8):** replace VMs and interpreters with statically compiled kernel types sharing
   one dynamic execution model.
   - 8.1 Omissions: a type system that removes primitives, multi-argument dispatch, details of the
     base transforms, the VPU, and the assemblers.
   - 8.2 Status: what was fact versus speculation in 2005.
   - 8.3 Perspectives.

Artifacts named: Pepsi (prototype: C++ compiler emitting C), Coke (prototype: dynamic code only,
several CPUs, on a C++ object system), a C99 header parser (written, not integrated), the VPU
(virtual processor), a dynamic assembler, Croquet as the intended end-user target.

## D. Author's central problems

1. How can a programming system be made so that users can understand and modify *every* part of
   it, down to messaging semantics and code generation?
2. What is the smallest pair of abstractions from which such a system can describe and implement
   itself?
3. How is such a circular system brought into existence from nothing (the bootstrap)?
4. How can arbitrary languages be supported without layering a VM or interpreter?

## E. Key terms

- **COLA (Combined Object-Lambda Architecture):** a pair of mutually sustaining abstractions, one
  for representation (objects and messaging) and one for meaning (transformation of
  lambda-calculus-like structures into executable form).
- **Pepsi:** the representation layer, a statically compiled object/message language. It is "not
  the real thing" because it is not pervasively late-bound.
- **Coke:** the meaning layer, everything needed for a pervasively late-bound implementation. "The
  real thing."
- **Clone family:** the set of objects sharing one vtable, between a class and per-instance
  behaviour.
- **Binding object / vtable:** the object whose `lookup` method defines message semantics. The
  intrinsic vtable is its own vtable.
- **Transform:** a closure attached as a property to a tree's type symbol. Syntactic transforms
  rewrite (like macros); semantic/pragmatic ones emit IR or act.
- **Tree compiler:** the engine that repeatedly applies transforms to trees until nothing remains.
- **VPU (virtual processor):** translates abstract instructions to native ones, one function at a
  time, with monotonic allocation.
- **Vertical extension vs horizontal mutation:** layering a new language on top versus changing
  the system's own transforms in place until it *is* the new language.
- **Mood-specific language:** a local, scoped DSL for an arbitrarily small part of a program.
- **Open Future Principle:** avoid having to predict the future by binding nothing early.

## F. Main propositions and arguments

1. **Self-similarity makes a system simple** (§1).
   - Globally, the system describes and implements itself in one paradigm.
   - Locally, each stage differs from its neighbours in one aspect, through a minimal interface.
   - Reasoning: one paradigm plus small steps means one thing to learn and small diffs to
     understand.
2. **Messaging can be self-describing** (§3.3, §4).
   - The only intrinsic operation is the method-cache probe, which is an optimisation, not
     semantics.
   - Lookup on a miss is a real message to a real object, the vtable, which is its own vtable.
   - So the semantics of message sending are defined by sending messages, and delegation,
     inheritance or multiple dispatch are just overridden `lookup` methods.
3. **Meaning can be a tree compiler with no built-in semantics** (§5).
   - Trees are typed by symbols, and each type's `transform` closure gives its meaning.
   - Looking up a property on a symbol is isomorphic to binding a method to a selector, so the
     same object machinery serves both.
   - Namespaces give local or global redefinition.
4. **The two layers close a circle** (§6, Figs. 10–11). Meaning describes the implementation of
   methods (including bind), and representation provides the structures that meaning manipulates.
   So the whole system — object representation, messaging, parsing, compilation down to binary —
   is written in itself.
5. **Bootstrapping is a sequence of fixpoints in which the foreign seed is discarded** (§6.1,
   Fig. 13).
   1. Pepsi compiler in C++, emitting C.
   2. Pepsi compiler in Pepsi, compiled by phase 1. Once its output is byte-identical to phase 1's,
      the C++ version is thrown away.
   3. The dynamic (Coke) layer written in Pepsi.
   4. Coke reimplemented in Coke, then Pepsi's object implementation reimplemented in Coke, so
      that everything is late-bound.
6. **Each compilation stage should be an independently usable library with a single-object
   interface** (§3.1–3.2). The dynamic assembler is one stateless object, and the VPU frees all its
   state per function. That makes stages replaceable (interpreters, bytecode, static output) and
   reusable from C.
7. **Back ends span dynamic to static on one model** (§3.3, §8).
   - In-memory native code, bytecode and assembler files are all produced the same way, and output
     follows the C ABI.
   - Statically compiled kernel types replace a VM; they are "frozen dynamic code" that can still
     be modified at run time.
8. **Languages come by mutation, not layering** (§6, §7). Change the transforms in place until the
   chain matches the source language; parts not needed disappear by GC. Traditional languages are
   still built, as stable reference points.
9. **Status as of 2005:** Pepsi prototyped (C back end), Coke prototyped (dynamic only, on C++),
   the rest "desire and speculation" (§8.2).

## G. Critique

- **Aspirational, by the author's own account.** §8.2 separates the little that existed in 2005
  from the rest. The paper is a design, not a report of results; "achieves the goals" (§6 box) is
  asserted.
- **Incomplete.**
  - The type system that would remove primitive methods, the base transforms, the VPU and the
    assemblers are all deferred (§8.1).
  - Exactly the parts that ground the circle are the parts not described: the cache, the
    primitive operations, the code generator.
- **Tension with "minimise what is grounded."** The design keeps an intrinsic vtable format and a
  global method cache rigid (Fig. 3 caption). It's honest about that, but it means "nothing is
  early-bound" (§1 footnote) is not literally true. The later Maru paper (2011) narrows the
  grounded part further, to type-indexed dispatch plus primitive application.
- **No size target here.** Unlike STEPS, the white paper gives no line counts. Simplicity is argued
  from structure, not measured.
- **Agreement where it counts.**
  - The bootstrap discipline — a disposable foreign seed, then byte-identical self-reproduction,
    then discard the seed — is sound and testable.
  - Stages-as-libraries with minimal interfaces is good engineering independent of the larger
    vision.

## H. What of it?

- **The bootstrap test is the same in both generations.** Pepsi.pepsi must reproduce Pepsi.C++'s
  output byte for byte before the seed is discarded; Maru's `eval` must reproduce `eval.s`. Our
  rebuild should state that as its acceptance criterion for "`emit.l` generates the evaluator",
  and check it in `make check`.
- **The dynamic assembler as a single stateless object with a functional interface** matches the
  table-driven encoders: `(x86 X ...)`, with the caller owning the buffer. The white paper also
  wants static *and* dynamic back ends on one model; our spec now has exactly that (`exe.l` for
  files, `MAP_JIT` for memory, the same encoder).
- **The VPU is the ancestor of `emit.l`'s abstract machine and `ir.k`.** One function at a time,
  monotonic allocation, a few cheap optimisations, chosen by price/performance (footnote 7).
  That's a criterion for which peepholes our backends should carry.
- **Foreign-object identity** (vtable pointer one word before the object) explains Maru's object
  layout, and the C99-header parser explains `osdefs`/`compile-osdefs.l` as the descendant of
  "parse platform headers for interfaces".
- **"Mutate, don't layer"** suggests that new front ends (maruby, Nile) and new back ends (A64)
  should replace transforms in place rather than add stages. Fewer lines.
- **Open:** how much of Pepsi/Coke's object model survives in Maru 2.4's `boot.l`, which adds
  messaging and multimethods at user level, as the 2011 paper describes.

## Permanent notes extracted from this source

- [[messaging-is-self-describing-when-lookup-is-a-message]]: lookup on cache miss is a message; the vtable is its own vtable
- [[self-hosting-is-shown-only-by-byte-identical-regeneration]]: self-hosting is demonstrated only by byte-identical regeneration from the seed
- [[in-memory-code-generation-needs-instruction-words-built-from-fields]]: JIT needs bit-field instruction construction plus back-patching
- [[ground-as-little-of-the-evaluator-as-possible]]: the grounded (C) part should freeze as few assumptions as possible
