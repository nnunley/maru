
# LObjects: Lesserphic's box model

LObjects is the Squeak package that held Lesserphic's graphical model: `LObject`, the base of objects that announce and receive events; `LBox`, the one class for windows, buttons, menus, text letters and document pages; `LShape`, which says how a box looks; `LWindow`, the top box of a world; and `LWorldState`, the per-window state (hand, halo, menu, clipboard, alarms). Input events and changes are both announcements. A box re-announces what it receives to its components, and a handler is an object installed in a box that listens for announcement classes. Shapes are Gezira fills and paths.

## Why

The 2008 STEPS report names Lesserphic as "an experimental GUI framework" built around "behaviors", separate sets of methods and state a graphical object can carry (TR-2008-004). The 2009 report describes LBox as "a viewing and events framework" and says the mechanism "unifies the user input event routing with all other typical change notifications" (TR-2009-016, section 5). The 2010 report puts LWorld under LBox: LWorld is the tools framework, and "the LBox framework is the graphical application framework on top of it" (TR-2010-004, section 2). DBJr and LDBJr, the document application in Frank, were written in it.

## How

**Make a box.** `LBox class>>extent:fill:` is `super new shape: (LBoxShape extent: aPoint fill: aFill)`, and `extent:color:` converts the colour with `asGeziraFill` (LObjects source, LBox class, instance creation). `LesserphicMorph class>>test16` is a short example that builds a box in a window:

```
w := LesserphicMorph new openInWorld.
a := LBox new.
w window add: a.
a topLeft: 100@100.
```

**Give it a shape.** `LBoxShape` holds `fill`, `color`, `extent`, `borderColor`, `borderWidth`, `cornerRadius`, and the shadow's fill, offset and blur. Arbitrary outlines use `LGenericShape` with `elements:`, which holds Gezira paths. `LBox class>>duplicateIcon` is one:

```
LGenericShape new elements: {GeziraPath rect: (1@1 corner: 19@19) radius: 3. ...}
```

**Put it in a container.** `LBox>>add:` appends to `contents`, calls `layoutChanged`, and announces `LBoxContentsAdded`. Menus and handles go in `parts` (drawn in front) or `backgroundParts` (drawn behind), through `addAsParts:` and `addAsBackgroundParts:`. A layout is a component: `LBox>>layout:` calls `installTo:`, and `LObject>>install:as:` runs `layoutChanged` for the name `#Layout`. `box layout: (LHorizontalLayout new wrap: true)` appears in the source.

**React to events.** A handler is a subclass of `LEventHandler` (its `listensTo` names the event classes; `buttonDown:with:`, `click:with:`, `motion:with:` and so on are its methods) or `LUserEventHandler` (a target, a selector, modifier masks). `installTo:` puts the handler in the box as a named component (`install:as:`), and that subscribes it to each class in its `listensTo` (`on:to:`). Two examples from the source:

```
h := LStepHandler new target: a; selector: #translateBy:; arguments: {1@0}.
h installTo: a.                                  "LesserphicMorph test16"

(LButtonHandler withTarget: crd withSelector: #showInbox) installTo: but.
```

Routing is in `LBox>>receive:from:`. A keyboard event goes to the box holding keyboard focus. A mouse event is announced to the contents of each box that contains its point. Each box then re-announces it to its own subscribers (`super receive:from:`). If nothing handled it and the point is inside, the box offers itself as the default handler (`defaultHandlerWith:`).

**Lay out text.** `LBox>>addTextContents:` is "Convert an ascii string to be in my contents as LBoxes with letter glyphs". Each letter is a box. `LBox class>>newTextField:font:extent:color:` makes a text field with `LWordWrapLayoutF`. `LWordWrapLayoutNile` (tk, 2011-11-11) "uses Nile and Gezira in Smalltalk to compute the (x,y) of each letter" (VERSIONS, LObjects-tk.385).

**The window and its state.** `LWindow` is an `LBox` subclass with a `worldState` field. `LWindow class>>new` is `^ self basicNew initialize`. `LWorldState` holds `hand`, `halo`, `menu`, `clipboard`, `mode`, `damageRecorder` and `alarms`. `processActions` runs the alarms, then `announceAllValueChangesAt:` on the value announcers. A `LesserphicMorph` (a `RectangleMorph`) hosts the window in Morphic.

