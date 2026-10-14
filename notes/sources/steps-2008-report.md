# STEPS Toward the Reinvention of Programming: 2008 Progress Report (Kay, Piumarta, Rose, Ingalls, Amelang, Kaehler, Ohshima, Samimi, Thacker, Wallace, Warth, Yamamiya, 2008, VPRI TR-2008-004)

Source: https://tinlizzie.org/VPRIPapers/tr2008004_steps08.pdf

Page numbers are the printed folios (p.1 is the title page). Line references (l.) are to the text conversion of the PDF and are given only where a folio alone would be too coarse.

## A. Classification

- Genre: an annual progress report to the NSF (grant 0639876), written as a vision statement followed by an inventory of projects. Its claims come in three grades that the report does not always separate: demonstrated prototypes, "next-pass engineering" of earlier inventions, and aspirations.
- The report's own tag for the first two grades is useful: the 2007 rendering work was "invented" in 2007 and "engineered" in 2008 (p.6, l.205-211). Most of the report sits in the first grade; the reasoning and the numbers are thin.
- Domain: language and system design for personal computing (graphics, networking, UI, development tools, hardware bootstrapping).
- Not a paper in the empirical sense: no method, no benchmark tables, no test suites, no comparison set. The quantitative content is line counts and occasional speed remarks, usually without a stated measurement procedure or a stated baseline.
- Earlier documents: the 2008 text cites "the original proposal" only as the source of the "powerful principles" (p.5, l.192); the number RN-2006002 appears only in the 2009 report's reference list. The 2007 report is not in the sources, so it is compared only through what the 2008 text says about "last year". Those changes are listed in C.

## B. Unity

The unifying claim is that a personal computing system can be written as a family of compact, mathematically stated descriptions ("dynamic math", "active math"), and that a single transformation engine turns those descriptions into efficient running code. The same move is made for rendering (one formula for the contribution of a polygon edge to a pixel, p.2, l.45-58), for TCP/IP (a grammar whose actions emit packets, p.4, l.113-144), and for text layout (constraint-like rules, p.3, l.68-70).

The report states the bet directly: if the abstractions are powerful and parsimonious, the system will not need much code (p.2, l.34-35). A second strand is the separation of meaning from optimization, which the report calls an architectural "powerful principle" and expects to hold across languages and layers (p.5, l.192-196).

The unity is a bet rather than a demonstrated architecture. The transformation framework that would carry it is described as "nearing completion" (p.8, l.308-315). The report does not show it working in this document.

## C. Outline of major parts

Structure of the report:

1. Opening vision and the 20,000-line bet (p.2-3).
2. "Major findings" (p.2-5): universal polygon rendering; TCP/IP as a grammar; contextual control and UNDO ("system dreaming"); an expert-system and "Society of Mind" framing of the system's reasoning; separation of meaning from optimization.
3. "Research and education activities" (p.6-12), one short entry per project: CSL, Worlds, JOHN, XOOS, Bottle, IS, Lively Kernel (with Light and Lively), Lesserphic, Leastphic, algorithmics toolbox, Source IDE, OMeta/JS, TileScript, Chalkboard, DynaBook Jr, BoldlyCode, running parsers backwards, FPGA hardware.

Concrete artifacts named, with the line count as stated and what the count covers:

