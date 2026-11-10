# The grammar engine: one CST from any text, tree grammars for the rest

The user, 2026-11-08 and 09: the grammar engine hands off between grammars for mixed-mode input, wraps a grammar the way a
decorator does, and lets grammars be reflected on, "aligned with the whole nested environments, nested worlds concepts in
Warth's and Piumarta's papers". Then: "a side channel for the ast", "annotations to indicate the role of each
production", and "we need a homogeneous representation: text should also convert to the same AST representation before
we compare. Our initial instrumentation a CST that could be processed with tree grammars, and the tree grammars should be
able to give us the higher level analysis."

## Why

The erosion check (2026-11-08) reads Maru's text with a grammar that writes spans into each list's `source`, then walks
Maru's forms with tree grammars that know Maru's special forms by name. That works for one language, skips the eight
files that change language partway, and can't measure grammars, irl, pepsi or KScript. One representation for every
language, made the same way from any text, lets one analysis serve them all.

## What exists

- tpeg grammars are Maru classes and their rules are selectors (`$r`, a method per grammar class), so a child grammar is a
  nested environment of rules, inheriting through `%structure-bases`.
- A rule calls another grammar's rule on the same input (`p-r`, `match-rule-in`, through proxy cells), but the grammar is
  fixed when the caller is compiled. `tpeg-define` compiles rules and keeps no definition.
- Tree grammars (`<source-parser>`) enter any type defining the input selectors (`input.l`: `in-enter`, `in-head`,
  `in-tail` …), lists, arrays and bytes among them.
- Piumarta's mixed mode, in `repl.l` on the older engine: the REPL reads with a grammar, and a `{ … }` block reads to
  `(grammar-eval rules expr)`, which compiles the block and runs its expression on the stream the REPL reads, so the new
  grammar reads the rest of the file (`test-pepsi.l`).

## The design

1. **Reflection.** A grammar keeps its definition: a `<grammar>` record (name, type, parent, fields, rules, scope), each
   rule a `<grammar-rule>` (name, parameters, body as the tree tpeg parsed, annotations). Grammars live in scopes (the user,
   2026-11-09: "irl's grammar blocks should be registering, even if they're only locally scoped"): the root holds tpeg's,
   and a compilation may make one of its own under it, as irl does for its grammar blocks, whose names are found there and
   then above. `(grammar-of type)`, `(grammar-named name scope)`, `(grammar-rules g)` (its own and inherited, nearest first),
   `(grammar-rule g name)`; defining a rule again replaces it in its place. The grammars a grammar calls, and where it came
   from, wait for the handoff step, which needs them.
2. **Annotations.** A rule may carry annotations naming its role, written before it: `@decision if = …`. They are data on
   the rule, read through reflection; the engine gives them no meaning.
3. **The CST, as plain lists.** No class of its own (the user, 2026-11-09: "do we need a special cst? We already have
   generic iteration via the streams concept"): a node is a list, `(rule child …)`, a leaf the text its rule matched, and
   a node's span (the stream positions its rule began and ended at, and their lines) is a `<source-span>` in the list's
   `source`, where `eval.c`'s reader keeps a form's location. So a CST is the same kind of thing as Maru's forms, entered by
   the streams tree grammars already use (`input.l`, `source-parser.l`), and a pattern reads `` `( 'list `( 'symbol "if" )
   …) ``.
4. **Instrumentation, a decorator.** `(grammar-instrumented g)` is a grammar under g whose every rule, inherited ones too,
   runs g's and, on success, adds a node to a side channel the parser keeps; the rule's own result and g are
   untouched. A world over a grammar: the decoration is a child, the base is never changed. Comments and blanks are rules
   too, so they are nodes.
5. **Handoff.** A rule's action may run another grammar's rule, chosen while parsing, on the same input at the current
   position, and continue where it stopped: `grammar-eval` on tpeg. An instrumented parser hands its instrumentation on,
   so the CST of a mixed file is one tree, its nodes naming the grammar that made each.
6. **Maru's reader as a grammar, Piumarta's.** `peg.g`'s `sexpr` and `sexpression` rules already are Maru's reader as a
   grammar over the character stream (the user, 2026-11-09: "isn't maru's reader already effectively a grammar on top of
   the bottom level reader?"), with `set-list-source` keeping each list's location and the `{ … }` block reading to
   `grammar-eval`, the handoff. They come onto tpeg as they are, extended only where `eval.c` reads more (doubles, every
   escape, `?c`, `{…}` outside a grammar), held to `eval.c`'s reader on every file. `maru-lines.g`, which rebuilt them by
   hand, goes. A symbol is a first character and the rest, as `peg.g`'s `symfirst` and `symrest` have it: `?` and digits
   never start one (a character, a number), operators (`< <= << * = + %`) are words of operator characters, and the
   conventions and other languages' sigils Maru carries as symbols (`<type>`, `*global*`, `%internal`, `$rule`, `.long`,
   `%eax`, `$1`) are productions of their own, each reading to the same symbol, so their nodes say what they are.
7. **Analysis by tree grammars over the CST.** Roles come from annotations where a language's productions say them (pepsi's
   or irl's `if`), and from role grammars over the CST where they don't: Maru's `(if …)` is a `list` node like `(f …)`, so a
   tree grammar for Maru's syntax names its decisions, callables and binders. The erosion analysis then works on roles
   alone: complexity is 1 plus a callable's decisions, source lines its span less its comments, a clone a subtree of at
   least 12 leaves met twice once its binders are renamed. The erosion check is rewritten on this as the first user, and
   the eight files it skips are measured.

8. **Experiment: classes and slots as syntax, not generated names.** Today `define-structure <ks-point> (x y)` binds a
   form per field under a concatenated name, `<ks-point>-x`, and a method binds `self.x` the same way; nothing looks the
   class or the slot up where the name is used. The user, 2026-11-09: `<name>` should name a registered class, and
   `<name>-slot` (and `self.slot`) be a lookup of that class's slot, "as opposed to just generating bound names with long
   text that simulates that". Tried both ways and compared, one shared world either way:
   - **At expansion:** the reader keeps the plain symbol (agreement with `eval.c` holds); a Maru syntax rule resolves
     `<name>-slot` and `self.slot` against the class's fields where forms are expanded, refusing an unknown class or slot
     by name, and `define-structure` stops generating forms. Probably cheaper.
   - **At the parse:** the reader grammar reads `<name>` and `<name>-slot` as structured forms (class, slot), so every
     later step, the analyses above among them, sees a class reference and a slot access rather than a long symbol.
     Cleaner for analysis; it changes the forms the evaluators read, so each evaluator's reader changes with it.
   Measured: what each costs at load and run, what each lets the analyses see, and what breaks. The step after the CST
   and role grammars, which it builds on.

## Tests

Reflection answers a grammar's rules, bodies and annotations, inherited ones too. An instrumented grammar's results equal
the plain grammar's on every check that uses it, and its CST spans every character of its input exactly once (children
in order, no gaps or overlaps beyond its own text). A handoff continues where the other grammar stopped, and an
instrumented one yields one CST. Maru's reader grammar reads every file as `eval.c`'s reader does. The erosion check gives
the same numbers through the CST as before on the files it measured, and measures the eight it skipped.

## Order

Reflection and annotations; the CST and instrumentation; handoff; Maru's reader grammar; the erosion analysis on the CST;
the classes-and-slots experiment. Each its own merge, with its tests.

## Not in this item

Scope-aware renaming (environments a role grammar builds, later); other languages' role grammars beyond what their
annotations give; the older engine (`peg.l`, `parser.l`).
