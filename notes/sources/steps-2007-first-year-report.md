# STEPS Toward The Reinvention of Programming: First Year Progress Report (Kay, Piumarta, Rose, Ingalls et al., 2007, VPRI TR-2007-008)
Source: https://tinlizzie.org/VPRIPapers/tr2007008_steps.pdf

Page cites ("p.N") are the printed page numbers in the footer of the text extraction. Appendix G's formulas are figures and are absent from the text extraction; I could not check them. Figure-only claims are marked as such.

## A. Classification

A first-year progress report (December 2007) for an NSF- and FATTOC-funded research project. It is part status report, part design rationale, and part code appendix. Its genre is "results so far, with calibration of the bet": most results are small prototypes (a parser, a compositor, a rasterizer, a few language translators), and the report says plainly that the big architectural questions are still open for 2008-2009 (p.9, p.30). The appendices (A-F, pp.38-49) are the only place where code can be checked against the text. The formulas in Appendix G (p.50) are not in the text extraction.

## B. Unity

The unity is now a pipeline and a method rather than a single object. The IS system is a meta-extensible chain of transformation stages: language front ends, then standard ("canonical") forms, then target-machine rules (pp.10-11). Each language, graphics model, parser and even the IS back end is produced by writing rules for one stage, so the "same abstraction" runs through all layers. The report says so directly: many apparently different problems (code generation, pub/sub, TCP, inference, scripting) are "instances from the same abstraction" (p.6). The unifying method is "runnable math": every expression of meaning should be executable and debuggable, and code size counts only the meaning needed, with optimizations counted separately (pp.5-6, p.9).

The unity is still uneven. The report calls its central "miracle" the place where most unknowns lie (p.5), and it says the stronger semantic bases for future languages are yet to be invented (p.11).

## C. Outline of major parts

Sections (pages):
- About this report, motivation (pp.4-5): the "Moore's Law software" framing, the 2e9 to 2e3 line scale question, and the 3-4 orders-of-magnitude goal.
- General plan of attack (pp.5-7): "atoms to life" (bootstrap from hardware, p.6), comparisons (JavaScript as a pivot, p.7), language strategies (p.7), relation to extensible languages of the 1960s-70s, DSLs of today, specification languages (p.8).
- 2007 research activities (p.9): a list of about 15 results and the sizes that calibrate the "sense of entropy".
- Major progress (pp.10-31):
  - IS, meta-meta language-language and parametric compiler (pp.10-11).
  - Graphical compositing and rendering: Jitblt (pp.12-13), Gezira (pp.13-15), universal polygons and viewing (p.16).
  - A tiny TCP/IP using non-deterministic parsing (pp.17-18).
  - OMeta (p.18), JavaScript (p.19), Prolog and Toylog in OMeta (p.20), OMeta in itself (p.21).
  - Lively Kernel: Morphic in JavaScript (pp.22-23).
  - HyperCard model (p.24), Logo (p.25), visual dataflow (p.26), Tiny BASIC (p.27), particles and fields (p.27), IDE for IS (p.28), tiny FPGA computer (p.29).
  - Architectural issues and lookaheads (pp.30-33): a proto-system bootstrap, a complete application, a multiple-perspective object model, "Internet all the way down", and a sine-function example for semantic matching.
- Comments (p.34); training and outreach (p.35); references (pp.35-37).
- Appendices: A Logo-to-JavaScript OMeta translator (p.38); B Prolog-to-JavaScript (pp.39-40); C Toylog (p.41); D OMeta-to-JavaScript (pp.42-43); E tiny TCP/IP (pp.44-46); F IDE tools for IS (pp.47-49); G Gezira formulas (p.50, figures only).

