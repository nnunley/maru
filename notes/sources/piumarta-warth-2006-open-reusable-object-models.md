# Open, extensible object models (Piumarta & Warth, 2006, VPRI TR-2006-003-a)

Source: https://tinlizzie.org/VPRIPapers/tr2006003a_objmod.pdf

Page numbers are the printed TR page numbers. The cover reads "Open Reusable Object Models"; the title on the first body page is "Open, extensible object models". The same work appeared as Piumarta & Warth in LNCS 5146 (S3 2008). I read the converted text only; I did not compile or run Appendix B.

## A. Classification

- Genre: technical report, later a workshop paper. Design paper with a reference implementation and a short evaluation.
- Field: programming-language implementation; object models; open implementation; prototype-based languages.
- Contribution, in three parts: (1) a three-type, five-method object model with a bootstrap sequence (pp.3-14); (2) a GNU C implementation of it (Appendix B, pp.26-30); (3) demonstrations that the model can host JavaScript-style objects, Traits, closures, and mixed-mode execution, plus a micro-benchmark (pp.15-22).
- Argumentative mode: constructive. "This small thing can be built, and here is what it lets you do." Evidence is worked examples, a C program, and timings on one machine. No comparison with other object-model implementations and no user study.

## B. Unity

One idea organises the paper: the object model is itself made of objects and messages, so the only fixed part is small, and everything above it, including message sending, is ordinary user-visible code. The fixed part is the `lookup` method of a "vtable of vtables" (pp.3, 9). Every other feature (type addition, multiple inheritance, closure slots, mixed-mode execution, JavaScript properties, Traits) is shown to be an ordinary method installed in that system. The stated aim is to remove the split between an implementation level and an end-user level (Abstract, p.1; Sec. 1, p.2).

## C. Outline of major parts

Sections, with printed page ranges:
- Abstract (p.1).
- 1 Introduction (pp.1-3). Motivates with a tagged-union representation and with delegation. Lists contributions (p.3).
- 2 The object model by example (pp.3-6). 2.1 Adding data types (pp.4-5). 2.2 Multiple inheritance in a prototype language (pp.5-6).
- 3 Open, extensible object models (pp.6-16). Minimal model (pp.6-9). Essential objects and methods (pp.9-11). Message sending (p.12). Bootstrap (pp.12-14). Bindings (p.14). Caches (pp.14-16).
- 4 Extensions that improve generality (pp.15-18). Closures (pp.15-17). Self-like slots (p.17). Mixed-mode execution (p.18).
- 5 Evaluation (pp.18-22). 5.1 JavaScript objects (pp.18-19). 5.2 Traits (pp.19-20). 5.3 Benchmarks (pp.21-22). 5.4 Limitations (p.22).
- 6 Related work (pp.22-23). 7 Conclusions and further work (pp.23-24).
- Appendix A, prototype-language syntax (pp.25-26). Appendix B, GNU C implementation (pp.26-30).

