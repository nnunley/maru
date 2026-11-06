# Maru

## What this is

Dan Amelang's Maru as of 2012-12-24 (`ac07e5e`), as used for Nile, on top of
Ian Piumarta's 2.4 release, with Kurt Stephens' fork merged in. Kurt's merge
adds only `maruby.l`; his other changes are in the history, not the code.
`ac07e5e` is Piumarta's own commit `e8356c4` (less `.hg_archival.txt`); his
history behind it (from 2010-10-30) and his 2013 commits after it (to
2013-11-12: label and goto, keyword `make`, `eval3`, the SDL2 example) are
merged in, from attila-lendvai/maru's `piumarta` branch. A replace ref grafts
`e8356c4` under `ac07e5e` for log and blame; fetch it with
`git fetch origin 'refs/replace/*:refs/replace/*'`.

The layout is flat, as upstream intended: `require` and `load` resolve
relative to the current directory, so run everything from the repo root.

## The goal, and its core reference

The end goal is to synthesize the rest of VPRI's work into something that runs on modern
machines. [tinlizzie.org](https://tinlizzie.org/), the archived VPRI site, is a core reference
for that: the papers (`/VPRIPapers/`) and the top-down system's own dump (`/dbjr/`, including
the KSWorld `.pp` bundles). Keep third-party texts in `~/pkm`, not in this tree, with one exception: `ksworld/` is
KSWorld's own source, every KS class as Frank's image last had it (`ksworld/README.md` says where it comes from), kept
here as the reference for the KSWorld work. Its `.st` files aren't counted in `lines`.

## Other history (tags)