## When

- Lesserphic is named in the 2008 report (TR-2008-004), which refers to the "Lessphic UI project reported last year". The 2007 report as extracted in STEPS 2007 report, VPRI TR-2007-008 does not name it, so the brief's 2007 start is not supported by the sources I read. LBox is named in the 2009 report. The method stamps in `source.st` run from 2008 (131 with a 2008 stamp) and are dense from 2009 (668), so the title's 2009 start is the bulk of the code, not its first stamp.
- The Monticello history runs from `LObjects-bf.1`, "initial commit", on 2011-01-11 to `LObjects-bf.606` on 2013-10-22: 599 versions. INDEX.md gives the three main authors (yo 301, bf 145, tk 72), not totals.
- Frank loaded `LObjects-bf.595` (2013-02-21). The server has later versions, to bf.606.
- Status: active through 2013. Recent changes include the ODF reader and an Etoys launch hook (bf.597). For new box work, KSWorld (see [ksworld](ksworld.md)) is the successor. Read LObjects for DBJr and LDBJr, SISS serialization, the ODF reader, and the 2009-2012 widgets. Read [box-lineage](box-lineage.md) for the packages between the two.

## Family of expression

- **One box for everything.** Windows, buttons, the world menu (`LBox class>>addWorldMenuTo:`), text letters, and document pages are all `LBox`. KSWorld keeps the same rule (see [ksworld](ksworld.md)).
- **Announcements as the one event path.** Input events are `LUserEvent` subclasses (`LButtonDownEvent`, `LKeyStrokeEvent`, `LMotionEvent`), and value and geometry changes are `LValueChanged` and `LGeometryChanged`. Both use the same `announce:` and `receive:from:`.
- **Dataflow.** `LObject` has a `frp scripting` category (`formulaAt:`, `evaluateFormulaeAt:`, `sortedFormulae`). Kobjects-yo.43, "FRP stuff migrated to LObjects" (2012-01-25), moved that code from Kobjects into LObjects. KScript later carried the same model.
- **Gezira and Nile.** Shapes are Gezira fills and paths (TR-2010-004, section 2). `LWordWrapLayoutNile` puts letters with Nile and Gezira.
- **SISS.** `LObject class>>sissClassVarsInto:`, `LBox>>saveOnFile`, `LBox>>saveSVG`, and `LBoxShape>>writePDF:` serialize and export boxes.
- **Worlds.** `LWorldState` keeps alarms and a pseudo time (`is:past:`; yo.437, 2012-04-09, "Make LWorld runs in pseudo time"); that is LWorld, Lesserphic's own framework, not Warth's. The Worlds package is used in `LPaintTool`, a paint tool with world boxes. Its `newWorld` is `currentWorldBox := self newWorldBoxFor: self currentWorld sprout`, and its `initialize` starts from `Processor activeProcess currentWWorld` (`WWorld` is the Worlds package's class, [worlds](worlds.md)). LObjects-tk.376 (2011-11-02) says "New Word Wrap demo. It uses preend worlds." The `LesserphicMorph` browser lists the `Worlds` and `Worlds2` categories with the LObjects ones. I did not find LObjects using `Worlds2`'s `WWorld2` classes.

## Links

- [ksworld](ksworld.md): the KScript successor, KSObjects.
- [box-lineage](box-lineage.md): Kobjects, reLObjects and JObjects between the two.
- [worlds](worlds.md): Warth's Worlds.
- Maru (this repository): the tree has no LObjects reader. LObjects appears there only in `doc/plans/2026-11-03-frank-on-macos-then-qemu.md`. The KSWorld reader is `ksworld-pp.l`, `ksworld-source.l` and `st-classes.l` (see the KSWorld page).

## Sources

- package LObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (LObjects-bf.606: LObject, LBox, LShape, LBoxShape, LWindow, LWorldState, LAnnouncement, LEventHandler, LesserphicMorph examples)
- package LObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (version record, 2011-01-11 to 2013-10-22)
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package LObjects (Frank's extraction, LObjects-bf.595)
- TR-2008-004: Lesserphic
- TR-2009-016, section 5: the LBox model
- TR-2010-004, section 2: LWorld and LBox
- https://tinlizzie.org/updates/exploratory/packages/
