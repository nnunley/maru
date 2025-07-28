;;; demo-port-dispatch.l - Demonstrate Maru's Port Multiple Dispatch System
;;;
;;; This shows the REAL intent of "port streams" - multiple dispatch for different data types

(println "🎯 Maru Port Multiple Dispatch System Demo")
(println "==========================================")

;; Load the port and pretty-print infrastructure
(load "lib/stream/port.l")
(load "lib/pretty-print.l")

(println "\n1. Understanding Port Structure:")
(println "   Ports are data structures that support multiple dispatch")

;; Create different types of ports
(define string-port-example (string-port))
(define console-port-example (console-port))

(print "   String port:  ")
(dump string-port-example)
(print "   Console port: ")
(dump console-port-example)

(println "\n2. Multiple Dispatch in Action:")
(println "   Different types use different printing methods via define-method")

;; Test data of different types
(define test-data (list 
  42                    ; <long>
  "hello world"         ; <string>  
  'test-symbol          ; <symbol>
  '(a nested (list structure))  ; <pair>
  (array 1 2 3 4 5)))   ; <array>

(println "\n   Standard print:")
(list-do item test-data
  (print "     ")
  (print item)
  (println))

(println "\n   Pretty print (multiple dispatch):")
(list-do item test-data
  (print "     ")
  (pretty-print item))

(println "\n3. Port Output Control:")
(println "   Same dispatch system, different output destinations")

(println "\n   To console:")
(let ((port (console-port)))
  (print "     Result: ")
  (do-pretty '(code (with multiple) dispatch) port 0)
  (println))

(println "\n   To string buffer:")
(let ((port (string-port)))
  (do-pretty '(captured (in string) buffer) port 0)
  (println "     Captured: '" (port-contents port) "'"))

(println "\n4. Type-Specific Method Dispatch:")
(println "   Each type has its own do-pretty method")

;; Demonstrate that different types use different methods
(define demo-types (list 42 "string" 'symbol '(1 2 3)))

(list-do item demo-types
  (let ((port (string-port))
        (type-name (array-at %type-names (type-of item))))
    (print "     <" type-name "> " item " -> ")
    (do-pretty item port 0)
    (println "'" (port-contents port) "'")))

(println "\n5. This is NOT just I/O redirection!")
(println "   It's a full multiple dispatch system where:")
(println "   • Each data type can define its own formatting behavior")
(println "   • Methods are selected automatically based on object type") 
(println "   • Port abstraction handles output destination")
(println "   • Pretty printing uses structured formatting rules")

(println "\n✨ Multiple dispatch enables type-specific behavior without switch statements!")
(println "✨ Ports provide flexible output control with the same dispatch system!")
(println "✨ This is object-oriented programming with method dispatch!")