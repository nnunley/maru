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

(define-function john-sat-satisfy (o g args)
  (john-sat-check)
  (john-fail "planner sat: the encoding is not built yet"))

(define-function john-run-sorts (forms)
  (john-reset)
  (list-do s forms (or (= 'satisfy (car s)) (john-statement s)))
  (john-sat-check))
