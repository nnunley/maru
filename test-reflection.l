;;; test-reflection.l - Explore Maru's reflective properties

(require "lib/stream/port.l")

(println "=== Maru Reflection Exploration ===")
(println)

;; Test 1: type-of function
(println "Test 1: type-of various objects")
(println "type-of 42: " (type-of 42))
(println "type-of \"hello\": " (type-of "hello"))
(println "type-of 'symbol: " (type-of 'symbol))
(println "type-of '(1 2 3): " (type-of '(1 2 3)))
(println "type-of +: " (type-of +))
(println "type-of (lambda (x) x): " (type-of (lambda (x) x)))
(println)

;; Test 2: Define multimethod for compile-to-c
(println "Test 2: Define multimethod compile-to-c")
(define-selector compile-to-c)

;; Add methods for each type
(add-method compile-to-c <long> 
  '(self port)
  '((port-write port "LONG(")
    (port-write port (long->string self))
    (port-write port ")")))

(add-method compile-to-c <string>
  '(self port)
  '((port-write port "make_string(\"")
    (port-write port self)
    (port-write port "\")")))

(add-method compile-to-c <symbol>
  '(self port)
  '((port-write port "make_symbol(\"")
    (port-write port (symbol->string self))
    (port-write port "\")")))

(add-method compile-to-c <pair>
  '(self port)
  '((port-write port "cons(")
    (compile-to-c (car self) port)
    (port-write port ", ")
    (compile-to-c (cdr self) port)
    (port-write port ")")))

(add-method compile-to-c <undefined>
  '(self port)
  '((port-write port "nil")))

;; Test the multimethod
(println "\nTest 3: Using compile-to-c multimethod")
(define port (string-port))

(print "42 => ")
(compile-to-c 42 port)
(println (port-contents port))

(set port (string-port))
(print "\"hello\" => ")
(compile-to-c "hello" port)
(println (port-contents port))

(set port (string-port))
(print "'foo => ")
(compile-to-c 'foo port)
(println (port-contents port))

(set port (string-port))
(print "'(1 2 3) => ")
(compile-to-c '(1 2 3) port)
(println (port-contents port))

;; Test 4: Check available types
(println "\nTest 4: Available types")
(println "<long>: " <long>)
(println "<string>: " <string>)
(println "<symbol>: " <symbol>)
(println "<pair>: " <pair>)
(println "<expr>: " <expr>)
(println "<form>: " <form>)
(println "<subr>: " <subr>)

;; Test 5: Handling special forms and expressions
(println "\nTest 5: Special forms and expressions")
(define test-expr '(+ 1 2))
(println "Expression: " test-expr)
(println "Type: " (type-of test-expr))
(println "car type: " (type-of (car test-expr)))
(println "Is car a symbol?: " (= <symbol> (type-of (car test-expr))))

;; Test 6: Function application detection
(println "\nTest 6: Detecting function calls")
(define-function function-call? (expr)
  (and (pair? expr)
       (symbol? (car expr))))

(println "(+ 1 2) is function call? " (function-call? '(+ 1 2)))
(println "42 is function call? " (function-call? 42))
(println "'foo is function call? " (function-call? 'foo))

(println "\n=== Reflection test complete ===")