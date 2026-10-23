---
title: "Maru's native evaluator should tag integers (low bit 1, nil = 0) as eval.c and the whole COLA lineage do, not box them as eval.l does today"
scope: personal
status: live
created: 2026-10-23
last_reviewed: 2026-10-23
falsifier: "Tagging makes the native GC, the FFI boundary or the bootstrap fixpoint harder than boxing (e.g. raw words in eval.l can't be told from tagged ints), or a measured boxed native evaluator already meets the check time limits with no allocation pressure"
links: [nil-and-small-integers-are-objects-without-bodies, word-size-baked-into-tag-tests-blocks-ports]
schema_version: 1
---

# Why I hold this

Every system in this lineage that runs at speed tags small integers with bit 0 and makes nil the zero pointer: the 2007 COLA runtime, Maru 2.4's eval.c, and this tree's eval.c. eval.l keeps the same assumptions everywhere except the one switch that picks a representation. Its type test checks bit 0, its GC skips odd words, its sentinel is chosen so it can't be a tagged immediate, and only `if-tagged-int` (eval.l:12) forces boxing. So turning tagging on brings eval.l into line with eval.c rather than adding a design. Boxing every integer means every arithmetic result in the native evaluator allocates, which costs most in exactly the stage-1 and stage-2 runs that have to fit the check limit. What remains to settle is the overflow check that eval.c has and eval.l's `new-<long>` lacks, and keeping eval.l's raw machine words (sizes, counters) out of slots the GC scans. This is my position, not a decision. The representation is the user's call in the back-end RFC.

# Revision log
## 2026-10-23 — created
From reading idst-20070918, the COLA white paper and Maru 2.4 against this tree, 2026-10-23
