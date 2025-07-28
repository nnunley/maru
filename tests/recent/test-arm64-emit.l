;; Test ARM64 emit with port streams
(require "core/compiler/emit.l")
(require "core/compiler/emit-arm64.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

;; Emit some ARM64 instructions
(emit TEXT)
(emit GLOBAL (LABEL 'test_function))
(emit DEFLABEL (LABEL 'test_function))
(emit ENTER 16)
(emit LOAD (LI32 42))
(emit STORE (TI32 8))
(emit LOAD (TI32 8))
(emit ADD (TI32 8))
(emit LEAVE 16)

(emit DATA)
(emit DEFLABEL (LABEL 'test_string))
(emit ASCIZ "Hello, ARM64!\n")

;; Get the output
(define output (port-contents test-port))
(println "Generated ARM64 assembly:")
(println "------------------------")
(print output)
(println "------------------------")

;; Basic validation
(if (and (string-search output ".text")
         (string-search output ".globl")
         (string-search output "stp")
         (string-search output "mov")
         (string-search output ".asciz"))
    (println "✓ ARM64 emit test PASSED")
    (println "✗ ARM64 emit test FAILED"))