`refactor-main` (the 2025 reorganization, with unfinished ARM64 experiments
in `core/compiler/ir-gen-arm64*.k`), `amelang-nile` (Dan's repo for Nile),
`linear-main`, `kurt/*`, and releases `v1.0-original`, `maru-1.0`,
`maru-2.1` … `maru-2.4`, `maru-last-vpri`, `v2.5-vpri-complete`.

## Build

    make    # eval, eval2, eval3, osdefs.k, and eval32 where -m32 links (not macOS)

`eval3` (Piumarta, 2013) is the third iteration of the bootstrap and `eval2`'s successor: it boots
`boot2.l` too. Piumarta's `eval2` had `subr` commented out, and `eval3` restored it through libffi;
both now share one `subr`.

On arm64 macOS with Rosetta, `make check` also builds `bin/x86_64/eval` and
`bin/x86_64/eval2` (`-arch x86_64`) to run x86-64 code in-process.

`nile/` and `gezira/` are submodules (forks on `nnunley`); clone with
`--recurse-submodules` or run `git submodule update --init`.

`osdefs.k` describes this machine. `compile-osdefs.l` (run by `eval`, which
doesn't need it) turns `system.osdefs` into a C program, `system.osdefs.c`,
that the host compiler builds and runs to measure it. Any other `X.osdefs`
builds the same way; the `.c` and the program are temporary.
ir2 takes the size of each C type (`char` … `long`, pointers) and every
alignment from `osdefs.k`; fixed-width types (`int8` … `int64`) have their
sizes by definition.

## Verify

    make check

`make check` runs the cases four at a time (`check/parallel.l`, `MARU_CHECK_JOBS` to change it), and says which were slowest, in CPU time; `times` in its directory has each case's wall and CPU time in milliseconds, peak memory (bytes on macOS, kilobytes on Linux), disk blocks, minor and major faults, and switches;
`make check-quick` leaves out the slowest, for everyday edits. Everything runs before a merge. `make check-sweep` looks for new
corner cases: the generated laws on fresh seeds, more trials and every evaluator; a failure names its seed, and `MARU_LAW_SEED`
reruns it. A checkout writes under `/tmp/maru-check/` in a directory of its own, so two can run at once.

`check/check.l` (untyped Maru, built on boot.l's `unit-test`) runs each demo and
asserts what it computes; `make check CHECKS="NAME…"` runs selected cases, after
building what is stale. Libraries and grammars that checks open are built by make into
`build/` (`CHECK_LIBS`, failures ignored so the other checks still run), and a check asserts
`make -q` on what it opens; `make clean` removes `build/`. Run cases through make, not
`./eval check/check.l` directly: no case names the derived files it needs (`law.g.l`, `cexpr.g.l` …), so a
direct run in a fresh or stale tree fails on a missing or old grammar.
Typed checks are ir2 programs in `check/` (`ir2.k`, `gc.k`), as upstream's
`maru-check.k` is.

- `osdefs`: `osdefs.k` agrees with the compiler's predefined macros.
- `pepsi`: the Smalltalk-like language's FFT peaks at bins 2 and 6.
- `recursion`: left-recursive PEG grammars match as expected and build a
  left-associative tree.
- `peg_compose` (`check/peg-compose.l`, `check/peg-lr.l`): grammars that
  call each other's rules keep their memos apart, an inherited rule calls an
  override, and a left-recursive entry rule grows, in `parser.l` and
  `text-parser.l`.
- `repl`: a language defined at the REPL prints a correct multiplication
  table and `nfibs(15)`.
- `pegen`: a generated PEG matcher stops at the first unmatched character.
- `earley`: Earley parsing of `1+2*3` respects precedence.
- `maruby`: Ruby arithmetic and method calls.
- `maru_test`: a program compiled through the ir2 C backend computes primes
  and struct arithmetic.
- `asm_x86` (`check/asm-x86.l`): the x86 assembler that make generates from
  `gen-asm-x86.k` (C preprocessor encoding macros, read by a grammar) encodes as
  `clang -target i386` does. Change the spec, never `asm-x86.k`.
- `ir2` (`check/ir2.k`): sizes, alignment and struct padding match `osdefs.k`;
  pointer offsets of any integer width move by bytes at full pointer width; an indexed element is an lvalue, as in C,
  so a struct in an array has its fields read and written in place and `(addressof (indir s i))` is i elements in.
- `core_forms` (`check/core-forms.l`): arithmetic, comparison and logical
  forms give the same values untyped and through `maru.k`.
- `zero_global` (`check/zero-global.k`): a global declared with no
  initialiser, `(define (name T))`, starts at zero, for a scalar and a struct.
- `maru_check`: upstream's own ir2 test, `maru-check.k`, passes all sections.
- `maru_label`: Piumarta's `maru-label.k`, through the C back end: `label` and
  `goto`, plain, computed from an `if`, and through a label held in a variable.
- `eval3`: `eval3` runs `boot2.l` with the `boot2_strings` and `asm_interface`
  cases, and `dlextern` (`check/dlextern.l`, as `libsdl2.k` uses it) calls libc
  through `subr` in `eval3` and `eval2` alike.
- `sdl3_window` (`check/sdl3-window.k`, `sdl3.k`): `sdl3.k`, typed SDL3 over its C functions (measured in `sdl3.osdefs`), opens a
  window on SDL's dummy video driver, draws a known frame, reads its pixels back at four points and round-trips a mouse button,
  a motion and a key event. Offscreen fails on macOS (no GL), so the case sets `SDL_VIDEO_DRIVER=dummy`. `sdl3.osdefs.k` is
  measured from this machine's SDL3 headers when the check builds (it isn't tracked), and the case asserts it's up to date.
  Where `pkg-config` finds no SDL3 (or there's no `pkg-config`) it prints `SKIP` and passes.
- `maru_gc`: the GC written in Maru allocates 2.56M cells, collects, and
  frees everything.
- `maru_gc_coalesce` (`check/gc.k`): its allocator grows the heap when needed
  and merges adjacent free chunks.
- `text_parser`: `text-parser.l` matches a string literal that ends at the
  end of its input.
- `cexpr_forms` (`check/cexpr-forms.l`): `cexpr.g` parses C's expressions,
  with C's precedence, to Maru forms.
- `john_forms` (`check/john-forms.l`): `john.g` (inheriting `cexpr.g`) and `john.l` read
  JOHN, Samimi's VPRI planning language, as reconstructed in
  `~/pkm/wiki/synthesis/john-language-reconstruction.md`: the three complete programs in
  `check/john/` (Hanoi4, the puzzle and x86 register allocators) to 31, 47 and 33
  statement forms. A keyword argument is one primary and sends chain on after it
  (`a at: (i) length = 2`), `+` ends a keyword send, and a name is an infix relation
  if a `rel-qualify` anywhere in the program declares it (`it smaller Surface`; the
  program is read twice). `for some X` (ours) is `for any X`; over a class it means the
  class's instances, a rule for evaluation, not parsing.
- `john_run` (`check/john-run.l`): `john-eval.l` runs JOHN programs by searching possible
  worlds level by level, each action's effects all read from the world it starts in (a
  swap). It solves Towers of Hanoi in the fewest moves, 3 for `check/john/hanoi2.john` and
  7 for `hanoi3.john` (both ours, after the memo's Hanoi2 tables), and reports the worlds
  it looked at. Qualifications take the first clause whose guard holds (`sorted`), a
  class is its instances in `for every`, `for some` and `select`, and a name, property
  or qualification nothing defines is an error. An `action-optimization` narrows an
  action's arguments and a `goal-optimization` the actions each world tries, so the memo's
  x86 allocator (`check/john/x86-allocator.john`) finds a plan in 6 steps, one a split, and
  its allocation fills every live range slot by slot. Lists count from 1 (`at:`, `to:`,
  `from:`). The puzzle allocator, asked to satisfy its goal, stops at
  `unknown name: live-vars`, the memo's slip for `each live-vars`. Heuristics score a
  world: with `set-opt max-time-ahead H`, every H levels the next move toward the
  best-scoring world is certain and the other branches are dropped, so the maze
  (`check/john/maze.john`, ours) is solved looking at fewer worlds, and a dead end that
  scores better is committed to (the incompleteness RN-2008-003 admits). With
  `set-opt two-player-game [ A, B ]` the opponent makes only its best-scoring replies:
  Nim from 3 is won only if Black blunders, from 4 always. Ours, not the memos':
  `set-opt merge-worlds yes` drops a world whose state (every property of every object)
  was reached before, so Hanoi3 looks at 8 worlds at its last level instead of 1086 and
  a consistent Hanoi4 (`check/john/hanoi4-ours.john`) is solved in 15 moves; a commit
  forgets the states seen on the branches it drops. Time is the chain of worlds:
  `at time t E` reads an earlier world, and a later t gives the values over the possible
  worlds that far ahead (RN-2008-003). Ours, after McCarthy's Elephant: an expression
  may read earlier times (`at time T E`, `for some time T after A up to B do P`) and ask
  which action made a world (`X did reserve`), an action may be an event with no
  effects, and `X do act` runs one action now. So the airline
  (`check/john/airline.john`) keeps no record of reservations: a passenger has one if a
  request made while the flight had room wasn't cancelled since. An expression can't
  read the future. Qualifications are kept per world. `hanoi4.john` as printed is
  inconsistent (`Peg1` supports `B`, which sits on `C`).
  A program can `load "file.l"`, and its objects and values answer the messages that file defines with
  `define-john-builtin`, so an object can ask a grammar (`check/john-message.l`). Reading before the first world is an
  error, and a time window reaching there starts at the first action.
  How a goal is solved is separate from what it means: `goal-strategy Class goal sat if guard.` names a strategy, the
  first whose guard holds, then `set-opt planner`, then the search. A loaded file adds one with `(john-strategy name
  function)`, and an unknown name is an error. Under `sat`, only what the goal can reach has to be encodable.
  Ours: `set Light = lit | dark.` names what a value may be, and `set Evidence = untested | passed(tree) | failed(tree).` gives a
  member named fields: `passed(tree: T)` makes one, it must name every field the set declares, `x tree` reads one, and `x kind` is its
  member's name. Two values are the same by what they hold, and comparing a value with fields to a bare name is an error.
  `a is b` asks whether a is one of a kind, b naming a member, its set, a group holding it or a class, and otherwise whether they're the
  same value; so `its evidence is Good`, after `group Good passed tested proved.`, and a value with fields simply isn't a bare name.
  `qualify C p is E` gives p E's value (the memos have it as `if`, in one use that answers yes or no).
- `call_by_meaning` (`check/meaning.l`): `meaning.l`, call by meaning (Samimi et al., Onward! 2014, TR-2014-003) with a model
  where the paper had Cyc. A model proves nothing, so each answer is held to what John can check: `"…" find-passing: "probe"`
  takes an object whose `spec` the model says means the text only if it passes the probe, a qualification of its class, and
  `"…" adapt: [ [ in, out ], … ]` takes a formula only if `meaning.g` reads it (x, whole numbers, `+ - * /`, parentheses:
  nothing else parses) and `meaning-value.g` maps every example (a formula found before is held to new examples too); `x apply-adapter: "…"` runs it with no model. A refusal goes
  back with its reason, three tries, then a John error that `recover.l`'s `try` catches (holding only the source's literals:
  strings the program made are undone with the world). An adapter is written into the world it was found in, so a failed
  branch takes it with it; builtins read that world from `*john-builtin-world*`. Answers are recorded by prompt, and one
  recorded isn't sent again. `ollama.l` asks a local Ollama's `/api/chat` over `socket.l` (TCP through `subr`, Darwin's and Linux's
  sockaddr; what a peer does is answered, not signalled, so the client needs no handler, and it runs on Linux arm64), reading the reply with `http.g` and `json.g`; it answers nothing for no server, a server that closes early (no SIGPIPE), a status other
  than 200, or a reply with no message. A cloud model sees the prompt: public text only.
- `plan_evidence` (`check/plan-evidence.l`): what `check/law.l` prints, read by `notes/plan/law-report.g` in a command, `law-events.l`, to events of
  evidence, one a law, read back through John: tested and proved hold if they're about this code, refuted, starved, vacuous, inconclusive and a law that
  stopped its run don't. The plan itself replays and plans.
- `irl`: `irl.g` (inheriting `cexpr.g`) and `compile-irl.l` turn `test.irl`
  into a `.k` program that `maru.k` compiles and that prints what it should; a program that defines its own `main`
  (`check/irl-main.irl`, with arguments) keeps it, and one with both its own `main` and top-level statements is an error;
  `?:` with branches of different types (`check/irl-errors.irl`) stops ir2 at
  a type mismatch in the `if` (`check/irl-errors.l` records it in Maru).
- `irl_library` (`check/irl-library.l`): `compile-irl.l --library A.irl B.irl` reads
  several irl files to one program with no `main` (a top-level statement is an error), and
  `export f;` keeps a function visible; make builds the library (`build/irl-lib.dylib`), which
  untyped Maru opens by its path in the tree and calls by address. A library is compiled in
  one process, `./eval2 compile-irl-library.l A.irl B.irl > build/lib.c`: the irl is read to
  forms that stay in memory, then ir-gen-c.k and maru.k compile them; only `cc` runs after. `cast(e, type)` and
  `sizeof(type)` read to maru.k's own forms. A global's constant initialiser (a literal, negated or cast) is C's initialiser at
  its definition, in irl and typed Maru alike; a computed one would need a `main`, so it's an error in a library.
- `kscript` (`check/kscript.l`): `kscript.g` (inheriting `cexpr.g`) reads the 39 KScript listings
  transcribed from TR-2012-001, and `kscript.l` runs streams tick by tick, as the report says: a
  stream recomputes when a stream it depends on fires, a primed name isn't a dependency (so
  `nat <- 0 fby nat' + 1` never updates), and undefined keeps the value and stops the change. `timerE`
  is the only source. Untyped, so it runs on `eval`, not through ir2; `anyE` and `switchColE` still
  read held values, and layout and rendering don't exist yet.
  Methods are defined per kind of receiver (`ks-methods`: a KSWorld object's class, or `Number`, `String`, `Point` …), and
  a send no method answers is an error naming kind and selector; a KSWorld object's send sets or reads a field it already has, but
  never makes one, which would hide a missing method. A field read on any other value (`ev.hand`) is a send with no arguments.
- `ksworld_headless` (`check/ksworld.l`): `./eval ksworld-run.l DOC.pp [TICKS]` loads a KSWorld document (`ksworld-pp.l`), reads
  every stream's code (a setter's is a printout of the value the document already holds) and runs the evaluator tick by
  tick, each stream on its own, then reports what ran, fired and failed, and why. Our fixture `check/ksworld/tiny.pp`
  counts a timer's ticks and names the send nothing answers. With `MARU_DBJR` naming a copy of the dbjr documents laid out
  as tinlizzie.org/dbjr (`make check` fetches one into a fresh `mktemp -d` directory, removed after, unless `MARU_DBJR` is
  already set; third-party, so never in this tree) it runs `KSWorld.ks`:
  520 objects, 346 streams (281 setters), every stream's code read, and nothing it names missing: `KSTextLayout`'s
  `installSelection`, `handleButtonDown` and `handlePointerMotion` are class methods, which documents don't keep, and
  `ksworld-events.l`'s stand in for KSWorld's own (KScript, in `ksworld/KSTextLayout.st`). Named but missing is a failure;
  unset, it says it skipped them.
  `ksworld-render.l`'s `(ksworld-render box gezira width height)` draws a document with whatever Gezira it's given: walking
  the box tree (`backgroundParts`, `contents`, `parts`; a hidden box draws nothing), it asks `(gezira-fill-path gezira matrix
  width height paint floats count)` of each shape's path, as its FloatArray holds it, placed by the matrix composed from every
  transformation above it. The geometry is Gezira's, in Nile. `gezira-library.l`'s Gezira is libgezira and libnile
  (`libgezira.k`, `libnile.k`: a `TransformBeziers`, `ClipBeziers`, `Rasterize`, composite pipeline); Gezira compiled into the
  image would answer the same message, so neither need be a library. Matrices are Gezira's (x' = a x + c y + e); a
  document's `MatrixTransform2x3`, and KScript's `M(...)`, name Squeak's rows, read once into those fields. The check asks
  a recording Gezira: the fixture's one path, matrix and paint, and KSWorld.ks's 7 paths before its text, which is kept as
  `span` records (string, font, fill, size) to be laid out with TrueType glyphs.
  `truetype.l` reads a TrueType font (tables by offset, `cmap` format 4, simple and composite glyphs) to a glyph's
  quadratic Béziers in whole font units, a straight segment as start, start, end and an implied point rounded down, as
  KSWorld wrote its own: each character box KSWorld.ks kept (Times New Roman, plain and bold, a face's style being bits,
  `ksworld-pp.l`'s `define-flags`) is identical to what it reads from this system's Times New Roman, where macOS has it.
  `ksworld-text.l` lays a text box's spans out as KSWorld did (its KSTextLayout's margins, justification, tab stops and
  wrapping; lines ascent plus descent plus 2 apart; a centred line's width adding its first glyph's left bearing), and
  `ksworld-render.l` draws each character's outline after the box's shape: each of KSWorld.ks's five text boxes puts the
  character KSWorld left laid out (its last line's first) where KSWorld did, and the document draws 937 paths (the three
  carets it kept showing among them).
  Fonts are found as a browser finds them: a family falls through to its alternatives, its generic family (`serif`,
  `sans-serif`) and a last resort (DejaVu Sans, which `fetch-dbjr` fetches), and a character a font lacks to the next
  font with a glyph for it. `truetype.l` reads a TrueType Collection's faces by full name, so Palatino Linotype is macOS's
  `Palatino.ttc`, with its own metrics: of the front page's text boxes, those in Times New Roman and DejaVu Sans are where
  KSWorld put them, 411's tab stops among them (measured from the box's edge, the pen starting at the line's first
  glyph's left bearing). An emphasis other than bold and italic is an error.
