---
title: "A global method cache is easy to purge; inline caches scattered through compiled code are not"
source: "../sources/piumarta-1992-delayed-code-generation-thesis.md"
created: 2026-10-23
schema_version: 1
links: [a-selector-flush-keeps-a-global-method-cache-correct, dynamic-binding-dominates-sends-even-with-a-perfect-method-cache]
---

# A global method cache is easy to purge; inline caches scattered through compiled code are not

A global method cache is one table keyed by class (or vtable) and selector, so when a method changes the runtime can clear the affected entries, or all of them, in one place. An inline cache is a different kind of thing: a remembered class and target stored at each send site, inside compiled code, so there are as many caches as sends and nothing lists them. Piumarta's 1992 thesis states the asymmetry directly and names the ways out, each costly: keep the caches in out-of-line structures and trawl memory for them, record a map of every site, or scan code for a recognisable signature. It also caches the destination method's object pointer rather than its address, so the collector can move methods without patching sites.

The asymmetry explains a choice made fifteen years later. The COLA runtime invalidates its global cache by flushing a selector (see [[a-selector-flush-keeps-a-global-method-cache-correct]]), while its compiler's per-site inline cache is off by default and is not reached by that flush. For a native Maru the order of work follows: a global cache with a defined flush first, inline caches only once there is a way to find and invalidate every site.

Source: Piumarta 1992, *Delayed Code Generation in a Smalltalk-80 Compiler*, App. E.3.1-E.3.4, pp. 179-184 (primary); idst-20070918 `object/idc/CompilerOptions.st:47`, `object/id/libid.c:685-700`.
