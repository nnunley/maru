---
title: "A one-word object header is reachable either by making it the behaviour pointer or by indexing a small table of common classes"
source: "../sources/ingalls-1997-back-to-the-future-squeak.md"
created: 2026-10-23
schema_version: 1
links: [a-header-word-before-the-body-lets-foreign-structs-be-objects, an-object-table-buys-become-and-enumeration-not-speed, maru-moved-dispatch-from-vtables-to-type-indexed-selectors]
---

# A one-word object header is reachable either by making it the behaviour pointer or by indexing a small table of common classes

Every object must say what kind of thing it is, and the cheapest place to say it is a single word next to the object. Two members of the same research community reached a one-word header by opposite routes. Squeak (1997) packs a 5-bit index into a table of up to 31 "compact" classes, together with size, format, hash and header-type bits, into one word; only objects of other classes need a second word holding a full class pointer, and in practice about 81% of objects need just the one. Piumarta's COLA runtime instead makes the single header word the pointer to the object's vtable and keeps the size out of the object entirely, leaving it to the allocator. Kay describes the origin of the idea in FLEX: a reference first carried two pointers, to the object's "master" and to the instance, until they realised the master pointer should live in the instance to save space.

The trade is between what the word must hold. A pointer names any behaviour but leaves no room for size or GC bits, so the collector must find them elsewhere; an index leaves room for those bits but limits how many classes can be named cheaply. Maru's evaluator and its Maru GC carry a four-word header (size, flags, next, type), the largest in the lineage. A native Maru that wants a smaller header can take either route, and the choice is coupled to how its GC finds object sizes.

Source: Ingalls et al. 1997, *Back to the Future: The Story of Squeak*, Object Memory section (primary); idst-20070918 `object/id/libid.c:245-255`; Kay 1993, *The Early History of Smalltalk*, FLEX section; this tree's `eval.l:17`, `maru-gc.k:15`.
