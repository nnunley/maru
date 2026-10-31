# draft-ndn-maru-forms-as-neutral-tree-00: Maru Forms as the Neutral Tree for Every Front End

**Status:** DRAFT
**Category:** Standards-Track
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies the tree that Maru's language front ends produce:
Maru's own s-expression forms, the same ones a programmer writes in a `.l`
or `.k` file. A C-level language hands its forms to the typed namespace
(`maru.k`, compiling to ir2); a dynamic language hands them to untyped
Maru. It fixes the core forms both namespaces share, the forms only the
typed namespace has, how a language adds constructs of its own, and how
`cexpr.g` and irl produce them. It is written for whoever writes or
changes a front-end grammar.

## Motivation

At the time of writing (October 2026), Maru's front ends each build a
different tree:

- `irl.g` emits calls to `ir.k`'s constructors (`(ir-add a b)`,
  `(ir-get 'x)`), an IR that nothing else in the tree uses; `maru.k`
  compiles to ir2 instead.
- `irgol.g` targets an older `ir.k` and no longer compiles: its
  `ir-function-type` calls fail with "too few arguments".
- `cexpr.g`, shared by irl and irgol since main 0ec9930, builds placeholder
  nodes (`(name x)`, `(lit 3)`, `(+ a b)`) that no consumer reads; irl
  overrides every rule that names them.
- The STEPS languages Maru aims to host each defined a vocabulary of their
  own: Nothing's `binOp`/`unOp`/`wordAt` nodes, OMeta/JS's
  `binop`/`get`/`send`, Nile's `opexpr`. Adopting one means writing a
  translator for every consumer.

Maru already has a neutral tree. `maru.k`'s `maru-compile` (`maru.k`
lines 74–215) lowers typed Maru's forms to ir2, and untyped Maru evaluates
the same operator, conditional, loop and binding forms. A grammar that
produces those forms needs no translator: the namespace that evaluates
them supplies the meaning. This document makes that the rule, so that
irl, Nothing and later KScript share one tree, and retires `ir.k`.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **form** — a Maru s-expression as the reader returns it: an atom, a
  symbol, or a list.
- **front end** — a grammar and its driver that read a language's source
  text and produce forms.
- **typed namespace** — the compilation environment `maru.k` opens with
  `compile-begin`, whose non-form bindings `compile-namespace` lowers to
  ir2.
- **untyped namespace** — the environment `eval` (or `eval2`) evaluates
  directly.
- **core form** — a form both namespaces accept with the same shape and
  the same meaning on integers.
- **typed form** — a form only the typed namespace accepts.
- **extension form** — a construct of one language, defined as a
  `define-form` (or expanded by its front end) into core and typed forms.
- **handoff** — the point where a front end's forms reach the namespace
  that compiles or evaluates them.

## Specification

This document defines the forms a front end produces, the core and typed
forms, the extension rule, the handoff, the forms `cexpr.g` produces, and
irl's move from `ir.k` to `maru.k`. It does NOT define new ir2
instructions (owned by `ir2.k`), Nothing's or KScript's own forms (later
documents), or the surface syntax of any language beyond the mapping
tables below.

**One vocabulary.** A front end's output is a list of forms in Maru's
existing vocabulary. A front end that invents a node head no namespace
defines violates this document.

**Meaning comes from the namespace.** The same form means a machine
operation in the typed namespace and an object operation in the untyped
one. A front end chooses a namespace; it does not encode meaning in the
tree.

### Data model

```
ENUM Namespace:
    TYPED       -- maru.k's compilation environment; lowers to ir2
    UNTYPED     -- eval's environment; evaluates forms directly

RECORD CoreForm:
    shape       : Form          -- e.g. (+ a b), (if c t e)
    typed       : Boolean       -- accepted by the typed namespace
    untyped     : Boolean       -- accepted by the untyped namespace
```

The core forms, with the namespaces that accept them today:

