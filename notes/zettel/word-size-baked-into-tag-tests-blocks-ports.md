---
title: "Tag tests, slot offsets and arithmetic written for one word size block every port to another"
source: "../sources/piumarta-2007-idst-source.md"
created: 2026-10-23
schema_version: 1
links: [a-header-word-before-the-body-lets-foreign-structs-be-objects, in-memory-code-generation-needs-instruction-words-built-from-fields, low-bit-integer-tags-rely-on-aligned-object-pointers, native-eval-should-tag-integers-as-eval-c-does, nil-and-small-integers-are-objects-without-bodies]
---

# Tag tests, slot offsets and arithmetic written for one word size block every port to another

The 2007 COLA tree defines its integer tag with `long`, yet its tag tests cast pointers to `unsigned`, its inline integer arithmetic works in `int`, and its Lisp layer steps slot offsets by four bytes. On a 32-bit machine these agree; on a 64-bit one the casts truncate pointers and the offsets land inside fields, so the system cannot be moved without finding each site by hand. Maru's own eval.l and emit.l repeat the pattern: a structure's size is four bytes per field, sizes are converted with a shift by two, alignment masks with minus four, and every slot, immediate and data directive in the emitted code is 32 bits.

The lesson is that word size is not one constant but a property scattered through representation code (tagging, header layout, field offsets, alignment, immediate widths). It has to be a named parameter from the first line, the way ir2 takes sizes from `osdefs.k`, or a port becomes a search. For the native bootstrap this is a concrete work list: eval.l's literal fours, twos and minus fours, and emit.l's 32-bit slots, scales and directives.

Source: idst-20070918 `function/objects/tag.h:1-2`, `object/id/libid.c:609`, `object/idc/CCodeGenerator.st:803-832`, `function/jolt/object.k` (primary); this tree's `eval.l:83`, `:183`, `:203`, `emit.l:252-259`, `:276-301`.
