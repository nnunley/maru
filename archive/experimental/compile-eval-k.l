;;; compile-eval-k.l - Compile eval.k through the IR system
;;;
;;; This loads the necessary infrastructure and compiles eval.k

(load "boot.l")

(println "=== Compiling eval.k ===")
(println)

;; First, we need the IR infrastructure
(println "Loading IR system...")
(load "core/compiler/ir.k")
(println "  ir.k loaded")

;; Load the maru.k compiler
(println "Loading maru.k compiler...")
(load "core/maru.k")
(println "  maru.k loaded")

;; Now compile eval.k
(println)
(println "Compiling eval.k...")
(println "  Loading eval.k into compilation namespace...")

;; The compilation will happen when we load eval.k
;; because it has compile-begin/compile-end
(load "core/eval.k")

(println)
(println "=== Compilation complete ===")
(println)

;; If test-eval was compiled, we can run it
(if (defined? 'test-eval)
    (let ()
      (println "Running test-eval...")
      (test-eval))
  (println "Note: test-eval function not found (may need proper IR code generation)"))