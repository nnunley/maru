---
title: "A self-describing system must count its own substrate, not just what it adds"
source: "../sources/steps-2011-report.md"
created: 2026-10-14
schema_version: 1
links: [a-line-count-needs-a-stated-boundary, self-hosting-is-shown-only-by-byte-identical-regeneration, steps-budgeted-20k-lines-of-meaning-code, the-meaning-of-immediates-is-installed-by-user-code]
---

# A self-describing system must count its own substrate, not just what it adds

Conventional software size comparisons leave out the compiler, runtime and IDE the code depends on. The C compiler under a C program is not counted against the program. The 2011 STEPS report rejects that convention for STEPS itself. Every line of "meaning code" needed to run the system counts, including the system's own bottom (code generation down to machine code) and the tools for all its languages. That is precisely why the project needed Maru: a way to go from very high-level problem-oriented languages down to CPU instructions without an uncounted C toolchain underneath.

The report also admits where it falls short. In 2011 the system still had C modules at its bottom. In 2012 the final accounting still excluded the Squeak host under the user interface.

For a rebuild with a line budget, this justifies counting the C bootstrap evaluator until the system generates its own evaluator. The C is part of the bottom, and the point of the exercise is to replace it with described, counted, smaller code.

Source: Kay et al. 2011, STEPS report (VPRI TR-2011-004), p. 22 (primary); Kay et al. 2012, STEPS final report (VPRI TR-2012-001), App. II p. 47 (shortfall).
