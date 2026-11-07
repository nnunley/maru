# draft-ndn-maru-laws-and-rules-00: Laws and Rules for Testing Maru's Languages

**Status:** DRAFT
**Category:** Experimental
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies a small logic-oriented language for testing the
languages Maru implements. Rules state, as a few inference rules, what a
valid input is (a well-typed Nile expression, say); the same rules generate
such inputs, check given ones, and enumerate all of them up to a size. Laws
state what must hold of those inputs, often over templates written in the
target language with holes the rules fill. It is written for whoever
writes or changes a Maru grammar, compiler pass or runtime.

## Motivation

Maru's checks test by example. `cexpr_forms` lists twenty sources and the
form each must parse to; `core_forms` lists twenty-three forms. Each row
was thought of by hand, so each check covers what its author thought of
and nothing else.

Generating inputs finds what nobody thought of, but only when the inputs
are valid. A throwaway spike (Appendix A) measured both halves:

- Generating sentences from `cexpr.g`'s own rules found, in its first
  run, that `0xq` is accepted as a hexadecimal number, the number 0
  (`higit` is `[0-9A-Za-z]`).
- From Nile's grammar alone, 0 of 40 generated operations and kernels
  that parse are valid Nile: Nile's own compiler rejects all of them.
  The same run found input that crashes Nile's resolver instead of
  being rejected.
- From four rules and fourteen facts for Nile expressions, 60 of 60
  generated expressions are well typed, and on 160 independent cases
  the rules and Nile's type checker agree every time.

So grammars are enough for laws about syntax, and not for laws about
meaning; rules are. This document provides the rule and law language,
its three modes, and the checks it applies to itself.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **rule** — an inference rule: a named conclusion that holds when all of
  its premises hold. A rule with no premises is a **fact**.
- **relation** — the name a rule's conclusion is about, such as `expr`;
  the rules for one relation form its **rule set**.
- **goal** — a relation applied to arguments, some of which may be
  unknown.
- **size** — the bound on how deeply rules may nest in one derivation.
- **law** — a statement that must hold for every value a domain
  produces.
- **domain** — what a law's variables range over: a goal, a grammar rule,
  or a finite set.
- **template** — source text in a target language, with holes.
- **hole** — a place in a template, written `{name}`, filled by a
  variable's value.
- **reference** — an existing implementation that rules are compared
  with, such as Nile's type checker.
- **mutant** — a rule set with one rule changed or removed, used to
  test the laws about it.

## Specification

This document defines rules, laws, templates, the three modes rules run
in, the outcomes a law reaches, and the laws every rule set is held to.
It does NOT define the forms rules and laws compile to; those are Maru's
own forms (draft-ndn-maru-forms-as-neutral-tree-00). It does NOT define
typed execution: laws over code that needs `maru.k`'s typed namespace to
run wait for an in-process back end (roadmap item 1).

**Everything runs in Maru.** The engine, generators, laws and runner are
untyped Maru. No law or check runs a shell, a C compiler or a host tool,
so the whole system can run where Maru does, bare metal included.

**One rule set, three uses.** A rule set is written once. Generating,
checking and enumerating are three ways of running it, never three
definitions.

### Data model

```
RECORD Rule:
    name        : Symbol            -- for coverage and reports
    conclusion  : Goal              -- relation and arguments
    premises    : List(Goal)        -- empty for a fact
    parameters  : List(Symbol)      -- relation parameters; empty once expanded

RECORD Law:
    name        : Symbol
    variables   : List(Binding)     -- each variable and its domain, or a per-case let and its value
    conditions  : List(Expression)  -- preconditions on the variables
    claim       : Expression        -- what must hold
    size        : Integer = 3       -- the bound on every rule domain
    method      : Method = TEST

ENUM Method:
    TEST        -- sample the domains
    EXHAUST     -- every value up to the size

ENUM Outcome:
    TESTED      -- held on every sampled value
    PROVED      -- held on every value up to the size (EXHAUST)
    REFUTED     -- failed; reports the shrunk values and the seed
    STARVED     -- too few values met the conditions to judge
    VACUOUS     -- the claim does not depend on the code under test
    INCONCLUSIVE -- a reference crashed instead of answering
    UNDERCOVERED -- passed, but a class met fewer cases than its cover asks
```

