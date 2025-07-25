# Maru JIT Compiler Design for macOS

## Overview

This document outlines the design for implementing a JIT-like native code compilation system for Maru on macOS, avoiding Apple's JIT restrictions by using `dlopen()` to load dynamically generated native code.

## Requirements for Maru JIT on macOS

### macOS Security Requirements

**Memory Protection APIs:**
- `MAP_JIT` flag for mmap() to allocate JIT-capable memory
- `pthread_jit_write_protect_np()` to toggle W^X (write XOR execute) protection
- Memory must alternate between writable (for code generation) and executable (for running)

**Code Signing:**
- Requires `com.apple.security.cs.allow-jit` entitlement
- Must be properly code-signed for distribution
- Development builds can use ad-hoc signing

### True JIT Implementation with MAP_JIT

A traditional JIT implementation would use:

```c
// Allocate JIT memory
void* jit_memory = mmap(NULL, size, 
                       PROT_READ | PROT_WRITE | PROT_EXEC,
                       MAP_PRIVATE | MAP_ANONYMOUS | MAP_JIT,
                       -1, 0);

// Write code (must disable protection)
pthread_jit_write_protect_np(0);  // Make writable
memcpy(jit_memory, generated_code, code_size);

// Execute code (must enable protection)
pthread_jit_write_protect_np(1);  // Make executable
((void(*)())jit_memory)();  // Call generated code
```

### Alternative Approach: dlopen() Strategy

Instead of dealing with JIT restrictions, we can:
1. Generate machine code or C code
2. Write to a file
3. Compile/assemble to a dynamic library
4. Load with `dlopen()`
5. Execute normally

This avoids all JIT restrictions while achieving native performance.

## Comparison: MAP_JIT vs dlopen() Strategy

### MAP_JIT Approach

**Pros:**
- **Lower latency** - No file I/O or external process invocation
- **Fine-grained control** - Can patch code in-place
- **Memory efficiency** - No intermediate files
- **True JIT capabilities** - Dynamic optimization, inline caching
- **No external dependencies** - No need for compiler/assembler at runtime

**Cons:**
- **Requires entitlements** - `com.apple.security.cs.allow-jit` needed
- **App Store restrictions** - Cannot be distributed via Mac App Store
- **Security complexity** - Must manage W^X protection correctly
- **Debugging difficulty** - No symbols, harder to debug
- **Platform specific** - Different APIs on different platforms
- **Limited memory** - JIT memory regions have size limits

### dlopen() Approach

**Pros:**
- **No special entitlements** - Works with standard code signing
- **App Store compatible** - Can be distributed normally
- **Better debugging** - Real symbols and debug info available
- **Leverages optimizing compilers** - Full C compiler optimizations
- **Cross-platform** - Same approach works everywhere
- **Unlimited size** - No restrictions on code size
- **Persistent caching** - Can save compiled libraries

**Cons:**
- **Higher latency** - File I/O and process spawning overhead
- **Requires toolchain** - Needs compiler/assembler installed
- **Disk usage** - Creates temporary/cached files
- **Process overhead** - Spawning compiler processes
- **Less dynamic** - Cannot easily patch running code
- **dlopen limits** - System limits on loaded libraries (256-1024)

### Performance Comparison

**MAP_JIT Performance:**
```
Initial compilation: ~1-10ms (in-memory only)
Execution: Native speed
Memory usage: Minimal
Suitable for: Frequent small compilations
```

**dlopen() Performance:**
```
Initial compilation: ~100-1000ms (file I/O + external compiler)
Execution: Native speed (same as MAP_JIT)
Memory usage: Higher (files + compiler process)
Suitable for: Larger compilation units, cached execution
```

**dlopen() with Maru's Native Code Generation:**
```
Initial compilation: ~10-50ms (direct assembly generation)
Execution: Native speed (same as MAP_JIT)
Memory usage: Moderate (files but no external process)
Suitable for: All compilation scenarios
```

### Recommendation for Maru

The dlopen() approach is recommended for Maru because:

1. **Matches Maru's design** - Already has excellent code generation
2. **Fast native generation** - Maru can directly emit machine code, avoiding external compiler overhead
3. **Environment-based compilation** - Natural compilation units reduce dlopen() overhead
4. **No distribution restrictions** - Can be packaged normally
5. **Better development experience** - Easier debugging and profiling
6. **Cross-platform compatibility** - Same code works on Linux/BSD
7. **Caching opportunities** - Compiled environments can be reused

