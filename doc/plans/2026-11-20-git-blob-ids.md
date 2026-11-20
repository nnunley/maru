# Git Blob Ids in Maru Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** The ledger's include fingerprints computed in Maru, identical to git's blob ids, so reading the ledger starts no git process (listing the counted files still uses `git ls-files` and `git check-attr`; out of scope).

**Architecture:** `sha1.l` beside `sha256.l`; `git-object.l` builds git's blob form over a file's bytes and hashes it with the algorithm the repository's config names, read by a grammar, `git-repo.g`; `ledger.l`'s `ledger-fingerprint` calls it.

**Tech Stack:** Maru (`eval`), tpeg grammars, `file-bytes.l`, `sha256.l`; git only in tests, as the oracle.

**Spec:** `doc/plans/2026-11-20-git-blob-ids-design.md`

## Global Constraints

- Work in `.worktrees/erosion-attribution`, on branch `erosion-attribution`; run everything from its root.
- Ids equal `git hash-object --no-filters PATH`, in SHA-1 and SHA-256 repositories and in a worktree.
- Hash bytes, never strings: `file-bytes.l` reads the file; a Maru string stops at a NUL and holds characters.
- The format: `extensions.objectformat` in the repository's config, `sha1` when absent; `sha256` the only other value.
- No shell in checks (`spawn.l` starts programs directly). git appears only in tests, as the oracle.
- Every line-count change gets a `check/ledger` entry in continuation form; erosion and verbosity entries from
  `make erosion-report REV=HEAD`, never guessed.
- Definitions in dependency order (a global used in a function is defined above it); no `t` variable (use `'t`).

## Review Focus

- A `.git` file whose `gitdir:` is relative (git writes absolute paths, but a moved worktree may be fixed up with a
  relative one): resolved against root.
- A config with `objectformat` in another case or spacing (`objectFormat = sha256`, tabs): git's keys are
  case-insensitive, so it is read.
- A file with a NUL byte in it: hashed whole, not cut at the NUL.
- An empty file: `blob 0` and the NUL alone, `e69de29bb2d1d6434b8b29ae775ad8c2e48c5391` in SHA-1.
- A root that isn't a repository (no `.git`): an error naming root, not a wrong id.

Each has its test in Task 2.

---

### Task 1: SHA-1

