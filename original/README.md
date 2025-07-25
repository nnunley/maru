Maru (○)
Maru is a symbolic expression evaluator that can compile its own implementation language.
There are two versions. The original version has been described in various forums (such as [1]) and is preserved both as a reference implementation for those descriptions and as an almost-minimal proof of concept. The current version has departed from and expanded on the original, and is where new development is being done. Parts of it have also been described in various forums (such as [2]) and so keeping both versions publicly accessible seems expedient.

The original version
The whole thing is 1750 lines of code (about twice what it should be) and includes a garbage collector and user-level implementations of user-defined types and structures, single-dispatch object-oriented "messaging", and generic "multimethods" (all of which are needed by the compiler). The compiled binary code runs at about 30% the speed of aggressively-optimised C.

Maru runs on Linux, Darwin (Mac OS X) and Windows (Cygwin and/or MinGW). On Linux just type make, otherwise edit the first part of emit.l appropriately first.

The parts
boot-eval.c
contains a reader/evaluator for a simple s-expression language, written in C.

eval.l
contains the same evaluator, written in the s-expression language. In other words, eval.l is a metacircular evaluator for the language it is written in.

emit.l
contains a compiler from s-expressions to IA32 machine code, written in the s-expression language. This compiler can be thought of as a semantics-preserving "level shift" from s-expressions to IA32 machine code, letting the metacircular evaluator in eval.l escape from "infinite metacircular regression" to a language grounded in hardware.

boot.l
contains the data structures, algorithms and paradigms that are needed by emit.l, written in the s-expression language.

Makefile
contains the commands needed to build everything.
The recursive implementation and compiler (in the three .l files) is split into three parts for clarity, but they could all be in a single source file.

The process
boot-eval.c is compiled to make boot-eval, an s-expression evaluator. boot-eval is then run on the concatenation of boot.l, emit.l and eval.l, which together implement an s-expression compiler and a metacircular evaluator for s-expressions; the output from evaluating them is eval.s — a machine code implementation of the s-expression evaluator described by eval.l. eval.s is then assembled and linked to make eval, which can be run on the concatenation of boot.l, emit.l and eval.l to recreate (an identical) eval.s. The C compiler is thereafer entirely out of the loop, unless you break eval and have to bootstrap it again.
The s-expression language has a few interesting characteristics some of which are exhibited by the way user-defined types and structures are implemented, and the way object-oriented single-dispatch messaging and generic functions (multimethods) are added to the language at runtime in boot.l. The compiler makes some attempt to be small and simple, and no attempt whatsoever to optimise.

The performance figure of 30% of optimised C was calculated by comparing the time needed for generating eval.s by eval and boot-eval. (The C-compiled boot-eval gains a significant advantage by inlining the entire implementation of the critical function assq into callers in several places.)
