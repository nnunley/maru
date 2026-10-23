---
title: "Maru replaced Pepsi's per-object vtable with a type index in the header and per-selector method arrays"
source: "../sources/piumarta-2007-idst-source.md"
created: 2026-10-23
schema_version: 1
links: [a-selector-flush-keeps-a-global-method-cache-correct, delegation-costs-nothing-for-objects-that-do-not-use-it, dynamic-binding-dominates-sends-even-with-a-perfect-method-cache, messaging-is-self-describing-when-lookup-is-a-message, nil-and-small-integers-are-objects-without-bodies, type-indexed-tables-make-every-composition-replaceable]
---

# Maru replaced Pepsi's per-object vtable with a type index in the header and per-selector method arrays

Pepsi stores a pointer to a vtable in each object's header, and a send asks that vtable for the selector through a global cache and, on a miss, a `lookup:` message. Maru keeps the header placement and the immediate test but stores a small integer type id there instead, and inverts the table: each selector holds an array of methods indexed by type id, and a send indexes the selector's array with the receiver's type. On a miss it walks the type's bases; a line that would copy the inherited method down into the array is commented out, so there is no cache at all. The evaluator itself dispatches the same way, through arrays of evaluators and applicators indexed by type.

No source states this as a change of mind; it is visible only by comparing the two code bases. The effect is that behaviour is grouped by operation instead of by object family, which suits multimethods (Maru's `<generic>` indexes one array per argument) and the type-indexed evaluator tables, and loses the per-object replaceable `lookup` that made Pepsi's messaging self-describing. A native evaluator compiled from eval.l inherits Maru's scheme: dispatch is a type test followed by an array index, not a cache probe.

Source: synthesis. Maru 2.4 `boot.l:499-511` (selector applicator, copy-down commented out at 504) and `eval.c:85`; this tree's `boot.l:508-522`, `eval.c:116`, `boot.l:663-713`; idst-20070918 `object/id/libid.c:605-640` (Pepsi bind).
