# PEG-based transformer provides front-, middle- and back-end stages in a simple compiler (Ian Piumarta, 2010, VPRI TR-2010-003)

Source: https://tinlizzie.org/VPRIPapers/tr2010003_PEG.pdf (S3 2010, Tokyo, 27 September 2010).
The code archive was at http://piumarta.com/S3-2010/.

## A. Classification

Practical/theoretical compiler-construction paper with a complete worked artifact. All three
grammars are listed in full in Appendix B.

## B. Unity

One PEG-based pattern matcher, working on one representation (lists of objects), can serve as every
stage of a compiler: text to AST, AST to abstract stack-machine code, and abstract code to
assembly. The result is a compiler of about 100 lines of grammar that a student can understand in
hours and that reaches near-C speed with two peephole rules.

## C. Outline of major parts

1. **Introduction:** compilers normally use a different generator per stage (Yacc/ANTLR,
   tree-rewriters, BURG). This experiment uses one.
2. **Architecture (§2, Fig. 1):** a parser is an input stream, rules, an output stream and a
   "current result".
   - Rules are functions returning success.
   - Objects are atoms or lists, so characters and trees are matched the same way.
   - Stages are chained by sharing streams.
3. **The chain by example (§3)**, compiling `nfibs`:
   - 3.1 Front end: s-expression text to AST (Fig. 6).
   - 3.2 Middle end: AST to an accumulator/stack abstract machine (Table 1, Fig. 7).
   - 3.3 Back end: abstract machine to i386 assembly as string templates (Fig. 8), with runtime
     model and registers (Fig. 4).
4. **Discussion (§4).**
   - Performance: 75% of gcc -O2, rising to 80% and then 96% with two peephole rules.
   - Size: under 100 lines of PEG and about 20 of auxiliary functions; the PEG implementation is
     under 150 lines.
   - Compile speed: about 326 source lines per second.
   - Extensions: BURG-style tree covering by ordered choice, static types via type tokens, runtime
     demands (inline caches, barriers, stack maps).
5. **Related work (§5):** META II (Schorre), Baker's META for data structures, OMeta, Yacc/Lex,
   ANTLR, IBURG.
6. **Conclusion (§6):** one generator language throughout. Self-describing and self-sustaining
   languages are the target, and foreign calling conventions are the hard part. JIT needs output
   expressions that build instruction words from bit fields.
7. **Appendices:** the PEG syntax (Table 2), the output-expression syntax (Table 3), and the three
   grammars.

Artifacts named:
- The three-stage compiler and the `nfibs` benchmark.
- The PEG implementation (under 150 lines).
- Forall / Tamacola (Yamamiya and Ohshima), compiled to ActionScript bytecode for AVM2.
- The STEPS project.

## D. Author's central problems

1. Can a single grammar-driven mechanism specify *and* implement every stage of a compiler?
2. Does that make the compiler small and understandable without giving up acceptable speed?
3. What does such a compiler need from its host language in order to become self-describing and
   self-sustaining?

## E. Key terms

- **Stage / parser:** a set of PEG rules with an input stream, an output stream and a current
  result. Each stage maps a higher-level stream to a lower-level one.
- **Current result:** the semantic value of the last expression. Rule-local variables (`:name`)
  save it.
- **Output expressions** (`-> ...`): templates that build new structure, using `:`/`::`/`:::` to
  splice at increasing depth, and `` `(...) `` to escape to the host language. A backquoted string
  writes characters with substitutions such as `\#{n}` and `\${n}`.
