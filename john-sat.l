;;; john-sat.l -- JOHN planning by satisfiability (draft-ndn-maru-sat-00), the frame: what the
;;; encoding covers is checked before anything is built.
;;;
;;;   (john-sat-satisfy o g args)   satisfy under set-opt planner sat (john-eval.l dispatches)
;;;   (john-sorts)                  ((object prop) . sort) for every property [R-sorts]
;;;   (john-run-sorts forms)        a program's statements but satisfy, then its sorts checked
;;;
;;; A sort is number, name (an object, a word, a string) or (list S); () is a sort not yet
;;; known, and agrees with any.  Sorts come from the values in the world and, statically,
;;; from what each effect sets: literals, lists, arithmetic, and properties read through it,
;;; an action's parameters and objects.  A property given two sorts is E_SORT, a number
;;; outside sat-width bits E_BOUND, and what the encoding doesn't cover E_SAT_UNSUPPORTED
;;; [R-sat-unsupported].

(require "cnf.l")
(require "sat.l")

(define-function john-sat-nth (l i) (while (< 0 i) (set l (cdr l)) (set i (- i 1))) l)
(define-function assoc-sort (s o p)	; the entry ((o p) . sort) of s, or ()
  (let ((r ())) (list-do e s (and (not r) (= o (car (car e))) (= p (cadr (car e))) (set r e))) r))

;;; ---- sorts

(define-function john-sort-text (s)
  (cond ((= s 'number) "a number") ((= s 'name) "a name") (else "a list")))
