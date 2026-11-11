
# J: an array-language interpreter in Squeak (2014)

J is Yoshiki Ohshima's July 2014 interpreter for the J array language, written in Squeak. It has a parser (JParser), an interpreter (JInterpreter), an array class (JArray), a text editor that evaluates a selection (JEditor) and a workspace that uses it (JWorkspace). Words are shifted onto a stack and reduced from its right end, as J's right-to-left rule needs. Verbs (`+`, `%`, `i.`, `?`), adverbs (`/`, `~`), conjunctions (`&`, `"`, which sets rank) and trains (forks) are all implemented. This is J, the array language. It is not JOHN, Samimi's planning language (see [JOHN](../john.md)). No paper in the corpus describes the J language. The code and the version record are the only sources here.

## Why

The version messages show the aims. J-yo.1 (13 July 2014) is "Initial version." J-yo.5 (16 July) says "train works." J-yo.9 (23 July) says "Rank conjunction parses and executes." J-yo.11 (24 July) says "JWorkspace added. i. added." J-yo.14 (29 July) says "roll and deal added." J-yo.16 (30 July) says "ravel almost working, but the semantics of it with the rank operator is not right." J-yo.17 says "All tests passes." J-yo.19 (31 July) says "Make sure it works in a clean image." The aim is a working array language inside a Squeak workspace. The INDEX.md entry says "an interpreter, parser and editor for J arrays: after Frank."

## How

Evaluating a sentence is a parse followed by an interpretation, both OMeta2 matches (JInterpreterTest>>testMonad0):

    tree := JParser matchAll: '+/ 1 2 3' with: #sentence.
    result := JInterpreter match: tree with: #sentence withArgs: {nil}.
    result = 6.

Outer product (JInterpreterTest>>testOuter0). Here `+/` is the dyadic adverb `/` applied to `+`, the outer product, so the 3-vector `4 4 4` against the 3-vector `1 2 3` gives a 3 by 3 table:

    tree := JParser matchAll: '4 4 4 +/ 1 2 3' with: #sentence.
    result := JInterpreter match: tree with: #sentence withArgs: {nil}.
    result shape = #(3 3).
    result data = {5. 6. 7. 5. 6. 7. 5. 6. 7}.

A fork, or train (JInterpreterTest>>testTrains0). The sum divided by the count is the mean:

    tree := JParser matchAll: '(+/ % #) 1 2 3 4 5' with: #sentence.
    result := JInterpreter match: tree with: #sentence withArgs: {nil}.
    result = 3.

In a workspace, JEditor>>evaluateSelectionAndDo: parses the selected text with `JParser matchAll: ... with: #sentence` and runs it with the workspace's `bindings`, so names assigned earlier stay defined. JWorkspace class>>open opens one, and its buildWith: installs JEditor as the editor class of the text.

The array itself (JArray class>>new:data:offset:) is a shape, a flat Array of data and an offset. A cell is a view, not a copy. JArray>>cellAt:rank: returns `JArray new: (shape copyLast: rank) data: data offset: newOffset`, so a row shares the table's storage.

## When

- **Dates and authors.** J-yo.1 (13 July 2014) to J-yo.19 (31 July 2014). All 19 versions are by yo, and the record holds all of them. INDEX.md's first date, 2014-07-15, is the server's upload time for J-yo.1 (packages.tsv, 2014-07-15 23:28, UTC). The record's 13 July 2014 6:46 pm is when the version was saved, in local time. Both are right; they measure different things.
- **Status.** Not in the Frank image (INDEX.md). The last version is "Make sure it works in a clean image." The package has 17 test methods, in JArrayTest (4), JInterpreterTest (9) and JParserTest (4). I did not run them. The source has three lines that end in `..`, a double period: in `doDyad:with:lRank:rRank:`, `makeArray:with:` and `reduce:with:rank:into:offset:`. The methods carry change stamps (`doDyad:` is stamped 7/30/2014 20:26), and Squeak saves a method only once it compiles, so they probably compile. `?` and `deal` are tested by range, not by value (JInterpreterTest>>testRandom), because they use Random.
- **Reach for it** when you want a small, readable model of rank-polymorphic array operators built on ordinary Smalltalk objects. It is also a worked example of a parser and interpreter written as OMeta2 rules. It is not a path into Frank's documents, and nothing in the Maru repository uses it.

## Family of expression

The J code applies one operator to whole arrays and lets the rank decide how far down the cells it goes (JInterpreter>>doDyad:with:lRank:rRank:). Kay describes Smalltalk's own `+` and `*` as having senses "that go beyond simple APLish generalizations of scalar operators to arrays" (Kay, "The Early History of Smalltalk" (1993)). The STEPS 2010 report makes the same comparison for Nile, which it calls "a little like a 'parallel stream-based APL'" (VPRI TR-2010-004).

ForAll is the other data-parallel form in this set. It is also an OMeta2 grammar, but its unit is a selection of boxes: `{for all c in C | c.left > 0 ...} do together {...} for others {...}` (INDEX.md, the ForAll section; ForAll-Compiler's ForAllParser). J's parallelism comes from ranks on verbs, and ForAll's comes from a predicate over a collection. See [forall](forall.md).

## Links

- Related: [forall](forall.md), [ometa2](ometa2.md), [siss](siss.md), [silt](silt.md)
- Not JOHN: [JOHN](../john.md) (Samimi's planning language, a different language with the same initial)
- Maru repository (this repository): none. The repository has no J code.

## Sources

- package J, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package ForAll-Compiler, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- https://tinlizzie.org/updates/exploratory/packages/
- STEPS 2010 report, VPRI TR-2010-004
- kay-1993-early-history-of-smalltalk
