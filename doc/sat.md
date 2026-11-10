# SAT solving

The CDCL solver in irl, DIMACS, DRAT proofs, and JOHN's SAT planner.

## Checks

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
- `sat_proof` (`check/sat-proof.l`): every UNSAT answer from `sat-decide` carries a DRAT
  proof (`sat.irl` writes each learned clause, and `0` at the refutation), which
  `drat-check.irl` verifies forward (a lemma RUP, or else RAT on its first literal, propagating
  by two watched literals) against the formula it reads itself through `dimacs.irl`'s grammars, else `E_PROOF`. It rejects a
  proof without its final `0`, an empty one, a lemma that doesn't follow (naming its line), and
  one that deletes what it needs. Formula and proof stay in memory; a check that fails writes
  both to a `maru-sat` directory in the check's own (`/tmp/maru-sat` outside a check) and names them in its error. `make clean` removes `/tmp/maru-check`
  and `/tmp/maru-sat`.
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