**Field constraints:** logic variables in rules are lower-case names;
names that start with a capital letter (`Number`) and strings (`"+"`) are
constants. A law's size MUST be stated or defaulted, never inferred from
how long generation takes.

| Outcome | What the runner does |
|---|---|
| `TESTED` | Reports the law as passing, with the number of values tried. |
| `PROVED` | Reports the law as passing for every value up to the size, with their count. |
| `REFUTED` | Fails; prints the smallest failing values found and the seed that reproduces them. |
| `STARVED` | Fails; prints how many values were drawn and how few met the conditions. |
| `VACUOUS` | Fails; names the law. |
| `INCONCLUSIVE` | Fails; prints the reference's status and the input it crashed on. |
| `UNDERCOVERED` | Fails; names each class whose share fell short, its share and the share asked. |

### Configuration

| Key | Type | Default | Description |
|---|---|---|---|
| `size` | Integer | `3` | The bound on rule nesting for a law's rule domains |
| `trials` | Integer | `100` | Values sampled per law under `TEST` |
| `seed` | Integer | `42` | Start of the generator's sequence, so every run repeats |
| `starved_ratio` | Integer | `20` | `STARVED` when fewer than 1 value in this many meets the conditions |

The defaults are small because a small size already reaches the cases
that matter (Appendix A's mutants are all caught at size 1) and keeps a
check's time in seconds. **Resolution precedence:** a value written in
the law; then the law file's `defaults` line; then this table. For a
sweep, `MARU_LAW_SEED` and `MARU_LAW_TRIALS` in the environment override all three.

### Rules

A rule set MUST be usable in three modes, from the same rules: generate
(an unknown argument is built by trying rules in a random order), check
(every argument is given, and the rules decide whether the goal holds),
and enumerate (every distinct value for the unknown argument, up to the
size). [R-rules-three-modes]

```maru-check @R-rules-three-modes
law_engine
```

A derivation MUST NOT nest rules deeper than the size: at size 0 only
rules whose relation cannot be reached from their premises, directly or
through other rules, apply. Generation
therefore always ends, and enumeration is finite. [R-size-bound]

```maru-check @R-size-bound
law_engine
```

The engine MUST unify with an occurs check. Without it a variable can be
bound to a term containing itself, and the next lookup never ends; the
spike's own unification law found exactly this (Appendix A).
[R-occurs-check]

```maru-check @R-occurs-check
law_engine
```

Three relations are built in, and every other relation MUST be
concluded by some rule in the file; a premise naming one that is not
is rejected before any law runs (`E_UNKNOWN_RELATION`). [R-builtins]

| Relation | Generate | Check | Enumerate |
|---|---|---|---|
| `x: t in list` | picks a pair `x: t` from the list | looks the pair up | every pair |
| `number(n)` | picks from `0 1 2 0.5 10` and the numbers the law file mentions | `n` is one of those | all of them |
| `a = b` | unifies | unifies | unifies |

A file's `let numerals = [1]` replaces `number(n)`'s numerals, the built-in ones and the file's, with its list.

Numbers the law file mentions are offered because boundary values are
where bugs live (writ seeds its generators the same way).

```maru-check @R-builtins
law_engine
```

A value is a constant (`Number`, `"+"`, `2`), a list `[a, b]`, a pair
`a: Number`, or a filled template. `let name = value` names one; `set
Name = A | B | C` declares a finite set, which `EXHAUST` enumerates and
`TEST` samples uniformly. A law file names what it tests in one `under
test:` line; those are the names the vacuity and mutant checks replace.

### Lists

A list `[a, b | t]` is a term in a rule and in a claim or condition. A rule can
conclude a list term from its premises: `schedule([c | s])` from `schedule(s)`,
with `schedule([c])` from `number(c)` as its base. No new support is needed for
this: a rule's list term is a cons term the engine already unifies, and the
value a support function receives is the Maru list those cells make, its
elements in order and ending in nil (`lists.law` checks that its argument is
such a list of numbers). In a claim, `[a, b | t]` builds that list from the
values of `a`, `b` and `t`, and `[]` is nil. [R-list-terms]

```maru-check @R-list-terms
law_rules
```

The size bounds rule nesting, and a list's length follows from it. A recursive
rule (one whose premise reaches its own relation) applies only at size one or
more, and each application spends one unit of size; a rule with no recursive
premise applies at size 0. So a list that takes k applications of the recursive
rule is reached at size k - 1 and no more. For `schedule` above, a list of
length L is reached at size L - 1, and `by exhaustion size n` over k numerals
enumerates every list of length 1 to n + 1: k + k^2 + ... + k^(n+1) of them,
each once. `PROVED n` then says every such list passed; it says nothing about
longer lists. `lists.law` counts this (2 numerals: 6 at size 1, 14 at size 2).
[R-list-bound]

```maru-check @R-list-bound
law_rules
```

An element of a list MAY be a range, `A .. B`: the whole numbers from A to B in
order, put in place where the range stands, so `let numerals = [0 .. 400, 610]`
is 402 numerals written on one readable line. A range's ends MUST be whole
numbers written as constants; anything else is `E_RANGE`, which stops the file.
`range.law` checks `[1 .. 4, 10]` is five values. [R-list-range]

```maru-check @R-list-range
law_rules
```

### Higher-order rules

Rules MAY be written higher-order, to keep them short, in three forms:
a schema (`for op in "+" | "-" | "/": fact infix(op, Number, Number,
Number)`), a rule whose parameter is a relation (`rule cons_list(r):
r(x), list_of(r, xs) => list_of(r, [x | xs])`, where `r(x)` applies `r`
with `x` as its last argument), and facts read from a source (below).
All three MUST be expanded into first-order rules before any law runs,
so the engine, its three modes and the mutants see only first-order
rules. [R-higher-order-expansion]

A relation parameter is expanded by specialising: each relation passed
to it, with the arguments given before the applied one, yields its own
copy of the rule set (`list_of(expr(env, t), es)` gives one `list_of`
for `expr` that carries `env` and `t`). A parameter that would need
solving for an unknown relation is rejected (`E_UNKNOWN_RELATION`):
the engine never searches over relations.

```maru-check @R-higher-order-expansion
law_engine
```

`facts R1, R2 from f` takes facts for relations `R1` and `R2` from `f`,
a Maru function that returns them; a returned fact for any other
relation is rejected. Facts SHOULD be read from a source that already
states them rather than copied, so they cannot drift from it: Nile's
operator facts come from its prelude, read through Nile's own grammar
(`a:Number + b:Number : Number` is `infix("+", Number, Number,
Number)`). Read facts are facts like any other, mutants included.
[R-facts-from-source]

```maru-check @R-facts-from-source
law_nile
```

### Templates and holes

A template is source text in a target language, written
`` lang`text` `` with holes `{name}`. Its holes are filled by text:
each hole's variable has a value that is source text in the same
language, and the filled template is parsed by that language's grammar.
`{{` and `}}` stand for literal braces, which Nile's conditional
expressions need.
A filler is inserted as text, with no parentheses added, so grouping is
the template author's: a template that needs a filler to bind as a unit
writes the parentheses itself (`(a + b)`, as `e_infix` does).
A template that does not parse when filled is an error in the rule or law
that wrote it, reported with the filled text.
In a rule a template is a term, its holes the rule's variables, and the
rules check template terms, not text: a value given as text (`"a + b"`)
matches no rule's template, even one whose filled text it is. Text is what
a reference or a claim receives. [R-template-holes]

```maru-check @R-template-holes
law_cexpr
law_nile
```

A hole's kind MUST come from its variable's domain, not from where the
parser stands when it reaches the hole. The spike tried the latter (the
first rule asked to match at a hole takes it) and it failed on every
unannotated template: a left-recursive rule never grows from a claimed
hole (`a + {x} * b`), an outer rule swallows it (`{c} ? {t} : {e}`), a
lexical rule claims it (`-{x}` became a float), and a rule matching zero-or-one
drops it (`f({x}, 1)` parsed as `(f 1)`). [R-hole-kinds]

```maru-check @R-hole-kinds
law_cexpr
```

### Generating from a grammar

For laws about syntax, a domain MAY be a grammar rule (`cexpr.primary`);
its size is the generator's fuel.
Its values are sentences generated from the grammar's own records (the
tree `tpeg.l` builds before compiling), each kept only if the grammar's
compiled parser accepts all of it. A sentence counts as accepted only when
the parser stops at its end with the language's sentinel after it (for
`cexpr`, `)`). A grammar domain cannot be exhausted (`E_EXHAUST`).
[R-grammar-domain]

