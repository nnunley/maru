;;; A small first-order logic engine.  One rule set runs three ways: generate
;;; (rules in random order, one solution), check (rules in order, does the goal
;;; hold) and enumerate (every solution).  A rule is (name conclusion premise...),
;;; a rule set a list of rules, and $x a logic variable.  Rule sets are passed
;;; in, never global, so mutants can swap them.  See doc/rfc/draft-ndn-maru-laws-and-rules-00.md.
(require "hash.l")	; seen solutions, by equal

;; seeded, replayable.  rules-fired names the rules used in successful generate and check derivations, rules-used lists them.
(define *rules-seed* 42)
(define *rules-fired* ())	; rule names used in successful derivations
(define *rules-used* ())	; the rules themselves, as facts share their relation's name
;; the generator: splitmix64 (Steele, Lea and Flood), 32 bits a step, so a draw reaches every index of a large domain
;; (an LCG modulo 65537 reached none past 65536) and a float's bits are independent
(define *rules-state* 42)
(define-function rules-seed (n) (set *rules-seed* n) (set *rules-state* n) (set *rules-fired* ()) (set *rules-used* ()))
(define-function rules-fired () *rules-fired*)
(define-function rules-used () *rules-used*)
(define-function rules-lsr (z k) (& (>> z k) (- (<< 1 (- 64 k)) 1)))	; a logical shift right of a 64-bit word
(define-function rules-bits32 ()	; 32 random bits
  (set *rules-state* (+ *rules-state* -7046029254386353131))	; 0x9E3779B97F4A7C15
  (let ((z *rules-state*))
    (set z (* (^ z (rules-lsr z 30)) -4658895280553007687))	; 0xBF58476D1CE4E5B9
    (set z (* (^ z (rules-lsr z 27)) -7723592293110705685))	; 0x94D049BB133111EB
    (& (^ z (rules-lsr z 31)) 4294967295)))
(define-function rules-rand (n) (% (rules-bits32) n))
(define *rules-random* ())
;; a list's values one at a time, the first f answers anything for: in order when checking or enumerating, in a random
;; order when generating, drawn lazily (Fisher-Yates, one swap per value tried, the swaps kept aside), so a draw costs
;; the values it tries rather than the list's length; a long list's array is made once
(define rules-arrays (identity-hash-table))
(define-function rules-array (l)
  (or (hash-at rules-arrays l)
      (if (< (list-length l) 64) (list->array l)
	(hash-at-put rules-arrays l (list->array l)))))
(define-function rules-first-of (l f)
  (let ((r ()))
    (if (not *rules-random*)
	(while (and l (not r)) (set r (f (car l))) (set l (cdr l)))
      (let* ((a (rules-array l)) (n (array-length a)) (moved (equal-hash-table)) (i 0)
	     (at (lambda (k) (if (hash-includes? moved k) (hash-at moved k) (array-at a k)))))
	(while (and (< i n) (not r))
	  (let* ((j (+ i (rules-rand (- n i)))) (v (at j)))
	    (hash-at-put moved j (at i))
	    (set r (f v))
	    (set i (+ i 1))))))
    r))
(define-function rules-pick (l) (let ((a (rules-array l))) (array-at a (rules-rand (array-length a)))))

;; logic variables: $x in rules, fresh <lv>s when a rule is used
(define-structure <lv> (id))
(define *rules-lv* 0)
(define-function lv? (x) (= <lv> (type-of x)))
(define-function rules-var? (x) (and (symbol? x) (= ?$ (string-at (symbol->string x) 0))))

(define-function walk (x s)
  (if (lv? x)
      (let ((b (assq x s))) (if b (walk (cdr b) s) x))
    x))
(define-function walk* (x s)
  (let ((x (walk x s)))
    (if (pair? x) (cons (walk* (car x) s) (walk* (cdr x) s)) x)))
(define-function occurs? (v x s)
  (let ((x (walk x s)))
    (or (= v x) (and (pair? x) (or (occurs? v (car x) s) (occurs? v (cdr x) s))))))
