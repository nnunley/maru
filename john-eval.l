;;; john-eval.l -- runs JOHN programs (john.l's forms) by searching possible worlds.
;;;
;;;   (john-run forms)        runs a program's statements in order; the lines it prints
;;;   (john-run-file path)    the same, for a file
;;;
;;; An object is its name, a symbol; a class is its instances wherever a collection is
;;; expected.  A world holds the property values set in it and finds the rest in its
;;; parent; an action makes a child world one time step on, with every effect evaluated
;;; in the parent (the memos' Time1 / Time2).  satisfy searches the worlds level by level
;;; (iterative deepening, M-2009-001's brute-force planner); an action-optimization
;;; narrows an action's arguments and a goal-optimization the actions a world tries.
;;; Heuristics score a world; with max-time-ahead H the search commits, every H levels,
;;; to the next move toward the best-scoring world (RN-2008-003 §10), and in a
;;; two-player-game the opponent makes only its best-scoring replies (§12).  Ours, not the
;;; memos': with merge-worlds a world whose state was reached before is dropped (G12).  A name nothing defines is an error, never a quiet no.

(require "john.l")

(define-structure <john-world> (time parent action writes))	; writes: ((obj prop . value) ...)

(define *john-classes* ())	; (class props . groups-it-belongs-to)
(define *john-objects* ())	; (name . class), newest first
(define *john-quals* ())	; (class selector params body), in source order
(define *john-rels* ())		; (name (type a) (type b) body)
(define *john-actions* ())	; (class name params effects)
(define *john-rules* ())	; (class action expr)
(define *john-goals* ())	; (class name params expr)
(define *john-aopts* ())	; (class action dynamically? expr): an action's arguments must satisfy expr
(define *john-gopts* ())	; (class goal actions expr): in a world where expr holds, the goal tries actions
(define *john-heuristics* ())	; (class goal weight maximize|minimize expr)
(define *john-options* ())	; (name . value), from set-opt
(define *john-world* ())	; the current world
(define *john-out* ())		; lines printed, newest first
(define *john-limit* 16)	; satisfy gives up after this many time steps

(define-function john-fail args (apply error (cons "john: " args)))
(define-function john-say (s) (push *john-out* s))

;;; ---- classes and objects

(define-function john-class (c) (assq c *john-classes*))
(define-function john-object-class (o) (cdr (assq o *john-objects*)))
(define-function john-object? (o) (and (symbol? o) (assq o *john-objects*)))
(define-function john-isa? (c target)	; c is target, or one of target's groups holds c
  (or (= c target) (let ((r ())) (list-do g (cddr (john-class c)) (and (john-isa? g target) (set r 1))) r)))
(define-function john-instances (c)	; in the order they were made
  (let ((out ())) (list-do o *john-objects* (and (john-isa? (cdr o) c) (push out (car o)))) (list-reverse! out)))
(define-function john-props (c)	; a class's properties, its groups' after its own
  (let ((cl (john-class c)) (ps ()))
    (and cl (set ps (cadr cl)) (list-do g (cddr cl) (set ps (concat-list ps (john-props g)))))
    ps))

;;; ---- worlds

(define-function john-lookup (w o p)
  (let ((v ()) (found ()))
    (while (and w (not found))
      (list-do e (<john-world>-writes w) (and (not found) (= (car e) o) (= (cadr e) p) (let () (set v (cddr e)) (set found 1))))
      (set w (<john-world>-parent w)))
    (or found (john-fail "no value for " o " " p))
    v))
(define-function john-write (w o p v) (set (<john-world>-writes w) (cons (cons o (cons p v)) (<john-world>-writes w))))

;;; ---- values

(define-function john-true? (v) (and v (not (= v 'no))))
(define-function john-bool (c) (if c 'yes 'no))
(define-function john-list? (v) (or (not v) (pair? v)))
(define-function john-collection (v)	; a class is its instances
  (cond ((and (pair? v) (= 'class (car v))) (john-instances (cdr v)))
	((john-list? v) v)
	(else (john-fail "not a collection: " v))))
(define-function john-text (v)
  (cond ((symbol? v) (symbol->string v))
	((long? v) (format "%d" v))
	((string? v) v)
	((and (pair? v) (= 'class (car v))) (symbol->string (cdr v)))
	((john-list? v) (let ((s "[ ") (first 1))
			  (list-do x v (set s (concat-strings s (if first "" ", ") (john-text x))) (set first ()))
			  (concat-string s " ]")))
	(else "?")))

;;; ---- expressions, in world w with env ((name . value) ...)

(define john-eval)
(define-function john-name (x w env)
  (let ((b (assq x env)))
    (cond (b (cdr b))
	  ((member? x '(yes no empty)) x)
	  ((john-object? x) x)
	  ((john-class x) (cons 'class x))
	  (else (john-fail "unknown name: " x)))))
(define-function john-quals (c sel)	; clauses for sel on c, then on c's groups
  (let ((out ()))
    (list-do q *john-quals* (and (= sel (cadr q)) (= c (car q)) (push out q)))
    (set out (list-reverse! out))
    (or out (let () (list-do g (cddr (john-class c)) (or out (set out (john-quals g sel)))) out))))
(define-function john-bind (names vals env)
  (while names (set env (cons (cons (car names) (car vals)) env)) (set names (cdr names)) (set vals (cdr vals)))
  env)
(define-function john-qualify (r clauses args w)	; first clause whose guard holds
  (let ((v ()) (done ()))
    (list-do q clauses
      (or done
	  (let* ((env (john-bind (caddr q) args (list (cons 'it r)))) (b (cadddr q)))
	    (if (= 'if (car b))
		(and (john-true? (john-eval (cadr b) w env)) (let () (set v 'yes) (set done 1)))
	      (and (or (not (cddr b)) (john-true? (john-eval (caddr b) w env)))
		   (let () (set v (john-eval (cadr b) w env)) (set done 1)))))))
    (if done v (if (= 'if (car (cadddr (car clauses)))) 'no (john-fail "no clause of " (cadr (car clauses)) " applies to " r)))))
;; lists count from 1: at: n is the nth element, to: n the first n, from: n the nth onward
(define-function john-drop (l n) (while (and l (< 0 n)) (set l (cdr l)) (set n (- n 1))) l)
(define-function john-take (l n) (let ((out ())) (while (and l (< 0 n)) (push out (car l)) (set l (cdr l)) (set n (- n 1))) (list-reverse! out)))
(define-function john-builtin (r sel args)
  (cond ((and (string? r) (= sel 'name)) (string->symbol r))
	((and (john-list? r) (= sel 'at:)) (let ((l (john-drop r (- (car args) 1)))) (or l (john-fail "at: " (car args) " past the end of " (john-text r))) (car l)))
	((and (john-list? r) (= sel 'to:)) (john-take r (car args)))
	((and (john-list? r) (= sel 'from:)) (john-drop r (- (car args) 1)))
	((and (pair? r) (= sel 'last)) (car (john-drop r (- (list-length r) 1))))
	((and (john-list? r) (= sel 'size)) (list-length r))
	((and (pair? r) (= sel 'first)) (car r))
	((and (pair? r) (= sel 'second)) (cadr r))
	((and (pair? r) (= sel 'third)) (caddr r))
	((and (john-list? r) (= sel 'rest)) (cdr r))
	(else (john-fail "no property or qualification " sel " of " r))))
;; a value that is not an object has a class for qualifications: List, Number, String, Word
(define-function john-class-of (v)
  (cond ((john-object? v) (john-object-class v)) ((john-list? v) 'List) ((long? v) 'Number) ((string? v) 'String) (else 'Word)))
(define-function john-send (r sel args w)
  (let ((c (john-class-of r)))
    (cond ((and (john-object? r) (not args) (member? sel (john-props c))) (john-lookup w r sel))
	  ((john-quals c sel) (john-qualify r (john-quals c sel) args w))
	  (else (john-builtin r sel args)))))
(define-function john-holds (r a b w env)
  (if (= r 'in) (john-bool (member? a (john-collection b)))
    (let ((d (assq r *john-rels*)))
      (or d (john-fail "no relation " r))
      (john-bool (john-true? (john-eval (cadddr d) w (list (cons (cadr (cadr d)) a) (cons (cadr (caddr d)) b))))))))
(define-function john-quantify (all? l p w env)
  (let ((r all?))
    (list-do x (john-collection (john-eval l w env))
      (let ((h (john-true? (john-eval p w (cons (cons 'each x) env)))))
	(if all? (or h (set r ())) (and h (set r 1)))))
    (john-bool r)))
(define-function john-arith (o a b)
  (cond ((and (long? a) (long? b)) (cond ((= o '+) (+ a b)) ((= o '-) (- a b)) ((= o '*) (* a b)) (else (/ a b))))
	((and (= o '+) (john-list? a)) (concat-list a (if (john-list? b) b (list b))))
	((and (= o '-) (john-list? a)) (let ((out ()) (bs (if (john-list? b) b (list b))))
					 (list-do x a (or (member? x bs) (push out x))) (list-reverse! out)))
	(else (john-fail "can't " o " " a " and " b))))
(define-function john-eval (x w env)
  (cond ((symbol? x) (john-name x w env))
	((not (pair? x)) x)
	(else (let ((op (car x)))
		(cond ((= op 'send) (john-send (john-eval (cadr x) w env) (caddr x) (map (lambda (a) (john-eval a w env)) (cdddr x)) w))
		      ((= op 'list) (map (lambda (a) (john-eval a w env)) (cdr x)))
		      ((= op '=) (john-bool (equal (john-eval (cadr x) w env) (john-eval (caddr x) w env))))
		      ((member? op '(< > <= >=))
		       (let ((a (john-eval (cadr x) w env)) (b (john-eval (caddr x) w env)))
			 (john-bool (cond ((= op '<) (< a b)) ((= op '>) (> a b)) ((= op '<=) (<= a b)) (else (>= a b))))))
		      ((member? op '(+ - * /)) (john-arith op (john-eval (cadr x) w env) (john-eval (caddr x) w env)))
		      ((= op 'and) (john-bool (and (john-true? (john-eval (cadr x) w env)) (john-true? (john-eval (caddr x) w env)))))
		      ((= op 'or) (john-bool (or (john-true? (john-eval (cadr x) w env)) (john-true? (john-eval (caddr x) w env)))))
		      ((= op 'not) (john-bool (not (john-true? (john-eval (cadr x) w env)))))
		      ((= op 'rel) (john-holds (cadr x) (john-eval (caddr x) w env) (john-eval (cadddr x) w env) w env))
		      ((= op 'every) (john-quantify 1 (cadr x) (caddr x) w env))
		      ((= op 'any) (john-quantify () (cadr x) (caddr x) w env))
		      ((= op 'all) (if (cddr x) (john-fail "all with property values is not read yet") (john-instances (cadr x))))
		      ((= op 'select) (let ((out ()))
					(list-do o (john-instances (cadr x))
					  (and (john-true? (john-eval (caddr x) w (cons (cons 'which o) env))) (push out o)))
					(list-reverse! out)))
		      (else (john-fail "can't evaluate " x)))))))

;;; ---- actions and search

(define-function john-combos (types)	; every tuple of instances, one per parameter type
  (if (not types) (list ())
    (let ((out ()) (rest (john-combos (cdr types))))
      (list-do o (john-instances (car types)) (list-do r rest (push out (cons o r))))
      (list-reverse! out))))
(define-function john-step (w actor a args)	; the child world, or () when a rule fails
  (let* ((env (john-bind (map cadr (caddr a)) args (list (cons 'it actor)))) (ok 1))
    (list-do r *john-rules* (and ok (= (car r) (car a)) (= (cadr r) (cadr a)) (or (john-true? (john-eval (caddr r) w env)) (set ok ()))))
    (and ok
	 (let ((child (new <john-world>)) (sets ()))
	   (list-do e (cadddr a)	; (set X p v guard?): X, v and the guard all read w
	     (and (or (not (cddddr e)) (john-true? (john-eval (car (cddddr e)) w env)))
		  (push sets (list (john-eval (cadr e) w env) (caddr e) (john-eval (cadddr e) w env)))))
	   (set (<john-world>-time child) (+ 1 (<john-world>-time w)))
	   (set (<john-world>-parent child) w)
	   (set (<john-world>-action child) (cons actor (cons (cadr a) args)))
	   (list-do s (list-reverse! sets) (john-write child (car s) (cadr s) (caddr s)))
	   child))))
(define-function john-allowed? (w actor a args)	; every action-optimization of a holds
  (let ((env (john-bind (map cadr (caddr a)) args (list (cons 'it actor)))) (ok 1))
    (list-do o *john-aopts* (and ok (= (cadr o) (cadr a)) (john-isa? (john-object-class actor) (car o))
				 (or (john-true? (john-eval (cadddr o) w env)) (set ok ()))))
    ok))
(define-function john-children (w actors using)
  (let ((out ()))
    (list-do a *john-actions*
      (and (or (not using) (member? (cadr a) using))
	   (list-do actor (if actors actors (john-instances (car a)))
	     (and (john-isa? (john-object-class actor) (car a))
		  (list-do args (john-combos (map car (caddr a)))
		    (and (john-allowed? w actor a args)
			 (let ((c (john-step w actor a args))) (and c (push out c)))))))))
    (list-reverse! out)))
(define-function john-using (w o g using)	; the actions o's goal-optimizations choose in w; all when none holds (G13)
  (if using using
    (let ((out ()) (env (list (cons 'it o))))
      (list-do p *john-gopts* (and (= g (cadr p)) (john-isa? (john-object-class o) (car p)) (john-true? (john-eval (cadddr p) w env))
				   (list-do a (caddr p) (or (member? a out) (set out (concat-list out (list a)))))))
      out)))
;; a world's score for o's goal g: each heuristic's weight times its value, negated to minimize
(define-function john-score (w o g)
  (let ((n 0) (env (list (cons 'it o))))
    (list-do h *john-heuristics*
      (and (= g (cadr h)) (john-isa? (john-object-class o) (car h))
	   (let ((v (john-eval (car (cddddr h)) w env)))
	     (set v (cond ((long? v) v) ((= v 'yes) 1) ((= v 'no) 0) (else (john-fail "a heuristic's value is a number: " (john-text v)))))
	     (set n (+ n (* (if (= 'maximize (cadddr h)) 1 -1) (* (caddr h) v)))))))
    n))
(define-function john-best (ws o g)	; the worlds of ws with the highest score, in order
  (let ((top ()) (out ()))
    (list-do w ws (let ((v (john-score w o g))) (and (or (not top) (> v top)) (set top v))))
    (list-do w ws (and (= top (john-score w o g)) (push out w)))
    (list-reverse! out)))
(define-function john-opponent (o)	; o's opponent in a two-player-game, or ()
  (let ((ps (cdr (assq 'two-player-game *john-options*))))
    (and ps (member? o ps) (if (= o (car ps)) (cadr ps) (car ps)))))
(define-function john-expand (w o g using by)	; w's children; the opponent's replies only its best
  (let ((kids (john-children w (and by (list by)) (john-using w o g using))) (opp (john-opponent o)))
    (if (not opp) kids
      (let ((mine ()) (theirs ()))
	(list-do c kids (if (= opp (car (<john-world>-action c))) (push theirs c) (push mine c)))
	(concat-list (list-reverse! mine) (john-best (list-reverse! theirs) opp g))))))
(define-function john-at-time (w t) (while (> (<john-world>-time w) t) (set w (<john-world>-parent w))) w)

;; a world's state: every property of every object, as text; seen states kept in buckets by hash
(define-function john-state (w)
  (let ((s ""))
    (list-do o *john-objects* (list-do p (john-props (cdr o)) (set s (concat-strings s (john-text (john-lookup w (car o) p)) " "))))
    s))
(define-function john-hash (s) (let ((h 7)) (for (i 0 (string-length s)) (set h (% (+ (* h 31) (string-at s i)) 4093))) h))
(define-function john-new-state? (seen w)	; and records it
  (let* ((k (john-state w)) (h (john-hash k)) (b (array-at seen h)))
    (and (not (member? k b)) (let () (set-array-at seen h (cons k b)) 1))))
(define-function john-step-text (st)	; (actor action args...) as A move Peg2
  (let ((s (concat-strings (john-text (car st)) " " (john-text (cadr st))))) (list-do v (cddr st) (set s (concat-strings s " " (john-text v)))) s))
(define-function john-path (w)
  (let ((out ())) (while (<john-world>-action w) (push out (<john-world>-action w)) (set w (<john-world>-parent w))) out))
(define-function john-satisfy (o g args using by)
  (let* ((c (john-object-class o)) (goal ()) (frontier (list *john-world*)) (found ()) (k 0)
	 (ahead (cdr (assq 'max-time-ahead *john-options*))) (horizon ahead) (committed *john-world*)
	 (merge (john-true? (cdr (assq 'merge-worlds *john-options*)))) (seen (and merge (array 4093))))
    (and merge (john-new-state? seen *john-world*))
    (list-do d *john-goals* (and (= g (cadr d)) (john-isa? c (car d)) (set goal d)))
    (or goal (john-fail "no goal " g " for " o))
    (let ((env (john-bind (caddr goal) args (list (cons 'it o)))))
      (while (and frontier (not found) (<= k *john-limit*))
	(list-do w frontier (and (not found) (john-true? (john-eval (cadddr goal) w env)) (set found w)))
	(or found
	    (let ((next ()))
	      (and horizon (= k horizon) frontier	; past the flashlight: commit one move toward the best world
		   (let* ((best (car (john-best frontier o g)))
			  (step (john-at-time best (+ 1 (<john-world>-time committed)))))
		     (set committed step)
		     (set frontier (let ((keep ())) (list-do w frontier (and (= step (john-at-time w (<john-world>-time step))) (push keep w)))
				     (list-reverse! keep)))
		     (set horizon (+ horizon ahead))
		     (and merge (let () (set seen (array 4093)) (list-do w frontier (john-new-state? seen w))))
		     (john-say (concat-strings "certain: " (john-step-text (<john-world>-action step))))))
	      (list-do w frontier (list-do c (john-expand w o g using by) (and (or (not merge) (john-new-state? seen c)) (push next c))))
	      (set next (list-reverse! next))	; concat-list recurses per element and overflows on a wide level
	      (set k (+ k 1))
	      (set frontier next)
	      (and next (john-say (concat-strings "looking " (format "%d" k) " time unit ahead (" (format "%d" (list-length next)) " possible worlds)")))))))
    (if (not found) (john-say (if frontier "not satisfied within the time limit" "unsatisfiable"))
      (set *john-world* found)
      (john-say (concat-string "satisfied at time: " (format "%d" (<john-world>-time found))))
      (let ((s "satisfied by: [ ") (first 1))
	(list-do st (john-path found) (set s (concat-strings s (if first "" " , ") (john-step-text st))) (set first ()))
	(john-say (concat-string s " ]"))))))

;;; ---- statements

(define-function john-make (c o vals env)	; a name given to make is an object, made or not yet
  (let ((cl (john-class c)))
    (or cl (john-fail "make: no class " c))
    (set o (if (symbol? o) o (john-eval o *john-world* env)))
    (set *john-objects* (concat-list *john-objects* (list (cons o c))))
    (let ((ps (cadr cl)))
      (or (= (list-length ps) (list-length vals)) (john-fail "make " o ": " (list-length ps) " properties, " (list-length vals) " values"))
      (list-do v vals (john-write *john-world* o (car ps) (if (symbol? v) v (john-eval v *john-world* env))) (set ps (cdr ps))))))
(define-function john-statement (s)
  (let ((op (car s)))
    (cond ((= op 'start-world) (set *john-world* (new <john-world>)) (set (<john-world>-time *john-world*) 0))
	  ((= op 'end-world))
	  ((= op 'group) (or (john-class (cadr s)) (push *john-classes* (list (cadr s) ())))
	   (list-do m (cddr s) (let ((cl (or (john-class m) (let () (push *john-classes* (list m ())) (john-class m)))))
				 (set-cdr (cdr cl) (cons (cadr s) (cddr cl))))))
	  ((= op 'create) (let ((ps (if (= 'typed (caddr s)) (map caddr (cdddr s)) (cddr s))) (cl (john-class (cadr s))))
			    (if cl (set-car (cdr cl) ps) (push *john-classes* (list (cadr s) ps)))))
	  ((= op 'make) (john-make (cadr s) (caddr s) (cdddr s) ()))
	  ((= op 'for) (list-do x (john-collection (john-eval (cadr s) *john-world* ()))
			 (let ((b (caddr s)) (env (list (cons 'each x))))
			   (if (= 'make (car b)) (john-make (cadr b) (caddr b) (cdddr b) env)
			     (john-say (john-text (john-eval b *john-world* env)))))))
	  ((= op 'qualify) (set *john-quals* (concat-list *john-quals* (list (cdr s)))))
	  ((= op 'rel-qualify) (or (cadr s) (push *john-rels* (list (cadddr s) (caddr s) (car (cddddr s)) (cadr (cddddr s))))))
	  ((= op 'action) (set *john-actions* (concat-list *john-actions* (list (list (cadr s) (caddr s) (cadddr s) (cddddr s))))))
	  ((= op 'rule) (set *john-rules* (concat-list *john-rules* (list (cdr s)))))
	  ((= op 'goal) (push *john-goals* (cdr s)))
	  ((= op 'heuristic) (set *john-heuristics* (concat-list *john-heuristics* (list (cdr s)))))
	  ((= op 'set-opt) (push *john-options* (cons (cadr s) (john-eval (caddr s) *john-world* ()))))
	  ((= op 'action-optimization) (set *john-aopts* (concat-list *john-aopts* (list (cdr s)))))
	  ((= op 'goal-optimization) (set *john-gopts* (concat-list *john-gopts* (list (cdr s)))))
	  ((= op 'satisfy) (john-satisfy (cadr s) (caddr s) (map (lambda (a) (john-eval a *john-world* ())) (cadddr s))
					 (car (cddddr s)) (cadr (cddddr s))))
	  ((= op 'query) (john-say (john-text (john-eval (cadr s) *john-world* ()))))
	  (else (john-fail "statement not read yet: " op)))))
(define-function john-run (forms)
  (set *john-classes* ()) (set *john-objects* ()) (set *john-quals* ()) (set *john-rels* ()) (set *john-actions* ())
  (set *john-rules* ()) (set *john-goals* ()) (set *john-aopts* ()) (set *john-gopts* ()) (set *john-heuristics* ()) (set *john-options* ()) (set *john-out* ()) (set *john-world* (new <john-world>))
  (set (<john-world>-time *john-world*) 0)
  (list-do s forms (john-statement s))
  (list-reverse! *john-out*))
(define-function john-run-file (path) (john-run (john-read path)))
