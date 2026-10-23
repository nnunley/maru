# The Early History of Smalltalk (Alan Kay, HOPL-II 1993)

Source: image-only PDF from the VPRI listing, OCR'd with tesseract; read the messaging, FLEX and B5000 sections. Line numbers refer to the OCR text and are approximate.

## A. Classification
Historical memoir by the language's designer: the ideas behind objects and messaging, 1966-1980.

## B. Unity
Objects are whole computers in miniature that communicate only by messages, an idea assembled from Sketchpad, Simula, the B5000 and LISP.

## C. Outline of major parts
Background (1960-66); FLEX; Smalltalk-71/72/76/80; reflections.

## D. Author's central problems
Find a single, scalable building block for software and for children's learning.

## E. Key terms
- FLEX descriptor: an object reference with two pointers, to the object's "master" and to the instance.

## F. Main propositions
F1. Objects should privately own all of their behaviours: an object is a kind of mapping whose values are its behaviours (line ~529).
F2. Each object can be seen as a syntax-directed interpreter of the messages sent to it (line ~725).
F3. Object references generalise B5000 descriptors; FLEX's descriptor held two pointers, to the object's "master" and to the instance, and "later we realized that we should put the master pointer in the instance to save space" (lines 517-520).
F4. The tenets: everything is an object; objects communicate by messages; objects have their own memory; every object is an instance of a class; the class holds shared behaviour.

## G. Critique
A memoir; claims are about intent, not implementation.

## H. What of it?
The FLEX descriptor (behaviour pointer plus instance) is the ancestor of COLA's header word, and "object as interpreter of messages" is the intent COLA's replaceable `lookup` serves.

## Permanent notes extracted from this source
- [[an-object-is-an-interpreter-of-the-messages-sent-to-it]]
