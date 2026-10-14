---
title: "A line count means nothing without a stated boundary of what it includes"
source: "../sources/steps-2007-first-year-report.md"
created: 2026-10-14
schema_version: 1
links: [a-self-describing-system-must-count-its-own-bottom, assembler-coverage-should-cost-rows-not-code, steps-budgeted-20k-lines-of-meaning-code]
---

# A line count means nothing without a stated boundary of what it includes

Every size claim in the STEPS literature that could be checked turned out to depend on an unstated boundary of what was counted:

- JavaScript was "170 lines" of OMeta, but needed about 1,000 lines of the IS system underneath, about 1,170 in total (2007 report).
- Nile's 1,240 lines excluded OMeta and the C compiler (2009).
- The minimal object kernel was "about 140 lines" with no counting rule, against about 180 non-blank lines in its appendix (2006).
- A Smalltalk-like language's "333 lines, blanks and comments removed" did not reproduce from the printed source (2011).
- The final report's essential-code table excluded the Squeak host and the Nile engine (2012).
- Piumarta's own figures for the original Maru differ: 1,750 lines on the project page, under 1,800 "distinct lines" in the 2011 paper.

The lesson is not that the counts are wrong. It is that a count without its boundary (what is included, what is host, what is generated, how blanks and comments are treated) cannot be compared or checked. A budget enforced by a machine needs exactly that boundary written down. The Maru rebuild's `check/lines` ledger does this: a fixed counting command, `derived` attributes for generated files, and a reason for every delta.

Source: Kay et al. 2007, STEPS first-year report (VPRI TR-2007-008), pp. 7, 11 (primary); Kay et al. 2009 (TR-2009-016), pp. 7, 9; Piumarta & Warth 2006 (TR-2006-003a), pp. 21, 24; Kay et al. 2011 (TR-2011-004), p. 34; Kay et al. 2012 (TR-2012-001), App. II p. 47; Piumarta, Maru project page and TR-2011-002 §6.
