;;; generate-arch-grammar.l - Architecture Grammar Generator
;;;
;;; Converts architecture specifications to PEG assembly grammars

(require "arch-spec.l")

;; Utility functions - simplified for now
(define-function list-append (list item)
  "Append item to end of list"
  (if list
      (cons (car list) (list-append (cdr list) item))
    (list item)))

;; Grammar generation functions

(define-function generate-register-rules (registers)
  "Generate PEG rules for register matching"
  (let ((rules ()))
    ;; Generate individual register rules
    (list-do reg registers
      (let ((name (<arch-register>-name reg)))
        (push rules (list 'rule (concat-symbol '% name) 
                         (list 'literal (concat-string "%" (symbol->string name)))
                         (list 'action (list 'quote name))))))
    
    ;; Generate combined register rule
    (let ((register-alternatives 
           (map (lambda (reg) (concat-symbol '% (<arch-register>-name reg))) 
                registers)))
      (push rules (list 'rule 'register 
                       (cons 'choice register-alternatives)
                       (list 'action 'self))))
    
    rules))

(define-function generate-instruction-syntax-rule (instruction)
  "Generate PEG rule for instruction syntax"
  (let* ((name (<arch-instruction>-name instruction))
         (syntax (<arch-instruction>-syntax instruction))
         (ir-form (<arch-instruction>-ir-form instruction)))
    
    ;; Convert syntax pattern to PEG rule
    ;; For now, handle simple patterns like ("mov" register "," register)
    (let ((peg-sequence ())
          (bindings ())
          (binding-counter 0))
      
      ;; Process each element in syntax
      (list-do element syntax
        (cond
          ((string? element)
           ;; Literal string
           (push peg-sequence (list 'literal element)))
          ((= element 'register)
           ;; Register operand - create binding
           (let ((binding-name (concat-symbol 'arg (incr binding-counter))))
             (push bindings (cons binding-name 'register))
             (push peg-sequence (list 'bind binding-name 'register))))
          ((= element 'immediate)
           ;; Immediate operand - create binding
           (let ((binding-name (concat-symbol 'arg (incr binding-counter))))
             (push bindings (cons binding-name 'immediate))
             (push peg-sequence (list 'bind binding-name 'immediate))))
          ((string? element)
           ;; Comma, whitespace, etc.
           (push peg-sequence (list 'literal element)))
          (else
           (error "Unknown syntax element: " element))))
      
      ;; Generate the complete rule
      (list 'rule name 
            (cons 'sequence peg-sequence)
            (list 'action (list 'quote ir-form))))))

(define-function generate-instruction-rules (instructions)
  "Generate PEG rules for all instructions"
  (let ((rules ())
        (instruction-alternatives ()))
    
    ;; Generate individual instruction rules
    (list-do insn instructions
      (let ((rule (generate-instruction-syntax-rule insn)))
        (push rules rule)
        (push instruction-alternatives (<arch-instruction>-name insn))))
    
    ;; Generate combined instruction rule
    (push rules (list 'rule 'instruction
                     (cons 'choice instruction-alternatives)
                     (list 'action 'self)))
    
    rules))

(define-function generate-basic-rules ()
  "Generate basic PEG rules for assembly parsing"
  (list
    ;; Whitespace and comments
    '(rule whitespace (choice (char-class " \t") eol) (action ()))
    '(rule _ (star whitespace) (action ()))
    
    ;; Numbers and immediates  
    '(rule digit (char-class "0-9") (action self))
    '(rule integer (plus digit) (action (string->number (list->string self))))
    '(rule immediate (sequence "$" integer) (action (cadr self)))
    
    ;; Basic program structure
    '(rule eol (choice "\n" "\r") (action ()))
    '(rule program (star (sequence _ instruction _ eol)) (action (filter self)))
    ))

(define-function generate-assembly-grammar (architecture)
  "Generate complete PEG grammar for architecture"
  (let* ((name (<architecture>-name architecture))
         (registers (<architecture>-registers architecture))
         (instructions (<architecture>-instructions architecture))
         (grammar-name (concat-symbol name '-assembly)))
    
    ;; Combine all rules
    (let ((all-rules ()))
      ;; Add basic rules
      (set all-rules (concat-list all-rules (generate-basic-rules)))
      
      ;; Add register rules
      (set all-rules (concat-list all-rules (generate-register-rules registers)))
      
      ;; Add instruction rules  
      (set all-rules (concat-list all-rules (generate-instruction-rules instructions)))
      
      ;; Create complete grammar
      (list 'grammar grammar-name 'program all-rules))))

;; Grammar output functions

(define-function output-peg-expression (expr)
  "Output PEG expression"
  (cond
    ((symbol? expr)
     (print (symbol->string expr)))
    ((string? expr)
     (print "\"" expr "\""))
    ((pair? expr)
     (let ((op (car expr)))
       (cond
         ((= op 'literal)
          (print "\"" (cadr expr) "\""))
         ((= op 'choice)
          (output-peg-expression (cadr expr))
          (list-do alt (cddr expr)
            (print " | ")
            (output-peg-expression alt)))
         ((= op 'sequence)
          (output-peg-expression (cadr expr))
          (list-do seq (cddr expr)
            (print " ")
            (output-peg-expression seq)))
         ((= op 'bind)
          (output-peg-expression (caddr expr))
          (print ":" (symbol->string (cadr expr))))
         ((= op 'char-class)
          (print "[" (cadr expr) "]"))
         ((= op 'star)
          (output-peg-expression (cadr expr))
          (print "*"))
         ((= op 'plus)
          (output-peg-expression (cadr expr))
          (print "+"))
         (else
          (error "Unknown PEG operator: " op)))))
    (else
     (error "Unknown PEG expression: " expr))))

(define-function output-peg-action (action)
  "Output PEG action"
  (cond
    ((= action 'self) (print "self"))
    ((pair? action)
     (print "{ ")
     (dump action)
     (print " }"))
    (else
     (dump action))))

(define-function output-peg-rule (rule)
  "Output a single PEG rule in .g format"
  (let ((rule-name (cadr rule))
        (rule-body (caddr rule))
        (rule-action (cadddr rule)))
    
    (print (symbol->string rule-name))
    (print " = ")
    (output-peg-expression rule-body)
    (when rule-action
      (print " -> ")
      (output-peg-action rule-action))
    (println " ;")))

(define-function output-peg-grammar (grammar filename)
  "Output complete PEG grammar to file"
  (let ((name (cadr grammar))
        (start-rule (caddr grammar))
        (rules (cadddr grammar)))
    
    (println "# Generated assembly grammar for " name)
    (println "# Auto-generated by generate-arch-grammar.l")
    (println)
    
    ;; Output grammar header
    (println "<" (symbol->string name) "> : <text-parser> ()")
    (println)
    
    ;; Output all rules
    (list-do rule rules
      (output-peg-rule rule))
    
    (println)
    (println "# End of generated grammar")))

;; Test with x86-64 architecture
(define test-grammar (generate-assembly-grammar test-arch))
(println "=== Generated Grammar ===")
(output-peg-grammar test-grammar "test-x86.g")