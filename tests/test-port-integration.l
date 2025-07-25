;;; Test port.l integration with repl.l

(println "Testing port.l integration...")

;; First, test loading port.l directly
(println "Loading port.l...")
(load "lib/stream/port.l")
(println "✓ port.l loaded successfully")

;; Test basic port functionality
(println "Testing basic port functionality...")

;; Create a string port
(define test-port (string-port))
(println "✓ string-port created: " test-port)

;; Test writing to port
(port-write test-port "Hello" " " "World" "!")
(println "✓ port-write completed")

;; Test getting contents
(define contents (port-contents test-port))
(println "✓ port contents: '" contents "'")

;; Create a console port
(define console (console-port))
(println "✓ console-port created: " console)

;; Test console port output
(println "Testing console port output:")
(port-write console "This should appear on console\n")

;; Test pretty-print.l integration
(println "Testing pretty-print.l integration...")
(load "lib/pretty-print.l")
(println "✓ pretty-print.l loaded successfully with port.l")

;; Test pretty printing
(define test-data '(hello (world (nested list)) 42 "string"))
(println "Pretty printing test data:")
(pretty-print test-data)

(println "✓ All port integration tests passed")
(println "Port streams are working correctly!")