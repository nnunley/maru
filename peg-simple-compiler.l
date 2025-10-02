;;; Simple PEG IR to S-expression Compiler
;;; Uses basic Maru functionality only

(define-function progress-simple args (apply println (cons "; Simple PEG: " args)))

(progress-simple "defining simple PEG IR compiler")

;;; Helper functions
(define-function is-atom (x) (not (pair? x)))

;;; Simple IR compiler
(define-function compile-peg-ir (ir)
  "Compile PEG IR to S-expression"
  (cond
    ((is-atom ir) ir)
    ((pair? ir)
     (let ((op (car ir))
           (args (cdr ir)))
       (cond
         ;; Basic matching
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
         
         ;; Combinators
         ((= op 'match-first)
          `(or ,@(map compile-peg-ir args)))
         ((= op 'match-all)
          `(and ,@(map compile-peg-ir args)))
         
         ;; Repetition
         ((= op 'match-zero-one)
          `(let ((pos (<parser-stream>-position _)))
             (or ,(compile-peg-ir (car args))
                 (let () (set (<parser-stream>-position _) pos) 1))))
         ((= op 'match-zero-more)
          `(let () (while ,(compile-peg-ir (car args))) 1))
         ((= op 'match-one-more)
          `(and ,(compile-peg-ir (car args))
                (let () (while ,(compile-peg-ir (car args))) 1)))
         
         ;; Results
         ((= op 'result-expr)
          `(let () (set self.result ,(car args)) 1))
         ((= op 'assign-result)
          `(let ((,(car args) ,(compile-peg-ir (cadr args))))
             (and ,(car args) (set self.result ,(car args)))))
         
         ;; Conversions
         ((= op 'make-string)
          `(make-string ,(compile-peg-ir (car args))))
         ((= op 'make-symbol)
          `(make-symbol ,(compile-peg-ir (car args))))
         ((= op 'make-number)
          (if (pair? (cdr args))
              `(make-number ,(car args) ,(compile-peg-ir (cadr args)))
              `(make-number 10 ,(compile-peg-ir (car args)))))
         
         (else (error "Unknown IR operation: " op)))))
    (else (error "Invalid IR: " ir))))

;;; Rule compilation
(define-function compile-peg-rule (rule)
  "Compile PEG rule definition"
  (let ((name (car rule))
        (body (cadr rule)))
    (let ((compiled-body (compile-peg-ir body)))
      `(define-rule ,name ,compiled-body))))

;;; Grammar compilation
(define-function compile-peg-grammar (rules)
  "Compile complete PEG grammar"
  (map compile-peg-rule rules))

;;; Generate peg-compile.l
(define-function generate-peg-compile-l (rules output-file)
  "Generate peg-compile.l from IR rules"
  (progress-simple "generating" output-file)
  (let ((compiled-rules (compile-peg-grammar rules)))
    (with-output-to-file output-file
      (lambda ()
        (println ";;; Generated PEG Compiler")
        (println ";;; Compiled from PEG IR")
        (println)
        (println ";;; Include base PEG forms")
        (println "(require \"core/peg-compile.l\")")
        (println)
        (println ";;; Generated rule definitions")
        (map (lambda (rule)
               (println rule)
               (println))
             compiled-rules)))
    (progress-simple "generated" output-file)))

;;; In-place instantiation API
(define-function peg-instantiate-grammar (rules class-name)
  "Compile and instantiate PEG grammar immediately"
  (progress-simple "instantiating grammar for" class-name)
  (let ((compiled (compile-peg-grammar rules)))
    ;; For now, just return the compiled rules
    ;; In a full implementation, this would eval them
    compiled))

(progress-simple "testing compiler")

;;; Test with simple grammar
(define test-simple-rules
  '((letter (match-class "letter"))
    (digit (match-class "digit"))
    (identifier (match-one-more (match-rule letter)))
    (number (match-one-more (match-rule digit)))
    (expr (match-first (match-rule identifier) (match-rule number)))))

;; Test compilation
(let ((compiled (compile-peg-grammar test-simple-rules)))
  (progress-simple "test compilation result:")
  (map (lambda (rule) (println "  " rule)) compiled))

;; Generate peg-compile.l
(generate-peg-compile-l test-simple-rules "peg-compile-simple.l")

(progress-simple "simple compiler ready")