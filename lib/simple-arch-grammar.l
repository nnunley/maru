;;; simple-arch-grammar.l - Simplified Architecture Grammar Generator
;;;
;;; Generate basic PEG grammars from architecture specifications

(require "arch-spec.l")

;; Simple grammar generation (working version)

(define-function generate-simple-register-rules (registers)
  "Generate PEG rules for registers"
  (let ((rules ()))
    ;; Generate individual register rules
    (list-do reg registers
      (let ((name (<arch-register>-name reg)))
        (push rules (list 'rule (concat-symbol '% name)
                         (list 'literal (concat-string "%" (symbol->string name)))
                         (list 'action (list 'quote name))))))
    
    ;; Generate combined register rule  
    (let ((register-alternatives ()))
      (list-do reg registers
        (push register-alternatives (concat-symbol '% (<arch-register>-name reg))))
      (push rules (list 'rule 'register
                       (cons 'choice register-alternatives)
                       (list 'action 'self))))
    rules))

(define-function generate-simple-instruction-rules (instructions)
  "Generate simple instruction rules"
  (let ((rules ())
        (instruction-alternatives ()))
    
    ;; For now, just generate placeholder rules for each instruction
    (list-do insn instructions
      (let ((name (<arch-instruction>-name insn))
            (syntax (<arch-instruction>-syntax insn)))
        ;; Simple rule that matches the instruction name
        (push rules (list 'rule name
                         (list 'literal (symbol->string (car syntax)))
                         (list 'action (list 'quote name))))
        (push instruction-alternatives name)))
    
    ;; Combined instruction rule
    (push rules (list 'rule 'instruction
                     (cons 'choice instruction-alternatives)
                     (list 'action 'self)))
    rules))

(define-function generate-simple-basic-rules ()
  "Generate basic parsing rules"
  (list
    ;; Program structure
    '(rule program (star instruction) (action self))
    '(rule _ (star (char-class " \t\n")) (action ()))
    ))

(define-function generate-simple-grammar (architecture)
  "Generate a simple working grammar"
  (let* ((name (<architecture>-name architecture))
         (registers (<architecture>-registers architecture))
         (instructions (<architecture>-instructions architecture))
         (grammar-name (concat-symbol name '-simple)))
    
    (let ((all-rules ()))
      ;; Combine rules
      (set all-rules (concat-list all-rules (generate-simple-basic-rules)))
      (set all-rules (concat-list all-rules (generate-simple-register-rules registers)))
      (set all-rules (concat-list all-rules (generate-simple-instruction-rules instructions)))
      
      ;; Return grammar structure
      (list 'grammar grammar-name 'program all-rules))))

;; Simple output function
(define-function output-simple-grammar (grammar)
  "Output grammar in a readable format"
  (let ((name (cadr grammar))
        (start (caddr grammar))
        (rules (cadddr grammar)))
    
    (println "# Generated grammar: " name)
    (println "# Start rule: " start)
    (println)
    
    (list-do rule rules
      (let ((rule-name (cadr rule))
            (rule-body (caddr rule)))
        (println rule-name " = " rule-body " ;")))))

;; Test the simple generator
(println "=== Testing Simple Grammar Generator ===")
(let ((simple-grammar (generate-simple-grammar test-arch)))
  (println "\nGenerated grammar structure:")
  (output-simple-grammar simple-grammar))

(println "\n=== Simple Grammar Generator Test Complete ===")