---
title: "In-memory code generation needs instruction words built from fields, plus label back-patching"
source: "../sources/piumarta-2010-peg-based-transformer.md"
created: 2026-10-14
schema_version: 1
links: [a-compiler-is-the-level-shift-that-grounds-a-metacircular-evaluator, assembler-coverage-should-cost-rows-not-code, one-pattern-matcher-can-implement-every-compiler-stage, word-size-baked-into-tag-tests-blocks-ports]
---

# In-memory code generation needs instruction words built from fields, plus label back-patching

A compiler back end that writes assembly text can lean on an external assembler for encoding and for resolving forward branches. Generating code directly into memory, for a just-in-time compiler or for a self-hosting system with no external toolchain, needs two things the text back end did not. First, a way to build each binary instruction word from its fields. Second, label management for forward references, by two passes or back-patching. Piumarta named exactly these as the missing pieces when he noted that his grammar-driven compiler could be extended to JIT compilation.

An encoding table in the vendor manual's notation supplies the first piece declaratively. An A64 row is literally the instruction's bit fields; an x86 row is its opcode bytes and ModRM/immediate fields. The same rows can decode as well as encode. The second piece belongs to the caller, which the encoder can support by reporting where each relocatable field landed.

On Apple Silicon, running such code in-process also needs memory mapped for JIT, switched between writable and executable per thread, and an instruction-cache flush. Every ARM host needs the flush.

Source: Piumarta 2010, *PEG-based transformer…* (VPRI TR-2010-003), §6 last paragraph (primary); Piumarta 2005, COLA white paper (VPRI RN-2006-001-a), §3.1 (dynamic assembler as a pipeline stage); Maru rebuild spike, 2026-10-14 (MAP_JIT probe running table-encoded A64 code).
