# STEPS Toward the Reinvention of Programming, 2012 Final Report (Ohshima, Amelang, Kaehler, Freudenberg, Lunzer, Kay, Piumarta, Yamamiya, Borning, Samimi, Victor, Rose, 2012, VPRI TR-2012-001)

Source: https://tinlizzie.org/VPRIPapers/tr2012001_steps.pdf
(Local text used: scratchpad `sources/tr2012001_steps.txt`, 51 printed pages.)

Reading note on the source. Pages 1-19 (the report proper) are extracted with a font-encoding problem: body glyphs are substituted, so most sentences are unreadable as extracted. I decoded them by building a glyph map from words that were readable in context, and I cross-checked each decoded number against the clean appendices and against arithmetic inside the text. Pages 20-51 (Appendices I and II, the KScript/KSWorld and KSWorld applications papers, plus the File List listings) are clean. Where a digit is decoded but not confirmed, I say so in G. Page numbers are the printed "VPRI TR-2012-001" page numbers.

## A. Classification

- Genre: a final progress report to the NSF (the NSF part of the project ends 2012), with two previously published research papers attached as appendices. Pages 1-19 are the report; pp. 20-33 are Appendix I (KScript and KSWorld); pp. 34-35 are its File List code listings; pp. 36-49 are Appendix II (building applications in KSWorld); pp. 50-51 repeat the listings.
- Mode: an expository progress report that doubles as an argument. It is partly a status report and partly a thesis defended by example ("personal computing in about 20,000 lines of meaning-laden code").
- Field: programming languages and systems design, with GUI frameworks and graphics. The text sits closer to design research than to measurement; its quantitative claims are almost all line counts and frame rates.
- Audience: a general reader first (pp. 2-6 are written for the public), then systems researchers (pp. 6-19), then implementers (the appendices).
- Reliability markers: self-reported, no independent evaluation, no baseline measured by the authors themselves for the comparisons they draw against "standard" systems (see G).

## B. Unity

The whole report argues one thesis in three parts. (1) Most of the complexity of current personal computing is accidental, not inherent (pp. 2-4). (2) It can be removed by inventing a small set of domain-specific languages, each compact because it is written in the "runnable mathematics" of its domain, and by building each system from its own languages, so that the system is small enough to understand (pp. 4-6, 13). (3) The project tested this by building working pieces (the Nile graphics system, the Maru-based language chain, the KScript/KSWorld GUI framework and the Frank document editor) and by counting their lines (pp. 5-11, 20-33, 46-48). The stated test of success is the line count and the understandability of the result (p. 6).

The report's unifying term is "meaning": the 20,000-line budget was meant for meaning-laden code, with optimization code counted separately and at first not counted at all (p. 4). The later sections (pp. 13-18) show the project moved from that single goal to three competing ones (real-time on a laptop, universal documents, cooperating solvers), and the report is candid that this split the effort.

## C. Outline of major parts

Body, pp. 1-19:
- pp. 1-4: Public summary. Origin in asking why systems are so large (p. 3). Aim: personal computing as a whole. "Science project" framing, the "General Approach" heuristics, "t-shirt programming", and an overall map of the project (p. 4).
- pp. 4-5: Overview of results. The "universal document" editor (Frank) and "runnable maths" (Nile).
- pp. 5-6: Nile graphics as a runnable mathematics; the Nile compiler made by a metatranslator; "Assessing STEPS" (p. 6).
- p. 7: 2012 research summary, in four areas: a language for UI and applications and the rewrite of Frank; a "chain of meaning" from the screen to the CPU; automatic visualizers; "What vs How" with cooperating languages and solvers.
- pp. 8-9: Worked example of a bubble (a tool-bar panel) in KSWorld.
- pp. 10-11: The Maru-based chain of meaning, Maru's description, and the sidebar on bootstrapping Maru from itself.
- p. 12: Automatic visualizers for Nile programs; "worlds of solutions" for text layout.
- pp. 13-14: Cooperating solvers and cooperating languages; Dedalus and Bloom.
- pp. 14-15: Overall findings; the claimed scale of 1,000s to tens of thousands of lines.
- pp. 15-18: Reflections: "more languages than planned"; the engine room; universal documents; what was left undone; a significant unsolved problem (intermodule coordination).
- pp. 18-19: References (about 20 items).

