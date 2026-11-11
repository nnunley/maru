
# Gezira

Gezira is the STEPS 2-D vector renderer. Quadratic Bézier contours go in, pixel coverage spans come out, and a paint is composited into a Form. The rendering stages are Nile kernels (see [nile](nile.md)). Frank drew with it through `GeziraCanvas` and `GeziraBindings`: Smalltalk builds a command array, and a VM plugin runs the Nile-compiled code. The 2016 Nile source is in the maru tree.

## Why

Gezira's rasterizer computes exact pixel coverage from a formula, not supersampling. The 2007 report says the rasterization stage is "only 50 lines of code instead of the 500+ lines of code seen in similar libraries" (steps-2007, Gezira section; formula in Appendix G). It was meant to replace third-party rendering in IS: the 2008 report says it replaced Lively's SVG rendering. The 2010 report says Gezira "is used for all graphical operations in Frank", and that LBox shapes are drawn by building a Gezira pipeline per box.

## How

The stages, in the 2016 Nile source, are TransformBeziers (gezira.nl:819), ClipBeziers (823), Rasterize (555), a texture (`ApplyTexturer`, 427), and a compositor (`CompositeOver`, 681). `ApplyTexturer` chains them over a span stream:

```
ApplyTexturer (t:Texturer) : SpanCoverage >> (Color, PointCoverage)    (gezira.nl:427)
    → ExpandSpans () → DupZip (→ ExtractSamplePoints () → t,
                               → PassThrough ())
```

Frank's live path is `GeziraCanvas>>drawPath:`. The version Frank runs is in `GeziraBindings-Base.MT` (ael.70 overlays the Base classes), and it is the one in the Frank image's `GeziraCanvas`. Abridged:

```
drawPath: aPath
    | g |
    (g := deferredRenderer ifNil: [GeziraBindings new])
        appendKernels: (
            g pipeline: ({g funnel}),
                (stroke ifNil: [#()] ifNotNil: [stroke strokePipelineOn: g]),
                (clipAndTrans collect: [:each |
                    each isRectangle
                        ifTrue: [g clipBeziers: each]
                        ifFalse: [g transformBeziers: each]]),
                (fill renderOn: g target: target for: self));
        pour: aPath from: 1 to: aPath size final: true.
```

So the order is funnel, stroke expansion (in path space), clip or transform, then the fill. The 2016 source puts the transform before the clip and rasterize; the canvas puts a stroke before the transform. A fill renders itself. For an opaque uniform colour, `GeziraFillUniform>>renderOn:target:for:` (`GeziraFillUniform.st:93`) is:

```
^{ g rasterize.
    g compositeUniformColorCA: alpha cR: red cG: green cB: blue overImageARGB32: targetForm }
```

A canvas is used like this (`GeziraCanvas class>>example1`, Base):

```
f := Form extent: 500@500 depth: 32.
(GeziraCanvas on: f)
    color: (Color red alpha: 0.5);
    translateBy: 100@100;
    drawPath: self star.
```

`GeziraBindings.st:468-470` says the one primitive that invokes Gezira is `primExecuteThreads:memory:commands:`, in module `GeziraBindingsMT`. The Smalltalk side builds an array of `{#Kernel. #Name. args}` and `{#Pour. floats. start. end. final}` entries and `sync` sends it. The plugin is VM code, not image code: `GeziraBindingsMT-Plugin` is Slang, and its VERSIONS pins the Nile and Gezira git commits it was built from.

`Gezira-Nile`'s `GZBindings` is a second implementation of the same protocol, with the kernels compiled to Smalltalk. Its VERSIONS says it "works exactly like GeziraBindings" (bf.20) and later that it "makes GZBindings render Frank fully" (bf.24).

## When

- 2007: invented and tested (steps-2007). 2008: engineered for use (steps-2008).
- 2011: Gezira-Kernels-bf.17 (20 Oct 2011) and GeziraBindings-Base-bf.48 (30 Nov 2011), two of the versions Frank loaded. The `GeziraBindingsMT` class arrived in GeziraBindings-Base (bf.26, 15 Jun 2011). The MT default became five threads (Base.MT bf.47, 15 Nov 2011). TR-2011-004 reports nearly linear speedup per core, and nearly 30 times on a 40-core machine.
- 2012: Gezira-Nile-bf.45 (10 Sep 2012), the last Monticello version of the Smalltalk kernels.
- 2013: GeziraBindingsMT-Plugin-bf.25 (15 Mar 2013) is "Bindings 3.0: execute asynchronously". GeziraBindings-Base.MT-ael.70 (28 Mar 2013) is the newest bindings version and the one Frank loaded. TR-2013-002 counts Gezira Bindings at 2,330 lines of Squeak and calls it "semi-essential".
- 2016: `gezira.nl` is Gezira in the Nile dialect (damelang/nile, 8c76903, 2016-10-06).
- 2026: maru builds `gezira.dylib` from that source and runs `gezira_image` and `gezira_maru` checks (`gezira-maru.l`, `nile/runtimes/maru/gezira-image.k`).
- Reach for it when you need the rendering formula or a reference for the compositing modes. For a renderer in this tree, use `gezira-maru.l`.

## Family of expression

Gezira's stages are pointwise maps over streams of records: `Bezier` in, `SpanCoverage` and `Color` out, with compositors as functions `(A, B) → C` (`∀ (A, B)` in gezira.nl). That is the same per-element `∀` form ForAll uses over boxes (see [nile](nile.md)), with the stream carrying the data between stages.

The link to KScript ([kscript](kscript.md)) is at the Box, not the stream; the KSWorld side is in [ksworld](ksworld.md). A KSWorld box's shape holds the contour and its fill and stroke data, and each frame renders every box with Gezira (TR-2013-002 §4.2). KScript's event streams drive when a shape changes, and Gezira draws it when the next frame comes.

Source note: `gezira.nl:184` reads `(x1 + y1, x2 + y2)` in `u:Vector + v:Vector`, where the sum should be `(x1 + x2, y1 + y2)`. `Vector + Number` (line 188) calls it. I did not check whether any kernel reaches that path.

## Links

- [nile](nile.md)
- [ksworld](ksworld.md)
- `gezira/` (submodule): `nile/gezira.nl`, `c/gezira.c`.
- `gezira-library.l`: Gezira as libraries (libgezira, libnile), with a `gezira-fill-path` method over them.
- `gezira-maru.l`: the `build/gezira.dylib` selectors, `gezira-fill-path`, `gezira-pixel`.
- `nile/runtimes/maru/gezira-image.k`: the ARGB32 composite in typed Maru. It is under `nile/runtimes/`, not at the repo root.
- `ksworld-render.l`: calls `gezira-fill-path` for each KSWorld shape.
