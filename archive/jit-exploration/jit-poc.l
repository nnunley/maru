;;; jit-poc.l - Proof of concept for Maru JIT using dlopen
;;;
;;; This demonstrates:
;;; 1. Generating native code using Maru's existing infrastructure
;;; 2. Creating a minimal dylib
;;; 3. Loading and executing via dlopen

(define *jit-temp-dir* "/tmp/maru-jit")

;; We'll need to manually ensure the temp directory exists
;; In a real implementation, we'd use mkdir() via FFI

;;; Simple code generation for ARM64
;;; For PoC, we'll generate a function that returns a constant

(define-function emit-arm64-return-constant (value port)
  "Emit ARM64 code to return a constant value"
  ;; mov x0, #value
  ;; ret
  (println ".global _maru_compiled_fn" port)
  (println ".align 2" port)
  (println "_maru_compiled_fn:" port)
  (println (concat-string "    mov x0, #" (number->string value)) port)
  (println "    ret" port))

(define-function emit-x64-return-constant (value port)
  "Emit x64 code to return a constant value"
  ;; mov rax, value
  ;; ret
  (println ".global _maru_compiled_fn" port)
  (println "_maru_compiled_fn:" port)
  (println (concat-string "    movq $" (number->string value) ", %rax") port)
  (println "    ret" port))

;;; System interface
(define system (extern 'system))

(define-function shell-command (cmd)
  "Execute a shell command"
  (system cmd))

;;; Architecture detection
(define-function get-current-arch ()
  ;; For now, we'll assume ARM64 on macOS
  ;; In a real implementation, we'd check at compile time
  'arm64)

;;; Compile a simple function
(define-function compile-constant-function (name value)
  "Compile a function that returns a constant value"
  (let* ((arch (get-current-arch))
         (asm-file (concat-string *jit-temp-dir* "/" name ".s"))
         (obj-file (concat-string *jit-temp-dir* "/" name ".o"))
         (dylib-file (concat-string *jit-temp-dir* "/" name ".dylib")))
    
    ;; Generate assembly
    (with-output-to-file asm-file
      (lambda ()
        (case arch
          ((arm64) (emit-arm64-return-constant value (current-output-port)))
          ((x64) (emit-x64-return-constant value (current-output-port)))
          (else (error "Unsupported architecture")))))
    
    ;; Assemble
    (let ((as-result (shell-command (concat-string "as -o " obj-file " " asm-file))))
      (if (!= as-result 0)
          (error "Assembly failed")))
    
    ;; Link to dylib
    (let ((ld-cmd (if (= arch 'arm64)
                      (concat-string "ld -dylib -o " dylib-file " " obj-file 
                                     " -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -arch arm64")
                      (concat-string "ld -dylib -o " dylib-file " " obj-file 
                                     " -lSystem -L/usr/lib"))))
      (let ((ld-result (shell-command ld-cmd)))
        (if (!= ld-result 0)
            (error "Linking failed"))))
    
    ;; Return path to dylib
    dylib-file))

;;; Runtime loading and execution

;; C wrapper for dlopen/dlsym/dlclose
(define-alien dlopen-prim
  "void* dlopen_wrapper(char* path) {
     void* handle = dlopen(path, RTLD_NOW);
     if (!handle) {
       fprintf(stderr, \"dlopen error: %s\\n\", dlerror());
     }
     return handle;
   }")

(define-alien dlsym-prim
  "void* dlsym_wrapper(void* handle, char* symbol) {
     void* sym = dlsym(handle, symbol);
     if (!sym) {
       fprintf(stderr, \"dlsym error: %s\\n\", dlerror());
     }
     return sym;
   }")

(define-alien dlclose-prim
  "int dlclose_wrapper(void* handle) {
     return dlclose(handle);
   }")

(define-alien call-compiled-function
  "long call_fn(void* fn) {
     return ((long(*)())fn)();
   }")

;;; High-level interface

(define-function jit-compile-and-load (name value)
  "Compile a function and load it"
  (let* ((dylib-path (compile-constant-function name value))
         (handle (dlopen-prim dylib-path)))
    (if (not handle)
        (error "Failed to load compiled library"))
    
    (let ((fn-ptr (dlsym-prim handle "_maru_compiled_fn")))
      (if (not fn-ptr)
          (error "Failed to find compiled function"))
      
      ;; Return a closure that calls the compiled function
      (lambda ()
        (call-compiled-function fn-ptr)))))

;;; Test the system

(define-function test-jit ()
  (println "Testing Maru JIT proof-of-concept...")
  
  ;; Compile a function that returns 42
  (let ((compiled-fn (jit-compile-and-load "test_42" 42)))
    (println "Compiled function that returns 42")
    (let ((result (compiled-fn)))
      (println (concat-string "Result: " (number->string result)))
      (if (= result 42)
          (println "SUCCESS: JIT compilation works!")
          (error "FAILED: Got wrong result"))))
  
  ;; Compile another function that returns 1337
  (let ((compiled-fn (jit-compile-and-load "test_1337" 1337)))
    (println "\nCompiled function that returns 1337")
    (let ((result (compiled-fn)))
      (println (concat-string "Result: " (number->string result)))
      (if (= result 1337)
          (println "SUCCESS: Multiple compilations work!")
          (error "FAILED: Got wrong result")))))

;;; More complex example: compile arithmetic expression

(define-function emit-arm64-add (a b port)
  "Emit ARM64 code to return a + b"
  (println ".global _maru_compiled_fn" port)
  (println ".align 2" port)
  (println "_maru_compiled_fn:" port)
  (println (concat-string "    mov x0, #" (number->string a)) port)
  (println (concat-string "    mov x1, #" (number->string b)) port)
  (println "    add x0, x0, x1" port)
  (println "    ret" port))

(define-function compile-add-function (name a b)
  "Compile a function that returns a + b"
  (let* ((arch (get-current-arch))
         (asm-file (concat-string *jit-temp-dir* "/" name ".s"))
         (obj-file (concat-string *jit-temp-dir* "/" name ".o"))
         (dylib-file (concat-string *jit-temp-dir* "/" name ".dylib")))
    
    ;; Generate assembly
    (with-output-to-file asm-file
      (lambda ()
        (case arch
          ((arm64) (emit-arm64-add a b (current-output-port)))
          (else (error "Add not implemented for this arch yet")))))
    
    ;; Assemble and link (same as before)
    (shell-command (concat-string "as -o " obj-file " " asm-file))
    (shell-command (concat-string "ld -dylib -o " dylib-file " " obj-file 
                                  " -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` -arch arm64"))
    
    dylib-file))

(define-function test-jit-arithmetic ()
  (println "\nTesting JIT arithmetic compilation...")
  
  ;; Compile 10 + 32
  (let* ((dylib-path (compile-add-function "add_10_32" 10 32))
         (handle (dlopen-prim dylib-path))
         (fn-ptr (dlsym-prim handle "_maru_compiled_fn")))
    (let ((result (call-compiled-function fn-ptr)))
      (println (concat-string "10 + 32 = " (number->string result)))
      (if (= result 42)
          (println "SUCCESS: Arithmetic JIT works!")
          (error "FAILED: Arithmetic gave wrong result")))))