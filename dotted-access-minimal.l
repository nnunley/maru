;;; Minimal Dotted Environment Access System  
;;; Works with existing Maru string functions

(define-function progress-min args (apply println (cons "; Minimal Dot: " args)))

(progress-min "implementing minimal dotted access")

;;; Manual string splitting for dotted symbols
(define-function split-at-dot (str)
  "Split string at first dot, return (before . after) or () if no dot"
  (let ((len (string-length str))
        (before "")
        (after "")
        (pos 0)
        (found-dot ()))
    
    ;; Find the dot
    (while (and (< pos len) (not found-dot))
      (if (= (string-at str pos) ?.)
          (set found-dot pos)
          (set pos (+ pos 1))))
    
    (if found-dot
        ;; Build before and after strings character by character
        (let ((i 0))
          ;; Build before string
          (while (< i found-dot)
            (set before (concat-string before (string (string-at str i))))
            (set i (+ i 1)))
          ;; Build after string  
          (set i (+ found-dot 1))
          (while (< i len)
            (set after (concat-string after (string (string-at str i))))
            (set i (+ i 1)))
          (cons before after))
        ())))

(define-function parse-dotted-symbol (sym)
  "Parse dotted symbol into (env-name . symbol-name)"
  (if (symbol? sym)
      (let ((parts (split-at-dot (symbol->string sym))))
        (if parts
            (cons (string->symbol (car parts))
                  (string->symbol (cdr parts)))
            ()))
      ()))

;;; Simple environment for testing
(define *test-env* ())

(define-function env-define (symbol value)
  "Define symbol in test environment"
  (let ((binding (assq symbol *test-env*)))
    (if binding
        (set-cdr binding value)
        (set *test-env* (cons (cons symbol value) *test-env*))))
  value)

(define-function env-lookup (symbol)
  "Look up symbol in test environment"
  (let ((binding (assq symbol *test-env*)))
    (if binding (cdr binding) ())))

;;; Manual dotted access function
(define-function dot-get (dotted-symbol)
  "Get value using dotted symbol like 'env.name'"
  (let ((parts (parse-dotted-symbol dotted-symbol)))
    (if parts
        (let ((env-name (car parts))
              (symbol-name (cdr parts)))
          ;; For now, just use the global test environment
          ;; In real implementation, would look up the environment
          (if (= env-name 'env)
              (env-lookup symbol-name)
              ()))
        ())))

(progress-min "testing minimal system")

;; Test string splitting
(println "String splitting tests:")
(println "  split-at-dot \"hello.world\": " (split-at-dot "hello.world"))
(println "  split-at-dot \"env.x\": " (split-at-dot "env.x"))
(println "  split-at-dot \"simple\": " (split-at-dot "simple"))

;; Test symbol parsing
(println "Symbol parsing tests:")
(println "  parse-dotted-symbol 'env.x: " (parse-dotted-symbol 'env.x))
(println "  parse-dotted-symbol 'test.field: " (parse-dotted-symbol 'test.field))
(println "  parse-dotted-symbol 'simple: " (parse-dotted-symbol 'simple))

;; Test environment operations
(env-define 'x 42)
(env-define 'y "hello")
(env-define 'test "world")

(println "Environment tests:")
(println "  env-lookup 'x: " (env-lookup 'x))
(println "  env-lookup 'y: " (env-lookup 'y))

;; Test dotted access
(println "Dotted access tests:")
(println "  dot-get 'env.x: " (dot-get 'env.x))
(println "  dot-get 'env.y: " (dot-get 'env.y))
(println "  dot-get 'env.test: " (dot-get 'env.test))

;; Demonstrate concept for PEG grammars
(println "PEG grammar concept:")
(env-define 'letter "letter-rule")
(env-define 'digit "digit-rule")
(env-define 'identifier "identifier-rule")

(println "  Grammar rules accessible as:")
(println "    env.letter: " (dot-get 'env.letter))
(println "    env.digit: " (dot-get 'env.digit))
(println "    env.identifier: " (dot-get 'env.identifier))

(progress-min "minimal dotted access system working")
(progress-min "ready for PEG grammar environment integration")