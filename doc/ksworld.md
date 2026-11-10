# KScript and KSWorld

KScript's evaluator, KSWorld documents headless and in a window, KSWorld's own sources, text and rendering.

## Checks

- `kscript` (`check/kscript.l`): `kscript.g` (inheriting `cexpr.g`) reads the 39 KScript listings
  transcribed from TR-2012-001, and `kscript.l` runs streams tick by tick, as the report says: a
  stream recomputes when a stream it depends on fires, a primed name isn't a dependency (so
  `nat <- 0 fby nat' + 1` never updates), and undefined keeps the value and stops the change. `set` fires its stream,
  as KSWorld's does, so what depends on it updates. `timerE` is the only source. Untyped, so it runs on `eval`, not
  through ir2. `anyE` and `switchColE` take the first item whose stream fired that tick, as KSWorld's do, so a menu
  reports the button just pressed; layout and rendering don't exist yet.
  Methods are defined per class (`ks-methods`: a KSWorld object's class, or `Number`, `String`, `Point` …), each a method of
  the class's type, and a send no method answers is an error naming class and selector; a KSWorld object's send sets or reads a
  field or entry it already has, but never makes one, which would hide a missing method. A field read on any other value (`ev.hand`) is a send with no arguments.
  A list (`[1, 2]`, a range, a comprehension) is a Maru array, as Smalltalk's Arrays are, indexed from 0; an empty one is a
  collection, true as a test, never nil. Truth is Maru's: true is `t`, false and nil are one value, `()`, as test-pepsi.l has
  them (`false := nil`), and `undefined` is neither; a stream saved with no value is undefined. Departures: false prints
  as `nil`, where Squeak printed `false`, and the symbol `t` (a Smalltalk `#t`, a document's Symbol `t`) is true.
- `ksworld_headless` (`check/ksworld.l`): `./eval ksworld-run.l DOC.pp [TICKS]` loads a KSWorld document (`ksworld-pp.l`), reads
  every stream's code (a setter's is a printout of the value the document already holds) and runs the evaluator tick by
  tick, each stream on its own, then reports what ran, fired and failed, and why. Our fixture `check/ksworld/tiny.pp`
  counts a timer's ticks and names the send nothing answers. With `MARU_DBJR` naming a copy of the dbjr documents laid out
  as tinlizzie.org/dbjr (`make check` fetches one into a fresh `mktemp -d` directory, removed after, unless `MARU_DBJR` is
  already set; third-party, so never in this tree) it runs `KSWorld.ks`:
  520 objects, 346 streams (281 setters), every stream's code read, and nothing it names missing: `KSTextLayout`'s
  `installSelection`, `handleButtonDown` and `handlePointerMotion` are class methods, which documents don't keep, and
  `ksworld-events.l`'s stand in for KSWorld's own (KScript, in `ksworld/KSTextLayout.st`). Named but missing is a failure;
  unset, it says it skipped them.
  `ksworld-render.l`'s `(ksworld-render box gezira width height)` draws a document with whatever Gezira it's given: walking
  the box tree (`backgroundParts`, `contents`, `parts`; a hidden box draws nothing), it asks `(gezira-fill-path gezira matrix
  width height paint floats count)` of each shape's path, as its FloatArray holds it, placed by the matrix composed from every
  transformation above it. The geometry is Gezira's, in Nile. `gezira-library.l`'s Gezira is libgezira and libnile
  (`libgezira.k`, `libnile.k`: a `TransformBeziers`, `ClipBeziers`, `Rasterize`, composite pipeline); Gezira compiled into the
  image would answer the same message, so neither need be a library. Matrices are Gezira's (x' = a x + c y + e); a
  document's `MatrixTransform2x3`, and KScript's `M(...)`, name Squeak's rows, read once into those fields. The check asks
  a recording Gezira: the fixture's one path, matrix and paint, and KSWorld.ks's 7 paths before its text, which is kept as
  `span` records (string, font, fill, size) to be laid out with TrueType glyphs.
  `truetype.l` reads a TrueType font (tables by offset, `cmap` format 4, simple and composite glyphs) to a glyph's
  quadratic Béziers in whole font units, a straight segment as start, start, end and an implied point rounded down, as
  KSWorld wrote its own: each character box KSWorld.ks kept (Times New Roman, plain and bold, a face's style being bits,
  `ksworld-pp.l`'s `define-flags`) is identical to what it reads from this system's Times New Roman, where macOS has it.
  `ksworld-text.l` lays a text box's spans out as KSWorld did (its KSTextLayout's margins, justification, tab stops and
  wrapping; lines ascent plus descent plus 2 apart; a centred line's width adding its first glyph's left bearing), and
  `ksworld-render.l` draws each character's outline after the box's shape: each of KSWorld.ks's five text boxes puts the
  character KSWorld left laid out (its last line's first) where KSWorld did, and the document draws 937 paths (the three
  carets it kept showing among them).
  Fonts are found as a browser finds them: a family falls through to its alternatives, its generic family (`serif`,
  `sans-serif`) and a last resort (DejaVu Sans, which `fetch-dbjr` fetches), and a character a font lacks to the next
  font with a glyph for it. `truetype.l` reads a TrueType Collection's faces by full name, so Palatino Linotype is macOS's
  `Palatino.ttc`, with its own metrics: of the front page's text boxes, those in Times New Roman and DejaVu Sans are where
  KSWorld put them, 411's tab stops among them (measured from the box's edge, the pen starting at the line's first
  glyph's left bearing). An emphasis other than bold and italic is an error.