Concrete artifacts named:
- C tagged-union `struct Object` with an integer tag and a payload union (p.2); switch-based `length()` (p.4); a Vector type added by a new vtable (Fig. 1, p.5).
- Prototype language with `addParent:` and `ParentList` (Fig. 2, p.7); example families C1, C2, C3 (p.6).
- Figures of the minimal object (Fig. 3, p.8), object layout with vtable pointer at offset -1 (Fig. 4, p.8), vtable layout (Fig. 5, p.8), vtable-of-vtables (Fig. 6, p.9).
- Table 1, the three types and five methods (p.9).
- Pseudo-code for `symbol intern` (Fig. 7, p.10), `vtable addMethod` (Fig. 8, p.10), `lookup` (Fig. 9, p.11), `allocate` (Fig. 10, p.11), `delegated` (Fig. 11, p.11).
- `send` and `bind` (p.12); bootstrap sequence (Fig. 12, p.13); the initialised object universe (Fig. 13, p.14).
- Inline-cache `send` macro (Fig. 14, p.15); global method cache in `bind` (Fig. 15, p.16).
- Closure-based vtables (Fig. 16, p.16); closure-taking `addMethod`, `send`, `bind` (Fig. 17, p.17); getter/setter self-like slots (Fig. 18, p.17); shared interpreter for mixed-mode execution (Fig. 19, p.18).
- JavaScript-style `get` and `set:to:` (Fig. 20, p.19); Trait `addTo:` and `traitMethodAt:put:` (Fig. 21, p.20); the T1/T2/C Trait example (p.20).
- Benchmarks: nfibs(34), static C versus dynamic send (p.21); length over 40 objects, switch versus object-based with global and inline caches (p.22).
- Platform: 2.16 GHz Intel Core Duo, Darwin 8.8.1, gcc-4.0.1 (pp.21-22, fn. 6).
- Appendix B, the GNU C implementation (pp.26-30), with reported object sizes of 1,453 and 1,822 bytes (p.21).
- External artifacts: the prototype language and its implementation, "COLA" at piumarta.com/software/cola (p.5, fn. 1); the object-model reference implementation at piumarta.com/software/id-objmodel (p.22, fn. 7); the Lieberman-prototype memo RM-2007-002-a (p.18); Self (p.23); Smalltalk-80 (p.23); TinyObjects (p.22); Traits (p.20); ECMAScript (p.18); the mixed-mode execution patent (p.18, ref. 10).

## D. Author's central problems

1. Low-level representation decisions become unchangeable. A tag-based union fixes the layout and the set of types, so end users cannot add payloads or tags without rebuilding the implementation (pp.1-2).
2. Adding a behaviour to every primitive means editing every primitive. A new type shared with third parties breaks unless every primitive anticipated it (p.4).
3. Eager reification of semantics. When a runtime bakes single delegation into its structure, multiple delegation is hard to add because the runtime assumes one parent (pp.2-3).
4. Existing remedies are partial. Metaobject protocols give control at a separate meta level (p.1, p.22). Smalltalk's reflective methods cannot change message sending or object layout (p.23). Self and Lieberman prototypes hide some semantics such as slot lookup (p.23).
5. Implicit in the Abstract: the split between implementation and user language is itself the cause, and the designer should not have to get everything right in advance.

## E. Key terms

- oop: the pointer to an object's state. Its vtable pointer sits one word before it (p.7).
- vtable: an object that maps selectors to behaviour. Its `lookup` method defines the object's responses (p.3).
- lookup: the method that maps a selector to a method (later, a closure). It is the single point of semantic control (p.3).
- selector (symbol): an interned, unique name for a message, compared by identity (p.10).
- bind and send: `bind` asks the receiver's vtable to `lookup` the selector; `send` calls the result (p.12).
- allocate: vtable method creating an object in that vtable's family (pp.10-11).
- delegated: vtable method creating a child vtable whose parent is the receiver (p.11).
- vtable-of-vtables (VtableVT): the vtable that describes all vtables, including itself (pp.8-9).
- closure: a method plus a data slot. Carries state for slots and interpreters (pp.15-16).
- inline cache and global method cache: a per-send-site memo of the last vtable and method; a hashed table keyed on vtable and selector (pp.14-16).
- mixed-mode execution: one interpreter shared by many closures whose data are code (p.18).
- Traits: method-only composable units whose conflicts are signalled (pp.19-20).

## F. Main propositions and arguments

P1. An object's behaviour is fixed by its vtable's answer to `lookup` (pp.3, 12). Reasoning: sending a message is defined as two steps: find the vtable, send it `lookup` with the selector, and call the result. Overriding `lookup` for a vtable therefore changes the sending semantics of every object that vtable describes (Figs. 9, 17).