- `png_asan` (`check/png-asan.irl`): `png.irl` built with a harness (an irl program with its own `main`) under
  AddressSanitizer and UndefinedBehaviorSanitizer; every PNG fixture, good and hostile, is read into a buffer of exactly
  its size, so any read past the input fails the case.
- `png` (`check/png.l`): `png.l`'s `(png-load path)` reads an 8-bit RGBA or RGB PNG, not interlaced, to a `<png>`: width,
  height and width x height ARGB words in C memory (alpha on top, not premultiplied), as a Gezira image holds them. The
  decoder is `png.irl`, typed and lowered through ir2 into `build/png.dylib`: every chunk's CRC-32 is checked, the data
  inflated (stored, fixed and dynamic Huffman blocks) and checked against its Adler-32, and every row filter undone;
  ancillary chunks are skipped and an unknown critical one refused (PNG 5.4), and anything else is an error naming it. Our
  fixtures (`check/png/`) are held to pixels worked out separately through zlib: every block kind and filter, RGB, and
  `chunks.png`'s chunks with no pixels (gAMA, cHRM, sRGB, pHYs, tEXt, zTXt, iTXt, a suggested PLTE, a private one, tIME and
  tEXt after the data) around data split over three IDATs. Hostile input is refused for its own reason, never read past
  (`check/png/bad/`, one file per rule): a file that ends early or a chunk longer than the file, IHDR missing, not first or
  not 13 bytes, a zero or too large width or height (at most 2^24 each and 2^28 pixels), a compression or filter method
  other than 0, no IEND, a zlib preset dictionary or missing trailer, a stored block whose NLEN isn't LEN's complement or
  whose LEN runs past the data, a length or distance code no stream may use, and an over-subscribed Huffman code.
  `png-encode` writes an image back (any filter per row, stored
  or fixed Huffman blocks with runs, IDATs of any size, tEXt around them), and 120 random images round-trip pixel for
  pixel. With `MARU_DBJR` the front page's image (730 x 980, which `fetch-dbjr` fetches with every image a document
  names) at five points and in its byte sum; it decodes in well under a second.
