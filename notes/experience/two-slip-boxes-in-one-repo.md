---
title: "This repo has two slip-boxes; slipbox sees only notes/"
created: 2026-10-23
---

# This repo has two slip-boxes; slipbox sees only notes/

While extracting zettels on the COLA object model, a research agent cited
`docs/superpowers/notes/zettel/` (8 zettels on ir2 and the environment stack: type names per layer,
unscaled pointer arithmetic, typed ports). `slipbox` walks up to `notes/zettel/` (20 zettels) and
never sees the other box, so `check`, `show` and hub surveys miss those notes, and links between the
boxes can't be made with `slipbox link`.

What I did: filed new zettels in `notes/` and left the other box alone. Before the next extraction,
ask the user whether to merge `docs/superpowers/notes/` into `notes/` (move files, then
`slipbox check --strict`), so one network holds both clusters.
