;;; Minimal emit test

(require "boot.l")
(require "emit.l")
(require "emit-c.l")

(println "Testing basic emit...")
(emit LOAD LI32 42)
(println "Emit completed.")