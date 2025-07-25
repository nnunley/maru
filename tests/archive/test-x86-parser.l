;;; test-x86-parser.l - Test x86 assembly parser

(require "ir.k")
(require "text-parser.l")
(require "x86.g.l")

(println "=== Testing x86 Assembly Parser ===")

;; Test assembly strings
(define test-programs '(
  "mov %rax, %rbx"
  "mov $42, %rcx"  
  "mov %rdx, %rax
   mov $100, %rbx"
))

(define-function test-x86-parse (source)
  "Test parsing x86 assembly source"
  (println "\nTesting: " source)
  (let* ((parser (text-parser-for-on <x86> source))
         (result (if ($program parser) (<x86>-result parser) ())))
    (if result
        (let ()
          (println "Parsed successfully:")
          (list-do insn result
            (println "  " insn)))
      (println "Parse failed"))))

;; Test each program
(list-do program test-programs
  (test-x86-parse program))

(println "\n=== x86 Assembly Parser Test Complete ===")