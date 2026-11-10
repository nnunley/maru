# Roadmap

1. An `ir-gen-arm64.k` backend beside `ir-gen-c.k` and `ir-gen-x86.k`.
   Its output goes through `exe.l` to a file or `code-region.l` to the JIT. x86-64 needs the same: `emit.l` and
   `ir-gen-x86.k` emit 32-bit code, so hand-assembled programs are the only native x86-64 binaries so far.
2. Carry over refactor work from `refactor-main` case by case, with tests.
   - First: the UTF-8 grammar, `grammars/unicode/utf8.g` on `refactor-main`.
     It was never run. Its actions read the lead byte as hex text, and it
     accepts overlong forms, surrogates and values above U+10FFFF. Restore it
     with RFC 3629's valid ranges and U+FFFD for invalid input, and add a check.
3. Promote the grammars in `notes/sources/grammars/` (transcribed from the
   STEPS reports and papers) into the tree as working grammars, each with a
   check and a `check/lines` entry. TCP first: `net/tcp.k`'s packet handling
   as the 2007/2008 reports' `svc`/`syn`/`req`/`ack` rules.
4. Bare metal: Maru as a bootable live image. The qemu raw-boot
   environments (i386, x86-64 long mode, A64 `virt`: boot, console, memory
   map, exit) are the first step, specified after the encoders
   (RFC 0001, `doc/rfc/0001-table-assemblers.md`) as part C of the 2026-10-14
   assembler design.
5. Nile on Maru: a Nile runtime written in typed Maru (new kernel interface,
   POSIX mutexes, arm64 and x86-64), then Gezira, then its demos in an SDL3
   window on macOS and Linux.
   Nile and Gezira come in as submodules of forks, and count toward the 20k.
   Spec: `doc/rfc/draft-ndn-nile-runtime-in-maru-02.md`.
   - Array types in `maru.k`/`ir2`, replacing the runtime's `long` field runs.
   - Blocks sized to a stream's element size, so kernels over large tensors
     can run (one 512-byte block size caps an element at about 118 floats).
6. Checks without make or a shell, for the bare-metal image. `check/check.l`
   compiles a stale grammar in-process with `compile-tpeg.l` (each case naming the
   derived files it needs), and `lines` counts the tree in Maru instead of through
   `git ls-files | grep | wc`. Today the cases reach the shell through `run`
   (`system`), and only `make` builds what they need.
