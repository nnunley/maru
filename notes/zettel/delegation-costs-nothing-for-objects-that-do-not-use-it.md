---
title: "Delegation consulted only after a failed lookup costs nothing for objects that never delegate"
source: "../sources/piumarta-2007-lieberman-prototypes-memo.md"
created: 2026-10-23
schema_version: 1
links: [a-selector-flush-keeps-a-global-method-cache-correct, maru-moved-dispatch-from-vtables-to-type-indexed-selectors, messaging-is-self-describing-when-lookup-is-a-message, object-identity-can-stay-fixed-while-state-varies-by-context]
---

# Delegation consulted only after a failed lookup costs nothing for objects that never delegate

COLA's vtables give inheritance between families of objects, but not Lieberman-style delegation, where one object forwards messages it does not understand to another while `self` stays the original receiver. Piumarta's 2007 memo adds delegation by changing only bind: look the selector up as usual, and only if that fails, ask the receiver for its delegate and repeat the lookup there. Ordinary objects answer nil to the delegate request, and that request happens only immediately before a message would fail anyway, so they carry no extra state and pay no extra time.

The general pattern is to put a rare mechanism on the failure path of a common one. It keeps the object layout unchanged (no delegate slot in every object) and leaves the fast path exactly as fast. It also means delegation interacts with caching only through misses, so a cache that stores successful lookups needs no change. For Maru, whose dispatch walks a type's bases on a miss, delegation could be added the same way, after the bases are exhausted, without touching headers.

Source: Piumarta 2007, *Efficient sideways composition in COLAs via 'Lieberman' prototypes*, VPRI M-2007-002-a, §2.2 (primary); Piumarta & Warth 2006, *Open reusable object models*, fn. 2.
