;;; Minimal emit test

(require "boot.l")
(require "emit.l")
(require "core/compiler/emit-c.l")

(println "Testing basic emit...")
(emit LOAD LI32 42)
(println "Emit completed.")