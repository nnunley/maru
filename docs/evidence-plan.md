# The evidence plan

`notes/plan/tree-matching.john` says what stage 1 builds, how the pieces relate and what would show each works.
`./eval notes/plan/observe.l [full]` asks its checks (cases, measures, and every tree grammar compiled live on each
evaluator, reading its language) and prints the answers as events, each an `Evidence` value naming the code it's about;
`notes/plan/record [full]` appends them to `evidence.john`; `./eval notes/plan/next.l` shows what's done and the next step,
running nothing. A law's check answers its verdict, with what backs it, and only tested or proved counts. Planning says `using build`, so
under `sat` the evidence is constant. `notes/plan/LOOP.md` holds the loop's rules and notes.
`MARU_PLAN=NAME` picks another plan, `notes/plan/NAME.john` with its own `NAME-evidence.john`: `ksworld` is the headless
KSWorld work, whose first capability is that the dbjr documents can be fetched.
