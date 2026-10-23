---
title: "Kay's object is an interpreter of the messages sent to it, owning all of its behaviour"
source: "../sources/kay-1993-early-history-of-smalltalk.md"
created: 2026-10-23
schema_version: 1
links: [maru-moved-dispatch-from-vtables-to-type-indexed-selectors, messaging-is-self-describing-when-lookup-is-a-message, one-pattern-matcher-can-implement-every-compiler-stage]
---

# Kay's object is an interpreter of the messages sent to it, owning all of its behaviour

In his history of Smalltalk, Alan Kay describes the idea that organised the language: an object should privately own all of its behaviour, so that it is a kind of mapping whose values are its behaviours, and each object can be seen as a syntax-directed interpreter of the messages sent to it. Operators and functions are not things that act on objects from outside; the receiver decides what a message means.

Piumarta's COLA object model is a literal implementation of that sentence. Because method lookup is itself a message to the object's vtable, each family of objects can replace how messages are interpreted, not just which methods it has. Maru moved dispatch into per-selector tables indexed by type, which keeps "the receiver's type decides" but gives up the per-object ownership of interpretation. Kay's framing is the yardstick for that trade: it measures how far a dispatch scheme is from objects that interpret their own messages, and it connects the object model to the grammar-driven side of STEPS, where interpreting structured input is the whole job of a matcher.

Source: Kay 1993, *The Early History of Smalltalk*, HOPL-II, the passages on objects as mappings of behaviours and as interpreters of messages (primary; OCR text lines ~529 and ~725); Piumarta 2005, COLA white paper §4.
