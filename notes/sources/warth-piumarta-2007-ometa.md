# OMeta: an Object-Oriented Language for Pattern Matching (Warth & Piumarta, 2007, VPRI TR-2007-003)

Source: https://tinlizzie.org/VPRIPapers/tr2007003_ometa.pdf

The converted text carries no printed page numbers, only running footers. I counted pages from those footers, which give nine pages in all (pp.1-9). Page numbers below follow that count. Published at DLS 2007. I read the converted text only; I did not run the implementation, which the paper says is downloadable but which is not in the sources.

## A. Classification

- Genre: language design paper, with a DLS 2007 publication history. Design with an implementation and worked examples.
- Field: programming-language implementation; pattern matching; parsing; PEG-based syntax; syntax extension.
- Contributions, as listed on pp.1-2: (1) a generalisation of PEGs from character streams to arbitrary data, with parameterised and higher-order productions; (2) an extensibility mechanism for PEGs based on object-oriented grammars; (3) the OMeta language built on these; (4) examples in language-implementation tasks.
- Argumentative mode: demonstration by example, plus one case study (a nearly complete JavaScript implementation, pp.7-8). No benchmark, no size comparison with other tools, no formal semantics.

## B. Unity

One mechanism does the work of several tools. An ordered-choice, backtracking matcher over any sequence of objects serves as lexer, parser, visitor, tree transformer, and extension mechanism (pp.1, 4, 9). The paper says the separate phases of a compiler are "instances of the same problem" (p.1). Grammars are objects, so syntax extension and pattern matching share one mechanism, inheritance (pp.4-7).

## C. Outline of major parts

Sections, with page ranges:
- Abstract and 1 Introduction (pp.1-2). Problem: compiler phases use different tools (lex, yacc, visitors), and ML-style matching is too weak for lexing and parsing. Lists the contributions (pp.1-2).
- 2 OMeta: an extended PEG (pp.2-4). 2.1 PEG basics in OMeta syntax (p.2, with Table 1 and Fig. 1). 2.2 Generality beyond characters (p.3). 2.3 Expressiveness: arguments, predicates, `apply` (p.3). 2.4 Memoisation (p.4).
- 3 O is for Object-Oriented (pp.4-6). 3.1 Quick language extensions (p.4, Fig. 3 on p.5). 3.2 Extensible pattern matching: optimisation grammars (p.4, Fig. 4 on p.6). 3.3 Stateful matching (p.5, Fig. 5 on p.6). 3.4 Foreign production invocation (p.5).
- 4 More examples (pp.5-8). 4.1 Lexically scoped syntax extensions (pp.5-7, Fig. 6 on p.7). 4.2 Checking printf calls (pp.7-8, Fig. 7 on p.8).
- 5 Case study: JavaScript (pp.7-8). 5.1 Parsing (p.8). 5.2 Code generation (p.8).
- 6 Related work (pp.8-9). 7 Conclusions and future work (p.9). References (p.9).

Concrete artifacts named:
- OMeta (the language); COLA (the host language, ref. [11]); the Squeak Smalltalk port, done with Yoshiki Ohshima (p.2, fn. 2); COLA s-expressions; the authors' OMeta web pages (p.2).
- Table 1, the inductive definition of PEG operators (p.2).
- Fig. 1, an arithmetic-expression grammar (p.2).
- Fig. 2, a list-flattening grammar (p.4).
- Fig. 3, a `Java++` grammar that adds a `foreveryother` loop (p.5). The paper says it does not run (p.4).
- Fig. 4, the `NullOptimization` and `OROptimization` grammars (p.6).
- Fig. 5, the Calc desk calculator, with a transcript (pp.5-6).
- A `MetaCOLA` grammar that invokes `OMeta` and `COLA` productions foreign (p.5).
- Fig. 6, a C-style array-indexing syntax extension for COLA (p.7).
- Fig. 7, a grammar `P` that rewrites ill-formed `printf` calls to `BAD_PRINTF` (p.8).
- The JavaScript implementation: a 177-line OMeta parser (p.8); a code generator in Scheme-style macros (p.8); use by a Sun Labs group on programs of about 2k lines (p.7); missing `with` and `try/catch` (p.7, fn. 7).
- An earlier Python subset parser with an indentation stack (p.5).
- Optimisations: a jump-table for character choices and left-factoring (p.5, fn. 3).
- Memoisation variants: the COLA port memoises productions without arguments; the Squeak port memoises none (p.4).
- Related systems: Schorre's META-II (p.8); LISP70 (p.9); Ford's Pappy and Packrat parsing (pp.3, 8); Grimm's Rats! (p.8); Haskell parser combinators, Hutton & Meijer and Leijen & Meijer's Parsec (p.9); Ford's PEG paper (p.2); the visitor pattern (p.1); NSLR(1) scannerless parsing (p.3, ref. 13).