Concrete artifacts named (with who is responsible where the report says):
- IS: a pipeline of meta-extensible transformation engines; "about 1000 lines" to regenerate itself (pp.7, 11). Principal researcher: Ian Piumarta (p.10). Targets installed: Intel, PowerPC and StrongARM (p.10). A "rapidly maturing prototype" is publicly available (p.10).
- OMeta: a pattern-matching and translation language; "BNF with transformations" (p.18). Its self-description is "about 100 lines" (p.7), "about 100 LOC" (table, p.18), and "about 40 lines" (pp.19, 21). Principal researcher: Alex Warth (p.18). Refereed paper with Piumarta (DLS 2007, reference list p.35).
- JavaScript in OMeta/IS: a complete implementation in "less than 200 lines" (p.19), "170 lines" of meta-description (pp.7, 10, 18). Researchers: Warth and Yoshiki Ohshima (p.19).
- Smalltalk: "200 LOC in JavaScript with a few changes" (p.18). No appendix or demo given.
- Logo: "50 LOC" (p.18); a parallel Logo with Croquet-style pseudo-time: "about 260 lines of OMeta and about 290 lines of supporting code" (p.25). Appendix A (p.38).
- Prolog: about 9 lines of OMeta syntax, about 80 lines of semantics (p.11, p.20); "less than 100 LOC in JavaScript" (table, p.18); Appendix B (pp.39-40). Warth.
- Toylog (English Prolog for children): "about 120 LOC in JavaScript" (table, p.18); "about 35 lines" for the English syntax (p.20); Appendix C (p.41). Warth.
- CodeWorks: "about 100 LOC in Squeak", the HyperCard scripting language (p.18, p.24).
- HC-II, a HyperCard reconstruction: principal researcher Ted Kaehler (p.24).
- Jitblt: a compositing engine compiled on demand from IS meta-descriptions, "460 lines of code"; deployed as an alternative compositing engine for pixman (p.12). Principal researcher Dan Amelang (p.12); his UCSD M.Sc. thesis is forthcoming (p.12; p.35; in-preparation list, reference list p.36).
- Gezira: a 2-D vector graphics engine; rasterization in "50 lines of code" instead of "500+" (p.14); "450 lines" for a good subset of vector graphics (p.14). Principal researcher Dan Amelang (p.13). Named after a region of Cairo (p.13).
- Cairo: an open-source PostScript-like library; "about 44,000 lines of C" (p.7). Cairo maintainers are cited for the claim that bloat is from special-case optimizations (p.12).
- Universal polygons and viewing: a graphics, window and UI model; "about 3,500 LOC" prototype including geometry, color, typefaces, events, interaction and platform connections (p.16). Principal researcher Ian Piumarta (p.16).
- Tiny TCP/IP: "less than 200 lines of code" for the whole apparatus (pp.7, 11, 17; Appendix E, pp.44-46). Principal researcher Ian Piumarta (p.17). The report contrasts it with TCP/IP packages of "10,000 or 20,000 lines of code in C" (p.7).
- Tiny BASIC: an 85-line grammar plus "another 200 lines" of runtime state (p.27); a claimed 250,000 lines per second. Principal researcher Ian Piumarta (p.27).
- Particles and fields: "our 200-line JavaScript" extended for particle programs; a decentralized text formatter in "a few lines" (p.27). Principal researcher Alex Warth, using Ted Kaehler's ideas (p.27).
- IDE for IS, "Pepsi version": a Squeak-hosted environment for source trees (p.28; Appendix F, pp.47-49). Principal researcher Scott Wallace (p.28).
- Tiny FPGA computer: "about 100 lines of Verilog" (p.29). Principal researcher Chuck Thacker, of Microsoft (p.29).
- Lively Kernel: Morphic in JavaScript; the download is "about 10,000 lines of code (about 300k bytes)" (p.23); the STEPS version is "our 200-line OMeta-based version" (p.22). Principal researcher Dan Ingalls, of Sun Microsystems (p.22).
- Logo, dataflow, Prolog, and the other "languages": the report lists "JavaScript, Smallertalk, Logo, BASIC, Prolog, Toylog, Dataflow, CodeWorks", plus specialty languages for metalinguistic work, mathematics, graphics (SVG, Cairo) and systems (TCP/IP) (p.9).
- COLA: named as the architecture the students learned (pp.35-36), as the "COLA shell" (p.45), and in reference titles (pp.36-37). It is never defined in this report.
- "Pepsi": appears only in the heading "IDE for IS (Pepsi Version)" (p.28). "Coke" does not appear in this report.
- Maru, Nile and Gezira-DSL: none of these appear. Gezira is named (pp.13-15), but the planned graphics DSL is not described.
- Other named systems used as comparisons: Intentional Software (Simonyi; p.8), Larch and OBJ (p.8), Morphic and Squeak (pp.9, 22-23), Logo (p.25), HyperCard (p.24), Playground (p.33), Linda (p.32), ART (p.32), EURISKO and AM (p.33), TeX (p.31), Meta II (p.18; reference list p.37).
- People: Alan Kay (PI), Ian Piumarta (co-PI), Kim Rose (co-PI), Dan Ingalls (co-PI, Sun) (p.3). Researchers: Dan Amelang, Ted Kaehler, Yoshiki Ohshima, Scott Wallace, Alex Warth, Takashi Yamamiya (p.3). Colleagues and advisors: Jim Clune (UCLA), John Maloney (MIT Media Lab), Andreas Raab and Dave Smith (qwaq), David Reed (MIT), Vishal Sikka (SAP), Chuck Thacker (Microsoft) (p.3). Hamaguchi (NHK), visiting (p.35).
- Funding: NSF grant 0639876 and FATTOC, 5 years (p.3); Intel, SAP, Nokia Labs, Sun Labs, Applied Minds (p.3).
- Named external numbers: "3 cubic miles of case law" (p.4); a 400-page book at 20,000 lines (p.5); a "Moore's Law" leap of 3-4 orders (p.5); the Burroughs B5000 (p.6, reference list p.37); Cairo's 44,000 lines (p.7); a 1000-book library for 20 million lines (p.5).

