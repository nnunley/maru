;;; generate-arm64-comprehensive.l - Comprehensive ARM64 Grammar Generator
;;;
;;; Generates complete ARM64 assembly grammar from comprehensive specification

(require "arm64-spec-complete.l")

(define-function generate-comprehensive-arm64-grammar (arch-spec output-file)
  "Generate complete PEG grammar for ARM64 assembly"
  (let ((output (file-stream output-file "w")))
    
    ;; Grammar header
    (println "# -*- coke -*-")
    (println "# Comprehensive ARM64 assembly grammar")
    (println "# Generated from complete architecture specification")
    (println "# Instructions: " (list-length (<architecture>-instructions arch-spec)))
    (println "# Registers: " (list-length (<architecture>-registers arch-spec)))
    (println "")
    (println "<arm64> : <text-parser> ()")
    (println "")
    
    ;; Basic parsing elements
    (println "blank     = [\\t ] ;")
    (println "eol       = \"\\n\"\"\\r\"* | \"\\r\"\"\\n\"* ;")
    (println "_         = (blank | eol)* ;")
    (println "")
    
    ;; Number and immediate parsing
    (println "digit     = [0-9] ;")
    (println "letter    = [A-Z_a-z] ;")
    (println "hexdigit  = [0-9A-Fa-f] ;")
    (println "integer   = digit+ $#10:x _        -> x ;")
    (println "hexint    = \"0x\" hexdigit+ $#16:x _ -> x ;")
    (println "number    = hexint | integer ;")
    (println "immediate = \"#\" number:x           -> `(ir-lit ,x) ;")
    (println "")
    
    ;; Generate comprehensive register definitions
    (println ";; Register definitions")
    (let ((x-regs ()) (w-regs ()) (d-regs ()) (s-regs ()) (special-regs ()))
      
      ;; Categorize registers
      (list-do reg (<architecture>-registers arch-spec)
        (let ((name (<arch-register>-name reg))
              (name-str (symbol->string (<arch-register>-name reg))))
          (cond
            ((and (> (string-length name-str) 0) (= (string-at name-str 0) ?x))
             (push x-regs name))
            ((and (> (string-length name-str) 0) (= (string-at name-str 0) ?w))
             (push w-regs name))
            ((and (> (string-length name-str) 0) (= (string-at name-str 0) ?d))
             (push d-regs name))
            ((and (> (string-length name-str) 0) (= (string-at name-str 0) ?s))
             (push s-regs name))
            (else
             (push special-regs name)))))
      
      ;; Generate individual register rules
      (list-do reg (<architecture>-registers arch-spec)
        (let ((name (<arch-register>-name reg)))
          (println name " = \"" name "\" -> '" name " ;")))
      
      (println "")
      
      ;; Generate register categories
      (print "x_register = ")
      (list-do reg x-regs
        (print reg)
        (unless (= reg (car (last-pair x-regs))) (print " | ")))
      (println " ;")
      
      (print "w_register = ")
      (list-do reg w-regs
        (print reg)
        (unless (= reg (car (last-pair w-regs))) (print " | ")))
      (println " ;")
      
      (when d-regs
        (print "d_register = ")
        (list-do reg d-regs
          (print reg)
          (unless (= reg (car (last-pair d-regs))) (print " | ")))
        (println " ;"))
      
      (when s-regs
        (print "s_register = ")
        (list-do reg s-regs
          (print reg)
          (unless (= reg (car (last-pair s-regs))) (print " | ")))
        (println " ;"))
      
      (print "special_register = ")
      (list-do reg special-regs
        (print reg)
        (unless (= reg (car (last-pair special-regs))) (print " | ")))
      (println " ;")
      
      (println "register = x_register | w_register | d_register | s_register | special_register ;"))
    
    (println "")
    
    ;; Memory addressing modes
    (println ";; Memory addressing modes")
    (println "memory_ref = \"[\" _ register:base _ \"]\" _")
    (println "           -> `(ir-mem-ref (ir-get ',base))")
    (println "           | \"[\" _ register:base \",\" _ immediate:offset _ \"]\" _")
    (println "           -> `(ir-mem-ref (ir-add (ir-get ',base) ,offset))")
    (println "           | \"[\" _ register:base \",\" _ register:index _ \"]\" _")
    (println "           -> `(ir-mem-ref (ir-add (ir-get ',base) (ir-get ',index)))")
    (println "           | \"[\" _ register:base \",\" _ immediate:offset _ \"]\" _ \"!\" _")
    (println "           -> `(ir-mem-ref (ir-pre-inc ',base ,offset))")
    (println "           | \"[\" _ register:base _ \"]\" _ \",\" _ immediate:offset _")
    (println "           -> `(ir-mem-ref (ir-post-inc ',base ,offset)) ;")
    (println "")
    
    ;; Condition codes
    (println ";; Condition codes")
    (println "condition = \"eq\" -> 'eq | \"ne\" -> 'ne | \"cs\" -> 'cs | \"cc\" -> 'cc")
    (println "          | \"mi\" -> 'mi | \"pl\" -> 'pl | \"vs\" -> 'vs | \"vc\" -> 'vc")
    (println "          | \"hi\" -> 'hi | \"ls\" -> 'ls | \"ge\" -> 'ge | \"lt\" -> 'lt")
    (println "          | \"gt\" -> 'gt | \"le\" -> 'le | \"al\" -> 'al ;")
    (println "")
    
    ;; Labels
    (println ";; Labels")
    (println "label = letter (letter | digit | \"_\")*@$:name _ -> name ;")
    (println "")
    
    ;; Generate comprehensive instruction patterns
    (println ";; Instruction patterns")
    (let ((instruction-rules ()))
      
      (list-do insn (<architecture>-instructions arch-spec)
        (let ((name (<arch-instruction>-name insn))
              (syntax (<arch-instruction>-syntax insn))
              (ir-form (<arch-instruction>-ir-form insn)))
          
          ;; Convert syntax pattern to PEG grammar rule
          (let ((rule-name (symbol->string name))
                (rule-def (generate-instruction-rule syntax ir-form)))
            (when rule-def
              (println rule-def)
              (push instruction-rules rule-name)))))
      
      (println "")
      
      ;; Generate instruction selector
      (print "instruction = ")
      (let ((count 0))
        (list-do rule instruction-rules
          (when (> count 0) (print " | "))
          (print rule)
          (set count (+ count 1))))
      (println " ;"))
    
    (println "")
    (println "program = _ instruction*:insns (!. ~\"instruction\") -> insns ;")
    (println "")
    
    (close output)))

