# STEPS Toward the Reinvention of Programming: 2009 Progress Report (Kay, Piumarta, Rose, Ingalls, Amelang, Kaehler, Ohshima, Samimi, Thacker, Wallace, Warth, Yamamiya, 2009, VPRI TR-2009-016)

Source: https://tinlizzie.org/VPRIPapers/tr2009016_steps09.pdf

Page numbers are the printed folios (p.1 is the title page). Line references (l.) are to the text conversion and are given where a folio alone would be too coarse.

## A. Classification

- Genre: an NSF progress report (grant 0639876), October 2009. It is a demonstration report organized as "T-shirts": six named findings, each a small working component, plus a document application (DBjr) that uses them. It is more concrete than the 2008 report: it includes code excerpts and line counts for several components.
- It mixes three grades of claim, as the 2008 report did: demonstrated prototypes (the Nile chain, the text-layout rules, a distilled machine-code chain), engineering counts, and aspirations (need-brokering, confinement, native bootstrap). The report marks some of these as "research problems" (p.15, l.740), which helps.
- Self-presentation: the report says its first page was "authored and rendered in our own system" (p.1), a claim the text cannot check.
- Earlier reports: the 2006 proposal (RN-2006002) and the 2008 report (TR-2008-004) are its references [1] and [2] (p.15). The 2007 report is not in the sources.

## B. Unity

The unity is a method, the "chain of meaning": a sequence of pattern-directed translators, each written in one meta-language, that carries a problem-oriented notation down to executable form (p.2-4, l.83-101, l.106-118). Input text becomes an abstract syntax tree; the tree is rewritten and optimized; the result is emitted as another language, bytecode, or machine code (p.3, l.95-97).

The report's architectural "powerful principles" (p.2, l.55-62) are the list of ideas the method is meant to serve: "Math Wins", "Meaning Separated From Optimization", "No Centers", "Loosely-Coupled Communications", "Control of Control and Context", "Model-T-Shirt Programming", "Particles and Fields", "Universal Parametric Objects", and "From Nothing" bootstrapping. Only some of these are exercised in the text. The meta-language and the intermediate form are the parts that connect the T-shirts.

Compared with 2008, the unity is more concrete: the 2008 report named a transformation framework (IS) that was "nearing completion" (2008 p.8); the 2009 report shows an actual chain, from a Nile grammar (p.5-6) through a Nile-to-C generator (p.7) and an s-expression-to-x86 chain (p.8-9). It does not name IS.

## C. Outline of major parts

1. The DBjr "omni-application" and the Model-T and Maxwell metaphors (p.1-2, l.36-46). The six T-shirt findings are listed on p.2 (l.47-52).
2. Powerful principles (p.2, l.55-62).
3. "Oldies but goodies" plus new ideas (p.2, l.66-74).
4. Chains of meaning: pattern-directed translators, the self-implementing claim, and the 30-200 line size of the T-shirts (p.2-4, l.77-134).
5. T-shirt 1, Nile rendering and compositing: rendering operations, 26 compositing operations, and the line table (p.4-5, l.137-185).
6. T-shirt 2, syntax and semantics into executable form: the Nile parser in OMeta, the Nile-to-C generator, the total (p.5-7, l.187-281).
7. T-shirt 3, intermediate forms to machine code: the s-expression intermediate language, the postfix form, a simplified B5000-style stack machine, and the x86 text output (p.7-9, l.292-447).
8. T-shirt 4, report editor and text layout: "particles and fields" text layout, the seven layout rules, editing rules, and the total of 36 rules (p.9-12, l.452-635).
9. T-shirt 5, LBox viewing and event framework: announcement routing, subscription, composition, loose coupling (p.12-13, l.637-693).
10. T-shirt 6, the DBjr application: brokering between views, events and confined objects; backgrounds; undo through Worlds (p.14-15, l.697-756).
11. References (p.15).

Artifacts named, with the count as stated and what it counts:

