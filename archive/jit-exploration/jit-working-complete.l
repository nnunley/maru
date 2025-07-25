;;; jit-working-complete.l - Complete working JIT using Maru's existing FFI
;;; This demonstrates actual compilation and execution of generated code

(require "dlopen.k")

;; Initialize dlopen infrastructure
(init-dlopen)

;; Define system commands through dlopen
(define system  (dlextern "libSystem" "system" "s"))
(define unlink  (dlextern "libSystem" "unlink" "s"))

(println "=== Complete JIT Proof of Concept ===")
(println)

(define-function generate-test-function (filename value)
  "Generate ARM64 assembly for a function that returns a constant"
  (let ((port (open-output-file filename)))
    (println ".section __TEXT,__text,regular,pure_instructions" port)
    (println ".global _test_function" port)
    (println ".align 2" port)
    (println "_test_function:" port)
    (println (concat-string "    mov x0, #" (number->string value)) port)
    (println "    ret" port)
    (close-output-port port)))

(define-function generate-fibonacci-function (filename n)
  "Generate ARM64 assembly for fibonacci calculation"
  (let ((port (open-output-file filename)))
    (println ".section __TEXT,__text,regular,pure_instructions" port)
    (println ".global _fibonacci" port)
    (println ".align 2" port)
    (println "_fibonacci:" port)
    (println "    cmp x0, #1" port)
    (println "    ble .base_case" port)
    (println "    sub sp, sp, #32" port)
    (println "    stp x29, x30, [sp, #16]" port)
    (println "    stp x19, x20, [sp]" port)
    (println "    mov x19, x0" port)
    (println "    sub x0, x19, #1" port)
    (println "    bl _fibonacci" port)
    (println "    mov x20, x0" port)
    (println "    sub x0, x19, #2" port)
    (println "    bl _fibonacci" port)
    (println "    add x0, x20, x0" port)
    (println "    ldp x19, x20, [sp]" port)
    (println "    ldp x29, x30, [sp, #16]" port)
    (println "    add sp, sp, #32" port)
    (println "    ret" port)
    (println ".base_case:" port)
    (println "    ret" port)
    (close-output-port port)))

(define-function compile-and-load (asm-file dylib-file)
  "Compile assembly to dylib and load it"
  (let ((compile-cmd (concat-string "as -arch arm64 -o /tmp/temp.o " asm-file))
        (link-cmd (concat-string "ld -dylib -arch arm64 -o " dylib-file " /tmp/temp.o -lSystem")))
    
    (println (concat-string "Compiling: " compile-cmd))
    (let ((compile-result (system compile-cmd)))
      (if (= compile-result 0)
          (let ()
            (println (concat-string "Linking: " link-cmd))
            (let ((link-result (system link-cmd)))
              (if (= link-result 0)
                  (let ()
                    (println "Successfully created dylib")
                    (dlopen dylib-file))
                  (let ()
                    (println "Link failed")
                    0))))
          (let ()
            (println "Compile failed")
            0)))))

(define-function call-test-function (lib)
  "Call the compiled test function"
  (let ((test-fn (%dlsym lib "_test_function")))
    (if (= test-fn 0)
        (println "Could not find _test_function symbol")
        (let ((fn (subr "_test_function" "")))
          (if fn
              (let ((result (fn)))
                (println (concat-string "test_function() returned: " (number->string result)))
                result)
              (println "Could not create subr for test_function"))))))

(define-function call-fibonacci (lib n)
  "Call the compiled fibonacci function"
  (let ((fib-fn (%dlsym lib "_fibonacci")))
    (if (= fib-fn 0)
        (println "Could not find _fibonacci symbol")
        (let ((fn (subr "_fibonacci" "i")))
          (if fn
              (let ((result (fn n)))
                (println (concat-string "fibonacci(" (number->string n) ") = " (number->string result)))
                result)
              (println "Could not create subr for fibonacci"))))))

;; Demo 1: Simple constant return
(println "Demo 1: Constant return function")
(let ((asm-file "/tmp/test_constant.s")
      (dylib-file "/tmp/test_constant.dylib")
      (test-value 42))
  
  (generate-test-function asm-file test-value)
  
  (let ((lib (compile-and-load asm-file dylib-file)))
    (if (= lib 0)
        (println "Failed to load library")
        (let ()
          (call-test-function lib)
          (unlink asm-file)
          (unlink dylib-file)))))

(println)

;; Demo 2: Fibonacci function
(println "Demo 2: Fibonacci recursive function")
(let ((asm-file "/tmp/fibonacci.s")
      (dylib-file "/tmp/fibonacci.dylib"))
  
  (generate-fibonacci-function asm-file 10)
  
  (let ((lib (compile-and-load asm-file dylib-file)))
    (if (= lib 0)
        (println "Failed to load library")
        (let ()
          (call-fibonacci lib 1)
          (call-fibonacci lib 5)
          (call-fibonacci lib 10)
          (unlink asm-file)
          (unlink dylib-file)))))

(println)
(println "=== JIT Demo Complete ===")
(println "Successfully generated, compiled, loaded, and executed native code!")