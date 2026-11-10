# Laws and rules

The rule engine, `.law` files and their runner, and the laws over C expressions and Nile.

## Checks

- `law_engine` (`check/rules-test.l`): `rules.l`'s one rule set generates, checks and
  enumerates alike; a recursive rule never applies at size 0; unification has an occurs
  check; the `in`, `number` and `=` builtins work as specified; schemas (whose variable may name a term's function:
  `for f in num | dbl: ... key(f(n))`, `law_cexpr`), relation
  parameters and facts read from a function expand to first-order rules, and an unknown
  relation is rejected.
- `law_cexpr` (`check/law-compile-test.l`, `check/laws/cexpr.law`): `law.g` (inheriting
  `cexpr.g`) and `law-compile.l` read the RFC's example law file to rule, let, set and
  law items. A template's holes fill by text with no grouping added (`{x} * c` with
  `a + b` parses to `(+ a (* b c))`), and `{{` is a literal brace. An error fails naming
  its line, and an unbound hole is `E_TEMPLATE_PARSE`. `cexpr.law` holds `?:` to the
  right, `-` to the left and a comment to a blank, over `cexpr.primary` sentences
  generated from `cexpr.g`'s records, at least 80% accepted (a sentence counts when the
  parser stops at its end with `)` after it). The false `{a}-({b}-{c})`
  (`check/laws/fixtures/minus-right.law`) is refuted for seed 42.
- `law_rules` (`check/law.l`, `check/laws/fixtures/`): the runner prints one line per
  law, `law NAME:`, then `TESTED n`, `PROVED n`, `REFUTED x=v ... seed=s` (shrunk;
  the seed reproduces it), `STARVED k of n`, `VACUOUS` or `INCONCLUSIVE status=s input=...`
  (a reference crashed). A file with no `under test:` line is `E_NO_UNDER_TEST`, a goal
  domain must bind its last argument (`E_BINDING`), and a grammar domain must name a
  registered language (`E_GRAMMAR`) and can't be exhausted (`E_EXHAUST`).
  `law NAME: mutants of R by exhaustion size n. L, ...` judges each mutant of the rules
  R reaches at the least size its rule appears: `PROVED n` if each fails a named law,
  else `REFUTED k of n survive` (`fixtures/adequacy.law`). `let numerals = [1, 2]`
  replaces `number`'s numerals (`fixtures/numerals.law`). The mutant focus follows where a law
  uses the relation (`reach.law`), and a reference's answers are kept by name and text
  (`refs.law`). A per-case `let NAME = EXPR` binding is evaluated once per case, is no domain, and shrinks by recomputing (`let.law`); `law-record` answers a record and `r.name` reads its field, `=` by value, E_FIELD otherwise (`fields.law`, `field-error.law`, `field-plain.law`); list terms `[c | s]` in rules and claims, and by exhaustion's bound on lists: size n reaches lengths 1 to n + 1 (`lists.law`, `schedule.law`); a range `A .. B` in a list is the whole numbers A to B, `E_RANGE` for ends that aren't (`range.law`); a list of constants in a claim is one constant, and claims' `=` and the runner's check of the names a claim uses (`law-names?`) loop along a list's spine, so a value thousands long (a run's output) doesn't overflow the stack. Shrinking keeps each value in its domain, and a let after a shrunk value is computed only from values in their domains (`domain-shrink.law`: a driver once got 0 workers). After its method a law may `classify NAME when EXPR, ...` (over the cases that pass; classes overlap) and its `TESTED` or `PROVED` line ends with each class's share, `TESTED 1000 (empty 6%, two_buffers 31%)`; a class is held to a claim's rules (a verdict is `E_CLAIM`, a crash `INCONCLUSIVE`); `cover P% NAME, ...` short of its share (exhausted, fewer; tested, decided sequentially as QuickCheck's `checkCoverage` does, drawing `trials` more cases at a time until a Wilson bound at z = 6 decides it, up to `trials` x `cover_ratio`, so fresh seeds neither fail it by chance nor let a real shortfall through, and one still undecided is short: `classify-test.law`, `classify-cap.law`), or with no cases, is `UNDERCOVERED NAME 20 of 1000 < 20%` (counts, not rounded shares), judged after vacuity, and a cover of no class or over 100%, or a class named twice, is `E_COVER` (`classify.law`, `classify-none.law`); `law-report.g` reads the shares as optional. A law file may define functions, `(x) -> e` or by cases,
  `let value = num(n) -> n | pair(a, b) -> value(a) + value(b)` (or one equation per line, `let size(num(n)) = 1`), matched
  by unification, called from claims, each other and themselves, or passed by name; a function's name is the file's own (its
  `list` isn't Maru's, and doesn't reach the next file: `leak.law`), its parameters and pattern variables shadow file lets; no
  case is `E_NO_CASE` (`functions.law`, `no-case.law`), a call to a name nothing defines `E_UNDEFINED`, an empty list domain
  `E_DOMAIN` (`empty-domain.law`);
  and a law's variable may range over a list, inline or a `let`'s name, which a schema shares (`list-domain.law`). A file may
  `use "other.law"`, read in its place once however often used (`use.law`). `.law` files count toward `lines`.
- `law_nile` (`check/laws/nile.law`, `check/laws/nile-reference.l`): rules for
  well-typed Nile expressions, with operator facts read from `nile/compilers/prelude.nl`,
  are sound (Nile's own resolver and type checker, forked per question, accept what they
  generate), checked by themselves, all used, and agree with Nile on expressions that
  ignore types. Nile's resolver crash on `ϫ():ρ` / `forall_`
  (`fixtures/nile-crash.law`) is `INCONCLUSIVE`. `nile-adequacy.law`: every one of the
  69 mutants of the expr rules fails sound or agree.
