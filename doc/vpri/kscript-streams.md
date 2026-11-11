
# KScript streams: KSNewEventStream and dependency tracking

**Summary.** A KScript stream is an instance of `KSNewEventStream`, an `IdentityDictionary` subclass with 46 instance variables (current value, updater, source list, last time, and so on). A definition such as `x <- expr` compiles to a small graph. Each combinator call becomes a stream, sub-expressions are named `tt1`, `tt2`, and the top stream collects them. A bare name in a definition is a source, unless it is primed. A stream recomputes when a source's last-change time is later than its own check time. `KSDependencyEvaluator` sorts the streams topologically and evaluates them each tick. The first implementation, `KSEventStream`, was written in KScript itself; yo marked it obsolete in April 2013.

## Why

In the paper, a stream is a value that changes over time. An `undefined` result means "no new value" and stops propagation: "treats it not as a new value for the stream but as a signal for not propagating changes further" (TR-2013-002, §2.2). Evaluation is pull-based and runs on the display cycle (§2.5). Two problems in plain FRP drive the design. Circular dependencies appear in GUI code (a text field and its scroll bar), and a stream must refer to its previous value, as in turtle geometry (§3). The primed name `x'` answers both (§3.2).

The old class said why it was replaced: "This was written in KScript but for the performance reason this implementation was dropped in favor of the Squeak implementation called KSNewEventStream with real instance variables" (`KSEventStream` class comment, stamped yo 4/3/2013).

## How

The compiled form of a one-line definition is the clearest statement of the mechanism. This is the expected output in `KSQuoteTranslator2Test>>testAssignment` (KScript), for `foo <- timerE(100)`, reformatted across lines:

```
(self ksAssign: #foo with: ((true ifTrue: [
  pvtStrm := (KSNewEventStream ksNew: {}).
  (pvtStrm addSubExpression: #tt1 with: (self eventStream: #timerE with: 'timerE(100)' with: nil with: (OrderedCollection ksNew: {100}))).
  (pvtStrm finalizeTopLevelCreationWith2: (OrderedCollection ksNew: {}))]))))
```

`KSObject>>eventStream:with:with:with:` (KSObjects, 'frp') turns the selector into a combinator name, `timerE:with:with:with:`. It creates a new `KSNewEventStream` and performs that combinator on it. If the class cannot understand the name, it uses `exprE:with:with:with:`, the general message-send combinator. The no-argument `eventStream` (KScript, 'frp') makes a stream of `of(undefined)`, with no value.

Dependencies are stream references. `KSQuoteTranslator2>>fieldRef` turns a bare name into `KSEventStreamRef ref:`, or `refLast:` when primed. A chain after a stream (`a.b`) becomes a `getE` stream. `dependenciesFrom:` keeps the non-primed refs as sources:

```
dependenciesFrom: aCollection
	^ aCollection select: [:elem | elem isEventStreamRef and: [elem last ~~ true]]
```

(`KSNewEventStream>>dependenciesFrom:`, yo 4/3/2013.) That line is why `nat <- 0 fby nat' + 1` never updates: `nat'` is not a source. Maru's `check/kscript.l` asserts the same result, with `(0 0 0 0 0)` for five ticks.

Read time is `frpGet:`. It answers `lastValue` for a primed reference and `currentValue` otherwise. `lookup:` resolves the reference in the owning KSObject each time, which the paper calls loose coupling: "the actual stream to be bound to the variable is looked up in the owning KSObject each time the referenced sources are checked for updates" (§2.2).

Firing is by time. `basicShouldEventTrigger:` fires a stream when a source is "earlier", meaning `isEarlierThan:` answers true: the source's `lastTime` is `-1`, or later than the stream's `lastCheckTime`. Each tick, `KSDependencyEvaluator>>evaluateAt:` sets unset times to now, runs `maybeEvalAt:` over the sorted list, then `sync`s each stream, so `lastValue` takes `currentValue`. A stream's `updater` yields `undefined` to stop the change, and only a defined value sets `currentValue`.

Combinators. `KSNewEventStream` defines these, among others: `update:` (what `fby` compiles to), `setter`, `singleton`, `timerE`, `timerEDuration`, `mapE`, `doE`, `collectE`, `delayE`, `mergeE`, `anyE` and `switchColE`, `oneE`, `exprE`, `frpAnd`, `frpOr`, `frpIf`, `getE`, and the `M:` and `P:` constructors.

Assignment. `set:` changes a stream's value and time (§3.1). `KSObject>>ksAssign:with:` calls `set:` on an existing stream, and otherwise stores the new value in the slot.

## When

