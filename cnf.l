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
;;;   (cnf-count c)                             how many clauses
;;;   (cnf-mark c) (cnf-restore c mark)         take back what was added since mark
;;;   (cnf-free c)                              the formula's store, released

;; The clauses go to a C store (dimacs.irl's store_*) as they are made, never kept in Maru's
;; heap: a formula of 100,000 clauses there makes every collection slow.
(require "sat.l")

(define-structure <cnf> (nvars store true))
(define _store-new (sat-fn "store_new" ">p"))
(define _store-lit (sat-fn "store_lit" "pl"))
(define _store-count (sat-fn "store_count" "p>l"))
(define _store-length (sat-fn "store_length" "p>l"))
(define _store-at (sat-fn "store_at" "pl>l"))
(define _store-truncate (sat-fn "store_truncate" "pll"))
(define _store-free (sat-fn "store_free" "p"))
(define-function cnf-new () (new <cnf> 0 (_store-new) ()))
(define-function cnf-var (c)
  (set (<cnf>-nvars c) (+ 1 (<cnf>-nvars c)))
  (<cnf>-nvars c))
;; kept as sat-clean leaves it: a repeat once, a tautology not at all
(define-function cnf-clause (c lits)
  (let ((kept ())
	(taut ()))
    (list-do l lits
      (or (member? l kept)
	  (let ()
	    (and (member? (- l) kept) (set taut 1))
	    (push kept l))))
    (or taut
	(let ((f (<cnf>-store c)))
	  (list-do l (list-reverse! kept) (_store-lit f l))
	  (_store-lit f 0)))))
(define-function cnf-count (c) (_store-count (<cnf>-store c)))
(define-function cnf-clauses (c)	; the clauses as lists, read back from the store
  (let ((f (<cnf>-store c))
	(out ())
	(clause ()))
    (for (i 0 (_store-length f))
      (let ((l (_store-at f i)))
	(if (= l 0)
	    (let ()
	      (push out (list-reverse! clause))
	      (set clause ()))
	    (push clause l))))
    (list-reverse! out)))
(define-function cnf-mark (c)	; where the formula is now, to come back to
  (list (<cnf>-nvars c) (_store-length (<cnf>-store c)) (cnf-count c)))
(define-function cnf-restore (c mark)	; the clauses and variables made since mark, gone
  (set (<cnf>-nvars c) (car mark))
  (_store-truncate (<cnf>-store c) (cadr mark) (caddr mark)))
(define-function cnf-free (c) (_store-free (<cnf>-store c)))
(define-function cnf-nvars (c) (<cnf>-nvars c))
(define-function cnf-assert (c x) (cnf-clause c (list x)))
(define-function cnf-not (x) (- x))
(define-function cnf-true (c)
  (or (<cnf>-true c)
      (let ((t (cnf-var c)))
	(cnf-assert c t)
	(set (<cnf>-true c) t))))
(define-function cnf-and (c xs)
  (if (not xs) (cnf-true c)
    (let ((y (cnf-var c)))
      (list-do x xs (cnf-clause c (list (- y) x)))
      (cnf-clause c (cons y (map - xs)))
      y)))
(define-function cnf-or (c xs) (- (cnf-and c (map - xs))))
(define-function cnf-xor (c a b)
  (let ((y (cnf-var c)))
    (cnf-clause c (list (- y) a b))
    (cnf-clause c (list (- y) (- a) (- b)))
    (cnf-clause c (list y (- a) b))
    (cnf-clause c (list y a (- b)))
    y))
(define-function cnf-iff (c a b) (- (cnf-xor c a b)))
(define-function cnf-mux (c sel a b)
  (let ((y (cnf-var c)))
    (cnf-clause c (list (- sel) (- a) y))
    (cnf-clause c (list (- sel) a (- y)))
    (cnf-clause c (list sel (- b) y))
    (cnf-clause c (list sel b (- y)))
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

;;; ---- bit vectors: W literals, least significant first, two's complement.  Each gate folds
;;; where an input is known (the true literal or its negation), so a constant costs no clauses.
;;;
;;;   (cnf-bv-const c n w)                       n in w bits
;;;   (cnf-bv-add c a b) (cnf-bv-sub c a b)      (bits . overflow)
;;;   (cnf-bv-mul c a b) (cnf-bv-div c a b)      (bits . invalid): overflow, or dividing by zero
;;;   (cnf-bv-lt c a b) (cnf-bv-eq c a b)        a literal

(define-function cnf-known (c x)
  (let ((t (cnf-true c)))
    (cond ((= x t) 1)
	  ((= x (- t)) 0)
	  (else ()))))
(define-function cnf-and2 (c a b)
  (let ((ka (cnf-known c a)) (kb (cnf-known c b)))
    (cond ((= ka 0) a)
	  ((= kb 0) b)
	  ((= ka 1) b)
	  ((= kb 1) a)
	  ((= a b) a)
	  ((= a (- b)) (- (cnf-true c)))
	  (else (cnf-and c (list a b))))))
(define-function cnf-or2 (c a b) (- (cnf-and2 c (- a) (- b))))
(define-function cnf-xor2 (c a b)
  (let ((ka (cnf-known c a)) (kb (cnf-known c b)))
    (cond ((= ka 0) b)
	  ((= kb 0) a)
	  ((= ka 1) (- b))
	  ((= kb 1) (- a))
	  ((= a b) (- (cnf-true c)))
	  ((= a (- b)) (cnf-true c))
	  (else (cnf-xor c a b)))))
(define-function cnf-mux2 (c s a b)
  (let ((ks (cnf-known c s)))
    (cond ((= ks 1) a)
	  ((= ks 0) b)
	  ((= a b) a)
	  (else (cnf-mux c s a b)))))
(define-function cnf-bv-const (c n w)
  (let ((m (if (< n 0)
	       (+ n
		  (let ((p 1))
		    (for (i 0 w) (set p (* p 2)))
		    p))
	       n))
	(out ()))
    (for (i 0 w)
      (push out (if (= 1 (% m 2)) (cnf-true c) (- (cnf-true c))))
      (set m (/ m 2)))
    (list-reverse! out)))
(define-function cnf-bv-last (a) (if (cdr a) (cnf-bv-last (cdr a)) (car a)))	; the sign bit
(define-function cnf-bv-adder (c a b carry)	; (bits . carry out), unsigned
  (let ((out ()))
    (while a
      (let* ((x (car a)) (y (car b)) (h (cnf-xor2 c x y)))
	(push out (cnf-xor2 c h carry))
	(set carry (cnf-or2 c (cnf-and2 c x y) (cnf-and2 c carry h)))
	(set a (cdr a)) (set b (cdr b))))
    (cons (list-reverse! out) carry)))
(define-function cnf-bv-add (c a b)
  (let* ((r (cnf-bv-adder c a b (- (cnf-true c)))) (sa (cnf-bv-last a)) (ss (cnf-bv-last (car r))))
    ;; signs alike, the sum's not
    (cons (car r) (cnf-and2 c (- (cnf-xor2 c sa (cnf-bv-last b))) (cnf-xor2 c ss sa)))))
(define-function cnf-bv-sub (c a b)
  (let* ((r (cnf-bv-adder c a (map - b) (cnf-true c)))
	 (sa (cnf-bv-last a))
	 (ss (cnf-bv-last (car r))))
    ;; signs differ, the difference's from a's
    (cons (car r) (cnf-and2 c (cnf-xor2 c sa (cnf-bv-last b)) (cnf-xor2 c ss sa)))))
(define-function cnf-bv-eq (c a b)
  (let ((r (cnf-true c)))
    (while a
      (set r (cnf-and2 c r (- (cnf-xor2 c (car a) (car b)))))
      (set a (cdr a))
      (set b (cdr b)))
    r))
(define-function cnf-bv-lt (c a b)	; a - b is negative, or overflowed
  (let ((d (cnf-bv-sub c a b))) (cnf-xor2 c (cnf-bv-last (car d)) (cdr d))))
(define-function cnf-bv-negate (c a)
  (car (cnf-bv-adder c (map - a) (map (lambda (x) (- (cnf-true c))) a) (cnf-true c))))	; mod 2^w
(define-function cnf-bv-abs (c a)
  (let ((s (cnf-bv-last a)) (n (cnf-bv-negate c a)))
    (map (lambda (x y) (cnf-mux2 c s y x)) a n)))	; unsigned
(define-function cnf-bv-but-last (a) (if (cdr a) (cons (car a) (cnf-bv-but-last (cdr a))) ()))
(define-function cnf-or-list (c xs)
  (let ((r (- (cnf-true c))))
    (list-do x xs (set r (cnf-or2 c r x)))
    r))
(define-function cnf-tail (l n)
  (while (< 0 n)
    (set l (cdr l))
    (set n (- n 1)))
  l)
(define-function cnf-bv-signed (c s m)	; magnitude m, negative where s: (bits . doesn't fit)
  (let* ((w (list-length m)) (top (cnf-bv-last m)) (rest (cnf-or-list c (cnf-bv-but-last m))))
    (cons (map (lambda (x y) (cnf-mux2 c s y x)) m (cnf-bv-negate c m))
	  ;; positive: below 2^(w-1); negative: at most 2^(w-1)
	  (cnf-and2 c top (cnf-or2 c (- s) rest)))))
(define-function cnf-bv-mul (c a b)	; |a| |b| in 2w bits, then the sign
  (let* ((w (list-length a))
	 (f (- (cnf-true c)))
	 (ma (concat-list (cnf-bv-abs c a) (map (lambda (x) f) a)))
	 (mb (cnf-bv-abs c b))
	 (acc (map (lambda (x) f) ma))
	 (shift ma))
    (list-do bit mb
      (set acc (car (cnf-bv-adder c acc (map (lambda (x) (cnf-and2 c bit x)) shift) f)))
      (set shift (cons f (cnf-bv-but-last shift))))
    (let* ((low (let ((out ()) (l acc))
		  (for (i 0 w)
		    (push out (car l))
		    (set l (cdr l)))
		  (list-reverse! out)))
	   (high (cnf-tail acc w))
	   (s (cnf-xor2 c (cnf-bv-last a) (cnf-bv-last b)))
	   (r (cnf-bv-signed c s low)))
      (cons (car r) (cnf-or2 c (cdr r) (cnf-or-list c high))))))
;; truncating, as Maru's /: |a| / |b| by restoring division, then the sign
(define-function cnf-bv-div (c a b)
  (let* ((f (- (cnf-true c)))
	 (ma (cnf-bv-abs c a))
	 (mb (concat-list (cnf-bv-abs c b) (list f)))
	 (r (map (lambda (x) f) mb))
	 (q ()))
    (list-do bit (let ((out ()))
		   (list-do x ma (push out x))
		   out)	; most significant first
      (set r (cons bit (cnf-bv-but-last r)))
      ;; no borrow: r >= |b|
      (let* ((d (cnf-bv-adder c r (map - mb) (cnf-true c))) (ge (cdr d)))
	(push q ge)
	(set r (map (lambda (x y) (cnf-mux2 c ge y x)) r (car d)))))
    (let* ((s (cnf-xor2 c (cnf-bv-last a) (cnf-bv-last b)))
	   (res (cnf-bv-signed c s q))
	   (zero (cnf-bv-eq c b (map (lambda (x) f) b))))
      (cons (car res) (cnf-or2 c zero (cdr res))))))
