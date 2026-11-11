
# VPRI's Frank: the parts, by family of expression

Frank is the personal-computing system STEPS built in Squeak from 2009 to 2013 to see its small languages work together
(STEPS 2011 report, VPRI TR-2011-004: "Frank"—"to better understand how the POLs can work together"). Its code survives in two places: the
image Yoshiki Ohshima published (<https://tinlizzie.org/~ohshima/Frank-170908.zip>), whose changes file holds every class it
ran, and the Monticello repository it loaded from (<https://tinlizzie.org/updates/exploratory/packages/>, 63 packages,
2011–2014). This page sorts the
parts into the families STEPS hoped they would fall into, and links a one-page walkthrough of each: why it exists, how to use
it, when it was written and when to reach for it.

## The aim: families of expression, not a Tower of Babel

STEPS built many small "problem-oriented languages" (POLs), and knew the risk. The 2008 report names it (VPRI TR-2008-004):

> An important design criterion for making full use of "problem oriented languages" is to find ways to avoid the "Tower
> of Babel" problem of winding up with a system composed of many different languages which – although small – would be
> extremely difficult to learn and decipher. Our approach is to gradually seek an underlying style for these languages
> that will eventually wind them up looking very much like each other as at least a "family of expression". … Many of the
> experiments over the last few years use pattern-directed non-deterministic "discovery and transformation" coupled with
> constraint-solving as their central style of approach.

The 2007 report puts the same idea as an analysis: the "myriad of pattern-matching and transformation cases in all levels
of the system", from code generation to publish and subscribe to TCP to inference, "are all instances from the same
abstraction, which can be expressed very compactly" (VPRI TR-2007-008). And the 2011 report is candid that the bet wasn't
settled: many POLs against one general language, "There are no substantiations of this at present" (VPRI TR-2011-004).

Read against the code, Frank's parts fall into six families. Several parts sit in two.

## 1. Pattern-directed translation

One mechanism, a grammar whose rules match structure and build results, does parsing, compiling, optimizing and tree
rewriting alike.

- [ometa2](ometa2.md): Warth's OMeta in Squeak. Every other language here is defined in it: KScript's parser and
  compiler, ForAll, Silt's assembler, the Nile-to-C and Nile-to-Smalltalk translators, and OMeta itself.
- [forall](forall.md) and [silt](silt.md) are small worked cases: a grammar, a translator, a runtime.

## 2. Dataflow: streams and whole collections

Computation as values flowing through operators, written like the math, not as loops and callbacks.

- [nile](nile.md): kernels over streams (`∀`, `>>`, `→`); "runnable math".
- [gezira](gezira.md): 2-D rendering in Nile, a pipeline of kernels from Béziers to pixels.
- [kscript](kscript.md) and [kscript-streams](kscript-streams.md): event streams (functional reactive
  programming) in place of handlers; a field is a stream that recomputes when its sources fire.
- [forall](forall.md): data parallelism, an operation over a whole column of box properties under a mask.
- [j](j.md): Ohshima's 2014 J interpreter, array programming after Frank's work.

## 3. Constraints: say what, let a solver find how

A problem stated declaratively, with the solving left to a pluggable engine.

- [cassowary](cassowary.md): incremental linear constraints for layout.
- [cooperating-languages](cooperating-languages.md): Samimi's relational base language whose problems go to hosted solvers
  (Cassowary, Kodkod, Datalog, Z3). The same line continues in JOHN and call by meaning (VPRI RN-2008-003 (Samimi, JOHN),
  VPRI TR-2014-003).

## 4. Scoped, undoable state

- [worlds](worlds.md): Warth's worlds, first-class scopes of side effects that can be sprouted, tried and
  committed or dropped. Constraint solving uses them (Cassowary.Worlds), and from March 2012 to January 2013 every KSWorld
  object was a Worlds dictionary (`WIdentityDictionary`; [ksworld](ksworld.md)).

## 5. One object for everything

The same box model for a window, a slider, a page and a letter of text; and the same S-expression form for documents,
indices and copy-and-paste.

- [lobjects](lobjects.md): Lesserphic, boxes with announcements and installed handlers (2009–2013).
- [ksworld](ksworld.md): KSWorld, boxes as dictionaries of stream-valued slots, behaviour in KScript (2012–2013).
- [box-lineage](box-lineage.md): how the model moved through Kobjects, reLObjects and JObjects to KSWorld.
- [siss](siss.md): object graphs as S-expressions and a content-addressed store; KSWorld's `.pp` is its
  successor.

## 6. The machine floor

Where the high-level forms meet hardware without hand-written C (the 2007 report, its p. 6).

- [silt](silt.md): a typed register-machine assembly and emulator, Ohshima and Amelang, December 2012.
- [nile](nile.md): Warth's Nile-to-C translator, the route Gezira took to speed.

## What reading them together shows

- The families are real in the code, not just in the reports. OMeta is the one translation mechanism throughout; KScript's
  streams, Nile's kernels and ForAll's columns are three forms of the same dataflow idea; Worlds sits under both constraint
  solving and KSWorld's objects.
- They didn't converge into one notation. KScript, Nile and ForAll each kept its own syntax, and KScript itself has two
  syntax generations ([kscript](kscript.md)). The 2011 report's admission stands: the family is a shared style and
  shared machinery, not yet a shared language.
- For resurrecting Frank, the families say what to rebuild once rather than per language: a grammar engine (Maru's tpeg
  plays OMeta's part), one stream and dataflow runtime, one constraint interface, worlds, and one box model.

## Where the code is

- Frank's image: <https://tinlizzie.org/~ohshima/Frank-170908.zip> (`frank.image`, `frank.changes`, `SqueakV41.sources`).
  The KS classes as it ran them are `ksworld/` in this repository; `ksworld/README.md` says how they were recovered (each
  method the version the image's own source pointer names).
- The package repository: <https://tinlizzie.org/updates/exploratory/packages/>, 2,250 versions of 63 packages.
- The pages cite an extraction from these two, kept outside this repository: `INDEX.md` lists each of the 63 packages,
  its versions and authors, and whether Frank's image held it; `packages.tsv` and a package's `VERSIONS.txt` list its
  versions; `<Package>/source.st` is the source of a package's latest version in the package repository; and a class's own
  file (`GeziraBindings.st`, `Worlds/source.st` ...) is the class as the image ran it, recovered as `ksworld/` was.
  Each can be checked against the image or the repository above.
- The Maru reconstruction, this repository: `ksworld/`, and the unit docs `doc/ksworld.md`, `doc/nile.md`, `doc/john.md`,
  `doc/recover.md`, `doc/grammars.md`.

## Sources

- STEPS 2007 report, VPRI TR-2007-008
- STEPS 2008 report, VPRI TR-2008-004
- STEPS 2011 report, VPRI TR-2011-004
- STEPS final report, VPRI TR-2012-001
- https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip)
