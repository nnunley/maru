
# Cooperating Languages (Samimi)

Cooperating Languages is a framework in the CooperatingLanguages package. It has a base language, `CoopLangs`, in which a problem is written as classes with attributes and constraints, with relations and quantifiers. The problem is then solved declaratively by a hosted solver or language, or imperatively by a program. Each hosted language is connected by two OMeta translators: one that turns the base problem into the host's input, and one that turns the host's output back into a model of objects and values, which is applied to the Squeak environment. The Phase One report (May 2012) lists Cassowary (linear real arithmetic), Kodkod (relational first-order, SAT-based) and Z3 (SMT) as hosted solvers, and the package has more since then: Datalog (LogicBlox), OCassowary (a Cassowary wrapper over object attributes), and an OMeta host.

## Why

No single solver handles every problem (STEPS 2012, TR-2012-001, p. 13). The report describes cooperating solvers: constraints are partitioned into regions, regions share variables, and a shared variable is read-only for all but one region. The same paper says the framework "generalizes" that to cooperating languages, so one program can be composed of an imperative part, a linear part, and a first-order part. The phase one report puts it as a base language that is declarative, with hosted solvers that solve it declaratively or imperatively. The bridge circuit is its example: Cassowary, Kodkod and Z3 solve "the same exact problem" from one model (RM-2012-002, Figs. 2 to 4).

## How

The model, from RM-2012-002 Fig. 2 (the report's own indentation is lost in the text):

```
class Node : Thing
    Attributes
        voltage : Real
        leads : Set ( Lead )
    Constraints
        sum ( leads . current ) = 0.0
```

Setting up a problem and hosting Cassowary, from `CoopLangCassowaryExamples>>openInspectorOnIncrementalAddition2`:

```
env := CoopLangs newProblem: '
var x, y : Real
'.
env eval: 'this.x = this.streamOf(10)'.
p1 := env hostProgram: '
y = x+5
x<=20
' in: #Cassowary modifiableVars: #(x y).
p1 setupIncrementalRun: #(x) strengths: {ClStrength strong}.
```

Datalog: `CoopLangDatalogExamples>>movableBoxes` declares a `relation Movable(a: Box)` with a recursive rule and runs it with `env resolveRelations: {#debug. true}`. `CoopLangs>>resolveRelations:` is a hosted run of `'true'` in `#Datalog`.

Dispatch and the hosted run: `CoopLang class>>selectSolver:` maps the language symbol to a solver class and is, in its comment, "the method to extend with new solvers". `CoopLang>>run` parses the program, executes it, parses the output, and `runAndCommit` applies the resulting model to the environment with `applyModel:to:`. `CoopLangExternal>>execute` writes the generated text through `echo` into the solver binary and reads its output. `CoopLangCassowary` does not use text: it adds constraints to a `ClSimplexSolver` with `autoSolve` off, then `solve`, and reads the variables back.

Adding a language, as RM-2012-002 lists it: write an OMeta parser that turns the base AST into the host's input; say how to run the host (a library, or a system call); write a second OMeta parser that applies the host's model to the base environment.

## When

- **Phase One.** RM-2012-002, Hesam Samimi, May 11 2012, with Alan Borning consulting. Its "Onwards" list names time-ticking examples, an objective Cassowary, and cost optimisation and soft constraints as next steps.
- **Package history.** The first version is hs.1 (6 Apr 2012); the server holds 134 versions to yo.134 (10 Oct 2013). The changelog records the first hosted solver (CoopLangCassowary, "incremental version of CoopLangs"), OCassowary with prioritised soft constraints, Datalog, and CoopLangSimpleSearch (tk, Dec 2012 to Apr 2013: Sudoku, pentominoes, Weasel). Class comments date CoopLangKodkod to AHB, 15 Aug 2012, and CoopLangZ3 to AHB, 14 Aug 2012.
- **ConstraintPOL.** ConstraintPOL-AHB.1 (23 Mar 2012) and AHB.2 (6 Apr 2012, "moved ConstraintPOL classes into CooperatingLanguages"). The ConstraintPOL source is empty.
- **Frank.** INDEX.md lists CooperatingLanguages-tk.133 (8 Apr 2013) as in the image. The server's yo.134 is later.
- **Status.** A research prototype. Solvers are external binaries: LogicBlox for Datalog (`/usr/local/bin/logicblox`), Kodkod through a kodkodi script, and Z3 through a symlink at `/usr/local/bin/z3`. The Datalog tests stub the binary with `#mockOutput`.
- **Reach for it** when a problem is best stated as relations and constraints, and one of the hosted solvers fits its kind: linear real (Cassowary), finite relational (Kodkod), SMT (Z3). It is not a general planner.

## Family of expression

Cooperating Languages belongs to the family of declarative problem statements with pluggable solvers. JOHN has the same aim: a problem stated as goals and actions, solved by a search or, with `set-opt planner sat`, by a SAT encoding (the language is RN-2008-003; the SAT encoding, `john-sat.l`, is a later Maru addition). In both, the statement stays fixed while the solver changes. The difference is that CooperatingLanguages hosts external solvers and maps results back into objects, while JOHN solves in its own evaluator. KScript shares the streams side: CooperatingLanguages runs over KSObjects, so a changed input re-runs what depends on it. Call by meaning (`meaning.l`) is not a solver, but it has the same discipline of holding each answer to what the model can check. Maru has one hosted-solver shape already: `john-sat.l` turns a JOHN problem into clauses, and `sat.irl` solves them with proofs. It has no multi-solver layer and no external binaries.

## Links

- [cassowary](cassowary.md): the linear solver that `CoopLangCassowary` hosts.
- [worlds](worlds.md): the undo-and-speculation mechanism the phase one report does not use.
- [JOHN](../john.md): JOHN, the nearest relative in intent.
- Maru: `john-sat.l` (JOHN goals encoded to SAT), `sat.irl` (CDCL solver), `cnf.l` (gates), `meaning.l`. The JOHN notes are `doc/john.md`.

## Sources

- Samimi, Cooperating Languages, Phase One Report, VPRI RM-2012-002, May 11 2012
- TR-2012-001, pp. 12-13: cooperating solvers and languages
- package CooperatingLanguages, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (CoopLangs, CoopLang, CoopLangCassowary, CoopLangExternal, CoopLangKodkod, CoopLangDatalog, CoopLangZ3, examples and tests)
- package CooperatingLanguages, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (yo.134 back to hs.1)
- package ConstraintPOL, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (ConstraintPOL-AHB.2)
- https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package CooperatingLanguages (extraction, 60 files)
