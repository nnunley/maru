# How Dan Amelang Leveraged Maru for the Nile Language

## Overview

Dan Amelang created Nile as a **declarative stream processing language for media applications** at VPRI. Rather than building a compiler from scratch, he leveraged Maru's metacircular architecture as the implementation platform.

## The Nile Language Design

### Core Concept
Nile is a stream processing language with mathematical notation, designed for graphics and media processing:

```nile
-- Types
type Point = (x:Number, y:Number)
type Glyph = (w:Number, s:Number)

-- Stream processing with mathematical operators
PlaceWords (b:Point, h:Number) : Word >> (Word, Point)
    x = b.x
    y = b.y
    ∀ W
        >> (W, (x, y))
        if W.s = 2
            x' = b.x
            y' = y + h
        else
            x' = x + W.w
```

Key features:
- **Mathematical notation**: Uses Unicode symbols (∀, →, >>, ≤, ≥, etc.)
- **Stream-oriented**: Built around the `>>` stream operator
- **Type system**: Static types for media processing
- **Declarative**: Describes what to compute, not how

## How Dan Used Maru

### 1. **Maru as the Host Language**

Dan didn't implement Nile in C or another traditional language. Instead, he implemented it entirely in Maru:

```lisp
; From nile-compiler.l
(require "compile-tpeg.l")  ; Maru's PEG system
(require "print-structure.l")

(nile-load "nile-ast-nodes.l")
(nile-load "nile-resolve.l")
(nile-load "nile-type-check.l")

; Parse Nile grammar using Maru's PEG system
(map eval (parse-and-compile-grammar (++ nile-current-dir "nile-grammar.g")))
```

### 2. **Leveraging Maru's PEG System**

The Nile grammar (`nile-grammar.g`) is written in Maru's PEG notation:

```peg
<nile-parser> : <text-parser> (indentation)

# Mathematical operators as PEG rules
opname1 = [∧∨]@$ ;
opname2 = [<>≤≥≠=≈≉]@$ ;
FOREACH = ("∀" | "for"_"each" | "for"_"all")_ ;

# Stream expressions
expr    = opexpr1 ;
opexpr1 = opexpr1:a " "+ opname1:n " "+ opexpr2:b -> (nile-opexpr n 'in `(,a ,b)) | opexpr2 ;
```

This shows Dan using:
- Maru's PEG parser generator
- Unicode support in Maru
- AST construction via semantic actions

### 3. **Multi-Target Compilation**

Dan created multiple backends, all implemented in Maru:

```lisp
; From nile-compiler.l
(cond ((= nile-target-lang "c")    (nile-load "nile-gen-code-c.l"))
      ((= nile-target-lang "maru") (nile-load "nile-gen-code-maru.l"))
      (else (nile-fatal-error "Target language '"nile-target-lang"' not supported!")))
```

This shows:
- **C backend**: Compiles Nile to C for performance
- **Maru backend**: Compiles Nile to Maru for prototyping
- Extensible architecture for more backends

### 4. **Integration with Graphics Libraries**

Nile integrates with Gezira (2D graphics) and uses Maru's FFI:

```lisp
; From libgezira.k - Maru bindings for Gezira
(define gezira_TransformBeziers    (dlextern lib "gezira_TransformBeziers" "pffffff"))
(define gezira_ClipBeziers         (dlextern lib "gezira_ClipBeziers"      "pffff"))
(define gezira_Rasterize           (dlextern lib "gezira_Rasterize"        "p"))

; From libnile.k - Runtime support
(define nile_Process_pipe          (dlextern lib "nile_Process_pipe"       "p."))
(define nile_Process_feed          (dlextern lib "nile_Process_feed"       "ppi"))
```

### 5. **AST Representation in Maru**

Dan defined Nile's AST using Maru's object system:

```lisp
; From nile-ast-nodes.l (inferred structure)
(define-structure <nile-typeref>   (name))
(define-structure <nile-tupletype> (types))
(define-structure <nile-opexpr>    (name fixity args))
(define-structure <nile-varexpr>   (name))
(define-structure <nile-condexpr>  (cases otherwise))
```

## Architectural Insights

### 1. **Language-Oriented Programming**
Dan exemplified language-oriented programming by:
- Creating a domain-specific language (Nile) for graphics
- Using a metacircular host (Maru) that makes language creation easy
- Focusing on mathematical notation natural to the domain

### 2. **Leveraging Metacircularity**
Benefits Dan gained from Maru:
- **Rapid prototyping**: Could modify the compiler in the same language
- **Multiple backends**: Easy to add new code generators
- **Language experiments**: Could quickly try new syntax/semantics
- **Debugging**: Same environment for compiler and runtime

### 3. **Grammar-Driven Development**
The PEG grammar drives everything:
- Parsing with Unicode support
- AST construction
- Type checking
- Code generation

### 4. **Stream Processing Model**
Nile's stream model maps well to:
- Graphics pipelines (vertices → pixels)
- Text layout (glyphs → positions)
- Media processing (frames → effects)

## Technical Implementation Details

### Compilation Pipeline
1. **Parse**: Nile source → AST (using Maru PEG)
2. **Resolve**: Name resolution and binding
3. **Type Check**: Static type verification
4. **Code Gen**: AST → C or Maru code

### Runtime Architecture
- **Processes**: Stream transformers
- **Pipes**: Connect processes
- **Data**: Tuples flowing through streams

### Integration Points
- **FFI**: Direct C library access via `dlextern`
- **Graphics**: Gezira 2D rendering
- **Text**: Glyph and layout processing

## Why This Approach Was Brilliant

### 1. **Appropriate Abstraction Level**
- Nile provides high-level stream abstractions
- Maru provides low-level implementation power
- Together: expressive yet efficient

### 2. **Rapid Development**
- PEG grammars are concise and powerful
- Maru's metacircular nature enables quick iteration
- Same-language debugging throughout

### 3. **Mathematical Notation**
- Unicode operators (∀, →, ≤) make code readable
- Matches mathematical papers and thinking
- Natural for graphics algorithms

### 4. **Practical Results**
Dan achieved:
- Working graphics language
- Multiple compilation targets
- Integration with real rendering libraries
- Readable, maintainable implementation

## Lessons for Language Designers

1. **Use metacircular hosts**: They make language implementation easier
2. **PEG grammars scale**: From simple to complex languages
3. **Domain notation matters**: Use symbols natural to your domain
4. **Multiple targets**: Design for multiple backends from the start
5. **FFI is crucial**: Real languages need library integration

## Conclusion

Dan Amelang's Nile demonstrates the power of using Maru as a language implementation platform. By leveraging Maru's:
- PEG parser generator
- Object system for ASTs
- Multiple compilation targets
- FFI for library integration

He created a sophisticated domain-specific language for graphics programming that would have been much more difficult to implement in a traditional language. This showcases Maru not just as an academic exercise in metacircular compilation, but as a practical platform for creating real programming languages.