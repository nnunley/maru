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
- `tree_selectors`, `tree_source`, `tree_lists`, `tpeg_direct`, `tree_args`, `tree_args_unread`, `tree_apply`, `tree_memo`,
  `tree_foreign`, `tree_literals`, `tree_calc`, `tree_interleave`, `tree_text_refuses`, `tree_parse_complete`
  (`check/tpeg-*`): stage 1 of `doc/rfc/draft-ndn-maru-typed-tree-matching-00.md`, on every evaluator. A grammar whose
  parent is `<source-parser>` matches any source through the input selectors (`input.l`, `source-parser.l`): lists,
  a user's type, bytes (`input-binary.l`; not on `eval2`, which says it skipped them). A pattern enters a list or an array, a rule's
  arguments are cells on its input and leaving one unread is an error, memos live on the stream's cells, and a foreign
  rule reads through proxy cells with fresh memos. A value entered twice reuses its stream, found in a hash table (a
  string by its text, anything else by identity, as Maru's `=`), so `tree_memo` asserts that entering four times the
  values takes less than eight times as long; a list of every value entered made it quadratic, and native-arm64.g's
  lowering of a 4,600-intent function took 24 s, not 3. A choice dispatches on the head of the element in front of it: an alternative whose first step
  enters a list starting with a literal symbol, `` `( 'add …) ``, is tried only when the element's head is that symbol,
  and those with no such literal always, in their order; a head that isn't a symbol tries them all, so the results are
  the full choice's (`in-same` is identity on a symbol). `tree_lists` counts the literals tested (`in-same`): a list
  matched by the last of eight literal alternatives tests only its own and the one before it with no literal, where
  each alternative used to enter it to fail on its first literal. A **direct** list pattern, whose items are literal
  atoms, any element, or a direct rule (one of the grammar's own, with no parameters, whose whole pattern is
  `.:v -> e`, such as native-arm64.g's `reg`), each perhaps bound to a name, walks a list with `car` and `cdr` and makes
  no stream: each element taken and its literal tested in turn, as the stream path tests them, then the names bound
  and the direct rules' actions applied, so nothing runs for a pattern that fails. Strings and arrays, a dotted list,
  a nested list item, and a parser of a type derived from the grammar (which may redefine a direct rule) take the
  stream path. `tree_lists` holds the walk to the stream path's answers, and `tpeg_direct` (`check/tpeg-direct.l`)
  holds every intent of the native units and of the Nile runtime with Gezira to the same lowering through
  native-arm64.g and native-x64.g compiled both ways (`*tp-direct*` off recompiles a grammar's patterns to streams).
  It halved native-arm64.g's lowering of Gezira (11.9 s to 5.4 s on `eval2`). Grammars compile in process (`tpeg-load`), and `tpeg-repl.l`
  interleaves code and grammar blocks on one input. A text grammar refuses what needs a source, by name.
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
  stays `(name body parameters)`, so `compile-peg.l` and `compile-tpeg.l` still write the same `tpeg.l`. A rule's
  action form, `intent <arm64-sites> = …`, is kept among its annotations as `(actions arm64-sites)`: `compile-tpeg.l`
  compiles each of the rule's quasiquoted actions, `` -> `… ``, as `` (arm64-sites `…) ``, so the form, a macro, sees the
  template itself as the grammar loads, and any other action is as written (`tree_lists`). native-arm64.g's `intent`
  writes its instructions this way. A program that composes with a grammar's rules without matching with it reads them
  as data instead: `./eval grammar-data.l FILE.g VAR` writes `(define VAR '(RULE …))`, the same parsed rules, which
  make does for the arm64 encoder grammar (`arm64-rules-data.l`, walked by `asm-arm64.l`'s specialiser). Loading those
  costs `native.l` about 50 ms; loading the compiled `arm64-rules.g.l` to reflect on it would cost 1.5 s.
