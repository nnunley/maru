# SqueakJS: A Modern and Practical Smalltalk that Runs in Any Browser (Freudenberg, Ingalls, Felgentreff, Pape, Hirschfeld, DLS 2014)

Source: Tufts-hosted PDF found by web search (saved locally); read in full as text, §3.1-3.3 closely.

## A. Classification
Implementation paper: a Squeak VM in JavaScript that runs unmodified Squeak images.

## B. Unity
A Smalltalk VM can lean on a host's objects and garbage collector if it keeps just enough of its own structure for the operations the host can't provide.

## C. Outline of major parts
§3.1 object representation; §3.2 garbage collection and enumeration; §3.3 execution.

## D. Author's central problems
Run Squeak at usable speed in a browser, reusing the JavaScript engine's objects and GC.

## E. Key terms
- oop: here a number used as identity, not an address.

## F. Main propositions
F1. Each Squeak object is a JavaScript object with class, format, hash and slot arrays; SmallIntegers are plain JavaScript numbers, told apart by a `typeof` check; floats are boxed (§3.1).
F2. Special objects get flags (nil has `isNil`) so tests need no comparison (§3.1).
F3. There is no object table; because JavaScript has no weak pointers, old objects are chained through `nextObject` for enumeration, and `become` keys on the oop number (§3.2).

## G. Critique
Not critiqued beyond the points used.

## H. What of it?
Shows which runtime features actually need an object table or explicit object list (enumeration, become) and which do not.

## Permanent notes extracted from this source
- [[an-object-table-buys-become-and-enumeration-not-speed]]
