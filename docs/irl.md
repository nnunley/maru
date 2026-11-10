# irl

The C-like irl language over ir2: programs, libraries and grammar blocks.

## Checks

- `irl`: `irl.g` (inheriting `cexpr.g`) and `compile-irl.l` turn `test.irl`
  into a `.k` program that `maru.k` compiles and that prints what it should; a program that defines its own `main`
  (`check/irl-main.irl`, with arguments) keeps it, and one with both its own `main` and top-level statements is an error;
  `?:` with branches of different types (`check/irl-errors.irl`) stops ir2 at
  a type mismatch in the `if` (`check/irl-errors.l` records it in Maru).
- `irl_library` (`check/irl-library.l`): `compile-irl.l --library A.irl B.irl` reads
  several irl files to one program with no `main` (a top-level statement is an error), and
  `export f;` keeps a function visible; make builds the library (`build/irl-lib.dylib`), which
  untyped Maru opens by its path in the tree and calls by address. A library is compiled in
  one process, `./eval2 compile-irl-library.l A.irl B.irl > build/lib.c`: the irl is read to
  forms that stay in memory, then ir-gen-c.k and maru.k compile them; only `cc` runs after. `cast(e, type)` and
  `sizeof(type)` read to maru.k's own forms. A global's constant initialiser (a literal, negated or cast) is C's initialiser at
  its definition, in irl and typed Maru alike; a computed one would need a `main`, so it's an error in a library.
- `irl_grammar` (`check/irl-grammar.l`): a tpeg grammar calls another grammar's rule as `p-r`
  (compiled by `compile-tpeg.l` to a parser of `<p>` on the same input). In irl,
  `grammar { <G> : <parent> (fields) rules }` is tpeg's own syntax, read through that foreign
  call. Its matching is tpeg's own: `irl-grammar.l` lowers `compile-tpeg.l`'s `value-pe`
  output to typed Maru over `text-parser.k`, a struct `G` (string, limit, position, result,
  span, the fields) and one function per rule, `G_rule(self)`, actions maru.k forms copied in
  unchanged. A child's inherited rules call its overrides; a left-recursive rule, lists and
  strings are errors naming the rule.
