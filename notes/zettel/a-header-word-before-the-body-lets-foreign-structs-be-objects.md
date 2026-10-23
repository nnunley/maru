---
title: "Putting the header one word before the body lets a foreign struct become an object without moving it"
source: "../sources/piumarta-2005-colas-white-paper.md"
created: 2026-10-23
schema_version: 1
links: [a-host-vm-takes-away-control-of-lookup-and-layout, a-one-word-object-header-is-reachable-by-two-routes, nil-and-small-integers-are-objects-without-bodies, word-size-baked-into-tag-tests-blocks-ports]
---

# Putting the header one word before the body lets a foreign struct become an object without moving it

In the COLA object model an object pointer is the address of the object's first field, and the word naming its behaviour lives at the address just below. Piumarta gives the reason explicitly: a C struct, a C++ object or an Objective-C instance has its fields at its own address, so allocating one extra word in front of it turns it into an object whose pointer is the same pointer C already holds. The foreign code and the object system then share one identity for the value, with no proxy and no copying, which the Pepsi manual calls toll-free bridging.

The choice constrains everything that touches memory. A collector must treat the object pointer as an interior pointer of its allocation, field offsets start at zero from the pointer, and the header must be exactly what sits at offset minus one. Maru kept the placement (its GC header ends just below the object, and eval.l reads the type at `oop-at -1`) but its header grew to several words, so only the last word is adjacent to the body. The 2007 tree documents the wrapping but contains no example of it, so the benefit is argued rather than demonstrated.

Source: Piumarta 2005, COLA white paper §4.3 and Fig. 7 (primary); Pepsi manual (`pepsi.html`, "Object layout and object pointers"); Piumarta & Warth 2006, *Open reusable object models*, Fig. 4; idst-20070918 `object/id/libid.c:245-255`; Maru `gc.c:65-66`, `eval.l:313`.
