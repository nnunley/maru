# Steps Toward The Reinvention of Programming (Kay, Ingalls, Ohshima, Piumarta, Raab, 2006, VPRI RN-2006-002)
Source: https://tinlizzie.org/VPRIPapers/rn2006002_nsfprop.pdf

Page cites ("p.N") are the printed page numbers in the footer of the text extraction. "cited pN" is the body page where a reference appears; "reference list pN" is the printed page of the reference list. Section cites use the section headings.

## A. Classification

A funding proposal (NSF, granted 31 Aug 2006) that doubles as a research vision and design sketch. It is not a report of finished results. Its genre is "plan plus argument": it states a goal (a whole personal-computing system in under about 20,000 lines), lists the intellectual ideas expected to make the goal reachable, shows prior systems as evidence of feasibility, and sketches a schedule and team. The strongest material is in section 3 (Technical Notes) and the bootstrapping passages. Sections 1, 2 and 5 are mostly motivation and illustration (Etoys screenshots, pp.4-8).

## B. Unity

The unifying thesis is that a single, comprehensible, self-describing system can run from the end user down to the hardware, and that this system is small enough to read in full. Three commitments carry the unity:

1. One kind of object. Every visible or behavioral thing is a "universal" actor (a smart polygon with scripts, roles and embedding), so documents, applications, graphics and UI differ only in "costume" and role (pp.4-6, p.9).
2. One bootstrapping process. The kernel is a self-describing object engine that is first approximated, then replaces its own approximation. The result is late-bound all the way down (pp.10-12).
3. One discipline for meaning. Specifications should be runnable, meanings should be kept separate from optimizations, and time should be explicit (pp.9-10).

The proposal says these principles are "aspects of a single principle" (p.9), but it also lists "about a dozen" of them as separate ideas (pp.4, 9, 12). It never says which one is primitive, so the unity is asserted more than derived.

## C. Outline of major parts

Sections (with pages):
- Abstract and proposal, intellectual merits, broader impacts, outline (p.1).
- 1. What do we mean by "end-user to the metal" personal computing (pp.2-3): OS, internet, drivers, applications, graphics, printing, web, protection, end-user experience, computation, explanation.
- 2. Design approaches (pp.4-8): the Occam/Einstein balance, biology analogies, the "theatrical" view of actors, costumes (pp.4-5), scripting all the way down (p.6), animation and movies as costume change (p.7), particles and fields (p.8).
- 3. Technical notes (pp.9-12): polymorphic algebra, general agents, roles, late binding, meanings and optimization, truth maintenance, observe-and-transform, massively parallel objects, explicit time and islands (p.10), reflective self-description (p.10), bootstrapping with Albert (pp.10-12).
- 4. Implementation (pp.12-15): research environment, open-source process, goal decomposition and the 20,000-line analysis (p.13), people and money (p.14), late binding of plans (p.14), milestones (p.15).
- 5. Dissemination, education, outreach (p.15).
- References (pp.16-22).