## D. Author's central problems

1. Whether personal computing is intrinsically large, or whether its size is bloat from weak abstractions (pp.4-5). The report poses the question as a scale question (2e9 to 2e3 lines) and says "the answer is almost certainly in between" (p.5).
2. How to bootstrap from weak hardware without writing thousands of lines of low-level code. The report rejects C as the bottom ("essentially the abstraction of very simple hardware", p.6) and wants a steep ladder from machine code up to high-level languages, produced by automatic processes (p.6).
3. How to find "engines of meaning" that cover many problems at once: particles and fields, pattern transformation, and constraints (pp.5-6).
4. How to express meaning so that it is runnable and debuggable, and how to separate that meaning from optimization, so that a system can be small and still fast (pp.5-6, 8-9).
5. How to make an object model that is simpler than the classic models and still supports multiple perspectives, roles, and matching of resources by meaning (pp.31-33).
6. How to validate each mechanism at small scale before committing to the 20,000-line budget (p.9).

## E. Key terms

- Moore's Law software: the project's name for the goal of 3-4 orders of magnitude less code (p.4-5).
- Meta-meta language-language; IS: the parametric transformation pipeline that generates languages and back ends (pp.10-11).
- Form #1..#n, standard forms, target-computer rules: the three stages of the IS pipeline (p.10, figure).
- OMeta: a wide-spectrum meta-translator that combines tokenizing, parsing and rewriting, and can describe itself (p.18).
- Chain of meaning: the sequence from source syntax to machine behavior, which the authors want to be uniformly modifiable (pp.18, 34).
- Active math / runnable math: meaning that can be executed and debugged, with pragmatics counted separately from optimizations (pp.6-7, p.9).
- Separation of meaning and optimization: the system must run with every optimization turned off (p.6, lines 240-242 of the extract).
- Universal polygons: the single graphical primitive from which all UI and text is built (p.16).
- Jitblt: just-in-time compilation of pixel-compositing pipelines from a description (p.12).
- Analytic pixel coverage: Gezira's way of computing exact edge coverage by formula instead of scan-line supersampling (p.13).
- Non-deterministic parsing: parsing with pattern-directed alternatives and heuristics, used for TCP (p.17).
- Particles and fields: a metaphor for many active objects coordinated by local and global messaging (p.27).
- Dumbbell models: experimental models built to learn, usually discarded, sometimes kept as stable subsystems (p.9).
- TAMO principle: used for "the miracle will have happened" (p.6; p.30). Not defined in the report.
- Miracle in the middle: the central unknown, the higher-level semantics that the bottom and top layers depend on (p.5, p.34).
- Semantic types / expectations: matching a desired meaning to a promised meaning, using a working model of the environment (pp.32-33).
- Monads (as used for "noticing modules"): a term the authors take from Leibniz via object theory (p.33).
- Internet all the way down: the idea that objects communicate by high-level messages at every scale (p.32).
- Perspectives: the Bobrow-Goldstein multiple-perspective object model, which the authors want to unify with binding (p.31).

