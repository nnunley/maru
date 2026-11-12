# Grammars and parsing

PEG and tpeg grammars, left recursion, composition, typed tree matching and grammar reflection.

## Checks

- `recursion`: left-recursive PEG grammars match as expected and build a
  left-associative tree.
- `peg_compose` (`check/peg-compose.l`, `check/peg-lr.l`): grammars that
  call each other's rules keep their memos apart, an inherited rule calls an
  override, and a left-recursive entry rule grows, in `parser.l` and
  `text-parser.l`.
- `pegen`: a generated PEG matcher stops at the first unmatched character.
- `earley`: Earley parsing of `1+2*3` respects precedence.
- `text_parser`: `text-parser.l` matches a string literal that ends at the
  end of its input.
- `cexpr_forms` (`check/cexpr-forms.l`): `cexpr.g` parses C's expressions,
  with C's precedence, to Maru forms.
- `tree_selectors`, `tree_source`, `tree_lists`, `tree_args`, `tree_apply`, `tree_memo`,
  `tree_foreign`, `tree_literals`, `tree_calc`, `tree_interleave`, `tree_text_refuses`, `tree_parse_complete`
  (`check/tpeg-*`): stage 1 of `doc/rfc/draft-ndn-maru-typed-tree-matching-00.md`, on every evaluator. A grammar whose
  parent is `<source-parser>` matches any source through the input selectors (`input.l`, `source-parser.l`): lists,
  a user's type, bytes (`input-binary.l`; not on `eval2`, which says it skipped them). A pattern enters a list or an array, a rule's
  arguments are cells on its input and leaving one unread is an error, memos live on the stream's cells, and a foreign
  rule reads through proxy cells with fresh memos. Grammars compile in process (`tpeg-load`), and `tpeg-repl.l`
  interleaves code and grammar blocks on one input. A text grammar refuses what needs a source, by name.

  The checks of `source`, `lists`, `args`, `memo`, `foreign`, `literals`, `calc` and `text_refuses` are scripts
  `tpeg-repl.l` reads (`#!./eval tpeg-repl.l`, so each runs on its own too; the reader passes over a `#!` line, as eval
  does), the way `repl.l` reads `test-pepsi.l`: their grammars are blocks, written as in a `.g` file, and their cases are
  input to a rule whose action checks each. `check/tpeg-cases.l` has the rule most share (`tpeg-read-file` reads it): a
  case says what it shows, then a grammar, a rule and a source, and `=>` what the rule answers or `fails`.
  `tpeg-repl.l --forms FILE` runs a script and prints where each of its forms and blocks starts and ends, so the
  erosion check reads a script's code and grammars, not its cases ([Line count and erosion](measures.md)).
  `check/tpeg-run.l`'s `try` runs a rule of any grammar on a new parser of the grammar's type, a selector with a method
  for `<source-parser>`, `<text-parser>` and peg's `<parser>` (when `parser.l` is loaded first). `text_refuses` reads each
  case's grammar block with tpeg's own `grammar` rule and defines it in a world (`recover.l`'s `try-call`), so the
  error undoes it and the case checks what it says; `args` catches an unread argument's error the same way.
  `peg_compose` still compiles `check/peg-lr.g` with the command-line `compile-tpeg.l`, and `tree_parse_complete`
  `check/tpeg-broken.g`, so that route stays checked.
- `grammar_reflect` (`check/grammar-reflect.l`, plan `doc/plans/2026-11-09-grammar-engine.md`): a tpeg grammar keeps its
  definition (`grammar.l`): `(grammar-of type)` is its `<grammar>` (name, type, own fields, rules), each rule a
  `<grammar-rule>` (name, parameters, body as the tree tpeg parsed, annotations), registered as the grammar is defined, in
  process (`tpeg-load`) or loaded from the file `compile-tpeg.l` wrote, on every evaluator. `(grammar-rules g)` answers its
  rules and its ancestors', nearest first, an overridden one once (a class between two grammars that isn't one doesn't cut
  the line), and defining a rule again replaces it in its place. Grammars live in scopes: tpeg's in the root, and each
  irl compilation's grammar blocks in a scope of its own under it (`irl-grammar.l`'s `*irl-scope*`), found by name there and
  then above, so a block is reflected on like any grammar, inherits through the same rules and fields, and is seen by
  nothing outside its compilation. A rule may be annotated,
  `@decision pick = …`, each `@name` (read as a symbol, so `@left-recursive`) kept in order as data the engine gives no meaning; a rule with none
  stays `(name body parameters)`, so `compile-peg.l` and `compile-tpeg.l` still write the same `tpeg.l`.
