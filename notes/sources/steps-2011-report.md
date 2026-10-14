# STEPS Toward Expressive Programming Systems: 2011 Progress Report (Amelang, Freudenberg, Kaehler, Kay, Murrell, Ohshima, Piumarta, Rose, Wallace, Warth, Yamamiya, 2011, VPRI TR-2011-004)

Source: https://tinlizzie.org/VPRIPapers/tr2011004_steps11.pdf

Authorship: the title page lists eleven names in alphabetical order and no roles. The report is issued by Viewpoints Research Institute. Page numbers below are the printed page numbers. The 2011 report is the first of the two to name Maru, so it is the one that matters for the rebuild. The 2010 report is the earlier one (see the companion note, steps-2010-report.md).

## A. Classification

An annual progress report to the NSF (Year 5 of award 0639876), not peer reviewed. It says it is "a progress so far report" because the project has been extended to six years and the next report will be the last (p.4). It has four parts: a plain-language summary (p.2); a one-page status summary and design essay (pp.3–6); a subsystem-by-subsystem account with screenshots and short code (pp.6–27); and two appendices, an "active essay" that builds the text layout system (Appendix I, pp.29–33, images only in the PDF text I worked from) and a Smalltalk-like language with an FFT demonstration written in Maru (Appendix II, pp.34–42).

In Adler and Van Doren's terms it is informative, with one part that is close to inspectional and that the reader can check: Appendix II gives source and output. Most of the rest is claims and screenshots. Two of the largest claims about the bottom of the stack, Maru and Nothing, are stated as goals or estimates rather than results.

## B. Unity

The 2010 question carries over. Can the phenomena of personal computing "from the user down to the metal" be expressed in 20,000 lines, using only the project's own code (pp.5–6)? The 2011 answer has the same shape as 2010: pick an area, derive its mathematics, write a problem-oriented language (POL) that is that mathematics, and then stitch the parts into Frank (p.6). What is new in 2011 is that the report puts the bottom of the stack at the centre. It asks how the high-level languages reach the CPU without C, and gives two candidate answers: Nothing, a BCPL-like low-level language, and Maru, a self-compiling Lisp-like language (pp.22–24).

The unity the report wants is a single chain of translations from the user's notation to machine code, in which each link is a language the project wrote. The report is honest that this chain is not complete: Nile is still compiled to C (p.24), and the low-level runtime language "has not been designed" (p.24).

## C. Outline of major parts

1. Title page and plain-language summary (pp.1–2).
2. One-page summary: status, what is still to do, and the "active essay" idea (p.3).
3. Introduction and context: the six-year project, the 20,000-line measure and the reflection on design (pp.4–6).
4. "STEPS in 2011": the goal, the approach (POL per area, then stitch) and the Frank picture (pp.6–7).
5. Summary table of areas, and the subsystems: graphics (pp.8–10), math syntax (pp.10–11), sound and movies, graphical objects, files, email, browsing (p.11), universal documents (pp.12–14), text (p.13), GUI (p.13), desktop publishing and presentations (p.14), spreadsheets and cells (pp.15–16), databases and scripting (pp.16–17), explanations (p.17), making languages (p.18), "NoOS" (pp.19–20), simulation of time with worlds (pp.20–21), TCP/IP (p.21), and dealing with CPUs (pp.22–25), which holds Nothing and Maru.
6. Importing and exporting, and experiments (pp.25).
7. Training, outreach (pp.25–27), references (p.28).
8. Appendix I: the active essay on text layout (pp.29–33).
9. Appendix II: Maru code for a Smalltalk-like language, an FFT and a plot, with output (pp.34–42).

Concrete artifacts named in the report

