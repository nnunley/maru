
# KSWorld and KSObjects: KScript's box model

KSWorld is the GUI framework written in KScript. KSObjects is its package of classes: `KSBox`, `KSShape`, the layouts, `KSTextLayout`, `KSWorldState`, the document editor. Every KS object is a dictionary (`KSProtoObject` is an `IdentityDictionary` subclass). A box's slots, such as `transformation`, `extent`, `bounds`, `shape`, `layout` and `visible`, are event streams: reactive variables. An event enters a document as a stream named after its type, such as `buttonDown`. Each display cycle evaluates the streams, lays out the boxes, and draws. A document is a `.pp` file, a PushPull serialization of the object graph.

## Why

KSonward says the goal is to reduce "accidental complexity in GUI framework code" and to make "an understandable, concise way to specify an application's behavior and appearance" (TR-2013-002, abstract). STEPS 2012 gives the scale: KScript and KSWorld replaced "50,000+ lines of Smalltalk" used as Frank's scaffold with "about 10,000 lines" (TR-2012-001). A slot is a reactive variable, so one object's definition can be changed or added in place, then refined with direct manipulation (TR-2013-002, section 1).

## How

**Make a box.** `KSBox` is a `KSObject`. Its `initialize` makes most slots streams:

```
this.transformation = this.streamOf(MatrixTransform2x3.identity())
this.extent = this.streamOf(P(50, 40))
this.bounds = this.streamOf(P(0, 0).corner(P(50, 40)))
this.shape = this.streamOf(KSShape._extent_fill(@extent, Color.random().alpha(0.7)))
```

(KSBox, `initialize`.) `_extent_fill` is KSCompiler's name for the selector `extent:fill:`, as `at:put:` is `_at_put` (`ksworld-source.l`). The document editor makes its main panel the same way: `var box = this.mainViewBox = KSBox._extent_fill(P(200,300), Color.gray())` (KSDocEditor).

**Give it a shape.** `KSShape` holds `elements` (Gezira paths), a `fill`, a border, a shadow, and `isRectangle`. `KSShape>>extent:fill:` sets `elements` to one rectangle path with that fill. A custom outline is `box shape: (KSShape new elements: {path})`, from `KSODFDocument>>renderDrawCustomShape:` (KSObjects, source.st, `bf 1/21/2013`), which turns an ODF path into a box's shape.

**Put it in a container and lay it out.** `add` is `addLast` (KSBox, collection). A layout is a box's `layout`, and the top-level loop runs the layouts in a separate phase. A swatch row in the colour picker reads:

```
var layout = KSHorizontalLayout.new()
layout.space(4)
swatchHolder.layout(layout)
for i in [0 .. 10]
    swatchHolder.add(swatch)
```

(KSBox, colour picker.) The layouts are `KSBasicLayout`, `KSHorizontalLayout`, `KSVerticalLayout` and `KSLineLayout`. `KSLayout` is the abstract class, and `layOut` is `subclassResponsibility`.

**React to events.** A box declares a stream per event type, and the framework sets the event into the stream of the box that gets it (TR-2013-002, 4.3):

```
buttonDown <- eventStream()
myMover <- when buttonDown then this.translateBy(P(10, 0))
```

(KSonward, 4.3 and 4.4.) Routing is procedural. The box holding focus gets keyboard events. Otherwise the deepest box containing the point, with a stream of that event's name, gets the event. `KSBox>>receive` offers the event to contents and parts first, then to the box's own `announce`, then to `defaultHandlerWith`.

**Lay out text.** `KSBox>>ensureTextLayout` installs a `KSTextLayout` if the box has none. `KSTextLayout` is a `KSUserEventHandler`. Its `addAll` inserts characters with `insertChar` and adds boxes with `@whole.addLast(cc)` (KSTextLayout, replace text). Each character is a box: "we made even the individual characters in a text field be separate Boxes" (TR-2013-002, 4.1).

**A document is a `.pp`.** A `.pp` file lists objects with `:ref` numbers. Slots are `(slot :keyClass ... :keyValue ... :valueId ...)`, and a stream keeps its code as a string. From `check/ksworld/tiny.pp` in the Maru tree:

```
(KSEventStream :__code__ "timerE(1)" :__dormant__ "false" :__homeObject__ "1" :__type__ "exprE" :ref "2")
```

`PPParser` is in the `KSObjects-PushPull-Core` category. Its siblings `PPPuller`, `PPPusher`, `PPElement` and `PPTextNode` are the rest of the PushPull code in KSObjects.

