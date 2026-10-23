---
title: "Compiling integer arithmetic inline makes the integer operations impossible to redefine"
source: "../sources/piumarta-1992-delayed-code-generation-thesis.md"
created: 2026-10-23
schema_version: 1
links: [low-bit-integer-tags-rely-on-aligned-object-pointers, nil-and-small-integers-are-objects-without-bodies, steps-budgeted-20k-lines-of-meaning-code, the-cost-of-meaning-by-indirection-is-recovered-by-staging]
---

# Compiling integer arithmetic inline makes the integer operations impossible to redefine

Smalltalk, Pepsi and Maru all treat `+` on integers as a message, which in principle anyone can redefine. Every fast implementation in the lineage instead compiles it inline: test that both operands carry the integer tag, add the untagged values, and fall back to a real send only when a test fails. Piumarta's thesis points out the consequence in a footnote: once arithmetic is inlined, redefining SmallInteger's arithmetic has no effect on code already compiled, and this is true of any Blue Book implementation, because the special selectors are short-circuited. His inline code also omitted the overflow check; COLA's Pepsi compiler later added one, falling back to the send when the sum leaves the integer range.

This is a place where speed and late binding meet head-on. The STEPS position, that meaning is kept separate from optimization, suggests treating inlined arithmetic as an optimization pass with a stated contract (the integer operations are fixed while it is on), not as part of the meaning of `+`. A native Maru that inlines tagged arithmetic should say so, keep the overflow fallback, and keep a path with the pass off that honours redefinition.

Source: Piumarta 1992, *Delayed Code Generation in a Smalltalk-80 Compiler*, pp. 87-88 and fn. 30 (primary, checked on the page image); idst-20070918 `object/idc/CCodeGenerator.st:803-832`.
