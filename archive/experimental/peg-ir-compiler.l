;;; PEG IR to S-expression Compiler
;;; Standalone compiler for PEG intermediate representation

(define-function progress-peg args (apply println (cons "; PEG IR: " args)))

(progress-peg "defining PEG IR compiler")

;;; PEG IR Compiler Structure
(define-structure <peg-ir-compiler> (output variables))

(define-function peg-ir-compiler ()
  "Create new PEG IR compiler instance"
  (let ((self (new <peg-ir-compiler>)))
    (set (<peg-ir-compiler>-output self) ())
    (set (<peg-ir-compiler>-variables self) ())
    self))

;;; Core IR to S-expression compilation
(define-method compile-ir <peg-ir-compiler> (ir)
  "Compile PEG IR node to executable S-expression"
  (cond
    ((atom? ir) ir)
    ((pair? ir)
     (let ((op (car ir))
           (args (cdr ir)))
       (cond
         ;; Basic matching
         ((= op 'match-object) 
          `(match-object ,(car args)))
         ((= op 'match-class)
          `(match-class ,(car args)))
         ((= op 'match-string)
          `(match-string ,(car args)))
         ((= op 'match-rule)
          `(match-rule ,(car args)))
         ((= op 'match-any)
          `(match-any))
         
         ;; Combinators
         ((= op 'match-first)
          `(match-first ,@(map (lambda (arg) (compile-ir self arg)) args)))
         ((= op 'match-all)
          `(match-all ,@(map (lambda (arg) (compile-ir self arg)) args)))
         
         ;; Repetition
         ((= op 'match-zero-one)
          `(match-zero-one ,(compile-ir self (car args))))
         ((= op 'match-zero-more)
          `(match-zero-more ,(compile-ir self (car args))))
         ((= op 'match-one-more)
          `(match-one-more ,(compile-ir self (car args))))
         
         ;; Predicates
         ((= op 'peek-for)
          `(peek-for ,(compile-ir self (car args))))
         ((= op 'peek-not)
          `(peek-not ,(compile-ir self (car args))))
         
         ;; Results
         ((= op 'result-expr)
          `(result-expr ,(car args)))
         ((= op 'assign-result)
          `(assign-result ,(car args) ,(compile-ir self (cadr args))))
         
         ;; Conversions
         ((= op 'make-string)
          `(make-string ,(compile-ir self (car args))))
         ((= op 'make-symbol)
          `(make-symbol ,(compile-ir self (car args))))
         ((= op 'make-number)
          (if (pair? (cdr args))
              `(make-number ,(car args) ,(compile-ir self (cadr args)))
              `(make-number 10 ,(compile-ir self (car args)))))
         ((= op 'make-span)
          `(make-span ,(compile-ir self (car args))))
         
         (else (error "Unknown IR operation: " op)))))
    (else (error "Invalid IR node: " ir))))

;;; Rule compilation
(define-method compile-rule <peg-ir-compiler> (rule)
  "Compile a PEG rule definition to method definition"
  (let ((name (car rule))
        (body (cadr rule)))
    (let ((compiled-body (compile-ir self body))
          (method-name (concat-symbol '$ name)))
      `(define-method ,method-name <peg> ()
         ,compiled-body))))

;;; Grammar compilation
(define-method compile-grammar <peg-ir-compiler> (rules)
  "Compile complete PEG grammar to S-expressions"
  (cons
    '(define-class <peg> <parser> (grammar-name))
    (map (lambda (rule) (compile-rule self rule)) rules)))

(progress-peg "defining in-place instantiation")

;;; In-Place Parser Instantiation
(define-structure <peg-instantiator> (class-name rules))

(define-function peg-instantiator (class-name)
  "Create parser instantiator for given class name"
  (let ((self (new <peg-instantiator>)))
    (set (<peg-instantiator>-class-name self) class-name)
    (set (<peg-instantiator>-rules self) ())
    self))

(define-method add-rule <peg-instantiator> (name ir)
  "Add rule to instantiator"
  (set (<peg-instantiator>-rules self)
       (cons (list name ir) (<peg-instantiator>-rules self))))

(define-method instantiate <peg-instantiator> ()
  "Generate and evaluate parser class, return class name"
  (let ((compiler (peg-ir-compiler)))
    (let ((compiled (compile-grammar compiler (<peg-instantiator>-rules self))))
      ;; Evaluate the generated parser class
      (map eval compiled)
      ;; Return class name
      (<peg-instantiator>-class-name self))))

;;; High-level API
(define-function peg-compile-ir-grammar (rules class-name)
  "Compile PEG IR grammar and instantiate parser class"
  (let ((instantiator (peg-instantiator class-name)))
    (map (lambda (rule)
           (add-rule instantiator (car rule) (cadr rule)))
         rules)
    (instantiate instantiator)))

(define-function peg-generate-compile-file (rules output-file)
  "Generate peg-compile.l style file from PEG IR rules"
  (progress-peg "generating" output-file)
  (let ((compiler (peg-ir-compiler)))
    (let ((compiled (compile-grammar compiler rules)))
      (with-output-to-file output-file
        (lambda ()
          (println ";;; Generated PEG Compiler")
          (println ";;; Compiled from PEG IR rules")
          (println)
          (map (lambda (form)
                 (println form)
                 (println))
               compiled)))
      (progress-peg "generated" output-file "with" (length compiled) "forms"))))

(progress-peg "testing IR compiler")

;;; Test the IR compiler
(define test-ir-rules
  '((letter (match-class "letter"))
    (digit (match-class "digit"))
    (identifier (match-one-more (match-rule letter)))
    (number (match-one-more (match-rule digit)))
    (expression (match-first (match-rule identifier) (match-rule number)))))

;; Test compilation
(let ((compiler (peg-ir-compiler)))
  (let ((compiled (compile-grammar compiler test-ir-rules)))
    (progress-peg "test compilation result:")
    (map (lambda (form) (println "  " form)) compiled)))

;; Test file generation
(peg-generate-compile-file test-ir-rules "peg-compile-generated.l")

(progress-peg "IR compiler ready")