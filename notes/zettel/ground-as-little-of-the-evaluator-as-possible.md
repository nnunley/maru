---
title: "Ground as little of a self-describing evaluator as possible, because grounded parts stop being modifiable"
source: "../sources/piumarta-2011-open-extensible-composition-models.md"
created: 2026-10-14
schema_version: 1
links: [a-compiler-is-the-level-shift-that-grounds-a-metacircular-evaluator, a-host-vm-takes-away-control-of-lookup-and-layout, messaging-is-self-describing-when-lookup-is-a-message, the-meaning-of-immediates-is-installed-by-user-code, type-indexed-tables-make-every-composition-replaceable]
---

# Ground as little of a self-describing evaluator as possible, because grounded parts stop being modifiable

When a metacircular evaluator is grounded by translating part of it into an executable form, the translated parts can no longer be inspected or changed from inside the language. Every assumption frozen there becomes a fixed limit on what programs can redefine. So the grounded part should be as small, and as free of semantic assumptions, as possible.

Piumarta's 2011 comparison makes this concrete. Grounding a conventional Lisp evaluator freezes which types can be expressions, what they mean, how combinations are represented and combined, which types can be operators, and what operators mean. Grounding an evaluator that dispatches through type-indexed tables freezes only two things: the table lookup itself, and how a primitive is applied. Everything else (atoms, list evaluation, closure application) stays redefinable from the language.

This gives a test for what a C bootstrap evaluator must contain: type dispatch, primitive application, and the primitives themselves. Special cases beyond that are drift, and in a line-budgeted rebuild they are counted C that belongs in the self-described part. The 2005 COLA design was less strict, since it kept a fixed vtable layout and a global method cache; the 2011 design narrows the grounded core further.

Source: Piumarta 2011, *Open, extensible composition models* (VPRI TR-2011-002), §5.1 (primary); Piumarta 2005, COLA white paper (VPRI RN-2006-001-a), Fig. 3 caption (contrast).
