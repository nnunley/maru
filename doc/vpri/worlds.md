
# Worlds (Warth)

A world is a first-class object that records the reads and writes a computation makes to the program's objects. Code runs in a world with `eval:`. `sprout` makes a child world whose view starts as its parent's. `commit` copies a child's writes into its parent. A child's side effects are invisible outside it until it commits, and it can be dropped without committing. Five Squeak packages make up the work here: **Worlds** (ael, the working version), **Worlds2** (yo, bf, aw, the 2011 design that Worlds replaced), **WorldsExamples** (text layout), **WorldsPlugin** (a VM primitive for lookup and flattening, not in the Frank image), and **Cassowary.Worlds**, which runs the Cassowary solver in worlds.

## Why

Side effects are global. A try/catch unwinds the stack but does not undo writes, so speculation and tree-undo need hand-written command objects. Worlds reify the state a computation touches so the programmer chooses the scope of its effects (Warth et al. 2011, section 1). Unlike transactions, worlds are first-class values: they can be stored, passed and revisited, and they are not tied to a control structure.

The paper states two safety properties (section 2.2). "No surprises": once a child has read or written a slot, later changes to that slot in the parent do not show in the child. "Consistency": a commit that conflicts with the parent's changes is refused. In Worlds, `WWorld>>commitInto:` calls `assertCommitIsSerializableIn:` first and signals "commit aborted -- failed serializability check".

## How

Worlds/JS, from the paper (section 2.1):

```
A = thisWorld;
p = new Point(1, 2);
B = A.sprout();
in B { p.y = 3; }
C = A.sprout();
in C { p.y = 7; }
C.commit();
```

Squeak, from Cassowary.Worlds `CassowaryExperiments>>competingConstraintExperiments4`, which gives each edit weight its own world:

```
world := WWorld thisWorld sprout.
world eval: [
    solver addEditVar: m strength: ClStrength medium weight: wt.
    solver solve.
    solver beginEdit.
].
```

Backtracking: the OMeta ordered choice in the paper (section 7) sprouts a world per alternative and commits only the one that succeeds (`in thisWorld.sprout() { ... if (ok) thisWorld.commit(); }`). A failed alternative is dropped by not committing it. Worlds-ael's `WWorld>>commit` is `self eval: [ self commitInto: parent. self initializeTrackers ]`.

Implementation (paper section 5; Worlds source): a `WWorld` holds a weak-keyed table from each `WObject` to a reads record and a writes record. A slot read walks from the current world toward the top-level world and takes the first recorded value that is not "Don't Know". Records are created lazily. `WObject` instance-variable access is routed through the current world. Flattening (copying an object's effective state) defaults to a top-down, depth-first strategy (`WWorld class>>flattenBlockSize:`, value -1). `WWorld class>>runWithoutPlugin:` runs without the primitive (Worlds-ael.41). Worlds-ael.44 adds a `currentWWorld` instance variable to `Process`.

Worlds2 (yo) had the same idea with per-object orig and delta records, and `pEval:` returned proxies. Its usage comment: `w1 := Processor activeProcess currentWWorld sprout. myObj := w1 eval: [ WArray2 with: 1 with: 2 with: 3 ]`.

## When

- **Paper.** Warth, Ohshima, Kaehler, Kay, ECOOP 2011, TR-2011-001. It supersedes RN-2008-001 and TR-2010-001. Case studies: a bitmap editor with tree-undo (about a million slots per bitmap, section 6) and OMeta with worlds (section 7).
- **Worlds2.** bf.1 on 11 Jan 2011, yo through yo.17 on 7 Oct 2011, aw.9 in between. The server holds 16 versions. INDEX.md records yo.15 as the version in the Frank image.
- **Worlds (ael).** The change record runs from Worlds-ael.1 (3 Oct 2011) to .67 (24 May 2013). The server holds 23 of them, .45 (2 Feb 2012) onward. Worlds-ael.45's preamble unloads Worlds2 if it is present.
- **WorldsPlugin (ael.1 to .6, Oct to Nov 2011).** Primitive instance-variable lookup and flattening. Not in the Frank image (INDEX.md: "—").
- **WorldsExamples (ael.1 to .5, Jan to Feb 2012).** `WWorldyCompetitiveTextLayout` sprouts a world at each word break in the wrap zone and ranks the results.
- **Frank.** INDEX.md lists Worlds-ael.67 and Worlds2-yo.15 as in the image. The extracted Worlds classes (30 classes) include `WWorld`, `WObject`, `WIdentityDictionary`, and no `WWorld2` or `WObject2`, so the Worlds2 classes are not live in the extraction.
- **Status.** Research prototype. The Squeak code runs in Frank. Cassowary depends on it, and Worlds-ael's history includes KSObjects support (ael.52, ael.55).
- **Reach for it** when a computation must try alternatives and keep one, or undo a bounded series of writes, and all the state involved is `WObject`-based. Writes that go through Squeak primitives are not tracked. The paper's bitmap case needed flattening before the primitives could see the bitmap.

## Family of expression

Worlds belong to the family of undoable, possible-worlds state. The shared form is a chain of overlays on a common base: a child records only what it changed or read, commit pushes the overlay down, and discarding it drops the branch. Maru has the same shape in two places. `recover.l`'s `try` runs a body in a world backed by an undo log (`undo-commit`), and it has the same limit: raw memory, files and foreign state are not covered. JOHN's search (`john-eval.l`) is a tree of worlds, each action reading the world it starts in, with `set-opt merge-worlds yes` dropping a world whose state was seen before. `meaning.l` keeps each adapter in the world it was found in, so a failed branch takes its adapters with it. Worlds are the general mechanism; Maru uses the same idea in its undo, search and meaning code.

## Links

- [cassowary](cassowary.md): the solver whose variables live in worlds (Cassowary.Worlds).
- [cooperating-languages](cooperating-languages.md): the framework that runs solvers over a problem.
- [JOHN](../john.md): JOHN's possible worlds and time as a chain of worlds.
- Maru: `recover.l` (`try`, the undo-log world), `john-eval.l` (worlds, `merge-worlds`), `meaning.l` (adapters held in worlds). The notes are `doc/recover.md` and `doc/john.md`.

## Sources

- Warth, Ohshima, Kaehler, Kay, Worlds: Controlling the Scope of Side Effects, VPRI TR-2011-001; sections 2, 5, 6, 7
- package Worlds, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package Worlds2, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package WorldsExamples, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package WorldsPlugin, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (ael, WorldsPlugin-ael.6)
- package Cassowary.Worlds, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (CassowaryExperiments, ClDemoWindow)
- https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package Worlds
- VPRI TR-2008-003 (Warth, thesis) (ch. 4, Worlds)