- Nile master rendering operations: 81 lines of Nile (p.5 table, l.180-181).
- Nile's 26 compositing operations: 90 lines of Nile in the table (p.5, l.182). The text says "about 100 lines of Nile code" for the same set (p.4, l.154-155). Internal inconsistency.
- Nile sampling: 71 lines; pen stroking: 76 lines; total of the four groups: 318 lines (p.5, l.183-185). Counts Nile source only.
- Nile active-math expression: "about 80 lines" (p.4, l.152).
- Nile parser: about 130 lines of OMeta meta-description (p.6, l.235).
- Nile AST-to-C generator: about 1110 lines of OMeta; "bringing the total to 1240 lines" of the prototype chain (p.7, l.279-281). The total is parser plus generator. The count excludes OMeta's own implementation and the C compiler.
- The "T-shirts": "about 30 - 200 lines" each (p.4, l.130).
- Machine-code chain (text to s-expression to postfix to x86 text): "less than 100 lines of meta description" (p.9, l.436-438). Output runs at about 70 percent of the speed of the same program in C with typical optimization (p.9, l.425-431). The sample program is not identified.
- Text paragraph editor: layout 7 rules; selection 5, show selection 4, typing 2; arrow keys 6, cut/copy/paste 3, tabs 1, tall letters 2, bold/italic/plain 3, font size 3; "Total: 36 rules" (p.10, l.550; p.12, l.617-635). Counts rules, not lines.
- TCP/IP as a grammar: about 160 lines, cited from the 2008 report (p.3, l.111).
- Wandering Letters: the name the report gives the paragraph-layout and editing rules, in the figure captions (p.9-11, l.472, l.573, l.594); the rules are counted in the next bullet.
- DBjr, LBox, Worlds integration: no line counts (p.12-15).
- Other named artifacts: Gezira and Jitblt (p.4, l.139); Cairo (p.4, l.149-150, as the baseline of extended PostScript capabilities); OMeta and OffsideRuleParser (p.5-7); Nile on PNG decompression (an experiment, p.7, l.282-284); Actionscript, JavaScript, Squeak, C, s-expressions, machine code as output targets (p.7, l.293-295); a B5000-style stack machine (p.8, l.349-355); BoxA-style LBox with BUI and Quiche as comparisons (p.13, l.687-688); LWorlds (p.15, l.752); Chains of Meaning memo RM-2009011 (ref [3], p.15).
- People: the author list only. The text does not attribute any artifact to a person. Historical references: HyperCard (Apple), DTP at PARC, Squeak Etoys, Maxwell's equations on a T-shirt, the Ford Model T, MIDI "General MIDI" (p.1-2, p.15).

Changes since 2008 visible in the text:

- Scope narrowed. The 2008 report pursued a whole system. The 2009 report sets DBjr, a document and office-suite application, as the bound on its "make a working model" goal (p.14, l.698-700). The 2008 projects JOHN, TileScript, Chalkboard, BoldlyCode, Lively, FPGA/BEE3 and the Source IDE do not appear in the 2009 text.
- Compaction expectation revised. The 2008 report projected a rendering "few tens of lines" (2008 p.2-3). The 2009 report counts 81 Nile lines for master rendering and says "we are also approaching the natural size for understandable expressions" (p.4, l.133-134).
- Nile named and built. "Nile" appears in the 2009 text and not in 2008; the 2008 report names Gezira only. The 2009 report shows its parser and generator.
- OMeta as the working meta-language. The 2008 report mentions OMeta in a browser and a JavaScript-replacement context (2008 p.9, p.11). The 2009 report uses OMeta for the Nile parser and generator (p.5-7).
- Intermediate form and targets. The s-expression intermediate language and the list of output targets (p.7) are new.
- The TCP/IP example is unchanged at about 160 lines, and the 2008 target of 80 lines (2008 p.6) is not repeated.
- Undo: in 2008 Worlds and undo were a major theme; in 2009 they appear only as a DBjr feature (p.15, l.754-755).
- Hardware: the 2008 FPGA and BEE3 work and the XOOS bare-hardware boot do not appear.
- The 2008 "20,000 lines" system budget is not restated in the 2009 text.

## D. Author's central problems

- Generality with brevity: an application that covers the ground of office suites and a "universal" view system without large code (p.2, l.66-74; p.14, l.698-709).
- Reuse: building-block languages should be reused more than the top-level notations (p.7, l.285-288).
- Output without a C compiler: "bypassing C or other compilers" for machine code, while remaining portable for now (p.2, l.49; p.7, l.292-296).
- Loose coupling at scale: how needers find suppliers without naming them, and how objects can be exchanged while the system still runs (p.12, l.641-660).
- Composition over subclassing, and making views recur and nest (p.12, l.641-642; p.13, l.677-682; p.15, l.747-749).
- Safety: running third-party objects "completely confined" (p.14, l.721-722).
- Interoperating with the world's formats and fonts while sending models of intent with objects (p.15, l.733-739).

## E. Key terms

