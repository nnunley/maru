;;; test-arch-spec.l - Test architecture specification parser

(require "arch-spec.l")

(println "=== Testing Architecture Specification Parser ===")

;; Test parsing the built-in example
(println "\n1. Testing built-in x86-64 specification...")
(println "Test architecture: " test-arch)

;; Test individual components
(println "\n2. Testing register parsing...")
(let ((regs (<architecture>-registers test-arch)))
  (list-do reg regs
    (println "  " reg)))

(println "\n3. Testing instruction parsing...")
(let ((insns (<architecture>-instructions test-arch)))
  (list-do insn insns
    (println "  " insn)))

(println "\n4. Testing addressing mode parsing...")
(let ((modes (<architecture>-addressing-modes test-arch)))
  (list-do mode modes
    (println "  " mode)))

(println "\n=== Architecture Specification Parser Test Complete ===")