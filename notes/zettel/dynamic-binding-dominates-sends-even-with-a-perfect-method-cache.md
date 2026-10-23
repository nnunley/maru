---
title: "Even a method cache that always hits leaves dynamic binding as the largest cost of a send"
source: "../sources/piumarta-1992-delayed-code-generation-thesis.md"
created: 2026-10-23
schema_version: 1
links: [inline-caches-are-harder-to-invalidate-than-a-method-cache, maru-moved-dispatch-from-vtables-to-type-indexed-selectors, the-cost-of-meaning-by-indirection-is-recovered-by-staging]
---

# Even a method cache that always hits leaves dynamic binding as the largest cost of a send

It is tempting to think a global method cache solves dispatch cost once its hit rate is near 100%. Piumarta's 1992 profile of his native Smalltalk says otherwise: with the method cache hitting essentially every time, 43% of run time was still spent in dynamic binding. Each send still had to compute the receiver's class, hash it with the selector, probe the table and compare, and that fixed work, multiplied by the number of sends, outweighed the methods themselves. ParcPlace's figures in the same thesis tell the same story from the other side: their inline cache improved performance by about ten percent at the price of five times the code size.

The lesson is about where to look for speed. Hit rate measures whether lookup is avoided, not whether binding is cheap. A native Maru whose dispatch is a type test plus an array index (see [[maru-moved-dispatch-from-vtables-to-type-indexed-selectors]]) already avoids hashing; measuring the share of time in dispatch before adding caches tells whether caches would pay at all.

Source: Piumarta 1992, *Delayed Code Generation in a Smalltalk-80 Compiler*, App. E.3, pp. 179-180 (profile), pp. 33-34 (ParcPlace figures) (primary).
