# Cleanup Summary

## Cleanup Actions Performed

### 1. Removed Compiled Binaries
- `generated` - Test binary
- `threaded-add-simple` - Test binary
- `eval2-utf8` - UTF8 test binary
- `return42` - Test binary
- `.dSYM` directories - Debug symbol directories
- Kept essential binaries: `eval`, `eval2`, `evalm`, `mkosdefs`

### 2. Consolidated JIT Documentation
- Created `MARU-JIT-EXPLORATION.md` - Single comprehensive JIT reference
- Removed individual JIT docs:
  - `JIT-POC-ANALYSIS.md`
  - `MARU-JIT-DESIGN.md`
  - `MARU-JIT-FEASIBILITY-COMPLETE.md`
- Moved JIT code files to `archive/jit-exploration/`

### 3. Organized Documentation
- Moved project planning/history docs to `doc/project-history/`:
  - Version evolution documents
  - Project analysis documents
  - Design and planning documents
- Reduced root directory markdown files from 27 to 16

### 4. Cleaned Temporary Files
- Removed backup files: `eval2.backup`, `emit.l.backup`
- Removed .new files: `peg.l.new`, `tpeg.l.new`, `osdefs.g.l.new`
- Removed `nile-analysis/` directory (already integrated)

### 5. Organized Experimental Code
- Moved to `archive/experimental/`:
  - Dotted syntax experiments
  - PEG compiler experiments
  - Evalm variants
- Moved test files to `tests/` directory

## Current State

The project is now better organized with:
- Clean root directory focused on core files
- Documentation properly categorized
- Experimental code archived but preserved
- No stray binaries or temporary files
- JIT exploration consolidated into single reference

## File Count Changes
- Root .md files: 27 → 16
- Root .l files: 36 → reduced (exact count varies)
- Better separation between stable core and experiments