;;; Generated PEG Compiler
;;; Compiled from PEG IR rules using enhanced peg-boot system

;;; Base PEG system requirement
(require "core/peg-boot.l")

;;; Enhanced PEG IR to S-expression compiler
;;; This provides the bridge between PEG IR and executable parser code

(define-function is-atom (x) (not (pair? x)))

(define-function compile-peg-ir (ir)
  "Compile PEG IR node to executable S-expression"
  (cond
    ((is-atom ir) ir)
    ((pair? ir)
     (let ((op (car ir))
           (args (cdr ir)))
       (cond
         ;; Basic matching operations using existing PEG forms
         ((= op 'match-object)
          `(OBJECT ,(car args)))
         ((= op 'match-class)
          `(CLASS ,(car args)))
         ((= op 'match-string)
          `(match-string ,(car args)))
         ((= op 'match-rule)
          `(RULE ,(car args)))
         ((= op 'match-any)
          `(match-any))
         
         ;; Sequence operations
         ((= op 'match-first)
          `(or ,@(map compile-peg-ir args)))
         ((= op 'match-all)
          `(and ,@(map compile-peg-ir args)))
         
         ;; Repetition with proper position handling
         ((= op 'match-zero-one)
          `(let ((pos (<parser-stream>-position _)))
             (or ,(compile-peg-ir (car args))
                 (let () (set (<parser-stream>-position _) pos) 1))))
         ((= op 'match-zero-more)
          `(let () (while ,(compile-peg-ir (car args))) 1))
         ((= op 'match-one-more)
          `(and ,(compile-peg-ir (car args))
                (let () (while ,(compile-peg-ir (car args))) 1)))
         
         ;; Predicates with backtracking
         ((= op 'peek-for)
          `(let ((pos (<parser-stream>-position _)))
             (let ((result ,(compile-peg-ir (car args))))
               (set (<parser-stream>-position _) pos)
               result)))
         ((= op 'peek-not)
          `(let ((pos (<parser-stream>-position _)))
             (let ((result ,(compile-peg-ir (car args))))
               (set (<parser-stream>-position _) pos)
               (not result))))
         
         ;; Result operations
         ((= op 'result-expr)
          `(let () (set self.result ,(car args)) 1))
         ((= op 'assign-result)
          `(let ((,(car args) ,(compile-peg-ir (cadr args))))
             (and ,(car args) (set self.result ,(car args)))))
         
         ;; Conversion operations
         ((= op 'make-string)
          `(make-string ,(compile-peg-ir (car args))))
         ((= op 'make-symbol)
          `(string->symbol ,(compile-peg-ir (car args))))
         ((= op 'make-number)
          (if (pair? (cdr args))
              `(string->number ,(compile-peg-ir (cadr args)) ,(car args))
              `(string->number ,(compile-peg-ir (car args)))))
         ((= op 'make-span)
          `(make-span ,(compile-peg-ir (car args))))
         
         (else (error "Unknown IR operation: " op)))))
    (else (error "Invalid IR: " ir))))

;;; Rule compilation to define-rule
(define-function compile-peg-rule (rule)
  "Compile PEG rule to define-rule form"
  (let ((name (car rule))
        (body (cadr rule)))
    `(define-rule ,name ,(compile-peg-ir body))))

;;; Grammar compilation
(define-function compile-peg-grammar (rules)
  "Compile complete PEG grammar to define-rule forms"
  (map compile-peg-rule rules))

;;; In-place instantiation mechanism
(define-function peg-instantiate-parser (rules parser-name)
  "Compile PEG IR rules and instantiate parser in-place"
  (let ((compiled-rules (compile-peg-grammar rules)))
    ;; Evaluate all the define-rule forms
    (map eval compiled-rules)
    ;; Return the parser name for use
    parser-name))

;;; Convenience function for quick parser creation
(define-function peg-quick-compile (rules)
  "Compile and return executable PEG rules immediately"
  (compile-peg-grammar rules))

;;; Example usage:
;;; (define my-grammar
;;;   '((letter (match-class "letter"))
;;;     (digit (match-class "digit"))
;;;     (identifier (match-one-more (match-rule letter)))))
;;; 
;;; (peg-instantiate-parser my-grammar '<my-parser>)

;;; Generated rule definitions (example)
(define-rule letter (CLASS "letter"))

(define-rule digit (CLASS "digit"))

(define-rule whitespace (or (OBJECT 32) (OBJECT 9) (OBJECT 10)))

(define-rule identifier (and (RULE letter) (let () (while (RULE letter)) 1)))

(define-rule number (and (RULE digit) (let () (while (RULE digit)) 1)))

(define-rule spaced-expr (and (let () (while (RULE whitespace)) 1) (or (RULE identifier) (RULE number)) (let () (while (RULE whitespace)) 1)))

;;; Export the compilation functions for use
(println "; PEG compile system loaded")
(println "; Use (compile-peg-ir ir) to compile IR nodes")  
(println "; Use (compile-peg-grammar rules) to compile grammars")
(println "; Use (peg-instantiate-parser rules name) for in-place instantiation")