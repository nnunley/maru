;;; test-jit-poc.l - Test the JIT proof of concept

;; Load the JIT components
(load "jit-poc.l")
(load "mach-o-writer.l")

;; Compile the C runtime support
(println "Compiling JIT runtime support...")
(let ((compile-result (shell-command "cc -c -o jit-runtime.o jit-runtime.c")))
  (if (!= compile-result 0)
      (error "Failed to compile jit-runtime.c")))

;; Link it into eval (simplified - in real implementation would be part of build)
(println "Note: For full test, link jit-runtime.o with your Maru build")

(println "\n=== Testing Basic JIT Compilation ===")
(test-jit)

(println "\n=== Testing Arithmetic JIT ===")
(test-jit-arithmetic)

(println "\n=== Testing Direct Mach-O Generation ===")
;; This will likely fail without proper Mach-O implementation
;; but demonstrates the concept
(catch 'error
  (lambda () (test-direct-macho))
  (lambda (err) (println (concat-string "Expected error in direct Mach-O: " err))))

(println "\n=== Performance Comparison ===")

;; Time the compilation + execution
(define-function time-operation (name fn)
  (let ((start (current-milliseconds)))
    (fn)
    (let ((end (current-milliseconds)))
      (println (concat-string name ": " (number->string (- end start)) "ms")))))

;; Compile and time
(println "\nCompilation timing:")
(time-operation "Compile constant function"
  (lambda () (compile-constant-function "perf_test" 12345)))

(time-operation "Load and execute"
  (lambda ()
    (let* ((handle (dlopen-prim (concat-string *jit-temp-dir* "/perf_test.dylib")))
           (fn (dlsym-prim handle "_maru_compiled_fn"))
           (result (call-compiled-function fn)))
      (if (!= result 12345)
          (error "Performance test failed")))))

(println "\nJIT PoC testing complete!")