Systems, languages and subsystems
- Frank: the integrated personal computing system, "a bit of a Frankenstein's monster" (pp.3, 6–7). The report itself was written in Frank and exported to PDF (p.7).
- Gezira: graphics engine (pp.8–10). Nile: the stream language that runs it (pp.8–11, 18). Nile's graphics are "457 lines" in total (pp.6, 8–9).
- Ants: a POL for text layout based on particles and fields, with 35 rules for a WYSIWYG editor and paragraph layout (p.13; Appendix I, pp.29–33).
- DBjr is not named in 2011. The universal document, the ribbon UI and the "bubbles and spill areas" are (pp.7, 12–13).
- OMeta: PEG-based transformation language, used to make the STEPS languages (pp.18, 25). A variant syntax and a module system for OMeta were added (p.25).
- Worlds: first-class state scopes with commit (pp.20–21; paper cited as ECOOP 2011, p.28).
- Nothing: a BCPL-like low-level language (pp.22–23). Cited as "STEPS 2010 4th Year Progress Report" (p.28).
- Maru: a self-compiling Lisp-like language and intermediate representation (pp.22–24; Appendix II, pp.34–42). Cited as Piumarta, "Open, extensible composition models", FREECO'11 (p.28).
- COLA: named once as the earlier work Maru "builds on" over "the last 4 years" (p.22). It is not defined in this report.
- Nile's prior back end: C (pp.22, 24–25). Nothing: an alternative back end (p.22–23).
- A Smalltalk-like language built over Maru (p.24, Appendix II).
- The "leg" parser-generator system, used for a Squeak bytecode compiler (p.25).
- MicroSqueak: a minimal Squeak image of about 250 kB that calls Gezira (p.25).
- Squeak VM, ported to Google Native Client (p.25).
- Tuplespace-based object system, experimental (p.25).
- TCP/IP: first compact version, about 160 lines (p.21).
- Condor PDA: a sales application with SAP, using a global corporate database through cells (p.16).
- OpenOffice Impress import; PDF export (p.25).
- Historical: HyperCard, PARC's Analyst and Smalltalk-based UI, Etoys, Scratch, Locus, Croquet, D. P. Reed's 1978 thesis (pp.11, 14, 19–20, 28).

Line counts stated (with what they count where the text says)
- 20,000 lines: the total target "from end-user down to the metal", using only the project's code (p.6). The report says the project is "still under our code limit" (p.5) but gives no total.
- 457 lines of Nile: all of the STEPS graphics (pp.6, 8, 9). The report says this is "100 times smaller" than other systems (p.6) and "457 lines in total" (p.8).
- Nile's core rendering formula: about 80 lines in the earlier form, now 45 (p.8).
- Ants: 35 rules for the editor and layout (p.13).
- TCP/IP: a first attempt of about 160 lines (p.21). A "typical" TCP/IP in C: about 20,000 lines, with smaller versions "in several thousand lines of C" (p.21). Neither figure is cited.
- The Linux kernel: "about 1000 lines" (p.19). Not cited.
- Maru's line count: not given. The report says Maru's self-compilation uses no hand-written C (p.23), but it gives no size for Maru itself, for its parser generator, or for its garbage collectors.
- Nile in Maru: "page-long" PEG grammar (p.24). Nile source: 457 lines, estimated to run in Maru "in about a month" (p.23).
- Smalltalk-like language in Maru: "333 lines of code (with blank lines and comments removed)" (p.34). See G for what I could and could not reproduce.
- Multicore: a 40-core run "nearly 30 times speedup" (p.9). The 4-core, 8-thread laptop demo (p.9) is described but not tabled.
- 2.5D graphics: "virtually all" in 457 lines (p.6).
- Tile scripting, databases, UI: no counts.

People responsible
- Alan Kay: project lead and presenter (p.26–27).
- Ian Piumarta: Maru, Nothing, OMeta, the PEG work and the Kyoto and FREECO talks (pp.25–26, 28).
- Yoshiki Ohshima: Worlds with Warth, the Universal Document demo at ECOOP 2011 and Kyoto talk (pp.26–27).
- Alessandro Warth: Worlds (p.27–28).
- Dan Amelang: Nile and Gezira; PhD at UCSD (p.25–26).
- Bert Freudenberg: presented at HPI, Potsdam (p.26).
- Ted Kaehler, Stephen Murrell, Scott Wallace, Kim Rose, Takashi Yamamiya: named on the title page; roles not stated in this report.

## D. Author's central problems

