;;; Working Dotted Environment Access System
;;; Alternative approach using character code manipulation

(define-function progress-working args (apply println (cons "; Working Dot: " args)))

(progress-working "implementing working dotted access with alternative approach")

;;; Alternative string building using character codes directly
(define-function char-to-string (char-code)
  "Convert character code to single character string"
  ;; Since string function doesn't work with codes, we'll use a lookup table
  (cond
    ((= char-code 97) "a") ((= char-code 98) "b") ((= char-code 99) "c") ((= char-code 100) "d")
    ((= char-code 101) "e") ((= char-code 102) "f") ((= char-code 103) "g") ((= char-code 104) "h")
    ((= char-code 105) "i") ((= char-code 106) "j") ((= char-code 107) "k") ((= char-code 108) "l")
    ((= char-code 109) "m") ((= char-code 110) "n") ((= char-code 111) "o") ((= char-code 112) "p")
    ((= char-code 113) "q") ((= char-code 114) "r") ((= char-code 115) "s") ((= char-code 116) "t")
    ((= char-code 117) "u") ((= char-code 118) "v") ((= char-code 119) "w") ((= char-code 120) "x")
    ((= char-code 121) "y") ((= char-code 122) "z")
    ((= char-code 65) "A") ((= char-code 66) "B") ((= char-code 67) "C") ((= char-code 68) "D")
    ((= char-code 69) "E") ((= char-code 70) "F") ((= char-code 71) "G") ((= char-code 72) "H")
    ((= char-code 73) "I") ((= char-code 74) "J") ((= char-code 75) "K") ((= char-code 76) "L")
    ((= char-code 77) "M") ((= char-code 78) "N") ((= char-code 79) "O") ((= char-code 80) "P")
    ((= char-code 81) "Q") ((= char-code 82) "R") ((= char-code 83) "S") ((= char-code 84) "T")
    ((= char-code 85) "U") ((= char-code 86) "V") ((= char-code 87) "W") ((= char-code 88) "X")
    ((= char-code 89) "Y") ((= char-code 90) "Z")
    ((= char-code 48) "0") ((= char-code 49) "1") ((= char-code 50) "2") ((= char-code 51) "3")
    ((= char-code 52) "4") ((= char-code 53) "5") ((= char-code 54) "6") ((= char-code 55) "7")
    ((= char-code 56) "8") ((= char-code 57) "9")
    ((= char-code 45) "-") ((= char-code 95) "_") ((= char-code 46) ".")
    (else "?")))  ; fallback for unknown characters

(define-function split-at-dot-working (str)
  "Split string at first dot using character lookup"
  (let ((len (string-length str))
        (before "")
        (after "")
        (pos 0)
        (found-dot ()))
    
    ;; Find the dot
    (while (and (< pos len) (not found-dot))
      (if (= (string-at str pos) 46)  ; 46 is ASCII for '.'
          (set found-dot pos)
          (set pos (+ pos 1))))
    
    (if found-dot
        ;; Build before and after strings
        (let ((i 0))
          ;; Build before string
          (while (< i found-dot)
            (set before (concat-string before (char-to-string (string-at str i))))
            (set i (+ i 1)))
          ;; Build after string  
          (set i (+ found-dot 1))
          (while (< i len)
            (set after (concat-string after (char-to-string (string-at str i))))
            (set i (+ i 1)))
          (cons before after))
        ())))

(define-function parse-dotted-symbol-working (sym)
  "Parse dotted symbol into (env-name . symbol-name)"
  (if (symbol? sym)
      (let ((parts (split-at-dot-working (symbol->string sym))))
        (if parts
            (cons (string->symbol (car parts))
                  (string->symbol (cdr parts)))
            ()))
      ()))

;;; Environment structure
(define-structure <working-env> (name bindings))

(define-function make-working-env (name)
  "Create new environment"
  (let ((env (new <working-env>)))
    (set (<working-env>-name env) name)
    (set (<working-env>-bindings env) ())
    env))

(define-function working-env-define (env symbol value)
  "Define symbol in environment"
  (let ((binding (assq symbol (<working-env>-bindings env))))
    (if binding
        (set-cdr binding value)
        (set (<working-env>-bindings env)
             (cons (cons symbol value) (<working-env>-bindings env)))))
  value)

(define-function working-env-lookup (env symbol)
  "Look up symbol in environment"
  (let ((binding (assq symbol (<working-env>-bindings env))))
    (if binding (cdr binding) ())))

;;; Compile-time dotted symbol expansion
(define-function expand-dotted-working (expr env-map)
  "Expand dotted symbols in expression"
  (cond
    ((symbol? expr)
     (let ((parts (parse-dotted-symbol-working expr)))
       (if parts
           (let ((env-name (car parts))
                 (symbol-name (cdr parts)))
             (let ((env-binding (assq env-name env-map)))
               (if env-binding
                   `(working-env-lookup ,env-name ',symbol-name)
                   expr)))
           expr)))
    ((pair? expr)
     (cons (expand-dotted-working (car expr) env-map)
           (expand-dotted-working (cdr expr) env-map)))
    (else expr)))

;;; Environment context macro
(define-form with-working-env (env-bindings . body)
  "Execute body with dotted access expanded at compile time"
  (let ((expanded-body (map (lambda (form)
                              (expand-dotted-working form env-bindings))
                            body)))
    `(let ,(map (lambda (binding)
                  (list (car binding) (cdr binding)))
                env-bindings)
       ,@expanded-body)))

(progress-working "testing working dotted access system")

;;; Test the system
(define test-env (make-working-env 'test))
(working-env-define test-env 'x 42)
(working-env-define test-env 'y 17)
(working-env-define test-env 'name "test-environment")

(progress-working "created test environment")

;; Test string splitting
(println "String splitting tests:")
(println "  split-at-dot-working \"env.x\": " (split-at-dot-working "env.x"))
(println "  split-at-dot-working \"test.field\": " (split-at-dot-working "test.field"))
(println "  split-at-dot-working \"simple\": " (split-at-dot-working "simple"))

;; Test symbol parsing
(println "Symbol parsing tests:")
(println "  parse-dotted-symbol-working 'env.x: " (parse-dotted-symbol-working 'env.x))
(println "  parse-dotted-symbol-working 'test.field: " (parse-dotted-symbol-working 'test.field))
(println "  parse-dotted-symbol-working 'simple: " (parse-dotted-symbol-working 'simple))

;; Test basic environment operations
(println "Basic environment operations:")
(println "  working-env-lookup test-env 'x: " (working-env-lookup test-env 'x))
(println "  working-env-lookup test-env 'y: " (working-env-lookup test-env 'y))
(println "  working-env-lookup test-env 'name: " (working-env-lookup test-env 'name))

;; Test compile-time expansion
(println "Compile-time expansion test:")
(let ((env-map '((env . test-env)))
      (test-expr '(+ env.x env.y)))
  (println "  Original expression: " test-expr)
  (println "  Expanded expression: " (expand-dotted-working test-expr env-map))
  ;; Skip evaluation test since it needs bound env variable
  )

;; Test with-working-env macro
(println "with-working-env macro test:")
(println "  Result of (+ env.x env.y): "
         (with-working-env ((env . test-env))
           (+ env.x env.y)))

(println "  Result of (* env.x 3): "
         (with-working-env ((env . test-env))
           (* env.x 3)))

(progress-working "working dotted access system complete!")
(progress-working "ready for PEG grammar integration")