With Maru's internal assembly generation, compilation latency is dramatically reduced:
- **Direct machine code generation** - Skip C compilation entirely
- **No external process spawning** - Everything happens in-process
- **Minimal file I/O** - Just write object file and link
- **Near-JIT performance** - 10-50ms vs 1-10ms for true JIT

The approach combines the best of both worlds:
- Fast compilation (close to MAP_JIT speeds)
- No security restrictions (like dlopen)
- Full control over generated code
- Ability to optimize at the instruction level

## Architecture Design

### Leveraging Existing Infrastructure

Maru already has:
- Direct assembly generation (`arch/arm64/*.l`, `arch/x86/*.l`)
- C code generation (`emit-c.l` and variants)
- IR system for intermediate representation
- Multimethod dispatch system

### Multimethod-Based Architecture Dispatch

```lisp
;;; emit-native.l - Multimethod-based native code generation via dlopen

(require "ir.k")

;; Base architecture class
(define-class <architecture> () (name pointer-size endianness))

;; Specific architectures
(define-class <arm64> <architecture> ())
(define-class <x86> <architecture> ())
(define-class <x64> <architecture> ())  
(define-class <riscv> <architecture> ())
(define-class <wasm> <architecture> ())

;; Architecture instances
(define *arch-arm64* (new <arm64> 'arm64 8 'little))
(define *arch-x64* (new <x64> 'x64 8 'little))
(define *arch-x86* (new <x86> 'x86 4 'little))
(define *arch-riscv* (new <riscv> 'riscv 8 'little))

;; Current architecture detection
(define-function current-architecture ()
  (let ((arch (or (getenv "MARU_TARGET_ARCH")
                  (cond ((string-match "arm64" (uname)) "arm64")
                        ((string-match "x86_64" (uname)) "x64")
                        (else "x86")))))
    (cond ((= arch "arm64") *arch-arm64*)
          ((= arch "x64") *arch-x64*)
          ((= arch "x86") *arch-x86*)
          ((= arch "riscv") *arch-riscv*)
          (else (error "Unknown architecture")))))
```

### Multimethod Definitions for IR → Native

```lisp
;; Generic emit-native multimethod
(define-multimethod emit-native (ir-insn arch output-port))

;; Architecture-agnostic IR operations
(define-method emit-native <ir-move> <architecture> (port)
  (emit-native-move self (current-architecture) port))

(define-method emit-native <ir-add> <architecture> (port)
  (emit-native-binary-op self 'add (current-architecture) port))

;; ARM64 specific implementations
(define-method emit-native <ir-move> <arm64> (port)
  (let ((src (ir-move-source self))
        (dst (ir-move-destination self)))
    (cond ((ir-immediate? src)
           (emit-arm64-mov-imm port dst (ir-immediate-value src)))
          ((ir-register? src)
           (emit-arm64-mov-reg port dst src))
          (else (error "Unknown move source")))))

(define-method emit-native <ir-add> <arm64> (port)
  (emit-arm64-add port 
                  (ir-add-destination self)
                  (ir-add-source1 self)
                  (ir-add-source2 self)))

;; x64 specific implementations  
(define-method emit-native <ir-move> <x64> (port)
  (let ((src (ir-move-source self))
        (dst (ir-move-destination self)))
    (cond ((ir-immediate? src)
           (emit-x64-mov-imm port dst (ir-immediate-value src)))
          ((ir-register? src)
           (emit-x64-mov-reg port dst src))
          (else (error "Unknown move source")))))

(define-method emit-native <ir-add> <x64> (port)
  (emit-x64-add port
                (ir-add-destination self)
                (ir-add-source1 self)
                (ir-add-source2 self)))
```

## Compilation Strategies

### Direct Assembly Generation

Using Maru's existing assembly generators:

```lisp
;; emit-dylib.l - Direct assembly to dynamic library
(define-function compile-to-native-dylib (name forms)
  (let ((asm-file (concat-string "/tmp/maru-" name ".s"))
        (obj-file (concat-string "/tmp/maru-" name ".o"))
        (dylib-file (concat-string "/tmp/maru-" name ".dylib")))
    
    ;; Generate assembly directly using Maru's internal tools
    (with-output-to-file asm-file
      (emit-dylib-header)
      (emit-native-forms forms))
    
    ;; Assemble to object file
    (shell-command (concat-string "as -o " obj-file " " asm-file))
    
    ;; Link to dylib (minimal, no libc needed for simple functions)
    (shell-command 
      (concat-string "ld -dylib -o " dylib-file " " obj-file 
                     " -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path`"))
    
    ;; Load it
    (dlopen dylib-file RTLD_NOW)))
