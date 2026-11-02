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

(define-function john-sat-nth (l i)
  (while (< 0 i)
    (set l (cdr l))
    (set i (- i 1)))
  l)
(define-function assoc-sort (s o p)	; the entry ((o p) . sort) of s, or ()
  (let ((r ()))
    (list-do e s (and (not r) (= o (car (car e))) (= p (cadr (car e))) (set r e)))
    r))

;;; ---- sorts

(define-function john-sort-text (s)
  (cond ((= s 'number) "a number")
	((= s 'name) "a name")
	(else "a list")))
(define-function john-sort-unify (a b)	; the sort agreeing with both, or clash
  (cond ((not a) b)
	((not b) a)
	((and (pair? a) (pair? b))
	 (let ((e (john-sort-unify (cadr a) (cadr b)))) (if (= e 'clash) e (list 'list e))))
	((= a b) a)
	(else 'clash)))
(define-selector john-value-sort (v) 'name)
(define-method john-value-sort <long> () 'number)
(define-method john-value-sort <undefined> () '(list ()))
(define-method john-value-sort <john-class-ref> () '(list name))
(define-method john-value-sort <pair> ()
  (let ((e ()))
    (list-do x self
      (let ((u (john-sort-unify e (john-value-sort x))))
	(and (= u 'clash) (john-fail "a list of " (john-text self) " mixes sorts"))
	(set e u)))
    (list 'list e)))

(define *john-sorts* ())	; ((object prop) . sort)
(define-function john-sort-of (o p) (cdr (assoc-sort *john-sorts* o p)))
(define-function john-sort-add (o p s)	; true when the entry changed
  (let* ((e (assoc-sort *john-sorts* o p)) (old (cdr e)) (u (john-sort-unify old s)))
    (and (= u 'clash)
	 (error "E_SORT: " o " " p " is " (john-sort-text old) " and " (john-sort-text s)))
    (and (not (equal u old)) (let () (set-cdr e u) 1))))

;; what an expression names statically: the class of the object it is, or ()
(define-function john-static-class (x env)
  (and (symbol? x)
       (let ((b (assq x env)))
	 (cond (b (cdr b))
	       ((john-object? x) (john-object-class x))
	       (else ())))))
(define-function john-holders (c p)	; the objects whose property p an X of class c can be
  (let ((out ()))
    (list-do o *john-objects*
      (and (if c (john-isa? (cdr o) c) 1) (member? p (john-props (cdr o))) (push out (car o))))
    out))
(define-function john-static-sort (x env)	; env: (name . class)
  (cond ((symbol? x)
	 (cond ((assq x env) 'name)
	       ((member? x '(yes no empty)) 'name)
	       ((john-object? x) 'name)
	       ((john-class x) '(list name))
	       ((= x 'time) 'number)
	       (else ())))
	((not (pair? x)) (john-value-sort x))
	(else (let ((op (car x)))
		(cond ((= op 'list)
		       (let ((e ()))
			 (list-do a (cdr x)
			   (let ((u (john-sort-unify e (john-static-sort a env))))
			     (or (= u 'clash) (set e u))))
			 (list 'list e)))
		      ((member? op '(* /)) 'number)
		      ((member? op '(+ -))
		       (let ((a (john-static-sort (cadr x) env)))
			 (if (pair? a) a (and (= a 'number) a))))
		      ((member? op '(= < > <= >= and or not rel every any)) 'name)
		      ((member? op '(all select)) '(list name))
		      ((and (= op 'send) (not (cdddr x)))
		       (let ((c (john-static-class (cadr x) env)) (p (caddr x)) (s ()))
			 (cond ((= p 'size) 'number)
			       (c (list-do o (john-holders c p)
				    (let ((u (john-sort-unify s (john-sort-of o p))))
				      (or (= u 'clash) (set s u))))
				  s)
			       (else ()))))
		      (else ()))))))

;; one pass over every action's effects; true when a sort changed
(define-function john-effect-sorts ()
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
  (list-do e *john-sorts*
    (john-sort-add (car (car e))
		   (cadr (car e))
		   (john-value-sort (john-lookup *john-world* (car (car e)) (cadr (car e))))))
  (let ((n 0)) (while (and (< n 8) (john-effect-sorts)) (set n (+ n 1))))
  *john-sorts*)

;;; ---- bounds: every number the program holds or names fits sat-width bits, signed

(define-function john-sat-option (name default) (or (cdr (assq name *john-options*)) default))
(define-function john-sat-width () (or (cdr (assq 'sat-width *john-options*)) 16))
(define-function john-bound-check (x w)
  (cond ((long? x)
	 (let ((top 1)) (for (i 1 w) (set top (* top 2)))
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
;; a value's lists, each no longer than sat-list-length
(define-function john-list-bound-check (v n)
  (and (pair? v)
       (let ()
	 (and (> (list-length v) n)
	      (error "E_BOUND: a list of " (list-length v) " does not fit sat-list-length " n))
	 (list-do x v (john-list-bound-check x n)))))
(define-function john-sat-check ()
  (list-do opt '(two-player-game max-time-ahead)
    (and (cdr (assq opt *john-options*)) (john-sat-refuse (symbol->string opt))))
  (list-do table (list *john-quals*
		       *john-rels*
		       *john-actions*
		       *john-rules*
		       *john-goals*
		       *john-aopts*
		       *john-gopts*
		       *john-heuristics*)
    (john-sat-scan table)
    (john-bound-check table (john-sat-width)))
  (list-do e (john-sorts)
    (let ((v (john-lookup *john-world* (car (car e)) (cadr (car e)))))
      (john-bound-check v (john-sat-width))
      (john-list-bound-check v (john-sat-option 'sat-list-length 16)))))

;;; ---- the encoding [R-bmc-encoding]: states 0 .. k, one action per step, the goal at k
;;;
;;; A value is (const . v), known when the formula is built; (names (v . literal) ...) over
;;; constants v (names, or the numbers a varying object holds), exactly one literal true; or
;;; (bv bit ...), a number that changes, sat-width bits in two's complement; or (lst len . elements),
;;; a list that changes, len a value over its lengths and the elements' terms in order (those past
;;; the length absent).  The literals of one one-hot value exclude each other, and a conjunction of
;;; two of them is false (*sat-groups*); a qualification asked twice at one time, of the same
;;; terms, is inlined once (*sat-memo*).  An expression is encoded under a path, the literal under which
;;; the evaluator would reach it; where the evaluator would stop with an error the literal
;;; (path and cause) goes in *sat-errs*, and the step or goal that read it is impossible.

(define-function john-sat-unroll () (john-sat-option 'sat-unroll 16))
(define *sat-c* ())		; the formula being built
(define *sat-t* ())		; its true literal
(define *sat-reach* ())		; the literal under which the expression being encoded is read
(define *sat-errs* ())		; literals under which it stops with an error
(define *sat-depth* 0)		; qualifications inlined, one inside another
;; time -> ((object (prop . value) ...) ...), the properties effects write
(define *sat-states* ())

(define *sat-groups* (array))	; a literal's code -> the one-hot groups it is in
(define *sat-group-n* 0)
(define *sat-memo* (array))	; time -> ((sel receiver args value . errors) ...)
(define *sat-memo-on* ())	; off for the goal, whose literals are taken back
(define-function sat-code (l) (if (< l 0) (+ 1 (* -2 l)) (* 2 l)))
(define-function sat-exclusive? (a b)
  (let ((ga (array-at *sat-groups* (sat-code a))) (r ()))
    (and ga (list-do g (array-at *sat-groups* (sat-code b)) (and (member? g ga) (set r 1))))
    r))
(define-function sat-group! (lits)	; lits: at most one true
  (and *sat-memo-on*
       (cdr lits)
       ;; passed along, not new: already known (folding is only an economy)
       (not (sat-exclusive? (car lits) (cadr lits)))
       (let ()
	 (set *sat-group-n* (+ 1 *sat-group-n*))
	 (list-do l lits
	   (set-array-at *sat-groups*
			 (sat-code l)
			 (cons *sat-group-n* (array-at *sat-groups* (sat-code l))))))))
;; a conjunction, folded where its literals are known or exclude each other
(define-function sat-and (ls)
  (let ((out ()) (f ()))
    (list-do l ls
      (cond ((= l *sat-t*))
	    ((or (= l (- *sat-t*)) (member? (- l) out)) (set f 1))
	    ((member? l out))
	    (else (push out l))))
    (and (not f)
	 (cdr out)
	 (let ((o out))
	   (while (and o (not f))
	     (list-do l (cdr o) (and (sat-exclusive? (car o) l) (set f 1)))
	     (set o (cdr o)))))
    (cond (f (- *sat-t*))
	  ((not out) *sat-t*)
	  ((not (cdr out)) (car out))
	  (else (cnf-and *sat-c* out)))))
(define-function sat-or (ls) (- (sat-and (map - ls))))
(define-function sat-mux (s a b)
  (cond ((= s *sat-t*) a)
	((= s (- *sat-t*)) b)
	((= a b) a)
	(else (cnf-mux *sat-c* s a b))))
(define-function sat-err (l)
  (let ((e (sat-and (list *sat-reach* l)))) (or (= e (- *sat-t*)) (push *sat-errs* e))))
(define-function sat-under (l thunk)	; thunk's value, its errors only where l holds
  (let ((saved *sat-reach*))
    (set *sat-reach* (sat-and (list saved l)))
    (let ((v (thunk))) (set *sat-reach* saved) v)))

(define-function sat-const (v) (cons 'const v))
(define-function sat-const? (x) (= 'const (car x)))
(define-function sat-bv? (x) (= 'bv (car x)))
(define-function sat-names (x)	; ((v . literal) ...)
  (cond ((sat-const? x) (list (cons (cdr x) *sat-t*)))
	((sat-bv? x) (john-sat-refuse "a changing number where one of a few values is read"))
	((= 'lst (car x)) (john-sat-refuse "a changing list where one of a few values is read"))
	(else (cdr x))))
(define-function sat-to-bv (x)	; (bits . literal): x's bits, and where x is a number at all
  (let ((w (john-sat-width)) (f (- *sat-t*)))
    (cond ((sat-bv? x) (cons (cdr x) *sat-t*))
	  ((sat-const? x)
	   (if (long? (cdr x))
	       (cons (cnf-bv-const *sat-c* (cdr x) w) *sat-t*)
	       (cons (cnf-bv-const *sat-c* 0 w) f)))
	  (else (let ((nums ()))
		  (list-do e (cdr x) (and (long? (car e)) (push nums e)))
		  (cons (map (lambda (i)
			       (sat-or (let ((ls ()))
					 (list-do e nums
					   (and (= *sat-t*
						   (car
						     (john-sat-nth
						       (cnf-bv-const *sat-c* (car e) w)
						       i)))
						(push ls (cdr e))))
					 ls)))
			     (let ((is ()))
			       (for (i 0 w) (push is i))
			       (list-reverse! is)))
			(sat-or (map cdr nums))))))))
(define-function sat-entry (v alist)
  (let ((r ()))
    (list-do e alist (and (not r) (equal v (car e)) (set r e)))
    r))
(define-function sat-lit-of (x n)
  (let ((e (sat-entry n (sat-names x)))) (if e (cdr e) (- *sat-t*))))
(define-function sat-names-value (alist)	; false names dropped; one true name is a constant
  (let ((out ()))
    (list-do e alist (or (= (cdr e) (- *sat-t*)) (push out e)))
    (if (and out (not (cdr out)) (= *sat-t* (cdr (car out))))
	(sat-const (car (car out)))
	(let ()
	  (sat-group! (map cdr out))
	  (cons 'names (list-reverse! out))))))
(define-function sat-union (xs)	; the names any of xs can be
  (let ((ns ()))
    (list-do x xs
      (list-do e (sat-names x) (or (sat-entry (car e) (map list ns)) (push ns (car e)))))
    (list-reverse! ns)))
;; defined below
(define sat-equal)
(define sat-list-like?)
(define sat-list-term)
(define sat-list-cases)
(define sat-lst)
(define sat-range)
(define-function sat-truth (x)	; john-true?: neither no nor the empty list
  (cond ((sat-bv? x) *sat-t*)
	((= 'lst (car x)) (- (sat-equal (cadr x) (sat-const 0))))
	((sat-const? x) (if (john-true? (cdr x)) *sat-t* (- *sat-t*)))
	(else (- (sat-or (let ((ls ()))
			   (list-do e (cdr x) (or (john-true? (car e)) (push ls (cdr e))))
			   ls))))))
(define-function sat-bool (l)
  (cond ((= l *sat-t*) (sat-const 'yes))
	((= l (- *sat-t*)) (sat-const 'no))
	(else (cons 'names (list (cons 'yes l) (cons 'no (- l)))))))
(define-function sat-equal (a b)
  (cond ((and (sat-const? a) (sat-const? b)) (if (equal (cdr a) (cdr b)) *sat-t* (- *sat-t*)))
	((or (= 'lst (car a)) (= 'lst (car b)))
	 (if (not (and (sat-list-like? a) (sat-list-like? b)))
	     (- *sat-t*)
	     (let ((ls ()))
	       (list-do ca (sat-list-cases a)
		 (list-do cb (sat-list-cases b)
		   (and (= (list-length (cdr ca)) (list-length (cdr cb)))
			(push ls
			      (sat-and (cons (car ca)
					     (cons (car cb) (map sat-equal (cdr ca) (cdr cb)))))))))
	       (sat-or ls))))
	((or (sat-bv? a) (sat-bv? b))
	 (let ((x (sat-to-bv a)) (y (sat-to-bv b)))
	   (sat-and (list (cdr x) (cdr y) (cnf-bv-eq *sat-c* (car x) (car y))))))
	(else (sat-or (map (lambda (e) (sat-and (list (cdr e) (sat-lit-of b (car e)))))
			   (sat-names a))))))
;; the value of a branch the evaluator stops in: its error is recorded, and merges drop it
(define *sat-stop* (cons 'const 'no))
;; ((literal . value) ...), at most one literal true; partial: some other branch stopped
(define-function sat-merge (choices . partial)
  ;; a branch that stops leaves the rest conditional on their literals, so later choices stay apart
  (let ((live ()) (stopped (and partial (car partial))))
    (list-do ch choices
      (cond ((= (car ch) (- *sat-t*)))
	    ((= (cdr ch) *sat-stop*) (set stopped 1))
	    (else (push live ch))))
    (set live (list-reverse! live))
    (cond ((not live) *sat-stop*)	; no choice can be taken: an error is recorded for it
	  ((let ((b ()))
	     (list-do ch live (and (sat-bv? (cdr ch)) (set b 1)))
	     b)	; a number that changes: bit by bit
	   (let ((vs (map (lambda (ch) (car (sat-to-bv (cdr ch)))) live)))
	     (cons 'bv
		   (map (lambda (i)
			  (sat-or (map (lambda (ch v)
					 (sat-and (list (car ch) (car (john-sat-nth v i)))))
				       live
				       vs)))
			(let ((is ()))
			  (for (i 0 (john-sat-width)) (push is i))
			  (list-reverse! is))))))
	  ((let ((same (not stopped)))
	     (list-do ch live
	       (or (and (sat-const? (cdr ch))
			(sat-const? (cdr (car live)))
			(equal (cdr (cdr ch)) (cdr (cdr (car live)))))
		   (set same ())))
	     same)
	   (cdr (car live)))
	  ((let ((all 1))
	     (list-do ch live (or (sat-list-like? (cdr ch)) (set all ())))
	     all)	; lists: length and each element
	   (let ((ls (map (lambda (ch) (sat-list-term (cdr ch))) live)) (m 0))
	     (list-do l ls (set m (if (> (list-length (cddr l)) m) (list-length (cddr l)) m)))
	     (sat-lst (sat-merge (map (lambda (ch l) (cons (car ch) (cadr l))) live ls) stopped)
		      (map (lambda (i)
			     (let ((chs ()))
			       (map (lambda (ch l)
				      (and (< i (list-length (cddr l)))
					   (push chs
						 (cons (car ch) (car (john-sat-nth (cddr l) i))))))
				    live
				    ls)
			       (sat-merge (list-reverse! chs) stopped)))
			   (sat-range m)))))
	  (else (sat-names-value (map (lambda (n)
					(cons n
					      (sat-or
						(map
						  (lambda (ch)
						    (sat-and
						      (list (car ch) (sat-lit-of (cdr ch) n))))
						  live))))
				      (sat-union (map cdr live))))))))
(define-function sat-cases (x)	; ((literal . constant) ...)
  (if (sat-const? x)
      (list (cons *sat-t* (cdr x)))
      (map (lambda (e) (cons (cdr e) (car e))) (cdr x))))
(define-function sat-combos (cases)	; one case of each
  (if (not cases)
      (list ())
      (let ((out ()) (rest (sat-combos (cdr cases))))
	(list-do c (car cases) (list-do r rest (push out (cons c r))))
	(list-reverse! out))))
;; f of terms: each case of xs' one-hot values a constant, lists and changing numbers as they are
(define-function sat-split (xs f)
  (let ((known 1))
    (list-do x xs (and (= 'names (car x)) (set known ())))
    (if known
	(f xs)
	(let ((choices ()))
	  (list-do combo (sat-combos (map (lambda (x)
					    (if (= 'names (car x))
						(map (lambda (e) (cons (cdr e) (sat-const (car e))))
						     (cdr x))
						(list (cons *sat-t* x))))
					  xs))
	    (let ((l (sat-and (map car combo))))
	      (or (= l (- *sat-t*))
		  (push choices (cons l (sat-under l (lambda () (f (map cdr combo)))))))))
	  (sat-merge (list-reverse! choices))))))
(define-function sat-bind (names vals env) (john-bind names (map sat-const vals) env))
(define-function sat-range (n)
  (let ((out ()))
    (for (i 0 n) (push out i))
    (list-reverse! out)))
(define-function sat-take (l n)
  (let ((out ()))
    (while (and l (< 0 n))
      (push out (car l))
      (set l (cdr l))
      (set n (- n 1)))
    (list-reverse! out)))

;;; ---- lists
(define-function sat-lst (len elems) (cons 'lst (cons len elems)))
(define-function sat-list-like? (x)
  (cond ((= 'lst (car x)) 1)
	((sat-const? x) (or (pair? (cdr x)) (not (cdr x))))
	((= 'names (car x))
	 (let ((all 1))
	   (list-do e (cdr x) (or (pair? (car e)) (not (car e)) (set all ())))
	   all))
	(else ())))
(define-function sat-list-term (x)	; a list-like x as (lst len . elements)
  (cond ((= 'lst (car x)) x)
	((sat-const? x) (sat-lst (sat-const (list-length (cdr x))) (map sat-const (cdr x))))
	(else (let ((m 0))
		(list-do e (cdr x) (and (> (list-length (car e)) m) (set m (list-length (car e)))))
		(sat-lst (sat-merge (map (lambda (e)
					   (cons (cdr e) (sat-const (list-length (car e)))))
					 (cdr x)))
			 (map (lambda (i)
				(sat-merge (let ((chs ()))
					     (list-do e (cdr x)
					       (and
						 (< i (list-length (car e)))
						 (push
						   chs
						   (cons
						     (cdr e)
						     (sat-const (car (john-sat-nth (car e) i)))))))
					     (list-reverse! chs))))
			      (sat-range m)))))))
(define-function sat-list-cases (x)	; ((literal . elements) ...), one for each length x can have
  (let ((l (sat-list-term x)))
    (map (lambda (c) (cons (car c) (sat-take (cddr l) (cdr c)))) (sat-cases (cadr l)))))
;; a list of these terms; longer than sat-list-length stops the step
(define-function sat-make-list (es)
  (and (> (list-length es) (john-sat-option 'sat-list-length 16)) (sat-err *sat-t*))
  (let ((known 1)) (list-do e es (or (sat-const? e) (set known ())))
    (if known (sat-const (map cdr es)) (sat-lst (sat-const (list-length es)) es))))
;; a builtin on a list of terms, as john-eval.l's methods; args constants
(define-function sat-list-op (es sel args)
  (let ((n (list-length es)) (k (car args)))
    (cond ((= sel 'size) (sat-const n))
	  ((and (= n 0) (member? sel '(first second third rest last at: name)))
	   (sat-err *sat-t*)
	   *sat-stop*)
	  ((= sel 'first) (car es))
	  ((= sel 'second) (if (< n 2) (sat-const ()) (cadr es)))
	  ((= sel 'third) (if (< n 3) (sat-const ()) (caddr es)))
	  ((= sel 'rest) (sat-make-list (cdr es)))
	  ((= sel 'last) (car (john-sat-nth es (- n 1))))
	  ((not (member? sel '(at: to: from:))) (sat-err *sat-t*) *sat-stop*)
	  ((not (long? k)) (sat-err *sat-t*) *sat-stop*)
	  ((= sel 'at:)
	   (if (and (<= 1 k) (<= k n))
	       (car (john-sat-nth es (- k 1)))
	       (let ()
		 (sat-err *sat-t*)
		 *sat-stop*)))
	  ((= sel 'to:)
	   (if (< k 0)
	       (let ()
		 (sat-err *sat-t*)
		 *sat-stop*)
	       (sat-make-list (sat-take es k))))
	  (else (sat-make-list (if (< k 2) es (john-sat-nth es (- k 1))))))))
(define-function sat-inc (x)	; a count one more
  (if (sat-const? x)
      (sat-const (+ 1 (cdr x)))
      (sat-names-value (map (lambda (e) (cons (+ 1 (car e)) (cdr e))) (cdr x)))))
(define-function sat-compact (es keeps)	; the elements whose literal holds, in order
  (let ((known 1))
    (list-do k keeps (or (= k *sat-t*) (= k (- *sat-t*)) (set known ())))
    (if known
	(sat-make-list (let ((out ()))
			 (map (lambda (e k) (and (= k *sat-t*) (push out e))) es keeps)
			 (list-reverse! out)))
	(let ((cnt (sat-const 0)) (slots (array (+ 1 (list-length es)))))
	  (map (lambda (e k)
		 (list-do c (sat-cases cnt)
		   (let ((l (sat-and (list k (car c)))))
		     (or (= l (- *sat-t*))
			 (set-array-at slots (cdr c) (cons (cons l e) (array-at slots (cdr c)))))))
		 (set cnt (sat-merge (list (cons k (sat-inc cnt)) (cons (- k) cnt)))))
	       es
	       keeps)
	  (sat-lst cnt
		   (let ((out ()))
		     (for (i 0 (list-length es))
		       (and (array-at slots i)
			    (push out (sat-merge (list-reverse! (array-at slots i))))))
		     (list-reverse! out)))))))
;; + appends an element or a list's elements, - removes them; a is a list
(define-function sat-list-arith (op a b)
  (if (not (sat-list-like? a))
      (let ()
	(sat-err *sat-t*)
	*sat-stop*)	; a number with a list: the evaluator's error
      (let ((bs (if (sat-list-like? b) (sat-list-cases b) (list (cons *sat-t* (list b))))) (out ()))
	(list-do ca (sat-list-cases a)
	  (list-do cb bs
	    (let ((l (sat-and (list (car ca) (car cb)))))
	      (or (= l (- *sat-t*))
		  (push out
			(cons l
			      (sat-under
				l
				(lambda ()
				  (if (= op '+)
				      (sat-make-list (concat-list (cdr ca) (cdr cb)))
				      (sat-compact
					(cdr ca)
					(map (lambda (x)
					       (- (sat-or
						    (map (lambda (y) (sat-equal x y)) (cdr cb)))))
					     (cdr ca))))))))))))
	(sat-merge (list-reverse! out)))))
(define-function sat-member (a b)	; a in b, a collection
  (if (sat-const? b)
      (if (sat-const? a) (sat-const (john-bool (member? (cdr a) (john-elements (cdr b)))))
	(sat-bool (sat-or (map (lambda (e) (sat-equal a (sat-const e))) (john-elements (cdr b))))))
      (sat-merge (map (lambda (cs)
			(cons (car cs)
			      (sat-bool (sat-or (map (lambda (e) (sat-equal a e)) (cdr cs))))))
		      (sat-list-cases b)))))

(define-function sat-cell (o p t)	; o's p at time t
  (let ((e (assq p (cdr (assq o (array-at *sat-states* t))))))
    (if e (cdr e) (sat-const (john-lookup *john-world* o p)))))
(define-function sat-builtin-ok? (r sel args)	; the evaluator's builtin answers, without an error
  (cond ((= sel 'name) (string? r))
	((member? sel '(size from:)) (or (pair? r) (not r)))
	((= sel 'to:) (and (or (pair? r) (not r)) (long? (car args)) (<= 0 (car args))))
	((= sel 'at:)
	 (and (pair? r) (long? (car args)) (<= 1 (car args)) (<= (car args) (list-length r))))
	(else (pair? r))))
(define sat-eval)
(define sat-qualify)
;; A piece of encoding asked again at one time, of equal terms, is the same formula: it is
;; built once (*sat-memo*), under the true literal, and each reader records its errors under
;; its own path.  Equal terms share literals, so a term rebuilt from the same parts still hits.
(define-function sat-memo (t key thunk)
  (if (not *sat-memo-on*)
      (thunk)
    (let ((hit ()))
      (list-do e (array-at *sat-memo* t)
	(and (not hit) (equal key (car e)) (set hit e)))
      (or hit
	  (let ((reach *sat-reach*)
		(errs *sat-errs*))
	    (set *sat-reach* *sat-t*)
	    (set *sat-errs* ())
	    (let ((v (thunk)))
	      (set hit (cons key (cons v *sat-errs*)))
	      (set *sat-reach* reach)
	      (set *sat-errs* errs)
	      (set-array-at *sat-memo* t (cons hit (array-at *sat-memo* t))))))
      (list-do l (cddr hit) (sat-err l))
      (cadr hit))))
;; r and args terms: constants, lists, changing numbers
(define-function sat-send-1 (r sel args t)
  (let ((c (cond ((sat-const? r) (john-class-of (cdr r)))
		 ((= 'lst (car r)) 'List)
		 (else 'Number)))
	(known 1))
    (list-do a args (or (sat-const? a) (set known ())))
    (cond ((and (sat-const? r) (john-object? (cdr r)) (not args) (member? sel (john-props c)))
	   (sat-cell (cdr r) sel t))
	  ((john-quals c sel)
	   (sat-memo t (cons sel (cons r args))
		     (lambda () (sat-qualify r (john-quals c sel) args t))))
	  ((not (assq sel *john-builtins*)) (sat-err *sat-t*) *sat-stop*)
	  ((not known) (john-sat-refuse "a builtin's argument that is a list or a changing number"))
	  ((= 'lst (car r))
	   (sat-memo t
		     (cons sel (cons r args))
		     (lambda ()
		       (sat-merge (map (lambda (cs)
					 (cons (car cs)
					       (sat-under
						 (car cs)
						 (lambda ()
						   (sat-list-op (cdr cs) sel (map cdr args))))))
				       (sat-list-cases r))))))
	  ((and (sat-const? r) (sat-builtin-ok? (cdr r) sel (map cdr args)))
	   (sat-const (john-builtin (cdr r) sel (map cdr args))))
	  (else (sat-err *sat-t*) *sat-stop*))))
;; the first clause whose guard holds gives the value; an if-qualification is yes or no
(define-function sat-qualify (r clauses args t)
  (if (>= *sat-depth* (john-sat-unroll))
      (let ()
	(sat-err *sat-t*)
	*sat-stop*)
      (set *sat-depth* (+ 1 *sat-depth*))
      (let ((before *sat-t*) (choices ()))
	(list-do q clauses
	  (or (= before (- *sat-t*))
	      (let* ((env (john-bind (caddr q) args (list (cons 'it r))))
		     (b (cadddr q))
		     (g (sat-under before
				   (lambda ()
				     (cond ((= 'if (car b)) (sat-truth (sat-eval (cadr b) t env)))
					   ((cddr b) (sat-truth (sat-eval (caddr b) t env)))
					   (else *sat-t*)))))
		     (chosen (sat-and (list before g))))
		(or (= chosen (- *sat-t*))
		    (push choices
			  (cons chosen
				(if (= 'if (car b))
				    (sat-const 'yes)
				    (sat-under chosen (lambda () (sat-eval (cadr b) t env)))))))
		(set before (sat-and (list before (- g)))))))
	(if (= 'if (car (cadddr (car clauses))))
	    (push choices (cons before (sat-const 'no)))
	    (sat-err before))
	(set *sat-depth* (- *sat-depth* 1))
	(sat-merge (list-reverse! choices)))))
(define-function sat-holds (r a b t)
  (if (= r 'in)
      (sat-split (list a b) (lambda (cs) (sat-member (car cs) (cadr cs))))
      (let ((d (assq r *john-rels*)))
	(or d (john-fail "no relation " r))
	(sat-bool (sat-truth (sat-eval (cadddr d)
				       t
				       (list (cons (cadr (cadr d)) a)
					     (cons (cadr (caddr d)) b))))))))
(define-function sat-known (x what)	; x's constant; a changing one isn't encoded yet
  (if (sat-const? x) (cdr x) (john-sat-refuse what)))
(define-function sat-fits? (n)
  (let ((top 1))
    (for (i 1 (john-sat-width)) (set top (* top 2)))
    (and (<= (- top) n) (< n top))))
;; on constants, as the evaluator, a term; dividing by zero, a type error or a number past sat-width
;; stops it
(define-function sat-arith (op a b)
  (cond ((and (member? op '(< > <= >=)) (not (and (long? a) (long? b))))
	 (sat-err *sat-t*)
	 *sat-stop*)
	((member? op '(< > <= >=))
	 (sat-const (john-bool (cond ((= op '<) (< a b))
				     ((= op '>) (> a b))
				     ((= op '<=) (<= a b))
				     (else (>= a b))))))
	((and (= op '/) (long? b) (= 0 b)) (sat-err *sat-t*) *sat-stop*)
	((not (if (member? op '(+ -))
		  (or (and (long? a) (long? b)) (pair? a) (not a))
		  (and (long? a) (long? b))))
	 (sat-err *sat-t*)
	 *sat-stop*)	; john-arith's type errors
	(else (let ((r (john-arith op a b)))
		(if (and (long? r) (not (sat-fits? r)))
		    (let ()
		      (sat-err *sat-t*)
		      *sat-stop*)
		    (sat-const r))))))
;; a number that changes, by circuits; a result past sat-width stops the step
(define-function sat-bv-arith (op a b)
  (let* ((x (sat-to-bv a)) (y (sat-to-bv b)) (c *sat-c*))
    (sat-err (- (sat-and (list (cdr x) (cdr y)))))	; not a number: the evaluator's error
    (cond ((= op '<) (sat-bool (cnf-bv-lt c (car x) (car y))))
	  ((= op '>) (sat-bool (cnf-bv-lt c (car y) (car x))))
	  ((= op '<=) (sat-bool (- (cnf-bv-lt c (car y) (car x)))))
	  ((= op '>=) (sat-bool (- (cnf-bv-lt c (car x) (car y)))))
	  (else (let ((r (cond ((= op '+) (cnf-bv-add c (car x) (car y)))
			       ((= op '-) (cnf-bv-sub c (car x) (car y)))
			       ((= op '*) (cnf-bv-mul c (car x) (car y)))
			       (else (cnf-bv-div c (car x) (car y))))))
		  (sat-err (cdr r))
		  (cons 'bv (car r)))))))
(define-function sat-eval (x t env)
  (cond ((symbol? x)
	 (let ((b (assq x env)))
	   (cond (b (cdr b))
		 ((= x 'time) (sat-const t))
		 (else (sat-const (john-name x *john-world* ()))))))
	((not (pair? x)) (sat-const x))
	(else (let ((op (car x)))
		(cond ((= op 'send)
		       (sat-split (cons (sat-eval (cadr x) t env)
					(map (lambda (a) (sat-eval a t env)) (cdddr x)))
				  (lambda (cs) (sat-send-1 (car cs) (caddr x) (cdr cs) t))))
		      ((= op 'list) (sat-make-list (map (lambda (a) (sat-eval a t env)) (cdr x))))
		      ((= op '=)
		       (sat-bool (sat-equal (sat-eval (cadr x) t env) (sat-eval (caddr x) t env))))
		      ((member? op '(< > <= >= + - * /))
		       (let ((a (sat-eval (cadr x) t env)) (b (sat-eval (caddr x) t env)))
			 (cond ((and (member? op '(+ -)) (or (= 'lst (car a)) (= 'lst (car b))))
				(sat-memo t (list op a b) (lambda () (sat-list-arith op a b))))
			       ((or (sat-bv? a) (sat-bv? b)) (sat-bv-arith op a b))
			       (else (sat-split (list a b)
						(lambda (cs)
						  (if (or
							(= 'lst (car (car cs)))
							(= 'lst (car (cadr cs))))
						      (sat-list-arith op (car cs) (cadr cs))
						      (sat-arith
							op
							(cdr (car cs))
							(cdr (cadr cs))))))))))
		      ((= op 'and)
		       (let ((a (sat-truth (sat-eval (cadr x) t env))))
			 (sat-bool (sat-and (list a
						  (sat-under
						    a
						    (lambda ()
						      (sat-truth (sat-eval (caddr x) t env)))))))))
		      ((= op 'or)
		       (let ((a (sat-truth (sat-eval (cadr x) t env))))
			 (sat-bool (sat-or (list a
						 (sat-under
						   (- a)
						   (lambda ()
						     (sat-truth (sat-eval (caddr x) t env)))))))))
		      ((= op 'not) (sat-bool (- (sat-truth (sat-eval (cadr x) t env)))))
		      ((= op 'rel)
		       (sat-holds (cadr x)
				  (sat-eval (caddr x) t env)
				  (sat-eval (cadddr x) t env)
				  t))
		      ((member? op '(every any))
		       (let ((coll (sat-eval (cadr x) t env))
			     (over (lambda (es)
				     (let ((ls (map
						 (lambda (e)
						   (sat-truth
						     (sat-eval
						       (caddr x)
						       t
						       (cons (cons 'each e) env))))
						 es)))
				       (sat-bool (if (= op 'every) (sat-and ls) (sat-or ls)))))))
			 (if (sat-const? coll)
			     (over (map sat-const (john-elements (cdr coll))))
			     (sat-merge (map (lambda (cs)
					       (cons (car cs)
						     (sat-under
						       (car cs)
						       (lambda () (over (cdr cs))))))
					     (sat-list-cases coll))))))
		      ((= op 'all)
		       (if (cddr x)
			   (john-fail "all with property values is not read yet")
			   (sat-const (john-instances (cadr x)))))
		      ((= op 'select)
		       (let ((os (john-instances (cadr x))))
			 (sat-compact (map sat-const os)
				      (map (lambda (o)
					     (sat-truth
					       (sat-eval
						 (caddr x)
						 t
						 (cons (cons 'which (sat-const o)) env))))
					   os))))
		      (else (john-fail "can't evaluate " x)))))))

;; (actor action args), as john-children enumerates them
(define-function john-sat-instances (using by)
  (let ((out ()))
    (list-do a *john-actions*
      (and (or (not using) (member? (cadr a) using))
	   (list-do actor (if by (list by) (john-instances (car a)))
	     (and (john-isa? (john-object-class actor) (car a))
		  (list-do args (john-combos (map car (caddr a)))
		    (push out (list actor a args)))))))
    (list-reverse! out)))
;; ((object prop ...) ...): what some effect may write, by john-holders
(define-function john-sat-mutable ()
  (let ((out ()))
    (list-do a *john-actions*
      (let ((env (cons (cons 'it (car a)) (map (lambda (p) (cons (cadr p) (car p))) (caddr a)))))
	(list-do e (cadddr a)
	  (list-do o (john-holders (john-static-class (cadr e) env) (caddr e))
	    (let ((row (assq o out)))
	      (or row
		  (let ()
		    (push out (list o))
		    (set row (car out))))
	      (or (member? (caddr e) (cdr row)) (set-cdr row (cons (caddr e) (cdr row)))))))))
    out))
;; (action . literal): goal-optimizations narrowing step t (G13)
(define-function john-sat-allowed (o g t using)
  (and (not using)
       (let ((env (list (cons 'it (sat-const o)))) (conds ()))
	 (list-do p *john-gopts*
	   (and (= g (cadr p)) (john-isa? (john-object-class o) (car p))
		(push conds (cons (sat-truth (sat-eval (cadddr p) t env)) (caddr p)))))
	 (and conds
	      (let ((none (sat-and (map (lambda (cd) (- (car cd))) conds))) (out ()))
		(list-do a *john-actions*
		  (or (assq (cadr a) out)
		      (push out
			    (cons (cadr a)
				  (sat-or (cons none
						(let ((ls ()))
						  (list-do cd conds
						    (and
						      (member? (cadr a) (cdr cd))
						      (push ls (car cd))))
						  ls)))))))
		out)))))
(define-function sat-require (x l) (or (= l *sat-t*) (cnf-clause *sat-c* (list (- x) l))))

;; x, its one name said outright: implied, and it lets the solver propagate
(define-function sat-one-hot (x)
  (or (not (= 'names (car x)))
      (let ((ls (map cdr (cdr x))))
	(cnf-clause *sat-c* ls)
	(while ls
	  (list-do l (cdr ls) (cnf-clause *sat-c* (list (- (car ls)) (- l))))
	  (set ls (cdr ls)))))
  x)
;; a cell at t + 1: the value of the write taken, else its value at t.  Writes of different
;; actions exclude each other (one action a step); of one action the later wins, as john-write's.
;; writes: ((object prop literal value variable) ...), in order
(define-function sat-next (o p cur writes)
  (let ((mine ()))
    (list-do w writes (and (= o (car w)) (= p (cadr w)) (push mine w)))	; newest first
    (if (not mine)
	cur
	;; (literal . value), each write's literal unless a later one of its action wins
	(let ((taken ()) (later ()))
	  (list-do w mine
	    (let ((over ()))
	      (list-do l later (and (= (car l) (car (cddddr w))) (push over (- (cdr l)))))
	      (push taken (cons (sat-and (cons (caddr w) over)) (cadddr w)))
	      (push later (cons (car (cddddr w)) (caddr w)))))
	  (let ((kept (sat-and (map (lambda (c) (- (car c))) taken))))
	    (sat-merge (cons (cons kept cur) taken)))))))
;; one formula grows a step at a time; each length adds its goal, solves, and takes it back
(define-structure <john-sat> (o g args using cnf goal instances acts))
(define-function john-sat-begin (o g args using by)
  (let ((enc (new <john-sat>)) (c (cnf-new)))
    (set (<john-sat>-o enc) o)
    (set (<john-sat>-g enc) g)
    (set (<john-sat>-args enc) args)
    (set (<john-sat>-using enc) using)
    (set (<john-sat>-cnf enc) c)
    (set (<john-sat>-goal enc) (john-goal-of o g))
    (set (<john-sat>-instances enc) (john-sat-instances using by))
    (set *sat-c* c)
    (set *sat-t* (cnf-true c))
    (set *sat-reach* *sat-t*)
    (set *sat-errs* ())
    (set *sat-depth* 0)
    (set *sat-states* (array (+ *john-limit* 1)))
    (set *sat-memo* (array (+ *john-limit* 1)))
    (set *sat-groups* (array))
    (set *sat-memo-on* 1)
    (set-array-at *sat-states*
		  0
		  (map (lambda (row)
			 (cons (car row)
			       (map (lambda (p)
				      (cons p (sat-const (john-lookup *john-world* (car row) p))))
				    (cdr row))))
		       (john-sat-mutable)))
    enc))
;; step t: one action, its rules and optimizations, state t + 1
(define-function john-sat-step (enc t)
  (let ((c (<john-sat>-cnf enc)) (xs ()) (writes ()) (allowed ()))
    (set *sat-errs* ())
    (set allowed (john-sat-allowed (<john-sat>-o enc) (<john-sat>-g enc) t (<john-sat>-using enc)))
    (list-do l *sat-errs* (cnf-assert c (- l)))	; a goal-optimization that stops the evaluator
    (list-do inst (<john-sat>-instances enc)
      (let* ((actor (car inst)) (a (cadr inst)) (vals (caddr inst)) (x (cnf-var c))
	     (env (sat-bind (map cadr (caddr a)) vals (list (cons 'it (sat-const actor)))))
	     (al (cdr (assq (cadr a) allowed))))
	(push xs x)
	(set (<john-sat>-acts enc)
	     (cons (cons x (cons t (cons actor (cons (cadr a) vals)))) (<john-sat>-acts enc)))
	(set *sat-errs* ())
	(and al (sat-require x al))
	(list-do r *john-rules*
	  (and (= (car r) (car a))
	       (= (cadr r) (cadr a))
	       (sat-require x (sat-truth (sat-eval (caddr r) t env)))))
	(list-do p *john-aopts*
	  (and (= (cadr p) (cadr a)) (john-isa? (john-object-class actor) (car p))
	       (sat-require x (sat-truth (sat-eval (cadddr p) t env)))))
	(list-do e (cadddr a)	; (set X p v guard?): X, v and the guard read time t
	  (let ((gd (if (cddddr e) (sat-truth (sat-eval (car (cddddr e)) t env)) *sat-t*)))
	    (sat-under gd
		       (lambda ()
			 (let ((target (sat-eval (cadr e) t env)) (v (sat-eval (cadddr e) t env)))
			   (list-do tc (sat-cases target)
			     (and (symbol? (cdr tc))
				  (assq (caddr e) (cdr (assq (cdr tc) (array-at *sat-states* t))))
				  (push writes
					(list (cdr tc)
					      (caddr e)
					      (sat-and (list x gd (car tc)))
					      v
					      x)))))))))
	(list-do l *sat-errs* (sat-require x (- l)))))
    (if xs (cnf-exactly-one c xs) (cnf-assert c (- *sat-t*)))
    (set writes (list-reverse! writes))
    (set-array-at *sat-states*
		  (+ t 1)
		  (map (lambda (row)
			 (cons (car row)
			       (map (lambda (pv)
				      (cons (car pv)
					    (sat-one-hot
					      (sat-next (car row) (car pv) (cdr pv) writes))))
				    (cdr row))))
		       (array-at *sat-states* t)))))
(define-function john-sat-goal (enc k)	; the goal at time k, asserted
  (let ((c (<john-sat>-cnf enc)) (goal (<john-sat>-goal enc)))
    (set *sat-errs* ())
    (set *sat-memo-on* ())
    (cnf-assert c
		(sat-truth (sat-eval (cadddr goal)
				     k
				     (sat-bind (caddr goal)
					       (<john-sat>-args enc)
					       (list (cons 'it (sat-const (<john-sat>-o enc))))))))
    (list-do l *sat-errs* (cnf-assert c (- l)))
    (set *sat-memo-on* 1)))
;; (cnf . ((variable time actor action args...) ...))
(define-function john-sat-encode (o g args k using by)
  (let ((enc (john-sat-begin o g args using by)))
    (for (t 0 k) (john-sat-step enc t))
    (john-sat-goal enc k)
    (cons (<john-sat>-cnf enc) (<john-sat>-acts enc))))

(define-function john-sat-plan (acts model)	; ((time actor action args...) ...), in time order
  (let ((out ()))
    (list-do a acts (and (array-at model (car a)) (push out (cdr a))))
    out))	; acts are newest first
(define-function john-sat-replay (plan o g args using)	; the world the evaluator reaches by plan
  (let ((w *john-world*) (goal (john-goal-of o g)))
    (list-do st plan
      (let ((d ()) (actor (cadr st)) (vals (cdddr st)) (u (john-using w o g using)))
	(list-do x *john-actions*
	  (and (= (caddr st) (cadr x)) (john-isa? (john-object-class actor) (car x)) (set d x)))
	(let ((child (and d
			  (or (not u) (member? (caddr st) u))
			  (john-allowed? w actor d vals)
			  (john-step w actor d vals))))
	  (or child
	      (error "E_ENCODING: step "
		     (car st)
		     " ("
		     (john-step-text (cdr st))
		     ") not possible in the evaluator"))
	  (set w child))))
    (or (john-true? (john-eval (cadddr goal) w (john-bind (caddr goal) args (list (cons 'it o)))))
	(error "E_ENCODING: goal not reached"))
    w))

;; one line per length tried, then the search's report, or the bounds no plan was found within
(define-function john-sat-answer (r)
  (cond ((= 'sat (car r)) "satisfiable")
	((= 'unsat (car r)) "unsatisfiable")
	(else "unknown")))
(define-function john-sat-satisfy (o g args using by)
  (john-sat-check)
  (set *sat-conflicts* (cdr (assq 'sat-conflicts *john-options*)))
  (let ((k 0)
	(done ())
	(enc (john-sat-begin o g args using by)))
    (while (and (not done) (<= k *john-limit*))
      (and (< 0 k) (john-sat-step enc (- k 1)))
      (let* ((c (<john-sat>-cnf enc))
	     (mark (cnf-mark c))
	     (_ (john-sat-goal enc k))
	     (n-vars (cnf-nvars c))
	     (n-clauses (cnf-count c))
	     (r (sat-decide-store n-vars (<cnf>-store c))))
	(cnf-restore c mark)	; the goal at k only
	(john-say (concat-strings "trying "
				  (format "%d" k)
				  " steps ("
				  (format "%d" n-vars)
				  " variables, "
				  (format "%d" n-clauses)
				  " clauses): "
				  (john-sat-answer r)))
	(cond ((= 'sat (car r))
	       (set done 1)
	       (let ((plan (john-sat-plan (<john-sat>-acts enc) (cdr r))))
		 (john-satisfied (john-sat-replay plan o g args using))))
	      ((= 'unknown (car r))
	       (set done 1)
	       (john-say (concat-strings "unknown at " (format "%d" k) " steps (conflict limit "
					 (format "%d" *sat-conflicts*) ")")))
	      (else (set k (+ k 1))))))
    (set *sat-memo-on* ())	; the memo and groups name this formula's literals only
    (cnf-free (<john-sat>-cnf enc))
    (or done
	(john-say (concat-strings "unsatisfiable within " (format "%d" *john-limit*) " steps"
				  " (width " (format "%d" (john-sat-width))
				  ", lists " (format "%d" (john-sat-option 'sat-list-length 16))
				  ", unroll " (format "%d" (john-sat-unroll)) ")")))))

(define-function john-run-sorts (forms)
  (john-reset)
  (list-do s forms (or (= 'satisfy (car s)) (john-statement s)))
  (john-sat-check))