(define-function john-sort-unify (a b)	; the sort agreeing with both, or clash
  (cond ((not a) b) ((not b) a)
	((and (pair? a) (pair? b)) (let ((e (john-sort-unify (cadr a) (cadr b)))) (if (= e 'clash) e (list 'list e))))
	((= a b) a)
	(else 'clash)))
(define-selector john-value-sort (v) 'name)
(define-method john-value-sort <long> () 'number)
(define-method john-value-sort <undefined> () '(list ()))
(define-method john-value-sort <john-class-ref> () '(list name))
(define-method john-value-sort <pair> ()
  (let ((e ()))
    (list-do x self (let ((u (john-sort-unify e (john-value-sort x)))) (and (= u 'clash) (john-fail "a list of " (john-text self) " mixes sorts")) (set e u)))
    (list 'list e)))

(define *john-sorts* ())	; ((object prop) . sort)
(define-function john-sort-of (o p) (cdr (assoc-sort *john-sorts* o p)))
(define-function john-sort-add (o p s)	; true when the entry changed
  (let* ((e (assoc-sort *john-sorts* o p)) (old (cdr e)) (u (john-sort-unify old s)))
    (and (= u 'clash) (error "E_SORT: " o " " p " is " (john-sort-text old) " and " (john-sort-text s)))
    (and (not (equal u old)) (let () (set-cdr e u) 1))))

;; what an expression names statically: the class of the object it is, or ()
(define-function john-static-class (x env)
  (and (symbol? x)
       (let ((b (assq x env)))
	 (cond (b (cdr b)) ((john-object? x) (john-object-class x)) (else ())))))
(define-function john-holders (c p)	; the objects whose property p an X of class c can be
  (let ((out ()))
    (list-do o *john-objects* (and (if c (john-isa? (cdr o) c) 1) (member? p (john-props (cdr o))) (push out (car o))))
    out))
(define-function john-static-sort (x env)	; env: (name . class)
  (cond ((symbol? x) (cond ((assq x env) 'name) ((member? x '(yes no empty)) 'name) ((john-object? x) 'name)
			   ((john-class x) '(list name)) ((= x 'time) 'number) (else ())))
	((not (pair? x)) (john-value-sort x))
	(else
	 (let ((op (car x)))
	   (cond ((= op 'list) (let ((e ())) (list-do a (cdr x) (let ((u (john-sort-unify e (john-static-sort a env)))) (or (= u 'clash) (set e u)))) (list 'list e)))
		 ((member? op '(* /)) 'number)
		 ((member? op '(+ -)) (let ((a (john-static-sort (cadr x) env))) (if (pair? a) a (and (= a 'number) a))))
		 ((member? op '(= < > <= >= and or not rel every any)) 'name)
		 ((member? op '(all select)) '(list name))
		 ((and (= op 'send) (not (cdddr x)))
		  (let ((c (john-static-class (cadr x) env)) (p (caddr x)) (s ()))
		    (cond ((= p 'size) 'number)
			  (c (list-do o (john-holders c p) (let ((u (john-sort-unify s (john-sort-of o p)))) (or (= u 'clash) (set s u)))) s)
			  (else ()))))
		 (else ()))))))

(define-function john-effect-sorts ()	; one pass over every action's effects; true when a sort changed
  (let ((changed ()))
    (list-do a *john-actions*
      (let ((env (cons (cons 'it (car a)) (map (lambda (p) (cons (cadr p) (car p))) (caddr a)))))
	(list-do e (cadddr a)	; (set X p v guard?)
	  (let ((s (john-static-sort (cadddr e) env)))
	    (list-do o (john-holders (john-static-class (cadr e) env) (caddr e))
	      (and (john-sort-add o (caddr e) s) (set changed 1)))))))
    changed))
(define-function john-sorts ()
  (set *john-sorts* ())
  (list-do o *john-objects*
    (list-do p (john-props (cdr o)) (push *john-sorts* (cons (list (car o) p) ()))))
  (list-do e *john-sorts* (john-sort-add (car (car e)) (cadr (car e)) (john-value-sort (john-lookup *john-world* (car (car e)) (cadr (car e))))))
  (let ((n 0)) (while (and (< n 8) (john-effect-sorts)) (set n (+ n 1))))
  *john-sorts*)

;;; ---- bounds: every number the program holds or names fits sat-width bits, signed

(define-function john-sat-width () (or (cdr (assq 'sat-width *john-options*)) 16))
(define-function john-bound-check (x w)
  (cond ((long? x) (let ((top 1)) (for (i 1 w) (set top (* top 2)))
		     (or (and (<= (- top) x) (< x top)) (error "E_BOUND: " x " does not fit sat-width " w))))
	((pair? x) (john-bound-check (car x) w) (john-bound-check (cdr x) w))))

;;; ---- what the encoding doesn't cover

(define-function john-sat-refuse (what) (error "E_SAT_UNSUPPORTED: " what " under planner sat"))
(define-function john-sat-scan (x)	; an expression reading another time
  (and (pair? x)
       (let ()
	 (cond ((= (car x) 'at-time) (john-sat-refuse "at time"))
	       ((and (member? (car x) '(every any)) (pair? (cdr x)) (= 'time (cadr x)) (cddddr x))
		(john-sat-refuse (if (= 'every (car x)) "for every time" "for some time")))
	       ((and (= (car x) 'rel) (pair? (cdr x)) (= 'did (cadr x))) (john-sat-refuse "did")))
	 (john-sat-scan (car x))
	 (john-sat-scan (cdr x)))))
(define-function john-sat-check ()
  (list-do opt '(two-player-game max-time-ahead) (and (cdr (assq opt *john-options*)) (john-sat-refuse (symbol->string opt))))
  (list-do table (list *john-quals* *john-rels* *john-actions* *john-rules* *john-goals* *john-aopts* *john-gopts* *john-heuristics*)
    (john-sat-scan table)
    (john-bound-check table (john-sat-width)))
  (list-do e (john-sorts) (john-bound-check (john-lookup *john-world* (car (car e)) (cadr (car e))) (john-sat-width))))

;;; ---- the encoding [R-bmc-encoding]: states 0 .. k, one action per step, the goal at k
;;;
;;; A value is (const . v), known when the formula is built, or (names (v . literal) ...) over
;;; constants v (names, or the numbers a varying object holds), exactly one literal true.  An expression is encoded under a path, the literal under which
;;; the evaluator would reach it; where the evaluator would stop with an error the literal
;;; (path and cause) goes in *sat-errs*, and the step or goal that read it is impossible.

(define-function john-sat-option (name default) (or (cdr (assq name *john-options*)) default))
(define-function john-sat-unroll () (john-sat-option 'sat-unroll 16))
(define *sat-c* ())		; the formula being built
(define *sat-t* ())		; its true literal
(define *sat-reach* ())		; the literal under which the expression being encoded is read
(define *sat-errs* ())		; literals under which it stops with an error
(define *sat-depth* 0)		; qualifications inlined, one inside another
(define *sat-states* ())	; time -> ((object (prop . value) ...) ...), the properties effects write

(define-function sat-and (ls)	; a conjunction, folded where its literals are known
  (let ((out ()) (f ()))
    (list-do l ls (cond ((= l *sat-t*)) ((or (= l (- *sat-t*)) (member? (- l) out)) (set f 1)) ((member? l out)) (else (push out l))))
    (cond (f (- *sat-t*)) ((not out) *sat-t*) ((not (cdr out)) (car out)) (else (cnf-and *sat-c* out)))))
(define-function sat-or (ls) (- (sat-and (map - ls))))
(define-function sat-mux (s a b) (cond ((= s *sat-t*) a) ((= s (- *sat-t*)) b) ((= a b) a) (else (cnf-mux *sat-c* s a b))))
(define-function sat-err (l) (let ((e (sat-and (list *sat-reach* l)))) (or (= e (- *sat-t*)) (push *sat-errs* e))))
(define-function sat-under (l thunk)	; thunk's value, its errors only where l holds
  (let ((saved *sat-reach*))
    (set *sat-reach* (sat-and (list saved l)))
    (let ((v (thunk))) (set *sat-reach* saved) v)))

(define-function sat-const (v) (cons 'const v))
(define-function sat-const? (x) (= 'const (car x)))
(define-function sat-names (x) (if (sat-const? x) (list (cons (cdr x) *sat-t*)) (cdr x)))	; ((v . literal) ...)
(define-function sat-entry (v alist) (let ((r ())) (list-do e alist (and (not r) (equal v (car e)) (set r e))) r))
(define-function sat-lit-of (x n) (let ((e (sat-entry n (sat-names x)))) (if e (cdr e) (- *sat-t*))))
(define-function sat-names-value (alist)	; false names dropped; one true name is a constant
  (let ((out ())) (list-do e alist (or (= (cdr e) (- *sat-t*)) (push out e)))
    (if (and out (not (cdr out)) (= *sat-t* (cdr (car out)))) (sat-const (car (car out))) (cons 'names (list-reverse! out)))))
(define-function sat-union (xs)	; the names any of xs can be
  (let ((ns ())) (list-do x xs (list-do e (sat-names x) (or (sat-entry (car e) (map list ns)) (push ns (car e))))) (list-reverse! ns)))
(define-function sat-truth (x)	; john-true?: neither no nor the empty list
  (if (sat-const? x) (if (john-true? (cdr x)) *sat-t* (- *sat-t*))
    (- (sat-or (let ((ls ())) (list-do e (cdr x) (or (john-true? (car e)) (push ls (cdr e)))) ls)))))
(define-function sat-bool (l)
  (cond ((= l *sat-t*) (sat-const 'yes)) ((= l (- *sat-t*)) (sat-const 'no)) (else (cons 'names (list (cons 'yes l) (cons 'no (- l)))))))
(define-function sat-equal (a b)
  (cond ((and (sat-const? a) (sat-const? b)) (if (equal (cdr a) (cdr b)) *sat-t* (- *sat-t*)))
	(else (sat-or (map (lambda (e) (sat-and (list (cdr e) (sat-lit-of b (car e))))) (sat-names a))))))
(define-function sat-mux-value (s a b)	; a where s holds, else b
  (cond ((= s *sat-t*) a) ((= s (- *sat-t*)) b)
	((and (sat-const? a) (sat-const? b) (equal (cdr a) (cdr b))) a)
	(else (sat-names-value (map (lambda (n) (cons n (sat-mux s (sat-lit-of a n) (sat-lit-of b n)))) (sat-union (list a b)))))))
(define-function sat-merge (choices)	; ((literal . value) ...), at most one literal true
  (let ((live ())) (list-do ch choices (or (= (car ch) (- *sat-t*)) (push live ch)))
    (set live (list-reverse! live))
    (cond ((not live) (sat-const 'no))	; no choice can be taken: an error is recorded for it
	  ((let ((same 1)) (list-do ch live (or (and (sat-const? (cdr ch)) (sat-const? (cdr (car live))) (equal (cdr (cdr ch)) (cdr (cdr (car live))))) (set same ()))) same)
	   (cdr (car live)))
	  (else (sat-names-value (map (lambda (n) (cons n (sat-or (map (lambda (ch) (sat-and (list (car ch) (sat-lit-of (cdr ch) n)))) live))))
				      (sat-union (map cdr live))))))))
(define-function sat-cases (x)	; ((literal . constant) ...)
  (if (sat-const? x) (list (cons *sat-t* (cdr x))) (map (lambda (e) (cons (cdr e) (car e))) (cdr x))))
(define-function sat-combos (cases)	; one case of each
  (if (not cases) (list ())
    (let ((out ()) (rest (sat-combos (cdr cases)))) (list-do c (car cases) (list-do r rest (push out (cons c r)))) (list-reverse! out))))
(define-function sat-split (xs f)	; f of every combination of xs' constants, merged
  (let ((known 1)) (list-do x xs (or (sat-const? x) (set known ())))
    (if known (f (map cdr xs))
      (let ((choices ()))
	(list-do combo (sat-combos (map sat-cases xs))
	  (let ((l (sat-and (map car combo))))
	    (or (= l (- *sat-t*)) (push choices (cons l (sat-under l (lambda () (f (map cdr combo)))))))))
	(sat-merge (list-reverse! choices))))))
(define-function sat-bind (names vals env) (john-bind names (map sat-const vals) env))

(define-function sat-cell (o p t)	; o's p at time t
  (let ((e (assq p (cdr (assq o (array-at *sat-states* t))))))
    (if e (cdr e) (sat-const (john-lookup *john-world* o p)))))
(define-function sat-builtin-ok? (r sel args)	; the evaluator's builtin answers, without an error
  (cond ((= sel 'name) (string? r))
	((member? sel '(size from:)) (or (pair? r) (not r)))
	((= sel 'to:) (and (or (pair? r) (not r)) (long? (car args)) (<= 0 (car args))))
	((= sel 'at:) (and (pair? r) (long? (car args)) (<= 1 (car args)) (<= (car args) (list-length r))))
	(else (pair? r))))
(define sat-eval)
(define sat-qualify)
(define-function sat-send-const (r sel args t)
  (let ((c (john-class-of r)))
    (cond ((and (john-object? r) (not args) (member? sel (john-props c))) (sat-cell r sel t))
	  ((john-quals c sel) (sat-qualify r (john-quals c sel) args t))
	  ((and (assq sel *john-builtins*) (sat-builtin-ok? r sel args)) (sat-const (john-builtin r sel args)))
	  (else (sat-err *sat-t*) (sat-const 'no)))))
;; the first clause whose guard holds gives the value; an if-qualification is yes or no
(define-function sat-qualify (r clauses args t)
  (if (>= *sat-depth* (john-sat-unroll)) (let () (sat-err *sat-t*) (sat-const 'no))
    (set *sat-depth* (+ 1 *sat-depth*))
    (let ((before *sat-t*) (choices ()))
      (list-do q clauses
	(or (= before (- *sat-t*))
	    (let* ((env (sat-bind (caddr q) args (list (cons 'it (sat-const r))))) (b (cadddr q))
		   (g (sat-under before (lambda () (cond ((= 'if (car b)) (sat-truth (sat-eval (cadr b) t env)))
							((cddr b) (sat-truth (sat-eval (caddr b) t env)))
							(else *sat-t*)))))
		   (chosen (sat-and (list before g))))
	      (or (= chosen (- *sat-t*))
		  (push choices (cons chosen (if (= 'if (car b)) (sat-const 'yes) (sat-under chosen (lambda () (sat-eval (cadr b) t env)))))))
	      (set before (sat-and (list before (- g)))))))
      (if (= 'if (car (cadddr (car clauses)))) (push choices (cons before (sat-const 'no))) (sat-err before))
      (set *sat-depth* (- *sat-depth* 1))
      (sat-merge (list-reverse! choices)))))
(define-function sat-holds (r a b t)
  (if (= r 'in) (sat-split (list a b) (lambda (cs) (sat-const (john-bool (member? (car cs) (john-elements (cadr cs)))))))
    (let ((d (assq r *john-rels*)))
      (or d (john-fail "no relation " r))
      (sat-bool (sat-truth (sat-eval (cadddr d) t (list (cons (cadr (cadr d)) a) (cons (cadr (caddr d)) b))))))))
(define-function sat-known (x what)	; x's constant; a changing one isn't encoded yet
  (if (sat-const? x) (cdr x) (john-sat-refuse what)))
(define-function sat-arith (op a b)	; on constants, as the evaluator; dividing by zero stops it
  (cond ((member? op '(< > <= >=)) (john-bool (cond ((= op '<) (< a b)) ((= op '>) (> a b)) ((= op '<=) (<= a b)) (else (>= a b)))))
	((and (= op '/) (= 0 b)) (sat-err *sat-t*) 0)
	(else (john-arith op a b))))
(define-function sat-eval (x t env)
  (cond ((symbol? x) (let ((b (assq x env))) (cond (b (cdr b)) ((= x 'time) (sat-const t)) (else (sat-const (john-name x *john-world* ()))))))
	((not (pair? x)) (sat-const x))
	(else
	 (let ((op (car x)))
	   (cond ((= op 'send) (sat-split (cons (sat-eval (cadr x) t env) (map (lambda (a) (sat-eval a t env)) (cdddr x)))
					  (lambda (cs) (sat-send-const (car cs) (caddr x) (cdr cs) t))))
		 ((= op 'list) (sat-const (map (lambda (a) (sat-known (sat-eval a t env) "a list of values that change")) (cdr x))))
		 ((= op '=) (sat-bool (sat-equal (sat-eval (cadr x) t env) (sat-eval (caddr x) t env))))
		 ((member? op '(< > <= >= + - * /))
		  (let ((a (sat-eval (cadr x) t env)) (b (sat-eval (caddr x) t env)))
		    (sat-split (list a b) (lambda (cs) (sat-const (sat-arith op (car cs) (cadr cs)))))))
		 ((= op 'and) (let ((a (sat-truth (sat-eval (cadr x) t env))))
				(sat-bool (sat-and (list a (sat-under a (lambda () (sat-truth (sat-eval (caddr x) t env)))))))))
		 ((= op 'or) (let ((a (sat-truth (sat-eval (cadr x) t env))))
			       (sat-bool (sat-or (list a (sat-under (- a) (lambda () (sat-truth (sat-eval (caddr x) t env)))))))))
		 ((= op 'not) (sat-bool (- (sat-truth (sat-eval (cadr x) t env)))))
		 ((= op 'rel) (sat-holds (cadr x) (sat-eval (caddr x) t env) (sat-eval (cadddr x) t env) t))
		 ((member? op '(every any))
		  (let ((ls (map (lambda (e) (sat-truth (sat-eval (caddr x) t (cons (cons 'each (sat-const e)) env))))
				 (john-elements (sat-known (sat-eval (cadr x) t env) "a collection that changes")))))
		    (sat-bool (if (= op 'every) (sat-and ls) (sat-or ls)))))
		 ((= op 'all) (if (cddr x) (john-fail "all with property values is not read yet") (sat-const (john-instances (cadr x)))))
		 ((= op 'select) (sat-const (let ((out ()))
					      (list-do o (john-instances (cadr x))
						(and (john-true? (sat-known (sat-eval (caddr x) t (cons (cons 'which (sat-const o)) env)) "a selection that changes")) (push out o)))
					      (list-reverse! out))))
		 (else (john-fail "can't evaluate " x)))))))

(define-function john-sat-instances (using by)	; (actor action args), as john-children enumerates them
  (let ((out ()))
    (list-do a *john-actions*
      (and (or (not using) (member? (cadr a) using))
	   (list-do actor (if by (list by) (john-instances (car a)))
	     (and (john-isa? (john-object-class actor) (car a))
		  (list-do args (john-combos (map car (caddr a))) (push out (list actor a args)))))))
    (list-reverse! out)))
(define-function john-sat-mutable ()	; ((object prop ...) ...): what some effect may write, by john-holders
  (let ((out ()))
    (list-do a *john-actions*
      (let ((env (cons (cons 'it (car a)) (map (lambda (p) (cons (cadr p) (car p))) (caddr a)))))
	(list-do e (cadddr a)
	  (list-do o (john-holders (john-static-class (cadr e) env) (caddr e))
	    (let ((row (assq o out)))
	      (or row (let () (push out (list o)) (set row (car out))))
	      (or (member? (caddr e) (cdr row)) (set-cdr row (cons (caddr e) (cdr row)))))))))
    (list-do row out (list-do p (cdr row)
		       (let ((s (john-sort-of (car row) p))) (and s (not (= s 'name)) (john-sat-refuse (concat-strings "a " (if (= s 'number) "number" "list") " that changes (" (symbol->string (car row)) " " (symbol->string p) ")"))))))
    out))
(define-function john-sat-allowed (o g t using)	; (action . literal): goal-optimizations narrowing step t (G13)
  (and (not using)
       (let ((env (list (cons 'it (sat-const o)))) (conds ()))
	 (list-do p *john-gopts* (and (= g (cadr p)) (john-isa? (john-object-class o) (car p))
				      (push conds (cons (sat-truth (sat-eval (cadddr p) t env)) (caddr p)))))
	 (and conds
	      (let ((none (sat-and (map (lambda (cd) (- (car cd))) conds))) (out ()))
		(list-do a *john-actions*
		  (or (assq (cadr a) out)
		      (push out (cons (cadr a) (sat-or (cons none (let ((ls ())) (list-do cd conds (and (member? (cadr a) (cdr cd)) (push ls (car cd)))) ls)))))))
		out)))))
(define-function sat-require (x l) (or (= l *sat-t*) (cnf-clause *sat-c* (list (- x) l))))

(define-function sat-one-hot (x)	; x, its one name said outright: implied, and it lets the solver propagate
  (or (sat-const? x)
      (let ((ls (map cdr (cdr x))))
	(cnf-clause *sat-c* ls)
	(while ls (list-do l (cdr ls) (cnf-clause *sat-c* (list (- (car ls)) (- l)))) (set ls (cdr ls)))))
  x)
;; a cell at t + 1: the value of the write taken, else its value at t.  Writes of different
;; actions exclude each other (one action a step); of one action the later wins, as john-write's.
(define-function sat-next (o p cur writes)	; writes: ((object prop literal value variable) ...), in order
  (let ((mine ()))
    (list-do w writes (and (= o (car w)) (= p (cadr w)) (push mine w)))	; newest first
    (if (not mine) cur
      (let ((taken ()) (later ()))	; (literal . value), each write's literal unless a later one of its action wins
	(list-do w mine
	  (let ((over ())) (list-do l later (and (= (car l) (car (cddddr w))) (push over (- (cdr l)))))
	    (push taken (cons (sat-and (cons (caddr w) over)) (cadddr w)))
	    (push later (cons (car (cddddr w)) (caddr w)))))
	(let ((kept (sat-and (map (lambda (c) (- (car c))) taken))))
	  (sat-merge (cons (cons kept cur) taken)))))))
;; one formula grows a step at a time; each length adds its goal, solves, and takes it back
(define-structure <john-sat> (o g args using cnf goal instances acts))
(define-function john-sat-begin (o g args using by)
  (let ((enc (new <john-sat>)) (c (cnf-new)))
    (set (<john-sat>-o enc) o) (set (<john-sat>-g enc) g) (set (<john-sat>-args enc) args) (set (<john-sat>-using enc) using)
    (set (<john-sat>-cnf enc) c) (set (<john-sat>-goal enc) (john-goal-of o g)) (set (<john-sat>-instances enc) (john-sat-instances using by))
    (set *sat-c* c) (set *sat-t* (cnf-true c)) (set *sat-reach* *sat-t*) (set *sat-errs* ()) (set *sat-depth* 0)
    (set *sat-states* (array (+ *john-limit* 1)))
    (set-array-at *sat-states* 0 (map (lambda (row) (cons (car row) (map (lambda (p) (cons p (sat-const (john-lookup *john-world* (car row) p)))) (cdr row))))
				      (john-sat-mutable)))
    enc))
(define-function john-sat-step (enc t)	; step t: one action, its rules and optimizations, state t + 1
  (let ((c (<john-sat>-cnf enc)) (xs ()) (writes ()) (allowed ()))
    (set *sat-errs* ())
    (set allowed (john-sat-allowed (<john-sat>-o enc) (<john-sat>-g enc) t (<john-sat>-using enc)))
    (list-do l *sat-errs* (cnf-assert c (- l)))	; a goal-optimization that stops the evaluator
    (list-do inst (<john-sat>-instances enc)
      (let* ((actor (car inst)) (a (cadr inst)) (vals (caddr inst)) (x (cnf-var c))
	     (env (sat-bind (map cadr (caddr a)) vals (list (cons 'it (sat-const actor)))))
	     (al (cdr (assq (cadr a) allowed))))
	(push xs x)
	(set (<john-sat>-acts enc) (cons (cons x (cons t (cons actor (cons (cadr a) vals)))) (<john-sat>-acts enc)))
	(set *sat-errs* ())
	(and al (sat-require x al))
	(list-do r *john-rules* (and (= (car r) (car a)) (= (cadr r) (cadr a)) (sat-require x (sat-truth (sat-eval (caddr r) t env)))))
	(list-do p *john-aopts* (and (= (cadr p) (cadr a)) (john-isa? (john-object-class actor) (car p))
				     (sat-require x (sat-truth (sat-eval (cadddr p) t env)))))
	(list-do e (cadddr a)	; (set X p v guard?): X, v and the guard read time t
	  (let ((gd (if (cddddr e) (sat-truth (sat-eval (car (cddddr e)) t env)) *sat-t*)))
	    (sat-under gd (lambda ()
	      (let ((target (sat-eval (cadr e) t env)) (v (sat-eval (cadddr e) t env)))
		(list-do tc (sat-cases target)
		  (and (symbol? (cdr tc)) (assq (caddr e) (cdr (assq (cdr tc) (array-at *sat-states* t))))
		       (push writes (list (cdr tc) (caddr e) (sat-and (list x gd (car tc))) v x)))))))))
	(list-do l *sat-errs* (sat-require x (- l)))))
    (if xs (cnf-exactly-one c xs) (cnf-assert c (- *sat-t*)))
    (set writes (list-reverse! writes))
    (set-array-at *sat-states* (+ t 1)
      (map (lambda (row) (cons (car row) (map (lambda (pv) (cons (car pv) (sat-one-hot (sat-next (car row) (car pv) (cdr pv) writes)))) (cdr row))))
	   (array-at *sat-states* t)))))
(define-function john-sat-goal (enc k)	; the goal at time k, asserted
  (let ((c (<john-sat>-cnf enc)) (goal (<john-sat>-goal enc)))
    (set *sat-errs* ())
    (cnf-assert c (sat-truth (sat-eval (cadddr goal) k (sat-bind (caddr goal) (<john-sat>-args enc) (list (cons 'it (sat-const (<john-sat>-o enc))))))))
    (list-do l *sat-errs* (cnf-assert c (- l)))))
(define-function john-sat-encode (o g args k using by)	; (cnf . ((variable time actor action args...) ...))
  (let ((enc (john-sat-begin o g args using by)))
    (for (t 0 k) (john-sat-step enc t))
    (john-sat-goal enc k)
    (cons (<john-sat>-cnf enc) (<john-sat>-acts enc))))

(define-function john-sat-plan (acts model)	; ((time actor action args...) ...), in time order
  (let ((out ())) (list-do a acts (and (array-at model (car a)) (push out (cdr a)))) out))	; acts are newest first
(define-function john-sat-replay (plan o g args using)	; the world the evaluator reaches by plan
  (let ((w *john-world*) (goal (john-goal-of o g)))
    (list-do st plan
      (let ((d ()) (actor (cadr st)) (vals (cdddr st)) (u (john-using w o g using)))
	(list-do x *john-actions* (and (= (caddr st) (cadr x)) (john-isa? (john-object-class actor) (car x)) (set d x)))
	(let ((child (and d (or (not u) (member? (caddr st) u)) (john-allowed? w actor d vals) (john-step w actor d vals))))
	  (or child (error "E_ENCODING: step " (car st) " (" (john-step-text (cdr st)) ") not possible in the evaluator"))
	  (set w child))))
    (or (john-true? (john-eval (cadddr goal) w (john-bind (caddr goal) args (list (cons 'it o))))) (error "E_ENCODING: goal not reached"))
    w))

(define-function john-sat-satisfy (o g args using by)
  (john-sat-check)
  (let ((k 0) (done ()) (n (format "%d" (john-sat-width))))
    (set *sat-conflicts* (cdr (assq 'sat-conflicts *john-options*)))
    (let ((enc (john-sat-begin o g args using by)))
     (while (and (not done) (<= k *john-limit*))
      (and (< 0 k) (john-sat-step enc (- k 1)))
      (let* ((c (<john-sat>-cnf enc)) (kept (<cnf>-clauses c)) (nv (cnf-nvars c)) (cls (let () (john-sat-goal enc k) (cnf-clauses c)))
	     (n-vars (cnf-nvars c)) (r (sat-decide-clean n-vars cls)))
	(set (<cnf>-clauses c) kept) (set (<cnf>-nvars c) nv)	; the goal at k only
	(john-say (concat-strings "trying " (format "%d" k) " steps (" (format "%d" n-vars) " variables, " (format "%d" (list-length cls)) " clauses): "
				  (cond ((= 'sat (car r)) "satisfiable") ((= 'unsat (car r)) "unsatisfiable") (else "unknown"))))
	(cond ((= 'sat (car r)) (set done 1) (john-satisfied (john-sat-replay (john-sat-plan (<john-sat>-acts enc) (cdr r)) o g args using)))
	      ((= 'unknown (car r)) (set done 1)
	       (john-say (concat-strings "unknown at " (format "%d" k) " steps (conflict limit " (format "%d" *sat-conflicts*) ")")))
	      (else (set k (+ k 1)))))))
    (or done (john-say (concat-strings "unsatisfiable within " (format "%d" *john-limit*) " steps (width " n ", lists "
				       (format "%d" (john-sat-option 'sat-list-length 16)) ", unroll " (format "%d" (john-sat-unroll)) ")")))))

(define-function john-run-sorts (forms)
  (john-reset)
  (list-do s forms (or (= 'satisfy (car s)) (john-statement s)))
  (john-sat-check))
