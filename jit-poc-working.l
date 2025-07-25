;;; jit-poc-working.l - Working JIT PoC using Maru's existing FFI
;;;
;;; This version uses actual extern functions available in eval

;; Load emit.l to get extern function
(load "core/compiler/emit.l")

(define *jit-temp-dir* "/tmp/maru-jit")

;; Define external functions we need
(define dlopen (extern 'dlopen))
(define dlsym (extern 'dlsym))
(define dlclose (extern 'dlclose))
(define dlerror (extern 'dlerror))
(define system (extern 'system))

;; dlopen constants
(define RTLD_NOW 2)
(define RTLD_LAZY 1)
(define RTLD_LOCAL 0)

;; Helper to call system and check result
(define-function shell-command (cmd)
  (println (concat-string "Executing: " cmd))
  (let ((result (system cmd)))
    (if (!= result 0)
        (error (concat-string "Command failed: " cmd)))
    result))

;; Create directory
(shell-command (concat-string "mkdir -p " *jit-temp-dir*))

;; Generate assembly file
(define-function generate-return-42-asm ()
  (let ((filename (concat-string *jit-temp-dir* "/return42.s")))
    (with-output-to-file filename
      (lambda ()
        (println ".section __TEXT,__text,regular,pure_instructions")
        (println ".global _return_42")
        (println ".align 2")
        (println "_return_42:")
        (println "    mov x0, #42")
        (println "    ret")))
    filename))

;; Compile to dylib
(define-function compile-to-dylib (asm-file)
  (let* ((obj-file (concat-string *jit-temp-dir* "/return42.o"))
         (dylib-file (concat-string *jit-temp-dir* "/return42.dylib")))
    
    ;; Assemble
    (shell-command (concat-string "as -arch arm64 -o " obj-file " " asm-file))
    
    ;; Link
    (shell-command (concat-string 
      "ld -arch arm64 -dylib -o " dylib-file " " obj-file 
      " -lSystem -syslibroot `xcrun -sdk macosx --show-sdk-path` "
      "-platform_version macos 11.0 11.0"))
    
    dylib-file))

;; Test the JIT
(define-function test-jit-with-real-dlopen ()
  (println "=== Working Maru JIT PoC ===")
  (println)
  
  ;; Generate assembly
  (println "1. Generating assembly...")
  (let ((asm-file (generate-return-42-asm)))
    (println (concat-string "   Generated: " asm-file)))
  
  ;; Compile
  (println "\n2. Compiling to dynamic library...")
  (let ((dylib (compile-to-dylib (concat-string *jit-temp-dir* "/return42.s"))))
    (println (concat-string "   Created: " dylib))
    
    ;; Load with dlopen
    (println "\n3. Loading with dlopen...")
    (let ((handle (dlopen dylib RTLD_NOW)))
      (if handle
          (let ()
            (println "   Library loaded successfully!")
            
            ;; Find symbol
            (println "\n4. Finding symbol with dlsym...")
            (let ((fn-ptr (dlsym handle "_return_42")))
              (if fn-ptr
                  (let ()
                    (println "   Found function _return_42")
                    (println "\n5. Function pointer obtained!")
                    (println "   (Would call function here if we had proper FFI)")
                    
                    ;; Clean up
                    (dlclose handle)
                    (println "\n✓ SUCCESS: JIT compilation pipeline works!"))
                  (println "   ERROR: Could not find symbol"))))
          (let ()
            (println "   ERROR: dlopen failed")
            (let ((err (dlerror)))
              (if err (println (concat-string "   Error: " err)))))))))

;; Run the test
(test-jit-with-real-dlopen)

;; Show what a complete implementation would look like
(println "\n=== Complete Implementation Would Include ===")
(println "1. FFI function caller:")
(println "   (define-alien call-function")
(println "     \"long call_fn(void* fn) { return ((long(*)())fn)(); }\")")
(println)
(println "2. Then we could actually execute:")
(println "   (let ((result (call-function fn-ptr)))")
(println "     (println (concat-string \"Result: \" (format \"%d\" result))))")
(println)
(println "3. Full multimethod dispatch for different IR nodes")
(println "4. Direct Mach-O generation to skip linker")
(println "5. Environment-based compilation units")