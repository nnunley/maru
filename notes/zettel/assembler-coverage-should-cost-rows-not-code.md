---
title: "Instruction coverage should cost table rows, not hand-written encoder code"
source: "../sources/steps-2012-final-report.md"
created: 2026-10-14
schema_version: 1
links: [a-line-count-needs-a-stated-boundary, back-ends-are-the-line-budget-lever, compiler-size-concentrates-in-code-generation-not-parsing, in-memory-code-generation-needs-instruction-words-built-from-fields, the-cost-of-meaning-by-indirection-is-recovered-by-staging]
---

# Instruction coverage should cost table rows, not hand-written encoder code

The STEPS final report gives the one direct figure on what an assembler costs inside a self-describing system. Maru's assembler was 621 of its 4,317 hand-written lines. Because it encoded all x86 instructions, the basis would have been about 500 lines smaller with only the instructions Maru and Nile actually used. In a hand-written assembler, every instruction form covered is code, so coverage and size trade off directly.

An encoding table written in the vendor manual's own notation changes the trade. Each instruction form is one row, and the code that interprets or compiles the rows is fixed in size. Coverage then costs about one line per form, and that row also serves the disassembler. The 2026 Maru rebuild spike measured this: 67 x86 forms in 79 lines of rows plus about 210 lines of grammar and interpreter, checked byte-for-byte against clang, including decoding. That replaced a 943-line macro file plus a separate 94-line disassembler.

The design rule: an assembler's size should grow with its table, not with its code, and a full table is affordable where a full hand-written encoder is not.

Source: Kay et al. 2012, STEPS final report (VPRI TR-2012-001), p. 11 (primary; verified from the page image); Maru rebuild table-driven assembler spike, 2026-10-14.
