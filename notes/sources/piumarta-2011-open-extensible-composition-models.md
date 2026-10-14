# Open, extensible composition models (Ian Piumarta, 2011, VPRI TR-2011-002)

Source: https://tinlizzie.org/VPRIPapers/tr2011002_oecm.pdf (extended abstract, FREECO'11 at ECOOP,
Lancaster, 26 July 2011); reviews at http://piumarta.com/freeco11/freeco11-piumarta-oecm-review.txt.
This is the paper Maru's project page cites (as "object models") for the original Maru.

## A. Classification

Theoretical computer science with a working artifact: a language-design paper (programming-language
semantics, meta-level architecture), 4 pages, with complete code figures.

## B. Unity

Take a minimal metacircular Lisp and move the two places where it assigns meaning — evaluating an
expression and applying a function — into tables indexed by type. The core then assumes almost
nothing, and macros, message passing and generic functions become ordinary user-level additions,
indistinguishable from built-in features, at a measured 30% cost.

## C. Outline of major parts

1. **Introduction:** what adding a composition mechanism takes (a type, values, a syntactic
   operator, a meaning algorithm), and why doing it inside a host's abstractions is obfuscating
   while doing it at the meta level is not.
2. **A minimal functional language** (Fig. 1): `eval`/`apply` over symbols, atoms and lists.
   - `<subr>` primitives, `<expr>` closures, and `<fixed>`, a wrapper that suppresses argument
     evaluation.
   - Lexically scoped; metacircular; corrects LISP's semantic inadequacies (citing Stoyan).
3. **Supporting open composition.**
   - 3.1 Extensible aggregate types: types are integers from a counter, and every aggregate is an
     unbounded tuple (Fig. 2, user-defined `<point>`).
   - 3.2 Extensible composition rules: `eval` and `apply` dispatch through `evaluators` and
     `applicators` tuples indexed by type (Fig. 3). The recursion stops at applying a `<subr>`.
     Four table entries restore the original semantics (Fig. 4).
4. **Defining new compositions:** `<form>` for macros (Fig. 5), `<selector>` for single-dispatch
   messages (Fig. 6), `<generic>` for multimethods (Fig. 7), each by installing an applicator.
5. **Discussion.**
   - 5.1 Metacircularity and extensibility: what grounding fixes.
   - 5.2 Compositionality: a Montague-style homomorphism.
   - 5.3 Implementation: Maru, with a compiler to IA-32.
   - 5.4 Performance: 30% slower.
6. **Conclusions:** under 1,800 distinct lines for evaluator, runtime and IA-32 compiler.

Artifacts named:
- Maru (`piumarta.com/software/maru`): the language of the examples.
- Its compiler from s-expressions to IA-32, which compiles the evaluator's metacircular definition.
- Figures 1–7: complete code for each mechanism.

## D. Author's central problems

1. How can an evaluator be built so that it makes as few assumptions as possible about the structure
   of data and the meaning of expressions?
2. Then, how can new composition mechanisms be added so that they are qualitatively
   indistinguishable from built-in ones?
3. What must be fixed when a metacircular evaluator is grounded in an executable representation,
   and how can that grounded part be minimised?
4. What does the extra indirection cost?

## E. Key terms

- **Composition**: any rule by which values combined in an expression get a meaning. Function
  application is only the built-in one.
- **Open composition**: the ability to add new combining forms, or replace existing ones, with
  their meanings.
- **Evaluators / applicators**: two tables indexed by type. The first gives the meaning of an
  expression *of* that type; the second the meaning of applying a value *of* that type as an
  operator.
- **`<fixed>`**: a wrapper marking an applicable value whose arguments are passed unevaluated. This
  is how special forms are made without built-in special forms.
- **`<form>`**: an applicable whose result is evaluated again. Put inside a `<fixed>`, it makes a
  macro.
- **Grounding**: translating (part of) a metacircular evaluator into an executable representation,
  which ends the regress but makes the translated parts inaccessible to manipulation from the
  language.
- **Syntactic operator**: in a language without syntax, the *type of the first value* in a
  combination plays the role of syntax.

## F. Main propositions and arguments

1. **Meaning should be attached by type, through tables, not by predicates in the evaluator**
   (§3.2, Figs. 3–4).
   - The rules are `eval(x,e) = apply(evaluators[type x], (x), e)` and
     `apply(f,a,e) = apply(applicators[type f], (f . a), e)`.
   - The recursion terminates only at applying a primitive `<subr>`.
   - Four entries (symbol, number, pair, and the closure applicator) give back the original
     language.
   - Reasoning: once dispatch goes through data, any value can supply the meaning of any
     expression, any value can become applicable, and the meaning of a list is no longer fixed by
     the evaluator.
