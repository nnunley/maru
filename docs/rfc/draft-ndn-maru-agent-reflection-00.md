# draft-ndn-maru-agent-reflection-00: Reflection and Tools for a Model Agent Working Inside a Live Maru Image

**Status:** DRAFT
**Corpus:** red (spec-first — evidence is the acceptance criteria)
**Category:** Experimental
**Authors:** Norman Nunley, Jr <nnunley@gmail.com>

## Abstract

This document specifies an agent loop that runs inside a live Maru image. A language model,
reached through Ollama's chat interface, can look the system up, write code, test it and keep
it. The model reaches the image only through one table of tools. That table also yields the
schema that constrains a trusted model's output, and the check applied to every model's output.
Reflection follows Piumarta's COLA design: an index of what's defined, kept in his trie, and
the per-type tables through which Maru evaluates, which a definition can change inside a world.
A tool that asks OpenCyc is included, backed by the OpenCyc 4.0 server for reference and by our
own extract of its knowledge base for bare metal.

## Motivation

Maru is metacircular. `*globals*` is an ordinary `<env>`, and evaluation goes through four
tables indexed by type: `*expanders*`, `*encoders*`, `*evaluators*` and `*applicators*`
(`boot.l:245-248`). A program can read and replace all of them. Piumarta's COLA white paper
(RN-2006-001-a) names this "horizontal mutation": using "the dynamic introspective capabilities
of the basic system to modify its global behaviour from within". His 2006 DLS slides call it
intercession: "full access to the compiler … full access to the runtime", both as first-class
functions. STEPS (TR-2011-004) says Maru's compile-time evaluator gives hosted languages "their
own metalinguistic and introspective facilities".

Nothing in the tree exposes any of this to an agent. The local-first spike
(`spike-local-first`, throwaway) showed a model can plan for JOHN when every answer is checked:
DeepSeek V4.1 Flash, through Ollama, solved Hanoi up to four disks, a maze and the x86 register
allocator, and the checks caught every wrong answer, including a formula the model got wrong by
misreading JOHN's arithmetic. But the spike's model only proposed plans and formulas. It couldn't
look anything up, run code or keep anything. Two things measured on 2026-11-05 shape the rest:
- **Ollama's `format` field was ignored by the cloud model tried.** A JSON schema sent to
  `/api/generate` with `deepseek-v4.1-flash:cloud` came back as markdown, with no error. That is
  one model, once, and not yet `/api/chat`. Whether a local model honours `format` is unmeasured
  here, since the only local model on this machine doesn't generate text. So a constraint is at
  most a help, and every answer still has to be checked.
- **Tool calls do work on cloud models.** Offered a lookup tool, the same model answered with
  `maru_lookup {"name": "*answer*"}`.

This document provides the reflection surface, the tool table, the sandbox, the model transport
and the OpenCyc tool, so that a model can write and test code in a live image, answer questions
about the system and steer JOHN, through one interface.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in BCP 14 (RFC 2119, RFC 8174)
when, and only when, they appear in all capitals, as shown here.

- **image** — one running Maru process, on one evaluator (`eval`, `eval2` or `eval3`).
- **agent loop** — the code in the image that sends a conversation to a model, runs the tool
  calls it answers with, and sends back their results.
- **model** — a language model reached through Ollama's `/api/chat`.
- **trusted model** — a model Ollama runs on this machine, whose output Ollama constrains to a
  schema. Every other model is **untrusted**.
- **tool** — one entry in the tool table: a name, an argument grammar, an effect class and a
  handler.
- **effect class** — what a tool can change: nothing, a child process, the image, or files.
- **reflection index** — a trie from paths of symbols to entries describing what's defined.
- **path** — a list of interned symbols naming one thing in the image, such as
  `(eval globals environment-find)`.
- **meaning table** — one of `*expanders*`, `*encoders*`, `*evaluators*` and `*applicators*`.
- **child** — a process forked from the image, in which a tool's code runs.
- **world** — the undoable scope that `recover.l`'s `try` runs its body in.
- **keep file** — a source file, in a worktree the user names, to which the agent writes what
  is meant to outlast the image.
