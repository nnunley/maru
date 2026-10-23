---
title: "An object table or object list is needed for become and heap enumeration, not for ordinary execution"
source: "../sources/freudenberg-2014-squeakjs.md"
created: 2026-10-23
schema_version: 1
links: [a-one-word-object-header-is-reachable-by-two-routes, low-bit-integer-tags-rely-on-aligned-object-pointers, object-identity-can-stay-fixed-while-state-varies-by-context]
---

# An object table or object list is needed for become and heap enumeration, not for ordinary execution

The Blue Book, Piumarta's 1992 Smalltalk and the 2010 "Nothing" GC prototype in the STEPS report all reach objects through an object table: a pointer is an index, and the table holds the object's real address. Squeak (1997) dropped the table and uses direct addresses, and it kept the one feature the table made easy, `become` (swapping the identities of two objects), by scanning memory once and fixing every pointer. SqueakJS (2014), running on JavaScript's collector, had no table and no weak references, and it found it still needed its own chain of old objects for the one job the host could not do: enumerating every object.

The table's real purchases are therefore two operations, identity exchange and heap enumeration, plus easy object movement. It costs an indirection on every access. For a native Maru whose evaluator never uses `become` and whose GC already threads objects on its own `next` list, there is no reason to add a table; if `become` is ever wanted, Squeak's whole-memory scan is the precedent.

Source: Freudenberg et al. 2014, *SqueakJS*, §3.1-3.2 (primary); Ingalls et al. 1997, *Back to the Future*, Object Memory section (become without an object table); Goldberg & Robson 1983, Ch. 30; STEPS 2010 report (TR-2010-004), Appendix 2; this tree's `eval.l:17` (the `next` field).
