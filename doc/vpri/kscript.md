
# KScript: the language

**Summary.** KScript is Ohshima's dynamic, indentation-sensitive language for KSWorld. Its surface resembles CoffeeScript. Values live in KSObjects, which are dictionaries of named slots, and a slot can hold an event stream in place of a value. Squeak's compiler reads KScript method text through OMeta2 grammars (`KSParser`, `KSParser2`) and a chain of tree passes that emit ordinary Smalltalk. KScript methods therefore become Smalltalk methods, and stream definitions become `KSNewEventStream` objects (see [kscript-streams](kscript-streams.md)). The Squeak sources hold two syntax generations. This page labels each form with its generation.

## Why

KSWorld's stated goal is "an understandable, concise way to specify an application's behavior and appearance, minimizing extra details that arise only because of the medium being used" (TR-2013-002, abstract). The language exists so that a widget's slots are reactive variables that can be redefined in place (abstract). The design drops the usual marker for fields. Temporaries must be declared with `var`, and bare names resolve to fields of the receiver (§2.1). Blocks are nested by the offside rule. The paper notes CoffeeScript's `->` versus `=>` split and says KScript "simplified the language and eliminated such issues" (§2.1).

## How

Method in the v1 syntax, a KSObject method from KSObjects (2013):

```
eventStream = () ->
	return this.class().eventStreamClass().of(undefined)
```

`KSObject>>eventStream` (KSObjects, category 'frp', yo 3/14/2013). The `name = (args) ->` header is the v1 form. The v2 form uses `:=`, as in the paper's `aFunction := (a) -> ...` (§2.1).

A stream definition, from the paper (§2.2), in the v2 syntax:

```
myTimer <- timerE(200)
fractionalPart <- myTimer % 1000
```

A v1 method that creates a stream, from `KSScriptor>>behavior` (KSObjects, yo 10/8/2013):

```
this.timer = $$(timerE(1000))
```

Here `$$(...)` marks an expression to be turned into a stream. v1 has no `<-` form, and v2 uses `<-` for the same job.

Compilation path. `KSProtoObject class>>compilerClass` answers `KSSqueakCompiler`, and `parserClass` answers `KSSqueakParser` (both KScript, yo 7/12/2012). `KSSqueakCompiler>>compile:in:classified:notifying:ifFail:` tries `KSParser2 isKScript2` (the `name := (args)` header) first, then `KSParser isKScript` (`name = (args)`). It rewrites the text with `compileMethodToString2:forClass:` or `compileMethodToString:forClass:`, then hands the result to the Smalltalk compiler. The v2 chain is KSParser2, KSDeclVisitor, KSVariableAttributor2, KSQuoteAttributor2, KSQuoteTranslator2, KSReturnVisitor2, KSBlockSimplifier, KSCompiler, and OMeta2Flattener. The v1 chain (KSParser, KSQuoteAttributor, KSQuoteTranslator, KSDeclVisitor, KSReturnVisitor, KSBlockSimplifier, KSCompiler, OMeta2Flattener) has no variable-attribution pass.

`KSSqueakParser>>parseSelector:` (ael, 2/25/2013) turns the header into a Smalltalk selector. It reads `name = (a, b)` with `KSParser`'s `nameAndArgsAndDiscardRest`, and answers `name:with:`, adding one `with:` per argument after the first. The method only matches the v1 `=` header. It predates `KSParser2`, so a `:=` header is not handled there. I did not run it, so I do not know how a browser treats a `:=` method.

Syntax, by generation (from the grammar rules):

| Form | v1 (`KSParser`, 2012) | v2 (`KSParser2`, from 2013) |
|---|---|---|
| method | `name = (args) ->` | `name := (args) ->` |
| stream definition | `$$(expr)` in an expression | `name <- expr` (rule `expr`, desugared to `#sets` of a `$$` call) |
| reference to a stream | `@name`, `@name'` (rule `atAccess`) | bare `name`, `name'` |
| initial value | `init fby next at|on tick` | `init fby next on tick` |
| response | none; `mapE` and `doE` are called as methods (`when` is only in comprehensions) | `when t: n then e` (mapE), `when t then e` (doE) |

