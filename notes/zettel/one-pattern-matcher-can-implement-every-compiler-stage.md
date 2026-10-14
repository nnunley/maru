---
title: "One pattern matcher over one representation can implement every compiler stage"
source: "../sources/piumarta-2010-peg-based-transformer.md"
created: 2026-10-14
schema_version: 1
links: [back-ends-are-the-line-budget-lever, compiler-size-concentrates-in-code-generation-not-parsing, in-memory-code-generation-needs-instruction-words-built-from-fields]
---

# One pattern matcher over one representation can implement every compiler stage

Compilers normally use a different generator for each stage: a parser generator for text, a tree rewriter for analysis, a bottom-up tree matcher (BURG) for code generation. Piumarta's 2010 experiment used one mechanism for all three. A parsing-expression-grammar (PEG) matcher was extended to match inside nested lists as well as character streams, and given output templates. Text, syntax trees and instruction lists were all represented as lists. The front end, the middle end (tree to stack-machine code) and the back end (stack-machine code to i386 assembly) were then each a set of rules over the same machinery, under 100 lines of grammar in total.

The claimed benefit is legibility: each stage's output templates visibly match the next stage's input patterns, so the whole chain can be read in hours. With two peephole rules, the generated code reached 96% of gcc -O2 speed on a recursive benchmark. A similar under-100-line text-to-x86 chain appears in the 2009 STEPS report at 70% of C.

This is the strongest argument in the sources for writing back ends as grammars rather than as hand-coded Lisp. It bears directly on keeping a rebuilt Maru inside a line budget, because code generation is where the lines go.

Source: Piumarta 2010, *PEG-based transformer provides front-, middle- and back-end stages in a simple compiler* (VPRI TR-2010-003), §2–4 and Appendix B (primary); Kay et al. 2009, STEPS report (VPRI TR-2009-016), p. 9.
