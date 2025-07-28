;;; test-struct-limits.l - Test structure field limits

(println "Testing structure field limits...")

;; Test with increasing number of fields
(println "\n1 field:")
(define-structure <test1> (a))
(println "Success")

(println "\n2 fields:")
(define-structure <test2> (a b))
(println "Success")

(println "\n3 fields:")
(define-structure <test3> (a b c))
(println "Success")

(println "\n4 fields:")
(define-structure <test4> (a b c d))
(println "Success")

(println "\n5 fields:")
(define-structure <test5> (a b c d e))
(println "Success")

(println "\n6 fields:")
(define-structure <test6> (a b c d e f))
(println "Success")

(println "\n7 fields:")
(define-structure <test7> (a b c d e f g))
(println "Success")

(println "\n8 fields:")
(define-structure <test8> (a b c d e f g h))
(println "Success")

(println "\n9 fields:")
(define-structure <test9> (a b c d e f g h i))
(println "Success")

(println "\n10 fields:")
(define-structure <test10> (a b c d e f g h i j))
(println "Success")

(println "\nAll tests passed!")