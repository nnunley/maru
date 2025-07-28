# Grammar Files - Core to Maru's Extensibility Power

## 🎯 Critical Discovery: Embedded Grammar Syntax

From `test-repl.l`, we can see Maru's **killer feature**: **embedded grammar definitions in `{ }` blocks** that compile and execute immediately!

### Example: Math Calculator with Custom Syntax
```lisp
{
  blank		= [\t\n\r ] ;
  comment	= "//"(![\n\r].)* ;
  _		= (blank | comment)* ;
  digit		= [0123456789] ;
  number	= digit+ $#:d _ -> d ;
  value		= number ;
  factor	= value:a ( "*" _ factor:b	-> (* a b)
			  | "/" _ factor:b	-> (/ a b)
			  |			-> a
			  ) ;
  term		= factor:a ( "+" _ term:b   _	-> (+ a b)
			   | "-" _ term:b   _	-> (- a b)
			   |			-> a
			   ) ;
}
```

This **immediately creates a working calculator** that parses:
```
3 +4
3- 4  
3*3
3* 3+4 *4
```

## 📊 Grammar File Infrastructure (2,061 lines total)

### Essential Core Grammars (~490 lines)
```
grammars/core/peg.g       277 lines  # Meta-grammar: defines grammar syntax itself
grammars/core/tpeg.g      134 lines  # Typed PEG variant
grammars/core/osdefs.g     41 lines  # OS definitions grammar
grammars/core/irgol.g     194 lines  # IR grammar (GOOL)
grammars/core/irl.g       194 lines  # IR language grammar
                         ──────────
Subtotal:                 840 lines  # Core grammar infrastructure
```

### Extended Examples & Demos (~1,221 lines)
```
# Architecture Grammars
grammars/arch/arm64.g     221 lines  # ARM64 assembly grammar
grammars/arch/arm64-asm.g  59 lines  # ARM64 assembler
grammars/arch/x86.g        31 lines  # x86 architecture  
grammars/arch/x86-asm.g    38 lines  # x86 assembler

# Unicode Support
grammars/unicode/*.g      403 lines  # UTF8, collation, normalization

# Example Grammars
grammars/examples/moo.g   313 lines  # Complex example language
grammars/examples/*.g     108 lines  # Simple examples

# Nile Language Integration
compilers/nile/nile-grammar.g 140 lines # Nile language grammar
```

## 🔑 Why .g Files are ESSENTIAL

### 1. **Meta-Grammar Bootstrap**
- `peg.g` defines the syntax for defining grammars
- **Self-hosting grammar system**: PEG grammar is defined in PEG syntax
- Line 73-75 in `peg.g`: `"{"  space grammar:e` - This enables `{ }` block syntax!

### 2. **Embedded Grammar Compilation**
- Grammar blocks `{ }` compile immediately into working parsers
- No external tools needed - everything happens at runtime
- Seamless integration with Lisp macro system

### 3. **Progressive Language Extension**
From `test-repl.l` we see **evolution in action**:

#### Stage 1: Basic Math
```lisp
{ number = digit+ ; factor = value:a ("*" factor:b -> (* a b) | -> a) ; }
```