## F. Main propositions and arguments

F1. The personal-computing experience (OS, apps and support) could be made in about 20,000 lines, a reduction of 3-4 orders of magnitude from today's practice (pp.4-5). Reasoning: the reader's comparison to a 400-page book (p.5), plus the claim that today's software is bloat from weak abstractions, not intrinsic demand (p.4). The 2e9-to-2e3 scale is a question, not a result.

F2. The required abstractions are a steep ladder from hardware to high-level languages, and the bottom of it must be produced by automatic processes, not by hand-written C (p.6). Reasoning: C is said to be the abstraction of simple hardware and to have distorted hardware design (p.6). Evidence: the IS pipeline has three targets (Intel, PowerPC, StrongARM) (p.10). The claim that C can be avoided is supported only by the existence of the IS back ends, not by any measure of their size or completeness.

F3. Problem-oriented languages make problems easier and solutions smaller (pp.6-7). Reasoning: each language is a semantic building block. Evidence: the report lists about a dozen languages (p.9), and its table gives per-language sizes of roughly 50 to 200 lines (p.18), with the counting caveats in G1-G4.

F4. OMeta is a sufficient meta-language for many languages: about 170 lines describe JavaScript (pp.7, 10, 19); about 100 lines describe OMeta itself (p.7). Reasoning: a grammar with transformation actions and a small amount of host code is enough, and the IS pipeline turns the result into fast code (p.10). Evidence: the JavaScript run is said to be fast relative to browsers (p.7), without any measurement given.

F5. IS can build itself from about 1000 lines of meta-description (pp.7, 11). Reasoning: the report says the IS engines and resources must be counted as part of the code base (p.11). Evidence: none beyond the statement.

F6. Graphical compositing can be done by compiling the composition operator from its formula at run time, and that is faster and smaller than static code with special cases (p.12). Reasoning: static compositing engines either explode combinatorially or are slow (p.12). Evidence: Jitblt at 460 lines "competes with hand-optimized" functions and was deployed in pixman (p.12). This is the strongest demonstrated result in the report, though it lacks a benchmark table.

F7. Analytic pixel coverage gives exact edge contributions, and a rasterizer can be expressed in about 50 lines instead of 500+ (p.14). Reasoning: the coverage of a polygon is a linear combination of edge contributions (p.13-14; formula in Appendix G, figure only). Evidence: a snowflake scene of 1400 animated, anti-aliased Bézier snowflakes at about 10 frames per second on a 1.8 GHz Pentium M (p.14 caption).

F8. Glyphs and all UI elements can be built from polygons and affine transforms, and this is fast enough for real-time text scrolling without bitmap caches (p.16). Reasoning: unification of UI into one scene model. Evidence: a 3,500-line prototype, which the report says will shrink (p.16).

F9. Network protocols are, in part, non-deterministic pattern recognition. A TCP responder can be written as a grammar over packet structure in under 200 lines (pp.17-18; Appendix E, pp.44-46). Reasoning: the reply to each packet depends only on a few predicates (tcp port, SYN, ACK, data). Evidence: a grammar and predicate code that answer SYN, data and ACK packets and reset unknown services, with a daytime example (p.46). Packet header accessors come from ASCII-art diagrams (p.44).

F10. Parsing can be made fast enough to run programs as a side effect of parsing: a Tiny BASIC grammar runs at 250,000 lines per second (p.27). Reasoning: a packrat-style parser with semantic actions acts as an interpreter. Evidence: stated numbers only.