| Form | Meaning | Typed | Untyped |
|---|---|---|---|
| integer, float or string atom | a literal | yes | yes |
| symbol | a variable reference | yes | yes |
| `(op a b)`, op ∈ `+ - * / % << >> & \| ^ < <= = != >= >` | binary operation | yes | yes |
| `(- a)`, `(~ a)`, `(not a)` | unary operation | yes | yes |
| `(and a b…)`, `(or a b…)` | short-circuit logic | yes | yes |
| `(if c t e)` | conditional; a value when used as one | yes | yes |
| `(while c body…)` | loop | yes | yes |
| `(let (bindings…) body…)` | local bindings | yes | yes |
| `(set x v)` | assignment to a variable | yes | yes |
| `(f args…)` | call, where `f` is no other form's head | yes | yes |

The typed forms are the other forms `maru.k` accepts: the definitions
`define`, `define-function`, `define-struct` and `define-type`, which
`compile-namespace` and `maru.k`'s own forms handle; and `extern`,
`return`, `indir`, `set-indir`, `member`, `set-member`, `addressof`,
`cast` and `sizeof`, which `maru-compile-form-map` and
`maru->ir-unary-map` name (`maru.k` lines 178–192). Declarations are
written `(name type…)` in the postfix type notation `maru-check.k`
documents; a `let` binding written without a type takes its
initialiser's.

A top-level `define`'s initialiser is evaluated by untyped Maru while
the namespace is built, before anything is compiled, so it can only be a
literal, an `(extern name)` or a function; any other expression fails
there as an undefined variable. A typed program sets a global from a
computed value at run time, with `set`. `(define (name T))`, with no
initialiser, declares a global of any type `T`, struct types included,
whose value starts as zero, as a C file-scope object does.

**Field constraints:** equality is `=`, never `==`; logical negation is
`not` (the typed namespace also accepts `!`, the untyped one does not);
`(if c t e)` used as a value requires `t` and `e` of one type or
coercible, as ir2's `ir-check-type` enforces.

**Truth differs between the namespaces.** Untyped Maru has one false
value, `nil` (`()`): `if`, `and`, `or`, `while` and `not` test against it
(`eval.c` lines 1543–1574, 1619 and 2629), so `0`, an ordinary boxed
integer, is true. Comparisons there answer the symbol `t` or `nil`, and
`and` and `or` answer the deciding operand. The typed namespace compiles
to C, where `0` is false and comparisons answer `1` or `0`. So
`(if 0 1 2)` is `1` untyped and `2` typed, and `(and 1 2)` is `2` untyped
and `1` typed. Both namespaces agree on the truth of comparison and
logical forms over integers, and that is all this document relies on.
Each namespace MUST evaluate the forms below as the table states; a row
is checked by printing the form with `println` under `eval` and with
`printf "%d"` from a program `maru.k` compiles (`-` means the form is not
typed). [R-truth-semantics] A change to either namespace's truth is a
change to this document.

<!-- evidence: @R-truth-semantics template=truth-row -->
| Form | Untyped | Typed |
|---|---|---|
| `(< 1 2)` | `t` | `1` |
| `(< 2 1)` | `()` | `0` |
| `(if 0 1 2)` | `1` | `2` |
| `(if (< 2 1) 1 2)` | `2` | `2` |
| `(not 0)` | `()` | `1` |
| `(not (< 2 1))` | `t` | `1` |
| `(and 1 2)` | `2` | `1` |
| `(or () 3)` | `3` | `-` |

```maru-truth id=truth-row
{{Form}}
untyped {{Untyped}}
typed {{Typed}}
```

### Behavior

A front end MUST produce only core forms, typed forms, and extension
forms that expand into them. [R-front-end-forms] A node head outside these
sets reaches `maru-compile` as a call to an undefined function, or reaches
untyped Maru as an undefined variable, far from the grammar rule that made
it.

```maru-check @R-front-end-forms
cexpr_forms
irl
```

The core forms MUST mean the same in both namespaces on integer
operands, in this sense: an arithmetic or bitwise form yields the same
integer, and a comparison or logical form yields the same truth (not
`nil` untyped, not `0` typed). [R-core-forms] A front end that hands the
same forms to either namespace MUST make each condition of `if` and
`while`, and each operand of `and`, `or` and `not`, a comparison or
logical form, never a bare integer, because the namespaces disagree on
the truth of `0`. This is what lets one grammar serve both kinds of
language.

