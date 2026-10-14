---
title: "A compiler is the level shift that grounds a metacircular evaluator in hardware"
source: "../sources/piumarta-maru-page.md"
created: 2026-10-14
schema_version: 1
links: [ground-as-little-of-the-evaluator-as-possible, in-memory-code-generation-needs-instruction-words-built-from-fields, safepoints-at-calls-and-back-edges-bound-preemption, self-hosting-is-shown-only-by-byte-identical-regeneration]
---

# A compiler is the level shift that grounds a metacircular evaluator in hardware

A metacircular evaluator is written in the language it evaluates, so on its own it needs another evaluator beneath it, and another beneath that, without end. Piumarta calls the way out a "level shift": a compiler that translates the evaluator's description into machine code while preserving its meaning. The description then rests on hardware instead of on yet another evaluator.

This puts the compiler at the centre of a self-describing system, not at its edge. It is the component that ends the regress, and in Maru it is written in the same language as the evaluator (`emit.l` beside `eval.l`). What gets grounded, and how little, then becomes the main design question.

It also explains why the back end (code generation down to instruction encoding) belongs inside the system's own description. A system whose bottom is an external C compiler has handed its grounding to something it cannot describe.

Source: Piumarta, Maru project page, "The parts" (on `emit.l`) (primary); Piumarta 2011, *Open, extensible composition models* (VPRI TR-2011-002), §5.1.