- Chain of meaning: a sequence of translators from problem notation to executable form (p.2-3, l.77-84).
- Pattern-directed translator: rules of the form "pattern to be matched, pattern to be generated", which can be nicknamed and read like a parser grammar (p.3, l.91-101).
- Meta description: a description of a language in the meta-language; a meta-description of meta-descriptions is the self-implementing case (p.4, l.127-129).
- T-shirt: a finding small enough to be stated in a few lines; the report's unit of presentation (p.1-2).
- Nile: an active-math dataflow language over collections, for rendering and compositing (p.4).
- Gezira and Jitblt: rendering geometries that Nile expresses (p.4, l.138-139).
- OMeta: the pattern-directed meta-language used for the Nile parser and generator (p.5-7).
- Particles and fields ("army of ants"): characters as independent agents that sense their neighbours and margins, following local situation-action rules (p.9, l.452-458).
- Wandering letters: the layout and editing rules for the paragraph component (p.9-11).
- No centers: a distributed architecture with no central controller (p.2; p.9-11).
- Needs and supplies: two bulletin boards per object, one listing needs and one listing supplies (p.12, l.658-660).
- LBox: the viewing and event framework; announcements re-announced to subscribers; composition by "sideways" installation of behaviors (p.12-13).
- DBjr (Dynabook Junior): the document application; backgrounds as shared superclass-like views; Worlds for undo (p.14-15).
- Omnicell / omni-application: the analogy of one generic object with many specialized cell types (p.2, l.36-42).
- Model-T-shirt programming: building from few components that a child could take apart and reassemble (p.2, l.43-46).
- Lingua franca: the s-expression intermediate language used as the common target (p.7, l.298-300).
- Simplified B5000: the accumulator-plus-stack-plus-named-memory abstract machine used for the distilled example (p.8, l.352-355).

## F. Main propositions and arguments

1. Problem-oriented languages can be built as chains of pattern-directed translators. Reasoning: a text-to-AST step, AST-to-AST rewriting, and AST-to-target generation, all written in one kind of rule (p.3, l.95-101). Status: a method, shown in examples; no general argument that the method is sufficient.
2. Meta-descriptions can implement themselves, so a meta-language's own parser and compiler are part of the chain (p.4, l.127-129). Reasoning: meta-descriptions are programs, so they can be converted to ASTs and then to executable form by the same machinery. Status: asserted. The report cites its 2008 predecessor for the implementation of meta-languages (p.7, l.289), which does not give it in detail.
3. Each T-shirt is 30 to 200 lines and is near the natural size of its subject (p.4, l.130-134). Reasoning: the authors compare the T-shirts with Maxwell's four equations and conclude that further compaction is possible but limited. Status: counts for several T-shirts (p.5, p.6, p.7, p.9), a range for the rest.
4. Nile can express rendering and compositing in a small amount of code: 318 Nile lines for master rendering, 26 compositing operations, sampling, and pen stroking (p.4-5). Reasoning: a line-by-line enumeration, with the operations named. Status: a counted set; the 2008 comparison baseline is not carried forward.
5. Nile's parser needs about 130 lines of meta-description, and its generator needs about 1110 lines, for a 1240-line chain (p.6-7). Reasoning: the generator is the larger part, because it maps Nile's typed operations onto a lower-level language. Status: counts for a prototype chain.
6. Building-block languages will be reused more than top-level languages (p.7, l.285-288). Reasoning: observed in the chain so far (the same translators serve several input languages). Status: an observation from few examples, not a measured reuse rate.
7. Nile is a general language for parallel operations over streams, not only for graphics; a PNG decompression experiment is cited (p.7, l.282-284). Status: an experiment with no result reported.
8. An s-expression intermediate language can serve as the common target for translators, and a chain from it to machine code can be small (p.7-9). Reasoning: Lisp's uniformity of data and code makes the intermediate form easy to produce and transform (p.7, l.298-300). Status: demonstrated on a distilled example; the report says the real intermediate form is "almost ready" (p.7, l.276-278).
9. A text-to-machine-code chain fits in under 100 lines of meta-description and runs at about 70 percent of C speed (p.9, l.425-438). Reasoning: a simple stack-based abstract machine maps onto x86 by direct templates (p.8-9). Status: a distilled example; the benchmark, the optimization level, and the machine are not specified.
10. Peephole optimizations would be straightforward and their effect "should be easily measurable" (p.9, l.447-450). Status: aspiration.
11. A paragraph can be laid out by characters that sense their neighbours and margins under seven or so rules (p.9-10, l.460-472, l.550). Reasoning: each character follows its predecessor and reacts to the margin; the distributed rules replace a central loop. Status: demonstrated in DBjr (figures on p.10-11); the report says it was designing the syntax for the rules (p.9, l.475-476) but also calls the excerpt "the current actual code" (p.11, l.576).
12. Editing and selection behave correctly with about 36 rules (p.12, l.617-635). Status: a rule count. Not a line count; each rule spans several lines of code.
13. User input events and ordinary change notifications can use one subscription mechanism, which simplifies the framework (p.13, l.669-676). Reasoning: events are delivered by subscribing to containers; the same message objects serve both. Status: design argument with no comparison.
14. A view can be a transformed projection of an object, so one object can appear several times, including inside itself (p.13, l.677-682; p.15, l.747-749). Reasoning: messages are reified, so the same LBox can be projected with a different transformation. Status: demonstrated (the page-in-page example, p.2 l.40-42 and p.13-14).
15. Needs can be matched to suppliers through brokerage on semantic descriptions, and this scales better than explicit selectors (p.12, l.641-660). Reasoning: the 1970s dispatch needed an explicit selector; semantic brokering removes the need to name the supplier, with the emergency-room "Help" as the picture. Status: aspiration. The report gives no mechanism and no measure, only "sweet spots" to be found (p.12, l.652-655).
16. Shared models of intent sent with objects improve the match between visiting objects and their hosts (p.15, l.733-739). Reasoning: the MIDI and font analogy. Status: described as "an ongoing research problem" (p.15, l.740).
17. Application breadth is limited to office-suite functions, and these can be one application built from a few components (p.14, l.698-709). Reasoning: one abstract text object, one abstract picture object, and one document type cover the list. Status: a scope decision and a design claim; not demonstrated for all items.
18. Third-party objects can run confined (p.14, l.720-722). Status: a stated goal; no mechanism described.
19. Worlds give DBjr undo (p.15, l.754-755). Status: a claim; the 2008 report describes the mechanism.
20. The code bloat of the last thirty years, three to four orders of magnitude, happened in the presence of better ideas that were not visible in popular computing (p.2, l.68-74). Status: a conjecture with no evidence in the report.