- Gezira rendering: a conventional-code baseline of "about 500 lines" for the rendering formula, expected to fall to "a few tens" (p.3, l.65-67).
- Cairo: the open-source renderer examined first, described as a PostScript variant for screen and print and "quite large" (p.2, l.40-44).
- Morphic: the graphics architecture inside the Lively Kernel (p.8, l.321).
- Lively wiki (WebDAV to SVN auto-commit) and page-local changeSet facility (p.8, l.328-333).
- Fabrik-style hook-together visual programming and EToys-style tile scripting, both as Lively projects (p.8, l.334-340).
- Java FX scene-graph port of the Lively Kernel (p.9, l.357-361).
- OMeta/JS Workspace: a wiki-style site where users create and share language experiments (p.11, l.437-439).
- NetworkPseudoInterface "tunnel" object used to run the TCP grammar over /dev/tun0 (p.4, l.134). The baseline is not identified (which renderer, which feature set). Invented 2007, engineered 2008 (p.6, l.207-208). No line count for the 2008 Gezira implementation.
- TCP/IP as a grammar: a budget of "a hundred or so" lines (p.3, l.89). The listing on p.4 covers only receive-side rules for SYN, data, ACK and reset, plus the outgoing acknowledgement numbers.
- CSL (Communications Strategy Language): "only 160 lines of metalanguage and language total" for a working TCP/IP serving a simple website (p.6, l.218-221). Projected to "80 lines" in the next attempt (p.6, l.222-223), not yet done.
- Worlds: a prototype as a JavaScript extension. No line count (p.6-7).
- JOHN: an object-oriented planning and reasoning system with a natural-language-like syntax. No line count (p.7).
- XOOS: boots on OpenFirmware; a framebuffer driver for the AMD Geode LX BitBlt operation in "20 lines of understandable code" (p.7-8, l.287-294). The count is the driver only; OpenFirmware and the surrounding system are not counted.
- IS: the transformation framework, parse, transform, and generate in one abstraction. No line count (p.8).
- Lively Kernel: "about 10,000 lines" of JavaScript for classes, Morphic graphics, windows, widgets (p.8, l.317-325). These are host (JavaScript) lines, not STEPS lines.
- Light and Lively: a replacement for browser JavaScript "in less than 200 lines of code in the OMeta and IS systems" (p.9, l.353-355). Scope of the replacement is not stated.
- Lesserphic: a GUI framework with "behaviors" as first-class objects. No line count (p.9-10).
- Leastphic: a single "Box" primitive; "less than 1000 lines of STEPS code" for a UI framework able to author Figure 1 (p.10, l.394-400).
- Algorithmics toolbox: dynamic planning used for paragraph layout, inspired by Knuth (p.10, l.403-411).
- Source IDE: a cross-development environment hosted in Squeak, first release early 2008 (p.10-11, l.414-416).
- OMeta/JS, TileScript, Chalkboard, DynaBook Jr, BoldlyCode: browser and end-user systems. No line counts (p.11-12).
- Running parsers backwards: a PEG-based parser whose rules can be reversed to print ASTs back as source. No count (p.12, l.488-497).
- FPGA "tiny computer" and the BEE3 platform by Chuck Thacker (p.12, l.499-519).

People named in the text: Thacker (FPGA and BEE3 work, p.12); Mark Lentczner (BoldlyCode derived from his Glyphic Codeworks, p.12, l.473-474); Knuth (paragraph-breaking method, p.10, l.408-409); Minsky (the "Society of Mind" phrase, p.5, l.177); McCarthy (the name JOHN, p.7, l.257); Wing (the "automation of abstractions" epigraph, p.2, l.28). The report does not attribute individual artifacts to individual authors other than these, so responsibility for specific components is not recoverable from this text.

