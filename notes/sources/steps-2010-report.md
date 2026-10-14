# STEPS Toward Expressive Programming Systems: 2010 Progress Report (Viewpoints Research Institute, 2010, VPRI TR-2010-004)

Source: https://tinlizzie.org/VPRIPapers/tr2010004_steps10.pdf

Authorship: the cover names no individual authors. The outreach section (p.26) names Alan Kay, Kim Rose, Co-PI Daniel Ingalls, Takashi Yamamiya, Yoshiki Ohshima and Ian Piumarta. The three papers summarized in the report carry their own authors (pp.23–25). Page numbers below are the printed page numbers of the report.

## A. Classification

An annual progress report to the NSF (Year 4 of award 0639876), not peer reviewed. It mixes four kinds of text: a plain-language summary for lay readers (p.2); a design essay that argues for a method, a "science of the artificial" paired with an "art of design" (pp.3–6); a status report on each subsystem, with screenshots and short code; and three workshop papers summarized in a page or two each (pp.23–25), followed by two appendices of code (pp.28–31).

In Adler and Van Doren's terms it is mostly informative: it tells the reader what exists and how far it reaches. The argument for the method is thin and asserted rather than tested. Most of the evidence is in figures and code that a reader of the PDF can see but cannot run, so the report cannot be inspected in the sense the authors intend.

## B. Unity

One question holds the report together. Can the working parts of personal computing be written in about 20,000 lines "from the end user down to the metal" (pp.3–4)? The method is to pick one area at a time, find the mathematics that governs it, invent a small problem-oriented language that reads like that mathematics, and implement the area in that language (p.6). The pieces are then stitched into one working system, Frank (pp.5–6). The bottom of the stack is a minimal target, Nothing, into which the higher languages are translated (pp.22–23).

The organizing belief is stated on p.2: as size grows, architecture matters more than materials, so careful reorganization of familiar parts should yield orders of magnitude in size. The 2010 report presents itself as the midpoint of this program. Its aim is to show that the parts fit together, not yet to show that the total is small.

## C. Outline of major parts

1. Public summary (p.2). Aims only, no technical claims.
2. Project introduction: the science and art framing, the 20,000-line measure, and results from the first three years (pp.3–4).
3. "STEPS in 2010": the Frank system, its large-scale architecture (virtual network of objects over the Internet) and its design approach (pp.5–6).
4. Parts of Frank (pp.7–23): DBjr, the universal document and user interface (pp.7–16); LWorld (p.17); Gezira and Nile graphics (pp.18–20); NotSqueak (p.20); networking and the argument against a conventional OS and browser (pp.20–22); OMeta (p.22); Nothing (pp.22–23).
5. 2010 experiments and papers (pp.23–26): Worlds (pp.23–24), Tamacola (p.24), Piumarta's PEG-based compiler transformer (p.25).
6. Training, outreach, references (pp.26–27).
7. Appendix 1: Nothing's syntax as an OMeta grammar (pp.28–29). Appendix 2: a copying garbage collector written in Nothing (pp.30–31).

Concrete artifacts named in the report:

Systems, environments and subsystems
- Frank: the integrated system, called a "cute Frankenstein's monster" (pp.5–6).
- DBjr: universal media and user-interface system, with seven document styles (pp.7–16).
- LWorld: tools framework with Announcements-based event notification and an LBox application layer (pp.17–18).
- Gezira: graphics engine, now used for all Frank rendering (pp.18–19).
- Nile: "runnable math" stream language; earlier described as a parallel stream-based APL (pp.7, 18–20).
- NotSqueak: a subset of Squeak Smalltalk used as scaffolding, to be replaced "by the end of next year" (p.20).
- OMeta: PEG-based pattern-matching and transformation language, described as "a BNF that transforms" (pp.7, 22–23).
- Nothing: a symbolic low-level target language; the name was first "Ex Nihilo" (p.22 footnote). Described as BCPL-like in syntax and Wirth's Euler-like in semantics (p.22).
- Worlds: a language construct that reifies program state and scopes side effects (pp.23–24).
- Tamacola: a Scheme-like metalanguage compiled to ActionScript bytecode on the Tamarin VM (p.24).
- Piumarta's PEG transformer experiment: one parser driving front end, middle end and back end (p.25).
- Networking: TCP/IP and an "alternate web" (pp.20–21).
- Historical systems cited for design lineage: Xerox PARC UI conventions, the Mac menu bar, MS Office 2007 menu panels, Etoys, Scratch, Alice, HyperCard, the Xerox Analyst spreadsheet, Playground, Agar (Travers), LOCUS, Toylog (from the 2007 report).