## D. Author's central problems

1. Compiler and parser work needs many tools, each with its own learning curve, so the skill is narrow (p.1).
2. ML-style pattern matching is good for structured data but not enough for lexing and parsing (p.1).
3. PEGs only match character streams, so they cannot process trees or structured configuration (pp.2-3).
4. Grammar reuse by copy or by inheritance causes code duplication, name clashes, and versioning problems (p.4-5).
5. Composing two grammars that share names is unsafe, and multiple inheritance would make clashes worse (p.5).
6. Semantic actions run during backtracking, so stateful matching can have effects that cannot be undone (p.5).
7. Packrat memoisation guarantees linear time but costs memory, and its benefit is unclear for the common case (p.4).
8. Productions with parameters cannot have those parameters matched in their bodies (p.9).

## E. Key terms

- PEG and prioritised choice: an ordered choice; there is no ambiguity, and the first alternative that matches wins (p.2).
- Operators (Table 1, p.2): sequence, prioritised choice, repetition, negation, production application, and character match.
- Notation: `::=` defines a production; `=>` is a semantic action (a host-language expression); `?` is a semantic predicate (a host boolean) (pp.2-3).
- `_` consumes exactly one element of any input. `end` is `~<_>` (p.3). `~~` is lookahead without consumption (p.3).
- List pattern: matches a list-like value by matching its contents against a nested pattern (p.3). Strings are lists of characters, so `"xyz"` and `'x' 'y' 'z'` are the same pattern (p.3).
- Parameterised production: a production taking arguments, which live on the stack, not in the input (pp.3, 9).
- `apply`: a higher-order production, which lets a production take a production (p.3).
- Grammar as class: `<:` for inheritance, `<super p>` for calling the overridden production, `init` and instance variables (pp.4-5).
- Foreign production invocation: lending the input stream to a production of another grammar (p.5).
- Lexically scoped syntax extension: a parser created at parse time, inheriting from the current one, active until the end of the enclosing s-expression (pp.6-7).
- Scannerless versus scanner-based parsing: one-character matching versus a token stage inside the grammar (p.3).
- Left recursion: productions that call themselves in the first position. The paper gives "special support" but no mechanism (p.2, fn. 1).
- Packrat memoisation: caching every intermediate result so that each production runs at most once per position (p.4).
- Automatic semicolon insertion: the `sc` production with lookahead (p.8).

## F. Main propositions and arguments

P1. A PEG generalises to arbitrary data when one primitive consumes one element of any sequence and the element kinds include strings, numbers, atoms, and lists (pp.2-3). Reasoning: once the input is a sequence, the PEG operators do not depend on what the elements are. Making a string the same as a list of characters lets one pattern language cover both (p.3).

P2. Parameterised productions make character classes and similar idioms definable by the user, so the language needs no built-in classes (p.3). Reasoning: `cRange x y`, a predicate-guarded character production, is said to be as convenient as a built-in class and more flexible (p.3). This is asserted through one example.

P3. Higher-order productions and semantic predicates bring parser-combinator expressiveness into PEG syntax (pp.3-4). Reasoning: `listOf p`, a production that takes a production, serves for both expression lists and name lists (p.3). The relation to combinator libraries is stated (p.4).

P4. Treating grammars as classes and productions as methods avoids name clashes and gives inheritance and overriding (pp.4-5). Reasoning: argued by analogy. `Java++ <: Java` extends a Java grammar by overriding one statement production and calling the inherited one with `<super stmt>` (p.5). The example does not run (p.4).

P5. Foreign production invocation composes grammars without inheritance clashes (p.5). Reasoning: `MetaCOLA` is the union of two languages. Inheriting from both would clash, and duplicating either grammar loses later changes. Lending the input to a foreign production avoids both problems (p.5).

P6. Stateful grammars, with instance variables and an `init` production, support context-sensitive features such as Python's indentation stack and a symbol table (pp.5-6). Reasoning: shown by the Python parser (p.5) and by Calc (Fig. 5, p.6). Calc's actions are interpreters, so semantic actions carry real computation.

P7. Semantic actions are not undone on backtracking, so stateful grammars must be written with that in mind (p.5). Reasoning: some actions, such as printing, cannot be undone. The paper states this as a limitation and does not solve it.

P8. Syntax extensions can be lexically scoped: a new parser is created at parse time inside an s-expression, so the extension applies only within that scope (pp.6-7). Reasoning: possible because the OMeta parser is itself written in OMeta and called through foreign invocation (p.7).