F11. Particles and fields give compact, general coordination: a decentralized text formatter in a few lines (p.27). Reasoning: constraints act on each letter and each adjacent pair (p.27). Evidence: a toy figure.

F12. Meaning and optimization should be separate, and the system should run with all optimizations off (p.6, p.9). Reasoning: meaning should be the debuggable spec; optimizations are checked against it. Evidence: the Jitblt case is partly this, but the report does not show a check of an optimization against its meaning.

F13. The object model should be simpler, and multiple perspectives plus binding-as-view can be unified with the rest of the system (pp.31-32). Reasoning: perspectives are useful in real life, and multiple inheritance has the same naming problems (p.31). Stated as a goal for 2008.

F14. The network should be an object architecture in which modules notice their needs and react, with matching by meaning and tolerance, not by name (pp.32-33). Reasoning: analogy with cellular biology, expert systems (ART) and Lenat's AM and EURISKO (p.33). Stated as a preliminary answer and explicitly speculative.

F15. Experiments calibrate the "sense of entropy" for each part of the task, and the bottom layers must be validated before the budget is spent (p.9). Reasoning: the first-year results are the calibration, and the report says the project is set up so that many parts can be discarded (p.9).

## G. Critique

Labels: [uninformed], [misinformed], [illogical], [incomplete]. Aspirations are marked as such. Where a line count is stated, I say what it counts.

G1. [incomplete / misleading count] The report uses several line counts with different boundaries, and they cannot be compared.
- "170 lines" for JavaScript (pp.7, 10, 18-19) counts the meta-description fed to IS, Squeak or JavaScript. It excludes the IS engines (p.11).
- The report says "all the languages ... could be defined and made to run in under 200 lines of code fed to our metasystems" (p.9). This is again the marginal cost over the metasystem.
- On p.11, the report says the full cost of a runnable JavaScript for three CPUs is "about 1170 lines" (1000 for IS plus 170), and that "we really have to count IS as part of the code base." That is the honest total, but the headline numbers (pp.7, 10, 18) do not use it.
- The "about 1000 lines" for IS (p.7, p.11) counts the meta-description that regenerates IS, but not the first, seed IS, nor the host system (Squeak or JavaScript) that the experiments run on (pp.9, 28).

G2. [misinformed / inconsistent] OMeta's self-description is given three ways: "about 100 lines" (p.7), "about 100 LOC in IS, Squeak, JavaScript" (table, p.18), and "about 40 lines" (pp.19, 21). The Appendix D grammar that defines OMeta (p.42) is about 40 lines. The code generator in Appendix D (p.43) is about 35 more lines. The "40" counts the parser grammar only, and the "100" appears to count the grammar plus generator plus back-end code, but the report does not say.

G3. [inconsistent] Logo is "50 LOC in Squeak and JavaScript" (table, p.18). Parallel Logo is "about 260 lines of OMeta and about 290 lines of supporting code" (p.25). The report does not say whether the 50 counts the runtime or only the translator, nor whether the parallel version is a different system.

G4. [inconsistent] Prolog is "about 90 lines" (p.11), "about 80 lines" of semantics (p.20; Appendix B, p.39), and "less than 100 LOC in JavaScript" (table, p.18). These are probably the same system counted differently, but the report does not say.

G5. [illogical] The TCP/IP result is overstated. The text says "the entire apparatus of TCP/IP was less than 200 lines of code" (p.7, p.11, p.17). Appendix E shows a grammar for a single server, reacting to SYN, data and ACK packets, plus predicates (pp.44-46). It omits the functions "out" (which fills in checksums and writes packets), "up" (delivery to services), "tcp-service-at", and the tun-interface plumbing. The report says so: "a few functions called from the above code are not shown" (p.46). The structure-diagram parser (p.44) is also outside the count. The text also says that TCP streams and retransmission are "just a few lines of code each" on top of a UDP-like base (p.17), but no such code is shown. There is no interoperability test or packet capture in the report. What is demonstrated is a parser that answers a few packet types for one service, which is a real result but not TCP/IP.

