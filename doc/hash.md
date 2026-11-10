# Hash tables

`hash.l`'s tables by identity or `equal`, and weak-key tables over the collector's ephemerons.

## Checks

- `hash_table` (`check/laws/hash.law`, `check/laws/hash.l`): `hash.l`, a hash table in Maru on every
  evaluator, keyed by identity (Smalltalk's `==`: a number by its value and kind, anything else by its address, as `=` compares
  strings by their text) or by Maru's `equal` (2 and 2.0 alike), kept in the order keys were first put. A number hashes by its
  double (a long past 2^53 is equal to the double it rounds to), and a bucket index wraps, never negates (the least long's
  negation is itself). Generated programs of puts, removes and gets, over numbers (negative, past 2^53, halves, the least long),
  strings, symbols, nested and deep pairs, nil and keys kept as one object (what each means, `make_key`, and what a program
  does, `run_program`, written in the law file), agree with an association list searched with an
  equality of its own, at every get and in the count, keys and values after; every pair of those numbers is found exactly when
  equal; sizes around each doubling hold, compacting at three quarters removed; and tables saved in an image (`check/hash-image-
  save.l`, where loading moves every object) answer as before, keep their order and grow, since each notes where an anchor of its
  own lived and rehashes once it has moved. Planted bugs (an entry not emptied on removal, 2.0 hashed apart from 2, a table that
  never rehashes) are each caught. NaN is no key: `=` doesn't find it equal to itself. JOHN's seen states (`merge-worlds`),
  `rules.l`'s seen solutions and `check/law.l`'s cache of reference answers are its tables, by `equal`.
- `weak_table` (`check/weak.l`, `check/laws/weak.law`): `hash.l`'s `(weak-identity-hash-table)`, on every evaluator, holds its keys
  weakly. An entry is an ephemeron (Hayes, 1997): a pair with `gc.c`'s weak bit (set by `GC_weaken`, through `subr`), whose first
  word is its key and whose other words the collector marks only once something else has marked the key, round after round until
  no more keys come alive; an entry whose key never is has every word cleared before the sweep, and the table drops it the next
  time it's used (`GC_collection_count` says when). So an entry goes with its key, a value holding its own key doesn't keep it,
  and a key held only by a live entry's value lives, in any order (a chain of thirty, put so one round can't settle it). A
  number or nil is no weak key. Generated graphs of entries and roots, put and collected, leave exactly the entries the law
  file's own model of reachability says; leaving out the rounds, or the weak bit, is refuted. The weak bit is kept in a saved
  image (`hash_table`'s image holds a weak table).