1. Size. The 2010 question remains: can a complete personal computing system be written in about 20,000 lines of meaning code (pp.4–6)?
2. Comparison. How do you measure "1000 times smaller" across systems that do not do the same things? The report calls this "apples and oranges" and changes the measure (pp.3, 6).
3. Counting the bottom. Standard systems do not count their C compilers and IDEs, but this project must count its own bottom and tools if its claim is to be honest (p.22).
4. Speed without mess. The bottom has to run fast enough for real-time graphics on a laptop, but the code at the bottom is "often ad hoc and messy" once optimized by hand (p.3; see also p.22).
5. A chain, not a stack. The high-level DSLs must reach the CPU through a chain of translations the project controls, and the chain must not reintroduce the "optimization tower of Babel" (p.22).
6. Metacircularity. The language used to describe the system must also describe its own optimizations, so the tower collapses into one mechanism (p.22).
7. Loose coupling. Components should interact through events and tuples rather than shared references (pp.20–21, 25).
8. Scoped side effects. Worlds are offered as a way to simulate time and to undo at any scale (pp.20–21).
9. Explanations. Code should be understandable by a self-exploring reader, through active essays that can be edited and run (pp.3, 17).

## E. Key terms

- POL (problem-oriented language): a language whose notation is the mathematics of one area (pp.6, 17).
- Runnable math: the same idea under the 2010 name, now used alongside POL (pp.4, 6).
- Chain of meaning: the sequence of translations from a POL to machine code, which the report says is "CPU independent until the very last stage" (p.18).
- Meaning versus optimization: the 2010 distinction. In 2011 the report says it has stopped making it (p.3).
- Universal document: one document type for pages, slides, email, web pages and cells (pp.12–14).
- Active essay: a document in which the code is live and the explanation builds it (pp.3, 17, 29–33).
- Cells: dynamic retrievers and calculators, which are also viewers (p.15–16).
- World: a first-class state scope that can be sprouted, edited and committed (p.20).
- NoOS: "no operating system", meaning hardware as caches for mobile objects (p.19).
- Real objects and virtual Internet: the networked object model carried over from 2010 (p.19).
- Maru IR: the intermediate representation that Maru projects forward to architectures and backward to views (p.23).
- Metacircularity: low-level mechanisms that implement high-level ones, and analyses described in the forms they analyze (pp.22–24).
- Compile-time AST evaluator: a Maru component that runs ASTs during compilation, so hosted languages can have their own introspection (p.24).
- Benchmarks: the three tests Maru and Nothing must pass, listed on p.23 (self-compile; write own GCs; run the Nile chain without C).
- "Science of Design" with footnote: a concept from CMU, credited to Newell, Simon, Freeman and others (p.5).

## F. Main propositions and arguments

F1. Maru is a self-compiling, Lisp-like language that compiles to machine code directly and needs no hand-written C (p.22–23).
Reasoning: self-compilation is a demanding test of a language and its back end, because the compiler must compile the code that implements it. Status: asserted. The report then qualifies it: Maru "still uses a few standard library routines" for buffered input and output, which "could easily be replaced" with system calls (p.23). So the claim is about the compiler's own code, not about the host runtime.

F2. Maru has garbage collectors written in Maru, one non-moving and one generation-scavenging, both precise (p.23).
Reasoning: a collector written in the language it serves is the second benchmark on p.23. Status: asserted. No collector size, pause time or throughput is given.

F3. Maru is a vertically extended description language. Its one intermediate representation can be projected forward to architectures and backward to views of its meaning (p.23).
Reasoning: an IR that serves both the compiler and its users avoids a separate representation per use. Status: stated as design. The report gives no example of a backward projection.

F4. Maru can host other languages through reusable components: a PEG parser generator, an AST abstraction, a compile-time AST evaluator and a code generator with instruction selection and register allocation, all with entry points for other languages (p.24).
Reasoning: if the components are reusable, each new language costs only its front end. Status: a list of components. The report says the Smalltalk-like language and the Nile front end use them (pp.24, 34), but gives no size for any component.

F5. A Smalltalk-like language can be built as a thin layer over Maru, using Maru's parser and evaluator, and it can run substantial code (p.24, Appendix II).
Reasoning: the language is defined by a PEG grammar that produces Maru ASTs, and kernel methods are written as embedded s-expressions (p.34–37). Status: the strongest evidence in either report. The source is printed, and output is shown (pp.34–42). But the program is run by interpretation, not compiled, and the report says the ASTs "could as easily be passed to Maru's compiler" (p.34), which is not demonstrated.

