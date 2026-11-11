
# ForAll

**Summary.** ForAll is a statement form for LObjects' boxes. `{for all c in C | guard} do together {...} for others {...}` runs a body on every box the guard selects in one operation; `do in order` runs it one box at a time. It is two 2011 packages. ForAll-Base holds the vector model it runs on: a box's properties as columns, and the selection as a stack of masks on the process. ForAll-Compiler is an OMeta2 parser and translator from the statement form to Smalltalk sends. Neither is in the Frank image.

## Why

A loop that sends each box a message performs the same operation n times, and it cannot state "every box whose left edge is positive" once. ForAll states the operation with a guard and runs it over the selected elements. In ForAll-Base an expression over `c` is evaluated over the whole column under the current mask, and a `for others` body runs under the complement. The INDEX attributes the form to the Connection Machine's `where`/`elsewhere`. No source in the tree says so, so that attribution is unchecked here.

## How

The compiler's class comment gives the example (ForAll-Compiler, `ForAllParser`, stamped aw, March 2010):

```
{for all c in C | c.left > 0 && c.right < 200} do together {
  if c.left > 0 && c.right < 200
  then {c.color(Color(255, 0, 255, 0))}
  else {c.color(Color(255, 0, 0, 0))}
}
```

It is read and translated with `ForAllParser matchAll: '...' with: #start`, then `ForAllTranslator match: tree with: #trans`. The `for` rule in `ForAllTranslator>>transFor` (yo, 11 March 2010) emits, with a guard and a `for others` body:

```
'(', S, ' forAllSuchThat: [:', x, ' | ', guard, '] do', how capitalized, ': [:', x, ' | ', body, ']', others, ')'
```

This is my reading of the rule, not a run: `{for all c in C | G} do together {B} for others {O}` gives roughly `(C forAllSuchThat: [:c | G] doTogether: [:c | B] forOthersDo: [:c | O])`. With no guard the translator uses `VIdentityMap new`, which selects everything.

The runtime is `VArray>>forAllSuchThat:doTogether:forOthersDo:` (ForAll-Base, enumeration). It computes the selection as a map, composes it with the enclosing mask, and runs the body under it:

```
mask := selectBlock value: self.
elseBlock ifNotNil: [t := mask not].
m := Processor activeProcess mask.
map := mask onTopOf: m.
Processor activeProcess masks add: map.
[return := doBlock value: self] ensure: [Processor activeProcess masks removeLast].
```

Composing with the outer mask is what makes nested for-alls narrow. `Object>>test:ifTrue:ifFalse:` applies the same push and pop to `if`. A defect in the compiler: `%` translates to `\`, but ForAll-Base defines `\\` (the translator's `%%`) and no `\`, so `%` sends a selector this package does not define.

## When

- **ForAll-Base**: `bf.1` (11 Jan 2011, "initial commit"); `yo.2` (18 Jan 2011, uses GeziraBindings' `primitiveTransformPoint`, v1.6); `yo.3` (20 May 2011, "From Moshi 2472"). The method stamps are almost all yo, January to March 2010 (278 of 279), so the code predates its package.
- **ForAll-Compiler**: `bf.1` (6 Jul 2011, "save from Moshi 2609"). The method stamps are aw (36, 9 to 11 March 2010) and yo (2). The grammar is Warth's; bf packaged it.
- **Not in the Frank image.** `frank.changes` and the image hold no `ForAllParser`, `VArray` or `VIdentityMap`. Two things still refer to it. `LesserphicMorph` (LObjects, yo 2011) lists 'ForAll-Base' among its categories, and its example `test24` uses `LBoxArray` and `VFloatArray`, which the image does not define, so the example fails there. Also, LObjects' `VBooleanArray` (an `ArrayedCollection` subclass) shares a name with ForAll-Base's (a `VArray` subclass). Loading ForAll-Base over the image would replace it.
- **Earlier lineage**: STEPS 2010 says "The Forall language is made in Tamicola, and then is used to program the game of 'Life'" (VPRI TR-2010-004, near line 914). That is Tamacola (VPRI TR-2010-002), a different system. I found no code linking it to the Squeak ForAll.
- **Reach for it** when one operation applies to many objects, a guard picks a subset, and the properties are columns that can be operated on whole.

## Family of expression

Data-parallel, masked operations over collections. The same form appears in Nile: Frank's `NileParser` reads `∀ pat eol block epilogue` as `#forAll` (Nile/NileParser.st), and `NileCTranslator` checks that each element is assigned once inside a for-all (`currentForAllAssignments`). The two are one idea at different levels: Nile for kernels over streams, ForAll for box properties in LObjects. ForAll's compiler half is OMeta2 (see [ometa2](ometa2.md)), so it is also one more case of grammar plus translation. The mask is per-process state, pushed and popped around the body with `ensure:`. That is ordinary dynamic scope, and it is not a mechanism ForAll shares with the other Frank parts.

## Links

- [ometa2](ometa2.md): the parser and translator are OMeta2 grammars.
- Maru, in this repository: no ForAll code. A search of the tree finds only Nile compiler text and a Nile law fixture. The nearest counterpart is the Nile side, in the `nile/` submodule (`nile/compilers`, `nile/runtimes`).

## Sources

- package ForAll-Base, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package ForAll-Compiler, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip)
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), class LesserphicMorph
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), class VBooleanArray
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), class NileParser
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), class NileCTranslator
- STEPS 2010 report, VPRI TR-2010-004
- VPRI TR-2010-002 (Yamamiya and Ohshima, Tamacola)
