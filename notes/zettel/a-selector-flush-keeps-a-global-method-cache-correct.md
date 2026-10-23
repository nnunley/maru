---
title: "A global method cache stays correct if every method change flushes all entries for that selector"
source: "../sources/piumarta-2007-idst-source.md"
created: 2026-10-23
schema_version: 1
links: [delegation-costs-nothing-for-objects-that-do-not-use-it, inline-caches-are-harder-to-invalidate-than-a-method-cache, maru-moved-dispatch-from-vtables-to-type-indexed-selectors, messaging-is-self-describing-when-lookup-is-a-message, the-cost-of-meaning-by-indirection-is-recovered-by-staging]
---

# A global method cache stays correct if every method change flushes all entries for that selector

The 2006 object-model paper leaves cache invalidation "beyond the scope", and its reference code never invalidates. The shipped COLA runtime does: its global cache holds entries of vtable, selector and closure, and installing or changing a method clears every entry with that selector, whatever vtable it belongs to. That over-flushes, but it is cheap to reason about, because a selector's bindings are the only thing a method change can make stale. Delegation needs no flush, because a vtable's parent is set when the vtable is made and never changed afterwards.

The per-send-site inline cache is a different matter. Pepsi's compiler can emit one, keyed on the receiver's vtable alone, but the selector flush does not reach it. It stays correct only because a changed method overwrites the existing closure in place; a new binding that shadows an inherited one would leave the site calling the old method. The authors shipped the global cache as the default and the inline cache as an option, which is the safe order. A native back end that adds inline caches needs an invalidation rule for them before it depends on them.

Source: idst-20070918 `object/id/libid.c:170-178`, `:360-368`, `:685-700`, `object/idc/CompilerOptions.st:47`, `object/idc/CCodeGenerator.st:118-150` (primary); Piumarta & Warth 2006, *Open reusable object models*, pp. 15, 22 (the paper's omission).