- **reference server** — the OpenCyc 4.0 server, reached over its text API.
- **KB extract** — `kb5022.cycl`, every assertion of OpenCyc's KB 5022 written as
  `(Mt formula truth direction strength)`.

## Specification

This document defines the reflection index, the meaning trace, the tool table and what it
yields, the sandbox, the agent loop's model transport, and the OpenCyc tool. It does NOT define
a user interface (inspectors are out of scope), how JOHN plans (`john-eval.l` and
draft-ndn-maru-sat-00 own that; the agent only calls them), or the evaluators' environments
themselves (`boot.l`, `boot2.l` and the C evaluators own those).

**One table, three uses.** The tool table is the only way a model reaches the image. The tools
offered to the model, the schema given to a trusted model and the check applied to every model's
output are all derived from it, so the three can't disagree.

**Nothing a model says runs unchecked.** Model text reaches Maru's reader, JOHN's parser or the
reference server only as a tool argument that has passed its tool's grammar, and code runs first
in a child.

**What's kept is reviewed.** The agent changes the image freely, inside worlds. What is meant
to outlast the image goes to keep files, and the user reviews it as a diff. The agent never
commits to version control.

### Data model

```
RECORD Entry:
    path        : List of Symbol       -- (level namespace name ...), its key in the trie
    kind        : EntryKind
    value       : Any                  -- the binding's value, the method, the rule
    source      : String | None        -- the file that defined it, when known
    signature   : List | None          -- parameters, or for a method the types it's on

ENUM EntryKind:
    FUNCTION    -- an <expr> bound in an environment
    FORM        -- a <form> (macro) bound in an environment
    VARIABLE    -- any other binding
    SELECTOR    -- a <selector>; its methods are entries under its path, keyed by type name
    GENERIC     -- a <generic> (multimethod); methods keyed by the sequence of type names
    METHOD      -- one method of a selector or generic
    MEANING     -- one meaning table's entry for one type
    RULE        -- a rule of a loaded grammar
    TOOL        -- a tool of the tool table itself

RECORD Tool:
    name        : Symbol
    arguments   : Grammar               -- what a call's arguments must match
    effect      : Effect
    handler     : Function              -- arguments -> Result
    describe    : String                -- the description offered to the model

ENUM Effect:
    READ        -- reads the image; runs in it directly
    SANDBOX     -- runs code; only ever in a child
    COMMIT      -- changes the image; inside a world, after its tests pass in a child
    KEEP        -- writes a keep file

RECORD Result:
    ok          : Boolean
    value       : Any                   -- encoded for the model as JSON text
    error       : Symbol | None         -- one of the errors below
    output      : String                -- what the code printed, truncated to output-limit

RECORD Exchange:                        -- one model reply, recorded so replay never asks again
    request     : String                -- the request's JSON text, exactly as sent
    reply       : String                -- the reply's JSON text, exactly as received
```

**Path constraints:** every element of a path is an interned symbol, because Piumarta's trie
compares keys by identity. The first element names the level (`eval`, `eval2`, `eval3`,
`grammar`, `meaning`, `tool`).

| Effect    | Meaning                                                                       |
|-----------|-------------------------------------------------------------------------------|
| `READ`    | Runs in the image. Changes nothing.                                            |
| `SANDBOX` | Runs in a child under time and heap limits. The image is unchanged whatever happens. |
| `COMMIT`  | Runs its tests in a child. Then, in the image inside a world, applies and tests again. Undone on any failure. |
| `KEEP`    | Appends to a keep file under the keep root. Never touches version control.    |

### Configuration

