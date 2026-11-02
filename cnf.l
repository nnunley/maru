;;; cnf.l -- clauses built from gates (draft-ndn-maru-sat-00): each gate is a fresh variable
;;; tied to its inputs by Tseitin's clauses, and returns its literal.
;;;
;;;   (cnf-new) (cnf-var c)                     a builder; a fresh variable
;;;   (cnf-true c) (cnf-not x)                  true; a literal's negation
;;;   (cnf-and c xs) (cnf-or c xs)              conjunction, disjunction of literals
;;;   (cnf-xor c a b) (cnf-iff c a b)           exclusive or, equivalence
;;;   (cnf-mux c sel a b)                       a if sel, else b
;;;   (cnf-assert c x)                          x must hold
;;;   (cnf-exactly-one c xs)                    exactly one of xs, by a sequential counter
;;;   (cnf-clauses c) (cnf-nvars c)             what the formula is

(define-structure <cnf> (nvars clauses true))
(define-function cnf-new () (new <cnf> 0 () ()))
(define-function cnf-var (c) (set (<cnf>-nvars c) (+ 1 (<cnf>-nvars c))) (<cnf>-nvars c))
(define-function cnf-clause (c lits) (set (<cnf>-clauses c) (cons lits (<cnf>-clauses c))))
(define-function cnf-clauses (c) (let ((out ())) (list-do k (<cnf>-clauses c) (push out k)) out))
(define-function cnf-nvars (c) (<cnf>-nvars c))
(define-function cnf-assert (c x) (cnf-clause c (list x)))
(define-function cnf-not (x) (- x))
(define-function cnf-true (c)
  (or (<cnf>-true c) (let ((t (cnf-var c))) (cnf-assert c t) (set (<cnf>-true c) t))))
(define-function cnf-and (c xs)
  (if (not xs) (cnf-true c)
    (let ((y (cnf-var c)))
      (list-do x xs (cnf-clause c (list (- y) x)))
      (cnf-clause c (cons y (map - xs)))
      y)))
(define-function cnf-or (c xs) (- (cnf-and c (map - xs))))
(define-function cnf-xor (c a b)
  (let ((y (cnf-var c)))
    (cnf-clause c (list (- y) a b)) (cnf-clause c (list (- y) (- a) (- b)))
    (cnf-clause c (list y (- a) b)) (cnf-clause c (list y a (- b)))
    y))
(define-function cnf-iff (c a b) (- (cnf-xor c a b)))
(define-function cnf-mux (c sel a b)
  (let ((y (cnf-var c)))
    (cnf-clause c (list (- sel) (- a) y)) (cnf-clause c (list (- sel) a (- y)))
    (cnf-clause c (list sel (- b) y)) (cnf-clause c (list sel b (- y)))
    y))
(define-function cnf-exactly-one (c xs)	; one at least, and at most one by s_i = "some of x_1..x_i"
  (cnf-clause c xs)
  (let ((prev ()))
    (list-do x xs
      (and prev (cnf-clause c (list (- x) (- prev))))
      (let ((s (cnf-var c)))
	(cnf-clause c (list (- x) s))
	(and prev (cnf-clause c (list (- prev) s)))
	(set prev s)))))
