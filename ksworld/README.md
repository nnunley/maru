# KSWorld's own source

KSWorld's classes (every class whose name starts with `KS`), as Frank's image last had them: one Squeak file-out per
class, its definition and then its methods by category, `!` doubled as the chunk format requires, LF line endings.
Most of KSWorld's behaviour is KScript (`name = (args) -> body`), kept in Smalltalk method chunks; the KScript compiler
and parser (`KSCompiler`, `KSParser`, `KSParser2`) are Smalltalk.

121 classes, 2,593 methods: `INDEX.txt` counts each class's methods, KScript and Smalltalk.

## Where it comes from

`frank.changes` in `Frank-170908.zip`, the Frank image Yoshiki Ohshima pointed to on squeak-dev on 2020-02-28 ("As for
Frank, we don't necessarily hide it. A zip file is here"):
<https://lists.squeakfoundation.org/pipermail/squeak-dev/2020-February/207478.html>. The archive mangles the link; the
file is <https://tinlizzie.org/~ohshima/Frank-170908.zip>, sha256
`95228a18346f3ddc3c1c682451732052749dffb06c2bde3099dc89da28978e39` (the same on 2026-11-03 and 2026-11-06).

A changes file holds every version of every method in the order it was written. For each class and selector the last
version is kept; a `removeSelector:` drops it, and a class's last definition is kept. The KS classes have no source in
`SqueakV41.sources`, so the changes file is all of it.

The copyright is VPRI's and its authors'. The zip carries no license.