```maru-check @R-core-forms
core_forms
```

A language construct that is not a core or typed form MUST be defined as
an extension form: a `define-form` in the target namespace, or an
expansion the front end performs, that produces only core, typed and
other extension forms. [R-extension-forms] irl's `for`, `where`,
`finally`, `true`, `false` and struct literals are extension forms of this
kind; `test.irl` uses all but `finally`.

```maru-check @R-extension-forms
irl
ir_retired
```

The handoff interface is the forms printed as a source file: a typed front
end's output, written to a `.k` file, MUST compile with
`./eval2 ir-gen-c.k maru.k FILE`. [R-handoff-file] A front end MAY instead
hand its forms to the namespace in-process; when it does, the forms MUST
be the ones it would print. The printed file is what a check compares and
what a person reads when a front end misbehaves.

```maru-check @R-handoff-file
irl
ir_retired
```

`cexpr.g`'s default rules MUST produce core forms, by the mapping in the
table below, with C's precedence and associativity. [R-cexpr-forms]

<!-- evidence: @R-cexpr-forms -->
| Source (cexpr.g) | Form |
|---|---|
| `x` | `x` |
| `42` | `42` |
| `"hi"` | `"hi"` |
| `a * b / c` | `(/ (* a b) c)` |
| `a + b * c` | `(+ a (* b c))` |
| `a << 1 + b` | `(<< a (+ 1 b))` |
| `a < b == c < d` | `(= (< a b) (< c d))` |
| `a & b \| c ^ d` | `(\| (& a b) (^ c d))` |
| `a && b \|\| c` | `(or (and a b) c)` |
| `-a + ~b` | `(+ (- a) (~ b))` |
| `!a` | `(not a)` |
| `c ? a : b` | `(if c a b)` |
| `f(a, b)` | `(f a b)` |

The precedence, loosest first: `?:`; `||`; `&&`; `|`; `^`; `&`; `==` `!=`;
`<` `<=` `>` `>=`; `<<` `>>`; `+` `-`; `*` `/` `%`; prefix `-` `~` `!`;
postfix call. Binary operators associate left; `?:` associates right.

```maru-check @R-cexpr-forms
cexpr_forms
```

irl's front end MUST produce typed forms, which `maru.k` compiles: its
grammar has no `ir-*` action, and `compile-irl.l` prints a `.k` program
for the handoff. [R-irl-via-maru] Beyond `cexpr.g`'s mapping, irl maps:

| irl | Form |
|---|---|
| `x := v` | `(set x v)` |
| `a[i]` | `(indir a i)` |
| `a[i] := v` | `(set-indir a i v)` |
| `*p` | `(indir p)` |
| `*p := v` | `(set-indir p v)` |
| `&x` | `(addressof x)` |
| `s.f` | `(member s f)` |
| `s.f := v` | `(set-member s f v)` |
| `return e;` | `(return e)` |
| `import T name;` | `(define (name T) (extern name))`; for a function type, `(define (name T *) (extern name))` |
| `&f`, `f` imported | `f` (already a pointer to the function) |
| `T name := e;`, `e` a literal | `(define (name T) e)` |
| `T name := e;`, `e` computed | `(define (name T))`, and `(set name e)` at its place in `main` |
| `T name(params) stmt` | `(define-function name T ((p T)…) stmt)` |
| `int`, `char`, `void`, … , `struct T` | the same name, `struct T` |
| `T*` | `T *` |
| `T(A, B)` | `(T A B)` |
| `T(A, ...)` | `(T A ...)` |
| `T()` | `(T ...)` |
| `struct T { int x, y; };` | `(define-struct T ((x int) (y int)))` |
| `struct T(a, b)` | `(let (((t struct T))) (set-member t x a) (set-member t y b) t)`, fields in declaration order |
| top-level statements | the body of `(define-function main int () … (return 0))` |