- **KSEventStream (old).** A `KSObject` subclass whose combinators are KScript methods, such as `M = (selector, code, extraDep, arguments) ->` and `basicShouldEventTrigger = (space, evaluator) ->` (KSObjects, yo 2012-2013). The inspector's evaluation uses `eval:` for version-1 streams and `eval2:` for version-2 (`KSEventStreamInspector>>eval:`, yo 9/6/2013).
- **KSNewEventStream (live).** The first commit is KSObjects-yo.388 (2013-01-24), whose message still says "A new version of KSEventStream that is written in Smalltalk." `KScript-bf.101` ("Enable KSNewEventStream", same day) switches the class: `KSProtoObject class>>eventStreamClass` answers `Smalltalk at: #KSNewEventStream` (bf, 1/24/2013). `PPPuller`'s class-name map sends saved `KSEventStream` objects to `KSNewEventStream` (yo, 2/7/2013), so old documents load as new streams.
- **Obsolete mark.** Comment stamp yo 4/3/2013 14:13. The class is still in the latest source and in the Frank extraction. The source does not remove it.
- **Frank.** The image loaded KSObjects-yo.627 (2013-09-11, "switchColE added"), which contains `KSNewEventStream>>switchColE:with:with:with:`. Frank's copy has both classes.
- **Status.** Current. The latest source is KSObjects-yo.684 (2013-12-05). The combinator set kept growing through 2013.

## Family of expression

KScript's streams are dataflow over named slots: the paper's "time-aware dataflow-style execution model" (abstract). Its neighbours are these.

- **Nile.** The STEPS 2012 report describes Nile's graphics code as "functional elements connected by dataflow streams" (steps-2012-final-report, near line 869). Both are dataflow over functional elements, though the mechanisms differ.
- **Cassowary.** The paper calls FRP "an equality-based, uni-directional constraint solver" (related work). KScript's evaluator is not a constraint solver: a stream is recomputed from its sources, and nothing is solved backwards. See [cassowary](cassowary.md).
- **ForAll.** `anyE` and ForAll both act over a collection, but by different means. See [kscript](kscript.md).
- **Worlds.** The paper does not connect streams to Warth's Worlds. See [worlds](worlds.md).

## Maru and KSNewEventStream

`kscript.l` is a separate evaluator, not a port of `KSNewEventStream`. Reading it against the Squeak source, these differ:

- **One object, not 46 variables.** A stream is a `KSEventStream` object with slots `__currentValue__`, `__prevValue__` and `__firedAt__`. There are no `tt` sub-streams and no `getE` streams.
- **Dependencies are recomputed.** `ks-collect-deps` walks the parsed AST each tick, instead of reading compiled `KSEventStreamRef` sources.
- **Firing.** A stream fires when `__firedAt__` equals the logical time. Squeak uses the `lastTime` and `lastCheckTime` comparison.
- **`delayE` does not delay.** The maru method answers the current value (`(delayE (ks-stream-curr recv))`), and `ks-collect-deps` drops `delayE` from the dependency set. Squeak keeps the behavior source and holds a `pastValues` queue.
- **`timerE` value.** Maru's `timerE` answers the logical time at which a multiple was crossed. Squeak's `ceilTime:` answers the multiple itself, `(t / interval) asInteger * interval`, and stores it as `lastTime`.
- **No priority bins.** Maru sorts by a plain depth-first visit. Squeak's `KSDependencyEvaluator` puts raw events, direct streams and layout streams first.
- **Previous values.** Maru snapshots `__prevValue__` for every stream before a tick. Squeak sets `lastValue` in `sync` after the tick.
- **`when` trigger.** Maru requires the trigger to have fired in this tick. Squeak compiles `when` to `mapE` or `doE`.

## Links

- [kscript](kscript.md): syntax, compilation, and syntax generations.
- [cassowary](cassowary.md), [worlds](worlds.md).
- Maru repository (this repository): `kscript.l` (the evaluator, `ks-sort-and-evaluate-at`, `ks-collect-deps`, `ks-methods KSEventStream`), `check/kscript.l` (the TR-2012-001 listings and the `nat` case), `ksworld-events.l` and `ksworld-run.l` (headless streams), `ksworld-window.l` and `check/ksworld-clock.l` (the window's clock).

## Sources

- package KSObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package KScript, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), class KSNewEventStream.st, KSEventStream
- TR-2013-002, sections 2.2-2.5, 3.1-3.2, related work
- TR-2012-001, Appendix I
- https://tinlizzie.org/updates/exploratory/packages/
- `kscript.l, check/kscript.l` in this repository