```maru-check @R-grammar-domain
law_cexpr
```

The generator's size is split among the parts of a sequence, so trees
come out balanced, and once it is spent a choice takes a cheap
alternative that cannot lead back to the rule being expanded, so
generation ends with varied leaves. The runner MUST report the share of
generated sentences the parser refused. [R-grammar-acceptance]

```maru-check @R-grammar-acceptance
law_cexpr
```

### Laws

A law holds, under `TEST`, when its claim is true for `trials` values
drawn from its domains that meet its conditions; under `EXHAUST`, when it
is true for every such value up to the size. A refuted law MUST report
values small enough to read: the runner shrinks each failing value
(a rule-built value by rebuilding it at a smaller size, a number toward
0) while the claim still fails, and prints the seed. A claim or condition
is true unless its value is false, except that a reference's verdict
(`accept`, `reject` or `(crash status)`) is no truth value: a claim or
condition valued one is `E_CLAIM`, and the law compares it instead
(`= accept`). [R-law-outcomes]

```maru-check @R-law-outcomes
law_cexpr
law_rules
```

A law whose claim does not call the code under test, or that holds when
that code is replaced by a constant, MUST be reported `VACUOUS`. A law
whose conditions admit fewer than 1 value in `starved_ratio` MUST be
reported `STARVED`, not passed; the runner draws up to `trials` times
`starved_ratio` values before deciding. Replacing "the code under test"
means rebinding each name on the `under test:` line to a function that
returns a constant. [R-weak-laws]