Line counts stated in the report (what each counts is noted where the text says)
- 20,000 lines: the budget for the "runnable meaning" of personal computing, end user to metal (p.3). Optimizations are counted in the running totals "for simplicity" but are said to be "technically" outside the 20,000 (pp.3–4).
- Today's systems: "hundreds of millions" of lines; the arithmetic example "100 million lines at 50 lines per page is 5000 books" (p.2) is correct.
- Graphics: "essentially all of standard personal computing graphics" in "a little more than 300 lines" of Nile (p.4).
- Nile's own translator: "a little over 100 lines" of OMeta, plus "another 700 lines" to make it run in real time, also in OMeta (p.4).
- OMeta: "about 100 lines" to make OMeta in itself and optimize it (p.4).
- Nothing's syntax-to-AST grammar: "a very simple 150 lines of OMeta" (p.22; Appendix 1, pp.28–29).
- Nothing copying garbage collector: "less than 100 lines" (p.22; Appendix 2, pp.30–31).
- Target ratios: factors of 100, 1000 and beyond (p.3); "roughly 1/1000th" of the bricks in the pyramid analogy (p.2).

People named as responsible
- Alan Kay: project lead and speaker throughout (pp.26).
- Daniel Ingalls: Co-PI, moved from Sun to SAP Labs in this program year (p.26).
- Kim Rose: co-chair of the S3 workshop (p.26).
- Dan Amelang: graduate student at UCSD, PhD work on Gezira/Nile (p.26).
- Ian Piumarta: OMeta, Nothing and the PEG transformer paper (pp.22, 25–26).
- Alex Warth, Yoshiki Ohshima, Ted Kaehler, Alan Kay: Worlds paper (p.23).
- Takashi Yamamiya and Yoshiki Ohshima: Tamacola paper (p.24).
- Mike Travers: Agar, the tile-scripted creature system (p.15).

## D. Author's central problems

1. Size. Personal computing now takes hundreds of millions of lines. Can the same phenomena be produced at a thousandth of the code, and does that make the system more understandable (pp.2–3)?
2. Measurement. How do you judge a claim like "1000 times smaller" when no two systems do the same things? The authors concede the comparison is "apples and oranges" and fall back on a fixed budget (p.3).
3. Integration. Individually small parts must be made to cooperate. The 2010 answer is to "stitch" them into Frank and see what breaks (pp.5–6).
4. Document diversity. Email, web pages, spreadsheets, presentations and desktop-publishing files are different "modes" with separate interfaces. The answer is one document kind and one set of conventions (pp.7–10).
5. Untrusted content. The web should be treated as code from elsewhere that must run safely, which makes it an operating-system problem (pp.14, 21).
6. The bottom. Machine code must come from a small, traceable target, so that a student can follow the chain of meaning to the hardware (p.22).
7. Loose coupling. Objects should interact through messages and publish-subscribe rather than direct references (pp.6, 20).
8. Undo and speculation. Side effects should be scoped so that alternatives can be tried and dropped (pp.23–24).
9. Performance. Optimizations should not pollute the meaning code, and the meaning code should run on a laptop, not only a supercomputer (pp.3–4, 19).

## E. Key terms