| Key              | Type     | Default                          | Description |
|------------------|----------|----------------------------------|-------------|
| `ollama-port`    | Integer  | `11434`                          | Ollama's port on 127.0.0.1 |
| `model`          | String   | `deepseek-v4.1-flash:cloud`      | The model the loop talks to |
| `trusted`        | Boolean  | `false`                          | Whether `model` is a trusted model |
| `max-turns`      | Integer  | `16`                             | Model replies per task before the loop stops |
| `child-seconds`  | Integer  | `10`                             | A child's time limit |
| `child-heap`     | Integer  | `268435456`                      | A child's heap limit, in bytes (`set-heap-limit`) |
| `output-limit`   | Integer  | `4096`                           | Characters of printed output returned per call |
| `keep-root`      | String   | none: KEEP tools refuse until set | The worktree directory keep files go under |
| `read-roots`     | List of String | the directory the image started in | The only directories a confined child reads |
| `approve-commits`| Boolean  | `true`                           | Whether a trusted model's `define` also waits for the user (an untrusted model's always does) |
| `cyc-port`       | Integer  | `3601`                           | The reference server's text API port on 127.0.0.1 |
| `cyc-seconds`    | Integer  | `30`                             | Time limit for one reference server answer |
| `cyc-default-mt` | String   | `#$InferencePSC`                 | The microtheory a question names no other |

`model` defaults to the model the spike measured. `trusted` defaults to false because the only
model measured ignores `format`. `child-seconds` is the spike's longest JOHN plan check with
margin. `keep-root` has no default, so nothing is written until the user names a place.
`read-roots` defaults to the tree Maru runs from, which is public code. `approve-commits`
defaults to true until a trusted model has been measured. `cyc-default-mt` is
`#$InferencePSC`, Cyc's usual context for queries, which sees every microtheory's facts, because
an agent asking a commonsense question means what Cyc knows, not one context of it.

**Resolution precedence** (highest first):

1. A value set by the program that starts the loop
2. An environment variable `MARU_AGENT_<KEY>`, the key upper-cased with `-` as `_`
3. The default from the table above

### Behavior

#### The reflection index

The reflection index MUST be a trie built with `trie.k`'s `trie-new`, `trie-at` and
`set-trie-at`, keyed by paths of interned symbols. [R-index-trie]
Piumarta's trie is already how `ir2.k` interns function types and `net/ip.k` finds handlers.
Strings as keys would never match, because the trie compares by identity.

```maru-check @R-index-trie
agent_reflect
```

On `eval`, the index MUST hold an entry for every binding of `*globals*`, of kind FUNCTION,
FORM or VARIABLE by its value's type, under `(eval globals NAME)`. [R-index-globals]
`*globals*` is a boot.l `<env>`; walking its `bindings` up to `offset` reaches every name (373
after boot.l).

```maru-check @R-index-globals
agent_reflect
```

The index MUST hold each selector's methods under `(eval globals SELECTOR TYPE-NAME)` and each
generic's under its path extended by the sequence of type names, naming each type through
`%type-names`. [R-index-methods]
This is lookup by a sequence of types, which is what Piumarta's trie was written for.

```maru-check @R-index-methods
agent_reflect
```

The index MUST hold each meaning table's entries under `(meaning TABLE TYPE-NAME)`, with
TABLE one of `expand`, `encode`, `eval` and `apply`. [R-index-meaning]

```maru-check @R-index-meaning
agent_reflect
```

On `eval2` and `eval3`, the index SHOULD hold their list-based environments' bindings under
`(eval2 …)` and `(eval3 …)`; where it doesn't, `lookup` on such a path MUST answer
`E_LEVEL_UNINDEXED`, not an empty result. [R-index-levels]
An empty answer would read as "nothing is defined", which is false.

```maru-check @R-index-levels
agent_reflect
```

A definition made through a COMMIT tool MUST update the index inside the same world, so that a
failed or undone definition leaves no entry behind. [R-index-in-world]
The trie lives in Maru's heap, so `try` undoes its writes like any others.

```maru-check @R-index-in-world
agent_reflect
```

#### The meaning trace

`trace-meaning` MUST answer, for a form given as text, the chain Maru follows to evaluate it:
for the form and each subform it reaches, its type's name, the meaning-table entry consulted at
each step (expand, encode, eval, apply), and the entry's path in the index. It MUST compute
this by reading the tables, not by evaluating the form. [R-trace-meaning]
Piumarta's slides put this first: introspection "from determining the type of a polymorphic
value to full analysis of the system's code as data". What actually runs tells an agent more
than any name does.

```maru-check @R-trace-meaning
agent_reflect
```

#### The tool table