- `gezira_image_fill` (`check/gezira-image-fill.l`): an image as a Gezira paint, `(image pixels width height matrix filter)`,
  as KSWorld's `GeziraFillImage` paints one (its `pipelineOn:for:`, in Frank's GeziraBindings): the canvas's inverse
  matrix, then `ReadFromImage_ARGB32` (typed Maru beside the writer, `gezira-image.k`), unfiltered for a whole-pixel
  translation, else mipmapped (GeziraBindings' `downsample`, each level cached on the form) while the minification passes
  2, 4 … and filtered bilinearly. A translation copies a small image exactly, a uniform image stays uniform downsampled and
  filtered, and premultiplying rounds as the writer does, on 1 and 4 workers. `ksworld-render.l` reads a Form's PNG from
  beside its document (`ksworld-pp.l` keeps the path) and premultiplies it once. With `MARU_DBJR` the front page's
  photograph, rendered with the rest of the page, matches what its pipeline gives worked out from the PNG's pixels (the
  downsampled texel, then the bilinear filter, then the writer's rounding) at 98 of 100 grid points, none off by more than 1.
- `ksworld_mouse` (`check/ksworld-mouse.l`): `ksworld-events.l`'s `(ksworld-pointer session kind point)` delivers a press,
  motion or release at a document point to KSWorld.ks's running streams (`ksworld-session` continues what `ksworld-run`
  left), headless: a press goes to the topmost box under it with a `buttonDown` (through the inverse of the matrices the
  renderer composes), a motion or release to the box the hand holds if that stream is awake, then one tick runs. The
  handlers are ours, written before KSWorld's own turned up in `ksworld/KSTextLayout.st`: a press puts the caret at the nearest gap, wakes `buttonUp` and `pointerMotion` and has the hand hold
  the box; a drag selects from the press; a release, by the document's own stream, puts them back to sleep. A selection is
  an Interval of gaps, `(from to: to + 1)`, as every one the documents kept is one wide, and the redraw asks the Gezira for
  it in the layout's `selectionColor` under the text.
- `ksworld_window` (`check/ksworld-window.l`): `ksworld-window.l` puts a running document in an SDL3 window through `sdl3.l`
  (SDL3 for untyped Maru, through `subr`, with `sdl3.osdefs.k`'s constants and offsets; the library is the first of
  `*sdl3-libraries*` that opens). Each `(ksworld-window-step win)` reads SDL's events, hands button 1's presses and
  releases and every motion to `ksworld-pointer` (window points are document points), and draws a frame when one reached a
  box, or first: it clears the Gezira, renders the document and shows `(gezira-image gezira)`, width x height ARGB pixels a
  painting Gezira answers. Escape or a quit stops it. On the dummy driver the check queues a press, a drag and a release as
  the window system would, and each reaches KSWorld.ks's title and draws a frame; its Gezira counts paths and paints
  nothing, so pixels wait on a Gezira that paints (GeziraImage). Where `pkg-config` finds no SDL3 it prints `SKIP`.
