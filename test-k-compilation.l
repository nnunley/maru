;;; test-k-compilation.l - Test .k file compilation properly

(println "Testing .k file compilation in correct order...")

;; Load dependencies in the right order
(println "1. Loading boot.l first...")
(load "boot.l")

(println "2. Loading scope.k...")
(load "core/scope.k")

(println "3. Loading trie.k...")
(load "trie.k")

(println "4. Loading ir.k...")
(load "core/compiler/ir.k")

(println "5. Loading maru.k...")
(load "core/maru.k")

(println "6. Loading eval-multimethod.k...")
(load "core/eval-multimethod.k")

(println "7. Testing the multi-method evaluator...")
(test-eval)

(println "\nSUCCESS: .k files compiled and executed directly!")