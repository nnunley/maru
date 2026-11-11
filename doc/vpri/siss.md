
# SISS and the DynaBook Data Store

SISS is a Squeak package that writes an object graph as S-expression text: each object is one element with an `:idref`, and references between objects are ids. The DynaBook Data Store, in the same package, is a content-addressed store built from DBDataStore, DBStorage, DBUrl, DBIndex, DBWriter and DBReader. A value is stored under the SHA-1 of its bytes. The index of a store is itself a stored S-expression, and one mutable file, `db/refs/index`, holds the key of the current index. Each save adds a version that links back to the one it replaces. LDBJr read and wrote `.siss` documents. Frank's DBJr sample documents use the same tree as KSWorld's `.pp` files, with different attribute names.

## Why

LDBJr needed to save whole pages (boxes, pictures, scripts, links between them) as plain text that could be copied and reloaded. SISS-yo.4 (21 January 2011) says it "Stores scripts in S-Expression objects and into the scripts instance variable of pages." The data store adds history. DBWriter>>writeMain: writes a header and a body, then calls `indexReplace:type:with:`, so the previous version becomes a `replaces` link. The class comment of DBDataStore states the layout: the index is stored in the hash storage like any content, and its key is kept at `db/refs/index`.

The STEPS reports describe DBjr as "a first pass at an 'omni-application' for STEPS" (VPRI TR-2009-016). No paper in the corpus names SISS or the data store. The 2012 report counts 1,260 lines of serialization in KSWorld and the Document Editor, and cites Ohshima's VPRI memo M-2013-001 on serializing FRP-style programs, which is not in the corpus.

## How

The store, from the DBDataStore class comment:

    DBDataStore default indexPut: 'Hello, world!!' type: 'text/plain'.
    DBDataStore default entriesMeta.
    (DBDataStore default at: 'db:943a702d06f34599aee1f8da8ef9f7296031d699' asUrl) asString

A key is the hash as text, `db:` and 40 hex digits (DBDataStoreTest>>testDBUrl):

    (DBUrl newFrom: 'Hello, World!!') printString
        = 'db:0a0a9f2a6772942557ab5355d76af442f8f65e01'

Equal bytes give one key, so a picture saved twice is stored once (DBWriter>>writeForm:into:).

Objects are written with `sissScanObjects` (SISSTest>>testAssociationWrite):

    (10 -> 20) sissScanObjects prettyString
    "(objects :root \"1\"
    	(Association :idref \"1\" :keyClass \"SmallInteger\" :keyValue \"10\"
    		:valueClass \"SmallInteger\" :valueValue \"20\"))"

A saved document is two S-expressions, a head and a body (DBReader class>>readURL:to: reads both). The head is built by DBIndex class>>subject:date:from:hasPart:replaces:, with a `hasPart` link for each resource. The 94 sample files in the dbjr documents (https://tinlizzie.org/dbjr/) have no head. They begin with the body, as `1b4582d0484e.siss` does:

    (objects :root "1"
    	(LBox :idref "1" :contentsCollectionClass "LCollection"
    		(slot :idref "2" :name "components")
    		(slot :idref "6" :name "transformation")
    		...

None of the 94 contains a `db:` link, and the file names are not the SHA-1 prefix of the contents (checked on three files). So these were not written through DBDataStore.

Reading needs `SexpParser`, which is defined in LObjects (LObjects/source.st, line 59356), not in SISS.

## When

- **Dates and authors.** The SISS record runs from SISS-bf.1 (11 January 2011, "initial commit") to SISS-yo.34 (5 July 2011). The ancestry record lists 33 versions by yo 23, tak 7 and bf 3. The server listing holds 34 (yo 24), including SISS-yo.33 (packages.tsv, 2011-07-06 02:36 UTC), which the record skips. The record's times are local: SISS-yo.34's 5 July 7:48 pm is the server's 2011-07-06 02:48 UTC, which is why INDEX.md's last date is one day later. INDEX.md follows the server, so it is correct. The data store starts with SISS-tak.5, "The first changeset of DynaBook Data Store", by Yamamiya (tak).
- **Status.** Not in the Frank image (INDEX.md). The store is behind the preference `useDBDataStore`, which defaults to false (DBDataStore class>>initialize). Its directory is `db` under the default FileDirectory.
- **Reach for it** when reading or converting Frank's `.siss` documents. Maru issue #9, "Read Frank's .siss documents" (nnunley/maru#9), is open.

## Family of expression

SISS uses one S-expression form for several jobs: a document body, the store's index (`(index (link :href "db:..." :rel "references" :type "text/x-siss"))`), a copy of a page's objects (LDBJr's `sissScanObjectsForCopy prettyStringWithSorting`, LDBJr/source.st, line 14, which its demo writes to a file), and page scripts (SISS-yo.4). The result is plain text.

KSWorld's `.pp` is the same tree in a different vocabulary:

| | `.siss` (SISS) | `.pp` (KSWorld) |
|---|---|---|
| object id | `:idref "1"` | `:ref "1"` |
| instance variable | `(slot :idref "2" :name "components")` | `(slot :keyClass "Symbol" :keyValue "ticks" :name "1" :valueId "2")` |
| script or stream | `LScript` objects with Smalltalk source (SISS-yo.4) | `(KSEventStream :__code__ "..." :__type__ "exprE" :ref "2")`, KScript |
| picture | `(Form :idref ... :href "<name>.png")` | `(Form ... :href "<name>.png")` |

`notes/sources/frank-dbjr-formats.md` dates the change: `.pp` replaces `.siss` in January 2013. Its `pagesBubble.ks` holds both `index.siss` (25 January) and `index.pp` (29 January). `.pp` is written by KSObjects' PPPusher (KSObjects/source.st, line 11629); PPPuller and PPParser sit beside it in the same package. On the Maru side, `ksworld-pp.l` only reads: `ksworld-read-pp` calls Maru's own `read`, and `ksworld-load` builds the objects. Its header calls it a deserializer. The `.siss` side has no reader in Maru yet, which is issue #9.

## Links

- Related: [silt](silt.md), [j](j.md), [ometa2](ometa2.md)
- Maru repository (this repository): `ksworld-pp.l` (the `.pp` reader), `ksworld/README.md` (where the KSWorld sources come from), `notes/sources/frank-dbjr-formats.md` (a 2026-11-03 survey of both formats), and issue nnunley/maru#9.

## Sources

- package SISS, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package LDBJr, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package LObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- package KSObjects, its latest version at https://tinlizzie.org/updates/exploratory/packages/
- https://tinlizzie.org/updates/exploratory/packages/
- the dbjr documents (https://tinlizzie.org/dbjr/)
- STEPS 2009 report, VPRI TR-2009-016
- STEPS final report, VPRI TR-2012-001
- `ksworld-pp.l` in this repository
- `notes/sources/frank-dbjr-formats.md` in this repository
