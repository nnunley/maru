# draft-ndn-maru-typed-tree-matching-00: Tree Matching in Typed Maru, and Warth's Optimizing Grammars

**Status:** DRAFT
**Corpus:** red
**Category:** Experimental
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies how tree-matching grammars, in the style of OMeta and Piumarta's PEG
transformer, compile through `maru.k` and ir2 to native code. It defines objects and selectors
in typed Maru, a parser over any data that can be iterated on, the grammar features Warth's
optimizers need, and those optimizers as grammars. It also specifies replacing hand-written tree
walks across the tree with such grammars. It is written for whoever implements the grammar
compilers and whoever writes a pass over Maru forms.

## Motivation

At the time of writing (November 2026), tree matching and native code don't combine in Maru:

- `peg.g` and `peg-compile.l` compile list patterns (`` `( … ) ``, `match-list`), but only for
  `parser.l`, which runs on the evaluators.
- `tpeg.g` reads the same syntax, but `compile-tpeg.l` has no rule for it: a list pattern stops
  it at `cannot find vars in: (match-list …)`.
- `irl-grammar.l`, the route from a grammar to ir2, refuses `match-list`, `match-object`,
  `match-rule-in`, rules with arguments, strings and symbols. Its rule values are `long`s.
- Typed Maru has no selectors. `maru.k` is written with `define-method`, but the programs it
  compiles have none.

So hand-written walks stand in for grammars. Counting lines that match `cond`, `(= op` or `(= (car` gives 102 in
`kscript.l`, 67 in `john-sat.l` and 44 in `john-eval.l`, and all of them run interpreted.
This is the opposite of what the sources intended: TR-2010-003 has one PEG matcher serve the
front, middle and back end of a compiler, and Warth writes his optimizers as grammars that
inherit from an identity pass.

Two lines of work meet here. Piumarta worked bottom up, on a kernel and back end for the VPRI goals, and
Warth top down, on a high-level system assuming those goals could run. OMeta stayed hosted on Squeak and
JavaScript, and Maru's `tpeg` narrowed to text in 2012 ("text-only peg scaffold"), and they weren't joined
before STEPS ended. Which is to say this document is that joining, for grammars.

The tree has no optimizer of this kind. The 2007 OMeta paper's Figure 4 exists here only as a
transcription in `notes/sources/grammars/`.

This document provides the objects, dispatch, input interface and grammar features that let those
grammars run natively, Warth's passes written in them, and the adoption of both across the tree.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT",
"RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as
described in BCP 14 (RFC 2119, RFC 8174) when, and only when, they appear in all capitals, as
shown here.

- **evaluator** — `eval`, `eval2` or `eval3`, running `.l` code. `eval3` is the third iteration of the bootstrap and
  `eval2`'s successor.
- **typed Maru** — the language `maru.k` compiles to ir2. This document uses "typed" and
  "evaluator" for code's level, as a description. Piumarta's sources don't divide Maru this way:
  `emit.l` compiles code with no declared types natively.
- **object** — a value whose structure is defined by `define-structure`: a pair, symbol, long,
  string or a user's structure.
- **word** — a typed `long` holding an object or a number.
- **host** — where native code's objects live: an evaluator's heap, or a standalone program's heap built on `maru-gc.k`.
  `eval2` and `eval3` have no integer tags, so they share a description unless a check finds otherwise.
- **host description** — the typed Maru file that says how one host represents objects.
- **selector** — a function that dispatches on its first argument's type, with one method per type.
- **source** — the value being matched; **position** — where in it, in the source's own terms.
- **stream** — a chain of cells over a source. A **cell** holds an element, a lazily built tail, and a memo table.
- **parser type** — `<text-parser>` for text, or `<source-parser>` for any source, through streams.

- **pass** — a grammar that rewrites a tree. A **null pass** rewrites every node to an equal node.
- **PE tree** — the parsing-expression forms `tpeg.g` produces (`match-all`, `match-first` …).

## Specification

This document defines typed objects and selectors, the input interface, the grammar features
listed below in both grammar compilers' shared route (`compile-tpeg.l`), the optimizing passes and
their driver, and the migration of hand-written walks. It does NOT define `ir2`'s instructions or
back ends; those stay as they are, and native code means ir2 through `ir-gen-c.k` until a native
back end exists. It does NOT change `peg.g`, `peg-compile.l` or `parser.l`.

The sections below go by topic. The work goes in this order, and each stage is useful alone:

1. On the evaluators: `<source-parser>` and streams, live grammars, list patterns, arguments on the input and the other grammar
   features in `compile-tpeg.l`.
2. On the evaluators: the passes, written in those grammars, and `compile-tpeg.l`'s generator rewritten
   as rules, since `tpeg` then has what `peg.g`'s generator uses.
3. In typed Maru: objects, host descriptions and selectors.
4. Lowering grammars to typed Maru, with memoization and left recursion.
5. Inlining and specialization, on both routes.
6. Adoption.
7. Worlds.


Stages 1 and 2 need nothing typed, so tree matching and Warth's passes work before native code does.

**Meaning is separate from optimization.** Selector tables and unoptimized grammars define what
a program means. Every pass is OPTIONAL at build time and leaves that meaning unchanged, so a
slow path is never a semantic commitment and a fast path is never the only path.

**A stream is a memoizable table of data.** Each position holds an element and can hold what rules
have answered there. OMeta/JS keeps a `memo` on each `OMInputStream`, `parser.l` keeps `notes` on each
`<token>`, and `text-parser.l` keeps an array of memos indexed by position: one rule, three layouts, and each parser type keeps its own.

**Memos are on the stream.** A rule's answer belongs to a position, so it lives in that position's cell, as in OMeta. Grammars keep theirs apart because a foreign rule
sees the input through a proxy with fresh memos, not because a parser owns them.

**One grammar object, and a stack of who has the input.** A grammar's fields stay on one object, and `self` stays that object throughout a match. What changes is the input: a list
pattern swaps it and restores it, as OMeta2's `form:` does; a call with arguments prepends to it, as `apply:withArgs:` does; and a foreign rule lends it to another
grammar's object and takes it back, as `foreign` does.

**Parse data is separate from parse state.** Whether a match succeeded is state; what it produced is data, kept in
`self.result`. No generated code and no runtime function decides success from a value, so a match can produce 0, nil
or anything else on any target. `compile-tpeg.l` already means to work this way; `peg`'s `(and ,exp (set self.result
…))` doesn't, which is why treating 0 as false hangs it on a literal `0`.

**Layout lives in one place.** Only a host description reads tag bits or object headers. `eval.c`
tags integers (`TAG_INT`) and `eval2.c` doesn't, so a layout written anywhere else is wrong under
one of them.

**A grammar states what it expects.** It doesn't state what it runs over or how its values are
represented. A stream is any data that can be iterated on and matched, as in Maru's `parser.l` and
in OMeta; characters are one kind of element. The matching machinery works the same on the evaluators
and in typed Maru. Whether one grammar compiles both ways depends only on how its semantic actions and return values
are composed, not on anything about grammars themselves.

### Objects in typed Maru

Typed Maru MUST provide `define-structure`, with the same meaning as `boot.l`'s: a named type with
a type number, allocation by `new`, and field accessors `<T>-f`. [R-typed-structure]

The built-in structures (`<undefined>`, `<data>`, `<long>`, `<double>`, `<string>`, `<symbol>`, `<pair>`, `<array>`) MUST have one definition, written in Maru, shared by every host. A host description
supplies what the definition can't say: [R-host-description]

```
RECORD HostDescription:          -- a typed Maru file; one for each host
    type-of(word)   : long       -- the grounding of dispatch: tag test, then header read
    long-value(word): long       -- a long object's number
        make-long(long) : word


        alloc(type, n)  : word       -- n bytes under a header for a type; may collect
    alloc-atom(n)   : word       -- bytes the collector doesn't trace
    intern(char *)  : word       -- the one symbol with this name; converts to wide characters
    make-string(char *, n): word -- a <string>, whose bits are wide characters on both evaluators
    string-at(word, i): long     -- one character of a <string>
    push-root(word *)            -- this local stays live across a collection
    pop-root(word *)

```

`push-root` and `pop-root` write `GC_stack_roots` directly, because `gc.h`'s functions are `inline` and exported
by neither evaluator, and `struct GC_StackRoot` has a different layout without `NDEBUG`. `E_HOST_MISMATCH`
covers that build flavour too.

`type-of` is the one operation selectors can't provide, because dispatch needs it. It is the
place this system is grounded, as `getType` is in `eval.c` and `get-type` is in `eval.l`.

A host description MUST be checked against its evaluator: native code reads objects the evaluator
built, the evaluator reads objects native code built, and they agree on longs, doubles, strings,
symbols, nested pairs and nil, under each evaluator. [R-host-agrees]

A standalone host MUST pass the same object cases through `ir2-build`, with no evaluator running.
It defines `alloc` and the roots over `maru-gc.k`, and `intern` over a table of its own.
[R-host-standalone]

`eval3.c`'s `subr` MUST do what `eval2.c`'s does: a call by address, a return letter after `>`, and variadic calls through
`ffi_prep_cif_var`. [R-subr-parity] Piumarta's `eval2` had `subr` commented out and `eval3` restored it through libffi in 2013;
`eval2`'s came back separately here, with those additions. So today `eval3` stops at `"s>l"`, truncates float and double results,
and passes garbage in variadic calls on Apple arm64.

`eval.c`, `eval2.c` and `eval3.c` MUST accept a signature letter `o` for an argument or result passed as the object itself,
unconverted, and a result letter `b` for a truth value. [R-object-subr] Today `subr`'s `p` rejects a pair ("invalid pointer
argument"), and no letter hands native code a tree. These evaluators MUST also export `intern`, as they already export `GC_malloc`.

A library MUST export one function that the evaluator calls once when it opens the library, passing what
it needs to register its types. That function allocates each native type's number through `%allocate-type`'s
counter, so `name-of-type`, `new` and accessors know it, then fills selector tables, interns quoted symbols,
and checks the host description against the evaluator (`E_HOST_MISMATCH`). A standalone program calls it
from `main`. [R-library-init] ir2 programs have no initializers of this kind today.

Native code that holds an object across an allocation MUST have it rooted. The collector scans no stack, so
a C temporary is invisible to it. The typed lowering therefore puts every intermediate object in a rooted
local, including each step of a quasiquote, and roots a rule's bindings and its parser's fields; a hand-written
typed function roots its own. [R-native-roots] The collector doesn't move objects, so a root only keeps an
object live.

A traced object MUST hold only words. `GC_default_mark_function` follows every even field, so a raw position
or count in a memo or parser crashes a collection. Raw numbers go in an atomic object or as `make-long`.
[R-traced-words]

A pass over a large tree MUST produce an equal result when a collection runs on every allocation, through a
flag in the host's `alloc` that calls `GC_gcollect`.
This is the check that the generated roots are complete. [R-gc-stress]

```maru-check @R-typed-structure
tree_objects
```

```maru-check @R-host-description
tree_objects
```

```maru-check @R-host-agrees
tree_host
```

```maru-check @R-host-standalone
tree_standalone
```

```maru-check @R-subr-parity
eval2_subr
```

```maru-check @R-object-subr
tree_host
```

```maru-check @R-native-roots
tree_gc
```

```maru-check @R-gc-stress
tree_gc
```

```maru-check @R-library-init
tree_host
```

```maru-check @R-traced-words
tree_gc
```

### Selectors in typed Maru

Typed Maru MUST provide `define-selector` and `define-method`. A call dispatches on the receiver's
type through a per-selector table of function pointers indexed by `type-of`. [R-typed-selector]
All methods of one selector share a signature, because a typed function pointer has one type.

Adding a method for a new type MUST NOT require recompiling callers of the selector.
[R-selector-open] This is the extensibility of TR-2011-002, whose `eval` and `apply` dispatch
through tables indexed by type.

A selector with no method for a type MUST call its default method, and a selector with no default
MUST stop with `E_NO_METHOD`, naming the selector and the type. [R-selector-default]

A native type's number MUST NOT collide with a type the evaluator allocates. [R-type-numbers]
`boot.l` allocates numbers at run time, so a library can't fix them when it is compiled.

```maru-check @R-typed-selector
tree_selector
```

```maru-check @R-selector-open
tree_selector
```

```maru-check @R-selector-default
tree_selector
```

```maru-check @R-type-numbers
tree_host
```

### Parser types and instances

There MUST be two parser types. [R-parser-types]

| Parser type | Source | Position | Memos |
|---|---|---|---|
| `<text-parser>` | a string | an integer | an array indexed by position, per parser, as today |
| `<source-parser>` | any value with input methods | a cell | in the cell |

`<text-parser>` and what `compile-tpeg.l` generates for it MUST stay as they are, with no test for the kind of source. Text pays nothing for the other. [R-text-unchanged] A grammar that
only reads text stays on it, and direct code for lists or binary is an optimization for later, through [R-opt-specialize], if evidence asks for it.

A grammar MUST name its parser type by its parent, as `<dc> : <parser> ()` does in `test-dc.g`: `<trees> : <source-parser> ()` runs on `<source-parser>`, and a child runs on what its parent runs on. No flag or build step
chooses it. A list pattern, an object literal or a call with arguments in a grammar on `<text-parser>` MUST stop with an error naming the rule. [R-instances]

A grammar on `<source-parser>` MUST read one input to equal results from text, a list of characters, a `<data-stream>`, and a user's type that generates its elements on demand. [R-any-source] A grammar that wants any source
declares `<source-parser>`, which reads text too; one that only reads text and wants its speed stays on `<text-parser>`.

### Streams

Each source MUST be read through these selectors, modelled on OMeta/JS's `toOMInputStream` and the `head` and `tail` of its streams. They carry no `$`, because `compile-tpeg.l` makes each rule `r` the
selectors `$r` and `$$r`, and grammars have rules called `start`. [R-input-selectors]

```
SELECTORS on a source:
    in-enter(value)          : boolean     -- can a list pattern go inside this value
    in-start(source)         : position    -- where it begins
    in-at-end(source, pos)   : boolean
    in-head(source, pos)     : word        -- the element at this position
    in-tail(source, pos)     : position    -- the next position
    in-same(a, b)            : boolean     -- does element a match literal b

STREAMS, built on them:
    stream-of(value)         : cell        -- the first cell, or an end cell
    stream-end?(cell)        : boolean
    stream-head(cell)        : word
    stream-tail(cell)        : cell        -- built the first time, then kept
    stream-memo(cell)        : table       -- what rules have answered at this position
```

**Behavior:**

- A cell's selectors run only when it is built, so revisiting a position costs a field read, and backtracking restores a saved cell, which is the whole state. One small allocation per element visited is the cost
  `<text-parser>` doesn't pay.
- `in-*` has methods for `<string>`, `<pair>` and nil, and for `<data-stream>` in `input-binary.l`, which loads `data-stream.k` only for binary parsing. The parser keeps the position, so a match doesn't move
  `<data-stream>`'s own `position`. `net/structure-diagram.k` reads a packet's diagram to field accessors, so a binary rule's actions read fields by name. At the time of writing, `net/*.k` reads packets by `byte-at` and
  doesn't use `<data-stream>`.
- A user's type becomes matchable by adding these methods. This is the generalization the thesis proposes after Wadler's views: list patterns that match "objects that are not actually lists". The 2008 report's
  `svc`/`syn`/`req`/`ack` rules run over a stream whose elements are whole packets, a user's type.
- `[0-9]` tests one element and fails on an element that isn't a character. `"abc"` matches consecutive elements `a`, `b`, `c`, as Warth's `seq` does. `'x` matches one element through `in-same`, which compares longs by value,
  symbols by identity and strings by contents.
- `@` gives a list of the elements between two cells, and `$` makes a string of a list of characters, as they do on text today.

### Live grammars

Grammars are live, as in `repl.l` and `test-pepsi.l`. Rules MUST compile in-process, and a grammar comes into use by importing it: `(require "x.g.l")`, or inline in a program. A `.g.l` file is a cache of the same forms. [R-live-grammars]

A program MUST be able to interleave code and grammars on one input, with `tpeg-repl.l` as `repl.l` is for `peg`, through `tpeg.g`'s existing `{ … }` blocks: [R-interleave]

- `{ <x> : <parent> (fields) rules }` defines a grammar, and `{ <x> + rules }` adds to one.
- `{ rules }` enriches the running grammar: a later block's rule overrides an earlier one, and other rules stay.
- `{ rules expression }` also matches the rest of the input against the expression, as `repl.l`'s comment says. The grammar has the input while it matches. When it stops matching, the reader carries on from that position, reading code.

So the reader takes part in the stack below: code, a grammar that takes the input, then code again, on one stream.

A grammar that doesn't parse to its end MUST be an error naming the file and position, because a grammar otherwise loses every rule after the one that stopped it, and nothing says so until a rule is missing. [R-parse-complete]

```maru-check @R-live-grammars
tree_interleave
tree_apply
```

```maru-check @R-interleave
tree_interleave
```

```maru-check @R-parse-complete
tree_parse_complete
```

### The input stack

A list pattern MUST match only if `in-enter` holds for the current element, its nested pattern matches from the stream of that element, so `` `() `` matches an empty list, and that match ends at an end cell. Its value is the
element, and the input moves past it. On failure, the input is as it was. [R-list-pattern] This is the thesis's `List-Success` rule and OMeta/Squeak 2's `form:`. Its body compiles inline in its rule, so its bindings are ordinary
bindings of that rule. `peg-compile.l`'s `match-list` doesn't require the end; see Compatibility.

A call's arguments MUST be elements its rule reads from the input, first argument first: new cells whose tail is the current input. [R-args-on-input] `:a` is shorthand for `.:a`, and a rule can match its arguments with any
pattern. `tpeg`'s function arguments go; its `rule :a` syntax stays. Failure restores the saved cell, so no cell stays behind.

Within one parser, entering the same value twice MUST reuse its stream and so its memos, as OMeta/Squeak 2's `om2streams` does for each matcher. [R-stream-per-value] A foreign rule `p-r` MUST run on an object of `<p>`, sees the
input through a proxy cell with fresh memos, and hands back where it got to, as OMeta's `foreign` does. [R-foreign-proxy] Its fields are its own: it is a different grammar.

**Worlds.** A world is one more thing the stack can hold ([R-worlds-shadow]): shadowed state that commits, or is discarded when popped.

```maru-check @R-parser-types
tree_source
```

```maru-check @R-text-unchanged
tree_source
```

```maru-check @R-instances
tree_source
tree_text_refuses
```

```maru-check @R-any-source
tree_source
```

```maru-check @R-input-selectors
tree_selectors
```

```maru-check @R-list-pattern
tree_lists
```

```maru-check @R-args-on-input
tree_args
```

```maru-check @R-foreign-proxy
peg_compose
tree_memo
```

### Grammar features

`compile-tpeg.l` MUST compile these for the evaluators, and `irl-grammar.l` MUST lower the same
output to typed Maru. Each is one the optimizers below need. [R-grammar-features]

| Feature | In Warth's source | Syntax here | Refused by typed grammars today |
|---|---|---|---|
| List pattern | `['And' …]` | `` `( … ) `` | yes |
| Object literal | `exactly(t)` | `'sym`, number | yes |
| Any element | `anything` | `.` | no |
| Rule parameter | `transInside :t` | `rule :t = …`, `{rule x}` | yes |
| Call by name | `apply(t)` | `{apply x}` | not available |
| Inherited rule | `^rule`, `^rrr(a1. a2)` | `{super rule x}` | not available |
| Consumed-by | `<…>`, `@<…>` | `@` | yes, except a `tp-span` number |
| Foreign rule | `BSSeqInliner.optimize` | `p-r` | yes |
| Building a list | `[x].concat(xs)` | ``-> `(…)`` | yes |

**Behavior:**

- `{apply x}` calls the rule named by `x` on this grammar, through a table of names kept per grammar, so an
  override in a child is the one called. `apply` and `super` become reserved in `{ }`. A name with no rule fails the match; it doesn't stop the program. Warth's `trans` guards
  the same case with a predicate.
- `{super r x}` calls `r` as the parent grammar defines it.

- A rule's parameters and bindings are words, and generated rules root them ([R-native-roots]).
- OMeta/Squeak 2's `<…>` answers the input's own species instead; Maru's grammars rely on `@` and `$` as they are.
  Positions are values, so a rule can keep a start and end as `@<…>`
  does without building the span. OMeta's operator came from Piumarta's COLA framework, so this is
  Maru's own idea coming back.

- A typed grammar's object is a struct whose fields are words, its parent's first, as `irl-grammar.l` lays them out today, and `self` is a pointer to it throughout a match. `define-class`'s accessors map to `member`. A typed
  `<source-parser>`'s position is a cell object, whose methods are typed selectors. A typed `<text-parser>` keeps its raw integer position, and so is not a traced object.
- `tpeg` keeps the source position of a list it builds, as `peg` does, and a pass carries it from a node to
  that node's rewrite, so errors still name the original text. [R-source-positions] `text-parser.l`'s
  `set-list-source` does nothing today.
- Actions read hexadecimal literals, as `peg` does.
- An action is whatever forms its target compiles, and calls to named functions. A grammar compiles
  for a target when its actions and return values do. `<cnf>`'s actions are typed functions and `long`s,
  so it compiles natively.
- A predicate MUST return a false value when it fails, and anything else counts as true. False is nil on an
  evaluator and 0 in typed Maru. Those are the same machine word, and only the number 0 differs: boxed by `subr`'s
  `l`, it is true on an evaluator. So a typed function answering a predicate is called through a new result letter
  `b`, which gives nil for 0 and `t` for anything else, and never hands the evaluator an arbitrary word as an
  object. With that, `<cnf>`'s rules and its functions' 0-or-1 results run on an evaluator as they are, or those
  functions can be written in Maru. [R-predicate-false]
- An action using forms a target doesn't have is a compile error for that target, naming the grammar
  and rule. [R-action-target] Nothing about the matching constrains this: a child grammar can override
  the rules that hold the actions and target something else.
- A grammar meant for both targets writes its actions in core forms
  (draft-ndn-maru-forms-as-neutral-tree-00), quasiquote, selectors and named functions, and its predicates return a false value as above. A rule's own success is 1 on both, with its value in
  `self.result`, so a matched nil or 0 is not a failure. Its values are
  words, however a target represents them. Where an action passes one to a typed function's `long`
  parameter, the compiler converts it, as `subr`'s `l` does on an evaluator, and a rewrite removes a
  conversion paired with its inverse ([R-opt-specialize]), so a number need never be boxed.
- In typed Maru, quasiquote builds objects through the host's `alloc`, and a quoted symbol is interned
  when the library loads.

Every match MUST succeed or fail independently of its value: an element, literal, number, span or action result of
0 or nil is an ordinary value, on every instance and target. [R-success-not-value]

A grammar whose actions compile for both targets MUST match the same inputs to equal results on each,
for every feature in the table. [R-namespaces-agree] With its actions removed, any grammar MUST accept
and reject the same inputs, at the same positions, on both, unless a predicate decides the match by
calling a target's function.

The `dbjr` demos' grammars MUST run as a check, transliterated: `ometaCalc-parse`'s left-recursive
calculator reads an expression to a tree, and `ometaCalc-eval`'s `OMeta2Evaluator` (`start :env = calc`,
with `{('+' | '-' | '*' | '/'):op calc:l calc:r}`) evaluates that tree, on each target. [R-dbjr-calc]

```maru-check @R-grammar-features
tree_lists
tree_args
tree_apply
tree_literals
```

```maru-check @R-stream-per-value
tree_memo
```

```maru-check @R-source-positions
tree_literals
```

```maru-check @R-dbjr-calc
tree_calc
```

```maru-check @R-action-target
tree_agree
```

```maru-check @R-predicate-false
tree_agree
sat_dimacs
```

```maru-check @R-success-not-value
tree_agree
```

```maru-check @R-namespaces-agree
tree_agree
```

### Memoization and left recursion

Each parser type MUST memoize, and grow left-recursive rules as OMeta/Squeak 2's `apply:` does: repeat until a pass fails or doesn't advance. `<text-parser>` judges that with `<`, as it does today, and
`<source-parser>` by cell identity. A left-recursive grammar
then compiles natively, which is what stops the JOHN, irl, law and KScript grammars from doing so
today. [R-typed-left-recursion] Refusing this was a limit in the matching machinery, not in a
grammar's actions.

A rule with arguments is not memoized by default. Warth's reason is memory footprint, and OMeta/JS's `memoizeParameterizedRules` shows it can be done. A copy
that [R-opt-specialize] makes for known arguments has none left and pushes no cells, so it is eligible like any other rule: `{two 1 2}`
can share one memo. [R-memo-specialized]

With no memo a rule can't detect its own recursion, so a left-recursive rule with arguments MUST stop at compile
time naming the rule, unless every call has known arguments and so reaches a specialized copy. It would otherwise
overflow the stack with no error. [R-param-left-recursion] In typed Maru, a rule that no left-recursive rule reaches through its left calls has no memo unless `memo-all` is set, because Warth
reports that the overhead can outweigh the benefit where backtracking is limited; so `<cnf>`, which
has no left recursion, stays free of memo tables. [R-memo-selective]

| Key | Type | Default | Description |
|---|---|---|---|
| `memo-all` | Boolean | false | Memoize every rule without arguments, for the linear-time guarantee on a grammar that backtracks heavily. |

Memo tables are objects under [R-native-roots], and [R-gc-stress] covers them.

```maru-check @R-typed-left-recursion
tree_memo
```

```maru-check @R-memo-selective
tree_memo
```

```maru-check @R-memo-specialized
tree_memo
opt_inline
```

```maru-check @R-param-left-recursion
tree_memo
```

### Optimizing passes

Passes follow Warth's `bs-ometa-optimizer.txt`. They rewrite PE trees, and each is a grammar. His
node names map to Maru's:

| Warth | Maru | Warth | Maru |
|---|---|---|---|
| `Or` | `match-first` | `Set` | `assign-result` |
| `And` | `match-all` | `Not` | `peek-not` |
| `Opt` | `match-zero-one` | `Lookahead` | `peek-for` |
| `Many` | `match-zero-more` | `Form` | `match-list` |
| `Many1` | `match-one-more` | `App` | `match-rule` |
| `Act` | `result-expr` | `Pred` | `peek-expr` |
| `JumpTable` | `match-table` (new) | `Rule` | a grammar's `(rule pe args)` |

A null pass MUST exist that rewrites every PE node to an equal node, with its `trans` rule choosing
a node's rule from the node's head by `{apply}`. Every other pass inherits from it and overrides
only the nodes it improves. [R-null-pass] A pass doesn't recurse by hand; the inherited rules
already walk a node's children.

A pass MUST record that it changed something (Warth's `setHelped`), and its `optimize` rule MUST
fail if it changed nothing. [R-helped] Failure is how the driver knows to stop.

The driver MUST apply passes to each rule separately, and passes MUST NOT name the driver or each
other. [R-driver] This seam is what lets another driver replace it (see Out of Scope, on JOHN).

```
FUNCTION optimize-rule(rule, inliners, repeaters) -> rule:
    -- Step 1: each inliner once, so its output can feed the repeaters
    FOR pass IN inliners:
        rule = pass.optimize(rule) IF it helped ELSE rule
    -- Step 2: repeaters until none helps
    REPEAT at most opt-pass-limit times:
        IF no pass in repeaters helps: RETURN rule
        rule = the first helping pass's output
    STOP with E_OPT_DIVERGED

-- Behavior:
--   - A rule no pass helps comes out equal to the rule that went in
--   - The order is Warth's: BSSeqInliner, then (Associative | JumpTable)*
```

| Key | Type | Default | Description |
|---|---|---|---|
| `opt-pass-limit` | Integer | `64` | Repeats before `E_OPT_DIVERGED`. A rewrite that undoes another would otherwise never end; 64 is far above what flattening and tables need. |
| `*grammar-optimize*` | Boolean | true | Whether grammar compilers run the driver. Off gives the unoptimized grammar that [R-opt-equivalent] compares against. |

These passes MUST exist:

- **Associative flattening.** A one-element `match-all` or `match-first` becomes its element, and a
  nested `match-first` in a `match-first`, or `match-all` in a `match-all`, joins its parent.
  [R-opt-associative]
- **String inlining.** A `match-string` becomes a `match-all` of its elements, followed by an action restoring
  the literal as the value, as Warth's trailing `['Act', s]` does. It exposes each alternative's first element. [R-opt-string-inline] Warth's `BSSeqInliner` does this; it
  has a TODO to stop when `seq` is overridden, which [R-opt-override] settles here.
- **Jump tables.** Consecutive alternatives of a `match-first` that start with distinct literals
  become a `match-table`, which dispatches on the head of the input and tries only the alternatives
  for it. Alternatives with the same literal stay in their order. [R-opt-jump-table] Warth's keys on a literal at
the head of an alternative. Looking inside a list pattern at a node's head symbol is ours.
- **Left factoring.** Alternatives with a common prefix share it, preserving ordered choice. A prefix containing an
  action or predicate isn't shared, because factoring changes how often it runs. [R-opt-left-factor] This is a
  TODO in Warth's source, and the thesis reports doing it.

```maru-check @R-null-pass
opt_passes
```

```maru-check @R-helped
opt_passes
```

```maru-check @R-driver
opt_passes
```

```maru-check @R-opt-associative
opt_passes
```

```maru-check @R-opt-string-inline
opt_passes
```

```maru-check @R-opt-jump-table
opt_passes
```

```maru-check @R-opt-left-factor
opt_passes
```

### Inlining methods

This part is ours, modelled on the string inliner: a rule that replaces a call with its expansion.
Because the whole stack is visible when a program is compiled, the indirect call of
[R-typed-selector] is the meaning, not a cost a program has to keep. It runs over Maru forms, after a grammar is lowered and before they reach `maru.k` or an evaluator's `.g.l` file, so
both routes get it, using the same driver and null-pass structure. Without that, every evaluator grammar would
keep its selector calls for good: one call per element cost about 1.8× a direct `string-at` when measured.

A pass MUST replace a selector call with its method's body where the receiver's type is known, and
with a type test, the inlined body, and a fallback to the table where a type is common but not
known. [R-opt-method-inline] Forms need their own null pass, which treats `quote` and quasiquote as data and knows
how `let` and `lambda` bind.

A pass MUST specialize a rule for arguments known at a call, so it pushes no cells, and for a source type known at an entry point, inlining `in-*` and removing cells
where nothing backtracks or memoizes. The same pass removes paired conversions and folds a span into what consumes it, so reading a number
from a known source allocates nothing. [R-opt-specialize]

A pass MUST NOT expand a rule or method that an inheriting grammar or a later `define-method` in the
program being compiled overrides. A call that an override can reach stays a call: `{apply r}` and an
overridable rule are expanded only in a grammar that nothing inherits from. [R-opt-override] This settles Warth's TODO, checked at compile time over the program being compiled; an override
in a later library isn't seen until recompiling.

A method redefined after a program is compiled takes effect only when that program is recompiled. A
type test notices a new type, not a new method; this is a stated limit, with no check, and Out of
Scope names what would lift it.

`<cnf>`'s text instance MUST contain no selector call and no allocation for each element. [R-known-source-direct]

`text-parser.k`'s direct forms MUST remain `<text-parser>`'s implementation in typed Maru. [R-instance-methods]

Every optimized grammar MUST match the same inputs to equal results as the same grammar with
`*grammar-optimize*` off, and fail at the same position, over: `cexpr.g`, `john.g`, `kscript.g` and
its 39 listings once that branch merges, `dimacs.irl`'s formulas, and `law.g`. [R-opt-equivalent]

The passes build in two steps, with `*grammar-optimize*` off and then on, and the second build's output MUST equal
what a third produces. The optimizer MUST compile to native code through the features above, and that native optimizer MUST
produce output equal to the same grammars run on an evaluator, on its own PE trees.
[R-opt-self-hosted] This is the optimizer optimizing itself, and the point of doing all this in
grammars.

```maru-check @R-opt-method-inline
opt_inline
```

```maru-check @R-opt-override
opt_inline
```

```maru-check @R-opt-specialize
opt_inline
```

```maru-check @R-known-source-direct
opt_inline
sat_dimacs
```

```maru-check @R-instance-methods
irl_grammar
sat_dimacs
opt_inline
```

```maru-check @R-opt-equivalent
opt_equivalent
```

```maru-check @R-opt-self-hosted
opt_self
```

### Adoption

A function that walks a tree by testing a form's head MUST be a grammar, in these files:
`kscript.l`, `john-eval.l`, `john-sat.l`, `compile-irl.l`, `irl-grammar.l`, `law-compile.l`, `compile-tpeg.l`.
[R-walks-are-grammars] A check scans them, in Maru, for `(= op '`, `(= h '`, `(= (car` and `record-case`. A scan can
be evaded, so the plan also names each function to be replaced. Code that
does something different per value type is a selector, not a grammar, as `john-eval.l`'s `john-text`
already is. `maru.k`, `ir2.k` and the other files from upstream are out of this list; they are
reference material as they stand.

Each migrated file's existing check MUST pass unchanged: `john_run`, `john_forms`, `sat_john`, `irl`, `irl_grammar`,
`irl_library`, `law_cexpr`, `law_rules`. The exceptions are `check/irl-grammar.l`'s two cases asserting that left
recursion and `make-string` are refused, which this document reverses; they become cases that those compile.
[R-adoption-preserves]

KScript MUST lower to Maru forms by a tree-rewriting grammar following `kscript.g`, as `test-pepsi.l`'s
language does and as the report's KScript compiler does in OMeta2/Squeak (a parser and back end of about
450 lines, and an expander of about 170), replacing the `ks-eval` interpreter. The forms
run on an evaluator and, for streams of numbers and booleans, through `maru.k` to native code. A
native program's streams are fixed when it is compiled, so its update order is computed then and a
tick is a generated function, with no scheduler at run time. Both routes give the report's values
for `nat`, `a` and `b`, and `stopper`, plus `when` and `mergeE` as `check/kscript.l` asserts them.
[R-kscript-native] The 39 listings are read by the grammar, not run natively. KScript objects, box
selectors and anything loaded from `.pp` bundles stay on the evaluator until their runtime is typed.

```maru-check @R-walks-are-grammars
tree_adoption
```

```maru-check @R-adoption-preserves
john_run
john_forms
sat_john
irl
irl_grammar
irl_library
law_cexpr
law_rules
```

```maru-check @R-kscript-native
kscript
kscript_native
```

### Worlds

A world is a nested, shadowing environment, like a stack frame. A child sees its parent's state and its own writes shadow it, as a
frame's locals shadow an enclosing scope in `eval3.c`'s environments, where a frame is a list onto its parent and lookup walks outward.
Worlds add two things to a frame: `commit` copies a child's writes to its parent, and they cover object fields, not only names. There is
one mechanism for both, not a separate one beside the evaluators' environments. [R-worlds-shadow] A frame that returns without
committing is a world discarded.

A failed alternative's actions MUST be undoable by running it in a child world, as thesis section 4.5 does for OMeta/JS. This is a pass
that rewrites `match-first` and `match-zero-more`, so a grammar opts in and doesn't change. [R-worlds-backtrack] JOHN's possible worlds
and DBjr's undo are the next users; how JOHN's search maps onto this needs its own design.

Reads and writes through worlds cost a lookup, which [R-opt-specialize] removes where no world is active.

```maru-check @R-worlds-shadow
tree_worlds
```

```maru-check @R-worlds-backtrack
tree_worlds
```

### Errors

| Error | Example | Recovery |
|---|---|---|
| `E_NO_METHOD` | `in-head` on a type with no input method and no default | Stop, naming the selector and the type. Add a method, or write a default. |

| `E_OPT_DIVERGED` | Two passes undoing each other past `opt-pass-limit` | Stop, naming the rule and the last pass. Fix the pass; a grammar can build with `*grammar-optimize*` off meanwhile. |
| `E_HOST_MISMATCH` | A library compiled for one evaluator's description opened by the other | Stop when the library loads, naming both. Rebuild for this evaluator. |

A left-recursive rule no longer stops a typed grammar, unless it has arguments ([R-param-left-recursion]). A
construct with no typed lowering still stops at compile time, naming the grammar and rule, and is
never silently dropped.

## Out of Scope

**JOHN describing optimizations.** A JOHN program could state an optimization's goal, the same meaning
at lower cost, with each pass an action, and a planner would choose what to apply and in what order.
This is the "what vs how" track of the STEPS 2012 report. It is excluded because JOHN's evaluator is
interpreted and the passes have to work first. Extension point: [R-driver] keeps the driver separate
and passes named, and [R-helped] gives a planner each pass's outcome, so another driver replaces this
one without touching a pass.

**The `emit.l` fixpoint on arm64, and `ir-gen-arm64.k`.** Piumarta's definition of the stack running:
`eval` run on `boot.l`, `emit.l` and `eval.l` reproduces an identical `eval.s`. This remains the goal
beyond this document, and roadmap item 1 is its neighbour. Excluded because it is a separate project
and the grammars here are independent of the back end. Extension point: the host description, one
more for a compiled `eval.l`; and [R-driver], since passes over ir2 or intents use the same structure.

**Live invalidation of inlined code.** Redefining a method and having running code notice, as Self
does. Excluded because a recompile is enough until a JIT and a live image exist. Extension point:
[R-opt-override], which a dependency record would replace.

**A dynamic KScript runtime in native code.** Streams created at run time, boxes, and the object model
the `.pp` bundles need. Excluded because they need a typed object runtime, which this document starts
but doesn't finish. Extension point: [R-kscript-native]'s generated tick, which a scheduler would
replace.

**Warth's full left-recursion algorithm.** The 2008 paper's involved sets, for indirect left recursion. `text-parser.l`
and OMeta/Squeak 2's `apply:` use the simpler growth, and this document follows them. Extension point:
[R-typed-left-recursion].

**Dispatch on more than the receiver.** TR-2011-002's `<generic>`. Streams need one receiver.
Extension point: [R-typed-selector], whose table would gain a dimension.

**Live grammars in native code.** Compiling a rule in-process needs a compiler in the running program. On the evaluators that is `compile-tpeg.l`; natively it needs a JIT or a native evaluator. Excluded until those exist: typed grammars compile ahead of time. This is where the distinction between interpreted and compiled has to disappear. Extension point: [R-live-grammars].

**Retiring `peg.g`, `peg-compile.l` and `parser.l`.** `tpeg` began on 2012-08-13 as Piumarta's "text-only
peg" ("scaffold", in his commit), derived from `peg.g`, which had matched structures since 2011 and
memoized since February 2012. They never converged. This document converges them in capability: `tpeg`
gains what `peg` has, and text becomes one parser type. Excluded is moving the remaining `peg` users, such as `net/structure-diagram.k`'s inline block, and `test-pepsi.l`. Extension point: [R-input-selectors], since `parser.l`'s streams are the same idea.

## Alternatives Considered

**Why not make the number 0 false on the evaluators, by a `$false?` selector or otherwise?** It would remove the
truth difference in draft-ndn-maru-forms-as-neutral-tree-00, but it fixes the wrong thing: truth was only a problem where
parse data was coupled to parse state, and [R-success-not-value] removes that. Tried on all three evaluators, it makes
`compile-peg.l` hang on a grammar containing `-> 0`, and it would change every evaluator program's meaning.

**Why not stretch `<text-parser>` over every source?** An earlier version of this design did: its `string` field held any source, with a branch in each operation, and it was built. That cost text about 4%.

**Why not a compile-time flag choosing the parser type?** `--on source` did, for a while. It made a grammar a batch artifact, compiled by another process and pointed at data afterwards, which isn't how Maru's grammars work. A grammar states its parent, and it is live.

**Why not a separate parser object per frame, with direct code per source type?** Also tried on paper. Each class has its own slots, so `self.env` set on one frame isn't there on the next, and a list pattern's body as a separate rule can't share bindings with the
rule around it, which typed Maru has no closures to fix. One grammar object and a swapped input, as in OMeta, have neither problem.

**Why not keep a memo table on the parser, keyed by position?** It reads against the sources and the principle above, and pairs make poor keys. Text keeps its array only because an integer position has no cell to hold one.

**Why not choose instances at load time?** Building them from stored rules suits a live system, but doesn't carry over to native code directly.

**Why not treat text grammars and typed grammars as kinds of grammar?** An earlier version of this
design did: grammars under `<text-parser>` meant characters, and `<cnf>` was a typed-only grammar. That
made a property of its actions into a property of grammars. `<cnf>` is expected
tokens and calls, and streams were never only text, in Maru or OMeta. Text stays, as one parser type among others.

**Why not keep `tpeg`'s function arguments?** They compile directly, but a parameter could then only be
bound, never matched, and OMeta/Squeak 2, OMeta/JS and `peg` all put arguments on the input. Specializing
for known arguments removes the cost ([R-opt-specialize]).

**Why not hard-code the evaluator's pair layout in native code?** It is the smallest change, but
`eval.c` tags integers and `eval2.c` boxes them, so it is wrong under one of them, and it would need
changing again for a compiled `eval.l`.

**Why not a separate typed tree, with structs in native code's own heap?** Clean and independent, but
every pass boundary needs a conversion, and a form couldn't move between the evaluator and native
code. The standalone host keeps that independence by another route.

**Why not a flattened tree, with open and close markers in a buffer?** It reuses the character cursor
and needs no collector. But passes become stream-to-stream, nothing shares structure, and Warth's
grammars don't read naturally over it.

**Why not call the evaluator's own selectors from native code?** One table and nothing duplicated, but
every `in-tail` goes back through `apply`, and native code would always need an evaluator under it.

**Why not resolve dispatch only at compile time?** That is the fastest form, but it closes the set of
types. Here it is a pass over open dispatch ([R-opt-method-inline]), so the meaning stays open and the
common paths still lose their call.

**Why not base the passes on FMPL's optimizer?** `lib/core/grammar_optimizer.fmpl` is the same idiom,
but it descends from Warth's, and his source and thesis are the primary work. Its eight stream
primitives (`head`, `advance`, `checkpoint`, `restore`, `position`, `apply`, `push`, `pop`) were
considered for the input interface; immutable inputs need neither `checkpoint` nor `push`.

**Why not rewrite ir2 instead of forms?** ir2 has no passes today, and its nodes are objects specific to
one layer. Forms are the shared tree (draft-ndn-maru-forms-as-neutral-tree-00). Passes over ir2 can
follow with the same structure.

**Why not converge on `peg-compile.l`, since it already compiles list patterns?** `peg` is the general
one, and this document moves toward it in capability. But its generated code runs through `parser-stream`,
token objects and groups, which typed code would all have to carry. `compile-tpeg.l` is already the route
to typed code, and `value-pe`'s shape survives this change.

## Security Considerations

This adds native code that reads objects by their type, so a wrong type or a stale object is memory
corruption, where an evaluator would stop with a type error. `<T>-f` accessors in typed Maru check types when built with `safe`, the form `eval.l` has for this and leaves
off, and checks build that way. A missing root is a
use-after-free, which [R-gc-stress] exists to find.

Grammars and passes come from this tree. Their input needn't: KSWorld's `.pp` bundles are downloaded
from tinlizzie.org, and an adversarial bundle could exercise a native parser's code paths. Nothing here
executes bundle content natively, because [R-kscript-native] keeps `.pp` objects on the evaluator. A
later typed runtime has to treat them as untrusted input, and this document doesn't make that safe.

## Compatibility

Existing irl grammar blocks keep their syntax and their actions, and `dimacs.irl`
keeps its direct code throughout. `peg.g`, `peg-compile.l` and `parser.l` don't change. Text grammars generate what they generate today, so building them doesn't slow; each stage measures that with hyperfine. The `make tpeg.l` byte comparison retires at stage 2, when `compile-tpeg.l`'s generator
becomes rules, since `peg` and `tpeg` differ on list patterns.

A list pattern in `tpeg` requires the whole list to match, where one in `peg` matches a prefix. Both
syntaxes look the same, so moving a grammar from `peg` to `tpeg` can make a pattern fail until it ends
in `.*`. This follows Warth; no `tpeg` grammar has list patterns yet, so none is affected.

The `kscript` branch (at the time of writing, unmerged) keeps its grammar and check, and its `ks-eval`
is replaced under [R-kscript-native]. Its `kscript.l` isn't merged to `main` in the meantime as if it
were the design.

Every step needs its `check/lines` entry, and the budget stays soft. Changing `eval.c` and `eval2.c`
([R-object-subr]) touches evaluators that the bootstrap is meant to retire; `eval.l` needs the same
letter when it gets there.

## References

- Warth, *Experimenting with Programming Languages* (PhD thesis, UCLA, 2009; VPRI TR-2008-003), §2.2.2
  (list patterns, `apply`), §2.2.3 (memoization), §2.3.2 (optimizers), §2.4.3 (`List-Success`), §2.5
  (views); local copy `~/pkm/raw/vpri/warth-2009-experimenting-thesis.txt`.
  https://tinlizzie.org/VPRIPapers/tr2008003_experimenting.pdf
- Warth and Piumarta, *OMeta: an Object-Oriented Language for Pattern Matching* (DLS 2007, VPRI
  TR-2007-003), Figure 4. https://tinlizzie.org/VPRIPapers/tr2007003_ometa.pdf
- Warth, Douglass, Millstein, *Packrat Parsers Can Support Left Recursion* (PEPM 2008, VPRI
  TR-2007-002). https://tinlizzie.org/VPRIPapers/tr2007002_packrat.pdf
- Warth, OMeta/Squeak 2 (2009): https://tinlizzie.org/ometa/ometa2.html and `OMeta2-rc.sar`
  (`apply:withArgs:`, `form:`, `consumedBy:`); local copy `~/pkm/raw/vpri/ometa2/`.
- tinlizzie.org/dbjr, `ometaCalc-parse.lbox`, `ometaCalc-tree.lbox`, `ometaCalc-eval.lbox`: OMeta2 as the
  DBjr documents use it; local copy `~/pkm/raw/vpri/ometa2/`.
- OMeta/JS, `bs-ometa-optimizer.txt` and `ometa-base.js` (`_form`, `toOMInputStream`); local copy
  `~/development/ometa/ometa-js`.
- Piumarta, *PEG-based transformer provides front-, middle- and back-end stages in a simple compiler*
  (S3 2010, VPRI TR-2010-003). https://tinlizzie.org/VPRIPapers/tr2010003_PEG.pdf
- Piumarta, *Open, extensible composition models* (FREECO 2011, VPRI TR-2011-002).
  https://tinlizzie.org/VPRIPapers/tr2011002_oecm.pdf
- STEPS 2011 and 2012 reports (VPRI TR-2011-004, TR-2012-001).
- tinlizzie.org, the archived VPRI site, is a core reference for this repository.
- draft-ndn-maru-forms-as-neutral-tree-00, draft-ndn-maru-sat-00 (its irl grammar blocks).
- FMPL, `lib/core/grammar_optimizer.fmpl` (https://github.com/nnunley/fmpl; Rust): the same idiom on a
  different runtime; secondary to Warth's work here.
