;;; test-simple-grammar.l - Simple grammar generator test

(require "arch-spec.l")

(println "=== Testing Simple Grammar Generation ===")

;; Test basic register rule generation
(define-function simple-register-rule (reg)
  "Generate a simple register rule"
  (let ((name (<arch-register>-name reg))
        (encoding (<arch-register>-encoding reg)))
    (list 'rule (concat-symbol '% name)
          (list 'literal (concat-string "%" (symbol->string name)))
          (list 'action (list 'quote name)))))

;; Test with one register
(let ((test-reg (car (<architecture>-registers test-arch))))
  (println "Testing register: " test-reg)
  (let ((rule (simple-register-rule test-reg)))
    (println "Generated rule: " rule)))

(println "\n=== Simple Grammar Test Complete ===")