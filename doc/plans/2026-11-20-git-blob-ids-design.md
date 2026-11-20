# Git blob ids computed in Maru: design

Approved 2026-11-20, in conversation.

## Intent

The ledger's include fingerprints (`include: PATH SUMMARY @ ID`, `doc/measures.md`) are files' git blob ids. Today
`ledger.l` starts `git hash-object` to compute them. The bare-metal goal wants Maru checking itself, so Maru computes
the ids instead, identical to git's in whichever object format the repository uses.

Reading the ledger then needs no git. The `lines` and `erosion` checks still do, as they did before the ledger: the
files they count are listed by `git ls-files` and their attributes read by `git check-attr` (`erosion-files.l`).
Replacing those (walking the tree under `.gitignore`, reading `.gitattributes` by grammar) is a separate change.

The ids are content addresses. The route to think about for later, on bare metal, is a content-addressed store of
history keyed by them, so that an include's `@ ID` can fetch the file as it was. That store is out of scope here.

## Goals

- Reading `check/ledger`, its fingerprints included, starts no git process.
- An id equals `git hash-object --no-filters PATH` for every file, in SHA-1 and SHA-256 repositories, in a worktree.
- The id is taken over the file's bytes, never a Maru string: strings stop at a NUL and read text as characters.

## Non-goals

- Reading git's object store, packfiles, or fetching old contents.
- Hardened (collision-detecting) SHA-1: plain SHA-1 gives git's ids for every ordinary file.
- Removing git from the attribution report: at a revision it keeps `git rev-parse REV:PATH` (the same id), and it
  needs git for diffs anyway.

## Approaches

1. SHA-256 over git's blob form always, written `@ sha256:…`: reuses `sha256.l`; matches git only in SHA-256
   repositories, so in this SHA-1 repository the ids would differ from git's.
2. **Chosen:** match the repository's object format: a SHA-1 beside `sha256.l`, the format read from the repository's
   config (`extensions.objectformat`, SHA-1 when absent). Ids equal git's everywhere; the cost is a second hash to keep
   until the repository moves to SHA-256.
3. SHA-256 of the raw contents, without git's blob form: simplest, but no git compatibility; dropped.

## Design

- `sha1.l`: FIPS 180-4 SHA-1 in the style of `sha256.l`, `(sha1 bytes start length)` answering 20 bytes.
- `git-object.l`: `(git-blob-id path root)`, the hex id of the file at path in the repository at root: git's header
  `blob SIZE` and a NUL, then the file's bytes (`file-bytes.l`), hashed with the repository's algorithm. The algorithm
  comes from the repository's config: root's `.git` is a directory, or a file whose `gitdir:` line names one; a
  worktree's git directory names the shared one in `commondir`. `.git` and the config are read by a grammar.
- `ledger.l`: `ledger-fingerprint` answers `git-blob-id`.
- `doc/roadmap.md`, bare metal: the content-addressed store as the route for history.

## Left to the builder

The grammar's shape, where the tests live, the ledger entries.
