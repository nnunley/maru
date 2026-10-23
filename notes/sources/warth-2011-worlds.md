# Worlds: Controlling the Scope of Side Effects (Alessandro Warth, Yoshiki Ohshima, Ted Kaehler, Alan Kay, ECOOP 2011; VPRI TR-2011-001)

Source: https://tinlizzie.org/VPRIPapers/tr2011001_final_worlds.pdf. Read in full as text.

## A. Classification
Language design paper with JavaScript and Squeak prototypes: first-class "worlds" that capture the side effects of a computation so they can be committed or discarded.

## B. Unity
State can be versioned by context without changing object identity: each world maps the same object to its own view of the object's slots, delegating to its parent world for slots it hasn't touched.

## C. Outline of major parts
Motivation; the worlds construct (sprout, commit); semantics; implementation (§5: per-world tables keyed by object, slot-level delegation, a lookup primitive); evaluation.

## D. Author's central problems
Let programs try changes speculatively and undo them, without copying the world.

## E. Key terms
- world: a scope of state; a child world sprouted from a parent sees the parent's state until it writes.

## F. Main propositions
F1. An object's identity is universal; each world associates it with that world's state for it (§3, line ~155).
F2. The per-world tables are keyed by the object itself, because "the identity of an object never changes, no matter what world" it is in (§5.2, line ~618).
F3. Slot reads delegate to the parent world when the slot is unknown in the current one; making this lookup a primitive gave a significant speedup (§5).

## G. Critique
Not critiqued beyond the points used.

## H. What of it?
Versioned or contextual state can be added later as a slot-access layer, provided the oop stays a stable identity. Maru's representation choice does not need to anticipate it.

## Permanent notes extracted from this source
- [[object-identity-can-stay-fixed-while-state-varies-by-context]]
