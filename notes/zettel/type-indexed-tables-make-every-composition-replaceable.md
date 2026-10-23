---
title: "Attaching meaning through type-indexed evaluator and applicator tables makes every composition replaceable"
source: "../sources/piumarta-2011-open-extensible-composition-models.md"
created: 2026-10-14
schema_version: 1
links: [ground-as-little-of-the-evaluator-as-possible, maru-moved-dispatch-from-vtables-to-type-indexed-selectors, messaging-is-self-describing-when-lookup-is-a-message, the-cost-of-meaning-by-indirection-is-recovered-by-staging]
---

# Attaching meaning through type-indexed evaluator and applicator tables makes every composition replaceable

An evaluator usually decides what an expression means with predicates written into its code: is it a symbol, a number, a list, a special form? Piumarta replaces those predicates with two tables indexed by type. `evaluators[type]` gives the meaning of an expression of that type; `applicators[type]` gives the meaning of applying a value of that type as an operator. Evaluation becomes "look up the evaluator for this expression's type and apply it", and application becomes "look up the applicator for this operator's type and apply it". The recursion stops at applying a primitive.

Four table entries restore ordinary Lisp. Macros, single-dispatch messages and multimethods are then each just a new type plus an applicator, a few lines apiece. They are indistinguishable from built-in features, because built-in types are made of the same parts as user types.

The design centre of Maru is this table pair, and it is still visible in the 2.4-based tree: `eval.c` and `eval.l` dispatch through `*evaluators*` and `*applicators*`. It is the same move as Smalltalk's method dictionaries, applied to the evaluator itself rather than to user objects.

Source: Piumarta 2011, *Open, extensible composition models* (VPRI TR-2011-002), §3.2 and Figs. 3–7 (primary); maru `eval.c` lines 1294 and 1381, `eval.l` line 908 (verified 2026-10-14).
