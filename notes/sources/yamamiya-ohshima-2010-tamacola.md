# Tamacola: A Meta Language Kit for the Web (Takashi Yamamiya & Yoshiki Ohshima, 2010; VPRI TR-2010-002)

Source: https://tinlizzie.org/VPRIPapers/tr2010002_tamacola.pdf. Read sections 2, 3 and 5.

## A. Classification
Design and implementation report: a Scheme-like meta-language with a PEG-based compiler, hosted on Adobe's Tamarin (ActionScript, AVM2) VM.

## B. Unity
COLA's ideas (grammars, self-description) can be carried to the web by compiling to an existing VM, at the price of the parts of COLA that need control of the VM.

## C. Outline of major parts
§2 relation to COLA and what the host forbids; §3 the language and compiler; §5 performance notes.

## D. Author's central problems
Bring a COLA-like meta-language to browsers, where only the host VM's bytecode can run.

## E. Key terms
- AVM2/Tamarin: the ActionScript virtual machine Tamacola targets.

## F. Main propositions
F1. On a third-party VM, Tamacola "cannot change the method lookup logic, nor can it change objects' layout in memory", unlike COLA, which implements its own kernel (§2.1).
F2. Message sending on the host is relatively slow, so translated code avoids it (§5).
F3. Objects, slots and classes map onto AVM2's (`send`, `slot-ref`, `class` forms) (§3).

## G. Critique
Not critiqued beyond the point used.

## H. What of it?
The team's own statement of what a host VM takes away: the two things COLA made replaceable, lookup and layout. Maru's native evaluator keeps both because it owns its runtime.

## Permanent notes extracted from this source
- [[a-host-vm-takes-away-control-of-lookup-and-layout]]
