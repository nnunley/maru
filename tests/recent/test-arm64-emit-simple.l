;; Simple test for ARM64 emit with port streams
(require "core/compiler/emit.l")
(require "core/compiler/emit-arm64.l")

;; Set up a string port to capture output
(define test-port (string-port))
(set *emit-output-port* test-port)

;; Emit some ARM64 instructions
(emit TEXT)
(emit GLOBAL (LABEL 'test_function))
(emit DEFLABEL (LABEL 'test_function))
(emit COMMENT (list "Test function"))
(emit ENTER 16)
(emit LOAD (LI32 42))
(emit NEG)
(emit LEAVE 16)

(emit DATA)
(emit DEFLABEL (LABEL 'test_string))
(emit ASCIZ "Hello, ARM64!")

;; Get the output
(define output (port-contents test-port))
(println "Generated ARM64 assembly:")
(println "------------------------")
(print output)
(println "------------------------")
(println "Test completed successfully!")