irl's type syntax MUST accept `...` as the last parameter type. A
function type with no parameters, `T()`, becomes `(T ...)`. A function
pointer's type MUST say how the function is called: on arm64 a variadic
function takes its variadic arguments differently from its fixed ones,
so a call through a pointer of type `(T ...)` cannot reach a function of
type `(T A ...)` correctly, and ir2 rejects that assignment as a type
mismatch. `test.irl` therefore MUST declare `printf` as
`int(char*, ...)` and `fun` as `int(char*, ...)*`. `test.irl`'s program,
compiled this way, MUST print what it printed through `ir.k` under
x86_64: the lines the `irl` check lists, on every host.

```maru-check @R-irl-via-maru
irl
ir_retired
```

`ir.k`, `irgol.g`, `compile-irgol.l`, `test.irgol` and `test-ir.k` MUST
be removed; the files that remain MUST NOT require `ir.k`, and `irl.g`
and `compile-irl.l` MUST NOT contain an `ir-` form. [R-ir-retired] The
`irl` check passed through `ir.k` before the move, so it shows the move
only together with this one. Two
IRs for one language double what a change to the C back end has to keep
working.

```maru-check @R-ir-retired
ir_retired
```

`(define (name T))` MUST declare a zero-initialised global of type `T`,
struct types included. [R-zero-global] Without it a struct-typed global
cannot be defined at all: no literal initialiser has a struct type, and
a computed one is evaluated untyped.

```maru-check @R-zero-global
zero_global
```

### Errors

| Error | Example | Recovery |
|---|---|---|
| unknown head | a grammar emits `(binop + a b)` | the `cexpr_forms` check fails on the printed forms; fix the grammar rule |
| typed form in the untyped namespace | `(indir p 0)` evaluated by `eval` | undefined-variable error at evaluation; the front end chose the wrong namespace |
| bare integer as a condition | `(if n a b)` with `n` an integer, handed to both namespaces | the two disagree when `n` is `0`; the front end writes `(if (!= n 0) a b)` |
| type mismatch in `(if c t e)` | branches of int and pointer | ir2 reports `ir-error-type-mismatch`; the front end casts one branch |
| construct with no form | a Nothing `goto` given to `maru.k` | the front end reports the construct as unsupported; a later document adds the typed form |

## Formal Grammar

The printed shape of the core forms. Atoms and symbols are as Maru's
reader reads them.

```abnf
core-form   = atom / symbol / binary / unary / logic / conditional / loop / binding / assign / call
binary      = "(" binop sp form sp form ")"
binop       = "+" / "-" / "*" / "/" / "%" / "<<" / ">>" / "&" / "|" / "^" / "<" / "<=" / "=" / "!=" / ">=" / ">"
unary       = "(" unop sp form ")"
unop        = "-" / "~" / %s"not"
logic       = "(" ( %s"and" / %s"or" ) 1*( sp form ) ")"
conditional = "(" %s"if" sp form sp form [ sp form ] ")"
loop        = "(" %s"while" sp form *( sp form ) ")"
binding     = "(" %s"let" sp "(" *( binding-pair ) ")" *( sp form ) ")"
binding-pair = "(" symbol sp form ")"
assign      = "(" %s"set" sp symbol sp form ")"
call        = "(" form *( sp form ) ")"
form        = core-form / typed-form
typed-form  = "(" symbol *( sp form ) ")"
atom        = 1*DIGIT / DQUOTE *( %x20-21 / %x23-7E ) DQUOTE
symbol      = sym-first *( sym-first / DIGIT )
sym-first   = ALPHA / "-" / "_" / "*" / "<" / ">" / "=" / "!"
sp          = 1*WSP
```

## Out of Scope

**Nothing's machine forms.** Labels, `goto`, `wordAt`, `byteAt` and bit
selection. ir2 has no jump instruction, so `goto` needs one before it can
be a typed form. Extension point: a later document adding typed forms and
the ir2 instructions behind them; `wordAt`/`byteAt` map to `indir` with
`cast` and need none.

**KScript's forms.** Sends, lambdas, stream definitions (`<-`, `fby`,
`when`). Extension point: extension forms in the untyped namespace, per
[R-extension-forms].