(define-function generate-instruction-rule (syntax ir-form)
  "Generate PEG rule for specific instruction syntax"
  (let ((mnemonic (car syntax))
        (operands (cdr syntax)))
    
    (case mnemonic
      ;; Move instructions
      ((mov)
       (cond
         ((and (= (car operands) 'immediate) 
               (member (cadr operands) '(x-register w-register)))
          (concat-strings 
            "mov_imm_reg = \"mov\" _ immediate:src \",\" _ register:dst"
            " -> `(ir-set ',dst ,src) ;"))
         ((and (member (car operands) '(x-register w-register))
               (member (cadr operands) '(x-register w-register)))
          (concat-strings
            "mov_reg_reg = \"mov\" _ register:src \",\" _ register:dst"
            " -> `(ir-set ',dst (ir-get ',src)) ;"))))
      
      ;; Arithmetic instructions
      ((add)
       (cond
         ((and (member (car operands) '(x-register w-register))
               (member (cadr operands) '(x-register w-register))
               (member (caddr operands) '(x-register w-register)))
          (concat-strings
            "add_reg_reg_reg = \"add\" _ register:rd \",\" _ register:rn \",\" _ register:rm"
            " -> `(ir-set ',rd (ir-add (ir-get ',rn) (ir-get ',rm))) ;"))
         ((and (member (car operands) '(x-register w-register))
               (member (cadr operands) '(x-register w-register))
               (= (caddr operands) 'immediate))
          (concat-strings
            "add_reg_reg_imm = \"add\" _ register:rd \",\" _ register:rn \",\" _ immediate:imm"
            " -> `(ir-set ',rd (ir-add (ir-get ',rn) ,imm)) ;"))))
      
      ;; Load/Store instructions
      ((ldr)
       (cond
         ((and (member (car operands) '(x-register w-register))
               (= (cadr operands) 'memory-ref))
          (concat-strings
            "ldr_reg_mem = \"ldr\" _ register:rt \",\" _ memory_ref:mem"
            " -> `(ir-set ',rt (ir-load ,mem)) ;"))
         ((and (member (car operands) '(d-register s-register))
               (= (cadr operands) 'memory-ref))
          (concat-strings
            "ldr_fp_mem = \"ldr\" _ register:rt \",\" _ memory_ref:mem"
            " -> `(ir-set ',rt (ir-load-fp ,mem)) ;"))))
      
      ((str)
       (cond
         ((and (member (car operands) '(x-register w-register))
               (= (cadr operands) 'memory-ref))
          (concat-strings
            "str_reg_mem = \"str\" _ register:rt \",\" _ memory_ref:mem"
            " -> `(ir-store ,mem (ir-get ',rt)) ;"))
         ((and (member (car operands) '(d-register s-register))
               (= (cadr operands) 'memory-ref))
          (concat-strings
            "str_fp_mem = \"str\" _ register:rt \",\" _ memory_ref:mem"
            " -> `(ir-store-fp ,mem (ir-get ',rt)) ;"))))
      
      ;; Branch instructions
      ((b beq bne)
       (when (= (car operands) 'label)
         (let ((branch-type (case mnemonic
                              ((b) "ir-branch")
                              ((beq) "ir-branch-eq") 
                              ((bne) "ir-branch-ne"))))
           (concat-strings
             (symbol->string mnemonic) "_label = \"" (symbol->string mnemonic) "\" _ label:target"
             " -> `(" branch-type " ',target) ;"))))
      
      ;; Compare instructions
      ((cmp)
       (cond
         ((and (member (car operands) '(x-register w-register))
               (member (cadr operands) '(x-register w-register)))
          (concat-strings
            "cmp_reg_reg = \"cmp\" _ register:rn \",\" _ register:rm"
            " -> `(ir-cmp (ir-get ',rn) (ir-get ',rm)) ;"))
         ((and (member (car operands) '(x-register w-register))
               (= (cadr operands) 'immediate))
          (concat-strings
            "cmp_reg_imm = \"cmp\" _ register:rn \",\" _ immediate:imm"
            " -> `(ir-cmp (ir-get ',rn) ,imm) ;"))))
      
      ;; Return instruction
      ((ret)
       (when (= (length syntax) 1)
         "ret = \"ret\" _ -> `(ir-return) ;"))
      
      ;; Default: return empty for unhandled instructions
      (else ()))))

(define-function concat-strings strings
  "Concatenate multiple strings"
  (let ((result ""))
    (list-do str strings
      (set result (concat-string result str)))
    result))

;; Generate the comprehensive ARM64 grammar
(println "=== Generating Comprehensive ARM64 Grammar ===")
(generate-comprehensive-arm64-grammar arm64-architecture-complete "arm64-complete.g")
(println "Generated comprehensive ARM64 grammar: arm64-complete.g")
(println "=== ARM64 Grammar Generation Complete ===")