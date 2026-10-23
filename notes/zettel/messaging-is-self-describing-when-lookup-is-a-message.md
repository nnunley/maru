---
title: "Messaging describes itself when method lookup on a cache miss is itself a message send"
source: "../sources/piumarta-2005-colas-white-paper.md"
created: 2026-10-14
schema_version: 1
links: [a-selector-flush-keeps-a-global-method-cache-correct, ground-as-little-of-the-evaluator-as-possible, maru-moved-dispatch-from-vtables-to-type-indexed-selectors, nil-and-small-integers-are-objects-without-bodies, the-meaning-of-immediates-is-installed-by-user-code, type-indexed-tables-make-every-composition-replaceable]
---

# Messaging describes itself when method lookup on a cache miss is itself a message send

In most object systems, method lookup is built into the virtual machine, so the meaning of a message send is fixed by code the program cannot see. Piumarta's minimal object model keeps only one primitive operation: probing a method cache. That probe is an optimisation, not semantics. When the cache misses, lookup is performed by sending a real `lookup` message to the receiver's vtable, which is itself an ordinary object.

The circle closes because the first vtable is its own vtable. Changing a vtable's `lookup` method then changes what sending a message means for every object using that vtable. Delegation, multiple inheritance or multiple dispatch become user-level overrides rather than VM features. The 2006 paper with Warth shows the kernel needs three object types and five methods, about 140 lines.

The same idea, that semantics belong in a replaceable object and not in the engine, reappears in Maru as type-indexed evaluator and applicator tables, generalised from messages to all evaluation. The weak point is the grounding: the cycle break (a hard-coded test for the vtable-of-vtables) and the cache are not themselves self-described, and the reference code never invalidates its cache. The shipped 2007 runtime answers the cycle-break objection differently from the paper: instead of testing whether the receiver is the vtable-of-vtables (TR Figs. 15, 17), `_libid_bind` counts its own nesting and calls the native lookup directly on the first nested bind (`libid.c:622`), so a replacement vtable-of-vtables no longer recurses forever.

Source: idst-20070918 `object/id/libid.c:622` (the recursion guard); Piumarta 2005, COLA white paper (VPRI RN-2006-001-a), §4 and Figs. 4–6 (primary); Piumarta & Warth 2006, *Open, reusable object models* (VPRI TR-2006-003a), pp. 3, 9, 12, 21–22.