- `ksworld_sources` (`check/ksworld-sources.l`, plan `doc/plans/2026-11-07-ksworld-keys.md`): KSWorld's own code runs from its
  sources (`ksworld/*.st`): `st-fileout.g` reads Squeak's file-out (each class's definition, its instance and class sides),
  `kscript.g` its KScript methods (with `+=`, `-=`, `#'symbols'` and stream expressions), and `squeak.g` (after `test-pepsi.l`'s
  grammar) its Smalltalk ones to the same trees, so neither is transliterated by hand; `ksworld-source.l` makes each a method
  of its class. A selector is named as KSCompiler named it (`at:put:` is `_at_put`; a KScript method with parameters is its
  keyword selector, and KScript's `rec.abc(a, b)` reaches `abc:with:`), `self` is `this`, an instance variable a field of it,
  and a Smalltalk method answers `self` without `^`, whose `^` leaves it from a block too (`catch.l`). A class is a Maru type
  (`st-classes.l`, boot.l's `define-structure` and `define-class`) under its superclass's type, a message a Maru selector
  (`#name`) with a method per class's type and Object's methods as its default, there being no root type, and a class object
  an instance of its metaclass type, under its superclass's metaclass, for class sides. Maru's values are instances of
  fieldless classes over their types (Number over `<long>` and `<double>`, String over `<string>` and `<symbol>`, Array,
  UndefinedObject …), and a Maru type's base is only ever such a class, so no selector of Maru's own reaches another Maru
  type. Instance variables are fields, the superclass's first; a Dictionary's include `slots`, its table; a document's Array
  is a Maru array, and its attributes (`:ref`, `:__type__` …) are table entries. A class whose type was made (a document met
  it) with other instance variables is refused, never given a second layout. An unknown form is an error, never a quiet
  nil. Under KSWorld's classes is `squeak-base.st`, the platform in `test-pepsi.l`'s form (its hierarchy, `{ }`
  primitives, methods answering their last value), with Squeak's meanings where pepsi's differ (Arrays count from 1), Maru's
  booleans (`t`, and `()` for false and nil alike: false answers as nil does), and a KSWorld object an IdentityDictionary of its slots:
  a dictionary's entries are a `hash.l` table, by identity, or by Maru's `equal` for a Dictionary (and its subclasses: an array key
  by its elements, a point by x and y, as Squeak's `=` has them), so one set of
  Dictionary methods serves both, and a Set or IdentitySet keeps its members as a table's keys, in the order added. Every KScript method of KSTextLayout and
  every Smalltalk method of KSContentsCollection and KSBox reads, and a KSContentsCollection is made, grown and edited by its
  own Smalltalk. A text box's letters are letter boxes, as KSWorld read the spans it wrote (`ksworld-pp.l`), checked in
  `ksworld_headless` against the five letters KSWorld kept.
- `ksworld_mouse` (`check/ksworld-mouse.l`): `ksworld-events.l`'s `(ksworld-pointer session kind point)` delivers a press,
  motion or release at a document point to KSWorld.ks's running streams (`ksworld-session` continues what `ksworld-run`
  left), headless: a press goes to the topmost box under it with a `buttonDown` (through the inverse of the matrices the
  renderer composes), a motion or release to the box the hand holds if that stream is awake, then one tick runs. The
  handlers are ours, written before KSWorld's own turned up in `ksworld/KSTextLayout.st`: a press puts the caret at the nearest gap, wakes `buttonUp` and `pointerMotion` and has the hand hold
  the box; a drag selects from the press; a release, by the document's own stream, puts them back to sleep. A selection is
  an Interval of gaps, `(from to: to + 1)`, as every one the documents kept is one wide, and the redraw asks the Gezira for
  it in the layout's `selectionColor` under the text.
- `ksworld_window` (`check/ksworld-window.l`): `ksworld-window.l` puts a running document in an SDL3 window through `sdl3.l`
  (SDL3 for untyped Maru, through `subr`, with `sdl3.osdefs.k`'s constants and offsets; the library is the first of
  `*sdl3-libraries*` that opens). Each `(ksworld-window-step win)` reads SDL's events, hands button 1's presses and
  releases and every motion to `ksworld-pointer` (window points are document points), and draws a frame when one reached a
  box, or first: it clears the Gezira, renders the document and shows `(gezira-image gezira)`, width x height ARGB pixels a
  painting Gezira answers. Escape or a quit stops it. On the dummy driver the check queues a press, a drag and a release as
  the window system would, and each reaches KSWorld.ks's title and draws a frame; its Gezira counts paths and paints
  nothing, so pixels wait on a Gezira that paints (GeziraImage). Where `pkg-config` finds no SDL3 it prints `SKIP`.
- `ksworld_clock` (`check/ksworld-clock.l`): a document in a window runs as it runs on its own. After its start-up evaluation
  (time 0), logical time is the window's clock in milliseconds from when it started (`SDL_GetTicks`, or any clock put in
  its `clock` field), each step evaluates what is due then, an event happens no earlier than the clock says, and a step in
  which something fired draws a frame. `timerE(n)` fires when time passes a multiple of n since the evaluator's last
  evaluation, once however many it passed, n whole or fractional (headless, with whole ticks, that's every nth tick, as
  before); time evaluated again passes nothing. In a window an event takes 1/1024 of a millisecond, so events keep their
  order without running ahead of the clock (headless they take a whole tick). A stream that fails is reported once and
  the rest run on. Our fixture `check/ksworld/tiny.pp` in a window on the dummy driver: with the clock held still nothing
  runs or draws; seven milliseconds on, its timer fires once and one frame is drawn; fifty presses with the clock held
  neither fire it nor leave the millisecond, nor do 2100 more (each event moves 1/1024 of the way to the next
  millisecond); its failing stream is reported once. An evaluator's time only moves forward: evaluating a time again, or an
  earlier one, is refused. `check/ksworld/timer.pp`'s timerE(1000)
  and timerE(2.5), read at times that skip their multiples, fire as time passes them. `ksworld-show.l` runs only the
  start-up evaluation before the window, then the clock.
- `gezira_image_fill` (`check/gezira-image-fill.l`): an image as a Gezira paint, `(image pixels width height matrix filter)`,
  as KSWorld's `GeziraFillImage` paints one (its `pipelineOn:for:`, in Frank's GeziraBindings): the canvas's inverse
  matrix, then `ReadFromImage_ARGB32` (typed Maru beside the writer, `gezira-image.k`), unfiltered for a whole-pixel
  translation, else mipmapped (GeziraBindings' `downsample`, each level cached on the form) while the minification passes
  2, 4 … and filtered bilinearly. A translation copies a small image exactly, a uniform image stays uniform downsampled and
  filtered, and premultiplying rounds as the writer does, on 1 and 4 workers. `ksworld-render.l` reads a Form's PNG from
  beside its document (`ksworld-pp.l` keeps the path) and premultiplies it once. With `MARU_DBJR` the front page's
  photograph, rendered with the rest of the page, matches what its pipeline gives worked out from the PNG's pixels (the
  downsampled texel, then the bilinear filter, then the writer's rounding) at 98 of 100 grid points, none off by more than 1.

Not yet described here (each has a comment above it in `check/check.l`): `ksworld_pixels`, `ksworld_rerender`, `ometa2`.
