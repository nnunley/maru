;;; Debug test for C code generation

(define EMIT_BACKEND 'c)
(println "About to load emit.l")
(require "emit.l")
(println "emit.l loaded")

(if (defined? 'compile-begin)
    (println "compile-begin is defined")
    (println "ERROR: compile-begin is NOT defined"))

(if (defined? '*emit-backend*)
    (println "*emit-backend* = " *emit-backend*)
    (println "ERROR: *emit-backend* is NOT defined"))