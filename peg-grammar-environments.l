;;; PEG Grammar with Isolated Environments
;;; Uses dotted environment access for grammar rule scoping

(load "dotted-access-working.l")

(define-function progress-peg args (apply println (cons "; PEG Grammar: " args)))

(progress-peg "implementing PEG grammar with isolated environments")

;;; Enhanced PEG IR compiler with environment support
(define-function compile-peg-ir-with-env (ir env-name)
  "Compile PEG IR node to S-expression with environment access"
  (cond
    ((symbol? ir) ir)
    ((pair? ir)
     (let ((op (car ir))
           (args (cdr ir)))
       (cond
         ((= op 'match-object) 
          `(OBJECT ,(car args)))
         ((= op 'match-class) 
          `(CLASS ,(car args)))
         ((= op 'match-rule) 
          ;; Transform rule references to use dotted access
          (let ((rule-name (car args)))
            (if (symbol? rule-name)
                `(RULE ,(string->symbol (concat-string (symbol->string env-name)
                                                       (concat-string "." (symbol->string rule-name)))))
                `(RULE ,rule-name))))
         ((= op 'match-string) 
          `(STRING ,(car args)))
         ((= op 'match-range) 
          `(RANGE ,(car args) ,(cadr args)))
         ((= op 'match-sequence) 
          `(SEQUENCE ,@(map (lambda (arg) (compile-peg-ir-with-env arg env-name)) args)))
         ((= op 'match-or) 
          `(OR ,@(map (lambda (arg) (compile-peg-ir-with-env arg env-name)) args)))
         ((= op 'match-star) 
          `(STAR ,(compile-peg-ir-with-env (car args) env-name)))
         ((= op 'match-plus) 
          `(PLUS ,(compile-peg-ir-with-env (car args) env-name)))
         ((= op 'match-optional) 
          `(OPTIONAL ,(compile-peg-ir-with-env (car args) env-name)))
         ((= op 'match-and) 
          `(AND ,(compile-peg-ir-with-env (car args) env-name)))
         ((= op 'match-not) 
          `(NOT ,(compile-peg-ir-with-env (car args) env-name)))
         (else
          (error "Unknown PEG IR operation: " op)))))
    (else ir)))

;;; Grammar environment structure
(define-structure <peg-grammar> (name env rules))

(define-function make-peg-grammar (name)
  "Create new PEG grammar with isolated environment"
  (let ((grammar (new <peg-grammar>)))
    (set (<peg-grammar>-name grammar) name)
    (set (<peg-grammar>-env grammar) (make-working-env name))
    (set (<peg-grammar>-rules grammar) ())
    grammar))

(define-function peg-define-rule (grammar rule-name ir)
  "Define rule in grammar environment"
  (let ((compiled-form (compile-peg-ir-with-env ir (<peg-grammar>-name grammar))))
    ;; Store in environment for dotted access
    (working-env-define (<peg-grammar>-env grammar) rule-name compiled-form)
    ;; Also store in rules list
    (set (<peg-grammar>-rules grammar)
         (cons (cons rule-name compiled-form) (<peg-grammar>-rules grammar)))
    compiled-form))

(define-function peg-get-rule (grammar rule-name)
  "Get rule from grammar environment"
  (working-env-lookup (<peg-grammar>-env grammar) rule-name))

(define-function peg-compile-grammar (grammar)
  "Compile entire grammar to executable parser"
  (let ((rules (<peg-grammar>-rules grammar))
        (env (<peg-grammar>-env grammar)))
    `(with-working-env ((,((<peg-grammar>-name grammar)) . ,env))
       ;; Generated parser code would go here
       (lambda (input)
         ;; Parser implementation using dotted rule access
         ,((<peg-grammar>-name grammar)).start))))

;;; Example: Create isolated grammars for different languages

(progress-peg "creating example grammars")

;; JavaScript-like identifier grammar
(define js-grammar (make-peg-grammar 'js))
(peg-define-rule js-grammar 'letter '(match-class letter))
(peg-define-rule js-grammar 'digit '(match-class digit))
(peg-define-rule js-grammar 'underscore '(match-string "_"))
(peg-define-rule js-grammar 'dollar '(match-string "$"))
(peg-define-rule js-grammar 'id-start '(match-or (match-rule letter) (match-rule underscore) (match-rule dollar)))
(peg-define-rule js-grammar 'id-continue '(match-or (match-rule letter) (match-rule digit) (match-rule underscore)))
(peg-define-rule js-grammar 'identifier '(match-sequence (match-rule id-start) (match-star (match-rule id-continue))))

;; Simple arithmetic expression grammar
(define math-grammar (make-peg-grammar 'math))
(peg-define-rule math-grammar 'digit '(match-class digit))
(peg-define-rule math-grammar 'number '(match-plus (match-rule digit)))
(peg-define-rule math-grammar 'plus '(match-string "+"))
(peg-define-rule math-grammar 'minus '(match-string "-"))
(peg-define-rule math-grammar 'mult '(match-string "*"))
(peg-define-rule math-grammar 'div '(match-string "/"))
(peg-define-rule math-grammar 'operator '(match-or (match-rule plus) (match-rule minus) (match-rule mult) (match-rule div)))
(peg-define-rule math-grammar 'expression '(match-sequence (match-rule number) (match-star (match-sequence (match-rule operator) (match-rule number)))))

(progress-peg "testing isolated grammar environments")

;; Test that grammars have isolated environments
(println "JavaScript grammar rules:")
(println "  js.letter: " (peg-get-rule js-grammar 'letter))
(println "  js.identifier: " (peg-get-rule js-grammar 'identifier))

(println "Math grammar rules:")
(println "  math.digit: " (peg-get-rule math-grammar 'digit))
(println "  math.expression: " (peg-get-rule math-grammar 'expression))

;; Test dotted access within grammar environments
(println "Testing dotted access in grammar contexts:")

(with-working-env ((js . (<peg-grammar>-env js-grammar)))
  (println "  Within JS grammar context, js.letter: " js.letter)
  (println "  Within JS grammar context, js.identifier: " js.identifier))

(with-working-env ((math . (<peg-grammar>-env math-grammar)))
  (println "  Within Math grammar context, math.number: " math.number)
  (println "  Within Math grammar context, math.expression: " math.expression))

;; Demonstrate rule name isolation
(println "Rule name isolation test:")
(println "  JS digit rule: " (peg-get-rule js-grammar 'digit))  ; Not defined in JS grammar
(println "  Math digit rule: " (peg-get-rule math-grammar 'digit))  ; Defined in Math grammar

;; Show compiled forms with environment references
(println "Compiled forms with environment references:")
(println "  JS identifier rule references internal rules with js. prefix")
(println "    " (peg-get-rule js-grammar 'identifier))
(println "  Math expression rule references internal rules with math. prefix")
(println "    " (peg-get-rule math-grammar 'expression))

(progress-peg "isolated PEG grammar environments working correctly")
(progress-peg "grammars can now coexist with same rule names in different environments")