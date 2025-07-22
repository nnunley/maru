;;; test-arm64-backend.l - Test the new define-emit ARM64 backend

(load "core/eval.l")
(load "core/compiler/emit.l")
(load "core/compiler/ir-gen-arm64.k")

(println ";;; --- Activating ARM64 Backend ---")
(set *emit-backend* 'arm64)

(println ";;; --- Defining a simple function ---")
(compile-begin)
(define (main) 42)

(println ";;; --- Compiling to ARM64 Assembly ---")
(compile-end)