## G. Critique

Charges are by claim. "Uninformed," "misinformed," "illogical" and "incomplete" have the meanings used in the 2008 note.

- Counts are not comparable across the report. The 318 Nile lines (p.5) are Nile source. The 1240 total (p.7) is a Nile parser in OMeta plus a Nile-to-C generator in OMeta, and it excludes OMeta, its host, and the C compiler that builds the output. The under-100-line machine-code chain (p.9) excludes the meta-compiler. The "30 to 200" lines (p.4) do not say what they include. The 36 rules (p.12) are rules, not lines. Read as a budget, the figures are incomplete.
- Inconsistent figures. The compositing operations are "about 100 lines" in the text (p.4, l.154-155) and 90 in the table (p.5, l.182). The Nile active-math expression is "about 80" (p.4, l.152) and 81 in the table (p.5, l.181). The difference is small, but it shows the counts are rough.
- Incomplete (no count for the central application). DBjr and the LBox framework, which the report says are the point of the work (p.14-15), have no line counts at all. The budget claim of 2008 therefore cannot be checked against the one component that matters most.
- Misattributed support. The self-implementing chain (p.4, l.127-129) cites the 2008 report for the meta-language's implementation (p.7, l.289). The 2008 report does not describe it. The claim is unsupported in both documents.
- Bootstrapping not shown. "From Nothing" bootstrapping is listed as a principle (p.2, l.61). The text shows no bootstrap sequence from a small core to the chain; the machine-code chain is "gisted" from a memo the reader does not have (p.7, l.295-297).
- "Bypassing C" is partial. The Nile path emits JavaScript or C (p.5-7, l.278-279), so it depends on a C compiler. Only the s-expression chain avoids C (p.7-9), and its output is 32-bit x86 text (p.9, l.377-445).
- Benchmark is unspecified. "About 70 percent of the speed" of a C program (p.9, l.425-426) does not identify the program, the compiler flags, the machine, or the number of runs.
- Retreat from the earlier projection. The 2008 report hoped for a few tens of lines for rendering (2008 p.2-3). The 2009 report says the size is "approaching the natural size" (p.4, l.133-134) and then gives 81 lines for the master operations (p.5). The shift is not stated as a revision.
- Layout rules: the report says it is still designing the syntax (p.9, l.475-476) and then calls the excerpt "the current actual code" (p.11, l.576). The reader cannot tell whether the rules run as shown. The text conversion also garbles some of the excerpts; this is a PDF problem and not an argument, but it limits what can be checked from the text.
- Illogical (efficiency of the ant-style layout). The report says the ant-style layout is efficient "if the task switching is at the same level of efficiency as message sending (which is the case in STEPS)" (p.10, l.545-548). The condition is asserted; no measurement of either is given.
- Aspirations stated as results. Need-brokering (p.12-13), confinement of third-party objects (p.14), and the PNG experiment (p.7) are stated without results.
- Overreach in the opening conjecture. "Three to four orders of magnitude code bloat" (p.2, l.70-72) is uncited and has no baseline.
- Scope cut without accounting. The 2009 report limits the application goal to office-suite tools (p.14, l.698-700). That is a reasonable scope decision, but the report does not say how much of the 2008 system goal it gives up or what the 20,000-line claim now covers.
- Demonstrated: the Nile grammar and generator (prototype), the s-expression chain on a distilled example, the text layout in DBjr, the LBox event routing, and the page-within-page view. Mostly aspirational: brokering, confinement, undo in DBjr, the native bootstrap, and the claim that the T-shirts reflect "natural size".

