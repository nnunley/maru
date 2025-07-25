;;; Test what's available in basic eval2

(println "Basic eval2 functionality test:")

;; Test define
(define test-var 42)
(println "define works, test-var:" test-var)

;; Test lambda
(define test-func (lambda (x) (+ x 1)))
(println "lambda works, test-func(5):" (test-func 5))

;; Check if define-function is available
(println "define-function available:" (if (defined? 'define-function) "yes" "no"))

;; Check if define-form is available  
(println "define-form available:" (if (defined? 'define-form) "yes" "no"))

;; Test basic functions
(println "Basic functions:")
(println "  cons available:" (if (defined? 'cons) "yes" "no"))
(println "  car available:" (if (defined? 'car) "yes" "no"))
(println "  cdr available:" (if (defined? 'cdr) "yes" "no"))
(println "  list available:" (if (defined? 'list) "yes" "no"))
(println "  + available:" (if (defined? '+) "yes" "no"))
(println "  = available:" (if (defined? '=) "yes" "no"))
(println "  if available:" (if (defined? 'if) "yes" "no"))
(println "  cond available:" (if (defined? 'cond) "yes" "no"))