#### Stage 2: Add Variables  
```lisp
{ name = letter+ ; value = number | name:n -> (eval n) ; vardefn = name:n "=" expression:e -> (eval `(define ,n ,e)) ; }
```

#### Stage 3: Add Functions
```lisp
{ funcall = name:f arglist:a -> `(,f ,@a) ; fundefn = name:f paramlist:a "=" expression:e -> `(define ,f (lambda ,a ,e)) ; }
```

#### Stage 4: Add Control Flow
```lisp
{ if = "if" expression:a "then" expression:b "else" expression:c -> `(if ,a ,b ,c) ; for = "for" name:n "=" expression:a "to" expression:b "do" statement:c -> `(while (<= ,n ,b) ,c (set ,n (+ ,n 1))) ; }
```

## 🏗️ Essential vs Optional Grammar Infrastructure

### ✅ **MUST PRESERVE for Extensibility** (~490 lines)

#### Core Meta-Grammar System
- **`grammars/core/peg.g`** (277 lines) - **CRITICAL**: Defines `{ }` embedded syntax
- **`grammars/core/tpeg.g`** (134 lines) - Typed PEG variant
- **`grammars/core/osdefs.g`** (41 lines) - OS definitions for platform code
- **`grammars/core/irgol.g`** (194 lines) - IR grammar for code generation
- **`grammars/core/irl.g`** (194 lines) - IR language definitions

Without these, **embedded grammar syntax completely breaks**.

### 🎨 **VALUABLE but can be Rebuilt** (~1,571 lines)

#### Architecture-Specific Grammars (349 lines)
- ARM64/x86 assembly grammars
- Platform-specific instruction sets
- **Can be removed for VPRI compliance, rebuilt via extensibility**

#### Unicode Support (403 lines)  
- UTF8 processing grammars
- Collation and normalization
- **Can be rebuilt as grammar extensions**

#### Examples & Demos (461 lines)
- Complex example languages (`moo.g`)
- Test grammars
- **Educational/demo value, not core functionality**

#### Nile Integration (140 lines)
- Nile language compiler grammar
- **Separate system, can be external extension**

## 🔄 Updated VPRI Strategy with Grammar Files

### Revised Essential Core (8,821 lines - still <10K!)
```
# Core Language System
boot.l           1,042 lines  # Bootstrap
eval.l           1,697 lines  # Evaluator  
emit.l           1,053 lines  # Code generator
ir.k               833 lines  # IR definitions
eval.k             930 lines  # Runtime support

# PEG Extensibility System  
core/parser.l      866 lines  # Stream abstraction
core/peg.l         159 lines  # PEG classes
core/peg-boot.l    405 lines  # Bootstrap rules
core/peg-compile.l 136 lines  # Grammar compilation
core/peg-compiler.l 210 lines # Rule compiler

# ESSENTIAL Grammar Files (enable embedded syntax)
grammars/core/peg.g   277 lines  # Meta-grammar (CRITICAL for { } blocks)
grammars/core/tpeg.g  134 lines  # Typed PEG
grammars/core/osdefs.g 41 lines  # OS definitions  
grammars/core/irgol.g 194 lines  # IR grammar
grammars/core/irl.g   194 lines  # IR language

# Support Infrastructure
osdefs.k           200 lines  # OS definitions
buffer.l           150 lines  # Basic I/O
gc.l               300 lines  # Garbage collector
misc support       200 lines  # Remaining essentials
                ──────────────
TOTAL:           8,821 lines  # ✅ Under 10K with full grammar extensibility!
```

## 💡 Grammar File Extensibility Benefits

### 1. **Language Evolution Without Core Changes**
- New syntax added via `{ }` blocks
- Mathematical notation: `{ equation = expr "=" expr }`
- SQL-like queries: `{ select = "SELECT" columns "FROM" table }`
- State machines: `{ state = "state" identifier transitions }`

### 2. **Domain-Specific Languages**
- Embedded DSLs for specific problem domains
- Custom notation for mathematical, scientific, or business logic
- Graphics languages, query languages, configuration languages

### 3. **Educational Platform**
- Students can experiment with syntax design
- Progressive introduction of language features
- Real working examples in `test-repl.l`

## 🚨 Critical Warning

**Removing core grammar files would BREAK Maru's fundamental value proposition.**

The `{ }` embedded grammar syntax that makes Maru an extensible platform depends on:
1. `grammars/core/peg.g` defining the grammar syntax
2. Core PEG compiler infrastructure 
3. Runtime grammar compilation capability

Without these, Maru becomes just another Lisp - losing its unique extensibility power.

## ✅ Updated Success Criteria

1. **Line count**: ≤10,000 lines total
2. **Self-hosting**: Can compile itself  
3. **Bootstrap**: Can generate eval2 from eval.l
4. **Portability**: Runs on major platforms via C backend
5. **🔥 EXTENSIBILITY**: Can define embedded grammars in `{ }` blocks**
6. **Grammar compilation**: Meta-grammar system functional
7. **Understandability**: Single person can comprehend entire system

**Test Case**: The system must be able to execute `test-repl.l` embedded grammar examples successfully.