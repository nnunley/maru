# Maru Version Evolution - Change Tracking Analysis

## Overview

This document tracks the evolution of Maru through its version history, documenting the changes between each release based on the archaeological git history reconstruction.

## Version Release Timeline

1. **v1.0-original** - Ian Piumarta's genesis implementation (6 files)
2. **v2.1-public** - First public multi-file release (January 25, 2012)
3. **v2.2-bootstrap-fix** - Metacircular bootstrap restoration (August 19, 2012)
4. **v2.3-win32-unicode** - Windows compatibility with Unicode (August 22, 2012)
5. **v2.4-darwin-mingw32** - Darwin and MinGW32 fixes (August 24, 2012)
6. **v2.5-vpri-complete** - VPRI canonical complete system (106+ files)

## Change Tracking Between Versions

### v1.0 → v2.1 (Genesis to First Public Release)

**Massive Transformation**: From 6 files to a complete multi-file system

The transformation from v1.0 to v2.1 represents the most significant evolution in Maru's history, expanding from a proof-of-concept to a practical programming system.

### v2.1 → v2.2 (Bootstrap Restoration)

**Major Changes**: 90 files modified, focusing on metacircular bootstrap

Key improvements:
- **Makefile**: Extensive build system improvements (+90 lines)
- **boot.l**: Major enhancements to core language (+209 lines)
- **eval.c**: Significant runtime improvements (+418 lines)
- **asm-x86.k**: Complete refactoring (904 lines changed)
- **New Files**: 
  - `assembler.k` (470 lines) - Native assembler
  - `compile-peg.l` (171 lines) - PEG compiler
  - `compile-tpeg.l` (195 lines) - Typed PEG compiler
  - `doc/ir.html` & `doc/ir.mac` - Comprehensive IR documentation

**Significance**: This release restored the metacircular bootstrap capability, a critical feature that had been broken in intermediate development.

### v2.2 → v2.3 (Windows Unicode Support)

**Focused Changes**: 3 files modified for Windows compatibility

Key improvements:
- **Makefile**: Windows build support (+16 lines)
- **eval.c**: Unicode handling improvements (+81 lines)
- **mkosdefs.c**: OS definition updates (+3 lines)

**Significance**: Minimal but critical changes to support Windows with Unicode, demonstrating surgical precision in cross-platform support.

### v2.3 → v2.4 (Darwin/MinGW32 Compatibility)

**Targeted Fixes**: 5 files modified for compatibility

Key improvements:
- **Makefile**: Platform detection improvements
- **boot.l**: Core language fixes (+23 lines)
- **eval.c**: Runtime compatibility (+20 lines)
- **test-pegen.k**: Test updates
- **text-parser.l**: Parser improvements (+32 lines)

**Significance**: Final compatibility fixes for Darwin (macOS) and MinGW32, completing cross-platform support.

### v2.4 → v2.5 (VPRI Complete System)

**Massive Expansion**: From ~77 files to 106+ files

This represents the transition from Ian Piumarta's individual development to the VPRI STEPS project, adding:
- Graphics integration (Gezira)
- Networking capabilities (Nile)
- LLVM IR backend
- Complete standard library
- Extensive testing framework
- Advanced optimization passes

## Evolution Patterns

### 1. Incremental Refinement (v2.1-v2.4)
The intermediate versions show careful, incremental improvements:
- Each version addresses specific issues
- Changes are minimal and focused
- Backward compatibility maintained
- Bug fixes prioritized over new features

### 2. Platform Evolution
- v2.1: Linux/Unix focus
- v2.2: General improvements
- v2.3: Windows Unicode support
- v2.4: Darwin (macOS) and MinGW32 support
- v2.5: Full cross-platform with multiple backends

### 3. Feature Evolution

**Core Compiler**:
- v1.0: Basic metacircular evaluator
- v2.1: Structured compiler with multiple files
- v2.2: Restored bootstrap capability
- v2.3-2.4: Stability and compatibility
- v2.5: Multiple backends (C, x86, LLVM)

**Parser System**:
- v2.1: Basic parser
- v2.2: PEG compiler introduction
- v2.5: Complete PEG system with grammar compilation

**Build System**:
- v1.0: Simple Makefile (32 lines)
- v2.1: Structured build system
- v2.2: Extensive build improvements
- v2.3-2.4: Platform detection
- v2.5: Comprehensive multi-platform build

## File Count Evolution

| Version | File Count | Notable Additions |
|---------|------------|-------------------|
| v1.0 | 6 | Core system |
| v2.1 | ~42 | Multi-file structure |
| v2.2 | ~50 | Assembler, PEG compiler |
| v2.3 | ~50 | Minimal changes |
| v2.4 | ~50 | Minimal changes |
| v2.5 | 106+ | Complete VPRI system |

## Change Tracking Quality

The git history provides excellent change tracking:

1. **Atomic Commits**: Each version is a single tagged commit
2. **Clear Messages**: "Maru release X.Y" or "Maru X.Y"
3. **Diff Visibility**: All changes trackable through git diff
4. **File-Level Tracking**: Complete visibility into what changed
5. **Line-Level Detail**: Exact modifications visible

## Insights from Change Analysis

### 1. Development Philosophy
- **Minimalism**: Changes are minimal and focused
- **Stability**: Core architecture remains stable
- **Compatibility**: Strong focus on cross-platform support
- **Pragmatism**: Fix what's broken, don't over-engineer

### 2. Critical Transitions
- **v1.0→v2.1**: Proof of concept to practical system
- **v2.1→v2.2**: Bootstrap capability restoration
- **v2.4→v2.5**: Individual to institutional development

### 3. Technical Evolution
The codebase shows a clear evolution from:
- Single-developer focus → Team development
- Single platform → Multi-platform
- Basic features → Complete system
- Simple testing → Comprehensive validation

## Conclusion

The version evolution shows excellent change tracking with clear, atomic commits for each release. The development pattern demonstrates careful, incremental improvement with a focus on stability and compatibility. The transition from v2.4 to v2.5 represents a quantum leap in capabilities while maintaining the core metacircular architecture.

This change tracking provides a valuable record of how a metacircular compiler evolves from concept to production system, with each step carefully documented in the version control history.