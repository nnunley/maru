;;; test-eval-k-basic.l - Basic test of eval.k concepts in standard Maru
;;;
;;; This tests the core concepts of eval.k using regular Maru syntax

(println "\n=== Testing eval.k concepts ===\n")

;; Type tags (from eval.k)
(define MARU-UNDEFINED  0)
(define MARU-LONG       2)
(define MARU-STRING     4)
(define MARU-SYMBOL     5)
(define MARU-PAIR       6)

;; Simulate tagged integers
(define-function maru-tag-int (value)
  (| (<< value 1) 1))

(define-function maru-tagged-int? (obj)
  ;; Check if it's a number and if so, check the tag bit
  (and (long? obj) (& obj 1)))

(define-function maru-untag-int (obj)
  (>> obj 1))

;; Test tagged integers
(println "1. Testing tagged integers:")
(let ((tagged (maru-tag-int 42)))
  (println "  Original: 42")
  (println "  Tagged: " tagged)
  (println "  Is tagged? " (maru-tagged-int? tagged))
  (println "  Untagged: " (maru-untag-int tagged)))

;; Universal value structure simulation
(define-structure <maru-value> (tag data))

(define-function make-maru-value (tag data)
  (let ((obj (new <maru-value>)))
    (set (<maru-value>-tag obj) tag)
    (set (<maru-value>-data obj) data)
    obj))

(define-function maru-type-of (obj)
  (if obj
      (if (maru-tagged-int? obj)
          MARU-LONG
        (<maru-value>-tag obj))
    MARU-UNDEFINED))

;; Test value creation
(println "\n2. Testing value creation:")
(let ((str-val (make-maru-value MARU-STRING "hello"))
      (sym-val (make-maru-value MARU-SYMBOL 'world)))
  (println "  String value type: " (maru-type-of str-val))
  (println "  Symbol value type: " (maru-type-of sym-val))
  (println "  Tagged int type: " (maru-type-of (maru-tag-int 5))))

;; Simple evaluator test
(define-function simple-eval (exp env)
  (let ((type (maru-type-of exp)))
    (cond
      ((= type MARU-UNDEFINED) exp)
      ((= type MARU-LONG) exp)
      ((= type MARU-STRING) exp)
      ((= type MARU-SYMBOL) 
       (println "    Looking up symbol: " (<maru-value>-data exp))
       ;; Simplified lookup
       'symbol-value)
      ((= type MARU-PAIR)
       (println "    Evaluating pair")
       'pair-result)
      (else exp))))

(println "\n3. Testing simple evaluator:")
(println "  Eval number: " (simple-eval (maru-tag-int 123) ()))
(println "  Eval string: " (simple-eval (make-maru-value MARU-STRING "test") ()))
(println "  Eval symbol: " (simple-eval (make-maru-value MARU-SYMBOL 'x) ()))

;; Memory allocation test (simulated)
(println "\n4. Testing memory allocation concepts:")
(define alloc-count 0)

(define-function maru-alloc (tag size)
  (set alloc-count (+ alloc-count 1))
  (println "  Allocating type " tag " size " size " (allocation #" alloc-count ")")
  (make-maru-value tag ()))

;; Test allocations
(maru-alloc MARU-PAIR 16)
(maru-alloc MARU-STRING 32)
(println "  Total allocations: " alloc-count)

(println "\n=== eval.k concept tests complete ===\n")