;;; Test the emit backend switching functionality

;; First, let's check if the backend variables are defined
(if (defined? '*emit-backend* *globals*)
    (println "Current emit backend: " *emit-backend*)
    (println "ERROR: *emit-backend* not defined"))

(if (defined? '*c-generation-mode* *globals*)
    (println "Current C generation mode: " *c-generation-mode*)
    (println "ERROR: *c-generation-mode* not defined"))

;; Check if the backend switching functions exist
(if (defined? 'use-asm-backend *globals*)
    (println "use-asm-backend is available")
    (println "ERROR: use-asm-backend not defined"))

(if (defined? 'use-c-simple-backend *globals*)
    (println "use-c-simple-backend is available")
    (println "ERROR: use-c-simple-backend not defined"))

(if (defined? 'use-c-threaded-backend *globals*)
    (println "use-c-threaded-backend is available")
    (println "ERROR: use-c-threaded-backend not defined"))

;; Now let's try a simple expression
(define test-value 42)
(println "Test value defined: " test-value)