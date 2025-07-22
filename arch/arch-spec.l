;;; arch-spec.l - Architecture Specification Language Parser
;;;
;;; Defines a language for describing processor architectures
;;; that automatically generates assembly grammars and encoders

;; Simple S-expression based parser for now
;; Will extend with PEG grammar later

;; Architecture specification data structures

(define-structure <arch-register> (name encoding bit-width))
(define-structure <arch-instruction> (name syntax ir-form encoding))
(define-structure <arch-addressing-mode> (name pattern))
(define-structure <architecture> (name registers instructions addressing-modes))

;; Pretty printing for debugging
(define-method do-print <arch-register> ()
  (print "<register " self.name " enc=" self.encoding " bits=" self.bit-width ">"))

(define-method do-print <arch-instruction> ()
  (print "<instruction " self.name " syntax=" self.syntax ">"))

(define-method do-print <architecture> ()
  (print "<architecture " self.name 
         " regs=" (list-length self.registers)
         " insns=" (list-length self.instructions) ">"))

;; Architecture specification parser
;; Uses simple S-expression syntax for now

(define-function parse-arch-register (spec)
  "Parse register specification: (name encoding bit-width)"
  (new <arch-register> (car spec) (cadr spec) (caddr spec)))

(define-function parse-arch-instruction (spec)
  "Parse instruction specification: (name syntax ir-form encoding)"
  (new <arch-instruction> 
       (car spec)    ; name
       (cadr spec)   ; syntax pattern
       (caddr spec)  ; ir-form
       (cadddr spec) ; encoding
       ))

(define-function parse-arch-addressing-mode (spec)
  "Parse addressing mode: (name pattern)"
  (new <arch-addressing-mode> (car spec) (cadr spec)))

(define-function parse-architecture-spec (spec)
  "Parse complete architecture specification"
  (let ((name (cadr spec))
        (registers ())
        (instructions ())
        (addressing-modes ()))
    
    ;; Parse each section
    (list-do section (cddr spec)
      (cond
        ((= (car section) 'registers)
         (set registers (map parse-arch-register (cdr section))))
        ((= (car section) 'instructions)
         (set instructions (map parse-arch-instruction (cdr section))))
        ((= (car section) 'addressing-modes)
         (set addressing-modes (map parse-arch-addressing-mode (cdr section))))
        (else
         (error "Unknown architecture section: " (car section)))))
    
    (new <architecture> name registers instructions addressing-modes)))

;; File loading and parsing
;; TODO: Implement proper file parsing later
;; For now, work with S-expressions directly

(define-function load-architecture-spec (filename)
  "Load and parse architecture specification from file"
  (error "File loading not implemented yet - use parse-architecture-spec directly"))

;; Example usage and test
(define test-x86-spec '(define-architecture x86-64
  (registers
    (rax 0 64)
    (rbx 3 64)
    (rcx 1 64)
    (rdx 2 64))
  (instructions
    (mov-reg-reg 
     ("mov" register "," register)
     (ir-set dst (ir-get src))
     (rex-prefix 0x89 modrm))
    (mov-imm-reg
     ("mov" immediate "," register)
     (ir-set dst (ir-lit imm))
     (rex-prefix 0xb8+reg imm32)))
  (addressing-modes
    (register-direct register)
    (immediate immediate))))

;; Test the parser
(define test-arch (parse-architecture-spec test-x86-spec))
(println "Parsed architecture: " test-arch)
(println "Registers: " (<architecture>-registers test-arch))
(println "Instructions: " (<architecture>-instructions test-arch))