```

### Direct Machine Code Generation (Even Faster)

Maru can generate machine code directly without going through assembly text:

```lisp
;; Direct machine code generation - skip assembly step entirely
(define-function compile-to-native-direct (name forms)
  (let ((obj-file (concat-string "/tmp/maru-" name ".o"))
        (dylib-file (concat-string "/tmp/maru-" name ".dylib")))
    
    ;; Generate machine code directly into object file format
    (with-binary-output-to-file obj-file
      (emit-mach-o-header (current-architecture))
      (let ((code-buffer (make-buffer)))
        ;; Use Maru's IR → machine code generation
        (for-each forms
          (lambda (form)
            (let ((ir (compile-to-ir form)))
              (emit-native-code ir (current-architecture) code-buffer))))
        (emit-mach-o-text-section code-buffer))
      (emit-mach-o-symbols forms))
    
    ;; Link to dylib (only linking step needed)
    (shell-command 
      (concat-string "ld -dylib -o " dylib-file " " obj-file 
                     " -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path`"))
    
    ;; Load it
    (dlopen dylib-file RTLD_NOW)))
```

This approach leverages Maru's complete toolchain:
- **ARM64 machine code generation** (`arch/arm64/arm64-compiler-complete.l`)
- **x86-64 machine code generation** (`arch/x86/x86-compiler.l`)
- **Direct object file creation** (skip assembler entirely)
- **Minimal external dependencies** (only need system linker)

## Linker Functionality and Elimination

### What the Linker Provides

The system linker (ld) provides several functions in our approach:

#### 1. **Dynamic Library Format Creation**
- Converts object files (.o) into proper dynamic libraries (.dylib)
- Creates Mach-O file structure with all required load commands
- Sets up proper file headers and magic numbers

#### 2. **Symbol Export Table**
- Creates the export trie that dlsym() uses to find functions
- Makes function symbols visible for dynamic lookup
- Handles name mangling and symbol visibility

#### 3. **Dynamic Loader Integration**
```
LC_ID_DYLIB         - Library identification
LC_SYMTAB           - Symbol table location
LC_DYSYMTAB         - Dynamic symbol table
LC_DYLD_INFO_ONLY   - Export trie and binding info
```

#### 4. **System Library Dependencies**
- Links against libSystem (even for minimal code)
- Resolves any system calls (malloc, free, etc.)
- Sets up proper load commands for dependencies

#### 5. **Position-Independent Code**
- Handles relocations for PIC
- Sets up GOT (Global Offset Table) if needed
- Ensures code works at any load address

### Eliminating the Linker: Direct Dylib Generation

Maru could generate complete dylib files directly, eliminating the linker dependency:

```lisp
;; Direct dylib generation - no linker needed
(define-function generate-minimal-dylib (name code-buffer symbols)
  (let ((dylib-file (concat-string "/tmp/maru-" name ".dylib")))
    (with-binary-output-to-file dylib-file
      ;; Mach-O header
      (emit-u32 #xfeedfacf)  ; MH_MAGIC_64
      (emit-u32 (if (eq? (current-architecture) *arch-arm64*)
                    CPU_TYPE_ARM64
                    CPU_TYPE_X86_64))
      (emit-u32 CPU_SUBTYPE_ALL)
      (emit-u32 MH_DYLIB)    ; File type
      
      ;; Load commands
      (emit-load-command-segment code-buffer)
      (emit-load-command-dylib-id name)
      (emit-load-command-symtab symbols)
      (emit-load-command-dysymtab)
      (emit-load-command-dyld-info exports)
      
      ;; Code and data
      (emit-text-section code-buffer)
      
      ;; Symbol tables
      (emit-symbol-table symbols)
      (emit-string-table symbol-names))
    
    ;; Load it directly
    (dlopen dylib-file RTLD_NOW)))
```

### Benefits of Eliminating the Linker

1. **Faster compilation** - No external process spawning
2. **Smaller output** - Only include what's needed
3. **Full control** - Custom optimization opportunities
4. **No dependencies** - Completely self-contained system
5. **Simpler deployment** - No need for developer tools installed

### Minimal Dylib Requirements

For simple functions with no external dependencies:
- Basic Mach-O header (64 bytes)
- One TEXT segment with code
- Minimal symbol table with function exports
- No imports or relocations needed

### Performance with Direct Dylib Generation

```
Code generation: ~5-10ms
Dylib creation: ~1-2ms
File writing: ~1ms
Total: ~7-13ms (approaching true JIT speeds!)
```

This brings us very close to MAP_JIT performance while maintaining all the benefits of the dlopen() approach.

### C Generation Approach

Leveraging existing C emission:

```lisp
;; compile-and-load.l
(define-function compile-to-dylib (name forms)
  (let ((c-file (concat-string "/tmp/maru-" name ".c"))
        (dylib-file (concat-string "/tmp/maru-" name ".dylib")))
    
    ;; Generate C code
    (with-output-to-file c-file
      (emit-c-header)
      (emit-c-forms forms))
    
    ;; Compile to dylib
    (shell-command 
      (concat-string "cc -shared -fPIC -O2 -o " 
                     dylib-file " " c-file))
    
    ;; Load the library
    (dlopen-library dylib-file)))
```

## dlopen() Limitations and Solutions

### System Limits

**macOS:**
- Typical limit: 256-1024 loaded libraries
- Controlled by `DYLD_SHARED_REGION_SIZE` and file descriptor limits
- Each library consumes 2-3 file descriptors
- Memory overhead: ~100KB-1MB per library

**Linux:**
- Similar limits, controlled by `ulimit -n` (file descriptors)
- Default often 1024 FDs total (shared with all files)
- Memory map limits: `/proc/sys/vm/max_map_count` (default ~65530)

### Mitigation: Environment-Based Compilation Units

Instead of compiling individual functions, compile entire environments as units:

```lisp
;;; environment-compiler.l - Environment-based native compilation

(define-class <compiled-environment> <environment> 
  (library-handle     ; dlopen handle
   symbol-table       ; symbol → native address mapping
   compilation-state  ; pending, compiled, loaded
   dependencies))     ; other environments this depends on

;; Extend multimethod for environment compilation
(define-multimethod compile-environment (env arch))

(define-method compile-environment <environment> <architecture> ()
  "Compile entire environment to native library"
  (let* ((env-name (or (environment-name self) (gensym "env")))
         (lib-path (environment-library-path env-name))
         (compiled-env (new <compiled-environment>)))
    
    ;; Copy environment structure
    (set (<environment>-parent compiled-env) (<environment>-parent self))
    (set (<environment>-bindings compiled-env) (<environment>-bindings self))
    
    ;; Generate native code for all functions in environment
    (with-output-to-file (concat lib-path ".s")
      (emit-environment-header env-name)
      (emit-environment-bindings self (current-architecture))
      (emit-environment-functions self (current-architecture))
      (emit-environment-footer))
    
    ;; Compile and link
    (compile-and-link-library lib-path)
    
    ;; Load the library
    (let ((handle (dlopen lib-path RTLD_NOW)))
      (set (<compiled-environment>-library-handle compiled-env) handle)
      (set (<compiled-environment>-symbol-table compiled-env) 
           (load-symbol-table handle env-name))
      (set (<compiled-environment>-compilation-state compiled-env) 'loaded))
    
    compiled-env))
```

### Environment Structure Emission

```lisp
(define-method emit-environment-bindings <environment> <architecture> ()
  "Emit data section for environment bindings"
  (println ".data")
  (println ".align 3")
  
  ;; Emit binding table
  (println env-name "_bindings:")
  (for-each (<environment>-bindings self)
    (lambda (binding)
      (let ((name (car binding))
            (value (cdr binding)))
        (cond 
          ;; Constants can be embedded
          ((number? value)
           (println ".quad " value " # " name))
          ;; Strings need special handling
          ((string? value)
           (emit-string-constant name value))
          ;; Function references
          ((function? value)
           (println ".quad " (mangle-function-name name)))
          ;; Other values need runtime initialization
          (else
           (println ".quad 0 # " name " (runtime init)")))))))

(define-method emit-environment-functions <environment> <architecture> ()
  "Emit all functions in environment"
  (println ".text")
  (for-each (<environment>-bindings self)
    (lambda (binding)
      (let ((name (car binding))
            (value (cdr binding)))
        (when (function? value)
          (emit-native-function name value (current-architecture)))))))
```

### Closure and Cross-Environment Call Support

```lisp
;; Handle closures that reference parent environment
(define-method emit-closure-support <environment> <architecture> ()
  "Generate closure trampolines for captured variables"
  (let ((captured (find-captured-variables self)))
    (when captured
      (println ".data")
      (println env-name "_closure_data:")
      (emit-closure-table captured)
      
      (println ".text")
      (for-each captured
        (lambda (var)
          (emit-closure-accessor var))))))

;; Optimize calls within same environment
(define-method emit-function-call <ir-call> <environment> <architecture> ()
  (let ((target (ir-call-target self)))
    (if (environment-contains? env target)
        ;; Direct call within environment
        (emit-direct-call target (current-architecture))
        ;; Inter-environment call through PLT
        (emit-plt-call target (current-architecture)))))
```

### Smart Compilation Triggers

```lisp
;; Compile environment when it's "hot"
(define-class <environment-profiler> ()
  (call-counts      ; Per-environment call tracking
   compile-threshold ; Calls before compilation
   size-threshold))  ; Minimum functions to justify compilation

(define *env-profiler* 
  (new <environment-profiler> (make-table) 100 5))

(define-method maybe-compile-environment <environment-profiler> (env)
  (let ((count (get-call-count self env))
        (size (environment-function-count env)))
    (when (and (>= count self.compile-threshold)
               (>= size self.size-threshold)
               (not (compiled? env)))
      (compile-environment env (current-architecture)))))

;; Hook into function calls
(define-method pre-call-hook <expr> (env)
  (increment-environment-calls *env-profiler* env)
  (maybe-compile-environment *env-profiler* env))
```

## Implementation Strategies

### Phase 1: Basic Infrastructure
- JIT memory management alternatives (file-based)
- Simple function compilation (arithmetic operations)
- Integration with existing eval.l

### Phase 2: Architecture Integration
- Leverage existing architecture files (arm64-compiler-complete.l, x86-compiler.l)
- Implement multimethod-based code emission
- Support multiple architectures cleanly

### Phase 3: Environment-Based Compilation
- Compile entire environments as units
- Support for closures and cross-environment calls
- Smart compilation triggers based on usage patterns

### Phase 4: Optimization
- Inline caching for method dispatch
- Type specialization
- Profile-guided optimization
- Library caching and reuse

## Usage Examples

### Basic Function Compilation

```lisp
;; Define a function for compilation
(define-compilable fib (n)
  (if (< n 2)
      n
      (+ (fib (- n 1)) 
         (fib (- n 2)))))

;; Trigger compilation
(compile-now 'fib)
;; Generates fib.c, compiles to fib.dylib, loads it

;; Now fib runs as native code
(fib 40)  ; Much faster!
```

### Environment-Based Compilation

```lisp
;; Define an environment (implicit in Maru)
(let ((math-env (make-environment *global-environment*)))
  ;; Define functions in the environment
  (with-environment math-env
    (define (factorial n)
      (if (<= n 1) 1 (* n (factorial (- n 1)))))
    
    (define (fibonacci n)
      (if (< n 2) n (+ (fibonacci (- n 1)) (fibonacci (- n 2)))))
    
    (define (prime? n)
      (let loop ((i 2))
        (cond ((> (* i i) n) #t)
              ((zero? (remainder n i)) #f)
              (else (loop (+ i 1)))))))
  
  ;; Environment gets compiled as a unit when hot
  (fibonacci 30)  ; Triggers compilation after threshold
  
  ;; Now all math functions run native!
  (factorial 100))

;; Explicit compilation
(compile-environment math-env (current-architecture))

;; Save for next session
(save-compiled-environment math-env "math-env")
```

## Benefits of This Approach

1. **No JIT restrictions** - Works on all macOS versions without special entitlements
2. **Leverages existing infrastructure** - Reuses Maru's assembly and C generation
3. **Clean architecture** - Multimethod dispatch keeps code organized
4. **Natural compilation units** - Environments provide logical boundaries
5. **Good performance** - Native code execution with minimal overhead
6. **Debugging support** - Real symbols and standard debugging tools work
7. **Cross-platform** - Same approach works on Linux, BSD, etc.

## Conclusion

This design provides Maru with JIT-like performance through dynamic native code generation and loading, while completely avoiding macOS JIT restrictions. By using environments as compilation units and leveraging Maru's existing code generation infrastructure, we can achieve efficient native execution with a clean, maintainable implementation.