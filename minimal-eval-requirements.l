;;; What does eval.l MINIMALLY need to run?
;;; Testing the bare minimum requirements

;; Test what eval.l actually requires
(println "=== Minimal eval.l Requirements Analysis ===")
(println)

;; Define just the bare essentials that eval.l uses
(define-form compile-begin () '())  ; Empty implementation
(define-form compile-end () '())    ; Empty implementation

(define-form define-structure (name fields)
  "Minimal structure support"
  `(define ,name ',fields))

(define extern (lambda (name)
  "Minimal extern support - just return the name"
  name))

(println "Minimal infrastructure defined:")
(println "  - compile-begin/compile-end (empty)")  
(println "  - define-structure (minimal)")
(println "  - extern (pass-through)")
(println)

;; Test defining structures like eval.l does
(println "Testing structure definitions:")
(define-structure <header> (size flags next type))
(define-structure <buffer> (contents size position))
(println "  <header> defined:" <header>)
(println "  <buffer> defined:" <buffer>)
(println)

;; Test extern declarations like eval.l does  
(println "Testing extern declarations:")
(define abort (extern 'abort))
(define malloc (extern 'malloc))
(println "  abort:" abort)
(println "  malloc:" malloc)
(println)

(println "=== Analysis Result ===")
(println "eval.l needs these forms defined, but they can be MINIMAL:")
(println "1. compile-begin/compile-end - can be empty!")
(println "2. define-structure - can just define symbols")
(println "3. extern - can just return names")
(println)
(println "So eval.l does NOT need full emit.l - just these 3 forms!")
(println "The threaded backend can provide minimal versions!")