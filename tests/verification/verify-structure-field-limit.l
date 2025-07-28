;;; verify-structure-field-limit.l - Verify define-structure has no field limit

(load "boot.l")

(println "=== VERIFYING DEFINE-STRUCTURE FIELD LIMIT ===")
(println)

;; The "too many arguments" error comes from passing fields as separate
;; arguments instead of as a list. Let's verify this.

;; define-structure expects: (name fields)
;; where fields is a LIST of field names

;; Test: Can we create very large structures?
(println "Creating structure with 100 fields...")
(define-structure <massive>
  (f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
   f11 f12 f13 f14 f15 f16 f17 f18 f19 f20
   f21 f22 f23 f24 f25 f26 f27 f28 f29 f30
   f31 f32 f33 f34 f35 f36 f37 f38 f39 f40
   f41 f42 f43 f44 f45 f46 f47 f48 f49 f50
   f51 f52 f53 f54 f55 f56 f57 f58 f59 f60
   f61 f62 f63 f64 f65 f66 f67 f68 f69 f70
   f71 f72 f73 f74 f75 f76 f77 f78 f79 f80
   f81 f82 f83 f84 f85 f86 f87 f88 f89 f90
   f91 f92 f93 f94 f95 f96 f97 f98 f99 f100))

(println "Structure defined successfully!")
(println)

;; The issue: When you forget parentheses
(println "The REAL issue - missing parentheses:")
(println)
(println "WRONG:")
(println "  (define-structure <foo> a b c d e)")
(println "  This passes 6 arguments to define-structure!")
(println)
(println "RIGHT:")  
(println "  (define-structure <foo> (a b c d e))")
(println "  This passes 2 arguments: name and fields list")
(println)

;; Show the error in action (commented out to avoid error)
;; (define-structure <bad> a b c d e f g h i j k)
;; This would give: "error: too many arguments applying Expr.define-structure"

(println "=== CONCLUSION ===")
(println)
(println "There is NO field limit in define-structure!")
(println)
(println "The error 'too many arguments applying Expr.define-structure'")
(println "means you forgot the parentheses around the field list.")
(println)
(println "define-structure expects exactly 2 arguments:")
(println "  1. Structure name")
(println "  2. List of fields (in parentheses!)")
(println)
(println "This was a SYNTAX ERROR, not a field limit!")
(println "==================================================")