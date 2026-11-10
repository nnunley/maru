# Errors, worlds and unwinding

`catch.l`'s native catch and throw, and `recover.l`'s conditions and undo-log worlds.

## Checks

- `catch` (`check/catch.l`): `catch.l`'s `catch`, `throw` and `unwind-protect`, in native stubs with no C. `abi.spec` says what each
  calling convention keeps where, `stub.l` writes a stub once as intents, `stub-arm64.g` and `stub-x64.g` lower them by tree
  matching to encoder forms, and the result is a primitive like the evaluator's own (`allocate-atomic`, its function the stub).
  On every evaluator and instruction set the host has: through deep frames and C, with the collector's roots restored.
- `recover` (`check/recover.l`): `recover.l`. `error` and C's `fatal` signal a condition a handler sees where it happened, and
  `try` runs its body in a world, an undo log (its logic `undo.irl`, compiled to `undo-irl.c`; `undo.c` is what it needs of each evaluator's objects): if it fails, every write through a primitive is undone (Warth's
  Worlds, 3.1). Reads cost nothing and C sees current values; raw memory, the evaluators' tables, files and foreign state
  aren't covered. A definition is undone like a write, though on `eval` a name new in the world stays bound. A value leaving a failed
  world keeps what it was made with. With no handler, errors end the program as before. `gc_image` checks a loaded image's heap.
- `undo_irl`: `undo-irl.c`, which every evaluator includes, is what `undo.irl` compiles to; `make undo-irl` rewrites it.
