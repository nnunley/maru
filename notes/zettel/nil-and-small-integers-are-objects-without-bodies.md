---
title: "Nil and small integers are objects without bodies, found by a three-way test on the pointer"
source: "../sources/piumarta-2007-idst-source.md"
created: 2026-10-23
schema_version: 1
links: [a-header-word-before-the-body-lets-foreign-structs-be-objects, maru-moved-dispatch-from-vtables-to-type-indexed-selectors, messaging-is-self-describing-when-lookup-is-a-message, native-eval-should-tag-integers-as-eval-c-does, the-meaning-of-immediates-is-installed-by-user-code, word-size-baked-into-tag-tests-blocks-ports]
---

# Nil and small integers are objects without bodies, found by a three-way test on the pointer

In Piumarta's COLA runtime every ordinary object is a body whose behaviour is named by a word stored just before it, but two kinds of value have no body at all. Nil is the pointer zero, and a small integer is its value shifted left one bit with the low bit set. Because neither can carry a header, the runtime finds their behaviour another way: any pointer with bit 0 set uses one global "tag" vtable, the zero pointer uses one global "nil" vtable, and everything else reads the word at offset minus one. That three-way test is the whole of "what kind of thing is this?", and it is the one piece of code every send runs before it can look anything up.

The design keeps arithmetic on small integers free of allocation while still letting integers and nil answer messages like any other object, so there is no separate primitive world. The cost is that the test must run at every dispatch, which is why Pepsi's compiler emits it inline and why the hand-written i386 bind path starts with a bit test, a zero test and a load. Maru's C evaluator keeps exactly this test in `getType` (bit 0 means Long, zero means Undefined, otherwise the header's type field), though what the header names changed (see [[maru-moved-dispatch-from-vtables-to-type-indexed-selectors]]). For a native back end the test is the first sequence the type dispatch must emit, so its shape and its constants (which bit, which value is nil) have to be fixed before the intent layer is.

Source: idst-20070918 `object/id/libid.c:609`, `function/objects/tag.h:1-2` (primary); Piumarta 2005, COLA white paper §4.2 and fn. 17; Maru `eval.c:116` and `eval.c:174-177`.
