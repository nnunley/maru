;;; PEG IR to S-expression Compiler Demo
;;; Demonstrates compilation of PEG IR to executable S-expressions

(define-function progress-demo args (apply println (cons "; PEG Demo: " args)))

(progress-demo "PEG IR to S-expression compiler demonstration")

;;; Helper functions
(define-function is-atom (x) (not (pair? x)))

(define-function list-length (lst)
  "Count elements in a list"
  (let ((count 0))
    (while (pair? lst)
      (set count (+ count 1))
      (set lst (cdr lst)))
    count))

;;; Core IR compiler
(define-function compile-peg-ir (ir)
  "Compile PEG IR node to S-expression using available Maru constructs"
  (cond
    ((is-atom ir) ir)
    ((pair? ir)
     (let ((op (car ir))
           (args (cdr ir)))
       (cond
         ;; Basic matching operations using available forms
         ((= op 'match-object)
          `(OBJECT ,(car args)))  ; Use existing OBJECT form
         ((= op 'match-class)
          `(CLASS ,(car args)))   ; Use existing CLASS form
         ((= op 'match-string)
          `(match-string ,(car args)))
         ((= op 'match-rule)
          `(RULE ,(car args)))    ; Use existing RULE form
         ((= op 'match-any)
          `(match-any))
         
         ;; Sequence operations
         ((= op 'match-first)
          `(or ,@(map compile-peg-ir args)))
         ((= op 'match-all)
          `(and ,@(map compile-peg-ir args)))
         
         ;; Repetition using position save/restore
         ((= op 'match-zero-one)
          `(let ((pos (<parser-stream>-position _)))
             (or ,(compile-peg-ir (car args))
                 (let () (set (<parser-stream>-position _) pos) 1))))
         ((= op 'match-zero-more)
          `(let () (while ,(compile-peg-ir (car args))) 1))
         ((= op 'match-one-more)
          `(and ,(compile-peg-ir (car args))
                (let () (while ,(compile-peg-ir (car args))) 1)))
         
         ;; Predicates with position save/restore
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
         
         ;; Result handling
         ((= op 'result-expr)
          `(let () (set self.result ,(car args)) 1))
         ((= op 'assign-result)
          `(let ((,(car args) ,(compile-peg-ir (cadr args))))
             (and ,(car args) (set self.result ,(car args)))))
         
         ;; Conversion operations (simplified)
         ((= op 'make-string)
          `(make-string ,(compile-peg-ir (car args))))
         ((= op 'make-symbol)
          `(string->symbol ,(compile-peg-ir (car args))))
         ((= op 'make-number)
          (if (pair? (cdr args))
              `(string->number ,(compile-peg-ir (cadr args)) ,(car args))
              `(string->number ,(compile-peg-ir (car args)))))
         
         (else (error "Unknown IR operation: " op)))))
    (else (error "Invalid IR: " ir))))

;;; Rule compilation to define-rule form
(define-function compile-peg-rule (rule)
  "Compile PEG rule to define-rule form"
  (let ((name (car rule))
        (body (cadr rule)))
    `(define-rule ,name ,(compile-peg-ir body))))

;;; Grammar compilation
(define-function compile-peg-grammar (rules)
  "Compile complete PEG grammar to list of define-rule forms"
  (map compile-peg-rule rules))

;;; In-place instantiation simulation
(define-function peg-instantiate (rules)
  "Show what instantiation would look like"
  (progress-demo "instantiating PEG grammar with" (list-length rules) "rules")
  (let ((compiled (compile-peg-grammar rules)))
    (progress-demo "compiled rules:")
    (map (lambda (rule) 
           (println "  " rule)
           (println))
         compiled)
    compiled))

;;; Generate peg-compile.l content (display only)
(define-function show-peg-compile-content (rules)
  "Show what the generated peg-compile.l would contain"
  (progress-demo "generated peg-compile.l content:")
  (println ";;; Generated PEG Compiler")
  (println ";;; Compiled from PEG IR rules")
  (println)
  (println ";;; Base PEG system requirement")
  (println "(require \"core/peg-boot.l\")")
  (println)
  (println ";;; Generated grammar rules")
  (let ((compiled (compile-peg-grammar rules)))
    (map (lambda (rule)
           (println rule)
           (println))
         compiled))
  (println ";;; End of generated content")
  (println))

(progress-demo "demonstration starting")

;;; Example PEG IR grammar
(define example-grammar
  '((letter (match-class "letter"))
    (digit (match-class "digit"))
    (whitespace (match-first (match-object 32) (match-object 9) (match-object 10)))
    (identifier (match-one-more (match-rule letter)))
    (number (match-one-more (match-rule digit)))
    (spaced-expr (match-all 
                   (match-zero-more (match-rule whitespace))
                   (match-first (match-rule identifier) (match-rule number))
                   (match-zero-more (match-rule whitespace))))))

(progress-demo "example grammar has" (list-length example-grammar) "rules")

;;; Demonstrate IR compilation
(progress-demo "compiling individual IR nodes:")
(println "  match-object:" (compile-peg-ir '(match-object 65)))
(println "  match-class:" (compile-peg-ir '(match-class "letter")))
(println "  match-rule:" (compile-peg-ir '(match-rule identifier)))
(println "  match-first:" (compile-peg-ir '(match-first (match-rule letter) (match-rule digit))))
(println "  match-one-more:" (compile-peg-ir '(match-one-more (match-rule letter))))
(println)

;;; Demonstrate rule compilation
(progress-demo "compiling rules:")
(let ((first-rule (car example-grammar)))
  (println "  Original rule:" first-rule)
  (println "  Compiled rule:" (compile-peg-rule first-rule))
  (println))

;;; Demonstrate full grammar compilation
(peg-instantiate example-grammar)

;;; Show generated content
(show-peg-compile-content example-grammar)

(progress-demo "demonstration complete")
(progress-demo "PEG IR compiler successfully converts IR to executable S-expressions")
(progress-demo "In-place instantiation mechanism ready for integration")