- Runnable meaning: code that, when run, produces the system's behavior. Optimizations are excluded in principle (p.3).
- Runnable math: a language designed so that the mathematics of an area can be written almost directly and still run (pp.4, 6).
- Universal document: one kind of document for email, web pages, slides, cells and books (p.7). "Mood" rather than "mode": authoring is always on, with fences in place of modes (p.10).
- Backgrounds: master pages extended to every object, used to build both content and UI (p.8).
- Cells: a spreadsheet cell with a value rule and a view rule, so that a value can have more than one view and a cell can hold a model, a view or a query (pp.14–15).
- Worlds: first-class state scopes that can be undone, branched or kept (pp.23–24).
- Chain of meaning: the sequence of translations from a high-level language to hardware (pp.22–23).
- Frank: the 2010 stitched system (pp.5–6).
- "Architecture dominates materials" and "design wins": the thesis (pp.2, 21).
- Science of the artificial; art of design: the two halves of the method (pp.3, 5–6), with the first attributed to Simon (p.3).
- Real objects, virtual ARPAnet, hardware as caches: the networked object model (pp.6, 21).

## F. Main propositions and arguments

F1. Personal computing can be re-created in under a thousandth of the code of current systems (p.2).
Reasoning: an analogy to the arch versus the pyramid (structure and design, not materials, determine size), plus results from earlier years: graphics in about 300 lines, OMeta self-hosting in about 100 (p.4). Status: a goal and an extrapolation. No total for the 2010 system is given.

F2. A fixed 20,000-line budget, counting all "runnable meaning" from end user to metal, is a useful measure of success (pp.3–4).
Reasoning: a budget forces design choices that a size comparison does not. The authors also admit the comparison problem and say they will look at "understandability" (p.3). Status: the budget is a target. The report states no measured total.

F3. Problem-oriented languages, each built from the mathematics of its domain, are the lever that makes the code small (pp.4, 6, 18).
Reasoning: when a language's notation matches the domain's mathematics, programs in it are short. The cost is that one must keep inventing and maintaining languages and making them work together (p.6). Status: supported for graphics by the Nile example; not shown for other domains.

F4. Gezira and Nile produce all of standard 2.5D graphics and sound in about 300 lines (p.4), now integrated into Frank (p.18).
Reasoning: the graphics pipeline is written as a stream of kernels; the report lists new features (joins and caps, bicubic scaling, mipmapping, Gaussian shadows, a new transparency fill) as evidence of coverage (pp.18–19). Status: coverage is shown in screenshots. No size or speed comparison is given for the features listed.

F5. OMeta can describe and implement itself, so the language tooling is small (pp.4, 22).
Reasoning: a PEG-based transformer defined in the same notation it implements. Status: stated counts (about 100 lines self-hosted). No listing is given for the OMeta grammar itself.

F6. Nothing is a deliberately simple target whose semantics are simple enough to trace, and that makes bootstrapping upward "easy to show" (p.22).
Reasoning: an analogy to building arches out of bricks, plus pedagogy. Status: the grammar and the garbage collector are shown as code (Appendices 1 and 2). The text does not show that either runs, or what it produces. The claim that a student could write a new back end is not tested.

F7. OMeta can be bootstrapped into Nothing, and that bootstrapping is a useful test of the design (pp.22–23).
Reasoning: OMeta needs a stack, so running it on Nothing tests the virtual machine. The argument echoes Schorre's Meta II (p.23). Status: stated, not measured.

F8. A web browser should be an operating system for safely running other people's objects, not an application for simple documents (pp.14, 21).
Reasoning: the browser's job is to take unknown code, run it safely and composite its output, which is an operating-system job. Status: argued by appeal to earlier designs (LOCUS, p.21) and to "Operating System 101" (p.14). The mechanism is deferred to the next year (p.21).

F9. Operating systems should reduce to safe allocation of resources to cached objects; drivers and graphics can be supplied by the objects themselves (p.21).
Reasoning: device drivers and graphics are numerous and differ by device, so the OS cannot supply them all. Status: a design position. Nothing in the 2010 system implements it (p.21 says the protected address space comes "next year").

