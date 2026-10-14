# An association-based model of dynamic behaviour (Ian Piumarta, FREECO'11, VPRI TR-2011-003) — skim only

Source: http://piumarta.com/freeco11/freeco11-piumarta-abmdb.pdf (also
https://tinlizzie.org/VPRIPapers/tr2011003_abmdb.pdf).

**Inspectional read; not read analytically.** The paper proposes that most organisations of state
and behaviour in dynamic languages can be built from one primitive: an n-way associative memory
with associative read and write. Its examples include single and multiple dispatch, object fields,
arrays, environments, inheritance and delegation, and versioned or "worlds"-style state, if time is
treated as just another key. Each is shown as a parameterisation of that memory.

The author's conclusion says plainly that it is meant to provoke thought, and that the
interesting challenges are management (especially garbage collection) and efficient
implementation, possibly in hardware.

Booth step 3 fails for this read. It bears on Maru's object model only as a generalisation of
the type-indexed tables in the companion paper ("Open, extensible composition models"). It says
nothing about bootstrapping, grounding, compilers or line budgets, so I stopped at inspection.
If the rebuild ever unifies `*evaluators*`/`*applicators*`, selector method tables and generic
function tables into one structure, read this one analytically.
