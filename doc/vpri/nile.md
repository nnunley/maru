
# Nile

Nile is the STEPS "runnable math" language for stream processing. A Nile program is a set of kernels: processes that read elements from input streams, write to output streams, and chain with `→`. Gezira, the 2-D renderer, is written in it. The Frank image holds two translators from Nile source: `NileCTranslator` (package Nile, Warth's OMeta translator to C) and `NileSqueakTranslator` (package Gezira-Nile, which compiles each kernel to a Smalltalk class). The maru tree builds Gezira from the 2016 Nile source, `gezira/nile/gezira.nl`.

## Why

The reports measure the language in lines. The 2009 report gives 318 lines of Nile for the graphics kernels it lists, and says the Nile-to-C translator is about 1,110 lines of OMeta, 1,240 with the parser. TR-2011-004 gives 457 lines for all STEPS graphics. The 2012 final report gives 495 lines for "virtually all personal computing graphics" and 45 lines for the rendering formula. The counts are for different versions of the code, so they don't compare line for line.

The kernel form fits the rendering maths. Each stage of Gezira is one kernel with a formula in its body. Kernels only touch their streams, so the runtime can run them concurrently. TR-2010-004 says stateless kernels can also be duplicated to split one stream across workers, and TR-2011-004 reports a multithreaded runtime with nearly linear speedup per core.

## How

A kernel is `Name (params) : InputType >> OutputType`. `∀` binds one input element, `>>` emits, `<<` puts a value back on the input, and `→` chains kernels. From `gezira/nile/gezira.nl`:

```
TransformBeziers (M:Matrix) : Bezier >> Bezier          (gezira.nl:819)
    ∀ (A, B, C)
        >> (MA, MB, MC)

Rasterize () : Bezier >> SpanCoverage                    (gezira.nl:555)
    → DecomposeBeziers () → SortBy (1) → SortBy (2) → CombineEdgeSamples ()

ExpandSpans () : SpanCoverage >> PointCoverage           (gezira.nl:417)
    ∀ (x, y, c, l)
        if c > 0 ∧ l > 0
            >> (x, y, c, 1 - c)
            << (x + 1, y, c, l - 1)
```

`ExpandSpans` emits one pixel and feeds the rest of the span back. The parser maps a `<<` line to `{#in}` (`Nile/source.st`, NileParser rule `indent(nil) ("<<" expr)*`).

`NileCTranslator` turns a `∀` body into a loop over buffers. From `NileCTranslator>>emitForAllWithPattern:body:`:

```
while (!nile_Buffer_is_empty (in) && !nile_Buffer_quota_hit (out)) {
```

The loop ends by saving the kernel's variables in `*vars` and returning `out`, so each call resumes where the last stopped.

The Squeak route is `NileSqueakTranslator translate` (`Gezira-Nile`, which translates `GZKernel source`), which writes methods into a change set named `Gezira-Translated`, or `translateIntoUniclasses:`, which makes one class per kernel. A pipeline is then built and fed as in `Gezira-Nile GZKernel class>>example`:

```
pipe := GZKernel pipeline: {transform. clip. rasterize. apply. write}.
pipe feed: vertices from: 1 to: vertices size by: 6.
```

## When

- 2007: Gezira and its formula are described in the first-year report (`steps-2007`, the Gezira section and Appendix G). The 2008 report says the rendering system was invented in 2007 and engineered for use in 2008.
- 2009: TR-2009-016 presents Nile as "active math" over streams, with the OMeta parser and translator.
- 2010: TR-2010-004 says Gezira/Nile "is used for all graphical operations in Frank". The 2010 report also says the meta-compilation of all Nile code via OMeta was completed.
- 2011: TR-2011-004 describes the multithreaded runtime and the Nile-with-maths syntax (`∀`, Unicode operators).
- 2012: the final report repeats the 495-line count and describes the metacompiler making itself.
- Monticello: Nile has eight versions, Nile-yo.1 (18 Feb 2011, local time) to Nile-bf.8 (16 Jun 2011). Frank loaded bf.8. `Gezira-Nile` runs to bf.45 (10 Sep 2012). `packages.tsv` dates are UTC, `VERSIONS.txt` dates local, which explains INDEX.md's 2011-02-19 first date. The `Gezira` package (yo.1, 18 Feb 2011) holds an earlier `NileSqueakTranslator` in category `Gezira-Nile`; the later one is in `Gezira-Nile`.
- Authors: method stamps are the authors. `aw` (Warth) wrote most of `NileCTranslator` in 2009–2010 and `dja` (Amelang) edited it in 2010–2011. The Monticello initials in INDEX.md are who uploaded each version; `yo` versions are marked "From Moshi NNNN".
- Status: no Monticello version after 2012. The 2016 `gezira.nl` header cites damelang/nile at commit 8c76903 (2016-10-06). The maru port is the active copy; `nile_compile`, `nile_text_layout` and `nile_laws` check it.
- Reach for it when: you need the rendering formula or a stream form for numeric kernels. Read `gezira.nl` first.

## Family of expression

Nile belongs to the dataflow and stream family. TR-2011-004 calls it "a data flow stream language with functions at the nodes". Its neighbours in this vault share some forms and differ in others.

- KScript ([kscript](kscript.md); TR-2013-002): both are graphs of named nodes that carry state across steps. KScript streams are event-driven: a stream recomputes when its inputs change, and the prime mark reads the previous value (§3.2). In Nile the prime is assigned, so the next element sees the new value: `min' = min ◁ A ◁ B ◁ C` (gezira.nl:845). Same carried state, opposite direction in the syntax. Nile kernels run when a buffer of input arrives, not when a value changes.
- ForAll ([forall](forall.md); INDEX.md, "ForAll"): both have a per-element `∀` form over a collection. ForAll applies an action to the boxes a mask selects, as one operation over each column. A Nile `∀` runs once per stream element and can carry a value forward. The one link in these sources is ForAll-Base yo.2, which calls `GeziraBindings`' `primitiveTransformPoint`.

## Links

- [gezira](gezira.md)
- [kscript](kscript.md), [forall](forall.md)
- `nile/` (submodule): `compilers/prelude.nl` (operators and coercions), `compilers/maru/`, `runtimes/maru/` (`nile-kernel.k`, `nile-sync.k`).
- `gezira/nile/gezira.nl`: Gezira in Nile, 2016.
- `doc/nile.md`: the unit's notes.