Appendix I, pp. 20-33: KScript and KSWorld (Ohshima, Lunzer, Freudenberg, Kaehler). Sections: 1 Intro; 2 KScript language; 3 Fixing FRP's problems (set, previous value, late binding); 4 KSWorld framework (Boxes, event routing, the top-level loop, layout, the halo); 5 Buttons; 6 Tools (File List, bubble panel); 7 Document editor (stacks, bubble selection, directory browser, tile scripting); 8 Example documents; 9 Complexity and performance (Table 1); 10 Related work. Acknowledgments and references at pp. 33.

Appendix A and B, pp. 34-35: File List layout and behavior listings.

Appendix II, pp. 36-49: Making applications in KSWorld. Sections: 1 Intro; 2 Revised KScript; 3 File List; 4 Icon via the Shape Editor; 5 Tool-bar panel; 6 Text fields; 7 Document editor; 8 Line counts per component; references.

Appendix A and B repeated, pp. 49-51.

Concrete artifacts named (sub-list, with the line counts the report attaches):

Systems and tools
- STEPS (the project, p. 1-4); NSF proposal 2006 (p. 4, ref list).
- Frank, the universal document editor, also called the "Document Editor" (pp. 3-5, 20, 29-31, 36, 45-46). Table 1 subtotal: 1,769 lines for the editor and its controls (p. 32; p. 47).
- KSWorld, the GUI framework (pp. 20-33, 36-49). Table 1 essential subtotal 10,055 lines; with Gezira bindings 2,330 lines and the rest 4,973; total 17,358 (p. 32; p. 47).
- Nile language and Nile graphics processor / compiler (pp. 5-6, 10-12). Stated size: under 500 lines of Nile for all of 2.5D graphics (p. 10, decoded; see G). Gezira (rendering engine by Amelang), "about 450 lines of Nile code" (App. II p. 48, clean).
- Maru (the self-hosting base language and system) and Maru-Meta (the metalanguage/metatranslator), with "Maru Description" (pp. 10-11). Maru's basis of hand-written code is stated at about 4,400 lines (p. 11). Verified from the page image. The diagram breaks it down as: Maru code chain = Parser 248 + CodeGen 1,357 + Assembler 621 = 2,226; Maru runtime 1,320 + library 771 = 2,091; total 4,317. Maru-Meta describes itself in about 100 lines; the Nile compiler description is 994 lines of Maru-Meta; Nile graphics is 495 lines of Nile.
- Meta (the metatranslator executable) (p. 6).
- Squeak Smalltalk (host environment for KSWorld; pp. 31, 47-48).
- Morphic (Squeak UI framework; pp. 20, 25, 48).
- OpenGL composition (288 lines, App. II p. 48). ODF and SVG importers (492 + 1,140 lines in Table 1, p. 32; p. 48).
- Lessphic (Piumarta; ref [11], p. 33), LWorld (the authors' earlier framework; App. II pp. 36-37, 42), Quiche (acknowledged, p. 33).
- Gezira, Nile, Frank, KSWorld, and KScript are the core design names. "Tweak", "Garnet", "Animus", "Forms/3", "Kaleidoscope" are cited as related systems (p. 32-33).

Languages
- KScript (dataflow/FRP language with CoffeeScript-like syntax; App. I pp. 21-25; App. II pp. 38-41). Compiles to Squeak Smalltalk (App. II p. 47).
- Nile (App. I, p. 5; p. 10-12).
- Maru (p. 10-11) and the Maru description language.
- OMeta (Warth; acknowledged, p. 33), OMeta/JS 2.0 and OMeta2/Squeak (the KScript parser about 450 lines; App. II p. 47; ref [11]).
- Flapjax (combinator names; App. I p. 23), Lucid (pre/fby; App. I pp. 22, 24), Compel (ref [8]), Forms/3 (ref [6]), Garnet (ref [18]), Kaleidoscope (ref [19]), CoffeeScript (ref [7]), JavaScript (p. 16), Prolog (p. 16), Logo (not named), Ruby (Bloom implementation, p. 14), Dedalus (Datalog with time; ref [17], p. 14).
- Cooperating languages / solvers framework (pp. 13-14); "Things" language (ThingLab-derived); a spring-and-strut language (p. 14).
- Bloom (implemented in Ruby; p. 14).

Solvers
- Cassowary (linear constraints, Badros/Borning/Stuckey; p. 14, ref).
- Kodkod (relational model finder; p. 14, "Bodkod" in the decoded text).
- A solver for uninterpreted functions, an SMT-based solver (name partly garbled; p. 14), and a naive depth-first search solver (p. 14).
- Cologne distributed constraint optimization (p. 15 ref list; mentioned as related work).

Line counts that the report states explicitly (all in "lines of code"):
- 20,000 lines: the original budget for meaning-laden code for everything "down to the metal" (p. 4; repeated pp. 6, 13, 15).
- 100 million lines: the stated size of a typical desktop OS plus application suite (App. I p. 20; App. II p. 36).
- Table 1, KSWorld and Frank (p. 32; p. 47): KScript compiler 753; basic object model 291; FRP implementation 654; basic model of Box 2,133; Box support 548; text support 962; common handlers 760; layout 716; stack 209; Document Editor 1,769; serialization 1,260; subtotal 10,055. Gezira bindings 2,330; OpenGL 288; spreadsheet table 95; SVG importing 492; ODF importing 1,140; development support 1,110; tests 1,848; subtotal 4,973. Grand total 17,358.
- File List: about 25 lines of layout, 40 lines of stream definitions, 10 lines of setup, versus about 250 lines of Smalltalk for the LWorld version (App. II p. 42; App. I p. 28).
- Button: about 12 lines of stream definitions for the state logic (App. I p. 27); about 50 lines for the whole button (App. II p. 47). Stated 5-to-1 reduction over LWorld (App. II p. 37).
- LWorld constraint code: just over 700 lines (App. II p. 37).
- Nile Language form about 130 lines; the meanings and optimizations about 750 lines (p. 6-11; decoded, tentative).
- Metatranslator definition: about 100 lines of definition code plus other modules (p. 6, decoded from clean-looking digits).
- Maru basis about 4,400 hand-written lines (p. 11; verified from the page image: 248 + 1,357 + 621 + 1,320 + 771 = 4,317). The assembler is 621 lines and covers all x86 instructions; the report says the basis would be about 500 lines smaller with only the instructions Maru and Nile use (p. 11, verified).
- KScript compiler in the Maru-era chain: 753 lines (p. 11; matches Table 1).
- Replacement of about 50,000 lines of Smalltalk scaffolding by about 10,000 lines of KScript (p. 7, decoded).
- 20,000 lines of code equals a 400-page book at 50 lines per page (p. 6, decoded).
- Dynamic size of the document editor: about 530 Boxes at launch, 13-18 streams per Box, about 8,800 streams; about 80,000 streams with a 4,000-character page (App. I p. 32).
- Frame rate: 30-50 fps on a 2.3 GHz laptop; 70% of time in rendering; as low as 2 fps during text editing (App. I pp. 32-33).

People responsible (as the report attributes them)
- Authors (all listed on the title page, in random order): Ohshima, Amelang, Kaehler, Freudenberg, Lunzer, Kay, Piumarta, Yamamiya, Borning, Samimi, Victor, Rose.
- Named in acknowledgments and text: Amelang (Gezira and Nile design, p. 33/48); Piumarta (Lessphic and Quiche designs; p. 33); Warth (OMeta; p. 33); Yamamiya (KSObject inspector; p. 33); Samimi and Borning (testing of KScript; p. 33; cooperating solvers and languages, pp. 13-14); Raab (frameworks, acknowledged in memoriam, p. 33); Guha (design discussions, p. 33).
- Not attributed in the text: who wrote Maru, Maru-Meta, and the x86 assembler. Maru's lineage is not named (see G).

## D. Author's central problems

1. Accidental versus essential complexity. The report starts from the claim that a typical desktop OS and application suite is over 100 million lines and that most of this is "accidental" (App. I p. 20; p. 2-4). The problem is to find how much of that can be removed without losing function.
2. How small can a complete personal computing system be? The target is 20,000 lines of meaning-laden code for everything from the hardware up (p. 4; p. 13).
3. How to make a system that is understandable, not just small: "pretty", "beautiful", with designs and code that can be read (p. 2; p. 6). The authors treat understandability as a separate requirement from size.
4. How to write the system's parts in a language suited to each part, without writing each part in a generic language. The report argues for domain-specific languages and for the "runnable mathematics" of each domain (pp. 5-6, 13).
5. How to make the languages cheap to build, given that language implementation is itself a large part of the work (pp. 16-17). The authors' answer is metacircular bootstrapping: the metalanguage is written in itself (pp. 6, 10-11).
6. How to keep a GUI authoring environment live and exploratory while using a declarative model: FRP with late binding, loose coupling and time (App. I pp. 20-25).
7. Whether real-time performance on a laptop is compatible with the code budget. This became a central problem in mid-project (pp. 16-17).
8. How to coordinate many small languages and solvers, the "What vs How" problem (pp. 7, 13-14; App. I p. 20).

## E. Key terms

- Accidental complexity: complexity that comes from the medium or from poor design rather than from the problem (App. I p. 20; p. 2).
- Meaning-laden code: code that states what a thing means, as opposed to code that optimizes it. The line budget counted only this at first (p. 4).
- Runnable mathematics: a notation that is both a standard mathematical description and an executable program (pp. 5-6).
- Chain of meaning: a sequence of transformations from a high-level language to executable machine code, with the intermediate steps also described in languages (p. 7; pp. 10-11).
- Metacircularity: a language whose implementation is itself written in it, so it can describe its own compiler and optimizations (p. 10).
- Maru: the self-hosting base language and system in this report, with a Maru-Meta metalanguage, and an AST abstraction, a PEG-based parser generator, a compile-time AST evaluator, and code generation including instruction selection and register allocation (p. 10).
- Metatranslator (Meta): an executable that reads a language description and produces a language processor; it can be fed a description of itself and regenerate itself (p. 6).
- Nile: a DSL for 2.5D graphics; compiled through the chain of meaning to machine code (pp. 5-6, 10-12).
- Gezira: the vector rendering engine written in Nile (App. I p. 25; App. II p. 48).
- KScript: a dynamic, dataflow-based language with time-aware, FRP-style "streams", late-bound variable references, and loose coupling (App. I pp. 21-25).
- KSWorld: a GUI framework built on KScript in which graphical objects (Boxes) are KScript objects (App. I pp. 25-26).
- Frank: the universal document editor built on KSWorld; a stack of pages, a ribbon-like tool bar of bubbles, and a directory browser (pp. 3, 29-31).
- Stream, behavior, event: the basic FRP units. A behavior has a current value; an event is a discrete change (App. I p. 22).
- Halo: a direct-manipulation handle around a selected Box (App. I p. 26).
- Bubble: a panel of related commands in the tool bar (App. I pp. 29-30; App. II pp. 44-45).
- Cooperating languages and cooperating solvers: a scheme in which constraint solvers and small languages exchange results through a bipartite constraint graph partitioned into regions (pp. 13-14).
- Dedalus and Bloom: a Datalog variant with explicit time, and its implementation as a DSL in Ruby, used to coordinate solvers (p. 14).
- Universal document: one document type for all document kinds, with a common fetch/store model (pp. 5-6, 17).
- t-shirt programming: a design heuristic: find the one compact model that captures a domain on a t-shirt (p. 4).

## F. Main propositions and arguments

F1. Most of personal computing's code is accidental and can be removed (App. I p. 20; p. 2-4). Reason given: the authors' earlier experience (in LWorld and earlier Smalltalk frameworks) showed that much of the code concerns plumbing, such as connecting events to actions and placing widgets, and that a declarative model removes much of it (App. II pp. 36-37). The evidence is the reduction they report for one widget and one tool (see F5).

F2. A personal computing system can be built in about 20,000 lines if the parts are written in the right languages (p. 4; p. 13). Reason: the budget was chosen to force design, not as a result; the authors argue that compact DSLs carry most of the meaning. Their own verdict is that they were "correct in thinking that a lot could be done" but covered "a bit less ground than expected", and that the optimization work for laptop performance "fought some of the original goals" (p. 15).

F3. Domain-specific languages written as "runnable mathematics" are much shorter than conventional code, and an executable can be made from a short language definition (pp. 5-6). Reason: Nile's graphics definitions are written in close to the mathematical form of the rendering formula (p. 5), and a metatranslator turns a language definition into a compiler. The stated figures for Nile are small (under 500 lines of Nile for all of 2.5D graphics, p. 10); the meaning-plus-optimization code for the Nile language is about 750 lines (p. 6; decoded tentatively).

F4. Metacircular bootstrapping keeps the system small. Reason: the Meta executable can make itself when fed a description of itself (p. 6); Maru is "made from itself" (p. 11, sidebar); the compile-time AST evaluator lets hosted languages supply their own analyses in the same notation (p. 10). The stated base is about 4,400 hand-written lines for Maru's basis, of which about 500 lines would be saved by assembling only the instructions used (p. 11; tentative).

F5. KScript and FRP make GUI code much shorter. Reason: a button's states (pressed, entered, clicked) are each one stream definition, so the logic is separate from the appearance (App. I pp. 26-28). The File List needs about 75 lines in KScript, against about 250 Smalltalk lines for LWorld (App. II p. 42). A 5-to-1 reduction is claimed (App. II p. 37).

F6. Late-bound references and loose coupling make the system easier to change and serialize (App. I pp. 23-24). Reason: references are resolved at each evaluation, so definitions can be added, removed or moved without bookkeeping, and an object can refer forward to something not yet defined (App. I p. 24).

F7. Direct manipulation and programming can be the same activity: the user changes the appearance and then attaches stream definitions in the same live object (App. I p. 20; p. 25; App. II pp. 40-44). Reason: the environment is a dynamic object model, so the inspector, halo and shape editor edit live objects.

F8. Real-time behavior on a laptop is achievable: 30-50 fps in common cases (App. I p. 32). Reason stated: rendering is the main cost, and the stream sorter is cached (App. I pp. 32-33). The authors also report that editing text can drop to 2 fps (App. I p. 33).

F9. Languages and solvers can be composed through a common partitioned constraint graph (pp. 13-14). Reason: constraints are split into regions, shared variables are read-only for all but one region, and each region's solution is then a dataflow problem (p. 13). Five solvers were tried, and two were run in separate processes through Bloom (p. 14).

F10. A small-counting discipline is itself a design aid. Reason: counting the code for languages and runtimes "provided a useful motivation to keep the language specifications clean and small" (p. 16).

F11. The "universal document" can subsume word processing, desktop publishing, presentations, email and web pages (pp. 5-6, 17). Reason: the report says the desktop-publishing and presentation parts were built, while email and web were only sketched (p. 17). The claim is a design thesis; the evidence covers only part of it.

## G. Critique

Scope, definitions, and what is counted.

G1. (Incomplete; the headline number has an uncounted host.) The 10,055-line "essential" subtotal and the 17,358 total (App. I p. 32; App. II p. 47) are for KScript, KSWorld and Frank. The report states that KScript compiles to Squeak Smalltalk (App. II p. 47) and that Box support gets its frame buffer and raw events from Squeak through a custom Morph (App. II p. 47). Squeak's VM, its object memory, its collections and its graphics, and the Morphic framework are not counted. The report says the tool "aims to be self-sustained" (App. I p. 33), but the counted system is not self-sustained at the bottom.

G2. (Incomplete; two stacks never summed.) The Maru/Nile chain (pp. 10-11) and the KSWorld GUI (Table 1) are reported separately. The Nile graphics engine is said to be about 450 lines of Nile (App. II p. 48), and it is not in Table 1 at all; Gezira's Smalltalk bindings (2,330 lines) are. Nothing in the report gives a single whole-system number that combines the Maru/Nile toolchain, the Smalltalk host, and the KSWorld layer. The "20,000 lines" headline is therefore never tested against a counted system.

G3. (Illogical comparison.) The report compares its line counts with "standard" systems (p. 6) and calls the ratios "factors of 100, 1000 and more" (p. 6). The comparison is between a counted subset of a new system and an uncounted estimate of an old one (the 100 million lines of p. 20 and p. 36, with no source). The authors admit the apples-and-oranges problem (p. 6) but still draw the ratio.

G4. (Inconsistent counting boundary.) A button is "about 12 lines" of stream definitions (App. I p. 27) and "about 50 lines" in Appendix II (p. 47). These are both correct under their stated scopes, but a reader who sees one number will not see the other, and the report does not reconcile them.

G5. (Misinformed by omission.) The report says that counting "tools" in the totals is "rarely done" in industry and that they count tools in the totals (p. 10). That is a sensible policy, but the Smalltalk host, the OS, the x86 hardware and the Squeak VM are the tools this report leaves out, while the Maru assembler is included. The inclusion rule is applied to some tools and not to the host.

G6. (Tests.) The 1,848 test lines are counted in the 17,358 total but not in the 10,055 "essential" figure. The authors concede the count "could certainly be made lower" by avoiding redundancy (App. II p. 48).

Maru and bootstrap.

G7. (Uninformed: lineage is not named.) The report never names COLA, Pepsi, or Coke. Maru's authorship is not stated. The Appendix II acknowledgments credit Piumarta for key designs in the Lessphic and Quiche work and Amelang for the Gezira engine (App. II p. 48). The Maru row in the report has no attribution. Any claim that Maru descends from a specific predecessor has to come from sources outside this report.

G8. (Incomplete: the seed is not counted.) The report says it did not use existing low-level tools such as C (p. 10) and built the "engine room" from scratch using minimal interpreters and bootstrapping techniques (p. 17). It never states the size of the seed: the first hand-written code that runs before Maru can compile itself. The "about 4,400" basis (p. 11) is the closest number, and it is for Maru's basis, not the seed. Without the seed size, the "metacircular" claim is not checkable.

G9. (Aspiration vs result.) The statement that Nile can generate "all graphics" and that the chain of meaning goes "all the way" to CPU instructions (p. 10-11) is demonstrated for Nile only. For KScript, the chain ends in Squeak Smalltalk (App. II p. 47). The report's own summary says the "chain of meaning" is "a workable chain" (p. 7); that is accurate for Nile and not for the GUI.

G10. (Aspiration vs result.) "Automatic visualizers" (p. 7, pp. 11-12) are shown for Nile programs only. The report calls the wider exploration of the whole system "a future research topic of great interest" (p. 6), and says more visualizer work "could use much more work" (p. 6).

G11. (Aspiration vs result.) "Cooperating solvers" and "cooperating languages" are described as an architecture (pp. 13-14). Two solvers were run across processes; the rest is planned. The report says it "plan[s] to implement" a Squeak Bloom "in the next months" (p. 14). The architecture is a plan, not a result.

G12. (Aspiration vs result.) "Universal documents" subsume many document types (pp. 5-6). Desktop publishing and presentations were built; email and the web were not (p. 17). The sentence "could subsume" is the report's own description of what it did not finish (p. 17).

G13. (Aspiration vs result, numbers.) "By any measure, this is many orders of magnitude smaller" (p. 15) is supported by no computed ratio in the report. The 1,000-fold claim (p. 6) is an estimate.

G14. (Performance and count are in tension, and the report admits it.) The laptop goal "fought some of the original goals" (p. 15). The authors add optimization code to the count "that we have had to add" (p. 4), and say that with more time they would have tried metatracing as in PyPy (p. 17). Because optimization was not in the original count, the 20,000 figure is not a like-for-like baseline for the real-time system.

Tentative numbers and readings.

G15. (Parent session, 2026-10-14: p. 11's figures were checked against the rendered page image, and its Maru figures are exact, see C and F. The other body pages remain decoded.) Several line counts in the body (pp. 5-11) were decoded from the garbled extraction. Confidence: high for "under 500 lines of Nile" (p. 10), "about 100 lines" for the metatranslator definition (p. 6), the "400-page book at 50 lines per page" arithmetic (p. 6), and the KScript compiler at 753 (p. 11, matches Table 1). Medium for the Maru basis of about 4,400 (p. 11), the Nile language form (p. 6) and the meanings-plus-optimizations figure (p. 6), and the replacement of about 50,000 Smalltalk lines (p. 7). Low for the Nile graphics figure on p. 5 (the middle digit is not readable) and for the Nile sum on p. 11, which I could not verify. Treat these as "approximately" and check the PDF before quoting them.

G16. The report cites a Maru of about 4,400 lines. Table 1 also gives Gezira's Smalltalk bindings at 2,330 lines, and the Nile engine at about 450 lines of Nile. These three figures come from different counting scopes and should not be added without a stated rule.

Sound and unsound moves.

G17. (Illogical, mild.) The report argues that a small language is easier to implement than to design (p. 16), and then that the "special language for each application area" is powerful but should be distilled into "a more general specification language" (p. 16). These are consistent only if the general language is itself designed and counted. The report does not show it.

G18. (Uninformed about prior art, partly.) Constraint systems, FRP and Datalog are cited with a short comparison (App. I pp. 32-33; p. 14). The comparison with Garnet and Animus is brief. The report does not compare its line counts with any other self-hosting system (for example Lisp or Forth bootstraps) under a common rule.

## H. What of it?

For a Maru rebuild with a hard ceiling of 10,000 lines, the report is useful less for its figures than for the way its figures are built.

1. The budget rule. STEPS counted meaning-laden code first and optimizations later, and left the host uncounted. A rebuild should state its counting rule in one place before any number is quoted. The rule in this repository (count the source, exclude `derived` files marked in `.gitattributes`, budget 10,000 per `check/lines`) is stricter than STEPS in one respect (generated code is excluded) and looser in another (the host toolchain is not counted at all). Decide which of those applies to the seed, the C/native bootstrap, and any generated evaluator. STEPS shows that an undeclared host is where a small-looking system's real size goes (G1, G2).

2. The seed. The report never sizes its seed. For this rebuild, the seed is the first thing that has to be counted: the minimum native or C code that lets Maru compile its own description. Name it, count it, and keep it under the same ceiling. Without this, the claim that the evaluator is "generated by Maru's own emitter" cannot be checked against the budget (G8).

3. Table-driven assemblers. The one number in the report about assembler cost is the x86 assembler: the full ISA costs roughly 500 more lines than the subset actually used (p. 11, verified from the page image: the assembler is 621 of Maru's 4,317 lines). That is the case for generating the assembler from a table and emitting only the instructions a build needs. It also supports the rebuild's gen-asm-x86.k and A64 table approach, which keeps the instruction spec as data and generates the encoder. The report offers no measured size for a table-driven assembler, so the budget claim for the A64 table is still to be measured.

4. DSLs and grammars. The report's strongest practical lesson is that PEG grammars handled nearly all its parsers and were "relatively easy" to make and use (p. 16). That supports the rebuild's preference for grammar-based parsers over hand-written ones. The same passage warns that optimization, not parsing, dominates the work once real-time performance is a goal (p. 16). Plan the budget for optimization explicitly, or fix the performance target so optimization stays out of the 10,000.

5. Metacircularity. The Meta executable regenerating itself from a description (p. 6) and the compile-time AST evaluator (p. 10) are the closest published analogs to the rebuild's plan that the evaluator be generated by Maru's own emitter. The report does not show the regeneration step's size, its fixed-point check, or what the first generation was built from. Those are the three things the rebuild needs to verify.

6. Scope of the chain of meaning. The report's end-to-end chain is for Nile only (G9). For the rebuild, decide whether the chain has to reach machine code for every language or only for the parts whose speed matters. STEPS's choice (run the graphics chain fast, let the GUI sit on a host) left the most costly part outside the count.

7. Baselines. The report's ratios are not computed against a measured baseline (G3, G13). If the rebuild quotes a ratio, measure the comparator the same way.

8. The unfinished parts are the rebuild's warnings. STEPS did not finish email, web, cooperating solvers, the bottom engine room, or large-scale coordination (pp. 14-18). Those are the parts most likely to grow past a 10,000-line budget, and the report's own text says so (p. 17).

Bottom line for the user: STEPS is evidence that a few thousand lines of DSL and a metacircular base can carry a useful amount of function, and that the cost moves to the host, to optimization, and to the seed. The rebuild should count those three things explicitly and should not treat the STEPS headline number as a measured total.

## Permanent notes extracted from this source

- [[assembler-coverage-should-cost-rows-not-code]]: Maru's 621-line assembler and the case for encoding tables
- [[compiler-size-concentrates-in-code-generation-not-parsing]]: parsers are cheap; code generation and optimisation are where lines go
- [[steps-budgeted-20k-lines-of-meaning-code]]: the STEPS figure is 20,000, not 10,000
- [[a-line-count-needs-a-stated-boundary]]: size claims need their counting boundary written down
