---
title: "Building on someone else's VM gives up control of method lookup and object layout"
source: "../sources/yamamiya-ohshima-2010-tamacola.md"
created: 2026-10-23
schema_version: 1
links: [a-header-word-before-the-body-lets-foreign-structs-be-objects, ground-as-little-of-the-evaluator-as-possible, messaging-is-self-describing-when-lookup-is-a-message]
---

# Building on someone else's VM gives up control of method lookup and object layout

Tamacola carried COLA's grammar-driven ideas to the browser by compiling a Scheme-like language to Adobe's ActionScript VM. Its authors state plainly what that cost: unlike COLA, which implements its own kernel, Tamacola cannot change how methods are looked up or how objects are laid out in memory, because the host VM fixes both. Those are exactly the two things COLA's design made replaceable: lookup is a message to a vtable, and the header-before-the-body layout lets any memory become an object. SqueakJS and Babelsberg (on a Ruby VM with hidden-class maps) show the same pattern from other angles: the host decides representation, and the guest adapts.

So owning the runtime is not incidental to the STEPS goal of a system that describes itself all the way down; it is the condition for lookup and layout being part of the description. It is one of the reasons Maru compiles to native code through its own back end rather than to a host VM, and why the representation choices for the native evaluator are worth getting right: there is no one else to make them.

Source: Yamamiya & Ohshima 2010, *Tamacola*, VPRI TR-2010-002, §2.1 (primary); Freudenberg et al. 2014, *SqueakJS*, §3.1; Felgentreff, Borning & Hirschfeld 2013, *Babelsberg*, VPRI TR-2013-001, §4.1-4.2.
