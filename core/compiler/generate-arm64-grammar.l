;;; generate-arm64-grammar.l - Generate ARM64 Assembly Grammar
;;;
;;; Creates PEG grammar for ARM64 assembly from architecture specification

(require "arm64-spec.l")

(define-function generate-arm64-grammar (arch-spec output-file)
  "Generate PEG grammar file for ARM64 assembly"
  (let ((output (file-stream output-file "w")))
    
    ;; Grammar header
    (println "# -*- coke -*-")
    (println "# Generated ARM64 assembly grammar")
    (println "# Auto-generated from architecture specification")
    (println "")
    (println "<arm64> : <text-parser> ()")
    (println "")
    
    ;; Basic parsing elements
    (println "blank     = [\\t ] ;")
    (println "eol       = \"\\n\"\"\\r\"* | \"\\r\"\"\\n\"* ;")
    (println "_         = (blank | eol)* ;")
    (println "")
    
    ;; Number parsing
    (println "digit     = [0-9] ;")
    (println "letter    = [A-Z_a-z] ;")
    (println "integer   = digit+ $#10:x _        -> x ;")
    (println "immediate = \"#\" integer:x         -> `(ir-lit ,x) ;")
    (println "")
    
    ;; Generate register definitions
    (println ";; Register definitions")
    (let ((registers (<architecture>-registers arch-spec)))
      (list-do reg registers
        (let ((name (<arch-register>-name reg)))
          (println name "       = \"" name "\"                 -> '" name " ;"))))
    
    (println "")
    (println ";; Register categories")
    
    ;; X registers (64-bit)
    (print "x_register = ")
    (let ((x-regs ()))
      (list-do reg (<architecture>-registers arch-spec)
        (when (and (>= (<arch-register>-bit-width reg) 64)
                   (let ((name-str (symbol->string (<arch-register>-name reg))))
                     (and (> (string-length name-str) 0)
                          (= (string-at name-str 0) ?x))))
          (push x-regs (<arch-register>-name reg))))
      (list-do reg x-regs
        (print reg)
        (unless (= reg (car (last-pair x-regs)))
          (print " | "))))
    (println " ;")
    
    ;; W registers (32-bit)
    (print "w_register = ")
    (let ((w-regs ()))
      (list-do reg (<architecture>-registers arch-spec)
        (when (and (= (<arch-register>-bit-width reg) 32)
                   (let ((name-str (symbol->string (<arch-register>-name reg))))
                     (and (> (string-length name-str) 0)
                          (= (string-at name-str 0) ?w))))
          (push w-regs (<arch-register>-name reg))))
      (list-do reg w-regs
        (print reg)
        (unless (= reg (car (last-pair w-regs)))
          (print " | "))))
    (println " ;")
    
    (println "register  = x_register | w_register | sp | xzr | wzr ;")
    (println "")
    
    ;; Memory addressing modes
    (println ";; Memory addressing modes")
    (println "memory_ref = \"[\" _ register:base _ \"]\" _")
    (println "           -> `(ir-mem-ref (ir-get ',base))")
    (println "           | \"[\" _ register:base \",\" _ immediate:offset _ \"]\" _")
    (println "           -> `(ir-mem-ref (ir-add (ir-get ',base) ,offset)) ;")
    (println "")
    
    ;; Generate instruction patterns
    (println ";; Instruction patterns")
    (let ((instructions (<architecture>-instructions arch-spec)))
      (list-do insn instructions
        (let ((name (<arch-instruction>-name insn))
              (syntax (<arch-instruction>-syntax insn))
              (ir-form (<arch-instruction>-ir-form insn)))
          
          ;; Convert syntax pattern to PEG grammar rule
          (case (car syntax)
            ((mov)
             (cond
               ((and (= (cadr syntax) 'register) (= (caddr syntax) 'register))
                (println "mov_reg_reg = \"mov\" _ register:src \",\" _ register:dst")
                (println "              -> `(ir-set ',dst (ir-get ',src)) ;"))
               ((and (= (cadr syntax) 'immediate) (= (caddr syntax) 'register)) 
                (println "mov_imm_reg = \"mov\" _ immediate:src \",\" _ register:dst")
                (println "              -> `(ir-set ',dst ,src) ;"))))
            
            ((add)
             (cond
               ((and (= (cadr syntax) 'register) (= (caddr syntax) 'register) (= (cadddr syntax) 'register))
                (println "add_reg_reg_reg = \"add\" _ register:dst \",\" _ register:src1 \",\" _ register:src2")
                (println "                  -> `(ir-set ',dst (ir-add (ir-get ',src1) (ir-get ',src2))) ;"))
               ((and (= (cadr syntax) 'immediate) (= (caddr syntax) 'register) (= (cadddr syntax) 'register))
                (println "add_imm_reg_reg = \"add\" _ register:dst \",\" _ register:src \",\" _ immediate:imm")
                (println "                  -> `(ir-set ',dst (ir-add (ir-get ',src) ,imm)) ;"))))
            
            ((sub)
             (cond
               ((and (= (cadr syntax) 'register) (= (caddr syntax) 'register) (= (cadddr syntax) 'register))
                (println "sub_reg_reg_reg = \"sub\" _ register:dst \",\" _ register:src1 \",\" _ register:src2")
                (println "                  -> `(ir-set ',dst (ir-sub (ir-get ',src1) (ir-get ',src2))) ;"))
               ((and (= (cadr syntax) 'immediate) (= (caddr syntax) 'register) (= (cadddr syntax) 'register))
                (println "sub_imm_reg_reg = \"sub\" _ register:dst \",\" _ register:src \",\" _ immediate:imm")
                (println "                  -> `(ir-set ',dst (ir-sub (ir-get ',src) ,imm)) ;"))))
            
            ((ldr)
             (when (and (= (cadr syntax) 'register) (= (caddr syntax) 'memory-ref))
               (println "ldr_reg_mem = \"ldr\" _ register:dst \",\" _ memory_ref:mem")
               (println "              -> `(ir-set ',dst (ir-load ,mem)) ;")))
            
            ((str)
             (when (and (= (cadr syntax) 'register) (= (caddr syntax) 'memory-ref))
               (println "str_reg_mem = \"str\" _ register:src \",\" _ memory_ref:mem")
               (println "              -> `(ir-store ,mem (ir-get ',src)) ;")))
            
            ((cmp)
             (cond
               ((and (= (cadr syntax) 'register) (= (caddr syntax) 'register))
                (println "cmp_reg_reg = \"cmp\" _ register:src1 \",\" _ register:src2")
                (println "              -> `(ir-cmp (ir-get ',src1) (ir-get ',src2)) ;"))
               ((and (= (cadr syntax) 'immediate) (= (caddr syntax) 'register))
                (println "cmp_imm_reg = \"cmp\" _ immediate:imm \",\" _ register:src")
                (println "              -> `(ir-cmp ,imm (ir-get ',src)) ;"))))
            
            ((b)
             (when (= (cadr syntax) 'label)
               (println "b_label = \"b\" _ label:target")
               (println "          -> `(ir-branch ',target) ;")))
            
            ((ret)
             (when (= (length syntax) 1)
               (println "ret = \"ret\" _")
               (println "      -> `(ir-return) ;")))))))
    
    (println "")
    (println ";; Label definition")
    (println "label = letter (letter | digit | \"_\")*@$:name _ -> name ;")
    (println "")
    
    ;; Instruction selector
    (println "instruction = mov_reg_reg | mov_imm_reg")
    (println "            | add_reg_reg_reg | add_imm_reg_reg")
    (println "            | sub_reg_reg_reg | sub_imm_reg_reg")
    (println "            | ldr_reg_mem | str_reg_mem")
    (println "            | cmp_reg_reg | cmp_imm_reg")
    (println "            | b_label | ret ;")
    (println "")
    (println "program     = _ instruction*:insns (!. ~\"instruction\") -> insns ;")
    (println "")
    
    (close output)))

;; Generate the ARM64 grammar
(println "=== Generating ARM64 Grammar ===")
(generate-arm64-grammar arm64-architecture "arm64.g")
(println "Generated ARM64 grammar: arm64.g")
(println "=== ARM64 Grammar Generation Complete ===")