-- Test kernels for the twin laws (check/laws/gezira-twin.law, check/laws/gezira-algebra.law), compiled after gezira.nl
-- into the twin's builds only: Nile's own floor and ceiling, each a kernel, so a law can hold them to mathematics.
Floors () : Number >> Number
    ∀ x
        >> ⌊x⌋

Ceilings () : Number >> Number
    ∀ x
        >> ⌈x⌉