**The loop.** Each cycle registers the events, builds the dependency graph from the display tree, evaluates the streams at the logical time, lays out the boxes, and draws. KSWorld runs at about 50 frames per second (TR-2013-002, 4.5).

## When

- KSObjects ran from 2012-03-13 to 2013-12-05: 682 versions. KScript ran from 2012-03-07 to 2013-10-24: 119 versions. INDEX.md gives the three main authors (KSObjects: yo 459, ael 136, tk 46; KScript: yo 103, ael 14, bf 2), not totals.
- The base class moved twice. On 2012-03-30 "KSProtoObject reparented to WIdentityDictionary" (KScript-yo.18), and `WIdentityDictionary` is the Worlds package's class (`Worlds/source.st`). On 2013-01-10 ael re-hung it: "re-hang KSProtoObject under IdentityDictionary" (KScript-ael.92), then "mostly removing WWorld dependencies" (ael.93). The current source reads `IdentityDictionary subclass: #KSProtoObject`. Before 2012 the lineage was K-prefixed (see [box-lineage](box-lineage.md)).
- Frank loaded KSObjects-yo.627 (2013-09-11). The server has yo.684 (2013-12-05).
- The paper is TR-2013-002, with the Onward! 2013 version, dated 2013/9/30 in its footer.
- Maru has a headless runner for `.pp` documents (`ksworld-run.l`), a window runner (`ksworld-window.l`), and the text and render code (`ksworld-text.l`, `ksworld-render.l`).
- Reach for KSWorld when writing a new widget or a document behaviour, or when reading a `.pp` file. Use [lobjects](lobjects.md) for the earlier model that DBJr and the ODF reader used.

## Family of expression

- **Dataflow and streams.** Slots are streams, and events are streams (KScript is FRP-style, TR-2013-002, section 2). The dependency graph and the sort are the evaluator's, which is the same family as Nile's stream processes and Gezira's pipelines.
- **One box for everything.** The document editor's tab bar, toolbar and scripting area are KSBoxes with layouts (KSDocEditor). Document pages are boxes too: `KSPageData` keeps `pageBoxes`, the boxes that go on one page (KSPageData, class comment). The letters of a text field are boxes.
- **Dictionaries.** `KSProtoObject` is an `IdentityDictionary` (KScript, source.st), after a 2012 spell under the Worlds package's `WIdentityDictionary`. The Maru port keeps the same rule: a send to a KSWorld object sets or reads a field or entry it already has, and never makes one ([doc/ksworld.md](../ksworld.md), on reading KScript). The `.pp` format writes the dictionary's slots by name.
- **Gezira.** A shape's `elements` are Gezira paths, and KSWorld draws them through Gezira (TR-2013-002, 4.2). The Maru renderer does the same (`ksworld-render.l`).
- **Worlds.** This is the closest link of the three. KScript's base was `WIdentityDictionary` from 2012-03-30 until ael removed the `WWorld` dependencies in 2013-01 (KScript-ael.93). KSObjects also calls `ksDoItWWorld`, which is nil "if this image doesn't even have Worlds", and has trace worlds (ael, KSObjects-ael.129, 2012-05-10). The Worlds package is [worlds](worlds.md). After 2013-01 the hooks are optional, and I did not find KSWorld's core depending on them.
- **Not SISS.** KSWorld's document format is PushPull (`.pp`), not SISS (which LObjects used).

## Links

- [lobjects](lobjects.md): the Lesserphic box model KSWorld replaced.
- [box-lineage](box-lineage.md): Kobjects, JObjects and reLObjects, 2011-2013.
- [worlds](worlds.md): Warth's Worlds.
- Maru, this repository: `ksworld-pp.l` (reads `.pp` into Maru objects), `ksworld-source.l` (reads KSWorld's own methods from `ksworld/*.st`), `st-classes.l` (Smalltalk classes as Maru types), `ksworld-text.l` (text layout), `ksworld-render.l` (draws a document with a Gezira), `ksworld-events.l` (pointer events), `ksworld-run.l` (headless run). The KSWorld notes are `doc/ksworld.md`, `ksworld/README.md` and `ksworld/INDEX.txt`.

## Sources

- package KSObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package KScript, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package KSObjects (KSBox.st, KSShape.st, KSTextLayout.st, KSDocEditor.st, KSWorldState.st, KSObject.st, PPParser.st; KSObjects-yo.627 as Frank loaded it)
- TR-2013-002, Ohshima, Lunzer, Freudenberg, Kaehler: sections 1, 3, 4.1 to 4.7
- TR-2012-001, KScript and KSWorld
- `ksworld/README.md and INDEX.txt (Frank's KS classes, as the Frank image last had them)` in this repository