The tool table MUST define at least these tools:

| Tool          | Effect    | Answers |
|---------------|-----------|---------|
| `lookup`      | `READ`    | The entry at a path, or `E_NOT_FOUND` |
| `list`        | `READ`    | The paths under a prefix, at most 200, and whether there were more |
| `describe`    | `READ`    | An entry with its signature and, where its source is known, its definition's text |
| `trace-meaning` | `READ`  | The meaning trace of a form |
| `parse`       | `READ`    | The tree a named, loaded grammar makes of some text, or where it stopped |
| `evaluate`    | `SANDBOX` | The value and printed output of a form, run in a child |
| `test`        | `SANDBOX` | A named check case or law, run in a child, with its verdict |
| `define`      | `COMMIT`  | A definition, applied in the image after the tests named with it pass |
| `john-ask`    | `READ`    | What a JOHN program's expression evaluates to, in the current world |
| `john-plan`   | `SANDBOX` | A plan for a JOHN goal, run in a child under a named strategy |
| `cyc-ask`     | `READ`    | The reference server's or the KB extract's answer to a whitelisted question |
| `keep`        | `KEEP`    | Appends a definition, with the tests it passed, to a keep file |

[R-tool-set]

```maru-check @R-tool-set
agent_tools
```

From the tool table, the agent loop MUST derive (a) the `tools` array sent in each `/api/chat`
request, with each tool's name, description and arguments as a JSON Schema object, and (b) the
JSON Schema sent as `format` when the model is trusted, which admits exactly one call of one
tool. Neither MAY be written by hand. [R-tool-derived]

```maru-check @R-tool-derived
agent_tools
```

Every tool call in a reply MUST be checked against its tool's argument grammar before its
handler runs, whether the model is trusted or not. A call naming no tool is `E_UNKNOWN_TOOL`;
arguments the grammar rejects are `E_BAD_ARGUMENTS`, with where it stopped. Either is sent back
to the model as the call's result, and nothing runs. [R-tool-checked]
Ollama ignored `format` on the cloud model without saying so, and a constraint can be
misconfigured, so the check is never skipped.

```maru-check @R-tool-checked
agent_tools
```

The tool table MUST itself appear in the reflection index under `(tool NAME)`, so an agent
can `describe` its own tools. [R-tool-reflected]

```maru-check @R-tool-reflected
agent_tools
```

#### The sandbox

A SANDBOX tool's code MUST run only in a child forked from the image. The child sets its heap
limit to `child-heap` and an alarm at `child-seconds`. It writes its Result to a pipe as one
frame of the wire format (Formal Grammar), and exits. [R-child]
A child shares the image's state up to the fork and can crash, loop or run out of memory
without touching the image. `recover.l` can't catch a stack overflow, but a child can still
crash from one harmlessly.

```maru-check @R-child
agent_sandbox
```

When a child ends without a complete frame, the tool's Result MUST be `E_CHILD_DIED`, with
the signal or exit status and how long it ran; one stopped by its alarm MUST be
`E_CHILD_TIMEOUT`. The image MUST be unchanged either way. [R-child-failure]

```maru-check @R-child-failure
agent_sandbox
```

Before it runs a tool's code, a child MUST confine itself: no network, no file writes, and
file reads only under `read-roots`. On macOS it does so by calling `sandbox_init` with a profile
saying exactly that. Where the child can't confine itself (`sandbox_init` fails, or the
platform has no equivalent), a SANDBOX tool MUST answer `E_UNCONFINED` to an untrusted model and
run nothing. [R-child-confined]
Without this, a cloud model's code could read the user's files and the tool's result would
carry them to the model's service. On 2026-11-05, a Maru process that called `sandbox_init` with
such a profile could still read `boot.l`, but `fopen` of `~/.zshrc` and of a file to write both
failed, and a connection to 127.0.0.1:11434 was refused.

```maru-check @R-child-confined
agent_sandbox
```

