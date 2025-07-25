;;; Enhanced PEG Bootstrap with IR to S-expression Compiler
;;; Includes in-place instantiation mechanism for generated parsers

;; Load required dependencies
(require "core/parser.l")
(require "core/peg-compile.l")

(define-function progress-enhanced args (apply println (cons "; Enhanced PEG: " args)))

(progress-enhanced "defining IR to S-expression compiler")

;;; PEG IR to S-expression Compiler
;;; Converts PEG intermediate representation to executable S-expressions

(define-structure <peg-ir-compiler> (output variables))

(define-function peg-ir-compiler ()
  (let ((self (new <peg-ir-compiler>)))
    (set (<peg-ir-compiler>-output self) (group))
    (set (<peg-ir-compiler>-variables self) ())
    self))

;;; Core IR compilation methods
(define-method compile-ir <peg-ir-compiler> (ir)
  "Compile PEG IR node to S-expression"
  (cond
    ((atom? ir) ir)
    ((pair? ir)
     (let ((op (car ir))
           (args (cdr ir)))
       (cond
         ;; Basic matching operations
         ((= op 'match-object) (compile-match-object self args))
         ((= op 'match-class) (compile-match-class self args))
         ((= op 'match-string) (compile-match-string self args))
         ((= op 'match-rule) (compile-match-rule self args))
         ((= op 'match-any) (compile-match-any self args))
         
         ;; Sequence operations
         ((= op 'match-first) (compile-match-first self args))
         ((= op 'match-all) (compile-match-all self args))
         
         ;; Repetition operations
         ((= op 'match-zero-one) (compile-match-zero-one self args))
         ((= op 'match-zero-more) (compile-match-zero-more self args))
         ((= op 'match-one-more) (compile-match-one-more self args))
         
         ;; Predicate operations
         ((= op 'peek-for) (compile-peek-for self args))
         ((= op 'peek-not) (compile-peek-not self args))
         
         ;; Result operations
         ((= op 'result-expr) (compile-result-expr self args))
         ((= op 'assign-result) (compile-assign-result self args))
         
         ;; Conversion operations
         ((= op 'make-string) (compile-make-string self args))
         ((= op 'make-symbol) (compile-make-symbol self args))
         ((= op 'make-number) (compile-make-number self args))
         ((= op 'make-span) (compile-make-span self args))
         
         (else (error "Unknown IR operation: " op)))))
    (else (error "Invalid IR node: " ir))))

;;; Basic matching operations
(define-method compile-match-object <peg-ir-compiler> (args)
  (let ((char (car args)))
    `(and (= (parser-stream-peek self.source) ,char)
          (parser-stream-next self.source))))

(define-method compile-match-class <peg-ir-compiler> (args)
  (let ((class (car args)))
    `(let ((ch (parser-stream-peek self.source)))
       (and ch (string-match-class ,class ch)
            (parser-stream-next self.source)))))

(define-method compile-match-string <peg-ir-compiler> (args)
  (let ((string (car args)))
    `(let ((start (parser-stream-position self.source)))
       (let ((result (string-match-prefix ,string self.source)))
         (or result
             (let () (set (parser-stream-position self.source) start) ()))))))

(define-method compile-match-rule <peg-ir-compiler> (args)
  (let ((rule (car args)))
    `(,(concat-symbol '$ rule) self)))

(define-method compile-match-any <peg-ir-compiler> (args)
  `(parser-stream-next self.source))

;;; Sequence operations
(define-method compile-match-first <peg-ir-compiler> (args)
  (let ((alternatives (map (lambda (alt) (compile-ir self alt)) args)))
    `(or ,@alternatives)))

(define-method compile-match-all <peg-ir-compiler> (args)
  (let ((sequence (map (lambda (item) (compile-ir self item)) args)))
    `(and ,@sequence)))

;;; Repetition operations
(define-method compile-match-zero-one <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args))))
    `(let ((pos (parser-stream-position self.source)))
       (or ,expr
           (let () (set (parser-stream-position self.source) pos) 1)))))

(define-method compile-match-zero-more <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args))))
    `(let ()
       (while ,expr)
       1)))

(define-method compile-match-one-more <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args))))
    `(and ,expr
          (let () (while ,expr) 1))))

;;; Predicate operations
(define-method compile-peek-for <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args)))
        (pos-var (gensym 'pos)))
    `(let ((,pos-var (parser-stream-position self.source)))
       (let ((result ,expr))
         (set (parser-stream-position self.source) ,pos-var)
         result))))

(define-method compile-peek-not <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args)))
        (pos-var (gensym 'pos)))
    `(let ((,pos-var (parser-stream-position self.source)))
       (let ((result ,expr))
         (set (parser-stream-position self.source) ,pos-var)
         (not result)))))

;;; Result operations
(define-method compile-result-expr <peg-ir-compiler> (args)
  (let ((expr (car args)))
    `(let () (set self.result ,expr) 1)))

(define-method compile-assign-result <peg-ir-compiler> (args)
  (let ((var (car args))
        (expr (compile-ir self (cadr args))))
    (set (<peg-ir-compiler>-variables self) 
         (cons var (<peg-ir-compiler>-variables self)))
    `(let ((,var ,expr))
       (and ,var (let () (set self.result ,var) 1)))))

;;; Conversion operations  
(define-method compile-make-string <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args))))
    `(let ((span ,expr))
       (and span (parser-stream-span->string self.source span)))))

(define-method compile-make-symbol <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args))))
    `(let ((str ,expr))
       (and str (string->symbol str)))))

(define-method compile-make-number <peg-ir-compiler> (args)
  (let ((base (if (pair? (cdr args)) (car args) 10))
        (expr (compile-ir self (if (pair? (cdr args)) (cadr args) (car args)))))
    `(let ((str ,expr))
       (and str (string->number str ,base)))))

(define-method compile-make-span <peg-ir-compiler> (args)
  (let ((expr (compile-ir self (car args))))
    `(let ((start (parser-stream-position self.source)))
       (let ((result ,expr))
         (and result (cons start (parser-stream-position self.source)))))))

;;; Rule compilation
(define-method compile-rule <peg-ir-compiler> (rule)
  "Compile a complete PEG rule definition"
  (let ((name (car rule))
        (body (cadr rule)))
    (let ((compiled-body (compile-ir self body))
          (method-name (concat-symbol '$ name)))
      `(define-method ,method-name <peg> ()
         (let ((pos (parser-stream-position self.source)))
           (or ,compiled-body
               (let () (set (parser-stream-position self.source) pos) ())))))))

;;; Grammar compilation  
(define-method compile-grammar <peg-ir-compiler> (rules)
  "Compile complete PEG grammar to S-expressions"
  (let ((compiled-rules (map (lambda (rule) (compile-rule self rule)) rules)))
    `((define-class <peg> <parser> (grammar-name))
      ,@compiled-rules)))

(progress-enhanced "defining in-place instantiation mechanism")

;;; In-Place Instantiation Mechanism
;;; Allows immediate creation and use of generated parsers

(define-structure <peg-instantiator> (parser-class rules))

(define-function peg-instantiator (class-name)
  (let ((self (new <peg-instantiator>)))
    (set (<peg-instantiator>-parser-class self) class-name)
    (set (<peg-instantiator>-rules self) ())
    self))

(define-method add-rule <peg-instantiator> (name ir)
  "Add a rule to the instantiator"
  (set (<peg-instantiator>-rules self) 
       (cons (list name ir) (<peg-instantiator>-rules self))))

(define-method instantiate <peg-instantiator> ()
  "Generate and evaluate parser class in-place"
  (let ((compiler (peg-ir-compiler)))
    (let ((compiled-grammar (compile-grammar compiler (<peg-instantiator>-rules self))))
      ;; Evaluate the generated code immediately
      (map eval compiled-grammar)
      ;; Return the parser class name for use
      (<peg-instantiator>-parser-class self))))

(define-method create-parser <peg-instantiator> (stream)
  "Create parser instance with given stream"
  (let ((class-name (instantiate self)))
    (let ((parser (new (eval class-name))))
      (set (eval (list 'parser-source parser)) stream)
      parser)))

;;; High-level API for easy use
(define-function peg-compile-and-instantiate (grammar-rules class-name)
  "Compile PEG grammar and instantiate parser class immediately"
  (let ((instantiator (peg-instantiator class-name)))
    (map (lambda (rule) 
           (add-rule instantiator (car rule) (cadr rule))) 
         grammar-rules)
    (instantiate instantiator)))

(define-function peg-quick-parser (grammar-rules stream)
  "Create parser from grammar rules and stream in one step"
  (let ((class-name (gensym '<quick-peg>)))
    (peg-compile-and-instantiate grammar-rules class-name)
    (let ((parser (new (eval class-name))))
      (set (eval (list 'parser-source parser)) stream)
      parser)))

(progress-enhanced "defining enhanced compilation interface")

;;; Enhanced Compilation Interface
(define-function compile-peg-grammar-enhanced (grammar-rules)
  "Enhanced grammar compilation with IR processing"
  (let ((compiler (peg-ir-compiler)))
    (compile-grammar compiler grammar-rules)))

(define-function generate-peg-compile-enhanced ()
  "Generate enhanced peg-compile.l with IR compilation support"
  (progress-enhanced "generating enhanced peg-compile.l")
  
  ;; Regenerate peg-compile.l with enhanced features
  (let ((output-file "peg-compile-enhanced.l"))
    (with-output-to-file output-file
      (lambda ()
        (println ";;; Enhanced PEG Compilation Support")
        (println ";;; Generated from PEG IR compiler")
        (println)
        
        ;; Include original compilation forms
        (println ";;; Original compilation forms")
        (with-input-from-file "core/peg-compile.l"
          (lambda ()
            (let ((expr (read)))
              (while expr
                (println expr)
                (set expr (read))))))
        
        (println)
        (println ";;; Enhanced IR compilation interface")
        (println "(define peg-ir-compile compile-peg-grammar-enhanced)")
        (println "(define peg-instantiate peg-compile-and-instantiate)")
        (println "(define peg-quick-parse peg-quick-parser)")
        ))
    
    (progress-enhanced "enhanced peg-compile.l generated as" output-file)))

;;; Demonstration
(progress-enhanced "testing enhanced compilation")

;; Test with simple grammar
(define test-grammar 
  '((identifier (match-one-more (match-class "letter")))
    (number (match-one-more (match-class "digit")))
    (expr (match-first (match-rule identifier) (match-rule number)))))

;; Compile and show result
(let ((compiled (compile-peg-grammar-enhanced test-grammar)))
  (progress-enhanced "compiled test grammar:")
  (map (lambda (rule) (println "  " rule)) compiled))

(progress-enhanced "enhanced PEG bootstrap complete")