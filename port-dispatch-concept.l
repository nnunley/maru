;;; port-dispatch-concept.l - Demonstrate the Real Intent of Maru Port Streams
;;;
;;; Shows how multiple dispatch works with ports for different data types

(println "🎯 The REAL Intent of Port Streams: Multiple Dispatch")
(println "===================================================")

;; Load Maru's multiple dispatch infrastructure  
(load "lib/stream/port.l")
(load "lib/pretty-print.l")

(println "\n1. Understanding the Architecture:")
(println "   Port streams = Data structures + Multiple dispatch + Output abstraction")

(println "\n2. How Multiple Dispatch Works:")
(println "   define-method creates type-specific behavior")

;; Show existing methods for different types
(println "\n   Existing do-pretty methods handle different types:")
(define test-values (list 42 "hello" 'symbol '(a b c) (array 1 2 3)))

(list-do value test-values
  (let ((type-name (array-at %type-names (type-of value))))
    (print "     <" type-name "> " value " -> ")
    (let ((port (string-port)))
      (do-pretty value port 0)
      (println "'" (port-contents port) "'"))))

(println "\n3. Port Abstraction for Output Control:")
(println "   Same dispatch, different destinations")

(let ((test-data '(example (nested structure) with "various" types)))
  (println "\n   To console:")
  (print "     ")
  (do-pretty test-data (console-port) 0)
  (println)
  
  (println "\n   To string buffer:")
  (let ((port (string-port)))
    (do-pretty test-data port 0)
    (println "     Captured: '" (port-contents port) "'")))

(println "\n4. Adding New Types with Custom Dispatch:")
(println "   Easy to extend with new data types")

;; Define a custom result type
(define-structure <computation-result> (input output operation))

;; Add a multiple dispatch method for our new type
(define-method do-pretty <computation-result> (port col)
  (port-write port "[" self.operation ": " self.input " => " self.output "]"))

;; Test the custom type
(define result (new <computation-result> 5 25 "square"))
(print "\n   Custom type: ")
(do-pretty result (console-port) 0)
(println)

(let ((port (string-port)))
  (do-pretty result port 0)
  (println "   Captured: '" (port-contents port) "'"))

(println "\n5. This is Object-Oriented Programming:")
(println "   • Each type defines its own behavior via define-method")
(println "   • Automatic method selection based on object type") 
(println "   • No switch statements or type checking needed")
(println "   • Easy to extend with new types and behaviors")
(println "   • Port abstraction separates formatting from output destination")

(println "\n6. Integration with Evaluation:")
(println "   An evaluator could use this system to:")
(println "   • Define custom result types with specialized formatting")
(println "   • Leverage existing type-specific pretty printing")
(println "   • Support multiple output destinations (REPL, files, strings)")
(println "   • Extend easily with new data types and display formats")

(println "\n✨ Key Insight: This is NOT just I/O redirection!")
(println "✨ It's a complete multiple dispatch system for type-specific behavior!")
(println "✨ Port streams = Multiple dispatch + Output abstraction!")

(println "\n🎉 Now I understand the real intent of 'port streams' in Maru!")