## H. What of it?

The rebuild has a hard 10,000-line budget, a preference for DSLs and grammars over hand-written code, a plan for the evaluator to be generated by Maru's own emitter, and table-driven x86 and ARM64 assemblers. The 2009 report is the more useful of the two for that, and it is also where the counting problem is most visible.

- Budget planning. The one usable planning fact is the split: the Nile parser is about 130 lines of meta-description, and the generator is about 1110 lines (p.6-7). In that chain the back end, not the grammar, is the expensive part. For a 10,000-line Maru budget, the analogous question is which back end is written in the DSL and which in host code, and the code generator should be budgeted first.
- Counting rule. Maru's `lines` check in the repo's CLAUDE.md counts every checked-in source line and excludes derived files. The STEPS figures exclude the meta-compiler and host. Any comparison must use one rule. The rebuild should record the rule it uses next to any figure it cites.
- Pipeline shape. The chain of meaning (grammar, AST, rewriting, emitter) is the shape Maru already has: the `ir2` and back-end generators, `gen-asm-x86.k`, and the PEG and Earley checks. The 2009 report supports keeping one small intermediate form that every front end targets. That is the s-expression lingua franca (p.7, l.298-300), and it argues for not adding a second IR.
- Peephole and optimization. The report defers peephole work and says its effect "should be measurable" (p.9, l.447-450). For the rebuild, leave peephole optimization out of the first version; it is an extra mechanism with no measured need.
- Table-driven assemblers. The 2008 idea of running a parser backwards (2008 p.12) is the same economy as a table that drives both encoding and decoding. The rebuild's table-driven assembler and disassembler (commit 3df21b8) is a narrower version of it. The report gives no mechanism, and it warns that the templates must come from a restricted rule form. That constraint should be designed in from the start.
- Generated evaluator. The self-implementing chain (p.4) is the nearest thing in the sources to the rebuild's goal. The report does not show the bootstrap, so it is a claim to test, not a method to copy. The rebuild needs an explicit bootstrap order: which evaluator runs first, what it is written in, and what the emitter generates from it.
- Targets. The machine-code example emits 32-bit IA32 text (p.9). Maru's `gen-asm-x86.k` produces the same kind of output, and the repo notes that 32-bit x86 does not run on this arm64 host. The example is a pattern, not a target. Its avoidance of C matches the roadmap item for an `ir-gen-arm64` backend.
- Out of scope for the rebuild. The layout, LBox, DBjr, brokering and confinement parts (p.9-15) do not bear on the budget or the evaluator. Importing them would be scope creep.
- What the sources do not contain. Neither report mentions Maru or the COLA, Pepsi and Coke lineage. Piumarta is an author, but the text does not discuss the Maru history. Those points must come from other sources.

## Permanent notes extracted from this source

- [[compiler-size-concentrates-in-code-generation-not-parsing]]: parsers are cheap; code generation and optimisation are where lines go
- [[one-pattern-matcher-can-implement-every-compiler-stage]]: one PEG matcher for front, middle and back end
- [[a-line-count-needs-a-stated-boundary]]: size claims need their counting boundary written down
