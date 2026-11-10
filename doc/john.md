# JOHN

Samimi's planning language: parsing, the possible-worlds evaluator, sessions and call by meaning.

## Checks

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
  Ours: `total S by E` is the sum of E over S's members (a class's instances, a `select`, a list), each read as `which`, as
  `select` reads them, and 0 over none; a member whose E isn't a number is an error naming it. A heuristic weighs a
  quantity, and without a sum a plan could only count (`doc/rfc/draft-ndn-maru-john-development-00.md`).
- `john_session` (`check/john-session.l`, `doc/rfc/draft-ndn-maru-john-session-00.md`): JOHN runs as a session, RN-2008-003's
  model (§15): `john-begin` starts one (an empty knowledge base, world 0), `john-enter` enters one statement and answers its
  lines, and `john-run` is a session fed a program. Declarations (and `make`'s facts) never move time; only `do` and a
  satisfied goal do, so world 0 keeps what was declared before the first step, and `time.` answers the current time. At
  the prompt, `./eval john-repl.l [FILE...]` (files entered first, read twice; then standard input, a statement ending at a
  line ending in `.` or `?`, a relation declared before it's used), a declaration answers `ok.`, a step its mutations
  (`time T: STEP`, then `  OBJECT PROPERTY = VALUE` per write, ours: the memos don't show them), a satisfied goal those of
  each new step after its plan, and a failed statement its error, undone by `recover.l`'s `try`. `all` answers a set,
  `{ A1, A2 }`, and `one-from` its one element (§14). The transcripts `check/john/*.session` (§13's `opponent`, §14's grid,
  its `row - 1` written `row + 1` to give the memo's answer, and ours) are replayed through the REPL.
  Ours: `choices O G.` answers O's frontier for G (`doc/rfc/draft-ndn-maru-john-development-00.md`): every step
  `john-children` allows from the current world, through G's goal-optimizations, one line each, `STEP  score N`, best
  first, N `john-score` of the world the step leads to, steps of one score in `john-children`'s order; then `choices: K.`
  It neither moves time nor searches: one level of what `satisfy` explores, ranked by the goal's heuristics.
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
