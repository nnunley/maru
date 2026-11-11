
# OMeta2

**Summary.** OMeta2 is Alessandro Warth's pattern-matching language, ported to Squeak. A rule is a parsing expression grammar (PEG) production with a semantic action, and it matches any sequence: characters, lists or objects. Frank's image ran it: 22 classes in the `OMeta2` category, with the package-info classes that store the rules. The Monticello packages are OMeta2-Preload (classes plus a decompiler), OMeta2-Postload (the rules in source form) and OMeta2Experiments (an instrumented matcher, not in the image).

## Why

Tokenizers, parsers, visitors and tree rewriters are usually built with different tools (lex, yacc, the visitor pattern). The 2007 paper argues that one notation can do all of them: a PEG extended to match arbitrary data, with host-language actions on each match (VPRI TR-2007-003, section 1). The OMeta2 form keeps the PEG core: ordered choice `|`, repetition, negative lookahead `~`, predicates `?[...]`, and actions `-> [...]`. Left recursion is supported by growing a seed. The 2008 paper gives the algorithm (VPRI TR-2007-002, GROW-LR). `OMeta2Base>>apply:` implements it: a failer is stored before the rule runs, and if the rule calls itself the result is repeated until it stops growing.

## How

Rules are compiled when a class is defined. The chain is `OMeta2RuleParser`, `OMeta2Optimizer`, `OMeta2RuleTranslator`, `OMeta2Flattener`, then Squeak's `Compiler` (`OMeta2Compiler>>compile:in:notifying:ifFail:`, OMeta2-Preload). OMeta2's own primitives are OMeta2 rules (OMeta2-Postload, class `OMeta2`):

```
char =
	anything:x ?[x isCharacter] -> [x]
```

Left recursion and list matching, from `OMeta2Examples` (OMeta2-Preload):

```
number =
	number:n digit:d -> [n * 10 + d]
|	digit
```

```
OMeta2Examples matchAll: '1234' with: #number.
OMeta2Examples matchAll: #($a $b $c 1 2 3 #(4 5)) with: #structure.
```

The second line matches a list, because `{anything*}` in a rule matches the elements of a sequenceable collection (`OMeta2Examples>>structure`). Rules may take parameters, as in `listOf :rule :delim` (OMeta2-Postload):

```
listOf :rule :delim =
		apply(rule):x (token(delim) apply(rule))*:xs -> [xs addFirst: x; yourself]
	|	empty -> [#()]
```

Maru reads the same rule text. `ometa2.g` is a tpeg grammar for it; its header lists the operators: `x:name`, `&x`, `~x`, `?[test]`, `-> [expr]`, `{ ... }` for a list, `< ... >` for matched text.

## When

- **2007**: the DLS paper. Its Squeak implementation does not memoize (section 2.4); the COLA one memoizes productions without arguments. OMeta2's `apply:` memoizes per input position, so it is a later design.
- **Feb 2009**: OMeta2 classes start (Warth's stamps run from 2/16/2009). Warth's dissertation (VPRI TR-2008-003) names OMeta/Squeak as one of its three implementations.
- **Apr 2010**: the Preload/Postload split (hmm, 16 April). On 30 April 2010 Warth changed his initials from `aw` to `warf`.
- **Jul 2011**: Postload and Preload `bf.12` (`fix OMeta2>>range`).
- **Aug 2012**: Preload `yo.14` merges a decompilation fix.
- **Nov 2012**: `ael` adds an instrumented `apply:` (Preload `ael.15`), reverts it (`ael.16`, "moved to OMeta2Experiments"). OMeta2Experiments (ael, 21 to 28 Nov 2012) holds that matcher: it records which rule applications built each node, for `OMeta2Exerciser`. Frank's `OMeta2Base>>apply:` is the plain version.
- **Status**: loaded in the image. The Maru tree runs KSWorld's KScript2 grammar classes as OMeta2 classes (`ometa2.l`, `ksworld/KSParser2.st`). STEPS 2010 calls OMeta "the workhorse of STEPS" (VPRI TR-2010-004, section 6).
- **Reach for it** when a grammar and its translation should be one object, or when the input is not characters (token lists, trees).

## Family of expression

Grammars with pattern-directed translation. The family is PEG parsing with actions: Maru's `peg.l` and `tpeg.g` are the same core, and STEPS's "Nothing" target is written in OMeta ("a little like a BNF that transforms", VPRI TR-2010-004, section 6). Within Frank the one notation carries both the ForAll parser and its translator (see [forall](forall.md)), so parsing, transformation and emission are all rules. OMeta2Experiments belongs to the same family: it keeps parse information about the rules alongside the grammar, and adds no new notation.

## Links

- [forall](forall.md): a language whose parser and translator are OMeta2 grammars.
- Maru, in this repository: `ometa2.g` (OMeta2 rule syntax as a tpeg grammar), `ometa2.l` (runs OMeta2 classes from their sources on Maru's PEG), `ometa2.st` (class `OMeta2` in Maru's own form), `check/ometa2.l` (registered in `check/check.l` as the `ometa2` case), `peg.l` and `tpeg.g` (the PEG underneath), and the `recursion` case in `check/check.l` (left recursion).

## Sources

- package OMeta2-Preload, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package OMeta2-Postload, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package OMeta2Experiments, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- https://tinlizzie.org/updates/exploratory/packages/
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), package OMeta2
- the Frank image (https://tinlizzie.org/~ohshima/Frank-170908.zip), class OMeta2Base
- VPRI TR-2007-003 (Warth and Piumarta, OMeta)
- VPRI TR-2007-002 (Warth et al., left recursion)
- VPRI TR-2008-003 (Warth, thesis)
- STEPS 2010 report, VPRI TR-2010-004
