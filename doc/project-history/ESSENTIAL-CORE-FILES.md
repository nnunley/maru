# Essential Maru Core Files

## Absolutely Essential (Do Not Touch)
```
boot.l boot2.l eval.l eval2.c port.l trie.k osdefs.k
gc.c buffer.c wcs.c eval.c
Makefile CLAUDE.md
```

## Core Compiler System
```
core/compiler/emit.l
core/compiler/emit-c-threaded.l
emit-c-threaded.l (unified implementation)
```

## Documentation (Keep Key Docs)
```
CLAUDE.md
MARU-TARGET-ARCH-INTEGRATION.md
ARM64-BACKEND.md
```

## Everything Else Can Be Archived
The remaining files are either:
- Generated files (eval2-*.c variants)
- Experimental implementations (evalm-*.l)
- Documentation of experiments (various .md files)
- Test outputs (threaded-*.c, unified-*.c)
- Support experiments (utf8.c, mini-eval.l, etc.)