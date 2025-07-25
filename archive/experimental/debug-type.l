;; Debug what type 11 is
(require "core/compiler/emit.l")

(println "Testing types:")
(println "if form type: " (type-of if))
(println "Fixed<if> type: " (type-of Fixed<if>))
(println "symbol type: " (type-of 'test))
(println "long type: " (type-of 42))
(println "variable type: ")

;; Create a test expression
(compile-begin)
(define test-var 123)
(println "test-var type: " (type-of test-var))
(compile-end)

;; Test parsing an if expression
(println "Parsed (if 1 2 3): ")
(dumpln (eval '(quote (if 1 2 3))))
(println "Type of car: " (type-of (car (eval '(quote (if 1 2 3))))))