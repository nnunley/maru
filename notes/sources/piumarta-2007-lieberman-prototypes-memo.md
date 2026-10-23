# Efficient sideways composition in COLAs via 'Lieberman' prototypes (Ian Piumarta, VPRI Memo M-2007-002-a, 2007-09-20)

Source: https://tinlizzie.org/VPRIPapers/m2007002a_lieb_proto.pdf (5 pages; a printed web page,
`prototypes.html`). Read in full as text.

## A. Classification

Short design memo with C-like pseudo-code. Shows how prototype delegation in Lieberman's sense (an object
forwards messages it does not understand to another object, with `self` still the original receiver) is
added to COLAs by changing `_bind`, not the object layout.

## B. Unity

Delegation between objects can be added to a vtable-based object model at no cost to objects that don't
use it, by extending bind to walk a chain of delegates only after the ordinary lookup has failed.

## C. Outline of major parts

1. §1: inheritance in COLAs is between vtables (method dictionaries shared by a family), and Lieberman
   prototypes add delegation between objects.
2. §2.2: `_bind` before and after: the one-dimensional lookup through a global cache, then the extended
   version that repeats the lookup for each prototype on the delegation chain.
3. Closing: properties (perfect encapsulation: only message sends cross between prototypes).

## D. Author's central problems

1. Provide object-level delegation ("sideways composition") alongside vtable inheritance.
2. Do it without adding state or cost to ordinary objects.

## E. Key terms

- vtable: a method dictionary shared by all members of a family; inheritance is between vtables.
- `_delegate`: a message answering the next prototype on the chain, or nil.
- global cache: an array indexed by the receiver's vtable, holding a selector and a closure.

## F. Main propositions

F1. Bind probes a global cache indexed by the receiver's vtable and compares the selector; on a miss it sends
`lookup` to the vtable, raises doesNotUnderstand if nothing is found, and fills the entry (§2.2, p. 2).
F2. Delegation is a loop around that lookup: on failure, ask the receiver for its `_delegate` and repeat
(§2.2).
F3. Objects that do not delegate pay essentially nothing: their `_delegate` answers nil and is called only
just before a certain doesNotUnderstand; no state is added to them (§2.2, p. 3).

## G. Critique

G1. The cache shown is indexed by vtable alone, one entry per vtable, so two selectors sent to the same
family evict each other; the shipped runtime hashes vtable and selector together (idst `libid.c:617`).
The memo's version is a sketch.
G2. Cache invalidation is not discussed.

## H. What of it?

1. Delegation is a property of bind, not of the object layout, which keeps Maru free to add it later without
   changing the header.
2. The zero-cost argument depends on delegation being consulted only after a failed lookup; any Maru
   dispatch extension should keep that order.

## Permanent notes extracted from this source

- [[delegation-costs-nothing-for-objects-that-do-not-use-it]]
