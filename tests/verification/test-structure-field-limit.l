;;; test-structure-field-limit.l - Testing define-structure field limits

(load "boot.l")

(println "=== TESTING DEFINE-STRUCTURE FIELD LIMITS ===")
(println)

;; Test 1: Small structure (should work)
(println "Test 1: Small structure (5 fields)")
(define-structure <small> (a b c d e))
(let ((s (new <small> 1 2 3 4 5)))
  (println "Success - created: " s)
  (println "  a=" (<small>-a s) " b=" (<small>-b s)))
(println)

;; Test 2: Medium structure (10 fields)
(println "Test 2: Medium structure (10 fields)")
(define-structure <medium> 
  (f1 f2 f3 f4 f5 f6 f7 f8 f9 f10))
(let ((m (new <medium> 1 2 3 4 5 6 7 8 9 10)))
  (println "Success - created: " m)
  (println "  f1=" (<medium>-f1 m) " f10=" (<medium>-f10 m)))
(println)

;; Test 3: Large structure (20 fields)
(println "Test 3: Large structure (20 fields)")
(define-structure <large>
  (f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
   f11 f12 f13 f14 f15 f16 f17 f18 f19 f20))
(println "Structure defined successfully")
(println "Attempting to create with 20 fields...")
(let ((l (new <large> 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20)))
  (println "Success - created: " l)
  (println "  f1=" (<large>-f1 l) " f20=" (<large>-f20 l)))
(println)

;; Test 4: Very large structure (30 fields)
(println "Test 4: Very large structure (30 fields)")
(define-structure <very-large>
  (f1 f2 f3 f4 f5 f6 f7 f8 f9 f10
   f11 f12 f13 f14 f15 f16 f17 f18 f19 f20
   f21 f22 f23 f24 f25 f26 f27 f28 f29 f30))
(println "Structure defined successfully")
(println "Attempting to create with 30 fields...")
;; This might fail with "too many arguments"
(let ((vl (new <very-large> 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30)))
  (println "Success - created: " vl)
  (println "  f1=" (<very-large>-f1 vl) " f30=" (<very-large>-f30 vl)))
(println)

;; Test where we encountered the issue - emit-c structures
(println "Test 5: Compiler structure from emit.l")
(define-structure <compiler> 
  (env param-counter arg-counter arg-limit 
   tmp-counter tmp-limit temps epilogue 
   asm pc section))
(println "11 field structure defined successfully")
(let ((c (new <compiler> 'e 0 0 0 0 0 () () () 0 'text)))
  (println "Success - created: " c)
  (println "  env=" (<compiler>-env c) " section=" (<compiler>-section c)))
(println)

(println "=== FIELD LIMIT INVESTIGATION COMPLETE ===")
(println)
(println "Summary: All structures created successfully!")
(println "No apparent field limit found in define-structure itself.")