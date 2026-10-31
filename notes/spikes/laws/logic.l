;;; SPIKE (throwaway): a small logic engine.  The same rules generate (random
;;; clause order, bounded size), check (a given term, clauses in order) and
;;; enumerate (every solution up to the size).

;; seeded, replayable
(define *seed* 42)
(define-function rand (n) (set *seed* (% (+ (* *seed* 75) 74) 65537)) (% *seed* n))
(define-function shuffle (l)
  (let ((a (list->array l)) (n (list-length l)))
    (while (> n 1)
      (let* ((j (rand n)) (t (array-at a j)))
	(set (array-at a j) (array-at a (- n 1)))
	(set (array-at a (- n 1)) t))
      (set n (- n 1)))
    (array->list a)))
(define *random* ())
(define-function choices (l) (if *random* (shuffle l) l))

;; logic variables: $x in rules, fresh <lv>s when a clause is used
(define-structure <lv> (id))
(define *lv* 0)
(define-function lv? (x) (= <lv> (type-of x)))
(define-function var-symbol? (x) (and (symbol? x) (= ?$ (string-at (symbol->string x) 0))))

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
      ((and (string? a) (string? b) (= a b)) s)
      (else				()))))
(define *empty* '((none . none)))	; a substitution that is never ()

(define-function rename (x env)	; env: cell holding an alist symbol -> lv
  (cond
    ((var-symbol? x)	(let ((b (assq x (car env))))
			  (if b (cdr b)
			    (let ((v (new <lv> (set *lv* (+ *lv* 1)))))
			      (set-car env (cons (cons x v) (car env)))
			      v))))
    ((pair? x)		(cons (rename (car x) env) (rename (cdr x) env)))
    (else		x)))

;; rules: (name (pred arg...) premise...); a rule is recursive when a premise
;; names its own predicate, and only non-recursive rules run at size 0
(define *rules* ())
(define-form rule (name head . body) `(set *rules* (concat-list *rules* (list '(,name ,head ,@body)))))
(define-function rule-recursive? (r) (let ((p (car (cadr r))) (y ())) (list-do g (cddr r) (and (pair? g) (= p (car g)) (set y 1))) y))
(define *fired* ())	; rule names used in successful derivations

(define solve)
(define-function solve-all (goals s size k)
  (if goals
      (solve (car goals) s size (lambda (s) (solve-all (cdr goals) s size k)))
    (k s)))

;; builtins: (member x list), (numeral x)
(define *numerals* '("0" "1" "2" "0.5" "10"))
(define-function numeral? (x) (and (string? x) (member? x *numerals*)))
(define-function solve-member (goal s k)
  (let ((x (cadr goal)) (r ()))
    (list-do e (choices (walk* (caddr goal) s))
      (or r (let ((s2 (unify x e s))) (and s2 (set r (k s2))))))
    r))
(define-function solve-numeral (goal s k)
  (let ((x (walk (cadr goal) s)))
    (if (lv? x)
	(let ((r ())) (list-do n (choices *numerals*) (or r (set r (k (unify x n s))))) r)
      (and (numeral? x) (k s)))))
(define-function solve-rules (goal s size k)
  (let ((p (car goal)) (r ()))
    (list-do rl (choices *rules*)
      (and (not r) (= p (car (cadr rl)))
	   (or (> size 0) (not (rule-recursive? rl)))
	   (let* ((env (list ())) (head (rename (cadr rl) env)) (body (rename (cddr rl) env))
		  (s2 (unify (cdr head) (cdr goal) s)))
	     (and s2 (set r (solve-all body s2 (- size 1)
				       (lambda (s3) (let ((v (k s3))) (and v (not (member? (car rl) *fired*)) (push *fired* (car rl))) v))))))))
    r))
(define-function solve (goal s size k)
  (let ((p (car goal)))
    (if (= p 'member) (solve-member goal s k)
      (if (= p 'numeral) (solve-numeral goal s k)
	(solve-rules goal s size k)))))

(define-function last-of (l) (if (cdr l) (last-of (cdr l)) (car l)))
;; generate: one random solution's binding for the goal's last argument
(define-function generate (goal size)
  (set *random* 1)
  (let* ((env (list ())) (g (rename goal env)) (out (rename (last-of goal) env)))
    (solve g *empty* size (lambda (s) (walk* out s)))))
;; check: does the goal, fully given, hold within size?
(define-function holds? (goal size)
  (set *random* ())
  (solve (rename goal (list ())) *empty* size (lambda (s) 1)))
;; enumerate: every distinct solution for the goal's last argument
(define-function enumerate (goal size)
  (set *random* ())
  (let* ((env (list ())) (g (rename goal env)) (out (rename (last-of goal) env)) (all ()))
    (solve g *empty* size (lambda (s) (let ((v (walk* out s))) (or (member? v all) (push all v))) ()))
    all))
