---
title: "Checking a budget at calls and loop back-edges bounds the time between preemption points"
source: "../sources/piumarta-2009-cola-kernel-abstraction.md"
created: 2026-10-14
schema_version: 1
links: [a-compiler-is-the-level-shift-that-grounds-a-metacircular-evaluator]
---

# Checking a budget at calls and loop back-edges bounds the time between preemption points

A running program can only keep going by calling procedures or by branching backwards. Straight-line code runs out. So if a compiler adds a cheap check of a budget counter in every function prologue and before every backward branch, there is a bound on how long the program can run between checks. When the budget is exhausted, the check enters the scheduler or kernel.

Piumarta's 2009 memo used exactly this to add preemptive multitasking to the STEPS core language. It took one new IR instruction (`tick`, which decrements the budget and conditionally calls the kernel's entry point) and a one-line addition to each of two compiler functions. Kernels there were minimal tuples (an entry point and a parent), scoped dynamically along the call graph. The same check point could serve time limits, isolation or interrupts.

The idea is the safepoint or yield point familiar from virtual machines, rediscovered at its smallest. The cost (a decrement and test at every call and loop) is not measured in the memo. For a small self-hosted system it is the cheapest way to get bounded run time or cooperative interruption without a runtime subsystem.

Source: Piumarta 2009, *COLA Kernel Abstraction* (VPRI M-2009-007), §2 and §3 (primary).
