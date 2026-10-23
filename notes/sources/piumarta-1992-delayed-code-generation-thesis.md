# Delayed Code Generation in a Smalltalk-80 Compiler (Ian Piumarta, PhD thesis, University of Manchester, October 1992)

Source: https://web.archive.org/web/2010id_/http://www.wolczko.com/mushroom/theses/piumarta.ps.gz (PostScript,
97 sheets of two printed pages). Read as text (`pdftotext -layout` of the `ps2pdf` output); the two-column
layout interleaves listings, so load-bearing listings were checked on the page image (PDF p. 45). Page numbers
are the thesis's printed pages.

## A. Classification

Doctoral thesis in language implementation. Constructive: a Smalltalk-80 compiler for the Motorola 68020 whose
code generator delays emitting code for an expression until its consumer is known, plus measurements against
ParcPlace PS2.3. Evidence is the implementation, listings and benchmark tables.

## B. Unity

A Smalltalk-80 compiler can produce good native code on stock hardware if code generation is delayed until
the context of each value is known, so that special selectors, literals and stack traffic are compiled for
how they are used rather than one bytecode at a time.

## C. Outline of major parts

- Ch. 3 (pp. ~20-40): Smalltalk implementation background, PS2.3, method caches and inline caches (3.1.1.3).
- Ch. 5 (pp. 53-90): the 68020 native-code Smalltalk: object memory and object table (5.1.1, pp. 53-55),
  frames (p. 59), sends (p. 75), special selectors and inline arithmetic (pp. 85-88).
- Ch. 6 (pp. ~100-130): delayed code generation; inlined arithmetic on tagged integers (Fig. 6.4, pp. 117-118).
- App. E.3 (pp. 179-184): profiling of dynamic binding; inline-cache design; cache interference and consistency.

## D. Author's central problems

1. Smalltalk sends are dynamically bound, and on stock hardware binding dominates run time.
2. Special arithmetic selectors must run at machine speed without abandoning dynamic typing.
3. A code generator working bytecode by bytecode emits code for values before it knows how they are used.

## E. Key terms

- OOP: object pointer; here a byte offset into the object table, a multiple of eight.
- SmallInteger: an immediate integer encoded in the OOP itself.
- method cache: global, keyed on (class, selector), holding the method's address.
- inline cache: per send site; the callee's prelude checks the receiver's class against the class cached at
  the site.
- special selectors: the 32 selectors PS2.3 sends with dedicated bytecodes; 16 are arithmetic.

## F. Main propositions

F1. SmallIntegers are 2n+1: because real OOPs are multiples of eight, odd pointers can be integers and even ones
objects (5.1.1, p. 55). The tag goes at the low end because high-end tags cost sign extension; a high-end tag
would make immediate checks a single `bne` (p. 55 fn. 3). Only SmallIntegers are immediate (fn. 4).

F2. Memory is an object table plus object memory; each allocated object has a two-word header holding its
class and its size in bytes (pp. 53, 55). Nil is an ordinary object, not a bit pattern (p. 59).

F3. Arithmetic special sends compile inline: test bit 0 of receiver and argument, do the operation, fall back
to a full send (pp. 87-88). The inline code does not check overflow, and inlining means a redefinition of
SmallInteger arithmetic has no effect, which the thesis notes is also true of any Blue Book implementation
(p. 88 fn. 30). The printed listing's branch (`btst #0` then `jne fullSend`) goes to the full send when bit 0
is set, the opposite of its prose; the later listing (`btst #0,d0; jeq … no`) has the right sense, so the
first is a typo.

F4. Even with the global method cache hitting essentially always, the runtime spends "a preposterous amount
of time" in dynamic binding: 43.3% of run time in the profile (App. E.3, pp. 179-180).

F5. Inline caches remove most of that cost. The chosen design caches the destination method's OOP, not its
address, which "simplifies garbage collection enormously", keeps the caches in a silo at the end of each
method, and checks the receiver's class in the callee's prelude (E.3.1-E.3.2, pp. 179-182). PS2.3 reported
85-90% method-cache and 95% inline-cache hit rates, the inline cache gaining 10% at five times the code size
(pp. 33-34).

F6. "The method cache is fairly easy to purge, but an inline cache presents a much more serious problem"
(E.3.4, p. 184): the options are trawling out-of-line structures, a map of sites, or scanning code for a
signature. Sends shared between deferred contexts make inline caches thrash (E.3.3, p. 183).

## G. Critique

G1. The arithmetic listing on p. 88 has its branch sense inverted (F3). Harmless to the argument, but a reader
copying the listing gets the wrong code.
G2. The representation decisions (low-bit tag, object table) are justified briefly, against one machine; the
evidence is the implementation, not a comparison.
G3. Inline arithmetic without overflow checks is acknowledged (fn. 30) but not measured.

## H. What of it?

1. The low-bit integer tag and the alignment argument for it are Piumarta's from 1992, fifteen years before
   COLA; Maru's `eval.c` inherits the same encoding.
2. The thesis already identified inline-cache invalidation as the hard part. COLA shipped a global cache
   with a selector flush by default; a Maru native back end should do the same before adding inline caches.
3. Inlining arithmetic fixes the meaning of integer operations at compile time. If Maru's native evaluator
   inlines tagged arithmetic, that loss of redefinability is a decision to record, not an accident.

## Permanent notes extracted from this source

- [[low-bit-integer-tags-rely-on-aligned-object-pointers]]
- [[inline-caches-are-harder-to-invalidate-than-a-method-cache]]
- [[inlining-integer-arithmetic-gives-up-redefining-it]]
- [[dynamic-binding-dominates-sends-even-with-a-perfect-method-cache]]

Belief: no shift in the tagging belief, which this strengthens (the encoding is Piumarta's since 1992); review entry added.
