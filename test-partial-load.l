;;; Test loading emit.l in parts to find where it fails

(println "Loading osdefs.k...")
(require "osdefs.k")
(println "osdefs.k loaded")

(println "About to evaluate first part of emit.l...")

;;; Copy just the beginning
(define *emit-backend* 'x86)
(println "*emit-backend* defined: " *emit-backend*)

;;; Test defining a form
(define-form test-form () `(println "test form works"))
(println "define-form works")

(test-form)

;;; Now test compile-begin
(define-form compile-begin ()	`(set *globals* (environment *globals*)))
(println "compile-begin defined: " (if (defined? 'compile-begin) "yes" "no"))