- `ksworld_clock` (`check/ksworld-clock.l`): a document in a window runs as it runs on its own. After its start-up evaluation
  (time 0), logical time is the window's clock in milliseconds from when it started (`SDL_GetTicks`, or any clock put in
  its `clock` field), each step evaluates what is due then, an event happens no earlier than the clock says, and a step in
  which something fired draws a frame. `timerE(n)` fires when time passes a multiple of n since the evaluator's last
  evaluation, once however many it passed, n whole or fractional (headless, with whole ticks, that's every nth tick, as
  before); time evaluated again passes nothing. In a window an event takes 1/1024 of a millisecond, so events keep their
  order without running ahead of the clock (headless they take a whole tick). A stream that fails is reported once and
  the rest run on. Our fixture `check/ksworld/tiny.pp` in a window on the dummy driver: with the clock held still nothing
  runs or draws; seven milliseconds on, its timer fires once and one frame is drawn; fifty presses with the clock held
  neither fire it nor leave the millisecond, nor do 2100 more (each event moves 1/1024 of the way to the next
  millisecond); its failing stream is reported once. An evaluator's time only moves forward: evaluating a time again, or an
  earlier one, is refused. `check/ksworld/timer.pp`'s timerE(1000)
  and timerE(2.5), read at times that skip their multiples, fire as time passes them. `ksworld-show.l` runs only the
  start-up evaluation before the window, then the clock.
- `sat_john` (`check/sat-john.l`): `cnf.l`'s gates (and, or, xor, iff, mux, true, exactly
  one) agree with their truth tables through the solver. Under `set-opt planner sat`,
  `satisfy` goes to `john-sat.l`, which infers a sort (number, name, or list of a sort) for
  every property from the world's values and each effect, refusing a property with two
  (`E_SORT`), a number outside `sat-width` bits (`E_BOUND`), and what the encoding doesn't
  cover (`E_SAT_UNSUPPORTED`: two-player-game, max-time-ahead, at time, a time quantifier,
  did). The encoding is a bounded model over states 0 … k: one action a step (exactly one),
  rules and optimizations as constraints, effects writing t + 1 and the rest carried over,
  the goal at k, each length on a fresh solver with every refutation's proof checked. Hanoi2,
  3 and the consistent Hanoi4 come out at 3, 7 and 15, the trap and the maze at the search's
  lengths, every plan replayed by the evaluator (`E_ENCODING` otherwise); a goal no plan
  reaches is `unsatisfiable within 16 steps (width 16, lists 16, unroll 16)`, and
  `sat-conflicts 1` leaves Hanoi3 `unknown`. A number that changes is `sat-width` bits of two's
  complement (`cnf.l`'s add, sub, mul, div, lt, eq, checked on every pair of 4-bit numbers), and
  a result that doesn't fit, or a division by zero, makes its step impossible: Nim from 3 and 4
  agree with the search, and a counter past 32767 is unsatisfiable in 16 bits but not in 17.
  A list that changes is a length (one of a few values) and its elements' terms; its
  builtins, `+` and `-`, quantifiers, `in` and `select` are encoded case by case, an index
  out of range or a list past `sat-list-length` making its step impossible. The x86
  allocator comes out at 6 and passes the slot-by-slot check (`check/john-allocation.l`,
  shared with `john_run`); list expressions over symbolic inputs equal the evaluator's on
  generated lists. An answer of unsatisfiable means no plan avoids an evaluator error, so a message the encoding can't answer never
  reads as one: `kind` and a loaded file's messages are asked of the evaluator on a constant (reading only what no action writes), on
  a changing value they are `E_SAT_UNSUPPORTED` naming the message, and a message nothing defines is the search's error.
  What `satisfy ... using` leaves out can't happen, so it needn't be encodable, and a value with fields no action in use writes is a
  constant; one that changes is refused.
  The formula's clauses live in a C store (`dimacs.irl`), out of Maru's
  heap, which the solver, the checker's DIMACS text and the model check all read.
  The search planner is unchanged otherwise.
- `sat_proof` (`check/sat-proof.l`): every UNSAT answer from `sat-decide` carries a DRAT
  proof (`sat.irl` writes each learned clause, and `0` at the refutation), which
  `drat-check.irl` verifies forward (a lemma RUP, or else RAT on its first literal, propagating
  by two watched literals) against the formula it reads itself through `dimacs.irl`'s grammars, else `E_PROOF`. It rejects a
  proof without its final `0`, an empty one, a lemma that doesn't follow (naming its line), and
  one that deletes what it needs. Formula and proof stay in memory; a check that fails writes
  both to a `maru-sat` directory in the check's own (`/tmp/maru-sat` outside a check) and names them in its error. `make clean` removes `/tmp/maru-check`
  and `/tmp/maru-sat`.
- `sat_core` (`check/sat-core.l`): `sat.irl`, a CDCL solver behind IPASIR (`sat_init`,
  `sat_add`, `sat_assume`, `sat_solve` answering 10, 20 or 0, `sat_val`, `sat_failed`), in
  `build/sat.dylib`. `sat.l`'s `sat-decide` solves a formula on a fresh solver and checks
  the model against every clause as Maru wrote it (`sat_store_holds`, over the formula's
  store, not the solver's clauses; `E_MODEL`). It answers satisfiable and unsatisfiable
  formulas, clauses added between solves, and assumptions with the ones a refutation used.
- `sat_dimacs` (`check/sat-dimacs.l`): `dimacs.irl`'s grammar block `<cnf>`, built into
  `build/sat.dylib` (opened by `sat.l`), reads DIMACS CNF and names the first bad line: a
  literal above V or twice in a clause, too few or too many clauses, no header, a count over
  2^30. `sat-write-dimacs` round-trips through `dimacs_load`. `sat-gen.l`'s formulas, their
  answers known by construction: pigeonhole 2..7 UNSAT with checked proofs, n-queens 1..8
  (UNSAT for 2 and 3, else a placement checked in Maru), planted 3-SAT at four ratios.
- `irl_grammar` (`check/irl-grammar.l`): a tpeg grammar calls another grammar's rule as `p-r`
  (compiled by `compile-tpeg.l` to a parser of `<p>` on the same input). In irl,
  `grammar { <G> : <parent> (fields) rules }` is tpeg's own syntax, read through that foreign
  call. Its matching is tpeg's own: `irl-grammar.l` lowers `compile-tpeg.l`'s `value-pe`
  output to typed Maru over `text-parser.k`, a struct `G` (string, limit, position, result,
  span, the fields) and one function per rule, `G_rule(self)`, actions maru.k forms copied in
  unchanged. A child's inherited rules call its overrides; a left-recursive rule, lists and
  strings are errors naming the rule.
- `tree_selectors`, `tree_source`, `tree_lists`, `tree_args`, `tree_args_unread`, `tree_apply`, `tree_memo`,
  `tree_foreign`, `tree_literals`, `tree_calc`, `tree_interleave`, `tree_text_refuses`, `tree_parse_complete`
  (`check/tpeg-*`): stage 1 of `docs/rfc/draft-ndn-maru-typed-tree-matching-00.md`, on every evaluator. A grammar whose
  parent is `<source-parser>` matches any source through the input selectors (`input.l`, `source-parser.l`): lists,
  a user's type, bytes (`input-binary.l`; not on `eval2`, which says it skipped them). A pattern enters a list, a rule's
  arguments are cells on its input and leaving one unread is an error, memos live on the stream's cells, and a foreign
  rule reads through proxy cells with fresh memos. Grammars compile in process (`tpeg-load`), and `tpeg-repl.l`
  interleaves code and grammar blocks on one input. A text grammar refuses what needs a source, by name.
- `law_engine` (`check/rules-test.l`): `rules.l`'s one rule set generates, checks and
  enumerates alike; a recursive rule never applies at size 0; unification has an occurs
  check; the `in`, `number` and `=` builtins work as specified; schemas, relation
  parameters and facts read from a function expand to first-order rules, and an unknown
  relation is rejected.
- `law_cexpr` (`check/law-compile-test.l`, `check/laws/cexpr.law`): `law.g` (inheriting
  `cexpr.g`) and `law-compile.l` read the RFC's example law file to rule, let, set and
  law items. A template's holes fill by text with no grouping added (`{x} * c` with
  `a + b` parses to `(+ a (* b c))`), and `{{` is a literal brace. An error fails naming
  its line, and an unbound hole is `E_TEMPLATE_PARSE`. `cexpr.law` holds `?:` to the
  right, `-` to the left and a comment to a blank, over `cexpr.primary` sentences
  generated from `cexpr.g`'s records, at least 80% accepted (a sentence counts when the
  parser stops at its end with `)` after it). The false `{a}-({b}-{c})`
  (`check/laws/fixtures/minus-right.law`) is refuted for seed 42.
