;;; debug-x86-parser.l - Debug x86 assembly parser

(require "text-parser.l")
(require "x86.g.l")

(println "=== Debugging x86 Parser ===")

;; Test individual components
(define-function test-component (parser rule-name input)
  "Test a specific parsing rule"
  (println "\nTesting " rule-name " with: '" input "'")
  (let* ((parser-obj (text-parser-for-on <x86> input))
         (rule-func (eval (concat-symbol '$ rule-name)))
         (result (rule-func parser-obj)))
    (if result
        (println "  SUCCESS: " (<x86>-result parser-obj))
      (println "  FAILED"))))

;; Test basic components
(test-component <x86> 'rax "%rax")
(test-component <x86> 'register "%rax")
(test-component <x86> 'immediate "$42")

;; Test instruction parsing
(test-component <x86> 'mov_reg_reg "mov %rax, %rbx")
(test-component <x86> 'instruction "mov %rax, %rbx")

(println "\n=== x86 Parser Debug Complete ===")