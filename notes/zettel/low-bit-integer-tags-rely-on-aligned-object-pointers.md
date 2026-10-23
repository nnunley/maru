---
title: "A low-bit integer tag works because real object pointers are aligned, and it beats a high-bit tag on sign extension"
source: "../sources/piumarta-1992-delayed-code-generation-thesis.md"
created: 2026-10-23
schema_version: 1
links: [an-object-table-buys-become-and-enumeration-not-speed, inlining-integer-arithmetic-gives-up-redefining-it, native-eval-should-tag-integers-as-eval-c-does, nil-and-small-integers-are-objects-without-bodies, word-size-baked-into-tag-tests-blocks-ports]
---

# A low-bit integer tag works because real object pointers are aligned, and it beats a high-bit tag on sign extension

An object pointer can double as a small integer only if some of its bit patterns can never be real pointers. The Smalltalk-80 Blue Book uses the low bit: 0 means the other bits index the object table, 1 means they are a signed integer, which needs no table entry and no heap space. Piumarta's 1992 thesis keeps that split for a 32-bit machine and gives the reason it is free. Real pointers are byte offsets that are always multiples of eight, so every odd pattern is unused, and an integer n can be stored as 2n+1. He also says why the tag goes at the bottom: a tag in the high bits forces sign extension when the value is recovered, though it would let a single branch-on-not-equal test for immediates.

The same encoding then runs unchanged through the 2007 COLA runtime and Maru's `eval.c`. What changed around it is nil. In the Blue Book and the thesis nil is an ordinary object with its own table entry; COLA makes it the zero pointer, giving a second body-less value (see [[nil-and-small-integers-are-objects-without-bodies]]). The encoding depends on alignment, so any allocator that hands out odd addresses, or any header layout that puts an object pointer at an odd offset, silently turns objects into integers. A native Maru must keep every heap object at least two-byte aligned, and in practice word aligned.

Source: Piumarta 1992, *Delayed Code Generation in a Smalltalk-80 Compiler*, §5.1.1, p. 55 and fn. 3-4 (primary); Goldberg & Robson 1983, *Smalltalk-80*, Ch. 30, p. 661; idst-20070918 `function/objects/tag.h`; Maru `eval.c:174-177`.
