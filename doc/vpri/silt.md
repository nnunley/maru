
# Silt: a register-machine assembly language, parser and emulator

Silt is a small register-machine assembly language with a text syntax, an OMeta2 parser (SiltParser) and an emulator (SiltInterpreter). Yoshiki Ohshima wrote it in December 2012, and the package's license names Dan Amelang as co-copyright holder. A program is a list of functions, `@name (args):` followed by instructions, and data blocks, `@name:` followed by hex bytes. Registers are a type letter and an index (`i0`, `w1`). The interpreter calls `@main`. Its only system call that does anything is a write, which goes to a console collection or to Transcript. No paper in the corpus mentions Silt. The code and the version record are the only sources here.

## Why

The class comment of SiltInterpreter gives the purpose: "A SiltInterpreter is a simple emulator of the Silt virtual architecture." The version record shows how it grew. Silt-yo.2 (5 December 2012) "Take out arguments." Silt-yo.3 added comments. Silt-yo.4 (6 December 2012) says "Interpreter can run a simple test program." Silt-yo.9 (11 December 2012) says "Add a few more instructions to run a fibonacci numbers code." The apparent aim is a textual target small enough to parse and step through in a test. The INDEX.md entry describes it as "an emulator and parser for 'the Silt virtual architecture', with fibonacci code."

## How

The hello-world program from SiltParserTest>>funcDefString. The data block before it is `@hello_string:` with the bytes of "hello world" and a 0x00 terminator, in SiltParserTest>>dataDefString.

    @main ():
    	COPY @hello_string -> w1
    	SYSCALL 0x04 0x01 w1 0x0A
    	COPY 0x0A -> i1
    	RETURN i1

Running it, from SiltInterpreterTest>>testHello:

    vm := SiltInterpreter new.
    console := OrderedCollection new.
    vm console: console.
    hello := SiltParser matchAll: SiltParserTest basicNew helloWorldString with: #start.
    vm run: hello.
    console first = 'hello world'.

Recursive Fibonacci, from SiltParserTest>>fibString (parsed by the tests; no test runs it):

    @fib (i2):
        COPY 0x00 -> i0
        COMP i2 i0
        JUMP> .L1
        RETURN i0
    .L1: COPY 0x01 -> i1
        COMP i2 i1
        JUMP!= .L2
        ...

Syntax the parser accepts (SiltParser rules): literals `0x` with 2, 4, 8 or 16 hex digits are a byte, short, int or long (`b s i l`). A decimal literal is a float as `42.5` and a double as `42..5`: the parser takes the type from the separator, and there is no suffix. Local labels start with `.`, global labels with `@`. `;` begins a comment. Operands are register references, literals and labels. An instruction may end with `-> dst`.

Two things in the interpreter are worth knowing before you rely on it:

- `syscallWith:` writes `arguments fourth + 1` bytes: `memory copyFrom: arguments third + 1 to: arguments third + 1 + arguments fourth`. The hello test passes length 0x0A and expects the eleven bytes "hello world". So a write of length n prints n + 1 bytes. This looks like an off-by-one that the test takes as its answer.
- Only syscall 4 (write) to fd 1 is implemented. Other numbers return nothing useful.

## When

- **Dates and authors.** Silt-yo.1 (5 December 2012) to Silt-yo.9 (11 December 2012). All versions are by yo. The ancestry record holds eight (yo.2 to yo.9). The server listing holds nine, including Silt-yo.1 (packages.tsv, 2012-12-05 03:28 UTC), which the record leaves out. The record's times are local: Silt-yo.2's 10:16 am is the server's 18:16 UTC. INDEX.md follows the server, so it is correct.
- **Status.** Not in the Frank image (INDEX.md). The last change is the Fibonacci one. The test suite has four interpreter tests (accessors, hello, lookup, memory) and no run of Fibonacci. I did not run the tests, since they need Squeak.
- **Reach for it** when you want a worked OMeta2 grammar for a small assembly, or a plain interpreter for typed registers to compare with a native back end. It is not a path into Frank's documents.

## Family of expression

Silt is the low end of the same stack that Maru's typed IR sits in. Its register types are sized: `b` 1 byte, `s` 2, `i` 4, `l` 8, `w` 8 (a word), `f` 4, `d` 8 (SiltInterpreter>>sizeOf:). Maru's ir2 has the same kind of typed slots, `int8` through `int64` with their sizes and alignments (ir2.k, lines 41 to 44). Silt does its typing at run time, from the register's letter. ir2 does it at compile time.

Silt's pipeline is parser, tree, interpreter. Maru's native path is typed IR, then architecture-neutral intents (native-gen.k: `enter`, `call`, `params`, `return`), then arm64 forms lowered by native-arm64.g (draft-ndn-maru-native-ir2-00). Silt stops at the interpreter. Maru's path ends in machine code that runs.

## Links

- Related: [siss](siss.md), [j](j.md), [ometa2](ometa2.md)
- Maru repository (this repository): `ir2.k` (typed IR and sizes), `native-gen.k` (intents), `native-arm64.g` (lowering), `doc/rfc/draft-ndn-maru-native-ir2-00.md` (the native design), `doc/plans/2026-11-06-native-ir2.md` (the plan).

## Sources

- package Silt, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- https://tinlizzie.org/updates/exploratory/packages/
- STEPS 2010 report, VPRI TR-2010-004
- `ir2.k` in this repository
- `native-gen.k` in this repository
- `doc/rfc/draft-ndn-maru-native-ir2-00.md` in this repository
