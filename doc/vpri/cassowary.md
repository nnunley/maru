
# Cassowary: an incremental linear constraint solver in Squeak

Cassowary is an incremental solver for linear equality and inequality constraints over real variables. It keeps required constraints exact, and satisfies weaker ones as well as their strengths and weights allow. When a variable is edited, it re-solves cheaply rather than from scratch. The Frank README calls the code "Badros and Borning's solver, adapted". Here it is a Squeak class set: `ClSimplexSolver` (the tableau and its protocol), `ClVariable`, `ClLinearExpression`, `ClLinearEquation` and `ClLinearInequality`, `ClStrength`, and the edit and stay constraints. Four packages carry it: **Cassowary** (AHB.27, the kernel with demos), **Cassowary.Worlds** (AHB.34, the same kernel with worlds and the strength used by CooperatingLanguages), **LCassowary** (yo.21, a KScript handler), and **ConstraintPOL** (AHB.2, whose classes were moved into CooperatingLanguages and whose source is empty).

## Why

Layout and geometry are sets of linear relations that change under a drag: boxes that must not overlap, a quad whose corners stay on a line, a binary tree that re-centres. The demos in Cassowary (`ClBoxesDemo`, `ClBinaryTreeDemo`, `ClQuadDemo`, `ClSpacedBoxesDemo`) are of this kind. The solver is also the linear-arithmetic backend that CooperatingLanguages hosts (`CoopLangCassowary`). It has limits: reals only (CoopLangCassowary's `environment:` signals an error for other types), and linear constraints only.

## How

Required and weak constraints, from `ClCassowaryTestCase>>testAddDelete1`:

```
solver addConstraint: (x cnEqual: 100.0 strength: ClStrength weak).
c10 := x cnLEQ: 10.0.
c20 := x cnLEQ: 20.0.
solver addConstraint: c10; addConstraint: c20.    "x = 10"
solver removeConstraint: c10.                      "x rises to 20"
solver removeConstraint: c20.                      "x = 100, the weak constraint"
```

Expressions and multi-variable constraints, from `testAddDelete2`: `cxy := x*2 cnEqual: y.` Constraints are objects, so a removal needs the object that was added.

The edit protocol, from the comment on `ClSimplexSolver>>beginEdit`:

```
solver addEditVar: v1 strength: ClStrength strong.
solver solve.                 "needed only if autoSolve is false"
solver beginEdit.
solver suggestValue: v1 newValue: nv1.
solver resolve.
solver endEdit.
```

Strengths are `ClStrength required`, `strong`, `medium`, `weak`, and `addEditVar:strength:weight:` takes a weight (ael, 2012). `addConstraint:` refuses a required edit or stay (`ClError requiredEditOrStay`). In Cassowary.Worlds, `ClStrength class>>virtuallyRequired` is stronger than any user strength. A required edit is given it, and the caller checks afterwards that the variable reached its value, which is how CoopLangCassowary's `resolveAndCommit` does it.

Worlds: in Cassowary.Worlds the solver is ordinary code run inside worlds. `CassowaryExperiments>>competingConstraintExperiments4` gives each edit weight its own sprouted world, edits and solves there, and reports which edit states are reachable. `ClDemoWindow` keeps a stack of worlds, one per manipulation, and `mouseUp:` commits them into the top world (see [worlds](worlds.md)). Each `ClVariable` is a `WObjectWithCachedLookup`, so the Cassowary-AHB.27 kernel also needs the Worlds package.

## When

- **Kernel.** The stamps on the kernel methods are from 2001 (jcg, AHB). The Squeak port was filed out as Cassowary-ael.1 on 15 Nov 2011 ("Fileout from old Squeak image"). In March 2012, AB, yo and AHB made Cassowary-AB.22 through -AHB.27: unit tests replaced the experiments, and a `ClSimplexSolver` autoSolve test was added.
- **Cassowary.Worlds.** ael.14 (record date 7 Dec 2011; server upload 2 Feb 2012) to AHB.34 (27 Aug 2012). Relevant steps: AHB.30 (coercion between numbers and symbolic expressions, OTI and Squeak differ), AHB.32 (29 Jul 2012, `virtuallyRequired` for CooperatingLanguages' required edits), AHB.34 (demo fix: stay constraints can't be required).
- **LCassowary (AB.1 on the server from 23 Feb 2012; yo's versions to yo.21 on 2 Mar 2013).** `KSCassowaryHandler`, a KSUserEventHandler that installs Cassowary constraints on the boxes of a KSBox playfield. The maru repository holds the same handler as `ksworld/KSCassowaryHandler.st`.
- **Frank.** INDEX.md lists Cassowary-AHB.27 and Cassowary.Worlds-AHB.34 as in the image. The extracted `sources/Cassowary/` holds `virtuallyRequired` (added in AHB.32) and `sprout`, so the image runs the Cassowary.Worlds-era kernel.
- **Status.** Working, with unit tests (`ClCassowaryTestCase`, 15 methods in the extraction). It is the reference solver for the Cassowary-backed problems in CooperatingLanguages.
- **Reach for it** when a problem is linear over reals, changes by small edits, and needs a stated priority for each constraint. Nonlinear or integer problems need another solver (see [cooperating-languages](cooperating-languages.md)).

## Family of expression

Cassowary belongs to the family of constraints as declarative problem statements with pluggable solvers. The constraint is the statement; the solver is chosen to fit the constraint's kind. CooperatingLanguages makes that choice a language-level one: `CoopLang class>>selectSolver:` maps `#Cassowary`, `#OCassowary`, `#Kodkod`, `#Z3` and `#Datalog` to different hosts. Cassowary is also a streams-and-events system: LCassowary wires constraint variables to KScript streams. Maru has no linear-arithmetic solver; its nearest constraint machinery is SAT. `john-sat.l` encodes JOHN's planning problem as SAT clauses and `sat.irl` solves them, with `cnf.l` giving the gates. JOHN's own planner can also search (`set-opt planner`), which is a small instance of choosing a solver per problem. The VPRI sources give the reason in STEPS 2012 (TR-2012-001, p. 13): no single solver will serve all needs, so there must be a way for several to interoperate.

## Links

- [worlds](worlds.md): the worlds Cassowary.Worlds runs in.
- [cooperating-languages](cooperating-languages.md): hosts Cassowary, OCassowary, Kodkod, Z3 and Datalog.
- Maru: `john-sat.l` and `cnf.l` (constraint encoding to SAT), `sat.irl` (solver), `ksworld/KSCassowaryHandler.st` (the LCassowary handler in this repo).

## Sources

- package Cassowary, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package Cassowary.Worlds, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package LCassowary, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package ConstraintPOL, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (ConstraintPOL-AHB.2; source.st is empty)
- package CooperatingLanguages, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (CoopLangCassowary, CoopLangCassowaryExamples)
- https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package Cassowary (extraction; ClStrength.st, ClSimplexSolver.st)
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package README.md
- TR-2012-001, p. 13