**Files:**
- Create: `sha1.l`
- Create: `check/git-object.l` (the unit's tests; prints `git object ok` last)
- Modify: `check/check.l` (a unit `git_object` after `erosion`), `doc/measures.md` (the unit's bullet),
  `AGENTS.md` (the unit in the Line count and erosion line)

**Interfaces:**
- Produces: `(sha1 bytes start length)` → a list of 20 bytes, `bytes` an array as `sha256` takes.
  `check/git-object.l` has `expect`, `hex (bytes)` and `bytes-of-string (s)` as `check/exe.l` defines them.

- [ ] **Step 1: Write the failing tests** in `check/git-object.l`, NIST vectors:

```lisp
(expect "sha1 empty" (digest "") "da39a3ee5e6b4b0d3255bfef95601890afd80709")
(expect "sha1 abc" (digest "abc") "a9993e364706816aba3e25717850c26c9cd0d89d")
(expect "sha1 two blocks" (digest "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq") "84983e441c3bd26ebaae4aa1f95129e5e54670f1")
(expect "sha1 55" (digest (a-times 55)) "c1c8bbdc22796e28c0e15163d20899b65621d65a")
(expect "sha1 56" (digest (a-times 56)) "c2db330f6083854c99d4b5bfb6e8f29f201be699")
(expect "sha1 64" (digest (a-times 64)) "0098ba824b5c16427bd7a1122a5a442a25ec644d")
```

with `digest` as `(hex (sha1 (bytes-of-string s) 0 (string-length s)))` and `a-times` n copies of `a`.

- [ ] **Step 2: Run** `./eval check/git-object.l` — Expected: `error: undefined variable: sha1`.
- [ ] **Step 3: Implement `sha1.l`**: 80 rounds, five 32-bit words from `67452301 efcdab89 98badcfe 10325476
  c3d2e1f0`, padding as `sha256` pads (the 1 bit, zeros to 56 mod 64, the bit length big-endian). Every function
  under CC 10.
- [ ] **Step 4: Run** `./eval check/git-object.l` — Expected: `git object ok`.
- [ ] **Step 5: Add the unit** `(check "git_object" …)` asserting the last line is `git object ok`; its bullet in
  `doc/measures.md`; run `make check CHECKS="git_object"` — Expected: `PASS git_object`.
- [ ] **Step 6: Commit** `feat(git-object): SHA-1 in Maru, NIST vectors`.

### Task 2: git-blob-id

**Files:**
- Create: `git-repo.g`, `git-object.l`
- Modify: `check/git-object.l`, `doc/measures.md` (the bullet)

**Interfaces:**
- Consumes: `sha1` (Task 1), `sha256` (`sha256.l`), `file-bytes`/`byte-at` (`file-bytes.l`).
- Produces: `(git-blob-id path root)` → hex string; `(git-object-format root)` → `'sha1` or `'sha256`, an error
  naming root if root has no `.git`.

- [ ] **Step 1: Write the failing tests**, each repository made by `git init -q --object-format=F` in the unit's
  scratch directory (`MARU_CHECK_TMP`), every expected id from `git hash-object --no-filters` there:
  - `"a file's id, SHA-1"` and `"…, SHA-256"`: a file of `héllo → wörld\n`; ids
    `5157042005afd04924712f06029d845980ea00f9` and
    `6799f2cef17ebee190dd8212caaff632212b99d0c699d3b3cb810cc759af4143`, and equal to git's.
  - `"an empty file"`: `e69de29bb2d1d6434b8b29ae775ad8c2e48c5391`.
  - `"a NUL inside"`: the bytes `a`, 0, `b` written with `fopen`/`fputc` subrs as `exe.l` writes; equal to git's.
  - `"in a worktree"`: `git worktree add` of the SHA-256 repository; the worktree's id equals git's (`commondir`
    followed).
  - `"a relative gitdir"`: a copy of the worktree's `.git` file rewritten with a relative path; same format.
  - `"objectFormat in another case"`: a config written by hand with `\tobjectFormat = sha256`; `'sha256`.
  - `"no repository"`: `(git-object-format "/nonexistent")` refused, the message naming the path.
- [ ] **Step 2: Run** `./eval check/git-object.l` — Expected: `error: undefined variable: git-blob-id`.
- [ ] **Step 3: Write `git-repo.g`**: entry rules `gitfile` (`gitdir: ` then the rest of the line → the path) and
  `config` (sections and `key = value` lines → the value of `objectformat` under `[extensions]`, keys compared
  case-insensitively, or ()). Lines it doesn't need (comments, other sections, continuation) are skipped, not refused.
- [ ] **Step 4: Implement `git-object.l`**: `git-object-format` (root's `.git`: a directory, or a file read by
  `gitfile`, relative paths against root; that directory's `commondir`, if any, relative to it; `config` read there)
  and `git-blob-id` (an array of the header's bytes, a 0, then each `byte-at` of `file-bytes`, hashed, as hex).
- [ ] **Step 5: Run** `./eval check/git-object.l` — Expected: `git object ok`.
- [ ] **Step 6: Commit** `feat(git-object): git blob ids from a file's bytes, the repository's format`.

### Task 3: The ledger fingerprints without git

**Files:**
- Create: `check/ledger-read.l`
- Modify: `ledger.l` (`ledger-fingerprint`), `check/erosion.l`, `check/git-object.l`, `doc/measures.md`

**Interfaces:**
- Consumes: `git-blob-id` (Task 2).
- Produces: `(ledger-fingerprint path)` → `(git-blob-id path ".")`, unchanged in shape.

- [ ] **Step 1: Write the failing test** `"the ledger reads with no git on PATH"` in `check/git-object.l`: run
  `./eval check/ledger-read.l` (a three-line script: require `ledger.l`, print `(ledger-read (contents-of-file-named
  "check/ledger"))`) as a `<command>` with env `(("PATH" . "/nonexistent"))`; its output has no `moved since` and
  equals the same script's output run with git on PATH.
- [ ] **Step 2: Run** — Expected: FAIL (git not found, so `ledger-fingerprint` answers () and both includes report
  moved).
- [ ] **Step 3: Implement**: `ledger-fingerprint` answers `git-blob-id`; `ledger.l` requires `git-object.l`.
- [ ] **Step 4: Run** `./eval check/git-object.l` and `./eval check/erosion.l` — Expected: `git object ok`,
  `erosion ok` (the pinned `hello` ids still hold).
- [ ] **Step 5: Commit** `feat(ledger): fingerprints computed in Maru`.

### Task 4: The route for history, and the ledger

**Files:**
- Modify: `doc/roadmap.md` (bare metal), `check/ledger`

- [ ] **Step 1:** In `doc/roadmap.md`'s bare-metal item, a paragraph: the ids `git-object.l` computes are content
  addresses; the route for history on bare metal is a content-addressed store keyed by them, git's object layout
  (zlib, which `png.irl` inflates) the model, so an include's `@ ID` can fetch the file as it was.
- [ ] **Step 2:** `make erosion-report REV=HEAD` (against the commit before Task 1); entries for `lines`, `erosion`
  and `verbosity` in `check/ledger`, continuation form, from its numbers.
- [ ] **Step 3: Run** `make check CHECKS="lines erosion erosion_attribution git_object"` — Expected: four PASS lines.
- [ ] **Step 4: Run** `caffeinate -i make check` alone — Expected: `all checks passed`.
- [ ] **Step 5: Commit** `docs(roadmap): content-addressed history as the route on bare metal`, and push.