`define` MUST (1) run the definition and the tests named with it in a child; (2) if they all
pass, apply the definition in the image inside a world and run the same tests there; and (3)
keep the definition only if they pass again, else undo it and answer `E_TESTS_FAILED`, naming
the tests that failed and where. A `define` naming no tests MUST be refused with `E_NO_TESTS`.
[R-define]
The second run matters: the image can differ from what the child inherited if anything ran
between the fork and the apply. A definition with no tests has no evidence behind it.

For an untrusted model, `define` MUST show the user the definition and its tests, after they
pass in the child and before step (2), and apply it only if the user agrees; a refusal answers
`E_NOT_APPROVED` to the model. For a trusted model, approval follows `approve-commits`.
[R-define-approved]
A child is confined, but the image isn't: a definition in it runs later with all the user's
rights, where it could read files or open connections itself. So a cloud model's code enters the
image only when the user has read it.

```maru-check @R-define-approved
agent_sandbox
```

After an undone `define` of a name that was new, `lookup` MUST answer `E_NOT_FOUND`, even on
`eval`, where `recover.l` leaves a name first bound inside a failed world still bound in
`*globals*`. [R-define-undone]
The index, not the environment, is what the agent reads, so the residue can't mislead it.

```maru-check @R-define-undone
agent_sandbox
```

```maru-check @R-define
agent_sandbox
```

A definition MAY replace a meaning-table entry, a selector's or generic's method or a grammar
rule, as well as a binding. It MUST go through `define` like any other, so that it is tested,
undoable and indexed. [R-intercession]
This is the white paper's horizontal mutation, applied locally, inside a world.

```maru-check @R-intercession
agent_sandbox
```

`keep` MUST refuse with `E_NO_KEEP_ROOT` until `keep-root` is set, and MUST refuse with
`E_OUTSIDE_KEEP_ROOT` a file name that resolves outside it. It appends the definition's text and
the names of the tests it passed, and MUST NOT run version-control commands. [R-keep]

```maru-check @R-keep
agent_sandbox
```

#### The model transport

The agent loop MUST talk to Ollama by HTTP/1.1 POST to `/api/chat` on 127.0.0.1 at
`ollama-port`, with `stream` false. It sends the conversation as messages, and returns each
tool's Result as a message whose role is `tool`, naming the tool. [R-chat]

```maru-check @R-chat
agent_loop
```

The agent loop MUST read JSON (RFC 8259) replies with a grammar in Maru, accepting the whole
of RFC 8259 including `\u` escapes and surrogate pairs, and refusing anything else with
`E_BAD_JSON`, naming the offset where it stopped. [R-json]
The spike read single string fields by searching the text, which can't read a tool call's
nested arguments.

```maru-check @R-json
agent_loop
```

Each reply MUST be recorded as an Exchange before its tool calls run. When a request's text
equals one already recorded, the recorded reply MUST be used and the model not asked. [R-record]
Replay then reproduces a session exactly, and a check can run the loop against recorded
replies with no model at all, as the spike's scripted model did.

```maru-check @R-record
agent_loop
```

The agent loop MUST stop after `max-turns` replies for one task, answering `E_TURNS`. A reply
with no tool calls ends the task with its text as the answer. A failed HTTP request, or a reply
whose status isn't 200, MUST count as a turn and be sent back as an error result, not end the
loop. [R-turns]
The spike lost a whole run to one HTTP 500 before this rule.

```maru-check @R-turns
agent_loop
```

#### The OpenCyc tool

`cyc-ask` MUST accept only a question built from one whitelisted function and arguments that
are Cyc constants (Formal Grammar, `cyc-question`). Maru builds the SubL
text itself. Text from a model MUST NOT reach the reference server any other way. [R-cyc-whitelist]
The reference server's own safety settings don't hold. On 2026-11-05, with
`*TCP-LOCALHOST-ONLY?*` set to T, a client on the LAN got answers, and with
`*PERMIT-API-HOST-ACCESS*` set to NIL, `with-open-file` reached the filesystem. The whitelist is
the boundary that does hold.

The whitelist is below. Every function but `arity` accepts a last argument naming the
microtheory to answer in, which can be left out; `arity` is the same in every microtheory, and the reference server
refuses a second argument to it.

