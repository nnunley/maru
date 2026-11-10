# Typed Maru (ir2) and the C back end

`maru.k`'s typed language, its sizes from `osdefs.k`, and `ir-gen-c.k`.

## Checks

- `osdefs`: `osdefs.k` agrees with the compiler's predefined macros.
- `maru_test`: a program compiled through the ir2 C backend computes primes
  and struct arithmetic.
- `ir2` (`check/ir2.k`): sizes, alignment and struct padding match `osdefs.k`;
  pointer offsets of any integer width move by bytes at full pointer width; an indexed element is an lvalue, as in C,
  so a struct in an array has its fields read and written in place and `(addressof (indir s i))` is i elements in.
- `core_forms` (`check/core-forms.l`): arithmetic, comparison and logical
  forms give the same values untyped and through `maru.k`.
- `zero_global` (`check/zero-global.k`): a global declared with no
  initialiser, `(define (name T))`, starts at zero, for a scalar and a struct.
- `maru_check`: upstream's own ir2 test, `maru-check.k`, passes all sections.
- `maru_label`: Piumarta's `maru-label.k`, through the C back end: `label` and
  `goto`, plain, computed from an `if`, and through a label held in a variable.
- `exit_status` (`check/exit-status.k`): a typed program's exit status is what its `main` answers, through `ir-gen-c.k`'s
  C `main` (it answered 0 whatever `main` returned, so checks reading a typed program's status were weaker than they read).
- `ir_retired`: `ir.k` and irgol are gone, and `irl.g` and `compile-irl.l`
  have no `ir-` form.

Not yet described here (each has a comment above it in `check/check.l`): `library_mode`.