G6. [uninformed comparison] Cairo's "about 44,000 lines of C" (p.7) is compared with Gezira's 450 lines (p.14) and with "50 lines" for rasterization (p.14). The report does not say what the 44,000 contains. Gezira implements "a good subset" (p.14). The comparison is not like-for-like, and the claim that Cairo's bloat is special-case optimization is second-hand (p.12, from Cairo's maintainers).

G7. [incomplete] Appendix G (p.50) contains the formulas that justify the 50-line rasterizer, but only as figures. I could not check the claim from the text. Figure-only results in general (the Jitblt images, the Morphic screenshot, the FPGA diagram) cannot be checked here.

G8. [incomplete] Performance claims lack a method. Tiny BASIC runs at 250,000 lines per second "on modest hardware" (p.27). The snowflake scene runs at about 10 fps on a 1.8 GHz Pentium M (p.14 caption). Jitblt "competes with" hand-optimized code (p.12). The Lively Kernel download is 10,000 lines (p.23). None of these has a stated benchmark, baseline, or machine.

G9. [illogical] "Engine" comparisons are not controlled. The report compares a JavaScript run against browsers as "fast" (p.7) and says the STEPS JavaScript is "compatible with version 1.4" (p.18), but gives no conformance test count.

G10. [incomplete / unresolved] The bottom of the stack is not described. The report says C must be avoided (p.6), that IS generates machine code for three targets (p.10), and that IS can regenerate itself from about 1000 lines (p.11). It does not say what compiled the first IS, which host (Squeak, JavaScript, or something else) ran the first experiments, or whether any target is hand-written in machine code. Squeak is used as scaffolding (p.9, p.28), so the stack is hosted, not native. The report does not say which parts of the rebuild path are hosted.

G11. [misinformed] The 2e9-to-2e3 comparison (p.5) and the "3-4 orders of magnitude" claim (p.5) use a baseline (20 million to 2 billion lines) that is not measured. The 2006 proposal used Squeak's 200,000 lines as the baseline and a factor of 10 (2006 report, p.1). Moving the baseline to "current practice" makes the leap look bigger without a measurement. The report acknowledges that the comparisons have "lots of wiggle room" (p.5).

G12. [incomplete] "The system must be able to run with all the separate optimizations turned off" (p.6). This is a testable claim, but the report does not say that it was tested for any artifact.

G13. [incomplete / rhetorical] The "miracle in the middle" (p.5) is the part of the project the report most needs, and it is described only as a set of ideas to be "invented" (pp.5, 11, 30). The TAMO principle (pp.5-6, 30) is used but never expanded.

G14. [uninformed on terms] "Semantic-meaning-kernel", "active math", "chain of meaning", "dumbbell models", "COLA" and "Pepsi" are used without definition. COLA appears in pp.35-36 and p.45, the "Pepsi version" heading is on p.28, and neither is defined in this report. "Coke" does not appear.

G15. [illogical] The report says that "the battles here are fought, won or lost on how much power of meaning lies under the syntactic forms" (p.6). That claim cannot be checked, because the report does not say how power of meaning is measured.

G16. [aspiration, labeled as such] The "Internet all the way down" section (pp.32-33) and the semantic matching of resources (p.33) are presented as open questions. The authors say that some reviewers "hated this" (p.32). The report also says the matching idea depends on working models of the environment that are not yet defined (p.33). These are aspirations, and the report marks them that way.

G17. [credit] The report is candid about several things: most experiments are models to learn from, not to keep (p.9); the central question is in the middle, not at the ends (p.5); and the team admits that its languages are not yet good enough (p.8, p.11). The use of Squeak as scaffolding is disclosed (p.9, p.28).

## H. What of it?

The 2007 report is the more useful of the two for the rebuild, because it gives sizes and a pipeline. It also shows where sizes are not comparable, and that matters more than the headline numbers.

1. Count boundaries. The rebuild has a hard 10k-line cap and an exclusion of derived files. The 2007 report shows the same accounting problem in its own work: "170 lines" for JavaScript is the marginal cost; "about 1170" is the total for three CPUs (p.11). Adopt the same two numbers for the Maru work: report marginal and total, and say what the seed and host cost. The IS self-regeneration figure (about 1000 lines, p.11) is the closest analogue to the rebuild's emitter-plus-boot cost, and it is the number to measure first.

