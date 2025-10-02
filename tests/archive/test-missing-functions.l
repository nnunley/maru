;;; Test which functions are missing

(println "Testing function availability:")

;; Test for
(println "for available:" (if (defined? 'for) "yes" "no"))

;; Test while  
(println "while available:" (if (defined? 'while) "yes" "no"))

;; Test string-append
(println "string-append available:" (if (defined? 'string-append) "yes" "no"))

;; Test number->string
(println "number->string available:" (if (defined? 'number->string) "yes" "no"))

;; Test long->string
(println "long->string available:" (if (defined? 'long->string) "yes" "no"))

;; Test concat-string
(println "concat-string available:" (if (defined? 'concat-string) "yes" "no"))

;; Test null?
(println "null? available:" (if (defined? 'null?) "yes" "no"))

;; Test reverse
(println "reverse available:" (if (defined? 'reverse) "yes" "no"))