Changes since the 2007 work, as the 2008 text itself reports them (the 2007 report is not in the sources, so these are the report's own accounts):

- Lively Kernel: "as of last year" it was an architecture project (p.8, l.317-320). In 2008 it has three explorations, development environments, end-user authoring and stand-alone kernels (p.8, l.326-327), a client-side wiki that auto-commits to SVN through WebDAV (p.8, l.328-333), and Fabrik-style and Etoys-style projects (p.8, l.334-340).
- Light and Lively: last year's replacement of browser JavaScript in under 200 lines of OMeta and IS (p.9, l.353-355); this year the SVG rendering is replaced by Gezira, and the Lively port to JavaFX took under two weeks (p.9, l.355-361).
- Lesserphic (reported last year) gains a sibling, Leastphic, reduced to one "Box" primitive and under 1000 lines (p.10, l.394-400).
- FPGA: last year's "tiny computer" becomes the BEE3 platform built this year (p.12, l.499-517).
- Source IDE: begun at the end of 2007, first usable release early 2008 (p.10, l.414-416).
- Gezira: invented and tested in 2007, engineered in 2008 (p.6, l.207-208).
- The 2008 text says the work is "over the last two years" (p.4, l.146-147), so the 2006-2007 period is the basis of its claims.

## D. Author's central problems

- Scale: how to cover "personal computing" from end user to bare metal in about 20,000 lines, which the report itself calls "no more than 20,000 lines of code" (p.2-3, l.87-89).
- Compactness without loss of speed: the "active math" must compile to code fast enough for real use (p.3-4, l.71-75; p.6, l.218-219).
- Many small languages: problem-oriented languages must not produce a "Tower of Babel" of mutually unintelligible notations; the report wants a shared "family of expression" (p.6, l.224-233).
- Undo and retraction at every granularity, both for users and for programmers' heuristic search and backtracking (p.4-5, l.155-173).
- Separating what a program is for from how it is optimized (p.5, l.192-196; p.7, l.272-276).
- Dependency maintenance: whether a deduction's support should be withdrawn when its evidence goes away, extended to all code dependencies (p.5, l.184-187).
- Hardware: how to make software and hardware co-designed, and whether a bare-metal bootstrap is reachable (p.7-8, p.12).
- Tooling: whether a system can be developed inside itself, which the report says is the route to "a snowballing effect" in usability (p.10-11, l.429-431).

## E. Key terms

- Dynamic math / active math: compact mathematical or grammatical statements that the system can transform into running code. The report's term for its method.
- Meta-representation-and-transformation engine (IS): the single framework meant to parse, transform structures, and generate output (p.2, l.59-60; p.8).
- Chain of meaning: a sequence of translators from problem-oriented notation down to executable form. Introduced in the 2009 text; the 2008 text uses the idea without the name.
- Gezira: the polygon rendering approach (p.2-3, p.6).
- CSL: a grammar-based language for communications protocols (p.6).
- Worlds: a scope for side effects that can be sprouted, discarded, or committed (p.6-7, l.236-242).
- Set of support: a truth-maintenance idea from earlier expert systems; the report proposes extending it to code dependencies (p.5, l.184-187).
- Ecology of abilities / meanings: the report's rephrasing of "Society of Mind" (p.5, l.176-178).
- Lively Kernel: a development and end-user environment built inside the browser's JavaScript, with an emulated reflective runtime (p.8-9).
- Lesserphic / Leastphic: a GUI framework built around multiple perspectives on a graphic object, and a stripped-down version built on one "Box" primitive (p.9-10).
- OMeta: a pattern-directed meta-programming language. The report uses OMeta/JS for browser experiments (p.9, p.11).
- Running a parser backwards: using a parser's rules to print an AST as source (p.12).

## F. Main propositions and arguments

Each entry gives the claim, the reasoning the report offers, and what it establishes.

1. Parsimonious abstractions imply small systems. Reasoning: a general claim from Wing's view of computing as the automation of abstractions (p.2, l.28-35). Status: a stated bet, not an argument from data.
2. Rendering can be stated as one mathematical relation and compiled to efficient code. Reasoning: the edge-to-pixel contribution formula (p.2, l.53-58); the claim that a conventional version needs about 500 lines (p.3, l.65) and that the math-as-program version should need "a few tens" (p.2-3, l.66-67). Status: the formula is shown; the 500-line baseline and the few-tens projection are not measured.
3. The resulting rendering is faster and better than expected. Reasoning: the authors' surprise (p.3, l.71-74); anti-aliasing "without the artifacts" of sub-sampling (p.3, l.80-84). Status: no speed numbers and no comparison images beyond a figure the report says is hard to reproduce (p.3, l.73-75).
4. TCP/IP can be written in a small grammar-based language. Reasoning: TCP is a set of heuristics combined with parsing and assembly, and such a problem is best served by a language aimed at it (p.6, l.214-219). Status: a working TCP/IP serving a web page is claimed at 160 lines (p.6, l.220-221). Demonstrated at the level of "it runs"; no interoperability or throughput results.
5. The TCP stream and retransmission logic are "just a few lines" each on top of IP (p.3-4, l.113-115). Reasoning: asserted by analogy with the layered separation of IP and TCP (p.3-4, l.103-112). Status: not shown in the listing.
6. Header formats can be read from the ASCII-art diagrams in the RFCs and turned into packet code (p.3-4, l.115-116). Status: asserted as a mechanism; no example beyond the one grammar.
7. Problem-oriented languages should converge on a shared style to avoid a Tower of Babel. Reasoning: a shared outlook among the authors and a pattern-directed, search-and-constraint style used in recent experiments (p.6, l.224-233). Status: a design principle; the claim that "quite a bit of this has happened already" is not shown.
8. Undo at every level of granularity improves learning, error recovery and search. Reasoning: "scattered" evidence that retraction improves code structure (p.4, l.155-158); analogy to backtracking and possible-worlds reasoning (p.4-5, l.168-170). Status: the evidence is not cited; the argument is a plausible design case.
9. Worlds provide sandboxing, undo, tentative execution, better exception handling, and possibly a module system. Reasoning: side effects are captured in a child world and committed to the parent on demand (p.6, l.236-242). Status: a JavaScript prototype with "early experiments" (p.6, l.243-245). The fine-grain efficiency claim (p.7, l.254-255) is not supported by any figure.
10. Meaning can be separated from optimization, with a goal-driven agent that checks completion against the meaning part. Reasoning: the JOHN design (p.7, l.272-276). Status: shown on toy problems (sorting, searching, games, question answering; p.7, l.283-285). It is not shown that this shrinks system code.
11. A system can be expressed as an "ecology of abilities" with dynamic discovery of new abilities over the network. Reasoning: discovery-system analogy (p.5, l.188-191). Status: aspiration.
12. The system's dependencies should be maintained like a truth-maintenance network. Reasoning: expert-system precedent (p.5, l.184-187). Status: aspiration.
13. A complete environment can be built on a weaker substrate in about 10,000 lines. Reasoning: the Lively Kernel as an existence proof (p.8, l.317-325). Status: demonstrated, but the count is of JavaScript on a browser, not of a self-contained system.
14. A browser's JavaScript could be replaced by a version under 200 lines in OMeta and IS (p.9, l.353-355). Status: stated; scope undefined.
15. A port of the Lively Kernel to a native host took under two weeks because the host's scene graph resembles SVG (p.9, l.357-361). Reasoning: the component boundary is portable. Status: one anecdote.
16. A UI framework can be reduced to one "Box" primitive under 1000 lines (p.10, l.394-400). Status: stated; the count is of STEPS code, and the report says the final UI framework will come from the "tension" between the two framework projects (p.10, l.399-400).
17. Parsers can be run in reverse, so translation needs two parsers instead of two parsers and two printers (p.12, l.488-497). Reasoning: rules are restricted so templates can be extracted from them. Status: a proposal; no example in the report.
18. Booting on bare hardware is an experiment (XOOS). A framebuffer driver for a BitBlt operation fits in 20 lines (p.7-8, l.287-294). Reasoning: OpenFirmware loads the system, and the driver replaces an existing one for one operation. Status: a driver count; the boot runs through firmware, and what the booted system contains is not reported.
19. Hardware can be shaped by programs (DPU and microcode lineage), and FPGAs are now the platform for this (p.12, l.499-519). Status: a stated research direction and a platform choice.

## G. Critique

Charges by claim. "Uninformed" means the claim ignores relevant knowledge; "misinformed" means it asserts something the report itself or the field contradicts; "illogical" means the inference does not follow; "incomplete" means the claim is true only in part.

- Incomplete (line counts, the 500-to-"few tens" claim, p.2-3). The 500-line baseline is not identified. The "few tens" projection is not met at the level the 2009 report measures: it counts 81 lines of Nile for the master rendering operations (2009 p.5), and 318 for the rendering and compositing set. Neither count says what it covers.
- Illogical (the 20,000-line bet, p.2-3). The total is a stated ceiling, not a sum. The report gives component counts (TCP about 100 budget, 160 achieved, 10,000 for Lively, under 1000 for Leastphic, under 200 for the JavaScript replacement, 20 for the framebuffer driver) but never adds them or says which components are in the 20,000. The components are counted in different units: STEPS lines, JavaScript lines, and driver-only lines.
- Misinformed or inconsistent (TCP budget, p.3 vs p.6). The report budgets "a hundred or so" lines for TCP/IP (p.3, l.89) and then reports "only 160 lines" for a working TCP/IP plus web service (p.6, l.220). The 160 is the metalanguage and language total; the report does not say whether the 100-line budget was for the protocol alone or the protocol plus the website. If the 160 is the protocol alone, the report exceeds its own budget by about 60 percent and does not say so; if it includes the website, the protocol's own cost is unreported.
- Aspiration presented as result. "A few lines" for retransmission (p.3-4); "could collapse by half again to 80 lines" (p.6); "should be able to" use the system for dreaming and set-of-support maintenance (p.4-5). None is demonstrated in the report.
- Uninformed (the speed claims, p.2-3). "Much faster than we had anticipated" is reported with no timing, no hardware, no baseline. The reader cannot tell whether the claim concerns the whole pipeline or only the rendering kernel.
- Incomplete (TCP/IP, p.4). The listing shows receive-side reply rules. It does not show congestion control, timers, fragmentation, or the sender side. The "TCP in 160 lines" claim cannot be checked against the listing.
- Incomplete (XOOS, p.7-8). "A simple hardware-accelerated framebuffer driver ... in 20 lines" counts one driver. The system is loaded by OpenFirmware (p.7, l.288-289), so every boot in this experiment runs through firmware. The report does not say what the booted system is or how large it is; only the driver is counted.
- Uninformed (the expert-system framing, p.4-5). The report cites "much (albeit scattered) evidence" for effects of retraction on code structure and does not cite any of it. The "set of support" proposal is presented without the known costs of truth maintenance.
- Incomplete (the claim about meaning vs optimization, p.5). The argument is supported by toy programs (p.7). The report gives no case where separating meaning from optimization made a real system smaller.
- Terminology drift. "Active math", "dynamic math", "chain of meaning", and "meta-representation" are used for overlapping things. Without a definition the reader cannot tell which claim is about which mechanism.

What is demonstrated, as opposed to proposed: the rendering formula (shown); a TCP-style grammar listing (shown, partially); the Lively Kernel environment (demonstrated in use, though on a host substrate); the Lively port (demonstrated, anecdotally); the Source IDE (released early 2008, p.10); the prototype Worlds extension (p.6). Most other items are described as prototypes or directions.

## H. What of it?

The rebuild has a hard budget of 10,000 lines, a stated preference for DSLs and grammars over hand-written code, a goal of generating the evaluator from Maru's own emitter, and table-driven x86 and ARM64 assemblers. This report bears on each, with limits.

- Budget. STEPS's ceiling is twice the Maru budget, and its component counts exclude hosts (JavaScript, Squeak, OpenFirmware). Maru's own rule (the `lines` check in the repo's CLAUDE.md) counts every checked-in source line and excludes only derived files. Any comparison with STEPS must therefore count the host-independent parts of the Maru chain, including the evaluator and the emitter, not only the front-end grammar. A "160-line TCP" claim is not evidence for a Maru budget unless the same counting rule is applied.
- Grammars. The report's strongest practical case is that a protocol or layout written as rules is short. That supports Maru's PEG and grammar work (`peg.l`, `pegen`, `earley` checks). The report also says the counts are "approaching the natural size" once the notation is good enough (2009 p.4), so the expected saving is a constant factor, not an order of magnitude.
- Parser reversal (p.12). Maru's table-driven assembler and disassembler (commit 3df21b8) is a narrower version of the same idea: one table, two directions. The report gives no mechanism, so the design would be the rebuild's own. The report's caution that templates must be extracted from a restricted rule form is the constraint to design for.
- Generated evaluator and bootstrap. The 2008 report says nothing about a bootstrap sequence. The 2009 report describes a self-implementing chain for parsers (2009 p.4) and a lingua franca s-expression intermediate form (2009 p.7). Both are the shape the rebuild wants. The sources do not show the bootstrap, so it cannot be copied from them.
- Targets. STEPS's machine-code example targets 32-bit x86 through textual assembly (2009 p.9), which is the same kind of output as Maru's `gen-asm-x86.k`. The repo notes that 32-bit x86 code does not run on this arm64 host, so the example is a design pattern, not a platform to copy.
- Undo and Worlds (p.6-7). If the rebuild ever needs speculative evaluation during bootstrap, a Worlds-style scope is a candidate. For now it is an extra mechanism with no stated use, and it should wait until a concrete need appears.
- What the sources do not contain. The COLA, Pepsi, Coke and Maru lineage, and the words "Maru" and "circular", do not appear in either report. Those must come from other sources. The reports are useful for the scope and the claims, not for the bootstrap history.
- Practical use: treat any "N lines" claim in these reports as needing its counting rule before it is used as a budget figure.

## Permanent notes extracted from this source

- [[steps-budgeted-20k-lines-of-meaning-code]]: the STEPS figure is 20,000, not 10,000