(define unify)
(define-function unify (a b s)
  (let ((a (walk a s)) (b (walk b s)))
    (cond
      ((= a b)				s)
      ((lv? a)				(and (not (occurs? a b s)) (cons (cons a b) s)))
      ((lv? b)				(and (not (occurs? b a s)) (cons (cons b a) s)))
      ((and (pair? a) (pair? b))	(let ((s (unify (car a) (car b) s))) (and s (unify (cdr a) (cdr b) s))))
      (else				()))))
(define *rules-empty* '((none . none)))	; a substitution that is never ()

(define-function rules-rename (x env)	; env: cell holding an alist symbol -> lv
  (cond
    ((rules-var? x)	(let ((b (assq x (car env))))
			  (if b (cdr b)
			    (let ((v (new <lv> (set *rules-lv* (+ *rules-lv* 1)))))
			      (set-car env (cons (cons x v) (car env)))
			      v))))
    ((pair? x)		(cons (rules-rename (car x) env) (rules-rename (cdr x) env)))
    (else		x)))

;; a rule is recursive when its own relation is reachable from its premises' relations,
;; directly or through other rules of the set; only the others run at size 0
(define-function rules-reaches? (from target rules seen)
  (let ((y ()))
    (and (not (member? from seen))
	 (let ((seen (cons from seen)))
	   (list-do rl rules
	     (and (not y) (= from (car (cadr rl)))
		  (list-do g (cddr rl)
		    (and (not y) (pair? g)
			 (or (= (car g) target) (rules-reaches? (car g) target rules seen))
			 (set y 1)))))))
    y))
(define-function rules-recursive? (r rules)
  (let ((p (car (cadr r))) (y ()))
    (list-do g (cddr r)
      (and (not y) (pair? g) (or (= (car g) p) (rules-reaches? (car g) p rules ())) (set y 1)))
    y))

(define rules-solve)
(define-function rules-solve-all (rules goals s size k)
  (if goals
      (rules-solve rules (car goals) s size (lambda (s) (rules-solve-all rules (cdr goals) s size k)))
    (k s)))

;; builtins: (in x t list), (number n), (float x), (= a b)
(define *rules-numbers* '(0 1 2 0.5 10))
;; membership by a table of the numerals, made once for each list, a whole double keyed as its long (2 and 2.0 are one)
(define-function rules-number-key (x) (if (and (double? x) (< -1e15 x) (< x 1e15) (= x (long->double (double->long x)))) (double->long x) x))
(define rules-number-sets (identity-hash-table))
(define-function rules-number? (x)	; numeric equality with one of them, long or double
  (and (or (= <long> (type-of x)) (= <double> (type-of x)))
       (let ((t (or (hash-at rules-number-sets *rules-numbers*)
		    (let ((t (equal-hash-table))) (list-do n *rules-numbers* (hash-at-put t (rules-number-key n) 1))
		      (hash-at-put rules-number-sets *rules-numbers* t)))))
	 (hash-includes? t (rules-number-key x)))))
(define-function rules-solve-in (goal s k)	; list is a list of (x . t) pairs
  (let ((pr (cons (cadr goal) (caddr goal))))
    (rules-first-of (walk* (cadddr goal) s) (lambda (e) (let ((s2 (unify pr e s))) (and s2 (k s2)))))))
(define-function rules-solve-number (goal s k)
  (let ((x (walk (cadr goal) s)))
    (if (lv? x)
	(rules-first-of *rules-numbers* (lambda (n) (k (unify x n s))))
      (and (rules-number? x) (k s)))))

;; float: float32 values made from the format's own structure, none listed.  A draw is one of three families: simple
;; (k / 2^j for small k and j), wide (a random sign, exponent field 0 to 254 and 23 mantissa bits, so every finite
;; magnitude is reachable), and boundary, as often as the other two together (the format's own: ±0, the least and the
;; greatest subnormal and any other, the greatest finite and the one below it, ±infinity, 2^24 where integers stop being
;; exact and its neighbours, a power of two and its neighbours an ulp away).  Each is a bit pattern built from the
;; layout: sign bit 31, exponent bits 23 to 30, mantissa bits 0 to 22.
;; the conversions are arithmetic, from the format's definition, so the engine runs on every evaluator (eval2 has no
;; data to reinterpret bits in): a normal value is (2^23 + m) 2^(e - 150), a subnormal m 2^-149, e 255 infinity
;; 2^n, exactly, from a table made once: from 2^-1100 (past double's least subnormal, 2^-1074, so it is 0) to 2^1100 (past
;; its greatest, so it is infinity); a power made by multiplying each time cost the float checks a loop per comparison
(define rules-pow2-table
  (let ((t (array 2201)) (r 1.0))
    (for (i 0 1101) (set-array-at t (+ 1100 i) r) (set r (* r 2.0)))
    (set r 1.0)
    (for (i 0 1101) (set-array-at t (- 1100 i) r) (set r (* r 0.5)))
    t))
(define-function rules-pow2 (n) (array-at rules-pow2-table (+ 1100 (max -1100 (min 1100 n)))))
(define rules-float-inf (* 1e308 10.0))
(define-function rules-float-of-bits (b)
  (let* ((s (if (= 0 (& b (<< 1 31))) 1.0 -1.0)) (e (& (>> b 23) 255)) (m (& b (- (<< 1 23) 1))))
    (* s (cond ((= e 255) rules-float-inf)
	       ((= e 0) (* (long->double m) (rules-pow2 -149)))
	       (else (* (long->double (+ (<< 1 23) m)) (rules-pow2 (- e 150))))))))
(define-function rules-float-split (x)	; (sign exponent-field mantissa) of a float32 value x, or () if x isn't one
  (let* ((s (if (< x 0) (<< 1 31) 0)) (a (if (< x 0) (- 0.0 x) x)))
    (cond ((!= x x) ())
	  ((= a 0) (list s 0 0))
	  ((= a rules-float-inf) (list s 255 0))
	  (else
	   (let ((e2 0))	; 2^e2 <= a < 2^(e2+1)
	     (while (>= a (rules-pow2 (+ e2 1))) (set e2 (+ e2 1)))
	     (while (< a (rules-pow2 e2)) (set e2 (- e2 1)))
	     (let* ((sub (< e2 -126)) (scaled (* a (rules-pow2 (if sub 149 (- 23 e2))))) (k (double->long scaled)))
	       (and (= scaled (long->double k)) (< e2 128)
		    (if sub (list s 0 k) (list s (+ e2 127) (- k (<< 1 23)))))))))))
(define-function rules-bits-of-float (x)
  (let ((p (rules-float-split x))) (if p (| (car p) (| (<< (cadr p) 23) (caddr p))) 0)))
(define rules-float-sign-bit (<< 1 31))
(define rules-float-infinity-bits (<< 255 23))
(define rules-float-greatest-bits (- rules-float-infinity-bits 1))
(define rules-float-mantissa-mask (- (<< 1 23) 1))
(define rules-float-least-normal (rules-float-of-bits (<< 1 23)))
(define rules-float-huge (rules-float-of-bits (<< (+ 127 100) 23)))	; 2^100
(define rules-float-infinity (rules-float-of-bits rules-float-infinity-bits))
(define rules-float-2^24 (rules-float-of-bits (<< (+ 127 24) 23)))
(define-function rules-float32? (x)	; a double holding a float32 value (NaN isn't one)
  (and (double? x) (rules-float-split x) 1))
(define-function rules-float-signed (b) (if (= 0 (rules-rand 2)) b (| b rules-float-sign-bit)))
(define-function rules-float-boundary ()
  (let ((k (rules-rand 7)))
    (rules-float-of-bits
     (rules-float-signed
      (cond ((= k 0) 0)
	    ((= k 1) (if (= 0 (rules-rand 2)) 1 rules-float-mantissa-mask))	; the least and the greatest subnormal
	    ((= k 2) (+ 1 (rules-rand rules-float-mantissa-mask)))			; any subnormal
	    ((= k 3) (- rules-float-greatest-bits (rules-rand 2)))		; the greatest finite, or the one below
	    ((= k 4) rules-float-infinity-bits)
	    ((= k 5) (+ (rules-bits-of-float rules-float-2^24) (- (rules-rand 5) 2)))	; 2^24 and its neighbours
	    (else (+ (<< (+ 1 (rules-rand 254)) 23) (- (rules-rand 3) 1))))))))	; a power of two, an ulp either side
(define-function rules-float-draw ()
  (let ((f (rules-rand 4)))
    (cond ((= f 0) (/ (long->double (- (rules-rand 129) 64)) (long->double (<< 1 (rules-rand 5)))))
	  ((= f 1) (rules-float-of-bits (rules-float-signed (| (<< (rules-rand 255) 23) (& (rules-bits32) rules-float-mantissa-mask)))))
	  (else (rules-float-boundary)))))
(define-function rules-float-magnitude (x) (if (< x 0) (- 0.0 x) x))
(define-function rules-float-family (x)	; which of the format's regions x is in, for a law's classes
  (let ((m (rules-float-magnitude x)))
    (cond ((= m 0)				'zero)
	  ((< m rules-float-least-normal)	'subnormal)
	  ((= m rules-float-infinity)		'infinite)
	  ((> m rules-float-huge)		'huge)
	  ((<= (rules-float-magnitude (- m rules-float-2^24)) 4.0) 'near24)
	  (else					'ordinary))))
;; enumerating float is over the format's landmarks: zero, ±1, the least subnormal, the least normal, 2^24, the
;; greatest finite and infinity, each with both signs
(define rules-float-landmarks
  (let ((out ()))
    (list-do b (list 0 (rules-bits-of-float 1.0) 1 (<< 1 23) (rules-bits-of-float rules-float-2^24) rules-float-greatest-bits rules-float-infinity-bits)
      (push out (rules-float-of-bits b)) (push out (rules-float-of-bits (| b rules-float-sign-bit))))
    (list-reverse! out)))
(define-function rules-solve-float (goal s k)
  (let ((x (walk (cadr goal) s)))
    (cond ((not (lv? x))	(and (rules-float32? (if (long? x) (long->double x) x)) (k s)))
	  (*rules-random*	(let ((r ()) (n 0)) (while (and (not r) (< n 16)) (set r (k (unify x (rules-float-draw) s))) (set n (+ n 1))) r))
	  (else			(rules-first-of rules-float-landmarks (lambda (v) (k (unify x v s))))))))
;; shrinking a float: candidates simpler than x, each kept by the shrinker only while the claim still fails.  Simpler is
;; zero, then finite before infinite, then an exponent nearer 1's, then fewer mantissa bits, then positive.
(define-function rules-float-cost (x)
  (if (= x 0) 0
    (let* ((b (rules-bits-of-float x)) (e (& (>> b 23) 255)) (m (& b rules-float-mantissa-mask)) (bits 23))
      (while (and (< 0 bits) (= 0 (& m 1)) (< 0 m)) (set m (>> m 1)) (set bits (- bits 1)))
      (and (= 0 (& b rules-float-mantissa-mask)) (set bits 0))
      (+ (+ (if (= e 255) 100000 0) (* 64 (if (< e 127) (- 127 e) (- e 127)))) (+ (* 2 bits) (if (= 0 (& b rules-float-sign-bit)) 0 1))))))
(define-function rules-float-before? (a b)	; a simpler than b: cheaper, or as cheap and nearer 0
  (let ((ca (rules-float-cost a)) (cb (rules-float-cost b)))
    (or (< ca cb) (and (= ca cb) (< (rules-float-magnitude a) (rules-float-magnitude b))))))
(define-function rules-float-bits-of-mantissa (m)	; how many of a mantissa's bits are significant
  (let ((bits 23)) (if (= m 0) 0 (let () (while (= 0 (& m 1)) (set m (>> m 1)) (set bits (- bits 1))) bits))))
;; the mantissas a float's search can move to by its bits alone: m rounded down and up to each count of bits, the next
;; binade toward 1's with its top bits filled (the values just across the binade's edge), and, at m's own count of bits,
;; m less each power of two of its last bit (as cheap, nearer 0, so a value can walk down to the least that still fails)
(define-function rules-float-moves (sign e m)
  (let ((out ()) (near (cond ((< e 127) (+ e 1)) ((> e 127) (- e 1)) (else e))) (last (<< 1 (- 23 (rules-float-bits-of-mantissa m)))))
    (for (k 0 24)
      (let* ((step (<< 1 (- 23 k))) (down (* step (/ m step))) (up (+ down (if (= down m) 0 step))))
	(push out (rules-float-of-bits (| sign (| (<< e 23) down))))
	(and (<= up rules-float-mantissa-mask) (push out (rules-float-of-bits (| sign (| (<< e 23) up)))))
	(push out (rules-float-of-bits (| sign (| (<< near 23) (& rules-float-mantissa-mask (- 0 step))))))
	(and (<= (<< last k) m) (< k 23) (push out (rules-float-of-bits (| sign (| (<< e 23) (- m (<< last k)))))))))
    out))
(define-function rules-float-insert (c out)	; c into out, which is simplest first
  (if (or (not out) (rules-float-before? c (car out))) (cons c out) (cons (car out) (rules-float-insert c (cdr out)))))
(define-function rules-float-simpler (x)	; simpler float32 values, simplest first
  (let* ((b (rules-bits-of-float x)) (sign (& b rules-float-sign-bit)) (e (& (>> b 23) 255)) (m (& b rules-float-mantissa-mask))
	 (cs (concat-list (list 0.0
		   (rules-float-of-bits (& b (- rules-float-sign-bit 1)))			; positive
		   (if (= e 255) (rules-float-of-bits (| sign rules-float-greatest-bits)) x)	; infinity to the greatest finite
		   (if (and (< (rules-float-magnitude x) rules-float-2^24) (< (rules-float-magnitude x) 1e15))
		       (long->double (double->long x)) x)						; the integer part
		   (rules-float-of-bits (| sign (| (<< e 23) (& m (- rules-float-mantissa-mask 4095)))))	; low mantissa bits cleared
		   (rules-float-of-bits (| sign (<< e 23)))						; no mantissa: a power of two
		   (rules-float-of-bits (| sign (| (<< (+ 127 (/ (- e 127) 2)) 23) m)))		; the exponent halved toward 1's
		   (rules-float-of-bits (| sign (| (<< (cond ((< e 127) (+ e 1)) ((> e 127) (- e 1)) (else e)) 23) m))))	; a step toward it
		  (if (= e 255) () (rules-float-moves sign e m))))
	 (out ()))
    (list-do c cs (and (rules-float32? c) (rules-float-before? c x) (not (member? c out)) (set out (rules-float-insert c out))))
    out))
(define-function rules-solve-eq (goal s k)
  (let ((s2 (unify (cadr goal) (caddr goal) s))) (and s2 (k s2))))
(define-function rules-note (rl v)
  (and v (not (member? rl *rules-used*)) (push *rules-used* rl) (not (member? (car rl) *rules-fired*)) (push *rules-fired* (car rl)))
  v)
(define *rules-touching* ())  (define *rules-touched* ())	; while touching, the rules whose conclusion unified with a goal
(define-function rules-try (rules rl goal s size k)
  (let* ((env (list ())) (head (rules-rename (cadr rl) env)) (body (rules-rename (cddr rl) env))
	 (s2 (unify (cdr head) (cdr goal) s)))
    (and s2 *rules-touching* (not (member? rl *rules-touched*)) (push *rules-touched* rl))
    (and s2 (rules-solve-all rules body s2 (- size 1) (lambda (s3) (rules-note rl (k s3)))))))
(define-function rules-solve-rules (rules goal s size k)
  (let ((p (car goal)))
    (rules-first-of rules
		    (lambda (rl)
		      (and (= p (car (cadr rl)))
			   (or (> size 0) (not (rules-recursive? rl rules)))
			   (rules-try rules rl goal s size k))))))
(define-function rules-solve (rules goal s size k)
  (let ((p (car goal)))
    (cond ((= p 'in)		(rules-solve-in goal s k))
	  ((= p 'number)	(rules-solve-number goal s k))
	  ((= p 'float)		(rules-solve-float goal s k))
	  ((= p '=)		(rules-solve-eq goal s k))
	  (else			(rules-solve-rules rules goal s size k)))))

(define-function rules-last (l) (if (cdr l) (rules-last (cdr l)) (car l)))
;; generate: one random solution's binding for the goal's last argument
(define-function rules-generate (rules goal size)
  (set *rules-random* 1)
  (let* ((env (list ())) (g (rules-rename goal env)) (out (rules-rename (rules-last goal) env)))
    (rules-solve rules g *rules-empty* size (lambda (s) (walk* out s)))))
;; check: does the goal, fully given, hold within size?
(define-function rules-holds? (rules goal size)
  (set *rules-random* ())
  (rules-solve rules (rules-rename goal (list ())) *rules-empty* size (lambda (s) 1)))
(define-function rules-has? (v l) (let ((y ())) (list-do e l (and (equal e v) (set y 1))) y))
;; enumerate: every distinct solution for the goal's last argument, those seen kept in a table (hash.l, by equal)
(define-function rules-enumerate (rules goal size)
  (set *rules-random* ())
  (let* ((env (list ())) (g (rules-rename goal env)) (out (rules-rename (rules-last goal) env)) (all ()) (seen (equal-hash-table)))
    (rules-solve rules g *rules-empty* size
		 (lambda (s) (let ((v (walk* out s)))
			       (or (hash-includes? seen v) (let () (hash-at-put seen v 't) (push all v)))) ()))
    (list-reverse! all)))

;; focus: the distinct instances of goal whose derivation uses rule rl, at the least depth (rules on the
;; path to rl) with any; premises off the path, and rl's own, at their relation's least size.  visit gets each
;; instance and the size it needs, and stops the search by answering true.
(define *rules-mins* ())	; (relation . least size), -99 for none needed
(define-function rules-min (rel) (if (member? rel '(in number float =)) -99 (or (cdr (assq rel *rules-mins*)) 99)))
(define-function rules-need (r rules) (if (rules-recursive? r rules) 1 0))
(define-function rules-mins (rules)
  (let ((more 1))
    (set *rules-mins* ())
    (while more
      (set more ())
      (list-do r rules
	(let ((v (if (= 1 (rules-need r rules)) 1 -99)) (p (car (cadr r))))
	  (list-do g (cddr r) (and (pair? g) (< v (+ 1 (rules-min (car g)))) (set v (+ 1 (rules-min (car g))))))
	  (and (< v (rules-min p)) (let () (set more 1) (push *rules-mins* (cons p v)))))))))
(define rules-focus-solve)
(define-function rules-focus-all (rules goals j s rl depth n k)	; premise j on the path; n the size needed so far
  (if (not goals) (k s n)
    (let ((g (car goals)))
      (if (= j 0) (rules-focus-solve rules g s rl (- depth 1) (lambda (s m) (rules-focus-all rules (cdr goals) -1 s rl depth (if (< n (+ m 1)) (+ m 1) n) k)))
	(let ((m (rules-min (car g))))
	  (rules-solve rules g s (if (< m 0) 0 m) (lambda (s) (rules-focus-all rules (cdr goals) (- j 1) s rl depth (if (< n (+ m 1)) (+ m 1) n) k))))))))
(define-function rules-focus-try (rules r rl goal s depth k)
  (let* ((env (list ())) (head (rules-rename (cadr r) env)) (body (rules-rename (cddr r) env)) (s2 (unify (cdr head) (cdr goal) s)) (j 0) (y ()))
    (and s2
	 (if (= r rl) (rules-focus-all rules body -1 s2 rl depth (rules-need r rules) k)
	   (list-do g body
	     (and (not y) (pair? g) (or (= (car g) (car (cadr rl))) (rules-reaches? (car g) (car (cadr rl)) rules ()))
		  (set y (rules-focus-all rules body j s2 rl depth (rules-need r rules) k)))
	     (set j (+ j 1)))
	   y))))
(define-function rules-focus-solve (rules goal s rl depth k)
  (let ((y ()))
    (and (> depth 0) (list-do r rules (and (not y) (= (car goal) (car (cadr r))) (set y (rules-focus-try rules r rl goal s depth k)))))
    y))
(define-function rules-focus (rules goal rl visit)	; true if visit stopped it
  (let ((d 1) (found ()) (stop ()) (seen (equal-hash-table)))
    (set *rules-random* ())
    (rules-mins rules)
    (while (and (not found) (not stop) (<= d (list-length rules)))
      (let ((g (rules-rename goal (list ()))))
	(set stop (rules-focus-solve rules g *rules-empty* rl d
				     (lambda (s n) (let ((v (walk* g s)))
						     (and (not (hash-includes? seen v))
							  (let () (hash-at-put seen v 't) (set found 1) (visit v n)))))))
	(set d (+ d 1))))
    stop))

;;; Higher-order rules.  rules-expand turns items into the first-order rule set above:
;;;   (rule name (param...) conclusion premise...)  a parameter ($r) is a relation; ($r x) applies it
;;;   (fact goal)   (schema var (value...) item)   (facts (relation...) function)
;;; A goal that passes a relation, (list_of (expr env t) es), calls the rule specialised for it:
;;; (list_of[expr] env t es).  Rejections go to *rules-reject* (error), then expansion goes on.
(define *rules-reject* error)
(define-structure <rx> (hos done todo used arity))	; higher-order rules, specialised relations made, rules to rewrite, relations passed
(define-function rules-cat-list (l) (if (cdr l) (concat-string (car l) (rules-cat-list (cdr l))) (car l)))
(define-function rules-cat l (rules-cat-list l))
(define-function rules-reject-with (code what) (*rules-reject* (rules-cat code what)))
(define-function rules-unknown (what) (rules-reject-with "E_UNKNOWN_RELATION: " what))
(define-function rules-subst (x v val)
  (cond ((= x v) val) ((pair? x) (cons (rules-subst (car x) v val) (rules-subst (cdr x) v val))) (else x)))
(define-function rules-fact (g) (list (car g) g))
(define-function rules-read-facts (it)	; (facts (relation...) function), the function a value or a global's name
  (let* ((f (caddr it)) (l ()) (gs ((if (symbol? f) (eval f) f))))
    (or gs (rules-reject-with "E_NO_FACTS: " (if (symbol? f) (symbol->string f) (rules-cat "facts for " (symbol->string (caadr it))))))
    (list-do g gs
      (if (member? (car g) (cadr it)) (set l (concat-list l (list (rules-fact g))))
	(rules-unknown (symbol->string (car g)))))
    l))
(define-function rules-keep (ho r) (set-car ho (concat-list (car ho) (list r))) ())
(define-function rules-flatten (items ho)	; first-order rules; higher-order ones go to the cell ho
  (let ((out ()))
    (list-do it items
      (let ((k (car it)))
	(set out (concat-list out
	  (cond
	    ((= k 'fact)	(list (rules-fact (cadr it))))
	    ((= k 'schema)	(let ((l ())) (list-do v (caddr it) (set l (concat-list l (rules-flatten (list (rules-subst (cadddr it) (cadr it) v)) ho)))) l))
	    ((= k 'facts)	(rules-read-facts it))
	    ((= k 'rule)	(if (caddr it) (rules-keep ho (cdr it)) (list (cons (cadr it) (cdddr it)))))
	    ((member? k '(let set law under-test reference defaults))	(rules-reject-with "E_UNKNOWN_ITEM: " (symbol->string k)) ())
	    (else		(list it)))))))
    out))

;; specialisation.  A binding is (param rel extras...): the relation a goal passes for a parameter.
(define-function rules-bind (r g)	; r: (name params conclusion premise...)
  (let ((b ()) (cs (cdr (caddr r))) (gs (cdr g)))
    (while (and cs gs)
      (and (member? (car cs) (cadr r))
	   (if (and (pair? (car gs)) (symbol? (caar gs)) (not (rules-var? (caar gs))))
	       (set b (concat-list b (list (cons (car cs) (car gs)))))
	     (rules-unknown (rules-cat (symbol->string (car g)) " needs a relation for " (symbol->string (car cs))))))
      (set cs (cdr cs)) (set gs (cdr gs)))
    b))
(define-function rules-suffix (binds)	; "[expr]", "[expr,stmt]"
  (let ((s "[") (first 1))
    (list-do b binds
      (set s (rules-cat s (if first "" ",") (symbol->string (cadr b))))
      (set first ()))
    (rules-cat s "]")))
(define-function rules-fresh (param i n)	; $param.i ... $param.n
  (and (<= i n) (cons (string->symbol (rules-cat (symbol->string param) "." (long->string i))) (rules-fresh param (+ i 1) n))))
(define-function rules-spec-term (x vs)	; vs: (param rel var...) per parameter
  (cond ((and (symbol? x) (assq x vs))	(cdr (assq x vs)))
	((pair? x)			(cons (rules-spec-term (car x) vs) (rules-spec-term (cdr x) vs)))
	(else				x)))
(define-function rules-spec-goal (g vs)
  (let ((b (assq (car g) vs)))
    (if b (cons (cadr b) (concat-list (cddr b) (rules-spec-term (cdr g) vs)))
      (cons (car g) (rules-spec-term (cdr g) vs)))))
(define-function rules-spec-rule (r binds suffix)
  (let ((vs (map (lambda (b) (cons (car b) (cons (cadr b) (rules-fresh (car b) 1 (list-length (cddr b)))))) binds)))
    (cons (string->symbol (rules-cat (symbol->string (car r)) suffix))
	  (map (lambda (g) (rules-spec-goal g vs)) (cddr r)))))
(define-function rules-hos (rel rx)
  (let ((l ())) (list-do r (<rx>-hos rx) (and (= rel (car (caddr r))) (set l (concat-list l (list r))))) l))
(define-function rules-queue (rx g rel suffix)	; make the specialised rules for rel, once
  (or (member? rel (<rx>-done rx))
      (let ((todo ()))
	(set (<rx>-done rx) (cons rel (<rx>-done rx)))
	(list-do b (rules-bind (car (rules-hos (car g) rx)) g) (set (<rx>-used rx) (cons (cadr b) (<rx>-used rx))))
	(list-do r (rules-hos (car g) rx) (set todo (concat-list todo (list (rules-spec-rule r (rules-bind r g) suffix)))))
	(set (<rx>-todo rx) (concat-list (<rx>-todo rx) todo)))))
(define-function rules-splice (r gs cs binds)	; g's arguments, each passed relation's own arguments in its place
  (and gs (concat-list (let ((b (and (member? (car cs) (cadr r)) (assq (car cs) binds)))) (if b (cddr b) (list (car gs))))
		       (rules-splice r (cdr gs) (cdr cs) binds))))
(define-function rules-arity (rx rel binds)	; one specialised relation, one count of carried arguments per parameter
  (let ((ns (map (lambda (b) (list-length (cddr b))) binds)) (seen (assq rel (<rx>-arity rx))))
    (if seen (or (equal (cdr seen) ns) (rules-reject-with "E_ARITY: " (symbol->string rel)))
      (set (<rx>-arity rx) (cons (cons rel ns) (<rx>-arity rx))))))
(define-function rules-call (g rx)
  (let ((hos (and (pair? g) (rules-hos (car g) rx))))
    (if hos
	(let ((binds (rules-bind (car hos) g)))
	  (if binds
	      (let* ((suffix (rules-suffix binds)) (rel (string->symbol (rules-cat (symbol->string (car g)) suffix))))
		(rules-arity rx rel binds)
		(rules-queue rx g rel suffix)
		(cons rel (rules-splice (car hos) (cdr g) (cdr (caddr (car hos))) binds)))
	    g))
      g)))
(define-function rules-concludes? (rel rules) (let ((y ())) (list-do r rules (and (= rel (car (cadr r))) (set y 1))) y))
(define-function rules-check (rules used)	; every relation passed or premised is concluded or built in
  (let ((seen ()))
    (list-do r rules (list-do g (cddr r) (and (pair? g) (set used (cons (car g) used)))))
    (list-do rel used
      (and (not (member? rel '(in number float =))) (not (member? rel seen))
	   (let () (set seen (cons rel seen)) (not (rules-concludes? rel rules)))
	   (rules-unknown (symbol->string rel))))))
(define-function rules-expand (items)
  (let* ((ho (list ())) (rx (new <rx> () () () () ())) (out ()))
    (set (<rx>-todo rx) (rules-flatten items ho))
    (set (<rx>-hos rx) (car ho))
    (while (<rx>-todo rx)
      (let ((r (car (<rx>-todo rx))))
	(set (<rx>-todo rx) (cdr (<rx>-todo rx)))
	(set out (concat-list out (list (cons (car r) (map (lambda (g) (rules-call g rx)) (cdr r))))))))
    (rules-check out (<rx>-used rx))
    out))
