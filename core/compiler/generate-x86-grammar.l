;;; generate-x86-grammar.l - Generate x86 Assembly PEG Grammar
;;;
;;; Create a .g file for x86 assembly using the same pattern as irl.g

(require "arch-spec.l")

(define-function write-x86-grammar (filename)
  "Write x86 assembly grammar directly to .g file"
  (println "# -*- coke -*-")
  (println "# Generated x86-64 assembly grammar")
  (println "# Auto-generated from architecture specification")
  (println)
  (println "<x86> : <text-parser> ()")
  (println)
  
  ;; Basic patterns
  (println "blank     = [\\t ] ;")
  (println "eol       = \"\\n\"\"\\r\"* | \"\\r\"\"\\n\"* ;")
  (println "_         = (blank | eol)* ;")
  (println)
  
  ;; Numbers and immediates
  (println "digit     = [0-9] ;")
  (println "letter    = [A-Z_a-z] ;")
  (println "integer   = digit+ $#10:x _        -> x ;")
  (println "immediate = \"$\" integer:x         -> `(ir-lit ,x) ;")
  (println)
  
  ;; Registers (based on test architecture)
  (println "rax       = \"%rax\" _               -> 'rax ;")
  (println "rbx       = \"%rbx\" _               -> 'rbx ;") 
  (println "rcx       = \"%rcx\" _               -> 'rcx ;")
  (println "rdx       = \"%rdx\" _               -> 'rdx ;")
  (println "register  = rax | rbx | rcx | rdx ;")
  (println)
  
  ;; Instructions (simple versions for now)
  (println "mov_reg_reg = \"mov\" _ register:src \",\" _ register:dst")
  (println "              -> `(ir-set ',dst (ir-get ',src)) ;")
  (println)
  (println "mov_imm_reg = \"mov\" _ immediate:src \",\" _ register:dst")  
  (println "              -> `(ir-set ',dst ,src) ;")
  (println)
  (println "instruction = mov_reg_reg | mov_imm_reg ;")
  (println)
  
  ;; Program structure
  (println "program     = _ instruction*:insns (!. ~\"instruction\") -> insns ;")
  (println))

;; Generate the grammar
(println "=== Generating x86-64 Assembly Grammar ===")
(write-x86-grammar "x86.g")
(println "=== Generated x86.g ===")