P9. Visitors over parse trees, and optimisations on them, can be written as OMeta grammars. The OR-flattening and null-elimination optimisers are grammars that inherit a traversal and override one production (pp.4, 6). Reasoning: this is the visitor pattern expressed as grammar inheritance (p.4).

P10. Pattern matching over program trees can check the arguments of variadic C calls, combining a counter (`rep`) with a format grammar (pp.7-8). Reasoning: `fmt` counts the arguments a format string needs, and `rep` checks the call against that count. The paper's example, as printed, has a problem (G2).

P11. Packrat memoisation is not essential. The COLA port memoises only argument-free productions, and the Squeak port does not memoise. The authors argue that memoisation's overhead can outweigh its benefit in the common case (pp.4, 8). Reasoning: "some of our experiments" are cited without data.

P12. The approach is practical at program scale: a 177-line JavaScript parser, and a nearly complete JavaScript implementation used on programs of about 2k lines (pp.7-8). Reasoning: this is the paper's main evidence of practicality, and it is anecdotal.

P13. OMeta adds backtracking and semantic actions to META-II, and so becomes as powerful as PEGs (p.8). Reasoning: META-II lacked backtracking, so grammars needed left-factoring, and its actions were print commands that forced code generation during recognition (p.8).

P14. OMeta is not a parser generator. It is a programming language whose control structure is PEG-based (p.8). Asserted; the difference is a matter of framing.

## G. Critique

Each charge is labelled by type. I say whether the paper demonstrates or asserts the point.

G1. Incomplete (left recursion). Footnote 1 (p.2) says OMeta gives "special support" to left-recursive productions. The paper does not state the semantics or the mechanism. Yet the arithmetic grammar in Fig. 1 (p.2) and Calc (Fig. 5, p.6) depend on left recursion, and Calc's left-associative results (p.5 transcript, e.g. `3+4*5` giving 23) are shown but not derived. A reader cannot tell what a left-recursive production means, or what it returns for a given input. Demonstrated by example only.

G2. Illogical (the printf example). In Fig. 7 (p.8), the first alternative of `expr` matches well-formed `printf` calls and has no semantic action. The paper's rule for a production without an action (p.2) says the value is the result of the last expression evaluated. Here that is the `rep` match, not the call. Yet the text says good calls stay as they are and only ill-formed calls become `BAD_PRINTF` (p.8). Either the figure omits an action or the default rule works differently from what the text describes. I did not run it. The implementation would settle it, and it is not in the sources.

G3. Incomplete (no formal semantics for the extension). Table 1 (p.2) defines only the PEG operators. The extensions have no definition: list patterns and the "list-like entity" that a string must be (p.3), arguments kept on the stack rather than the input (p.9), predicates, actions, foreign invocation, and `_` over arbitrary data. The paper does not say whether a list pattern must consume the whole list. Fig. 2's flattener (p.4) depends on that. The claim that OMeta extends PEGs cannot be checked against a definition.

G4. Incomplete (self-implementation). The keywords (p.1) say "metacircular implementation". The text shows: the parser is written in OMeta (p.7: "the OMeta parser itself was implemented in OMeta"), the optimisers are OMeta grammars (p.4), and the JavaScript parser is OMeta (p.8). But the step that turns parse trees into host code is in the host, "transformed by the OMeta compiler" (p.4), and that compiler is not shown. The implementations are in COLA and Squeak (p.2). The paper gives no bootstrap account: how the first OMeta parser was produced, and whether it can be regenerated from the grammar. The partial self-description is shown; a closed bootstrap is not.

G5. Interaction unexamined (memoisation and state). COLA memoises productions without arguments (p.4). Calc's `vars` is instance state (p.5), and semantic actions may have side effects that backtracking does not undo (p.5). If a memoised production has an action that reads or writes state, the memoised result skips the action on re-entry. Memoisation then changes observable behaviour, and the paper does not address that. Its linear-time guarantee also does not apply to productions with arguments, which are not memoised. The paper states this but does not price it.

G6. Unexecuted example. The `Java++` example, which carries the central object-oriented extension claim (P4), is stated not to run (p.4). The claim that such grammars can add a `foreveryother` loop to Java is therefore asserted, not run.

G7. Unmeasured claims. "Rapid prototyping" is said to be unrivalled (p.1). Hand-coded comparisons are not offered. The claim that the hybrid scanner idiom is "less error-prone" than scannerless parsing has no evidence (p.3). The memoisation overhead rests on unreported experiments (p.4). Performance "competitive with Rats!" is future work (p.9). The paper has no benchmark and only one code-size figure (177 lines for JavaScript, p.8).

