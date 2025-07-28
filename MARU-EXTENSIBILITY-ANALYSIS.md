# Maru Extensibility System - Core PEG Infrastructure Analysis

## 🎯 Maru Extensibility Hypothesis

**Core Principle**: Additional systems must be able to embed grammars to extend the language system dynamically.

This is **fundamental to Maru's value proposition** - not just a metacircular compiler, but an **extensible language platform** where new syntactic constructs can be added through embedded grammars.

## 📊 Current PEG Infrastructure Assessment

### Core PEG System (Essential - 1,776 lines)
```
core/parser.l      866 lines  # Stream abstraction & basic parsing
core/peg.l         159 lines  # PEG class definitions & selectors  
core/peg-boot.l    405 lines  # Bootstrap PEG implementation
core/peg-compile.l 136 lines  # Grammar compilation system
core/peg-compiler.l 210 lines # PEG rule compiler
                  ─────────────
TOTAL:           1,776 lines  # Essential for extensibility
```

### Enhanced PEG Features (Advanced - 1,200+ lines)
```
archive/experimental/peg-ir-compiler.l        # IR-based parser generation
archive/experimental/peg-grammar-environments.l # Grammar isolation
archive/experimental/peg-boot-enhanced.l     # Dynamic instantiation
dotted-access-working.l                      # Environment access syntax
```

### Grammar Definitions (~200 lines)
```
grammars/core/peg.g    # PEG grammar definition
grammars/core/tpeg.g   # Typed PEG variant
```

## 🔑 Extensibility Requirements

### 1. **Grammar Embedding Capability**
- Systems must be able to define new syntax dynamically
- Grammars should be isolated (no rule name conflicts)
- Runtime parser generation from grammar definitions

### 2. **Syntactic Extension Examples**
```lisp
;; SQL-like syntax embedded in Maru
(define-grammar sql-subset
  ((select-stmt (match-sequence 
                  (match-string "SELECT") 
                  (match-rule columns)
                  (match-string "FROM")
                  (match-rule table)))))

;; Mathematical notation
(define-grammar math-notation
  ((equation (match-sequence
               (match-rule expression)
               (match-char #\=)
               (match-rule expression)))))

;; Custom DSL for specific domains
(define-grammar state-machine
  ((state (match-sequence
            (match-string "state")
            (match-rule identifier)
            (match-rule transitions)))))
```

### 3. **Integration Points**
- **Bootstrap Integration**: PEG system loads during boot process
- **Runtime Extension**: New grammars can be defined and used immediately
- **Macro Integration**: Grammar rules can generate macro expansions
- **Code Generation**: Parsed structures feed into emit system

## 🏗️ Essential vs Enhanced Components

### ✅ **ESSENTIAL (Must Preserve for Extensibility)**

#### Core Infrastructure (1,776 lines)
- **`core/parser.l`** - Stream abstraction, position management
- **`core/peg.l`** - PEG class system and method dispatch
- **`core/peg-boot.l`** - Basic PEG rules (CLASS, OBJECT, STRING, etc.)
- **`core/peg-compile.l`** - Grammar compilation pipeline
- **`core/peg-compiler.l`** - Rule-to-code compiler

#### Grammar System (~200 lines)
- **`grammars/core/peg.g`** - Meta-grammar for defining new grammars
- Basic grammar definition syntax

### 🎨 **ENHANCED (Valuable but could be rebuilt)**

#### Advanced Features (~1,200 lines)
- **IR-based compilation** - More sophisticated parser generation
- **Grammar environments** - Namespace isolation for rules
- **Dynamic instantiation** - Runtime parser creation
- **Dotted access syntax** - `env.symbol` convenience syntax

#### Specialized Extensions
- **TPEG system** - Typed PEG variant
- **Debug parsers** - Parser debugging tools
- **Test infrastructure** - PEG-specific test suites

## 🔄 Updated VPRI Compliance Strategy

### Previous Plan Issues
The original VPRI reduction plan marked PEG enhancements as "non-essential" and targeted them for removal. This was **incorrect** given Maru's extensibility hypothesis.

### Corrected Core System (8,400 lines - still VPRI compliant)
```
boot.l           1,042 lines  # Bootstrap only
eval.l           1,697 lines  # Single evaluator
emit.l           1,053 lines  # C backend only  
ir.k               833 lines  # Essential IR

# PEG SYSTEM (Essential for extensibility)
core/parser.l      866 lines  # Stream abstraction
core/peg.l         159 lines  # PEG classes
core/peg-boot.l    405 lines  # Bootstrap rules  
core/peg-compile.l 136 lines  # Compilation
core/peg-compiler.l 210 lines # Rule compiler
grammars/core/peg.g 50 lines  # Meta-grammar

eval.k             930 lines  # Runtime support
osdefs.k           200 lines  # OS definitions
buffer.l           150 lines  # Basic I/O
gc.l               300 lines  # Garbage collector
misc support       300 lines  # Remaining essentials
                ─────────────
ESTIMATED:       8,331 lines  # ✅ Still under 10K!
```

## 🚀 Extensibility Benefits

### 1. **Language Evolution**
- New syntax can be added without rebuilding core system
- Domain-specific languages embedded in Maru
- Gradual syntax migration (old and new can coexist)

### 2. **Ecosystem Development**  
- Third parties can create syntax extensions
- Libraries can provide their own notation
- Educational systems can define simplified syntax

### 3. **Research Platform**
- Syntax experiments don't require core changes
- New parsing techniques can be prototyped
- Language design research facilitated

## 📋 Action Items

### 1. **Update VPRI Reduction Plan**
- Preserve complete PEG infrastructure in essential core
- Mark advanced PEG features as "valuable enhancements"
- Ensure grammar embedding capability remains intact

### 2. **Validate Extensibility Chain**
- Verify boot process loads PEG system correctly
- Test that new grammars can be defined and used
- Ensure integration with macro and emit systems

### 3. **Documentation**
- Create extensibility examples and tutorials
- Document grammar embedding best practices
- Provide migration path for existing extensions

## 💡 Conclusion

The PEG parser system is **not optional tooling** - it's **core infrastructure** that enables Maru's fundamental value proposition as an extensible language platform. 

Any VPRI-compliant reduction must preserve the complete grammar embedding capability, as this is what distinguishes Maru from a simple metacircular compiler and makes it a platform for language evolution and extension.

**Updated Core Principle**: VPRI compliance should preserve **extensibility over features** - the ability to add new capabilities is more valuable than any specific existing capability.