F6. Nile can be implemented in Maru as a page-long PEG grammar that produces Nile-specific ASTs, followed by analysis and code generation (p.24).
Reasoning: Nile's syntax is small and regular, and Maru's PEG handles it. Status: the grammar is described, not printed. The first code generator target is C, not machine code (pp.24–25).

F7. Maru will generate machine code directly, and the Nile source (457 lines) will run through the Maru chain in about a month, with a further month or so for the low-level runtime language (p.23).
Reasoning: the project's own estimates. Status: a forecast. The 2011 report does not say whether these dates were met; the next report is the one to check.

F8. Nothing runs the whole Nile runtime without C, and gives identical results to the existing Nile system (p.23).
Reasoning: Nothing's kernels run until they stop, can have multiple streams, and are parallel processes (p.23). Status: asserted. The C-built toolchain and the C-written garbage collector are acknowledged (p.23), so "without C" means the runtime, not the build.

F9. The Nile runtime scales across cores almost linearly, and reaches nearly 30 times speedup on 40 cores (p.9).
Reasoning: Nile programs are implicitly parallel. Pipelines run on threads, and stateless processes can be duplicated (pp.9, 19–20). Status: one benchmark, described, not tabled. The workload, the baseline and the variance are not given.

F10. Worlds provide simulated time and undo at any scale. A world can be sprouted, can hold changes that do not reach its parent, and can commit them (pp.20–21).
Reasoning: this is an extension of the 2010 claim, with the commit semantics and an example of two sibling worlds that see different totals while sharing a taxi-fare cell (pp.20–21). Status: demonstrated with a spreadsheet example. The efficiency of the implementation is not reported in this report.

F11. A compact TCP/IP can be written as a non-deterministic parser with balancing heuristics, in about 160 lines, and that version was robust enough to run a website (p.21).
Reasoning: TCP/IP takes a stream, pattern-matches it, backs up on errors and produces a transformed output, which is what PEG parsers with backup do. Status: the 160-line figure is reported. "Robust enough" is an anecdote. No protocol conformance or error test is cited.

F12. Virtually all 2.5D anti-aliased graphics fits in 457 lines of Nile (pp.6, 8–9).
Reasoning: a rendering formula derived from the geometry of a polygon and a pixel gives the anti-aliasing directly; compositing rules and effects are written as Nile rules (p.8). Status: the count is reported and the demos are said to run live. Only a list of features is given to show coverage.

F13. A layout system can be built from 35 rules based on "particles and fields", with each text component following local rules (p.13, Appendix I).
Reasoning: an analogy to particles that feel fields and line up. Status: the count is stated. The active essay that explains it is in Appendix I, which in the PDF text I worked from is images only, so I could not check the rules.

F14. The web and the operating system should be replaced by objects on a virtual Internet, with hardware as caches, and the local OS code should be a tiny kernel for caching and safe access (pp.19–20).
Reasoning: Reed's and Locus's work on distributed naming and migration, and the TCP/IP kernels that scaled without dependencies (p.19). Status: "much of this is future work" (p.19). The Linux figure is an analogy.

F15. Making languages with PEG parsers that match objects, not only strings, is more convenient and general than earlier pattern-directed systems, and OMeta can make itself (p.18).
Reasoning: the same parser can be used for syntax, for pipeline optimizations and for ASTs. Status: stated with the 1960s lineage. The report has a demo: the arithmetic-to-AST translation, live (p.18).

F16. Explanations as active essays help end users learn the system, and a varied set of POLs with tiny code counts is better than one large general language, because "human brains are overwhelmed by size" (p.17).
Reasoning: the second half is a claim about cognition, and the report says in the same paragraph that "there are no substantiations of this at present" (p.17).

F17. The bottom of the stack must be made of the project's own languages, and C should be removed from it, because C is large, does not pay its way at the low level and does not fit the other languages (p.22).
Reasoning: a list of three reasons. Status: a design argument. The report then states the current bottom is C (p.22), so the argument is in progress.

