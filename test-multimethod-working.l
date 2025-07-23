;;; test-multimethod-working.l - Working multi-method test

;; Test multi-method dispatch with built-in generics
(println "Testing Multi-Method Dispatch in Maru")
(println "=====================================")

;; Test 1: Built-in generic 'length'
(println "\n1. Testing 'length' generic function:")
(let ((str "hello")
      (arr (array 1 2 3 4 5)))
  (print "   Length of string \"hello\": ")
  (println (length str))
  (print "   Length of array (1 2 3 4 5): ")
  (println (length arr)))

;; Test 2: Built-in generic 'at'
(println "\n2. Testing 'at' generic function:")
(print "   Character at index 1 of \"hello\": ")
(println (at "hello" 1))
(print "   Element at index 2 of (10 20 30 40): ")
(println (at (array 10 20 30 40) 2))

;; Test 3: Built-in generic 'do-print'
(println "\n3. Testing 'do-print' generic function:")
(print "   Printing a selector: ")
(do-print length)
(println)
(print "   Printing a pair: ")
(do-print '(a b c))
(println)

;; Test 4: Define and test a custom generic
(println "\n4. Creating custom generic function:")

(define-generic size-of (obj))

;; Add methods using add-method syntax
(println "   Adding methods to size-of:")
(add-method size-of <long> '(self) '(1))
(add-method size-of <string> '(self) '((string-length self)))
(add-method size-of <array> '(self) '((array-length self)))
(add-method size-of <pair> '(self) 
  '((let ((n 0))
      (list-do x self (set n (+ n 1)))
      n)))

;; Test the custom generic
(println "   Testing size-of:")
(print "     size-of 42: ")
(println (size-of 42))
(print "     size-of \"test\": ")
(println (size-of "test"))
(print "     size-of (array 1 2 3): ")
(println (size-of (array 1 2 3)))
(print "     size-of '(a b c d): ")
(println (size-of '(a b c d)))

;; Show the design pattern
(println "\n5. Multi-Method Design Pattern:")
(println "   - Generic functions define the interface")
(println "   - Methods provide type-specific implementations")
(println "   - Dispatch is automatic based on first argument type")
(println "   - No manual type checking or switch statements!")

(println "\n6. How eval-multimethod.k Uses This Pattern:")
(println "   (define-generic maru-eval (exp ctx))")
(println "   (define-method maru-eval <maru-long> ((ctx ...)) self)")
(println "   (define-method maru-eval <maru-pair> ((ctx ...)) ...)")
(println "   (define-method maru-eval <maru-symbol> ((ctx ...)) ...)")
(println "   etc.")

(println "\nMulti-method dispatch demonstration complete!")