**Nile's operators.** Nile defines operators by name in the language.
Extension point: they become calls `(op args…)` to the functions their
definitions produce.

**In-process handoff.** Running the front ends inside `eval2`. Extension
point: [R-handoff-file]'s MAY, held to producing the printed forms.

## Alternatives Considered

**Why not tagged nodes in the OMeta/JS style (`binop`, `get`, `send`)?**
Warth's `BSJSTranslator` and Nothing tag every node. That is a second
vocabulary beside Maru's, and every consumer (ir2, a Nothing back end,
KScript) needs a translator grammar from it. Maru's forms already have a
compiler and an evaluator.

**Why not tagged nodes lowered to Maru forms?** Keeping a syntax-level
layer (get versus literal, send versus call) above Maru's forms would
help a consumer that needs those distinctions. None does today; the layer
can be added for one language when one does.

**Why not keep `ir.k` beside ir2?** irl could lower to both. `ir.k` has no
other user, and keeping it means every change to the C back end is made
twice or lets one IR rot, as `irgol.g` shows.

**Why not make `0` false in untyped Maru?** It would make the
namespaces agree on every condition. But untyped code uses `0` as an
ordinary value and `nil` as "none" (a position or count of `0` is found,
not missing), so every such idiom would change meaning, in `eval.c`,
`eval2.c` and the evaluator written in Maru alike; and each truth test
would grow from one comparison with `nil` to a type check and a value
comparison on a boxed integer, unless false became a singleton value of
its own, as `nil`, `true` and `false` are in Piumarta's Pepsi. Requiring
comparison or logical forms as conditions costs a front end nothing.

**Why not one namespace for all languages?** Dynamic languages could
target typed Maru with an object library written in it, as KScript's
object model sat on a Squeak dictionary. That builds an object system
before any dynamic language needs one; the untyped namespace is one
already.

## Security Considerations

The forms are programs: the typed namespace compiles them to C and the
untyped one evaluates them, with the full authority of the process,
including `extern` access to any C symbol. A front end's output is
therefore trusted exactly as its source file is; this document adds no
input that was not already code. A printed `.k` file is a program and is
treated as one: compiling an untrusted `.k` file is running untrusted
code.

## Compatibility

irl's generated C changes completely (ir2's C generator replaces
`ir.k`'s), so byte comparison with today's output is no longer the test;
the program's output is. Two behaviors change with C precedence: `==` and
`!=` move below `<` and `>`, so `a < b == c` parses as `(a < b) == c`; and
`a < b < c`, which irl's `relation` rejects (it allows one comparison),
parses as `(a < b) < c`, as in C. `test.irl` uses
neither. Indexing `a[i]` moves from `ir.k`'s pointer addition to
`maru.k`'s `indir`; both scale by the element size, and `test.irl`'s
sieve exercises it. Programs written for `irgol` lose their compiler,
which already fails. `test.irl` changes in two lines, declaring the parameters
of `printf` and of `fun`, so the `irl` check no longer needs x86_64 to
run it.

## References

- BCP 14: RFC 2119, RFC 8174.
- `maru.k` (`maru-compile`, `maru-compile-form-map`), `maru-check.k`
  (typed Maru's declaration syntax), `ir2.k`, `cexpr.g`, `irl.g`.
- A. Warth, `bs-js-compiler.txt` in OMeta/JS (local checkout
  `~/development/ometa/ometa-js/`): the `BSJSTranslator` node set, the
  tagged alternative.
- VPRI, *STEPS Toward Expressive Programming Systems, 2010 Progress
  Report*, TR-2010-004, Appendix 1: Nothing's grammar in OMeta
  (`~/pkm/raw/vpri/steps-2010-report.txt`).
- Y. Ohshima et al., *KScript and KSWorld*, VPRI TR-2012-001, in the 2012
  STEPS final report (`~/pkm/raw/vpri/steps-2012-final-report.txt`).
- RFC 0001 (table assemblers), draft-ndn-nile-runtime-in-maru-01: the
  `maru-check` evidence adapter used here.