2. **Built-in and user-defined types must be made of the same parts** (§3.1).
   - Types are integers handed out by a counter; aggregates are unbounded tuples.
   - Accessors for user types are ordinary functions (`<point>-x`, generated by `define-type`).
   - Reasoning: if intrinsic types are privileged, user extensions are second-class, which is the
     "complexity and obfuscation" the introduction objects to.
3. **Macros, messaging and generic functions are each a type plus an applicator**, a few lines
   apiece (§4, Figs. 5–7).
   - Selectors keep a table from type to method.
   - Generic functions keep a sparse multidimensional table, one dimension per argument position.
   - Lookup can be slow because results can be memoised (footnotes 4 and 6).
4. **Grounding should fix as little as possible** (§5.1).
   - Grounding the plain evaluator of Fig. 1 freezes which types may be simple expressions, their
     meaning, the representation of complex expressions, their composition rule, which types can
     be operators, and the operator semantics.
   - Grounding the generalised evaluator freezes only the type→meaning association and the
     application of a primitive. Everything else (atoms, list composition, closure application)
     stays modifiable "with care".
   - Reasoning: the translated parts can no longer be manipulated, so minimise how many there are
     and what they assume.
5. **The language is compositional in Montague's sense,** with the operator's type acting as the
   syntactic operator (§5.2).
   - `m(F(e1..ek)) = G(m(e1)..m(ek))`, where `G` is chosen by the type of the first value.
   - Lists are combinations, not syntax.
6. **Extensibility costs 30%:** the IA-32 compiler ran 30% slower on the extensible evaluator than
   on the original one (§5.4).
   - Staged evaluation is claimed to more than recover this (§6).
   - That claim is the stated reason the mechanism exists: to support language implementation as a
     series of partial evaluations (§3.2).
7. **The whole thing is small:** evaluator, runtime library and IA-32 compiler together are under
   1,800 distinct lines (§6).

## G. Critique

- **Asserted, not demonstrated.**
  - "Staged evaluation can more than recover this loss" is unsupported in the paper; two reviewers
    flagged it.
  - The motivation (partial-evaluation-based implementation) is named but never shown.
- **The measurement is thin.** The 30% comes from one run of one workload (the IA-32 compiler),
  with no account of method; reviewer 1 asked how it was measured.
- **Incomplete.**
  - No related work: CLOS/MOP, Smalltalk-style reflection and 3-Lisp-style reflective towers are
    the obvious comparisons; reviewers 2 and 3 noted this.
  - The "semantic inadequacies of LISP" that the evaluator corrects are cited but never listed.
  - It doesn't address compositions that aren't function application (inheritance, delegation,
    declarations); reviewer 3 noted this. Within the model those become *types* whose applicator
    differs, which covers delegation but not declarative meta-level constructs.
- **"Distinct lines"** (under 1,800) is a different count from Maru's page's "1,750 lines".
  Neither defines the unit. Both are the same order of magnitude, and both include the compiler
  and runtime.
- **Agreement where it counts.** The central architectural claim is correct and checkable from the
  code in the paper: dispatch through type-indexed tables makes the grounded core tiny, and makes
  every other meaning replaceable from the language. It's the same move as Smalltalk's
  method-dictionary dispatch, applied to the evaluator itself.

## H. What of it?

- **This is the design centre of Maru.** Our tree should carry it: `eval`/`apply` dispatching
  through evaluators and applicators tables, with `<fixed>`, `<form>`, selectors and generics
  defined in Maru.
  - The `*evaluators*`/`*applicators*` names should be checked against `eval.c`/`eval.l`.
  - Wherever our C evaluator has grown special cases beyond the type dispatch, that is drift from
    the design, and it costs lines in the counted C.
- **"Minimise what is grounded" is the criterion for what the C seed must contain:** type dispatch,
  primitive application, and the primitives. Everything else belongs in `.l`. That is a concrete
  way to shrink the 8,135 counted C lines.
- **Line accounting precedent:** under 1,800 for evaluator + runtime + compiler. Our 10k budget
  covers much more (PEG, ir2, typed `maru.k`, backends, Nile), but this is the yardstick for the
  core.
- **The table-driven assembler fits this design.** The encoding table plays the same role as
  `applicators`: meaning attached by data, interpreted or compiled at load time. Piumarta's own
  answer to the cost of the indirection is staging (compiling the dispatch), which is exactly the
  load-time compilation of rows we chose.
- **Open question:** what "staged evaluation" looked like in later Maru (2.x). Look for
  partial-evaluation machinery in `eval.l`, `ir.k` and `ir2.k`.

## Permanent notes extracted from this source

- [[ground-as-little-of-the-evaluator-as-possible]]: the grounded (C) part should freeze as few assumptions as possible
- [[type-indexed-tables-make-every-composition-replaceable]]: evaluators/applicators tables are Maru's design centre
- [[the-cost-of-meaning-by-indirection-is-recovered-by-staging]]: keep meaning in data, buy speed back by compiling the data
