# The grounded kernel

Maru's evaluator written in typed Maru through ir2, on the object level (doc/ir2-objects.md), aligned on eval3.c
(Piumarta, 2013). It runs natively and through C. The plan is doc/plans/2026-11-12-kernel-on-eval3.md. Its grounding is
oecm (TR-2011-002) §5.1, which keeps the grounded part minimal (dispatch from type to meaning, and the `<subr>` call),
and colaswp (RN-2006-001-a) §6.1, which reimplements the static layer one level up. eval, eval2 and eval3 stay as
the oracles.

`kernel.k` loads the sections in eval3's order, after maru-gc.k less its main. Only the objects are written so far.

## Objects (`kernel-objects.k`)

- **Types.** eval3's 13 built-in types (eval3.c:87) carry boot2.l's fields (boot2.l:425–437). The ids, 0 … 12, are
  the kernel's own. They are not read from the host running maru.k: the contract is with the boot file the kernel
  loads, which declares its built-in types in the same order.
- **Atoms** (no field the collector traces) are `<data>`, `<long>`, `<double>`, `<symbol>` and `<subr>`.
- **Characters.** A string's and a symbol's characters are `wchar_t` (four bytes here), as eval3 keeps them.
  - A string's live in managed memory: `gc_malloc_atomic`, kept alive through the string's `bits` field.
  - A symbol's are malloc'd and never freed, as eval3's `wcsdup` leaves them.
- **Constructors**: `k_newData`, `k_newLong`/`k_getLong`, `k_newDouble`/`k_getDouble`, `k__newString`,
  `k_newStringC`, `k_newSymbolC`, `k_cons`, `k_newArray`, `k_newExpr`, `k_newForm`, `k_newFixed` and `k_newSubrC`.
  Each is eval3's, `k_`-prefixed; `C` marks one that takes a C string, widened as eval3's `mbs2wcs` widens it.
- **A `<subr>`'s `imp`** is a function pointer of `(arguments env)`, called through the field.

## Departures from eval3

- **The collector is maru-gc.k**, not gc.c, until the plan's step 2a ports gc.c's design as `kernel-gc.k` (per-object length, ephemerons, heap limits).
- **`k_cons`, `k_newForm` and `k_newFixed` root their arguments** while they allocate. eval3 leaves that to its
  callers.
- **A failed type check is fatal**, as eval3's is, until the REPL's error handling comes (Task 6).

## Checks

- `kernel_native` (`check/kernel.l`, on eval2): each unit in `check/kernel/` is compiled natively after maru-gc.k
  and kernel.k, and its main runs in a child.
- `kernel_c` (`check/check.l`): the same units through ir-gen-c.k and the C compiler.
- `check/kernel/objects.k` asserts:
  - each type's id;
  - a pair's string head (its characters and size) and long tail;
  - a double, a symbol's characters, an array of 100, and an expr's three fields;
  - a subr called through its `imp`, natively too;
  - a list of 2,000 rooted pairs summing correctly with a collection on every allocation (`gc_frequency` 1).