Concrete artifacts named (with who is responsible where stated):
- Smalltalk-80 / Squeak Smalltalk: about 2.8 MB, "about 200,000 lines", claimed to cover all of personal computing (p.1). Squeak is cited as a practical Smalltalk written in itself (cited p.1; reference list pp.16, 21).
- Squeak Etoys: the children's authoring system used for the illustrations (pp.4-8; reference list p.17).
- Squeak Book and Presentations: named as the same kind of structure as the proposed pages (p.7).
- Target sizing: a proposed system under 20,000 lines (pp.1, 13), a 10x reduction from Squeak, split into 2x from dead code and 5x or more from architecture (p.1); later restated as 5x from current work plus 2x unknown, from about 40,000 to about 20,000 (p.13).
- Albert: the "from nothing" bootstrapper. Claimed to be "a few hundreds of lines" for a Squeak kernel, about 9x faster than the Squeak interpreter, and about 0.8 of C++ speed (p.10; repeated p.15). Author: Piumarta (internal whitepaper; reference list p.21).
- A disposable C++ compiler that seeds Albert (figure caption, p.11).
- Croquet and "Islands" (cited p.10; reference list p.20). Islands of "a few hundreds to a few thousands of objects" (p.10). Authors: Smith, Kay, Raab, Reed (reference list pp.16, 20).
- TeaTime (Reed; reference list p.20).
- HyperCard (Atkinson's model, cited pp.2, 4; Goodman in reference list p.17).
- Logo, spreadsheets, HyperCard as end-user precedents (p.13).
- Tweak (community about 50), Croquet (hundreds), Squeak and Etoys (thousands) as open-source communities (p.13).
- Muse object OS and Concurrent Aggregates, as precedents for particles (cited p.9; reference list p.19).
- NetLogo, Sketchpad, TeX, Cyc, Thinglab, Kaleidoscope, Prolog, Lisp, Smalltalk-72, Smalltalk-76: prior work cited (pp.2-14, refs).
- The "$100 laptop" (OLPC) as a target (pp.2, 14) and as a participating project (p.15).
- People: the five authors (Kay, Ingalls, Ohshima, Piumarta, Raab) (title block). Named advisers: Dawkins, Hillis, Wurman (p.14). Named prior-work authors: Reed (protection and islands, pp.3, 10), McCarthy (p.12), Sutherland (pp.4, 9), Irons (p.4), Strachey and Landin (p.4), Atkinson (p.4).
- Budget and staffing: about $1M per year, about 4 full-time professional equivalents and 3 graduate students (p.14). The proposal says the usual rule of thumb (6-8 professionals plus 4-6 students) would cost more.
- Schedule: five years, with a site visit at 18 to 24 months (p.15).

## D. Author's central problems

1. Compactness with practicality. Can personal computing be made small enough to understand, without giving up useful power? (pp.1, 13)
2. Bootstrapping from nothing, and whether the bootstrap stays valid once it has been replaced. How to make the kernel self-describing and late-bound (pp.10-12).
3. Unifying UI, graphics, documents, applications and OS under a single object notion, and deciding what "the object" is (pp.4-6, 9).
4. Separating meaning from optimization, so the semantics stay simple while the implementation gets fast (p.9).
5. Explanation and self-disclosure, so that a learner can see how any structure was made (pp.3, 14).
6. How much of this can be known in advance. The authors separate what they know (roughly 10x via structure) from what they do not (the last factor of 2, and the range of meaning-expression and explanation) (pp.13-14).

## E. Key terms

- End-user to the metal: the scope of the system, from user objects down to hardware, with no fixed OS or application layers (p.2).
- Exploratorium of itself, "system is the curriculum": a system compact enough to be learned by inspecting it (p.1, p.3).
- Universal object / actor / costume / role: one kind of object with a varying look and role (pp.4-5, 9).
- Omni-agent: the proposal's name for the single rich object used as a general agent (p.13).
- Sideways composition of roles, as an alternative to inheritance (p.9; the proposal says inheritance may be needed at all levels, p.13).
- Late binding of everything, including bootstrapping (pp.9, 14).
- Meaning versus optimization: a simple definition is kept as the meaning and optimizations are checked against it (p.9).
- Observe and transform: a rule style taken from functional and spreadsheet thinking, contrasted with "force and smash" (p.9).
- Particles and fields: massively parallel objects coordinated through fields (pp.8-9).
- Pseudo-time, islands: explicit time and replicated transactional object groups (p.10).
- Circular implementation (Albert): a static approximation, then a dynamic replacement (p.11 caption).
- Singularity: the point at which the kernel no longer depends on its original approximation (p.11).
- Kernel object model: every object is linked to a binding object that maps messages to methods, with an intrinsic vtable to stop the recursion (p.11 caption).
- Bottom-up rewrite rules for code generation (p.12 caption).
- Dozen powerful principles: the proposal's name for its design ideas (pp.4, 9, 12).

## F. Main propositions and arguments

F1. A whole personal-computing system can fit in under about 20,000 lines (pp.1, 13). Reasoning: Squeak is about 200,000 lines (p.1). The authors believe about 2x is removable dead code and about 5x more comes from better architecture (p.1). The reasoning is an estimate based on "mathematical entropy" (p.1), not a measurement of Squeak's dead code or of a prototype.

F2. Messaging should be the unit of coupling, not procedure calls, so that heterogeneous parts can interoperate (p.2). Reasoning: Internet analogy, plus the observation that many "object-oriented" languages use procedure-call coupling, which the authors say hurts scale and interoperability (p.2).

F3. Device drivers should be supplied by devices as objects, run in separate address spaces, and reached through messages (p.2). Reasoning: removes the need for OS-specific drivers. The text does not address interrupts, DMA, or timing, so this is a design proposal whose hard parts are deferred.

F4. Real objects are protected because they only accept messages they choose to handle, and capabilities fit this model (p.3). Reasoning: message filtering as access control, plus references to Lampson, Miller and Reed. No threat model is stated.

F5. Undo, redo and checkpointing are needed so users can experiment safely. The time model (pseudo-time and labeled histories) provides them (pp.3, 9-10). Reasoning: explicit time lets computation run forwards and backwards.

F6. One kind of object covers all end-user facilities (pp.4-7). Reasoning: DTP and HyperCard analogies, and demonstrations in Etoys: a car, a worm animation, a movie, a synthesizer, and a text reflow. These are demonstrations of one mechanism in several roles, not evidence of coverage.

F7. Particles and fields can express many coordinations, from gradient following to text layout (p.8). Reasoning: analogy with ants and pheromone fields; Etoys runs about 1 million particles at 10 fps on a laptop (p.8).

F8. Specifications should be executable, and the meaning of a program should be kept separate from its optimizations (pp.9). Reasoning: the sorting example. A permutation-and-check definition is correct but slow. A heuristic sort can be checked against that definition. The text does not say how such a check is performed in general.

F9. Explicit time (pseudo-time) avoids locks and race conditions, and it allows safe distribution (p.10). Reasoning: Croquet islands as demonstrated practice. Islands of a few hundred to a few thousand objects are said to be replicated and resynchronized.

F10. The system should be self-describing, late-bound, and implemented by a "half-page of math" that runs fast on many platforms (p.10). Reasoning: McCarthy's half-page eval, and the claim that the same spec can be both the semantics and the kernel.

F11. A kernel can be bootstrapped from a disposable compiler through a sequence of stages: a self-implementing object language, then a dynamic evaluator, then full self-description. The seed becomes irrelevant after a "singularity" (pp.10-11, caption p.11). Reasoning: the McCarthy-and-Russell pattern the authors cite, a small eval written in the language and then made real (p.12). Evidence: Albert's kernel, claimed at "a few hundreds of lines", about 9x the Squeak interpreter, and about 0.8 of C++ speed (p.10; repeated p.15). The benchmark is not described.

F12. Code generation can be compact if target machine capabilities are written as bottom-up rewrite rules over resource nonterminals and abstract operations, with actions that emit code (p.12 caption). Reasoning: register allocation is treated as a variant of text layout under a pressure constraint. The text gives a figure but no size or measurement.

F13. A kernel group plus open-source volunteers can build and maintain a large system, with the kernel group keeping the architecture (p.13). Reasoning: track record of four open-source systems (p.13). The community sizes given (thousands, hundreds, about 50) are not sourced.

F14. Always keep a running system. Bootstrap quickly so the system can help its own development, and release early and often (p.14). Reasoning: development experience with Smalltalk-within-Smalltalk, where a new system was grown inside an old one and then "born" as a fresh image (pp.14-15).

F15. Late binding is needed because learning in this field arrives late, so the system must allow reformulation without a rewrite (p.14). Reasoning: historical experience with Moore's Law and with projects that need insights late.

## G. Critique

Labels: [uninformed], [misinformed], [illogical], [incomplete]. Aspirations are marked as such.

G1. [incomplete] The 20,000-line target is not decomposed. No budget is given per subsystem (graphics, bootstrap, UI, network, storage, language). The proposal itself says the last factor of 2 is "an unknown" (p.13), and it says "we think" the target is possible (p.1). The 2x dead-code factor (p.1) has no measurement. This is an aspiration, not a result.

G2. [illogical] "Mathematical entropy" (p.1) is an intuition and is used as the premise for the size target. Nothing in the proposal shows how the factor of 10 would be measured, so the claim cannot be tested as written.

G3. [misinformed] The "from nothing" label (p.10) conflicts with the bootstrapping figure, which says the circular implementation is seeded by a disposable compiler written in C++ (p.11 caption). Later, the authors say Squeak is used as scaffolding for the new system (p.14-15). The bootstrap is from a host, not from nothing. This does not make the method wrong, but the label overstates it.

G4. [incomplete / aspiration] The singularity claim (p.11) says that after the switch "nothing can be known about the original approximations" and that they are "irrelevant". The proposal gives no argument for why the final kernel is independent of the seed. It gives no reproduction check (for example, rebuilding the kernel with its own output and comparing) and no defense against faults in the seed being carried forward. A bootstrap that is trusted only because it was seeded from a compiler that is itself trusted is the central risk of any self-hosting design, and the proposal does not name it.

G5. [incomplete] Albert's numbers are not reproducible from the text. "A few hundreds of lines" does not say what is counted (the kernel only, or also the expression compiler, which the authors say could be tens of thousands of lines in typical compilers, p.12). The "9 times faster" and "about 80% the speed of C++" claims give no benchmark, machine, or C++ baseline (p.10, p.15).

G6. [illogical] The meaning/optimization principle (p.9) is asserted with one example (sorting). The example shows that a simple definition can be used to check an optimization, but it does not say whether the check is a test, a proof, or a sample, or how it scales. The proposal says the principle is "not made it into mainstream system building" (p.9), which makes the lack of a mechanism more important, not less.

G7. [incomplete] Drivers as device-supplied objects (p.2) leave out interrupts, DMA, and timing. Address-space separation is not enough for devices that can write to memory directly. The text does not say how such devices are confined.

G8. [uninformed / counterfactual] "The web could have been easily designed this way" (p.2). This is a historical counterfactual with no evidence. It also doubles as a rhetorical claim that the authors' approach is the obvious one.

G9. [illogical] "Fail fast" (p.12) is offered as a reason for few points of failure. But a system with a dozen principles, each doing the work of hundreds of standard techniques, is not shown to have fewer points of failure. The authors' own text says most of the effort will fall in the last 10-15% of facilities (p.15), which undercuts the "small core, correct by construction" framing.

G10. [illogical] Unity is claimed in two forms: "aspects of a single principle" (p.9) and "about a dozen principles" (pp.4, 9, 12). These are not reconciled, and the text does not say which principle the others follow from.

G11. [incomplete] The proposal names "the system is the curriculum" as a goal and gives no metric for it (pp.1, 3). The authors admit explanation is the least understood part (p.14). Self-explanation is an aspiration here.

G12. [incomplete] Protection and safety are described in terms of capabilities and message filtering (pp.2-3) without a threat model.

G13. [uninformed] The open-source community sizes (p.13) and the staffing rule of thumb (p.14) are unsourced. They are plausible but unverifiable from the text.

G14. Credit where due: the proposal is candid about its unknowns (pp.13-14), says the big question is where to draw the NSF scope (p.14), and admits that some ideas have not been tested in the form needed (p.14). The "Albert" bootstrap is at least a real artifact (p.10) that the authors have used on a real system (Squeak), so it is more than a paper sketch.

## H. What of it?

For the rebuild, the proposal is most useful as a list of design patterns and as a list of claims that need measurements. Several are directly on the rebuild's path.

1. Bootstrap shape. The circular bootstrap (F11) maps onto the rebuild's existing stack. The C evaluator and boot layer act as the seed; the Maru-in-Maru pieces then take over; the evaluator is eventually generated by the emitter; and the C seed is retired. The proposal's "singularity" is a useful milestone: the kernel must build with the seed removed. The proposal does not supply the check. A fixed-point test (the emitter compiles its own source, the result compiles it again, and the outputs must match) would be the rebuild's test for G4. That test is my suggestion, not something the sources describe.

2. Reference and optimized paths. F8 is directly usable. Keep a slow reference evaluator as the meaning, and check the generated evaluator and the table-driven assemblers against it. The proposal's own sorting example is the pattern. It does not say how to make the check, so the rebuild must define it (for example, differential tests over `check/` cases).

3. Table-driven x86 and ARM64 backends. The nearest source is F12 (bottom-up rewrite rules over target resources), plus the 2007 "Target Computer" stage (p.10 of the 2007 report, with its three targets Intel, PowerPC and StrongARM). Neither source gives a table format, an example, or a size, and neither covers ARM64. Use the pattern, not the "vast majority of complexity" claim (p.12), which is unmeasured.

4. Line budget. The proposal's target is 20,000 lines, not 10,000. The 10,000 figure in the project notes ("VPRI's 10k lines") does not appear in these two sources. If it comes from a later VPRI document, that document is not yet read. The proposal's own decomposition (Section 4, p.13) splits the goal into five sub-goals with separate risks, which is a better model for budgeting than a single total.

5. Counting boundary. The proposal does not say what counts. The 2007 report says its own IS back end (about 1000 lines) must be counted as part of the code base (2007 report, p.11). The rebuild's current lines check excludes derived files. That is a real choice, and it should be made explicit, because the STEPS work shows that an excluded bootstrap can hide most of the size.

6. Host dependence. The proposal's "from nothing" claim (p.10) depends on a C++ seed and Squeak scaffolding (p.11, p.14-15). The rebuild's C evaluator is the same kind of seed. The honest description is "bootstrapped from a host that is then replaced", and that description should be used in the project's own documents.

7. Running system as a process rule. "Always have a running system" (F14) matches the rebuild's `make check` discipline. The proposal's practice of decoupled, early releases is also worth copying for the assemblers: ship x86 first, then ARM64, each with its own check.

8. What to ignore for now. Croquet islands, massive parallelism, the "omni-agent" and roles, and the self-ontology (pp.10-14) are outside the rebuild's current scope. Keep them as notes on what the architecture would need later, not as tasks.

9. Next reads that this proposal points to (not read here): the Albert whitepaper (Piumarta 2005; reference list p.21), and the Squeak "Back to the future" paper (cited p.1; reference list p.21).

## Permanent notes extracted from this source

- [[steps-budgeted-20k-lines-of-meaning-code]]: the STEPS figure is 20,000, not 10,000
- [[self-hosting-is-shown-only-by-byte-identical-regeneration]]: self-hosting is demonstrated only by byte-identical regeneration from the seed
