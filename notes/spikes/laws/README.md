# Laws and rules spike (throwaway)

Measurements behind draft-ndn-maru-laws-and-rules-00, Appendix A. This is
experiment code, not the implementation: it is kept so the numbers can be
re-run and checked, and it is not counted in `check/lines` (`notes/`).

Run everything from the repository root. Nile's grammar must be compiled
first (the output is ignored by git, as every `*.g.l` is):

    ./eval compile-tpeg.l nile/compilers/maru/nile-grammar.g > notes/spikes/laws/nile-grammar.g.l

| Script | Measures |
|---|---|
| `m1.l` | `cexpr.g` sentences generated from its own records that its parser accepts |
| `hex.l` | parses `0xq`; it lacks `text-parser-invoke-rule-with-recursion`, so `eval` overflows its stack on any input (exit 139), which was first misread as `0xq` crashing |
| `m2.l` | Nile sentences generated from its grammar that parse |
| `m3.l` | of those, how many Nile resolves and type-checks (forked, one per candidate) |
| `m4.l` | hole kinds inferred from the parser (fails) |
| `m5.l`, `m6.l` | holes as placeholder names, in `cexpr` and Nile templates |
| `t1.l` | the Nile expression rules generate, check and enumerate |
| `t2.l` | Nile as the reference, on five known cases |
| `m7.l` | laws on the rule set: sound, generate-checks, coverage, agree |
| `m8.l` | 42 mutants, caught by random cases (23) |
| `m10.l` | the same mutants, caught by exhaustion at size 1 (42) |
| `m9.l` | the engine's unification law |
| `xc1.l`, `xc2.l` | write cases and the spike's verdicts to `/tmp/maru-laws-xcheck` |

The files: `gen.l` generates from a tpeg grammar's records; `logic.l` is
the engine; `nile-rules.l` the Nile expression rules; `meta.l` the laws
about a rule set; `oracle.l` and `nile-load.l` load Nile's parser,
resolver and type checker into this tree's `eval`.

## Cross-check against Nile's own setup

`xc1.l` and `xc2.l` write `cN.nl` and `cN.spike` files. To judge them
with Nile's real compiler on its bundled Maru, copy `nile/compilers`
somewhere scratch, then in its `maru/maru`:

    make eval tpeg.l
    make gceval CFLAGS="-Wall -O3 -fomit-frame-pointer -DNDEBUG -I/opt/homebrew/include" \
                LIBS="-lm -lffi -ldl -L/opt/homebrew/lib"

(`gceval` links Boehm GC, which arm64 Homebrew installs under
`/opt/homebrew`, outside the compiler's default search path.) Then, from
the copy's `compilers/maru`, compile each case:

    ./maru/gceval -b maru/boot.l -L maru/ nile-compiler.l $PWD maru M /tmp/maru-laws-xcheck/cN.nl

and read the output: `Done.` is accept; `incompatible`, `undefined`,
`Couldn't find`, `must be explicitly typed` or `error in Nile program`
is reject; anything else is a crash. Nile exits 0 either way. All 64
verdicts agreed (October 2026).