- `law_rules` (`check/law.l`, `check/laws/fixtures/`): the runner prints one line per
  law, `law NAME:`, then `TESTED n`, `PROVED n`, `REFUTED x=v ... seed=s` (shrunk;
  the seed reproduces it), `STARVED k of n`, `VACUOUS` or `INCONCLUSIVE status=s input=...`
  (a reference crashed). A file with no `under test:` line is `E_NO_UNDER_TEST`, a goal
  domain must bind its last argument (`E_BINDING`), and a grammar domain must name a
  registered language (`E_GRAMMAR`) and can't be exhausted (`E_EXHAUST`).
  `law NAME: mutants of R by exhaustion size n. L, ...` judges each mutant of the rules
  R reaches at the least size its rule appears: `PROVED n` if each fails a named law,
  else `REFUTED k of n survive` (`fixtures/adequacy.law`). `let numerals = [1, 2]`
  replaces `number`'s numerals (`fixtures/numerals.law`). The mutant focus follows where a law
  uses the relation (`reach.law`), and a reference's answers are kept by name and text
  (`refs.law`). `.law` files count toward `lines`.
- `law_nile` (`check/laws/nile.law`, `check/laws/nile-reference.l`): rules for
  well-typed Nile expressions, with operator facts read from `nile/compilers/prelude.nl`,
  are sound (Nile's own resolver and type checker, forked per question, accept what they
  generate), checked by themselves, all used, and agree with Nile on expressions that
  ignore types. Nile's resolver crash on `ϫ():ρ` / `forall_`
  (`fixtures/nile-crash.law`) is `INCONCLUSIVE`. `nile-adequacy.law`: every one of the
  69 mutants of the expr rules fails sound or agree.
- `ir_retired`: `ir.k` and irgol are gone, and `irl.g` and `compile-irl.l`
  have no `ir-` form.
- `eval2_subr` (`check/eval2-subr.l`): every evaluator calls C through `subr`,
  by name or address, with typed results (`"dd>d"`; `>s` copies a `char *` into a string, `NULL` being nil), variadic
  calls and raw byte access.
- `data_length` (`check/data-length.l`): on `eval` and `eval3`, `(data-length d)` is the length `(data n)` was made with,
  kept in the object's header, not the collector's block size (often larger), and kept across a saved image (`gc_image`).
  Reads and writes past it are refused, and so are a negative index (which would reach the header) and an index whose
  byte offset overflows; the bounds check compares without a sum that could wrap, and a refusal's condition names it
  (`byte-at: index (n) out of range`). Every object's header holds the size it was made with, so a Data `allocate-atomic`
  made answers its own length, not a freed block's.
- `byte_bounds` (`check/byte-bounds.l`): on all three evaluators, raw access to any object (a pair, where `eval2` has no
  Data) refuses an index before its start or one whose byte offset wraps.
