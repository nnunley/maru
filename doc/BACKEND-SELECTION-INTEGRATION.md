# Backend Selection Integration for Maru

## Summary

This document describes how to integrate smart backend selection into Maru's emit.l system, enabling environment variable control and automatic platform detection.

## Problem

Currently, eval2.c is generated using the assembly backend by default, which produces ARM64 assembly on Apple Silicon instead of C code. The user requires:

1. Environment variable support (MARU_EMIT_BACKEND) for backend selection
2. Platform-specific default backend selection using osdefs.k
3. Preservation of command line semantics for eval2

## Solution

### 1. Add Backend Selection to emit.l

Add the following code at the end of `core/compiler/emit.l`:

```lisp
;; Smart backend selection with environment override and platform defaults
(define-function select-emit-backend ()
  "Select emit backend based on environment or platform"
  ;; Check for extern function availability
  (if (and (defined? 'extern) (extern 'getenv))
      ;; We have extern support - check environment
      (let* ((getenv (extern 'getenv))
             (env-backend (getenv "MARU_EMIT_BACKEND")))
        (cond
          ;; Environment variable override takes precedence
          (env-backend
            (cond
              ((string= env-backend "c")
               (println "; Using C backend (MARU_EMIT_BACKEND=c)")
               (use-c-backend))
              ((string= env-backend "arm64")
               (println "; Using ARM64 backend (MARU_EMIT_BACKEND=arm64)")
               (use-arm64-backend))
              ((string= env-backend "x86")
               (println "; Using x86 backend (MARU_EMIT_BACKEND=x86)")
               ;; x86 is the default assembly backend
               (set *emit-backend* 'asm)
               (set *c-backend-active* ())
               (set *arm64-backend-active* ())
               (if (defined? '*ir-backend-active*) (set *ir-backend-active* ())))
              ((string= env-backend "ir")
               (println "; Using IR backend (MARU_EMIT_BACKEND=ir)")
               (use-ir-backend))
              (else
               (println "; Warning: Unknown backend '" env-backend "', using platform default")
               (select-platform-default-backend))))
          
          ;; No environment override - use platform detection
          (else
            (select-platform-default-backend))))
      
      ;; No extern support - use platform detection
      (select-platform-default-backend)))

;; Platform-specific default backend selection using osdefs.k
(define-function select-platform-default-backend ()
  "Select default backend based on platform detection from osdefs.k"
  (cond
    ;; ARM64 platforms (Apple Silicon, etc.)
    ((or (defined? '__arm64__) (defined? '__aarch64__))
     (println "; Using ARM64 backend (platform: arm64/aarch64)")
     (use-arm64-backend))
    
    ;; x86-64 platforms
    ((defined? '__x86_64__)
     (println "; Using x86-64 assembly backend (platform: x86_64)")
     (set *emit-backend* 'asm)
     (set *c-backend-active* ())
     (set *arm64-backend-active* ())
     (if (defined? '*ir-backend-active*) (set *ir-backend-active* ())))
    
    ;; 32-bit x86
    ((defined? '__i386__)
     (println "; Using x86 assembly backend (platform: i386)")
     (set *emit-backend* 'asm)
     (set *c-backend-active* ())
     (set *arm64-backend-active* ())
     (if (defined? '*ir-backend-active*) (set *ir-backend-active* ())))
    
    ;; Other platforms fallback to C
    (else
     (println "; Using C backend as fallback")
     (use-c-backend))))

;; Auto-select backend on load
(select-emit-backend)
```

### 2. Update Makefile

Modify the eval2.c generation rule in the Makefile:

```makefile
eval2.c : core/compiler/emit.l core/eval.l eval
	@echo "Generating eval2.c with C backend..."
	MARU_EMIT_BACKEND=c ./eval core/compiler/emit.l core/eval.l > eval2.c
```

### 3. Load C Backend

If using emit-c.l as a separate C backend, add this after the backend selection:

```lisp
;; Load C backend if selected
(if *c-backend-active*
    (load "emit-c.l"))
```

## Usage

### Environment Variable Control

```bash
# Force C backend
MARU_EMIT_BACKEND=c ./eval core/compiler/emit.l code.l

# Force ARM64 backend
MARU_EMIT_BACKEND=arm64 ./eval core/compiler/emit.l code.l

# Force x86 backend
MARU_EMIT_BACKEND=x86 ./eval core/compiler/emit.l code.l

# Use platform default
./eval core/compiler/emit.l code.l
```

### Platform Defaults

- **ARM64/AArch64**: Uses ARM64 backend
- **x86-64**: Uses x86 assembly backend
- **x86 (32-bit)**: Uses x86 assembly backend
- **Other platforms**: Uses C backend as fallback

## Command Line Semantics

The eval.l file already contains the complete command line processing infrastructure:

```lisp
(define-function main (argc argv)
  ;; Process -v, -O flags
  ;; Build *arguments* list
  ;; Implement boot sequence
  ...)
```

This ensures that eval2 (whether generated as C or assembly) maintains identical command line semantics to the original eval.c.

## Testing

1. Test environment variable override:
```bash
MARU_EMIT_BACKEND=c make eval2.c
cat eval2.c | head -20  # Should show C code, not assembly
```

2. Test platform detection:
```bash
unset MARU_EMIT_BACKEND
./eval core/compiler/emit.l test.l  # Should use platform-appropriate backend
```

3. Test eval2 command line compatibility:
```bash
./eval2 -v  # Should show version
./eval2 file1.l file2.l  # Should process files in order
```

## Benefits

1. **Flexibility**: Users can choose backend via environment variable
2. **Platform Optimization**: Automatically selects optimal backend for platform
3. **Backward Compatibility**: Preserves existing behavior when no override
4. **Command Line Parity**: eval2 maintains identical semantics to eval.c
5. **Simple Integration**: Minimal changes to existing codebase

## Implementation Status

- ✅ Backend selection logic designed
- ✅ Environment variable support implemented
- ✅ Platform detection integrated with osdefs.k
- ✅ Makefile updated to use MARU_EMIT_BACKEND=c for eval2.c
- ✅ Backend selection code integrated into emit.l
- ✅ Command line semantics preserved via eval.l
- ✅ Test script created for verification