F10. Worlds reify program state, so side effects can be scoped, nested, tried and committed (pp.23–24).
Reasoning: try/catch unwinds the stack but does not undo effects, and manual command objects are error-prone. Worlds are first-class, which makes them more general than transactions. Status: the paper reports a Squeak-based prototype and a JavaScript extension with an efficient implementation strategy and two case studies. The summary gives no numbers.

F11. One parser driven by one uniform grammar can implement front end, middle end and back end of a compiler (p.25).
Reasoning: each stage is a transformation of trees or lists, and a PEG with semantic actions can express each one. Status: described, with a diagram. No code, no size, no output appears in the report.

F12. A spreadsheet cell that unifies value and display generalizes MVC, and a spreadsheet can be extended with arbitrary value rules (pp.14–15).
Reasoning: the Xerox Analyst allowed arbitrary models and views in cells, and loose coupling can be added by search or publish-subscribe. Status: the basic mechanism is shown (a value rule that changes cell color, a thumbs-up image). Scale is not shown.

F13. Tile-based scripting, borrowed from Etoys and Scratch, is good for beginners but breaks down for longer scripts (pp.15–16).
Reasoning: visual cues help novices but get in the way of gist-reading. Status: the report says a full scripting interface is for 2011. The argument is from experience with other systems.

F14. Universal undo and "no modes" reduce the burden on users (pp.9–10).
Reasoning: fewer categories, one set of save-and-send and find-and-fetch conventions. Status: a design goal, supported by Etoys experience and not by a study.

## G. Critique

Uninformed or misinformed claims

- The web argument (pp.14, 21) rests on a contrast with the browser as it was in 2010. It does not account for sandboxing work already underway, such as Native Client, which the 2011 report later uses. The claim that browsers "could have been almost nothing" is a rhetorical position, not a finding.
- Email is described as "essentially the same as a web search" for the user's name (p.13). The analogy leaves out delivery, transport, spam and identity, which is where email's difficulty lies. The report later says the networking code handles "our own filing, searching, email, and web needs" (p.21), but it does not say how much protocol work that involved.
- The claim that Nothing lets students "trace the chain of meaning down to computer hardware" (p.22) is weaker than stated. The chain passes through OMeta back ends and a host language, and the report does not say how big those are.

Illogical or uncheckable claims

- The 20,000-line measure mixes two categories. Optimizations are counted "for simplicity" yet said to be outside the measure (pp.3–4). The result is a number that cannot be checked against either the meaning or the total.
- The comparison ratios of 100 to 1000 (pp.2–3) are set against systems that have not been counted on the same basis, which the report itself calls "apples and oranges" (p.3). A factor-of-100 claim needs a named baseline and a named counting rule. Neither is given.
- The report says it will judge "understandability" (p.3) but gives no test of it: no reader study, no before-and-after, no comprehension task.

Incomplete

- No total line count is reported for 2010. The report gives the budget (20,000), a few component counts, and nothing that adds them up. So the report cannot say whether the program is on track.
- Appendix 1 says the Nothing grammar is "150 lines" of OMeta (p.22). The printed listing (pp.28–29) has about 118 non-blank lines. The counting rule is not stated, and the difference may be blank lines or line wraps. Either way, the figure cannot be reproduced from the page.
- Appendix 2's "copying garbage collector in less than 100 lines" (p.22) is about 84 non-blank code lines (pp.30–31). That figure is accurate for the printed code. But the code has limits it does not mention. The object table has `otSize = 32 * OTE.wordSize`, commented as the "max. number of objects" (p.30), which is a cap of 32 objects. The copy routine `moveToOtherHeap` recurses without a depth bound (p.31). Neither limit is discussed. The code is a demonstration, not a general collector, and the report should say so.
- Nothing's GC is presented in Appendix 2 as the example of bootstrapping, but the 2011 report says the GC is still written in C and "will soon be rendered in Nothing" (2011 p.23). The 2010 text does not say whether the Appendix 2 code has run.
- Piumarta's PEG transformer (p.25) gives a diagram but no grammar, no output and no size. It is the closest thing in the report to a test of the single-grammar idea, and it is not evidence yet.