- `exit_status` (`check/exit-status.k`): a typed program's exit status is what its `main` answers, through `ir-gen-c.k`'s
  C `main` (it answered 0 whatever `main` returned, so checks reading a typed program's status were weaker than they read).
- `asm_interface` (`check/asm-interface.l`): the one encoder interface
  (`asm`, `asm-forms`, `asm-decode`, refusals) answers the same way for arm64
  and x64, under both evaluators.
- `asm_rows_arm64`, `asm_rows_x64`, `asm_rows_x86` (`check/asm-rows.l`): every
  row of `arm64.spec` or `x86.spec`, sampled in every operand position (and
  every NEON arrangement), assembles to the bytes clang gives and decodes
  back to them; unencodable operands are refused.
- `asm_coverage` (`check/asm-coverage.l`): every form in `asm-coverage.spec`
  has a row, and every operation `ir2.k` declares, on every type, is named
  there for each instruction set.
- `asm_patch` (`check/asm-patch.l`): a placeholder patched later gives the
  same row's bytes for the final value; one past the field's range is refused.
- `jit_run` (`check/jit-run.l`): code assembled into a code region runs
  in-process through the C ABI on each evaluator the host has (arm64, and
  x86-64 under Rosetta through `bin/x86_64/eval2`).
- `exe` (`check/exe.l`): `exe.l` writes executables with no compiler, linker or codesign, for `linux-i386`, `linux-x64`,
  `linux-arm64`, `macos-arm64` and `macos-x64`, from an assembly buffer, as `code-region.l` runs one in-process. ELF is
  static; Mach-O keeps dyld and signs itself ad hoc (`sha256.l`, FIPS 180-4's vectors). On Linux a program makes system calls; on
  macOS the stable interface is `libSystem`, so a program imports `write` and `exit` through slots in `__DATA` that dyld fills. Each program prints a message
  and exits 42, the bytes are the same from all three evaluators, and each runs where it can: natively, under Rosetta,
  or in Colima's Linux VM, and a target with nowhere to run says so. One piece of arm64 code returns 42 from a file and
  through the JIT.
- `catch` (`check/catch.l`): `catch.l`'s `catch`, `throw` and `unwind-protect`, in native stubs with no C. `abi.spec` says what each
  calling convention keeps where, `stub.l` writes a stub once as intents, `stub-arm64.g` and `stub-x64.g` lower them by tree
  matching to encoder forms, and the result is a primitive like the evaluator's own (`allocate-atomic`, its function the stub).
  On every evaluator and instruction set the host has: through deep frames and C, with the collector's roots restored.
- `recover` (`check/recover.l`): `recover.l`. `error` and C's `fatal` signal a condition a handler sees where it happened, and
  `try` runs its body in a world, an undo log (its logic `undo.irl`, compiled to `undo-irl.c`; `undo.c` is what it needs of each evaluator's objects): if it fails, every write through a primitive is undone (Warth's
  Worlds, 3.1). Reads cost nothing and C sees current values; raw memory, the evaluators' tables, files and foreign state
  aren't covered. A definition is undone like a write, though on `eval` a name new in the world stays bound. A value leaving a failed
  world keeps what it was made with. With no handler, errors end the program as before. `gc_image` checks a loaded image's heap.
- `undo_irl`: `undo-irl.c`, which every evaluator includes, is what `undo.irl` compiles to; `make undo-irl` rewrites it.
- `gc_laws` (`check/laws/gc.law`): over graphs rules generate, in a forked child per question, on every evaluator: what's
  reachable survives and what isn't is freed, sharing and cycles hold, marking can't overflow the stack, the heap's books balance
  (`GC_check_heap`), worlds and throws keep all that, and `(set-heap-limit bytes)` reached is an error that can be recovered from,
  repeatedly, without the reserve creeping, and running out again with no room made is a final exit. Free blocks are in lists by
  size, so a small allocation walks nothing; blocks over a thousand bytes share one list.
- `gc_model` (`check/laws/gc-model.law`, `gc-model-paced.law`): generated programs (writes to a few slots, nested worlds that
  end, fail or are thrown out of, collections) run on real objects and on a pure model, and must agree in everything observable,
  with an empty log and balanced heap after; allocation sequences of many sizes; collections every allocation and every seventh.
  A world keeps one record per slot however often it writes it, and a commit hands its parent only what the parent lacks, so a
  loop in a `try` doesn't grow the log, though each call that sets a fresh local still adds a record. Generators are aimed by
  deliberate bugs: reintroduce one and count the seeds that catch it.
  A law file's limit is CPU time (300 s, `RLIMIT_CPU`, with an alarm at four times as long for a run that blocks), and so
  is each question's (`law.l`'s `law-limit`, 60 s, 10 s for Nile's), so cases or agents running beside them can't fail
  them by contention; each run keeps its own output, and a failure prints its
  last lines. Alone, each `gc_model` file takes 45 to 83 s; nearly all of it is the collector marking the heap the
  forked question inherits from the law runner.
- `cross_eval`: on arm64 macOS with Rosetta, `bin/x86_64/eval` and `eval2`
  are built.
- `boot2_strings` (`check/boot2-strings.l`): `boot2.l`'s Maru definitions of
  `string-copy`, `string-compare`, `long->string` and `string->long` behave
  as `eval`'s C primitives do (the cases pass under both evaluators).
- `nile_compile` (`check/check.l`): `nile/compilers/maru/nile-to-maru-compiler.sh`
  runs Nile's compiler on `eval2` and `boot2.l`, and writes the same Maru
  for `nile/examples/text-layout.nl` as `eval` and `boot.l` do.
- `nile_text_layout` (`check/check.l`): `text-layout.nl`, compiled by `nile-to-maru-compiler.sh` as module `text_layout`,
  runs through the Maru runtime (`nile/runtimes/maru/test/text-layout.k`) with 1 and 8 workers and lays four glyphs out
  as (0,0) (3,0) (6,0) (0,1).
- `gezira_image` (`check/check.l`): `gezira/nile/gezira.nl`, Gezira in the 2016 Nile dialect, compiled by Nile's Maru back end
  and built with the runtime, with `nile/runtimes/maru/gezira-image.k` (the ARGB32 composite) renders a 40 by 30 rectangle at
  (10.5, 20) through TransformBeziers, ClipBeziers, Rasterize and ApplyTexturer: full pixels red, edge columns half covered, the
  rest white, on 1 and 4 workers (`nile/runtimes/maru/test/gezira-image.k`).
- `gezira_maru` (`check/check.l`, `check/gezira-maru.l`): the Gezira library `build/gezira.dylib` (make builds it from
  `gezira/nile/gezira.nl` and the runtime) through `gezira-maru.l`'s `<gezira-maru>` selectors renders the `gezira_image`
  rectangle with a matrix, on 1 and 4 workers. `check/gezira-scene.l` draws `check/ksworld/scene.pp` the same way; it is
  verified in a scratch copy with main's KSWorld stack and is not registered on this branch.
- `run_limit`: `run` ends a command still running at its limit (120 s; 1 s in
  the check) by an alarm set in the child, through `subr` (no perl or coreutils).
- `lines`: the source line count equals the sum of `check/lines`. Any change
  in line count needs an entry there with its delta, and an entry that adds
  lines must say why. Derived files are marked `derived` in `.gitattributes`
  and not counted, nor is `notes/` (reference copies) or anything marked
  `unused` in the `nile/` and `gezira/` submodules; the C evaluator counts
  until `emit.l` generates it. Tests count. The budget is 20k lines, the
  STEPS target ("a modest 400-page book" one programmer can hold); it is
  soft, so the check reports the total but doesn't fail over it. Prefer a DSL or grammar (as `gen-asm-x86.k` generates
  the x86 assembler) over writing code out, tests included.

## The evidence plan

`notes/plan/tree-matching.john` says what stage 1 builds, how the pieces relate and what would show each works.
`./eval notes/plan/observe.l [full]` asks its checks (cases, measures, and every tree grammar compiled live on each
evaluator, reading its language) and prints the answers as events, each an `Evidence` value naming the code it's about;
`notes/plan/record [full]` appends them to `evidence.john`; `./eval notes/plan/next.l` shows what's done and the next step,
running nothing. A law's check answers its verdict, with what backs it, and only tested or proved counts. Planning says `using build`, so
under `sat` the evidence is constant. `notes/plan/LOOP.md` holds the loop's rules and notes.
`MARU_PLAN=NAME` picks another plan, `notes/plan/NAME.john` with its own `NAME-evidence.john`: `ksworld` is the headless
KSWorld work, whose first capability is that the dbjr documents can be fetched.

## Known not to work (verified on arm64 macOS)

- No 32-bit x86 code links or runs on macOS (dropped in 10.15; Rosetta is
  x86_64-only). That rules out `make test` (`emit.l` emits IA32 only; emitting
  and `cc -arch i386 -c` work, linking fails), `eval32` and its targets, and
  the demos that run i386 code in-process: `test-call.k`, `test-elf.l`,
  `test-mach-o.l`, `assembler.k`. On arm64 they first fail at
  `mprotect: Permission denied` (eval.c:2497).
- Neither evaluator eliminates tail calls, and a stack overflow is an unguarded
  segfault, the one failure `recover.l` can't yet catch. On the default 8 MB stack `eval` overflows between 2,000 and 4,000 nested
  tail calls, and `eval2` between 4,000 and 7,000.
- `eval2.c` was hand-edited upstream; nothing here regenerates it.
- Cross-compiling: ir2 sizes follow the host's `osdefs.k`. Since that change
  (to fix the C backend on 64-bit hosts), `ir-gen-x86.k` emits 64-bit layouts
  on a 64-bit host, which is wrong for its 32-bit target.
- `test-peg.l` loops forever on every platform: `peg.l`'s `definitions` rule
  matches empty input, so the parser never advances.
- `make test-emit` runs `emit.l` as a shell script; use
  `./eval emit.l test-emit.l`.
- `net/*.osdefs` are Linux-only (`linux/tcp.h`, `linux/if_tun.h`).
- `maruby.l` is an early start on Ruby: `1 < 2` yields `t`; there's no
  `nil`, `true`, `false`, strings or arrays; variables can't be read in
  expressions; the `block` rule is unused, so no blocks.
- Gezira/GL demos need `libnile` and `libglfw` built from `../nile`.
- The SDL2 example (`./eval3 libsdl2.k`, a window to draw lines in) needs
  SDL2 and SDL2_gfx; without SDL2_gfx it stops at `could not load: libSDL2_gfx`.

## Roadmap

1. An `ir-gen-arm64.k` backend beside `ir-gen-c.k` and `ir-gen-x86.k`.
   Its output goes through `exe.l` to a file or `code-region.l` to the JIT. x86-64 needs the same: `emit.l` and
   `ir-gen-x86.k` emit 32-bit code, so hand-assembled programs are the only native x86-64 binaries so far.
2. Carry over refactor work from `refactor-main` case by case, with tests.
   - First: the UTF-8 grammar, `grammars/unicode/utf8.g` on `refactor-main`.
     It was never run. Its actions read the lead byte as hex text, and it
     accepts overlong forms, surrogates and values above U+10FFFF. Restore it
     with RFC 3629's valid ranges and U+FFFD for invalid input, and add a check.
3. Promote the grammars in `notes/sources/grammars/` (transcribed from the
   STEPS reports and papers) into the tree as working grammars, each with a
   check and a `check/lines` entry. TCP first: `net/tcp.k`'s packet handling
   as the 2007/2008 reports' `svc`/`syn`/`req`/`ack` rules.
4. Bare metal: Maru as a bootable live image. The qemu raw-boot
   environments (i386, x86-64 long mode, A64 `virt`: boot, console, memory
   map, exit) are the first step, specified after the encoders
   (RFC 0001, `docs/rfc/0001-table-assemblers.md`) as part C of the 2026-10-14
   assembler design.
5. Nile on Maru: a Nile runtime written in typed Maru (new kernel interface,
   POSIX mutexes, arm64 and x86-64), then Gezira, then its demos in an SDL3
   window on macOS and Linux.
   Nile and Gezira come in as submodules of forks, and count toward the 20k.
   Spec: `docs/rfc/draft-ndn-nile-runtime-in-maru-02.md`.
   - Array types in `maru.k`/`ir2`, replacing the runtime's `long` field runs.
   - Blocks sized to a stream's element size, so kernels over large tensors
     can run (one 512-byte block size caps an element at about 118 floats).
6. Checks without make or a shell, for the bare-metal image. `check/check.l`
   compiles a stale grammar in-process with `compile-tpeg.l` (each case naming the
   derived files it needs), and `lines` counts the tree in Maru instead of through
   `git ls-files | grep | wc`. Today the cases reach the shell through `run`
   (`system`), and only `make` builds what they need.
