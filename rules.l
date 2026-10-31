;;; A small first-order logic engine.  One rule set runs three ways: generate
;;; (rules in random order, one solution), check (rules in order, does the goal
;;; hold) and enumerate (every solution).  A rule is (name conclusion premise...),
;;; a rule set a list of rules, and $x a logic variable.  Rule sets are passed
;;; in, never global, so mutants can swap them.  See docs/rfc/draft-ndn-maru-laws-and-rules-00.md.

;; seeded, replayable.  rules-fired names the rules used in successful generate and check derivations, rules-used lists them.
(define *rules-seed* 42)
(define *rules-fired* ())	; rule names used in successful derivations
(define *rules-used* ())	; the rules themselves, as facts share their relation's name
(define-function rules-seed (n) (set *rules-seed* n) (set *rules-fired* ()) (set *rules-used* ()))
(define-function rules-fired () *rules-fired*)
(define-function rules-used () *rules-used*)
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
(define-function rules-hash (x)	; equal terms hash alike (every number alike, as = compares 2 and 2.0)
  (cond ((pair? x)	(% (+ (* 31 (rules-hash (car x))) (rules-hash (cdr x))) 4093))
	((symbol? x)	(rules-hash (symbol->string x)))
	((string? x)	(let ((h 7)) (for (i 0 (string-length x)) (set h (% (+ (* h 31) (string-at x i)) 4093))) h))
	(else		1)))
;; enumerate: every distinct solution for the goal's last argument, those seen kept in buckets by hash
(define-function rules-enumerate (rules goal size)
  (set *rules-random* ())
  (let* ((env (list ())) (g (rules-rename goal env)) (out (rules-rename (rules-last goal) env)) (all ()) (seen (array 4093)))
    (rules-solve rules g *rules-empty* size
		 (lambda (s) (let* ((v (walk* out s)) (h (rules-hash v)))
			       (or (rules-has? v (array-at seen h)) (let () (push (array-at seen h) v) (push all v)))) ()))
    (list-reverse! all)))

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
      (and (not (member? rel '(in number =))) (not (member? rel seen))
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