G8. Limitation disclosed but unresolved (parameters). Production arguments cannot be matched in the body (p.9), because arguments are on the stack and matching uses the input. The authors say LISP70's approach would fix this and that they plan to adopt it. This is a known gap in the design, not a bug in the examples.

G9. Incomplete (built-ins). The grammars use `<empty>`, `<digit>`, `<letter>`, `<space>`, `<char>`, `<number>`, `<end>`, `<apply>`, `<foreign>`, and `<super>` (pp.2-8), but the paper does not list or define the built-in productions.

G10. Asserted framing. "ML-style pattern matching ... is not expressive enough on its own" (p.1) is given without an example or citation. The distinction between OMeta and a parser generator (p.8) is a matter of framing, not a demonstrated difference.

Summary of what is demonstrated: that the mechanisms work on the printed examples (Calc transcript, p.5; a 177-line JavaScript parser, p.8, in use). What is asserted: left recursion's semantics, the formal extension, the printf example as printed, the memoisation trade-off, the "less error-prone" and "rapid prototyping" claims, and the self-hosting story.

## H. What of it?

For the Maru rebuild, under the ≤10k-line budget, the DSL-and-grammar preference, the table-driven assemblers and disassemblers, and an evaluator to be generated by Maru's own emitter:

1. Grammar-driven implementation is the paper's central claim, and it bears on the budget. One matcher replacing several tools is attractive only if the matcher is small. The paper names the pieces (lists, arguments, predicates, actions, memoisation switch, inheritance, foreign invocation, jump tables, left-factoring) but does not size them. Decide which extensions Maru needs before writing the matcher. A plain ordered-choice PEG over characters and bytes, with actions, is much smaller than full OMeta.

2. Maru already has PEG machinery, and the paper's gaps match Maru's open items. The CLAUDE.md file lists `peg.l`, `pegen`, `earley`, and a `recursion` check for left-recursive PEG grammars. It also records that `test-peg.l` loops forever because the `definitions` rule matches empty input. The OMeta paper does not discuss repetition over a body that consumes nothing. That is the hazard in the Maru bug, and the fix belongs in the matcher's repetition rule: a body that consumes nothing must fail or stop, with a test. The `recursion` check passes, but the mechanism is undocumented. OMeta cannot supply a spec for it (G1), so Maru has to decide and document its own left-recursion semantics.

3. Table-driven encodings as grammars. OMeta's list patterns make a byte sequence matchable (pp.2-3), and parameterised productions (`cRange`, `rep`, pp.3, 8) can express field-parameterised encodings. A disassembler is then a grammar over byte lists, and an assembler's tables are productions. This matches the existing approach in Maru, where `gen-asm-x86.k` generates the assembler from a grammar. The paper does not apply OMeta to instruction sets; the suggestion is mine. Check any such grammar against clang output, as `asm_x86` already does.

4. Generation. OMeta compiles grammars to host code, and its code generator is in the host (G4). So the paper gives only a partial answer to the goal of generating the evaluator with Maru's emitter. Its optimisers (OR-flattening, jump tables, left-factoring, pp.4-6) are grammar-based passes that could serve as a model for the emitter's passes. The question of what sits at the bottom (untyped boot, typed `maru.k`, native) is the same bootstrap question raised by the object-model paper. Read that stack before settling the notation.

5. Side effects during parsing. Do not emit bytes inside semantic actions during a parse that can backtrack, because the output would survive backtracking (G5, P7). Emit in a separate pass over the parse tree.

6. Memoisation policy. If Maru memoises, restrict it to productions without state or arguments, and document the choice (G5). The COLA port's rule is a reasonable starting point; the paper does not justify it beyond "experiments" (P11).

7. Grammar inheritance and foreign invocation. For x86 and A64 variants that share an instruction-format core, the MetaCOLA argument (P5) suggests foreign invocation over copying or multiple inheritance, which the paper rules out (p.5, fn. 5). This is a suggestion to test, not a result from the paper.

8. The OMeta and object-model papers share a design shape: a small fixed core with user-visible, modifiable tables above it. The rebuild should state that shape once in its design note, then decide where the fixed core ends.

Open questions for the user: Is Maru's matcher input characters only, or also bytes and lists? Which left-recursion semantics does Maru adopt? Which memoisation policy? The answers set how much of OMeta's breadth the budget can carry.

## Permanent notes extracted from this source

None of its own. OMeta's generalisation of PEGs to arbitrary data is the ancestor of the structure matching in [[one-pattern-matcher-can-implement-every-compiler-stage]], which states the idea in its strongest, demonstrated form (Piumarta 2010).
