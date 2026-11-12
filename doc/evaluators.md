# Evaluators and boot files

The three evaluators (`eval`, `eval2`, `eval3`), what they share through `boot.l` and `boot2.l`, and their primitives.

## Checks

- `eval3`: `eval3` runs `boot2.l` with the `boot2_strings` and `asm_interface`
  cases, and `dlextern` (`check/dlextern.l`, as `libsdl2.k` uses it) calls libc
  through `subr` in `eval3` and `eval2` alike.
- `eval2_subr` (`check/eval2-subr.l`): every evaluator calls C through `subr`,
  by name or address, with typed results (`"dd>d"`; `>s` copies a `char *` into a string, `NULL` being nil; `>v` calls a void function, its result nil), variadic
  calls and raw byte access. On `eval` a function `subr` made by name survives a saved image: it keeps a copy of its name and
  its signature's text, which the image holds and loading reads again.
- `data_length` (`check/data-length.l`): on `eval` and `eval3`, `(data-length d)` is the length `(data n)` was made with,
  kept in the object's header, not the collector's block size (often larger), and kept across a saved image (`gc_image`).
  Reads and writes past it are refused, and so are a negative index (which would reach the header) and an index whose
  byte offset overflows; the bounds check compares without a sum that could wrap, and a refusal's condition names it
  (`byte-at: index (n) out of range`). Every object's header holds the size it was made with, so a Data `allocate-atomic`
  made answers its own length, not a freed block's.
- `byte_bounds` (`check/byte-bounds.l`): on all three evaluators, raw access to any object (a pair, where `eval2` has no
  Data) refuses an index before its start or one whose byte offset wraps.
- `boot_forms` (`check/boot-forms.l`): on every evaluator, the class and dispatch forms `boot.l` and `boot2.l` share, with the
  same text: `define-structure`, `define-class` (a class extends its base's fields), `make` with keyword pairs (Piumarta's 2013
  form; `boot.l` had kept the older association form), methods reading fields as `self.x`, and selectors inheriting through
  the bases. `define-selector` reads a binding through `%binding-value`, a `<variable>` on `eval` and a pair on `eval2` and
  `eval3`, and `test-pepsi.l` uses the boots' `define-class` rather than a copy.
- `equal_selector` (`check/equal.l`): on every evaluator, Maru's `equal` and `equal-hash` are selectors (`boot.l`, `boot2.l`),
  each type's equality defined with the type: numbers by value (2 is 2.0), strings by their text, pairs and arrays by their
  elements (a list along its spine in a loop, 100,000 long without a frame each), anything else itself unless its type defines
  both (as `<ks-point>` does, by x and y), and equal values hash alike, so a table finds a key by an equal one. A type
  that defines `equal` but not `equal-hash` can't be hashed: an error names it, where an equal copy would quietly be missed.
- `boot2_strings` (`check/boot2-strings.l`): `boot2.l`'s Maru definitions of
  `string-copy`, `string-compare`, `long->string` and `string->long` behave
  as `eval`'s C primitives do (the cases pass under both evaluators).
- `cross_eval`: on arm64 macOS with Rosetta, `bin/x86_64/eval` and `eval2`
  are built.
- `run_limit`: `run` ends a command still running at its limit (120 s; 1 s in
  the check) by an alarm set in the child, through `subr` (no perl or coreutils).
