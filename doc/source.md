# Sources

What loading defined answers its own source, form and line counts, text and tokens, through Maru methods (`source.l`); a file
that only runs is read without running it, to the same answers. Plan: `doc/plans/2026-11-10-erosion-by-reflection.md`.

## Checks

- `source` (`check/source.l`): on every evaluator. `load` calls `*load-hook*` (both boots, the same text) after each top-level
  form, and `source.l` keeps a definition's `<source>` (file, the lines the reader noted, the form as Maru's reader made it,
  before expansion) in a weak table keyed by what it defined (a function, form, selector or method; a type by its number), so a
  definition made again keeps only its latest. The selectors `source-of`, `source-form`, `form-count` (erosion's forms,
  `maru-forms.l`), `line-count` (lines holding more than a comment), `source-text` and `sources` (a selector's own and each
  method's, in the order kept) answer for each; what loading didn't define, a lambda made at run time, answers `()`. A
  definition's text is its own, from its opening paren to its closing one: the reader's noted lines miss a paren on a line of its
  own and drift after a string holding newlines, and a line may hold two definitions, so the file is divided into tokens once and
  read back keeping each list's opening and closing token, and a definition is the equal list nearest its noted line
  (`check/source/spans.l`). What was read before `source.l` (the boot file, which the evaluator reads itself before `load`
  exists, and each file required before) is read again when `source.l` is required, in the order it was evaluated (a `require`
  read where it stands), each definition kept for what its name is bound to then, so a file that requires another and redefines
  its function keeps its own (`check/source-order.l`). The file `./eval` is given is read by the evaluator too, so
  `./eval source-run.l FILE ARG...` runs FILE through `load`, as Ian named `boot.l` on the command line (`./eval boot.l emit.l
  eval.l`), and its definitions keep their sources (`check/source/main.l`).
- `source_lift` (`check/source-lift.l`): `(file-definitions path)` answers the `<definition>`s a file's forms make, read without
  running it (`source-lift.g`: function, form, selector, method, apply or type, a `(let () ...)`'s body entered), each with its
  `<source>`, answering the same selectors with the same form, lines and forms the loaded definitions answer. Erosion measures its
  callables through them.
- `source_tokens` (`check/source-tokens.l`): a definition's text divided as `eval.c`'s reader divides it (`source-tokens.l`):
  `maru-tokens.g` inherits tpeg's lexical rules where they agree with `eval.c` and has Maru's own where they differ (a symbol is
  any run of `eval.c`'s letters, `,` and `?` among them past the first; `1+` is a number and a symbol; a number may be a double;
  escapes as `readChar`), each token a `<token>` (kind, text, start, end, line), lines counted from positions afterwards.
  `maru-token-forms.g`, a tree grammar over the tokens, reads them back to the forms Maru's reader makes (numbers by `wcstoul`'s
  base 0, a leading 0 octal), for every definition the fixture makes and for `boot.l`, `boot2.l` and `hash.l` whole, on every
  evaluator. `(source-tokens x)` answers anything with a source, its lines the file's, and a `<source>` is an input of its tokens,
  so a tree grammar walks them (`check/source/symbols.g`). Tokens are made for what's asked: a text grammar costs some
  microseconds a character (12 ms for `boot.l`'s largest definition), so never for the tree.

## Limits

- A main file run directly (not through `source-run.l`) has no sources, and if it redefines a boot function before requiring
  `source.l`, that function answers the boot's source: only the evaluators' own file loops (`replFile` in C, `repl_stream` in
  `eval.l`) calling the hook would see it.
- Grammars defined by `tpeg-load` (read as text, not through `load`) answer no source; `grammar.l` keeps their rule bodies.
- `(set NAME (lambda ...))` is a definition when read but not when loaded; `define-apply` and `define` of a non-lambda value
  aren't kept.
- A token's number differs from `eval.c`'s in edge cases (`5x1f`, `08`, `1x`, `?\x`), and tokens accept what `eval.c` rejects
  (a mismatched closer, `(a . b c)`, an illegal escape).
- `(source-of 3)` answers type 3's source: a type is its number.