2. Target rules and the table-driven assemblers. The IS "Target Computer" stage (p.10) is a set of rules that describe architectural forms: instructions, register sets, and special organizations. It is the closest match to the rebuild's table-driven x86 and ARM64 assemblers and disassemblers. The report gives no per-target size and no ARM64 target. Three targets (Intel, PowerPC, StrongARM) were installed (p.10). The rebuild should ask for the same number per target before committing to the design.

3. Grammar-driven tables from manuals. Appendix E (p.44) turns ASCII-art packet diagrams into accessor definitions, so the table is the source and the code is generated from it. The rebuild's recent commit moves the x86 and A64 tables toward vendor-manual rows. That is the same pattern, and Appendix E is a worked example of it, with a size. It is not a claim about instruction sets.

4. Generated evaluator and emitter. The IS pipeline (p.10) and OMeta's two-stage design (AST first, then code generator, Appendix D, pp.42-43) support the rebuild's plan for an evaluator generated by Maru's own emitter. The report does not say how the first generation is seeded. The rebuild must say that for itself: which C evaluator or emitter builds the first Maru-in-Maru output, and how the output is checked against the seed.

5. Reference and optimized paths. The Jitblt case (F6) is the closest thing to a generated, optimized path checked against a plain reference: the generated compositing pipeline is judged against hand-optimized code. The report does not show a systematic check. The rebuild can make it explicit: keep the slow reference evaluator and the simple table-driven assembler as the meaning, and compare the optimized emitter against them.

6. DSLs and grammars. OMeta (p.18) is the strongest source for "grammar as program", and its self-description size (40 to 100 lines, G2) is what the rebuild would need to budget. Gezira (p.14) and the planned graphics DSL (p.14, not delivered) are the source for the Nile-style move. Nile itself is not in either source, so I cannot assess it from these two documents.

7. The 10k line budget. Neither source states 10,000 lines; both state 20,000 (2006, p.1; 2007, p.5 and p.7 in comparisons). The project notes' "VPRI's 10k lines" is therefore not from these reports. The STEPS components named here sum to a few thousand lines (for example, IS about 1000, JavaScript 170, Gezira 450, Jitblt 460, TCP 200, OMeta about 40 to 100), while the universal-polygon UI prototype was 3,500 (p.16). That gives a calibration table for the rebuild, and it shows that UI and graphics are where budgets go.

8. Lineage names. The Booth-reading target asked about the COLA/Pepsi/Coke/Maru lineage. In this report, COLA is named but not defined (pp.35-36, 45); "Pepsi" is a heading (p.28); "Coke" is absent; Maru is absent. The lineage cannot be reconstructed from this document. The COLA white paper and the Lieberman-prototype and bare-blocks memos are listed as reading (reference list p.36).

9. Host and bottom. The report avoids C at the bottom (p.6) but depends on Squeak and JavaScript for its experiments (pp.9, 19, 28). For the rebuild, the honest form is "bootstrapped from a host that is then replaced", with the host named and sized. Maru's untyped C evaluator is that host now.

10. Validation before scale. The report's method (p.9) is to build cheap experiments, measure their size, and only then extend. The rebuild already does this with `make check` and the named checks in CLAUDE.md. What the report adds is the habit of recording sizes for each experiment, so that the calibration accumulates.

11. Next reads that this report points to (not read here): the COLA white paper (reference list p.36), Warth and Piumarta's OMeta paper (reference list p.35), Piumarta's "Open, Reusable Object Models" (reference list p.36), Amelang's forthcoming thesis (cited p.12, p.35), and the Appendix G formulas, which are in the PDF as figures and need the PDF itself.

## Permanent notes extracted from this source

- [[a-line-count-needs-a-stated-boundary]]: size claims need their counting boundary written down
- [[steps-budgeted-20k-lines-of-meaning-code]]: the STEPS figure is 20,000, not 10,000
