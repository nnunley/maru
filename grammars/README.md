# Maru Grammar Files

This directory contains all grammar definitions used in the Maru system.

## Directory Structure

### core/
Core language grammars:
- **peg.g** - Parsing Expression Grammar (PEG) definition
- **tpeg.g** - Tree PEG grammar (enhanced PEG with tree construction)
- **irgol.g** - IR language grammar (high-level IR syntax)
- **irl.g** - IR low-level grammar
- **osdefs.g** - OS definitions grammar (generates platform-specific constants)

### arch/
Architecture-specific assembly grammars:
- **x86.g** - x86 assembly language grammar
- **arm64.g** - ARM64 assembly language grammar

### unicode/
Unicode and text processing grammars:
- **utf8.g** - UTF-8 encoding/decoding grammar
- **utf8-collation.g** - UTF-8 collation rules
- **utf8-collation-simple.g** - Simplified collation
- **utf8-full-unicode.g** - Full Unicode support
- **utf8-normalization.g** - Unicode normalization
- **unicode-collation.g** - General Unicode collation

### examples/
Example and test grammars:
- **test-dc.g** - Desktop calculator grammar example
- **test-recursion2.g** - Recursion test grammar
- **moo.g** - Example object-oriented grammar

## Grammar File Format

Grammar files use the PEG syntax defined in `core/peg.g`. Basic structure:

```
rule-name = expression ;

expression = sequence
           / choice
           / repetition*
           / optional?
           / positive+
           / &predicate
           / !predicate
```

## Using Grammars

To compile a grammar file:
```bash
./eval2 compile-peg.l grammar-file.g > grammar-file.l
```

To use a compiled grammar:
```lisp
(require "grammar-file.l")
```

## Creating New Grammars

1. Define your grammar rules in a `.g` file
2. Place it in the appropriate subdirectory
3. Compile it using the PEG compiler
4. Test with appropriate input files

See `examples/` for simple grammar examples to get started.