KScript's `kscript.g` in maru reads both `@x` and bare names, and both `=` and `:=`. It has no method-definition rule, so `name = (args) -> body` parses there as an assignment of a function value. In maru a method is a slot holding a closure (`ks-send` in `kscript.l`). Built-in methods are registered from Lisp with `ks-methods`.

## When

- **Dates.** The KScript package runs from 2012-03-07 (INDEX.md) to KScript-yo.120 (2013-10-24). It has 119 versions: yo 103, ael 14, bf 2 (VERSIONS.txt). `KSParser2`'s initialiser is stamped 3/29/2013. The v2 `fby ... on` syntax arrived with KScript-yo.115 (2013-09-06, "Change the syntax of fby."). `when` parsing was fixed in yo.116, `strmDefs` (bulk redefinition of streams) added in yo.118 (2013-10-07), and `delete` fixed in yo.119 and yo.120.
- **Frank.** The image loaded KScript-yo.115. Its `KSParser2.st` has the v2 `fby ... on` form, and `when`/`delete` rules. It does not have the `strmDefs` rule (yo.118).
- **Status.** Current in the Squeak sources. KSWorld's own methods are mostly v1 (`ksworld/README.md`), and the maru copy under `ksworld/` holds those classes.
- **When to reach for it.** To read or change KSWorld's methods, use v1. To write new code in the paper's style, use v2. Fall back to the paper for semantics.

## Family of expression

The paper places KScript in the family of time-aware dataflow over slots. It calls the language "a dynamic language based on the declarative and time-aware dataflow-style execution model of Functional Reactive Programming" (abstract). The STEPS 2012 report makes the same family point for Nile, whose graphics code "consists of functional elements connected by dataflow streams" (steps-2012-final-report, near line 869).

I could not find the phrase "families of expression" in the sources read for this page. The closest text is the STEPS 2012 passage that DSLs "need a clean, well-defined way to interact with each other" (around lines 939-947).

What KScript shares with its neighbours:

- **Nile.** Dataflow between functional elements. The page on streams gives the mechanism.
- **Cassowary.** The paper calls FRP "an equality-based, uni-directional constraint solver" (related work). KSWorld's layout uses Cassowary (see [cassowary](cassowary.md)).
- **ForAll.** INDEX.md describes ForAll as one guarded statement applied to every box it selects. KScript's `anyE` takes a new value from any element of a collection (paper §2.4.4). Both work over collections; they are not the same mechanism.
- **Worlds.** The paper does not mention Warth's Worlds. The only link found is that both were loaded into Frank (INDEX.md; see [worlds](worlds.md)).

## Links

- [kscript-streams](kscript-streams.md): `KSNewEventStream`, combinators, dependency tracking, and the maru evaluator.
- [cassowary](cassowary.md), [worlds](worlds.md).
- Maru repository (this repository): `kscript.g` (grammar), `kscript.l` (runtime and evaluator), `check/kscript.l` (the TR-2012-001 listings, run by `check/check.l`), `ksworld-run.l` and `ksworld-events.l` (headless runs and events), `ksworld/README.md` (the KS source), `doc/plans/2026-11-07-ksworld-keys.md`, and the unit's notes `doc/ksworld.md`.

## Sources

- package KScript, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package KScript (the Frank image's extraction, KScript-yo.115: KSParser2.st, KSSqueakCompiler.st)
- package KSObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/ (KSObject 'frp' methods, KSScriptor>>behavior)
- Ohshima, Lunzer, Freudenberg, Kaehler, TR-2013-002, sections 2.1-2.3, 3.2, related work
- TR-2012-001, the Nile example near line 869
- `ksworld/README.md, kscript.g, kscript.l, check/kscript.l` in this repository