P2. Three object types and five methods are sufficient to bootstrap an extensible model (Abstract, p.1; Table 1, p.9). Reasoning: constructive. The bootstrap (Fig. 12, pp.12-14) needs each method to reach the next step: `lookup` for sending, `addMethod` for populating vtables, `allocate` for making symbols, `intern` for creating `delegated`, and `delegated` for new behaviours. The paper does not argue that removing any one would break the system in general, so "minimal" is suggested, not shown.

P3. The self-description cycle is broken by one special case. A vtable's vtable is itself. Sending `lookup` to VtableVT is short-circuited to call the native `lookup` directly (p.12; code p.28). Reasoning: without the short-circuit, binding `lookup` needs sending `lookup`, indefinitely.

P4. The bootstrap can be ordered so each step uses only what is already in place: create the three vtables, install `lookup`, `addMethod`, and `allocate` by direct native calls, then intern symbols, install `intern`, and finally `delegated` (pp.12-14). Reasoning: until `lookup` exists, messages cannot be sent, so the first installs must be direct calls.

P5. Adding a type needs only a new vtable and its methods; no existing primitive changes (pp.4-5; Fig. 1). Reasoning: each primitive becomes a send, so the tag switch is replaced by dispatch on the object's vtable.

P6. Compiled-language vtables (C++) fix their layout at compile time, so adding a virtual method forces recompilation (pp.4-5). Reasoning: an assertion about C++ layout, used to motivate a runtime-extensible model. The paper does not consider runtime-extensible dispatch tables in other languages.

P7. Multiple inheritance can be added in user code with no loss of performance (pp.5-7; footnote 2, p.6). Reasoning: `lookup` is a message, so the parent slot can hold a `ParentList` that answers `lookup` by searching its members (Fig. 2, p.7). The performance claim rests on the method cache making the chain walk rare.

P8. Closures (method plus data) make slots and mixed-mode execution possible without changing the calling convention (pp.15-18). Reasoning: each method receives its closure, so one interpreter can serve many code blobs (Fig. 19), and a getter and setter pair can share one implementation (Fig. 18).

P9. JavaScript's delegation-based objects can be built on the model by translating field access into messages. Assigning `proto` changes the vtable's parent and flushes caches (pp.18-19). Reasoning: asserted through Fig. 20. No test is reported.

P10. Traits can be built by copying method closures into a target vtable and signalling name conflicts. Composition operators follow from that (pp.19-20). Reasoning: methods are data, so combining them is a loop. Exclusion and aliasing are "left as an exercise" (p.20).

P11. Performance is competitive. Dynamic send through an inline cache is about 56% of the speed of a static C call on nfibs(34) (p.21). An object-based `length` runs at about 70% of a switch-based one, about 90% with a global cache, and about 207% with an inline cache (p.22). Reasoning: the inline cache avoids a `bind` when consecutive receivers share a vtable, so the receiver order in the benchmark is a hidden variable (see G6).

P12. The model is small: the essential objects and methods come to about 140 lines of C, with object code of 1,453 bytes (1,822 with caches) (pp.21, 24). Reasoning: a count of code the paper presents, under a counting convention it does not state (see G7).

P13. Openness follows from circularity, as McCarthy's self-describing evaluator showed for Lisp (p.23).

P14. The model is a poor surface for hand-written code and an attractive target for automatic translation, including for statically typed languages (p.23). Reasoning: uniform structure makes generation easy. This is the authors' judgement, not tested.

P15. Experience: implementing the core took about three hours, and a similar form has been in daily use by several people for over a year (p.24). Anecdotal.

## G. Critique

Each charge is labelled by type and by whether the paper demonstrates or asserts the point. I read the code; I did not compile it.

G1. Overstated (misinformed). The Abstract and Sec. 1 say the implementation/user distinction is eliminated. Sec. 3.4 (p.14) lists three things still written in the implementation language: layout definitions, the five essential methods, and the invocation mechanism. Appendix B shows the five methods are native C functions installed as values (Fig. 12, p.13; code pp.28-30). The distinction is moved to a smaller native layer, not removed. Demonstrated against the claim by the paper's own text.