- **Structure match** `'( e )`: match *inside* a nested list. This is what lets PEGs walk trees.
- **Host predicate** `` &`pred ``: test the current input object with a host-language function.
- **Abstract machine:** accumulator plus stack plus named memory, with the 15 instructions of
  Table 1.

## F. Main propositions and arguments

1. **A single representation and a single matcher unify the compiler** (§2).
   - Lists can represent text (as character objects), trees, tables and code.
   - PEGs extended to match inside list structure work on any of them.
   - So lexing, parsing, tree rewriting and code emission are all the same operation, matching and
     emitting, differing only in their rules.
2. **Each stage's output template visibly matches the next stage's input pattern** (§6). That
   correspondence is what makes the chain easy to understand, and it's the claimed reason the
   compiler is small.
3. **It is small** (§4).
   - Under 100 lines of PEG and about 20 lines of auxiliary code compile the example language
     (define, lambda, if, `+`, `-`, `<`, calls).
   - The PEG engine itself is under 150 lines.
4. **It is fast enough** (§4), measured on `nfibs(32)` against gcc 4.3 -O2 on Core/Core2:
   - 75% of C speed at 1.8 times the code size;
   - 80% after removing redundant stack-pointer add/sub pairs;
   - 96% at 1.48 times the size after fusing compare-with-literal-and-branch.
   - Each peephole is obvious from inspecting the abstract code and cheap to add.
5. **Better instruction selection fits the same framework** (§4).
   - Keep the code tree-structured until the back end, and use ordered choice instead of cost
     functions for BURG-style covering.
   - The author's experiments report good performance, at the cost of more complex back-end
     grammars and with backtracking controlled by memoisation and prefix factoring.
6. **Types and runtime demands are mostly cheap** (§4).
   - Static types can be type tokens carried in the structured form.
   - Inline caches and barriers are no harder than arithmetic.
   - Stack maps put their complexity in auxiliary functions.
   - Extensible or inferential type systems are more evaluator-like than transformational.
   - Footnote 6 names the open problem: the smallest static type system that lets the language's
     runtime support be written in the language itself.
7. **The hard part of self-sustaining dynamic languages is primitives** (§6). Foreign calling
   conventions depend on declared parameter types, and arguments and results need coercions guided
   by those types.
8. **JIT, or in-memory code generation, needs one more output feature** (§6): building integer
   instruction words from bit fields, plus two passes or back-patching for forward references.

## G. Critique

- **The benchmark is narrow.** One recursive integer function is close to the best case for a stack
  machine mapped onto registers. "96% of C" is for simple numerical programs, as the author himself
  says, and the two peepholes are tuned to exactly this program.
- **The language is tiny.** It has no closures over free variables, no data structures and no GC,
  so "under 100 lines" measures a demonstration, not a usable compiler. Maru's own `emit.l` is
  larger because it compiles a real language.
- **Asserted, not shown.** The PEG tree-covering performance is reported from unpublished
  experiments.
- **Compile speed is low** (326 lines/s) and blamed on an unoptimised PEG engine; plausible, not
  shown.
- **Agreement where it counts.** The central claim (one matcher, one representation, three stages)
  is demonstrated in full by the listings, and is checkable.

## H. What of it?

- **Grammar-driven back ends are Piumarta's own direction.** Our current `emit.l` and `ir-gen-*.k`
  are hand-written Lisp, not PEG stages. The paper shows a back end as a few dozen lines of
  pattern → template rules. That directly supports the user's push for grammars over code to stay
  inside 10k lines: a back end for A64 written as PEG rules over the IR, emitting through the
  encoding tables.
- **§6 anticipates the table-driven assembler.** Its JIT note (output expressions that build
  instruction words from bit fields) is exactly what the A64 encoding table provides. The spec
  (`docs/superpowers/specs/2026-10-14-table-driven-assemblers-design.md`) is the "syntax to
  construct integer instructions from bit fields", made reversible.
- **The architecture already exists in our tree.** The middle end's accumulator/stack abstract
  machine is essentially `emit.l`'s model. The PEG engine (`peg.l`, `parser.l`, `peg-compile.l`)
  already supports structure matching. So rewriting `emit.l`'s instruction selection as a
  grammar is a natural, budget-reducing step.
- **Footnote 6 is the problem the typed layer solves.** The smallest static type system that lets
  the runtime be written in the language is what `maru.k` over `ir2.k` attempts.
- **Measure ourselves the same way.** Report generated-code speed and size against `cc -O2` on a
  named benchmark (`nfibs`) whenever a backend changes; the paper gives the precedent and the
  numbers.

## Permanent notes extracted from this source

- [[one-pattern-matcher-can-implement-every-compiler-stage]]: one PEG matcher for front, middle and back end
- [[in-memory-code-generation-needs-instruction-words-built-from-fields]]: JIT needs bit-field instruction construction plus back-patching
