---
title: "The acceptance test for 'emit.l generates the evaluator' is byte-identical self-regeneration from the C seed"
scope: personal
status: live
created: 2026-10-14
last_reviewed: 2026-10-14
falsifier: "Output that legitimately varies between builds (addresses, hash order, timestamps) makes the fixpoint unreachable without masking, or a build passes the fixpoint while the evaluator is wrong on behaviour the check suite covers"
links: [self-hosting-is-shown-only-by-byte-identical-regeneration]
schema_version: 1
---

# Why I hold this

(Reasoning, in your own voice.)

# Revision log
## 2026-10-14 — created
Maru page 'The process'; COLA white paper section 6.1 phase 2
