---
title: "An object's identity can stay fixed while its state varies by context, so versioned state needs no new representation"
source: "../sources/warth-2011-worlds.md"
created: 2026-10-23
schema_version: 1
links: [an-object-table-buys-become-and-enumeration-not-speed, delegation-costs-nothing-for-objects-that-do-not-use-it]
---

# An object's identity can stay fixed while its state varies by context, so versioned state needs no new representation

Warth's Worlds lets a program sprout a child "world", make changes in it, and later commit or discard them. The implementation keeps each object's identity the same in every world and stores, per world, a table from object to that world's view of the object's slots; a read that finds nothing in the current world delegates to the parent world. The authors key those tables on the object itself, and say why: an object's identity never changes, whatever world it is in. Making the delegating slot lookup a primitive gave a large speedup.

The point for representation is that contextual or versioned state is a layer over slot access, not a property of the object pointer. As long as the oop is a stable identity and slot reads and writes go through a small number of primitives, such a layer can be added later without changing headers, tags or dispatch. That lets a native Maru fix its representation for the bootstrap without foreclosing Worlds-style features.

Source: Warth, Ohshima, Kaehler & Kay 2011, *Worlds: Controlling the Scope of Side Effects*, ECOOP 2011 / VPRI TR-2011-001, §3 and §5.2 (primary).
