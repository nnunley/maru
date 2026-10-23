# Smalltalk-80: The Language and its Implementation, Part Four (Adele Goldberg & David Robson, 1983), object memory chapters

Source: https://web.archive.org/web/20110718042526id_/http://stephane.ducasse.free.fr/FreeBooks/BlueBook/Bluebook.pdf
(the free copy hosted by Stéphane Ducasse; 742 pages). Read only Part Four's object memory material
(Ch. 26 interface, Ch. 30 formal specification), as text; the Ch. 26 figures OCR poorly. Page numbers are
the book's.

## A. Classification

Textbook and formal specification: Part Four defines the Smalltalk-80 virtual machine in Smalltalk itself.
Only the representation of object pointers is used here.

## B. Unity (of the part read)

The object memory hides how objects are stored behind an interface of object pointers, classes and fields;
the reference implementation uses 16-bit pointers that are either object-table indices or immediate
integers.

## C. Outline of the part read

- Ch. 26: the object memory interface (an object pointer is associated with a class and 8- or 16-bit fields,
  p. ~570).
- Ch. 30: the formal specification of the object table and heap (p. 661 onward).

## D. Author's central problems

1. Specify an object memory precisely enough to implement, independent of the interpreter.
2. Fit useful integers into 16-bit pointers without heap allocation.

## E. Key terms

- object table: the table that maps an object pointer to the object's location in the heap.
- SmallInteger: an immediate integer held in the pointer.
- NilPointer: the object-table index of nil.

## F. Main propositions

F1. If the low-order bit of an object pointer is 0, the other 15 bits index the object table; if it is 1,
they are an immediate signed integer, using no object-table entry or heap space (Ch. 30, p. 661).
F2. Nil is an ordinary object at a fixed object-table index, `NilPointer` (Ch. 30, constants, p. ~662).

## G. Critique

Not critiqued; read only for the representation facts above.

## H. What of it?

The low-bit-one SmallInteger tag that Piumarta's 1992 thesis, the COLA runtime and Maru's `eval.c` use is the
Blue Book's. What changed later is nil: the Blue Book and the thesis make nil an ordinary object; COLA makes
it the zero pointer for compatibility with C.

## Permanent notes extracted from this source

- [[low-bit-integer-tags-rely-on-aligned-object-pointers]]
