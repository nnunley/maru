# Open, extensible object models: DLS 2006 talk slides (Ian Piumarta, 2006)

Source: https://www.piumarta.com/pepsi/DLS-2006-slides.pdf (42 pp.). Read in full as text.

## A. Classification

Conference talk slides accompanying the Piumarta & Warth object-model paper (Dynamic Languages Symposium
2006). Summary material; no new evidence beyond the paper.

## B. Unity

The same as the paper: a minimal object is a pointer with its vtable one word before it, and sending is
lookup in that vtable followed by a call.

## C. Outline of major parts

The minimal object (p. 10: `send := object[-1].lookup(message); method(object, ...)`); objects make no
assumptions about contents (p. 9); revised vtable methods with `object → self[-1]` (p. 15); "topics not
discussed".

## D. Author's central problems

Those of the paper (see `piumarta-warth-2006-open-reusable-object-models.md`).

## E. Key terms

As in the paper.

## F. Main propositions

F1. Objects carry no assumptions about their contents; implementation is decoupled from representation
(p. 9).
F2. "Topics not discussed" lists "implicit types: tagged immediates; NULL pointer as nil object" (p. ~38):
the only 2006 statement of both conventions outside the paper's footnote 4.

## G. Critique

Slides; nothing to critique beyond the paper.

## H. What of it?

Confirms that tagged immediates and nil = NULL were deliberate parts of the 2006 design, left out of the
paper's main text.

## Permanent notes extracted from this source

No new zettels; confirms [[nil-and-small-integers-are-objects-without-bodies]]. No belief shift: the slides
restate the paper.
