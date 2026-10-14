---
title: "A compiler's size concentrates in code generation and optimisation, not in parsing"
source: "../sources/steps-2009-report.md"
created: 2026-10-14
schema_version: 1
links: [assembler-coverage-should-cost-rows-not-code, back-ends-are-the-line-budget-lever, one-pattern-matcher-can-implement-every-compiler-stage]
---

# A compiler's size concentrates in code generation and optimisation, not in parsing

Across the STEPS reports the same pattern recurs: describing a language's syntax is cheap, and turning it into fast executable code is where the lines go.

| Source | Parsing / front end | Code generation / back end |
|---|---|---|
| Nile prototype, STEPS 2009 | about 130 lines of meta-description | about 1,110 lines for the AST-to-C translator |
| Maru in the 2012 final report | parser 248 lines | code generator 1,357 lines, plus a 621-line assembler |

The 2012 report also says plainly that PEG grammars handled almost every parser in STEPS, and that optimisation, not parsing, dominated the language work.

The practical consequence for a line budget is where to aim reduction effort. Grammars have already made front ends small. The remaining mass is instruction selection, optimisation and encoding, so that is where DSLs and tables pay off: grammar-driven back ends, and encoding tables in place of hand-written assemblers.

Source: Kay et al. 2009, STEPS report (VPRI TR-2009-016), pp. 6–7 (primary); Kay et al. 2012, STEPS final report (VPRI TR-2012-001), p. 11 (figure, verified from the page image) and p. 16.
