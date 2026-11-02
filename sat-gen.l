;;; sat-gen.l -- formulas whose answers are known by construction (draft-ndn-maru-sat-00
;;; [R-generated-instances]), each (number-of-variables . clauses).
;;;
;;;   (sat-pigeonhole n)            n+1 pigeons in n holes: UNSAT
;;;   (sat-queens n)                n queens on an n by n board: SAT, except for n = 2 and 3
;;;   (sat-planted n ratio seed)    random 3-SAT over n variables, ratio/10 clauses each, every
;;;                                 clause true under a planted assignment: SAT

(require "rules.l")	; rules-rand, a seeded stream

(define-function sat-pigeonhole (n)	; pigeon i in hole h is variable (i-1)n + h
  (let ((v (lambda (i h) (+ (* (- i 1) n) h))) (cs ()))
    (for (i 1 (+ n 2))
      (let ((c ()))
	(for (h 1 (+ n 1)) (push c (v i h)))
	(push cs c)))
    (for (h 1 (+ n 1))
      (for (i 1 (+ n 2)) (for (j (+ i 1) (+ n 2)) (push cs (list (- (v i h)) (- (v j h)))))))
    (cons (* (+ n 1) n) cs)))

(define-function sat-queens (n)	; a queen at row r, column c is variable rn + c + 1
  (let ((v (lambda (r c) (+ (+ (* r n) c) 1))) (cs ()))
    (for (r 0 n)
      (let ((c ()))
	(for (k 0 n) (push c (v r k)))
	(push cs c)))
    (for (a 0 (* n n))
      (for (b (+ a 1) (* n n))
	(let ((ra (/ a n)) (ca (% a n)) (rb (/ b n)) (cb (% b n)))
	  (and (or (= ra rb) (= ca cb) (= (- ra rb) (- ca cb)) (= (- ra rb) (- cb ca)))
	       (push cs (list (- (+ a 1)) (- (+ b 1))))))))
    (cons (* n n) cs)))

(define-function sat-planted (n ratio seed)
  (rules-seed seed)
  (let ((planted (array (+ n 1))) (cs ()) (m (/ (* ratio n) 10)))
    (for (v 1 (+ n 1)) (set-array-at planted v (= 0 (rules-rand 2))))
    (while (< (list-length cs) m)
      (let ((a (+ 1 (rules-rand n))) (b (+ 1 (rules-rand n))) (c (+ 1 (rules-rand n))))
	(or (= a b)
	    (= a c)
	    (= b c)
	    (let ((clause (map (lambda (x) (if (= 0 (rules-rand 2)) x (- x))) (list a b c)))
		  (holds ()))
	      (list-do l clause
		(and (if (< 0 l) (array-at planted l) (not (array-at planted (- l))))
		     (set holds 1)))
	      (and holds (push cs clause))))))
    (cons n cs)))