| Function            | Arguments                    | Answers |
|---------------------|------------------------------|---------|
| `isa?`              | term, collection [, mt]      | Whether a term is an instance of a collection |
| `genls?`            | collection, collection [, mt] | Whether a collection is a subcollection of another |
| `all-isa`           | term [, mt]                  | Every collection a term is an instance of |
| `all-genls`         | collection [, mt]            | Every collection a collection is under |
| `min-genls`         | collection [, mt]            | A collection's nearest supercollections |
| `disjoint-with?`    | collection, collection [, mt] | Whether two collections can share no instance |
| `arity`             | predicate                    | A predicate's arity |
| `comment`           | constant [, mt]              | A constant's comment text |

```maru-check @R-cyc-whitelist
cyc_ask
```

When a question names no microtheory, Maru MUST add `cyc-default-mt` to it before either
backend sees it, so that both backends answer in the same microtheory. [R-cyc-mt-default]
The reference server's own default is narrow and unstated: on 2026-11-05,
`(isa? #$Sindh-ProvincePakistan #$State-Geopolitical)` answered NIL with no microtheory and in
`#$BaseKB`, and T in `#$WorldPoliticalGeographyDataVocabularyMt`, `#$InferencePSC` and
`#$EverythingPSC`. A default the KB extract had to guess would make the agreement law test the
guess.

```maru-check @R-cyc-mt-default
cyc_ask
```

A microtheory argument MUST be a constant that is an instance of `#$Microtheory` (8,508 are, in
`#$UniversalVocabularyMt`); any other is `E_CYC_MT`, and nothing is asked. The KB extract MUST
answer in a microtheory by what it sees through `genlMt`, as the reference server does.
[R-cyc-mt]
Microtheories built from functions, such as `(#$MtSpace #$PeopleDataMt (#$MtTimeDimFn …))`,
hold 38,225 of the extract's assertions, but they can't be named as an argument here.

```maru-check @R-cyc-mt
cyc_kb
```

`cyc-ask` MUST answer from either backend, the reference server over its text API at
`cyc-port` or the KB extract read in Maru, with the same Result shape, and name which backend
answered. [R-cyc-backends]
The reference server needs Java 8, a few GB of memory and closed-source classes, so it can't
come to bare metal. The KB extract can.

```maru-check @R-cyc-backends
cyc_ask
```

Over a fixed sample of questions on `isa`, `genls` and `disjointWith`, the KB extract's answers
MUST equal the reference server's. A disagreement is a finding about Maru's reader or its
inference, reported with the question and both answers. [R-cyc-agree]
This is how `law_nile` holds the rules to Nile's own type checker: the reference implementation
decides.

```maru-check @R-cyc-agree
cyc_kb
```

When the reference server doesn't answer within `cyc-seconds`, `cyc-ask` MUST answer
`E_CYC_UNAVAILABLE` and the loop goes on. [R-cyc-unavailable]
A refused LAN connection kills the server's listener threads under its security policy, so it
can go quiet without warning.

```maru-check @R-cyc-unavailable
cyc_ask
```

### Errors

| Error                   | Example                                             | Recovery |
|-------------------------|-----------------------------------------------------|----------|
| `E_NOT_FOUND`           | `lookup` of `(eval globals no-such-name)`           | Sent to the model; it can `list` a prefix |
| `E_LEVEL_UNINDEXED`     | `lookup` under `(eval2 …)` before eval2 is indexed  | Sent to the model; nothing is implied about what's defined |
| `E_UNKNOWN_TOOL`        | a call of `shell`                                   | Sent to the model with the tool names |
| `E_BAD_ARGUMENTS`       | `define` with no text                               | Sent to the model with where the grammar stopped |
| `E_CHILD_DIED`          | the code overflows the stack                        | Sent to the model with the signal; the image is unchanged |
| `E_CHILD_TIMEOUT`       | an endless loop                                     | Sent to the model with the limit; the image is unchanged |
| `E_TESTS_FAILED`        | a definition breaks `john_run`                      | The definition is undone; the failing tests are sent to the model |
| `E_NO_TESTS`            | `define` naming no tests                            | Refused; the model is asked to name some |
| `E_UNCONFINED`          | a SANDBOX call on a platform with no `sandbox_init` | Refused for an untrusted model; nothing runs |
| `E_NOT_APPROVED`        | the user declines a cloud model's definition        | Nothing is applied; sent to the model |
| `E_NO_KEEP_ROOT`        | `keep` before the user sets `keep-root`             | Refused; only the user can set it |
| `E_OUTSIDE_KEEP_ROOT`   | `keep` to `../../.zshrc`                            | Refused; nothing is written |
| `E_BAD_JSON`            | a reply cut off mid-string                          | Counts as a turn; the loop asks again |
| `E_TURNS`               | the 17th reply on one task                          | The task ends; the conversation is kept for review |
| `E_HTTP`                | Ollama answers 500                                  | Counts as a turn; sent back as the call's result |
| `E_CYC_UNAVAILABLE`     | the reference server isn't running                  | Sent to the model; the KB extract can still answer |
| `E_CYC_MT`              | `(isa? #$Dog #$Animal #$Dog)`                       | Sent to the model; nothing is asked |