The constant stand-in judges only names that are Maru functions. It cannot
judge a grammar law: a constant parser satisfies a template equality. It
also satisfies idempotence- and positivity-style laws
(`absv(absv(n)) = absv(n)`), which are therefore reported `VACUOUS`.
Authors SHOULD state such laws another way. A law file
without an `under test:` line is rejected (`E_NO_UNDER_TEST`).

```maru-check @R-weak-laws
law_rules
```

### Per-case lets

A binding `let NAME = ARG` among a law's bindings is evaluated once per case:
its value is ARG's value with the names bound before it, and the later
bindings, the conditions and the claim read it as `NAME`. It is not a domain,
so it adds no cases and the counts of `TESTED` and `PROVED` are those of the
domains alone. A let reads only the names before it; a later name is an
error that stops the run. A refutation prints a let's value with the others
(`NAME=v`). Shrinking recomputes every let after a value it changed, from the
values before it, so a refutation's values agree with one another. A later
binding that names a let (a goal's argument) gets the let's value.
[R-per-case-let]

```maru-check @R-per-case-let
law_rules
```

### Records and fields

A support function or reference answers a record with `law-record`, which
`check/law.l` defines: `(law-record "name" value "name" value ...)`. Its Maru
representation is `(law-record (name . value) ...)`, the tag first and the
names strings. `=` is Maru's structural `equal`, so two records are equal when
their fields are, and a refutation prints one as `{name: value, ...}`. A claim
or condition reads a field as `r.name`, one level, from a name bound by a let or
a domain. [R-record-fields]

```maru-check @R-record-fields
law_rules
```

A field the record does not have, or a field read from a value that is not a
record, is `E_FIELD`: the run stops and names the field and the record's fields.
A field in a rule or domain is `E_FIELD` when the file is read. Postfix indexing
(`r[0]`) is not in `cexpr.g`, whose only postfix form is a call, so it is left
out; a list is read by a support function instead, and there is no index error.

### Classes and cover

A law MAY classify its cases after its method: `classify NAME when EXPR, ...`.
EXPR reads the law's names, lets included, as a claim does. Each case that meets
the conditions and passes the claim counts toward every class whose EXPR is true,
so classes can overlap, and a case can be in none. A `TESTED` or `PROVED` line
then ends with each class's share of those cases, in the order declared, as whole
percents rounded to nearest: `TESTED 1000 (empty 6%, two_buffers 31%)`. A law that
fails prints no classes. [R-law-classify]

A law MAY then ask for a share: `cover P% NAME, ...`. A law that would pass but in
which a class met fewer than P percent of its cases (counted exactly, not from the
rounded share) is `UNDERCOVERED`, naming each such class, its share and the share
asked: `UNDERCOVERED two_buffers 2% < 20%`. A cover is judged after `VACUOUS`, so
the stand-ins that judge vacuity are not judged for cover. A cover naming no declared
class, or asking for more than 100%, is `E_COVER`, and the law does not run.
[R-law-cover]

A reader of the report doesn't need the classes: `notes/plan/law-report.g` reads
`TESTED n` with or without them, and `UNDERCOVERED` as a failure.

```maru-check @R-law-classify
law_rules
plan_evidence
```

```maru-check @R-law-cover
law_rules
```

### References

A reference is declared with `reference name(args)` and is a Maru
function that returns `accept`, `reject`, or `(crash status)`; any other
result is taken as a crash. A crash MUST NOT count as a rejection; it
makes the law `INCONCLUSIVE`.
In the spike, a reference that crashed for an unrelated reason (a
name the test redefined) looked like 21 refutations of a sound law.
[R-reference-verdicts]

```maru-check @R-reference-verdicts
law_nile
```

A reference SHOULD run in-process, with its errors caught as values (as
`check/irl-errors.l` catches ir2's). A reference that exits on its first
error, as Nile's checker does today (`nile-fatal-error` calls `(exit)`),
MAY run in a forked child, which is a host facility; so MAY the runner's
vacuity probe, as a stand-in can raise an error. Maru has no
non-local exit, and `error` aborts the process, so such a reference runs
forked until one exists. A fork that fails, or a wait that does not return
the child, is `(crash -1)`, never another child's status.
A reference's `accept` and `reject` are kept by its name and the text it
was given; a crash is not kept, so the same question is asked again. The Nile reference MUST be Nile's compiler
loaded into this tree's Maru, not its vendored copy.

### Laws every rule set is held to

A rule set with a reference MUST be checked by these laws, which are
stated in the law language like any other: [R-rule-set-laws]

1. **Sound.** Every value the rules generate, the reference accepts.
2. **Generate implies check.** Every value the rules generate, the same
   rules check.
3. **Agree.** On values from looser rules, which ignore what the rules
   under test constrain (types, say) but write the same templates, the
   rules and the reference give the same verdict, both ways. Because the
   rules check template terms, an agree domain that yields text, such as
   a grammar rule, cannot be checked by the rules.
4. **Coverage.** Every rule is used in some generated derivation.
5. **Adequate.** Every mutant fails at least one of the laws above. The
   mutants are: each constant argument of each fact replaced by each
   other member of its finite set; each fact removed; each premise of
   each rule removed.
   Mutants MUST be judged by `EXHAUST` over the values that use the
   mutated rule: random sampling caught 23 of 42 of the spike's mutants
   and exhaustion caught all 42. Each mutant is judged at the least size at
   which its rule appears, over values whose derivation uses it.

A law's domain draws from the original rules, so `sound` cannot kill a
mutant, and `agree` carries adequacy. An adequacy law MAY use one leaf per
type (`let numerals = [1]`), because these rules type expressions by leaf
type, not leaf identity.

```maru-check @R-rule-set-laws
law_rules
law_nile
```

The engine is itself held to laws over values its rules generate,
including: when `unify(a, b)` gives a substitution, both sides are equal
under it. [R-engine-laws]

```maru-check @R-engine-laws
law_engine
```

### Files

Law files are `check/laws/NAME.law`. `./eval check/law.l FILE` runs one
and prints a line per law, `law NAME: OUTCOME` with its counts; each
`law_*` case in `check/check.l` runs its files and fails if any line is
not `TESTED` or `PROVED`. Each law's seed is `seed` plus its position in
the file, so adding a law does not change the values another draws.

### Errors

| Error | Example | Recovery |
|---|---|---|
| `E_TEMPLATE_PARSE` | a rule fills `{a} {op} {b}` with an operator that is not one | The run stops with the message and the filled text (Maru's `error`, which has no unwind); the file's later laws and later files do not run |
| `E_UNKNOWN_RELATION` | a premise names `exprs`, which no rule concludes | The run stops with the message before the file's laws run; later files do not run |
| `E_REFERENCE_CRASH` | Nile's resolver fails on `ϫ():ρ` | `INCONCLUSIVE`; print the input and the status |
| `E_BINDING` | a goal domain does not bind its last argument | Reject the law; it does not run |
| `E_GRAMMAR` | a grammar domain names a language that is not registered | Reject the law; it does not run |
| `E_EXHAUST` | a law asks `EXHAUST` over a grammar domain | Reject the law; a grammar domain cannot be exhausted |
| `E_UNKNOWN_ITEM` | an item other than a rule, fact, schema or facts reaches rule expansion (`let`, `set`, `law`, `under-test`, `reference`, `defaults`) | The run stops with the message, naming the item; later files do not run |
| `E_ARITY` | a higher-order relation is used with the same passed relation but a different number of carried arguments | The run stops with the message before the file's laws run; later files do not run |
| `E_NO_FACTS` | `facts R from f` where `f` returns no fact for `R` | The run stops with the message before the file's laws run; later files do not run |
| `E_NO_UNDER_TEST` | a law file has no `under test:` line | Reject the file; its laws test nothing |
| `E_DUPLICATE` | two laws in a file have one name | Reject the file; none of its laws run, as adequacy names laws |
| `E_CLAIM` | a claim is `nile_accepts(e, t)`, not `nile_accepts(e, t) = accept` | Reject the law, naming it; the next law runs |
| `E_ADEQUATE` | an adequacy law names a law that does not exist, or a relation with no mutants (no rule concludes it) | Reject the adequacy law; the next law runs |
| `E_FIELD` | `r.c` where `r` is a record with no field `c`, or a value that is not a record; a field in a rule or domain | The run stops with the message, naming the field and the record's fields; a field in a rule or domain stops the file when it is read |
| `E_COVER` | `cover 20% big` with no class `big`, or `cover 120% big` | Reject the law, naming the class or the share; the next law runs |
| `E_RANGE` | a range `A .. B` whose ends are not whole-number constants | The file stops when it is read, naming the ends |
| `E_NO_RULE_APPLIES` | asking for `expr(env, Boolean, e)` with no Boolean rule | `STARVED` |

## Formal Grammar

A law file holds rules, facts, defaults and laws. Expressions inside them
are `cexpr.g`'s; the grammar for law files inherits `cexpr.g` as irl
does.

```abnf
law-file    = *( item / comment )
comment     = "--" *( %x20-10FFFF )
item        = rule / fact / facts / schema / defaults / law / let / set / under-test / reference
let         = %s"let" name "=" arg
set         = %s"set" name "=" name *( "|" name )
under-test  = %s"under" %s"test" ":" name *( "," name )
reference   = %s"reference" name "(" name *( "," name ) ")"
rule        = %s"rule" name [ "(" name *( "," name ) ")" ] ":" [ premises ] "=>" goal
fact        = %s"fact" goal
facts       = %s"facts" name *( "," name ) %s"from" name
schema      = %s"for" name %s"in" arg *( "|" arg ) ":" item
premises    = goal *( "," goal )
goal        = name "(" [ arg *( "," arg ) ] ")" / name ":" arg %s"in" arg
arg         = list / pair / template / expression
list        = "[" [ elem *( "," elem ) [ "|" arg ] ] "]"
elem        = range / arg
range       = expression ".." expression
pair        = name ":" arg
template    = name "`" *( text / hole ) "`"
hole        = "{" name "}"
field       = name "." name
defaults    = %s"defaults" setting *( "," setting )
setting     = name "=" number
law         = %s"law" name ":" %s"all" binding *( "," binding ) "." claim [ method ] [ classify ] [ cover ]
law         =/ %s"law" name ":" %s"mutants" %s"of" name %s"by" %s"exhaustion" [ %s"size" number ] "." name *( "," name )
binding     = name *( "," name ) ":" domain / "let" name "=" arg / expression
domain      = goal / name "." name / name
claim       = expression
method      = %s"by" ( %s"test" / %s"exhaustion" ) [ %s"size" number ]
classify    = %s"classify" class *( "," class )
class       = name %s"when" expression
cover       = %s"cover" share *( "," share )
share       = number "%" name
name        = ALPHA *( ALPHA / DIGIT / "_" )
number      = 1*DIGIT
text        = 1*( %x20-5F / %x61-7A / %x7C / %x7E / %x80-10FFFF )
text        =/ "{{" / "}}"
expression  = 1*( %x20-10FFFF )
```

A claim MUST NOT use bitwise `|`: the law syntax uses `|` to separate set
members, schema values and list tails.

`text` excludes `` ` `` (%x60), `{` (%x7B) and `}` (%x7D); `expression`
stands for `cexpr.g`'s `expression`.

A `comment` starts at `--` at the start of a line (after any blanks), or
at `--` after a blank when a blank or the line's end follows it. Inside an
item `--` with anything else after it (`f(a) --1 == 0`) is no comment, so
the item reads as an expression or fails naming its line; it never loses
its tail to a comment.

An example, the spike's Nile rules and one law about them:

```
set Type = Number | Boolean
let abpq = [a: Number, b: Number, p: Boolean, q: Boolean]
reference nile_accepts(e, t)
under test: expr

facts infix, prefix from nile_signatures      -- read from Nile's prelude

rule e_var:    v: t in env                                        => expr(env, t, v)
rule e_num:    number(n)                                          => expr(env, Number, n)
rule e_prefix: prefix(op, at, t), expr(env, at, a)                => expr(env, t, nile`{op}({a})`)
rule e_infix:  infix(op, at, bt, t), expr(env, at, a), expr(env, bt, b)
                                                                  => expr(env, t, nile`({a} {op} {b})`)

law sound: all t: Type, e: expr(abpq, t, e). nile_accepts(e, t) = accept
```

Nile chains parenthesised comparisons: `((a = b) < c)` reads as
`(a = b) and (b < c)`, because its parser drops the parentheses. For `agree`
to hold, the rule set needs three chain rules beyond these four. They are in
`check/laws/nile.law`.

## Out of Scope

**Proof by induction over rules.** Proving a law for every size, by one
case per rule with the law assumed for the premises, as QuickChick's
derived proofs and writ's prover do. Excluded because `EXHAUST` already
gives proofs up to a size, and an induction checker needs its own trusted
core and tests (writ re-checks every proof with a separate checker).
Extension point: a third `Method`, `INDUCT`, with its own marker.

**Laws over typed code.** Running `maru.k` code inside a law, such as
`untyped(f) == typed(f)`. Excluded until typed code runs in-process;
routing it through a C compiler is what the bare-metal goal rules out.
Extension point: a domain or reference backed by the in-process code
region of RFC 0001.

**Non-local exit in Maru.** A `catch`/`throw` or an `error` that returns
to its caller as a value, in `eval.c` and `eval2`. Excluded because
neither evaluator has one today and adding it changes the evaluators, not
the laws. Owned by the evaluators. Extension point: once it exists, a
reference that exits on error runs in-process and its fatal errors become
`(crash status)` values, so the Nile laws no longer need a forked child.

**Weights on rules.** QuickCheck's `frequency`, choosing some rules more
often. Excluded until a measured distribution needs it; laws can already
assert coverage. Extension point: a weight after a rule's name.

## Alternatives Considered

**Why not generate from the grammar and filter by the reference?** It is
the cheapest generator and it works for syntax, but for meaning it finds
almost nothing: 0 of 40 parseable Nile operations and kernels survive
Nile's compiler. QuickCheck's guidance is the same: `suchThat` and `==>`
give up when they discard too much.

**Why not hand-written generators per type, as QuickCheck's `Arbitrary`?**
A generator says how to build values but not what a valid value is, so
it cannot also check one, and the rule-set laws (sound, agree, adequate)
would need a second definition to compare against. Rules are both.

**Why not infer a hole's kind from the parser?** Measured: it failed
on all four unannotated templates (see [R-hole-kinds]).

**Why not s-expressions for laws?** They are Maru's tree, and laws compile
to them, but laws are typed by people every day; a terse surface over
`cexpr.g` is cheaper to write and read, as irl is for typed code.

**Why not full higher-order rules, solving for unknown relations?**
Higher-order unification is undecidable in general, and nothing measured
needs it: every higher-order rule in sight is a schema or a parameter
given a known relation, which expansion handles. Expanding first also
keeps mutants well defined (they apply to the expanded rules).

**Why not an external solver?** It would not run where Maru runs, and
its answers could not be checked inside Maru.

## Security Considerations

Law files are trusted code: a law's claim is evaluated as Maru, with the
evaluator's full access. A law file from elsewhere is as dangerous as a
`.l` file from elsewhere. A reference run in a forked child can still
write files; forking isolates its exit, not its effects.

## Compatibility

Nothing existing changes. Existing checks keep their rows; a law can
replace a row-list check (`cexpr_forms`) when it covers the same ground,
and the `check/lines` ledger records the trade. The spike's engine,
generator and runner were about 400 lines of Maru; the budget is soft
while STEPS points are still being added.

The Nile laws need Nile's compiler to load into this tree's Maru. At the
time of writing (October 2026) it runs on its own vendored copy under
`nile/compilers/maru/maru/`; the spike loaded Nile's parser, resolver and
type checker into this tree's `eval`, and its verdicts matched Nile's own
setup on all 64 cases compared.

## References

- draft-ndn-maru-forms-as-neutral-tree-00: the forms laws compile to.
- RFC 0001 (`docs/rfc/0001-table-assemblers.md`): the in-process code
  region typed laws would use.
- Lampropoulos, Paraskevopoulou, Pierce, "Generating Good Generators for
  Inductive Relations", POPL 2018:
  <https://popl18.sigplan.org/details/POPL-2018-papers/11/Generating-Good-Generators-for-Inductive-Relations>
- Lampropoulos et al., "Beginner's Luck: a language for property-based
  generators", POPL 2017:
  <https://www.cs.tufts.edu/~nr/cs257/archive/john-hughes/beginners-luck.pdf>
- Pałka, Claessen, Russo, Hughes, "Testing an Optimising Compiler by
  Generating Random Lambda Terms", AST 2011:
  <https://www.cs.tufts.edu/~nr/cs257/archive/koen-claessen/icsews11astfull-24-palka.pdf>
- writ, <https://github.com/jlt-commons/writ> (Clojure): laws checked
  against code, with vacuity, stand-in and mutant checks on the laws
  themselves, starved refinements, and a prover whose every proof a
  separate checker replays.

## Appendix A: The spike

A throwaway implementation, kept in `notes/spikes/laws/` (with a README
saying how to re-run each row) but not part of the build, measured the design at the
time of writing (October 2026). All runs are seeded and repeatable.

| Measurement | Result |
|---|---|
| `cexpr.g` sentences from its own records that its parser accepts | `primary` 184 of 200, `expression` 148 of 200 |
| Found by those sentences | `0xq` parses as the number 0 (any letter is taken as a hex digit) |
| Nile sentences from its grammar that parse | `expr` 168, `stmt` 150, `typedef` 200, `opdef` 100, `processdef` 25, of 200 each |
| Of those, accepted by Nile's own compiler | operations and kernels: 0 of 40 cross-checked |
| Found by them | `ϫ():ρ` then `forall_` crashes Nile's resolver (`intype` has no method for `<nile-typeref>`), also on Nile's own setup |
| Hole kinds from the parser | 0 of 4 unannotated templates right; the 1 annotated one right |
| Holes as placeholder names, found in the parsed tree | all 5 `cexpr` templates right; all 3 Nile templates (expression, operator and type holes) parse |
| Nile rules: generated expressions Nile accepts | 60 of 60 |
| Generated, then checked by the same rules | 60 of 60 |
| Rules used in generation | all 18 |
| Rules and Nile agree on type-ignoring expressions | 160 of 160 verdicts |
| Mutants caught by 12, 12 and 25 random cases (sound, generate-checks, agree) | 23 of 42 |
| Mutants caught, exhaustive over the mutated operator at size 1 | 42 of 42 |
| Engine law `unify` | first run: crash on `_1003 = ((z . y) . _1003)` (no occurs check); after the fix, 165 of 300 pairs unify, none violate it |
| Spike verdicts against Nile's own compiler (bundled Maru) | 64 of 64 agree |

As built (October 2026), `check/laws/nile.law` reaches `sound` TESTED 100,
`generate_checks` TESTED 100, `agree` TESTED 100, `agree_rejected` TESTED
100, `round_trip` TESTED 100 and `coverage` PROVED 1.
`check/laws/nile-adequacy.law` reaches `sound` PROVED 46, `agree` PROVED
222 and `adequate` PROVED 69. `check/laws/cexpr.law` has 1000 of 1079
generated `cexpr.primary` sentences accepted (about 92%). The `law_nile`
check takes about 23 seconds of CPU time.
