;;; A small first-order logic engine.  One rule set runs three ways: generate
;;; (rules in random order, one solution), check (rules in order, does the goal
;;; hold) and enumerate (every solution).  A rule is (name conclusion premise...),
;;; a rule set a list of rules, and $x a logic variable.  Rule sets are passed
;;; in, never global, so mutants can swap them.  See docs/rfc/draft-ndn-maru-laws-and-rules-00.md.

;; seeded, replayable.  rules-fired names the rules used in successful generate and check derivations.
(define *rules-seed* 42)
(define *rules-fired* ())	; rule names used in successful derivations
(define-function rules-seed (n) (set *rules-seed* n) (set *rules-fired* ()))
(define-function rules-fired () *rules-fired*)
(define-function rules-rand (n) (set *rules-seed* (% (+ (* *rules-seed* 75) 74) 65537)) (% *rules-seed* n))
(define-function rules-shuffle (l)
  (let ((a (list->array l)) (n (list-length l)))
    (while (> n 1)
      (let* ((j (rules-rand n)) (t (array-at a j)))
	(set (array-at a j) (array-at a (- n 1)))
	(set (array-at a (- n 1)) t))
      (set n (- n 1)))
    (array->list a)))
(define *rules-random* ())
(define-function rules-choices (l) (if *rules-random* (rules-shuffle l) l))

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

;; builtins: (in x t list), (number n), (= a b)
(define *rules-numbers* '(0 1 2 0.5 10))
(define-function rules-number? (x)	; numeric equality with one of them, long or double
  (let ((y ()))
    (and (or (= <long> (type-of x)) (= <double> (type-of x)))
	 (list-do n *rules-numbers* (and (= x n) (set y 1))))
    y))
(define-function rules-solve-in (goal s k)	; list is a list of (x . t) pairs
  (let ((pr (cons (cadr goal) (caddr goal))) (r ()))
    (list-do e (rules-choices (walk* (cadddr goal) s))
      (or r (let ((s2 (unify pr e s))) (and s2 (set r (k s2))))))
    r))
(define-function rules-solve-number (goal s k)
  (let ((x (walk (cadr goal) s)))
    (if (lv? x)
	(let ((r ())) (list-do n (rules-choices *rules-numbers*) (or r (set r (k (unify x n s))))) r)
      (and (rules-number? x) (k s)))))
(define-function rules-solve-eq (goal s k)
  (let ((s2 (unify (cadr goal) (caddr goal) s))) (and s2 (k s2))))
(define-function rules-note (name v)
  (and v (not (member? name *rules-fired*)) (push *rules-fired* name))
  v)
(define-function rules-try (rules rl goal s size k)
  (let* ((env (list ())) (head (rules-rename (cadr rl) env)) (body (rules-rename (cddr rl) env))
	 (s2 (unify (cdr head) (cdr goal) s)))
    (and s2 (rules-solve-all rules body s2 (- size 1) (lambda (s3) (rules-note (car rl) (k s3)))))))
(define-function rules-solve-rules (rules goal s size k)
  (let ((p (car goal)) (r ()))
    (list-do rl (rules-choices rules)
      (and (not r) (= p (car (cadr rl)))
	   (or (> size 0) (not (rules-recursive? rl rules)))
	   (set r (rules-try rules rl goal s size k))))
    r))
(define-function rules-solve (rules goal s size k)
  (let ((p (car goal)))
    (if (= p 'in) (rules-solve-in goal s k)
      (if (= p 'number) (rules-solve-number goal s k)
	(if (= p '=) (rules-solve-eq goal s k)
	  (rules-solve-rules rules goal s size k))))))

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
;; enumerate: every distinct solution for the goal's last argument
(define-function rules-enumerate (rules goal size)
  (set *rules-random* ())
  (let* ((env (list ())) (g (rules-rename goal env)) (out (rules-rename (rules-last goal) env)) (all ()))
    (rules-solve rules g *rules-empty* size (lambda (s) (let ((v (walk* out s))) (or (rules-has? v all) (set all (concat-list all (list v))))) ()))
    all))
