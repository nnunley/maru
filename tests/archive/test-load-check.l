;;; test-load-check.l - Check if asm-arm64.k loads correctly

(println "Testing asm-arm64.k loading...")

(println "Loading asm-arm64.k...")
(require "asm-arm64.k")
(println "asm-arm64.k loaded successfully!")

(println "Testing basic constants...")
(println "X0: " _X0)
(println "X1: " _X1)

(println "Testing existing functions...")
(println "_ARM64_B function: " (type-of _ARM64_B))
(println "_ARM64_BLR function: " (type-of _ARM64_BLR))

(println "Testing _ARM64_BL function...")
(if (defined? '_ARM64_BL)
    (println "_ARM64_BL is defined: " (type-of _ARM64_BL))
  (println "_ARM64_BL is NOT defined"))

(println "Load check complete.")