Changes since the 2010 report (where the text shows them)

- Counting policy: 2010 said optimizations are counted "for simplicity" but are not part of the 20,000 meaning (pp.3–4 of the 2010 report). 2011 says it has dropped the distinction and counts "all the code, including the optimizations even at the bottom" (p.3).
- Graphics size: 2010 said "a little more than 300 lines" of Nile for essentially all graphics (2010 p.4). 2011 says 457 lines (pp.6, 8–9), with the core formula rewritten from about 80 lines to 45 (p.8). The total went up while features were added, and the report does not explain the difference beyond the new features listed on p.9.
- Nile syntax: now closer to mathematical notation, with Unicode operators and piecewise definitions (pp.10–11). 2010 had no such syntax.
- Nile runtime: 2010 called the parallel scheme "an experimental trial" (2010 p.19). 2011 reports a multithreaded runtime with a benchmark (p.9).
- Bottom of the stack: 2010 said the next project was moving Nile's back end from C to Nothing (2010 p.23). 2011 says Nile's first target is C, to set a baseline, and that Nothing and Maru are two parallel paths (pp.22, 24).
- Maru: absent from the 2010 report (which has no mention of Maru). Present in 2011, with the self-compile, GC and chain benchmarks on p.23.
- NotSqueak: 2010 said it would be "completely replaced by the end of next year" (2010 p.20). The 2011 report does not mention NotSqueak. The replacement is neither reported nor retracted.
- Protected address space: 2010 said it would be implemented "next year" (2010 p.21). The 2011 report defers the NoOS architecture to "future work" (p.19).
- Worlds: 2010 described the Worlds paper and its semantics (2010 pp.23–24). 2011 adds sprouting, commit and simulated time with a worked example (pp.20–21).
- TCP/IP: 2010 said the external network environment was implemented enough for the project's own needs (2010 p.21). 2011 reports a 160-line version that runs a website (p.21).
- Scripting, cells and the database: 2010 had cells and tile scripting with the UI "for 2011" (2010 pp.15–16). 2011 reports a live cell-based application with SAP data (p.16) and says a comprehensive scripting interface is still unfinished (p.16).
- Tamacola and the Flash VM: listed in 2010 (pp.24). Not mentioned in 2011.
- OMeta: 2010 said it had not needed improvement that year (2010 p.22). 2011 reports memoization added to a parser generator (p.25), a variant single-file syntax with a module system (p.25), and a Squeak compiler generated from the "leg" system (p.25).
- Team: 2010 credited no authors on the cover. 2011 lists eleven names. The Co-PI Daniel Ingalls, named in 2010, is not on the 2011 title page.

## G. Critique

Uninformed or misinformed claims

- The Linux kernel "in about 1000 lines" (p.19) is uncited. My recollection is that the earliest Linux kernel releases were several times larger than that, so the figure needs a source before it is used as a benchmark. Treat it as a rhetorical number.
- "A typical version of TCP/IP done in C is about 20,000 lines" (p.21) is uncited, and the report's own figure for its smaller versions ("several thousand lines of C") is also uncited. The comparison that follows, that a 160-line version is "very small", depends entirely on these numbers.
- The claim that HyperCard should have been the web's model (p.11) is an opinion, presented as a historical fact.
- The claim that a comparison of 2.5D graphics is "at least 100 times smaller than other extant systems" (p.6) names no system and no counting rule. The report itself says the comparison is apples-and-oranges (p.6). It can make the claim only as an intuition.

Illogical or uncheckable claims

