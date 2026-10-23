# Back to the Future: The Story of Squeak (Ingalls, Kaehler, Maloney, Wallace, Kay, OOPSLA 1997; VPRI TR-1997-001)

Source: https://tinlizzie.org/VPRIPapers/tr1997001_backto.pdf. Read in full as text.

## A. Classification
Experience report on building a portable Smalltalk whose VM is written in a Smalltalk subset and translated to C.

## B. Unity
A small team got a fast, portable Smalltalk quickly by writing the VM in Smalltalk itself and translating it to C, with an object memory designed for compactness and without an object table.

## C. Outline of major parts
Motivation; the Smalltalk-to-C translator; the object memory (format, headers, GC, become); performance; future work (dynamic translation).

## D. Author's central problems
1. A portable, modifiable VM the team could own. 2. Compact objects without an object table. 3. Keep `become` working without an object table.

## E. Key terms
- compact class index: a 5-bit header field naming one of up to 31 frequently used classes, so the class needs no pointer word.
- header type: 2 bits saying how many header words (1-3) precede the object.

## F. Main propositions
F1. Object pointers are direct 32-bit addresses; there is no object table (Object Memory section).
F2. A one-word header holds a 5-bit compact class index, 6-bit size, 4-bit format, 12-bit hash and 2-bit header type; objects of non-compact classes add a class word, and large objects a size word. About 81% of objects need only the one word (p. ~4, lines 184-212 of the text).
F3. `become` is done without an object table by scanning memory once and rectifying all pointers (line ~241).
F4. Comparing small integers as oops, without untagging, is listed among the performance measures (line ~468).
F5. The VM's own dispatch is a C switch generated from `dispatchOn:in:`, not a vtable.

## G. Critique
The paper does not give the SmallInteger encoding in detail (no bit count is stated); 31 appears only as the compact-class count.

## H. What of it?
A one-word header is reachable without making the header a vtable pointer: index a small table of common classes. Maru's four-word header is the outlier in the lineage.

## Permanent notes extracted from this source
- [[a-one-word-object-header-is-reachable-by-two-routes]]
- [[an-object-table-buys-become-and-enumeration-not-speed]]

Belief check (2026-10-23, with the other STEPS team papers): no shift in
[[native-eval-should-tag-integers-as-eval-c-does]]; the team papers that touch representation
(Squeak, SqueakJS, the 2010 Nothing GC) all use an immediate integer test, and none argues for boxing.