Aspiration versus demonstration

- Demonstrated, as far as the report shows: DBjr document forms and scripting tiles (screenshots, pp.7–16); Nile graphics features (screenshots, pp.18–19); the OMeta-based Nile and OMeta translators (figures, p.4); the Nothing grammar and GC (code only, pp.28–31).
- Aspirational: the 1000-times claim (p.2); "web content as virtual machines" (p.21); the protected address space (p.21, deferred); end users who learn deeper programming without noticing (p.16); a comprehensive scripting UI and contextual help (pp.10, 15), which the report admits it does not yet have.
- Human-factors claims (pp.5–10, 16), such as the UI being "much easier, comprehensive, learnable and useful" than its roots (p.6), have no evaluation at all.

## H. What of it?

For the Maru rebuild, the central fact is that this report never mentions Maru. The rebuild's problems appear here as goals, and the report's numbers are the only published benchmarks for them.

1. Count precisely, and say what is counted. STEPS 2010 counted optimizations "for simplicity" but excluded them in principle (p.3–4), and it reported no total. The rebuild's `check/lines` ledger, which requires a per-change delta and excludes derived files (repo CLAUDE.md), already avoids that trap. Keep it, and report a total at each milestone. Decide explicitly whether the C bootstrap (`osdefs.c`, the C evaluator until `emit.l` generates it) is inside the 10k budget, because STEPS did not answer the equivalent question.

2. Use the report's graphics-style claim as a density test, not as a target. "Essentially all of graphics in 300 lines of Nile" (p.4) is a claim about a domain language. The rebuild can make the same kind of claim for its own DSLs: state the domain, state the language's line count, and show the output. The report's weakness is that it counts nothing else.

3. The grammar-driven assembler has a precedent. Piumarta's single grammar driving three stages (p.25) is the same idea as the rebuild's table-driven x86 and A64 work, in which a grammar generates the encoders. STEPS gives no size, so the rebuild should count the spec, the generator and the derived output separately, and compare the spec-plus-generator against a hand-written encoder. OMeta's "about 100 lines" self-hosting (p.4) and the 150-line Nothing grammar (p.22) are rough benchmarks for the size of a grammar that defines a whole layer.

4. PEG parsers have a hazard the report does not mention. The repo's `test-peg.l` loops forever because a rule matches empty input and the parser never advances (repo CLAUDE.md). OMeta is described as "a BNF that transforms" (p.7) with no discussion of empty matches or left recursion. Any rebuild PEG generator needs a rule for both, and STEPS gives no example to copy.

5. The garbage collector is the clearest warning. The Appendix 2 collector caps the object table at 32 objects and recurses without bound (pp.30–31). Do not carry those limits into Maru's collectors. Maru's `maru_gc` check, which allocates 2.56M cells and frees everything, is a stronger test than anything in this report.

6. The bottom is where the budget goes. The report chose Nothing as a "pedagogical" low layer (p.22) and found itself writing a garbage collector in C anyway (2011 p.23). For the rebuild, the IR layer under the evaluator should be justified by line counts, not by teaching value, and its cost should be measured before adding another layer.

7. DSLs cover domains, not bottoms. STEPS's small graphics code worked because the domain was narrow. The bottom stayed hand-written, and it is counted (p.22). In the rebuild, the emitter that generates the evaluator will be the bottom. Expect it, and the optimizations for it, to take a large share of the 10k lines.

8. The "architecture dominates materials" claim is untested here. A rebuild can test it on its own terms. The repo's upstream is Maru 2.4 (repo CLAUDE.md), so the rebuild has a real baseline to compare against, which STEPS did not have.

## Permanent notes extracted from this source

- [[steps-budgeted-20k-lines-of-meaning-code]]: the STEPS figure is 20,000, not 10,000
