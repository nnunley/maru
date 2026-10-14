# Maru (○) project page (Ian Piumarta, 2010–2012)

Source: https://piumarta.com/software/maru/ (fetched 2026-10-14); original sources linked from it as
`original/boot-eval.c`, `original/boot.l`, `original/emit.l`, `original/eval.l`, `original/Makefile`.

## A. Classification

Practical: a software project page describing an artifact and how to build it. Short (about 900 words).

## B. Unity

Maru is an s-expression evaluator that compiles its own implementation language to machine code, so
that a small C seed is needed once and then the system regenerates itself from its own source.

## C. Outline of major parts

1. What Maru is: an evaluator (`eval.l`), a compiler to IA-32 assembly (`emit.l`), and the runtime
   support the compiler needs (`boot.l`).
2. Two versions: the *original* (a near-minimal proof of concept, kept as the reference for its
   published descriptions) and the *current* one (2.x, where development continued).
3. The original: size, contents, speed, platforms.
4. The parts, file by file.
5. The bootstrap process.
6. Notes on the language's interesting features (types, messaging and multimethods added at run time
   in `boot.l`; a compiler that does not optimise).
7. The current version (download links), the name, the license, the bibliography, the release log.

Artifacts named:
- `boot-eval.c`: reader and evaluator for the s-expression language, in C.
- `eval.l`: the same evaluator in the s-expression language (metacircular).
- `emit.l`: compiler from s-expressions to IA-32 assembly, in the s-expression language.
- `boot.l`: data structures, algorithms and paradigms `emit.l` needs.
- `eval.s`: the output, a machine-code evaluator.
- Original total: 1,750 lines.
- Releases: maru 2.1 (2012-01-25) to 2.4 (2012-08-24); 2.2 restored the metacircular bootstrap in
  the current version.

## D. Author's central problems

1. How can an evaluator escape infinite metacircular regress and be grounded in hardware while still
   being described entirely in its own language?
2. How small can such a self-compiling system be, including the features its own compiler needs?
3. How can user-level types, messaging and generic functions be added to a language at run time
   rather than built into its kernel?

## E. Key terms

- **Metacircular evaluator**: `eval.l` is an evaluator for the very language it is written in.
- **Level shift**: Piumarta's name for what `emit.l` does: a translation that preserves meaning
  from s-expressions down to IA-32 machine code, so that the metacircular description reaches the
  hardware.
- **Infinite metacircular regression**: the problem that an evaluator written in its own language
  needs another evaluator to run it, and so on; the compiler ends the chain.
- **Original vs current version**: the original is a frozen, almost-minimal reference; the current
  one (2.x) departs from and extends it.

## F. Main propositions and arguments

1. **The bootstrap reaches a fixpoint, after which C is no longer needed.** `boot-eval.c` is
   compiled once. That evaluator runs `boot.l` + `emit.l` + `eval.l`, whose output is `eval.s`, a
   machine-code version of the evaluator described in `eval.l`. Assembled and linked, `eval` run on
   the same three files produces an identical `eval.s`. From then on the C compiler is out of the
   loop, unless `eval` is broken and must be bootstrapped again. (Section "The process".) The
   argument is the identity of the regenerated output: once the compiled evaluator reproduces
   itself, the C seed carries no information the `.l` files don't.
2. **The compiler is what grounds the metacircular evaluator.** Without `emit.l`, `eval.l` would
   need another evaluator beneath it forever; compiling it to machine code shifts it down a level,
   onto hardware. ("The parts", on `emit.l`.)
3. **The whole original system is 1,750 lines, about twice what it should be.** That figure includes
   a garbage collector and user-level types, structures, single-dispatch messaging and multimethods,
   all needed by the compiler itself. (Section "The original version".)
4. **The three `.l` files are one program**, split only for clarity. ("The parts".)
5. **Compiled code runs at about 30% the speed of aggressively optimised C, with no optimisation in
   the compiler.** This was measured by timing the generation of `eval.s` by `eval` against
   `boot-eval`, and is partly explained by gcc inlining `assq` into its callers in the C seed.
   (Section on performance.)
6. **Object-oriented messaging and multimethods are added to the language at run time, in `boot.l`,**
   not in the kernel. (Section on the language.)

## G. Critique

- **Incomplete.**
  - The page states the fixpoint but not what the C seed must implement, i.e. the interface between
    `boot-eval.c` and the `.l` files.
  - Nor does it say how the current (2.x) version's bootstrap differs, beyond 2.2 having "made it
    work again". The 2.x tree we have (2.4, with Kurt Stephens' merge and Amelang's 2012 changes)
    builds `eval` from `eval.c` with a C compiler, and its own `emit.l` targets IA-32 only, so
    on arm64 the fixpoint can't be reached today.
- **Mislabelled citation.** Reference [1] is given as "Open, extensible object models", FREECO'11,
  but the FREECO'11 paper is titled "Open, extensible composition models" (VPRI TR-2011-002). The
  2006 paper with Warth is "Open, reusable object models".
- **Performance claim is narrow.** 30% of optimised C is measured on one workload (compiling the
  evaluator), and the comparison mixes two effects: an unoptimising compiler, and gcc's inlining
  in the seed.
- **The 1,750-line figure** counts the original's four sources. The page gives no line count for
  the current version.

## H. What of it?

- **The rebuild's goal "the evaluator generated by `emit.l`" is the original design, not a new
  idea.** In Maru the C evaluator is a seed, and the evaluator proper is `eval.l` compiled by
  `emit.l`. Our CLAUDE.md and `check/lines` treat `eval.c` as counted "until `emit.l` generates it",
  which is consistent; this page shows what "generates it" should mean: a fixpoint, where `eval`
  run on its own sources reproduces the same `eval.s`.
- **That suggests a concrete check.** Bootstrap from the C seed, rebuild with the result, and
  require byte-identical output. It needs a native backend for the host. On arm64 that means
  the A64 table and an `emit` for A64; on x86-64 Linux, IA-32 code already runs.
- **The size target is set by the author himself.** He calls 1,750 lines "about twice what it
  should be" for evaluator + compiler + GC + types + messaging. That gives a scale against which to
  judge our 27k-line tree and the 10k budget.
- **Treating the compiler as a "level shift"** matches the table-driven assembler spec: the encoding
  tables are the bottom of that shift.
- **Next:** read `original/` (`boot-eval.c`, `boot.l`, `emit.l`, `eval.l`) and compare it with our
  2.4-based files.

## Permanent notes extracted from this source

- [[self-hosting-is-shown-only-by-byte-identical-regeneration]]: self-hosting is demonstrated only by byte-identical regeneration from the seed
- [[a-compiler-is-the-level-shift-that-grounds-a-metacircular-evaluator]]: the compiler is what ends metacircular regress
