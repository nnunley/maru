;;; The simplest float32 against a claim x < T, worked out from the format and rules.l's own cost, for check.l to hold
;;; the shrinker's answer to (float.law's below_1000).  For each binade from T's up, and each count k of mantissa bits,
;;; the least value with k bits at or above T: it refutes the claim, and every value of the binade with k bits that
;;; refutes it is no less.  The cheapest of these by rules-float-cost is printed as the engine prints a refutation.
;;;   ./eval check/law-float-simplest.l T
(require "rules.l")
(define-function least-not-below (t)	; the bits of the least float32 >= T (T > 0): positive bits sort as their values
  (let ((lo 0) (hi rules-float-infinity-bits))
    (while (< lo hi) (let ((mid (/ (+ lo hi) 2))) (if (< (rules-float-of-bits mid) t) (set lo (+ mid 1)) (set hi mid))))
    lo))
(define-function simplest-not-below (t)
  (let ((b0 (least-not-below t)) (best ()))
    (for (e (& (>> b0 23) 255) 255)
      (let ((m0 (if (= e (& (>> b0 23) 255)) (& b0 rules-float-mantissa-mask) 0)))
	(for (k 0 24)
	  (let* ((step (<< 1 (- 23 k))) (m (* step (/ (+ m0 (- step 1)) step))))	; m0 rounded up to k bits
	    (and (<= m rules-float-mantissa-mask)
		 (let ((x (rules-float-of-bits (| (<< e 23) m))))
		   (and (not (< x t)) (or (not best) (rules-float-before? x best)) (set best x))))))))
    best))
(println "x=" (simplest-not-below (string->double (pop *arguments*))))
