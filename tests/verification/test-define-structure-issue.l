;;; test-define-structure-issue.l - Reproduce define-structure field issue

;; The issue we saw was when fields were passed as separate arguments
;; instead of in a list

(load "boot.l")

(println "=== TESTING DEFINE-STRUCTURE FIELD ISSUE ===")
(println)

;; Correct way - fields in a list
(println "Test 1: Correct syntax (fields in list)")
(define-structure <correct> (a b c d e))
(println "Success!")
(println)

;; What happens if we accidentally pass fields as separate arguments?
(println "Test 2: Incorrect syntax (fields as separate arguments)")
(println "Attempting: (define-structure <incorrect> a b c d e)")
(println)

;; This would cause the error:
;; (define-structure <incorrect> a b c d e)

;; Let's see what define-structure expects
(println "Checking define-structure definition...")
(println)

;; From boot.l, define-structure is defined as:
;; (define-form define-structure (name fields) ...)
;; It expects exactly 2 arguments: name and fields (as a list)

;; The real issue in emit-c-comprehensive.l was this line:
;; (define-structure <c-backend> 
;;   output-port indent-level temp-counter context pass
;;   signatures globals environment ffi-functions
;;   profiling-enabled profile-entries)

;; Missing parentheses around the fields!

(println "The issue was MISSING PARENTHESES around fields!")
(println)
(println "Wrong: (define-structure <name> field1 field2 field3 ...)")
(println "Right: (define-structure <name> (field1 field2 field3 ...))")
(println)

;; Let's verify large structures work fine with correct syntax
(println "Test 3: Very large structure with correct syntax")
(define-structure <huge>
  (f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
   f11 f12 f13 f14 f15 f16 f17 f18 f19 f20
   f21 f22 f23 f24 f25 f26 f27 f28 f29 f30
   f31 f32 f33 f34 f35 f36 f37 f38 f39 f40
   f41 f42 f43 f44 f45 f46 f47 f48 f49 f50))
(println "50 field structure defined successfully!")

;; Create instance with all fields
(let ((h (new <huge> 
          1 2 3 4 5 6 7 8 9 10
          11 12 13 14 15 16 17 18 19 20
          21 22 23 24 25 26 27 28 29 30
          31 32 33 34 35 36 37 38 39 40
          41 42 43 44 45 46 47 48 49 50)))
  (println "Created instance with 50 fields!")
  (println "  f1=" (<huge>-f1 h) " f50=" (<huge>-f50 h)))

(println)
(println "=== CONCLUSION ===")
(println "There is NO field limit in define-structure!")
(println "The error was due to MISSING PARENTHESES around the field list.")
(println "define-structure expects exactly 2 arguments: name and (fields)")
(println "====================================================")