G2. Overstated (misinformed). The Abstract says messaging semantics are "described entirely in terms of those same objects". `lookup` is user-replaceable (Figs. 9, 17), but `send` and `bind` are not. Sec. 5.4 (p.22) says they "cannot be exposed as easily" and points to Sec. 7. Sec. 7 (p.24) defers the work to "forthcoming publications". Only the lookup half is shown.

G3. Incomplete (illogical gap). Sec. 3 (p.9) and footnote 5 say a new vtable-of-vtables can be created to give a different `lookup`. But the cycle break in `bind` (p.12; code p.28) tests for the global VtableVT. If a replacement V2 is installed, its vtables send `lookup` through V2, and `bind(V2, lookup)` is not short-circuited. It then sends `lookup` to V2 again, indefinitely. The break condition must be generalised, which the paper does not show. Footnote 5 says `addMethod` would be overridden in parallel but says nothing about `bind`. Asserted, not demonstrated.

G4. Incomplete (the reference code does not run the paper's own examples). Cache invalidation is absent. The structural changes in Sec. 2.2 (`C3 vtable addParent:`, p.6) and the `proto` assignment in Fig. 20 (which calls `flush`, p.19) are wrong under a global method cache unless caches are invalidated. The paper calls invalidation "simple but beyond the scope" (p.15) and "neither described nor counted" (p.22). In Appendix B, `vtable_addMethod` and `vtable_lookup` (p.29) do not touch `MethodCache`, and `_bind` (p.28) returns cached entries unconditionally. The "no loss of performance" claim and the dynamic-inheritance demonstrations are not backed by the code given.

G5. Incomplete (inconsistent model). Appendix B implements the Sec. 3 model, not the Sec. 4 model. `method_t` takes only the receiver and arguments (p.26). `vtable_addMethod` stores the function pointer directly (p.29). `bind` returns a method, not a closure (p.28). Yet Sec. 4 says closures are what provide slots and mixed-mode execution (pp.15-18), and Sec. 5.3 says the benchmark follows "the algorithms and structure presented in this paper" (p.21). The timings and the size figure are therefore for a model without the features whose generality is claimed. The cost of closures, called a "slight increase in complexity" (p.16), is never measured.

G6. Unsupported measurement. The benchmarks (pp.21-22) use one machine, one run per configuration, and report no variance. The switch baseline is not shown, and the iteration order over the 40 objects is not given. The inline cache in Fig. 14 remembers only the last vtable at one send site, and `length` sends from one site to four different vtables. The hit rate, and so the 207% figure, depends on the unreported order. The nfibs result is admitted to be "polluted" by arithmetic (p.21). The text also says the global-cache version is "within 10%" of C (p.22), but the table gives 90.3%, which is about 11% slower. The headline numbers need the order and repeated runs.

G7. Incomplete definition (size claim). "Approximately 140 lines" (p.21) and "140 lines of source code" (p.24) do not state what was counted. In the converted text, Appendix B (pp.26-30) is about 180 non-blank lines, including headers, comments, cache macros, and initialisation. So 140 is a subset with unstated boundaries. The count also leaves out constructors (p.22), the vtable pointer (p.22), and the cache invalidation the paper omits (G4). The "tiny" claim is therefore a claim about an unspecified configuration.

G8. Overstated (self-description). The Abstract says the model is described in its own objects, but the five essential methods are native C. Fig. 12 installs C function pointers (p.13), and Appendix B confirms it (pp.28-30). Self-description covers dispatch and structure, not the primitives.

G9. Asserted, not shown. Fig. 20 uses `methodAt:put:`, `setData:`, and `flush`, none defined in the paper. Fig. 21 uses `keysAndValuesDo:`, `methodAt:put:`, and `errorConflict:`, also undefined. Trait exclusion and aliasing are said to take "a few minutes each" (p.20). The prototype language is "written entirely in itself" (p.5, fn. 1), but its code is not in the paper, so self-hosting is not shown here.

G10. Incomplete error path. When `lookup` finds nothing, Fig. 9 returns nil (p.11), and the send calls the result with no check (p.12). In Appendix B, a failed lookup prints a message and returns 0 (p.29), so the caller invokes a null pointer. The paper describes no "message not understood" protocol, although the delegation examples depend on fall-through and failure behaviour.

G11. Thin related work. The comparison set is short: C++ tables (pp.4-5), TinyObjects (p.22), Smalltalk metaclasses (p.23), Self maps and Lieberman prototypes (p.23). The paper does not discuss runtime method-table designs in other languages, such as Objective-C's, which also allow methods to be added at run time. This is an outside point, not an error in the source.

G12. Minor. Fig. 11 (p.11) assigns `child.value` where the surrounding text uses `values`. The argument against C++ (P6) credits the static layout alone. The paper's own model keeps a fixed core (`lookup` and the vtable layout, p.9). The real advantage is that the fixed part is small and user-replaceable. The paper does not say this plainly.

Summary of what is demonstrated: the bootstrap order and the five-method core are presented as running C (pp.26-30), and the JavaScript and Trait examples are shown as code fragments. What is asserted: minimality, the performance story under caching, the closure and mixed-mode generality as run code, the Trait operations not shown, and the self-hosting of the prototype language.

## H. What of it?

For the Maru rebuild with a ≤10k-line budget, a DSL and grammar preference, and an evaluator to be generated by Maru's own emitter:

1. The kernel size is affordable. Three types, five native methods, and send and bind fit the scale the paper claims (G7 shows the exact count depends on convention). Do not copy Appendix B as-is. It lacks closures and cache invalidation, which the paper's own examples need. Put both in the first version and record the line delta in the `check/lines` file (per CLAUDE.md), so the budget stays visible.

2. Turn the bootstrap into a test. Fig. 12 is an ordered sequence that can be checked. Mirror `osdefs_bootstrap`: build the object system from the native layer, then run a sample that exercises `lookup`, `addMethod`, `allocate`, `intern`, and `delegated` in that order.

3. Close the cycle-break gap on purpose (G3). The evaluator is to be generated, so the rule that breaks the vtable-of-vtables cycle has to be a deliberate design decision. Either parameterise the `bind` short-circuit on the vtable-of-vtables identity, or declare replacing it unsupported. Add a check in either case. The paper leaves this open.

4. Generated code and caches. The paper says the model suits generation and not hand-written code (P14). That fits the plan: author the spec, generate `send` and `bind`, and have the emitter produce per-site inline caches (Fig. 14) rather than writing caching by hand. Specify the invalidation rule (any change to a vtable's contents or parent flushes) before the emitter depends on the cache layout (G4).

5. Table-driven assemblers and disassemblers. The idea of a selector mapping to a closure whose data hold a template can carry an opcode table: mnemonic to encoder closure, with the encoding template as data. The paper gives no evidence at table scale (its examples have two to four entries). Measure a table of the size the x86 and A64 specs need before relying on dispatch for it.

6. Benchmark protocol. If the rebuild cites speed, record the iteration order and the cache hit rate, and repeat runs. The paper omits all three (G6).

7. Do not adopt "eliminates the distinction" as a requirement (G1). A realistic design rule is: a small native layer (five methods plus send and bind), with everything else user-visible and modifiable. Write that rule into the design note.

Open question for the user: the paper's native layer is C. Maru's untyped boot is also C-hosted (eval.c, boot.l), and its typed layer is maru.k. Decide which layer holds the five native methods, and whether the object model is written in boot.l first or generated from a spec. The bootstrap circularity in the paper applies to that choice. Read the whole stack (untyped boot, then maru.k, then native) before settling the notation, as the project memory advises.

## Permanent notes extracted from this source

- [[messaging-is-self-describing-when-lookup-is-a-message]]: lookup on cache miss is a message; the vtable is its own vtable
- [[a-line-count-needs-a-stated-boundary]]: size claims need their counting boundary written down