- The 20,000-line budget is stated as a target (p.6) and as a status (p.5: "still under our code limit"). No total is reported. A status claim without a number cannot be checked, and the report gives no way to get one.
- The change in counting policy (p.3) is stated without its effect. Earlier counts excluded optimizations; the new policy includes them. The 457-line graphics figure is not said to include or exclude the optimizations described on p.9, so the reader cannot tell which policy it follows.
- The report says the C modules at the bottom are the "current case" (p.22) and that a counted total must include the project's own bottom and IDEs (p.22). It does not say whether the C modules, the C-built Nothing toolchain (p.23) or the libc wrappers for Maru (p.23) are inside the total. This matters because the report also says the code at the bottom is "often ad hoc and messy" (p.3) and that C "is far from being pretty" (p.22).
- "Maru does not have to include or link with any hand-written C at all" (p.23) is accurate only for the compiler's code. The sentence goes on to say Maru uses standard library routines for I/O. A host C library is still a dependency, and the claim "no C" should say "no C written by the project", as the Nothing claim effectively does.
- The claim that Nothing gives identical results to the current Nile system (p.23) names no test, no inputs and no comparison.

Specific count checks

- Smalltalk-like language, "333 lines of code (with blank lines and comments removed)" (p.34). I counted the printed listing (extracted text, with page footers removed). Before the FFT methods (roughly lines 1240–1754 of the extracted text), there are about 374 non-blank lines once the ";;" and quoted-comment lines are also removed. For the whole listing, including FFT, plot and test, there are about 514 non-blank lines with ";;" comments removed. I cannot get 333 under the stated rule. The report does not say which part was counted, whether the FFT and plot are included, or whether the count was taken from a different version. The discrepancy is at least about 40 lines (roughly 11%) even for the smallest reading. The count is not reproducible from the page.
- "A little over 100 lines" for Nile in OMeta (2010 p.4) and 457 lines of Nile (this report) are not comparable without knowing whether one counts the 45-line formula, the whole graphics library or the optimizations.
- Appendix I (Ants) is images in the PDF text I worked from, so the 35-rule count cannot be checked here.

Incomplete

- Maru has no size in this report. The report says Maru has reusable components (PEG generator, AST abstraction, evaluator, code generator) (p.24), and gives no line count for any of them. For a rebuild with a 10k budget, Maru's own size is the number that matters most, and the report omits it.
- "Smaller than previous prototypes" (p.24) for the Nile-in-Maru embedding has no number behind it.
- The "COLA" lineage (p.22) is named without definition, and its citation is to a 2011 talk, not to the earlier work.
- The multicore benchmark (p.9) has no table, no workload description and no baseline. The 40-core result (nearly 30 times) is stated once.
- The Worlds implementation (p.20) is described as a set of worlds-enabled Smalltalk collections, with no size or performance figure.
- Nothing's "identical results" (p.23) and Maru's self-compilation (p.23) are both claims about tests the report does not describe.
- The 2010 promise of replacing NotSqueak (2010 p.20) is not carried forward. The 2011 report does not say whether it was done.

Aspiration versus demonstration

- Demonstrated, in the sense that the reader can see source and output: Appendix II's Smalltalk-like language, its FFT and plot (pp.34–42). This is the only program in either report whose output is printed next to its source. The output's peaks match the two sinusoids in the input (cos at 2 cycles per 64 samples, amplitude 1.0, and sin at 6 cycles, amplitude 0.75, p.41); I did not verify the exact bin columns from the extracted text. The repo's `pepsi` check encodes the same expectation (bins 2 and 6).
- Demonstrated by screenshot only: Nile graphics, Worlds sprouting and commit, the spreadsheet examples and the SAP-connected application (pp.8–10, 16, 20–21).
- Asserted with no demonstration: Maru's self-compilation, its collectors, its IR projections, Nothing's identity with Nile, the chain of meaning being CPU-independent until its last stage (p.18), and the 160-line TCP/IP "robust enough to run a website" (p.21).
- Future work, stated as such: NoOS (p.19), the migrating caches, a more beautiful "scaffolding" (p.3), and the protected address space.
- Human-factors claims, such as the ribbon UI being "great simplicity" (p.13) and the active essay being a good explanation (p.17), are not evaluated.
- The conclusion that "human brains are overwhelmed by size" (p.17) is stated and then flagged by the report itself as unsubstantiated.

## H. What of it?

The report's central claims about the bottom of the stack are the claims the Maru rebuild is trying to make. The useful parts are the benchmarks, the designs and one program with printed output. The weak parts are the counts, which the report does not total.