**Escape hatch.** A program that starts the loop can add tools to the table. Each still needs
an argument grammar and an effect class, and is checked and indexed like the others, but what
its handler does is its author's responsibility.

## Formal Grammar

A child's Result travels as one frame: a decimal length, a newline, and that many bytes of a
wire value.

```abnf
frame        = length LF wire-value
length       = 1*DIGIT
wire-value   = w-integer / w-string / w-symbol / w-nil / w-list
w-integer    = "i" [ "-" ] 1*DIGIT ";"
w-string     = "s" length ":" *OCTET
w-symbol     = "y" length ":" *OCTET
w-nil        = "n"
w-list       = "(" *wire-value ")"
```

A string's or symbol's length counts its bytes, and exactly that many follow the colon.

A `cyc-ask` question, before Maru turns it into SubL:

```abnf
cyc-question = "(" ( two-place / one-place / arity-question ) ")"
two-place    = ( %s"isa?" / %s"genls?" / %s"disjoint-with?" )
               SP cyc-constant SP cyc-constant [ SP cyc-mt ]
one-place    = ( %s"all-isa" / %s"all-genls" / %s"min-genls" / %s"comment" )
               SP cyc-constant [ SP cyc-mt ]
arity-question = %s"arity" SP cyc-constant
cyc-mt       = cyc-constant
cyc-constant = "#$" ( ALPHA / DIGIT ) *( ALPHA / DIGIT / "-" / "_" )
```

Every argument is a constant, so a question carries no strings or numbers for a model to hide
text in. Whether a `cyc-mt` names a microtheory is checked against the KB (`E_CYC_MT`), not by
the grammar.

A constant never contains `?`, which begins a SubL variable: a question names constants only,
so it reads facts and can't become a query over variables.

## Out of Scope

**Inspectors.** STEPS's end-user reflection: tables of cells that follow an object's values,
editable on the fly (TR-2010-004, TR-2012-001). They need a display Maru doesn't have.
Extension point: an inspector is a client of `describe` and `lookup`, plus a subscription the
index would add.

**The typed level.** maru.k's and ir2's own environments (typed globals, struct and function
types). Extension point: a `(typed …)` level in the index, and `trace-meaning` following
`maru.k`'s compile passes as it follows the meaning tables.

