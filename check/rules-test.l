;;; The rules engine's own checks (law_engine in check.l).
(load "rules.l")
(define ok 1)
(define-function expect (what c) (or c (and (println "FAIL " what) (set ok ()))))
(define-function all-in? (l all) (let ((y 1)) (list-do e l (or (rules-has? e all) (set y ()))) y))

(define rs '((tm (term $x) (in $x $t ((a . N) (b . N))))
	     (tp (term (pair $a $b)) (term $a) (term $b))))
(define all (rules-enumerate rs '(term $v) 1))
(rules-seed 7)
(let ((gens (list (rules-generate rs '(term $v) 1) (rules-generate rs '(term $v) 1) (rules-generate rs '(term $v) 1))))
  (expect "generated values are enumerated" (all-in? gens all))
  (expect "generated values hold" (let ((y 1)) (list-do g gens (or (rules-holds? rs (list 'term g) 1) (set y ()))) y)))
(expect "enumeration is finite and has atoms" (and (rules-has? 'a all) (rules-has? '(pair a b) all)))
(expect "a non-member does not hold" (not (rules-holds? rs '(term c) 1)))

;; size bound: at size 0 the recursive rule never applies
(expect "size 0 excludes recursion" (and (rules-holds? rs '(term a) 0) (not (rules-holds? rs '(term (pair a b)) 0))))
(expect "size 1 allows it" (rules-holds? rs '(term (pair a b)) 1))

;; occurs check
(expect "x does not unify with (f x)"
  (let ((v (new <lv> 9000))) (not (unify v (list 'f v) *rules-empty*))))

;; builtins
(expect "in binds t" (equal (rules-enumerate '((ty (ty $x $t) (in $x $t ((a . Number))))) '(ty a $t) 0) '(Number)))
(expect "number enumerates" (equal (rules-enumerate () '(number $n) 0) '("0" "1" "2" "0.5" "10")))
(expect "number checks" (and (rules-holds? () '(number "2") 0) (not (rules-holds? () '(number "3") 0))))
(expect "= unifies" (equal (rules-enumerate () '(= $x 5) 0) '(5)))

;; seeded
(rules-seed 3) (define g1 (rules-generate rs '(term $v) 1))
(rules-seed 3) (define g2 (rules-generate rs '(term $v) 1))
(expect "same seed, same value" (equal g1 g2))
(expect "fired names recorded" (rules-fired))

(println (if ok "rules ok" "rules FAILED"))