1. The rebuild has to report a total, and say what it counts. STEPS 2011 says it is now counting everything (p.3) and never gives the sum. The repo's `check/lines` ledger requires a per-change delta, excludes derived files and budgets to 10k (repo CLAUDE.md). That is the stronger practice. Make it say, too, whether the C that bootstraps Maru (`osdefs.c`, the C evaluator until `emit.l` generates it, and the `cc` dependency that `osdefs_bootstrap` requires) is inside the budget. STEPS did not answer that question, and it is the question the report's C-modules sentence (p.22) raises.

2. The three benchmarks on p.23 are the rebuild's acceptance tests, and most are already in the repo. Self-compilation without project-written C: the rebuild has this as the self-hosting target, with `osdefs_bootstrap` requiring only `cc`. Garbage collectors written in the language: `maru_gc` (2.56M cells collected and freed) and `maru_gc_coalesce` already test this. A full DSL chain to the CPU without C: `ir2` and the x86 path test pieces of it. STEPS's standard is worth quoting as the bar, and the rebuild should state its own version of "without C" honestly: a C compiler and a libc are still needed for bootstrap, and the rebuild should say so, as STEPS does for its I/O routines (p.23).

3. The FFT program is a target to match. Appendix II (pp.34–42) is a Smalltalk-like language built as a thin layer over Maru, with an FFT and a plot, and its printed output. The repo's `pepsi` check tests the same expectation (bins 2 and 6) on the same signal. The rebuild should copy the report's habit of printing source and output together, and it should keep the interpreted and compiled paths separate, because the report's claim that the ASTs "could as easily be passed to Maru's compiler" (p.34) is not shown.

4. A reusable component list is not a size. The report lists a PEG generator, an AST abstraction, an evaluator and a code generator with instruction selection and register allocation (p.24), and gives no line counts for any of them. The rebuild should count each component separately and publish those counts. That makes the component claim checkable, and it gives the rebuild a number the report lacks.

5. The table-driven assembler has a precedent. Piumarta's 2010 result (2010 p.25) and the 2011 IR projections (p.23) both argue for a single grammar that drives several stages. The rebuild's `gen-asm-x86.k` and the planned A64 table do the same job for encoders. The report gives no measurement, so the rebuild should measure its own: lines in the spec, lines in the generator, and lines of derived output, which the repo excludes. Compare the sum against a hand-written encoder, and report both.

6. The PEG hazards are not in the report. Maru's `test-peg.l` loops forever because a rule matches empty input (repo CLAUDE.md). The report describes OMeta as "BNF that transforms" and says it can make itself (pp.18, 25), but says nothing about empty matches or left recursion. Any rebuild PEG generator needs an answer to both before it can be trusted to define a layer.

7. The bottom is where the budget goes. The report's own account is that the "optimization tower of Babel" would be avoided by making the DSLs reflexive (p.22), and that the bottom is where the code is most ad hoc and most costly (p.3, p.22). The rebuild should expect the emitter, the register allocator and the optimizations to take a large share of the 10k lines, and should measure that share before adding anything to the stack.

8. The evaluator generated by Maru's own emitter (the rebuild's bootstrap goal) is the compile-time evaluator the report calls the mechanism for hosted languages' introspection (p.24). The report gives no example of an optimizer written this way. The rebuild can be the first to show one, and should do so with a line count.

9. The garbage collector is a second warning. The 2010 Appendix 2 collector caps the object table at 32 objects and recurses without bound (2010 pp.30–31). The 2011 report says the Nothing collector is still C (p.23). Maru's collectors should not reproduce the 2010 limits, and the rebuild should keep the `maru_gc` test as the stronger check.

10. Lineage. The report names COLA but does not define it (p.22). The repo already has a note on Piumarta's 2005 COLA white paper (`notes/sources/piumarta-2005-colas-white-paper.md`), which should supply the definition. I have not read it for this note. Read it before using "COLA" in the rebuild's own documents.

## Permanent notes extracted from this source

- [[a-self-describing-system-must-count-its-own-bottom]]: count the substrate, not just what is added on top
- [[a-line-count-needs-a-stated-boundary]]: size claims need their counting boundary written down
- [[steps-budgeted-20k-lines-of-meaning-code]]: the STEPS figure is 20,000, not 10,000