**Claude Code and MCP clients.** The bridge that offers the same tool table to an agent outside
the image (the design's option C). Extension point: the tool table already yields JSON Schema
for each tool; a bridge serves those over the spike's framed connection and calls the same
handlers.

**Several agents at once.** Two loops changing one image. Extension point: the operation log of
the local-first spike, where each `define` would be an event.

**CFASL.** OpenCyc's binary protocol on port 3600. Both ports go to the same evaluator, so it
adds no reach, only typed answers. Extension point: a third `cyc-ask` backend.

## Alternatives Considered

**Why not drive the image from outside (Claude Code or an MCP server sending commands)?** The
image would never drive itself, and it needs a host outside the image, which bare metal won't
have. The tool table makes a bridge cheap later; it isn't the first thing.

**Why not trust grammar-constrained output and skip the check?** Ollama ignored `format` on the
cloud model without an error. A constraint can be dropped silently anywhere along the way; the
check costs little and is the same code for every model.

**Why not run SANDBOX tools in a world instead of a child?** A world undoes writes to Maru's heap,
but not raw memory, files or C's state, and a stack overflow kills the process. A child loses
nothing but itself.

**Why not let the agent commit to git?** What lasts should be what the user has read. Keep files
in a worktree give the user an ordinary diff to review.

**Why not index names only?** Piumarta's design puts the reach in intercession: lookup and
`methodAt:put:` in COLA, the meaning tables in Maru. An index of names tells an agent what
exists, not what runs.

**Why not send SubL from the model to the reference server?** Its security settings don't hold,
so any SubL it accepts is code running as the user. The whitelist keeps the questions to reads.

## Security Considerations

This lets a model run code as the user, which nothing in the tree did before.

- **Code from a model** runs first in a child, under time and heap limits, confined to no
  network, no writes and reads under `read-roots` only. That is what keeps a cloud model's code
  from reading the user's files and carrying them out in a tool's result. `sandbox_init` is
  deprecated by Apple but works at the time of writing; where confinement fails, an untrusted
  model gets no SANDBOX tools at all.
- **Code entering the image** is not confined: once defined, it runs with all the user's rights.
  For an untrusted model, every `define` waits for the user to read and agree to it.
- **Data sent to models.** Everything in the conversation goes to the model's service; with a
  cloud model, that's Ollama's cloud. READ tools return what's in the image, and the confined
  child reads only `read-roots`, both public code by default. Pointing `read-roots` at private
  files, or loading private data into the image, sends it out with a cloud model.
- **Persistence** is limited to keep files under `keep-root`, which only the user sets, and
  version control is never run.
- **The reference server** listens on every interface, and its own localhost-only and host-access
  settings don't hold. It runs under a Java security policy that accepts connections only from
  this machine and writes only under its own directory; a refused outside connection stops its
  listeners. `cyc-ask`'s whitelist keeps model text from reaching it as SubL.
- **Ollama** is reached on 127.0.0.1 only.

## Compatibility

Nothing existing changes. The loop, its tools and the index are new files, loaded on request. The
spike's networking and model client are rewritten, not reused, since the spike is throwaway.
At the time of writing (November 2026), the reference server is OpenCyc 4.0 (KB 5022) on Zulu
JDK 8, and the measured model is `deepseek-v4.1-flash:cloud` through Ollama 0.40.14.

## References

- RFC 8259, The JavaScript Object Notation (JSON) Data Interchange Format.
- RFC 9110 and RFC 9112, HTTP Semantics and HTTP/1.1.
- JSON Schema, the form of Ollama's `tools` parameters and `format`:
  https://json-schema.org/
- Ollama API, `/api/chat`: https://github.com/ollama/ollama/blob/main/docs/api.md
- Piumarta, "Accessible Language-Based Environments of Recursive Theories", VPRI RN-2006-001-a
  (`~/pkm/raw/vpri/piumarta-2005-colas-white-paper.txt`).
- Piumarta, slides, Dynamic Languages Symposium 2006 (`~/pkm/raw/vpri/piumarta-2006-dls-slides.txt`).
- Piumarta and Warth, "Open, Extensible Object Models", 2006
  (`~/pkm/raw/vpri/piumarta-warth-2006-open-reusable-object-models.txt`).
- Warth et al., "Worlds: Controlling the Scope of Side Effects", 2011 (`recover.l`'s model).
- STEPS reports TR-2011-004 and TR-2012-001.
- Samimi et al., "Call by Meaning", VPRI TR-2014-003.
- draft-ndn-maru-sat-00 (JOHN planning by satisfiability), draft-ndn-maru-laws-and-rules-00 (laws).
- OpenCyc 4.0, from https://github.com/asanchez75/opencyc (`KB+inference_engine/opencyc-4.0-linux.tgz`).
- Clyc, https://github.com/white-flame/clyc (Common Lisp): its notes on `eval-in-api` document
  how the Cyc API evaluates requests, from LarKC's Apache-licensed source.
