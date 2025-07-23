# Open, Extensible Composition Models

**Author:** Ian Piumarta  
**Institution:** Viewpoints Research Institute  
**Publication:** VPRI Technical Report TR-2011-002  
**Conference:** 1st Workshop on Free Composition (FREECO) 2011  
**Publisher:** ACM, New York, NY  
**DOI:** 10.1145/2068776.2068778  
**URL:** https://tinlizzie.org/VPRIPapers/tr2011002_oecm.pdf

## Abstract

This paper presents work on open, extensible composition models developed as part of the VPRI STEPS project. The work explores the relationship between static vs. dynamic, compiled vs. interpreted, and early vs. late-bound systems as continuous ranges rather than strict dichotomies.

## Context: VPRI STEPS Project

The paper emerges from Alan Kay's "Fundamentals of New Computing" project at Viewpoints Research Institute (VPRI). The ambitious goal was to implement an entirely new, self-hosting computing system with GUI in just 20,000 lines of code. This project aimed to demonstrate that modern computing systems could be dramatically simplified while maintaining full functionality.

## Maru: A Metacircular Implementation

The paper discusses Maru, a symbolic expression evaluator that can compile its own implementation language. Key characteristics of Maru include:

### Core Architecture

- **Metacircular Evaluator**: `eval.l` is a metacircular evaluator for the language it is written in
- **Semantics-Preserving Compilation**: The compiler performs a "level shift" from S-expressions to IA32 machine code
- **Bootstrap Escape**: Allows the metacircular evaluator to escape from "infinite metacircular regression" to a language grounded in hardware

### Implementation Details

- **Size**: Approximately 1,750 lines of code (noted as "about twice what it should be")
- **Target Architecture**: IA32 machine code generation
- **Composition Mechanisms**: Several composition mechanisms defined for brevity, clarity, and simplicity

### Included Components

- **Garbage Collector**: Memory management system
- **User-Defined Types**: User-level implementations of custom data structures  
- **Object-Oriented Messaging**: Single-dispatch messaging system
- **Generic Multimethods**: Multiple dispatch system
- **All Compiler Requirements**: Everything needed by the compiler itself

## Theoretical Framework

### Continuous Spectrums vs. Dichotomies

The paper argues against viewing programming language features as strict either/or choices:

- **Static ↔ Dynamic**: Rather than purely static or dynamic typing, systems can exist along a continuum
- **Compiled ↔ Interpreted**: Execution models can blend compilation and interpretation
- **Early-bound ↔ Late-bound**: Binding times can be flexible and contextual

### COLA Influence

The work builds on Piumarta's earlier COLA (Combined Object-Lambda Architecture) research, which sought to be "as late-bound as you can get" while maintaining practicality.

## Composition Models

### Extensible Architecture

The paper presents composition models that are:

- **Open**: Can be extended with new functionality
- **Extensible**: Support modular composition of behaviors
- **Composable**: Allow combination of multiple models

### Self-Hosting Properties  

The system demonstrates self-hosting capabilities where:

- The language can compile itself
- Bootstrap process is well-defined and minimal
- Meta-levels are clearly separated but interconnected

## Historical Impact

### Development Timeline

- **Circa 2011**: Original development by Ian Piumarta at VPRI
- **Integration**: Part of the larger STEPS project ecosystem
- **Legacy**: VPRI went quiet and closed in 2018, but the work influenced later research

### Influence on Metacircular Systems

The paper's approach to metacircular compilation influenced subsequent work on:

- Self-hosting language implementations
- Minimal bootstrap processes
- Composition-based language design

## Technical Contributions

### Bootstrap Process

The paper describes how Maru achieves a clean bootstrap from a minimal evaluator to a fully self-hosting system that can generate machine code.

### Composition Mechanisms

Several specific composition mechanisms are detailed that enable:

- Modular compiler construction
- Extensible language features  
- Clean separation of concerns

### Level Shifting

The concept of "level shifting" - moving between different levels of abstraction while preserving semantics - is a key technical contribution.

## Relationship to Current Maru Codebase

The theoretical framework presented in this paper directly informs the current Maru implementation:

### File Structure Correspondence

- `eval.l`: The metacircular evaluator described in the paper
- `emit.l`: The compilation system that performs "level shifting" to machine code  
- `boot.l`/`boot2.l`: Bootstrap definitions that establish the self-hosting foundation

### Architectural Principles

- **Minimalism**: Every line of code justified by necessity
- **Composability**: Features built through composition rather than monolithic design
- **Extensibility**: Architecture supports adding new capabilities without core changes

## Contemporary Relevance

The paper's vision of flexible, composable programming systems remains highly relevant:

### Modern Applications

- **Language Workbenches**: Tools for creating domain-specific languages
- **Metacircular Interpreters**: Educational and research implementations
- **Bootstrap Studies**: Understanding how minimal systems can become complete

### Ongoing Research Directions

- **Gradual Typing**: Continuous spectrum between static and dynamic typing
- **Multi-Stage Programming**: Compile-time/runtime boundary flexibility
- **Reflective Systems**: Self-modifying and self-analyzing programs

## Technical Specifications

### System Requirements

- **Target**: IA32 architecture (32-bit Intel x86)
- **Host**: Any system capable of running the initial bootstrap
- **Memory**: Minimal requirements due to garbage-collected design

### Performance Characteristics

- **Compilation Speed**: Fast due to simple single-pass design
- **Runtime Performance**: Competitive with traditional interpreters
- **Memory Usage**: Efficient through precise garbage collection

## Research Methodology

### Experimental Approach

The paper represents both theoretical exploration and practical implementation, demonstrating ideas through working code rather than purely abstract models.

### Validation Strategy

- **Self-Hosting**: The ultimate test - the system must compile itself
- **Minimal Size**: Constraint forces elegant solutions
- **Complete Functionality**: Must support all necessary computing operations

## Conclusion

"Open, extensible composition models" presents a vision of programming systems that transcend traditional categorical boundaries. Through Maru, Piumarta demonstrates that powerful, complete computing environments can emerge from surprisingly minimal foundations when designed with appropriate composition principles.

The work stands as both a theoretical contribution to programming language design and a practical demonstration that ambitious goals (like VPRI's 20,000-line complete computing system) are achievable through principled minimalism and thoughtful composition.

## Notes for Maru Development

This paper provides crucial context for understanding the current Maru codebase:

### Design Philosophy

- Every complexity must be justified
- Composition preferred over monolithic solutions
- Self-hosting as the ultimate validation

### Implementation Strategies

- Start with minimal evaluator
- Build composition mechanisms incrementally  
- Maintain ability to bootstrap from scratch

### Future Directions

The paper's vision of flexible composition models suggests several potential extensions to the current Maru system, particularly in areas where strict boundaries could be softened into continuous spectrums.

---

*This document summarizes Ian Piumarta's 2011 paper "Open, extensible composition models" and its relationship to the Maru metacircular compiler system. The original paper is available at the provided URL and contains additional technical details and formal specifications.*