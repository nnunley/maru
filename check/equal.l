;;; Maru's equal and equal-hash are selectors, each type's equality defined with the type: numbers by value (2 is 2.0),
;;; strings by their text, pairs and arrays by their elements, anything else by identity unless its type says otherwise;
;;; and equal values hash alike, so a hash table (hash.l) finds a key by an equal one.
(require "hash.l")
(define ok 1)
(define-function same-list (a b)	; lists of atoms, compared with = alone (equal is what is under test)
  (while (and (pair? a) (pair? b) (= (car a) (car b))) (set a (cdr a)) (set b (cdr b)))
  (and (not a) (not b)))
(define-function expect (what got want)
  (or (if (pair? want) (same-list got want) (= got want)) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function a (l) (list->array l))
(expect "arrays by their elements" (list (equal (a '(1 2)) (a '(1 2))) (equal (a '(1 2)) (a '(1 3))) (equal (a '(1)) (a '(1 2))))
	'(t () ()))
(expect "numbers by value, strings by text, pairs by elements"
	(list (equal 2 2.0) (equal "ab" "ab") (equal (list 1 (a '(2))) (list 1 (a '(2)))) (equal (list 1 2) (list 1 2 3)))
	'(t t t ()))
(expect "symbols by identity" (list (equal 'x 'x) (equal 'x 'y)) '(t ()))
(let ((long ()) (other ()))
  (for (i 0 100000) (push long i) (push other i))
  (expect "a long list compares in a loop, not a frame per element" (equal long other) 't))
(expect "equal values hash alike"
	(list (= (equal-hash 2) (equal-hash 2.0)) (= (equal-hash "ab") (equal-hash (concat-string "a" "b")))
	      (= (equal-hash (a '(1 2))) (equal-hash (a '(1 2)))) (= (equal-hash (list 1 (a '(2)))) (equal-hash (list 1 (a '(2))))))
	'(t t t t))
;; a type of one's own says what its equality is, and a table then finds a key by an equal one
(define-structure <check-point> (x y))
(define-method equal <check-point> (b) (and (= <check-point> (type-of b)) (= self.x (<check-point>-x b)) (= self.y (<check-point>-y b))))
(define-method equal-hash <check-point> () (+ (* 31 (equal-hash self.x)) (equal-hash self.y)))
(let ((t (equal-hash-table)))
  (hash-at-put t (new <check-point> 3 4) 'found)
  (expect "a type's own equality, in a table" (list (equal (new <check-point> 3 4) (new <check-point> 3 4)) (hash-at t (new <check-point> 3 4)))
	  '(t found)))
(println (if ok "equal ok" "equal FAILED"))
