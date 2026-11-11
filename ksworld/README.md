# KSWorld's own source

KSWorld's classes (every class whose name starts with `KS`), as Frank's image last had them: one Squeak file-out per
class, its definition and then its methods by category, `!` doubled as the chunk format requires, LF line endings.
Most of KSWorld's behaviour is KScript (`name = (args) -> body`), kept in Smalltalk method chunks; the KScript compiler
and parser (`KSCompiler`, `KSParser`, `KSParser2`) are Smalltalk.

92 classes, 2,491 methods: `INDEX.txt` counts each class's methods, KScript and Smalltalk (KScript as `ksworld-source.l`
tells it: `selector = (`). Each class's comment is kept, as a chunk the file-out reader passes over.

## Where it comes from

`frank.changes` in `Frank-170908.zip`, the Frank image Yoshiki Ohshima pointed to on squeak-dev on 2020-02-28 ("As for
Frank, we don't necessarily hide it. A zip file is here"):
<https://lists.squeakfoundation.org/pipermail/squeak-dev/2020-February/207478.html>. The archive mangles the link; the
file is <https://tinlizzie.org/~ohshima/Frank-170908.zip>, sha256
`95228a18346f3ddc3c1c682451732052749dffb06c2bde3099dc89da28978e39` (the same on 2026-11-03, 2026-11-06 and 2026-11-10).

A changes file holds every version of every method in the order it was written, whether or not the image kept it: the
VM writes source there as it's accepted and commits the image's pointers to it only when the image is saved. So the image
decides, with the changes and sources files the only inputs. Each of its compiled methods
ends in a source pointer, a position in `frank.changes` (or `SqueakV41.sources`); walking `frank.image` (a 32-bit V3 object
memory, format 6505) for every method's trailer gives the positions of the 28,564 sources it runs, and each KS method here is
the version at one of them. A KScript method is named as KSWorld's compiler names it (`KSSqueakParser>>parseSelector:`):
`name = ()` is `name`, `name = (a)` is `name:` and `name = (a, b)` is `name:with:`, so `KSBox>>textContents` and `textContents:` are two
methods. Class definitions and comments, which nothing here points at, come from replaying the file
session by session: what a session wrote counts only if it was saved (`----SNAPSHOT----`, or a `----QUIT----` that saves;
201 of Frank's sessions end `----QUIT/NOSAVE----`), with `removeClassNamed:` and `renameClassNamed:as:` applied.

Replayed straight through, as this directory first was, it held 29 classes the image had removed (`KSArray`, `KShape`,
`KSTParser`, ...), 11 methods written in sessions quit without saving (`KSBox>>foo`), 9 versions later reverted unsaved
(`KSParser>>initialize`, whose saved version is `yo 9/5/2012`), and 119 methods no live method points at (early
`KSObject>>timerE`, `collectE`, `evaluateAt` ...), removed without a `removeSelector:` in the file. The KS classes have no source in
`SqueakV41.sources`, so the changes file is all of it. The replay is the author's `squeak-changes-extract.py classes
frank.changes ksworld KS --image frank.image`, which also recovers the rest of Frank's VPRI packages (kept privately).

The copyright is VPRI's and its authors'. The zip carries no license.
