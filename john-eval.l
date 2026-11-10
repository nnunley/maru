;;; john-eval.l -- runs JOHN programs (john.l's forms) as a session, searching possible worlds.
;;;
;;;   (john-begin)            starts a session: an empty knowledge base, and the current world at time 0
;;;   (john-enter form)       enters one statement; the lines it answers
;;;   (john-run forms)        a session fed a program's statements; every line they answer
;;;   (john-run-file path)    the same, for a file
;;;
;;; A session is RN-2008-003's model (§15): a knowledge base (classes, qualifications, actions, rules, goals, options ...,
;;; the *john-...* lists below) and a working memory (the current world and its parents).  Declarations add to the first,
;;; and a make's facts to the current world; only a step (do, or a satisfied goal) moves time.  With *john-echo* on, as at
;;; john-repl.l's prompt, a declaration answers ok., a step its mutations, and a failed statement its error, undone.
;;; doc/rfc/draft-ndn-maru-john-session-00.md.
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
;;; memos': with merge-worlds a world whose state was reached before is dropped (G12).
;;; Time is the chain of worlds.  at time t E reads E in the world at time t: at the REPL
;;; a later t gives the values over the possible worlds that far ahead (RN-2008-003 §4);
;;; ours, after McCarthy's Elephant, an expression may read earlier times, quantify over
;;; them (for some time T up to B), and ask which action made a world (X did act).  A name nothing defines is an error, never a quiet no.

(require "john.l")
(require "hash.l")

(define-structure <john-world> (time parent action writes cache))	; writes: ((obj prop . value) ...)

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
(define *john-echo* ())		; at the prompt: ok., each step's mutations, and errors answered rather than ending the run
(define *john-limit* 16)	; satisfy gives up after this many time steps: set-opt time-limit N (ours), 16 unless set

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
(define-function john-write (w o p v)
  (set (<john-world>-cache w) ())	; qualifications read the old value
  (set (<john-world>-writes w) (cons (cons o (cons p v)) (<john-world>-writes w))))
(define-function john-at-time (w t)
  (or (>= t 0) (john-fail "at time " t ": before the first world"))
  (while (> (<john-world>-time w) t) (set w (<john-world>-parent w)))
  w)

;;; ---- values.  A value is a Maru value, what it does chosen by its type: a name (an object or
;;; a word like empty), a number, a string, a list, or a class named where a value is read

(define-function john-true? (v) (and v (not (= v 'no))))
(define-function john-bool (c) (if c 'yes 'no))
(define-structure <john-class-ref> (name))
(define-function john-class-ref (c) (let ((r (new <john-class-ref>))) (set (<john-class-ref>-name r) c) r))

(define-selector john-text (v) "?")
(define-method john-text <symbol> () (symbol->string self))
(define-method john-text <long> () (format "%d" self))
(define-method john-text <string> () self)
(define-method john-text <john-class-ref> () (symbol->string self.name))
(define-method john-text <undefined> () "[ ]")
(define-method john-text <pair> ()
  (let ((s "[ ") (first 1)) (list-do x self (set s (concat-strings s (if first "" ", ") (john-text x))) (set first ())) (concat-string s " ]")))

;; where a collection is read: a list's elements, a class's instances
(define-selector john-elements (v) (john-fail "not a collection: " (john-text v)))
(define-method john-elements <pair> () self)
(define-method john-elements <undefined> () ())
(define-method john-elements <john-class-ref> () (john-instances self.name))

;; a value that is not an object still has a class for qualifications: List, Number, String, Word
(define-selector john-class-of (v) 'Word)
(define-method john-class-of <symbol> () (or (john-object-class self) 'Word))
(define-method john-class-of <pair> () 'List)
(define-method john-class-of <undefined> () 'List)
(define-method john-class-of <long> () 'Number)
(define-method john-class-of <string> () 'String)

;;; ---- enumerated values: set Name = a | b(x, y).  A plain one is itself; one with fields is a value holding them, by name

(define *john-enumerations* ())		; (set (member field...) ...), this program's and the prelude's
(define-function john-prelude-enumerations () '((Answer (yes) (no)) (Nothing (empty))))
(define-function john-member (name)	; (set . (member field...)) or ()
  (let ((found ()))
    (list-do e *john-enumerations*
      (list-do m (cdr e) (and (not found) (= name (car m)) (set found (cons (car e) m)))))
    found))

(define-structure <john-variant> (set kind fields))	; fields: ((name . value) ...), in the order the set declares
(define-method john-class-of <john-variant> () self.set)
(define-method john-text <john-variant> ()
  (let ((s (concat-string (symbol->string self.kind) "(")) (first 1))
    (list-do f self.fields
      (set s (concat-strings s (if first "" ", ") (symbol->string (car f)) ": " (john-text (cdr f))))
      (set first ()))
    (concat-string s ")")))
;; two values are the same by what they hold
;; a value with fields against its bare name would just be no, so that's an error: it's the kind that compares to a name
(define-function john-kind-only (name)
  (john-fail name " has fields, so compare its kind: x kind = " name))
(define-selector john-same (a b) (equal a b))
(define-method john-same <symbol> (b)
  (if (= <john-variant> (type-of b))
      (john-kind-only self)
    (= self b)))
(define-method john-same <john-variant> (b)
  (and (symbol? b) (john-kind-only b))
  (and (= <john-variant> (type-of b))
       (= self.kind (<john-variant>-kind b))
       (let ((same 1) (theirs (<john-variant>-fields b)))
	 (list-do f self.fields
	   (or (john-same (cdr f) (cdar theirs)) (set same ()))
	   (set theirs (cdr theirs)))
	 same)))
(define-method john-same <pair> (b)
  (and (pair? b)
       (john-same (car self) (car b))
       (john-same (cdr self) (cdr b))))
;; (variant kind (field: form) ...), with every field the set declares and no others, whatever the order
(define-function john-field-name (k)	; field: -> field
  (let ((s (symbol->string k))) (string->symbol (string-copy s 0 (- (string-length s) 1)))))

;;; ---- expressions, in world w with env ((name . value) ...)

(define john-eval)
(define-function john-make-variant (kind fields w env)
  (let ((m (john-member kind)) (out ()))
    (or m (john-fail "no such value: " kind))
    (let ((given (map (lambda (f) (cons (john-field-name (car f)) (cadr f))) fields)))
      (let ((seen ()))
	(list-do g given
	  (or (member? (car g) (cddr m)) (john-fail kind " has no field " (car g)))
	  (and (member? (car g) seen) (john-fail kind " is given its field " (car g) " twice"))
	  (push seen (car g))))
      (list-do name (cddr m)
	(let ((g (assq name given)))
	  (or g (john-fail kind " needs its field " name))
	  (push out (cons name (john-eval (cdr g) w env)))))
      (new <john-variant> (car m) kind (list-reverse! out)))))
;; a is b: b's kind (a member, the set it's in, a group holding it, a class), or else the same value.  Unlike =, a value
;; with fields is simply not a bare name, since that's the question being asked
(define-function john-kind-name? (b env)
  (and (symbol? b) (not (assq b env))
       (or (john-member b) (assq b *john-enumerations*) (john-class b) (member? b '(Number List String)))))
(define-function john-is-a (v target)
  (let* ((kind (cond ((= <john-variant> (type-of v)) (<john-variant>-kind v))
		     ((and (symbol? v) (john-member v)) v)))
	 (class (if kind (car (john-member kind)) (john-class-of v))))
    (or (= class target) (john-isa? class target)
	(and kind (or (= kind target) (john-isa? kind target))))))
(define-function john-equivalent (a b)
  (and (= (type-of a) (type-of b)) (john-same a b)))
(define-function john-name (x w env)
  (let ((b (assq x env)))
    (cond (b (cdr b))
	  ((john-member x) x)		; a member's name, which is what kind answers
	  ((john-object? x) x)
	  ((john-class x) (john-class-ref x))
	  ((= x 'time) (<john-world>-time w))
	  (else (john-fail "unknown name: " x)))))
(define-function john-quals (c sel)	; clauses for sel on c, then on c's groups
  (let ((out ()))
    (list-do q *john-quals* (and (= sel (cadr q)) (= c (car q)) (push out q)))
    (set out (list-reverse! out))
    (or out (let () (list-do g (cddr (john-class c)) (or out (set out (john-quals g sel)))) out))))
(define-function john-bind (names vals env)
  (while names (set env (cons (cons (car names) (car vals)) env)) (set names (cdr names)) (set vals (cdr vals)))
  env)
(define-function john-qualify-now (r clauses args w)	; first clause whose guard holds
  (let ((v ()) (done ()))
    (list-do q clauses
      (or done
	  (let* ((env (john-bind (caddr q) args (list (cons 'it r)))) (b (cadddr q)))
	    (if (= 'if (car b))
		(and (john-true? (john-eval (cadr b) w env)) (let () (set v 'yes) (set done 1)))
	      (and (or (not (cddr b)) (john-true? (john-eval (caddr b) w env)))
		   (let () (set v (john-eval (cadr b) w env)) (set done 1)))))))
    (if done v (if (= 'if (car (cadddr (car clauses)))) 'no (john-fail "no clause of " (cadr (car clauses)) " applies to " r)))))
;; a world never changes, so its answers are kept, by their question's text (= compares strings by
;; content; a string and a name spelt alike share a key, and no qualification here takes a string)
(define-function john-qualify (r clauses args w)
  (let* ((key (john-text (cons r (cons (cadr (car clauses)) args)))) (hit (assq key (<john-world>-cache w))))
    (if hit (cdr hit)
      (let ((v (john-qualify-now r clauses args w)))
	(set (<john-world>-cache w) (cons (cons key v) (<john-world>-cache w)))
	v))))
;; the messages every value of a type answers, each a selector: (message . selector)
(define *john-builtins* ())
(define-function john-no-builtin (sel r) (john-fail "no property or qualification " sel " of " (john-text r)))
(define-form define-john-builtin (message name)
  `(let () (define-selector ,name (r . _) (john-no-builtin ',message r)) (push *john-builtins* (cons ',message ,name))))
;; what an enumerated value is: its member's name, for a plain one and one with fields alike
(define-john-builtin kind john-kind)
(define-method john-kind <john-variant> () self.kind)
(define-method john-kind <symbol> () (if (john-member self) self (john-no-builtin 'kind self)))
(define-john-builtin name john-name-of)	(define-method john-name-of <string> () (string->symbol self))
(define-john-builtin size john-size)	(define-method john-size <pair> () (list-length self))	(define-method john-size <undefined> () 0)
(define-john-builtin first john-first)	(define-method john-first <pair> () (car self))
(define-john-builtin second john-second) (define-method john-second <pair> () (cadr self))
(define-john-builtin third john-third)	(define-method john-third <pair> () (caddr self))
(define-john-builtin rest john-rest)	(define-method john-rest <pair> () (cdr self))
(define-john-builtin last john-last)	(define-method john-last <pair> () (if (cdr self) (john-last (cdr self)) (car self)))
;; lists count from 1: at: n is the nth element, to: n the first n, from: n the nth onward
(define-john-builtin at: john-at)	(define-method john-at <pair> (n) (cond ((< n 1) (john-fail "at: " n " is below 1")) ((< n 2) (car self)) (else (john-at (cdr self) (- n 1)))))
					(define-method john-at <undefined> (n) (john-fail "at: past the end of a list"))
(define-john-builtin to: john-to)	(define-method john-to <pair> (n) (cond ((< n 0) (john-fail "to: " n " is a negative length")) ((< n 1) ()) (else (cons (car self) (john-to (cdr self) (- n 1))))))
					(define-method john-to <undefined> (n) (if (< n 0) (john-fail "to: " n " is a negative length") ()))
(define-john-builtin from: john-from)	(define-method john-from <pair> (n) (if (< n 2) self (john-from (cdr self) (- n 1))))
					(define-method john-from <undefined> (n) ())
;; a builtin reads the world it's asked in from *john-builtin-world*, the current world when nothing names one
(define *john-builtin-world* ())
(define-function john-builtin (r sel args . in)
  (let ((b (assq sel *john-builtins*)) (saved *john-builtin-world*))
    (or b (john-no-builtin sel r))
    (set *john-builtin-world* (if in (car in) *john-world*))
    (let ((v (apply (cdr b) (cons r args))))
      (set *john-builtin-world* saved)
      v)))
(define-function john-field (r sel)	; (field . value) if r is a value with that field
  (and (= <john-variant> (type-of r)) (assq sel (<john-variant>-fields r))))
(define-function john-send (r sel args w)
  (let ((c (john-class-of r)))
    (cond ((and (john-object? r) (not args) (member? sel (john-props c))) (john-lookup w r sel))
	  ((and (not args) (john-field r sel)) (cdr (john-field r sel)))
	  ((john-quals c sel) (john-qualify r (john-quals c sel) args w))
	  (else (john-builtin r sel args w)))))
(define-function john-holds (r a b w env)
  (if (= r 'in) (john-bool (member? a (john-elements b)))
   (if (= r 'did) (let ((st (<john-world>-action w))) (john-bool (and st (= a (car st)) (= b (cadr st)))))
    (let ((d (assq r *john-rels*)))
      (or d (john-fail "no relation " r))
      (john-bool (john-true? (john-eval (cadddr d) w (list (cons (cadr (cadr d)) a) (cons (cadr (caddr d)) b)))))))))
(define-function john-quantify (all? l p w env)
  (let ((r all?))
    (list-do x (john-elements (john-eval l w env))
      (let ((h (john-true? (john-eval p w (cons (cons 'each x) env)))))
	(if all? (or h (set r ())) (and h (set r 1)))))
    (john-bool r)))
(define-function john-quantify-time (all? v lo hi p w env)	; times lo+1 ... hi, none later than w, none before the first action
  (let ((r all?) (t (+ 1 (if lo (max 0 (john-eval lo w env)) 0))) (end (john-eval hi w env)))
    (or (<= end (<john-world>-time w)) (john-fail "time " end " is later than now, " (<john-world>-time w)))
    (while (<= t end)
      (let ((h (john-true? (john-eval p w (cons (cons v t) env)))))
	(if all? (or h (set r ())) (and h (set r 1))))
      (set t (+ t 1)))
    (john-bool r)))
;; arithmetic by the left operand's type: numbers, and lists, where + appends and - removes
;; (a single element on the right is a list of one, G8)
(define-selector john-number (v) (john-fail "not a number: " (john-text v)))
(define-method john-number <long> () self)
(define-selector john-as-list (v) (list v))
(define-method john-as-list <pair> () self)
(define-method john-as-list <undefined> () ())
(define-selector john-add (a b) (john-fail "can't add " (john-text b) " to " (john-text a)))
(define-method john-add <long> (b) (+ self (john-number b)))
(define-method john-add <pair> (b) (concat-list self (john-as-list b)))
(define-method john-add <undefined> (b) (john-as-list b))
(define-selector john-subtract (a b) (john-fail "can't take " (john-text b) " from " (john-text a)))
(define-method john-subtract <long> (b) (- self (john-number b)))
(define-method john-subtract <pair> (b)
  (let ((out ()) (bs (john-as-list b))) (list-do x self (or (member? x bs) (push out x))) (list-reverse! out)))
(define-method john-subtract <undefined> (b) ())
(define-function john-arith (o a b)
  (cond ((= o '+) (john-add a b)) ((= o '-) (john-subtract a b))
	((= o '*) (* (john-number a) (john-number b))) (else (/ (john-number a) (john-number b)))))
(define-function john-eval (x w env)
  (cond ((symbol? x) (john-name x w env))
	((not (pair? x)) x)
	(else (let ((op (car x)))
		(cond ((= op 'send) (john-send (john-eval (cadr x) w env) (caddr x) (map (lambda (a) (john-eval a w env)) (cdddr x)) w))
		      ((= op 'list) (map (lambda (a) (john-eval a w env)) (cdr x)))
		      ((= op '=) (john-bool (john-same (john-eval (cadr x) w env) (john-eval (caddr x) w env))))
		      ((= op 'variant) (john-make-variant (cadr x) (cddr x) w env))
		      ((member? op '(< > <= >=))
		       (let ((a (john-eval (cadr x) w env)) (b (john-eval (caddr x) w env)))
			 (john-bool (cond ((= op '<) (< a b)) ((= op '>) (> a b)) ((= op '<=) (<= a b)) (else (>= a b))))))
		      ((member? op '(+ - * /)) (john-arith op (john-eval (cadr x) w env) (john-eval (caddr x) w env)))
		      ((= op 'and) (john-bool (and (john-true? (john-eval (cadr x) w env)) (john-true? (john-eval (caddr x) w env)))))
		      ((= op 'or) (john-bool (or (john-true? (john-eval (cadr x) w env)) (john-true? (john-eval (caddr x) w env)))))
		      ((= op 'not) (john-bool (not (john-true? (john-eval (cadr x) w env)))))
		      ((= op 'is)
		       (let ((v (john-eval (cadr x) w env)))
			 (john-bool (if (john-kind-name? (caddr x) env)
					(john-is-a v (caddr x))
				      (john-equivalent v (john-eval (caddr x) w env))))))
		      ((= op 'rel) (john-holds (cadr x) (john-eval (caddr x) w env)
					       (if (= 'did (cadr x)) (cadddr x) (john-eval (cadddr x) w env)) w env))
		      ((and (member? op '(every any)) (= 'time (cadr x)) (cddddr x))
		       (john-quantify-time (= op 'every) (caddr x) (cadddr x) (car (cddddr x)) (cadr (cddddr x)) w env))
		      ((= op 'every) (john-quantify 1 (cadr x) (caddr x) w env))
		      ((= op 'any) (john-quantify () (cadr x) (caddr x) w env))
		      ((= op 'at-time) (let ((t (john-eval (cadr x) w env)))
					 (or (<= t (<john-world>-time w)) (john-fail "at time " t ": an expression reads only the past, now " (<john-world>-time w)))
					 (john-eval (caddr x) (john-at-time w t) env)))
		      ((= op 'one-from) (let ((xs (john-elements (john-eval (cadr x) w env))))	; RN-2008-003 §14
					  (or xs (john-fail "one-from: nothing to choose from"))
					  (car xs)))
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
	     (set v (cond ((= v 'yes) 1) ((= v 'no) 0) (else (john-number v))))
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
;; a world's state: every property of every object, as text; seen states kept in a table (hash.l, by equal)
(define-function john-state (w)
  (let ((s ""))
    (list-do o *john-objects* (list-do p (john-props (cdr o)) (set s (concat-strings s (john-text (john-lookup w (car o) p)) " "))))
    s))
(define-function john-new-state? (seen w)	; and records it
  (let ((k (john-state w)))
    (and (not (hash-includes? seen k)) (let () (hash-at-put seen k 't) 1))))
(define-function john-step-text (st)	; (actor action args...) as A move Peg2
  (let ((s (concat-strings (john-text (car st)) " " (john-text (cadr st))))) (list-do v (cddr st) (set s (concat-strings s " " (john-text v)))) s))
(define-function john-path (w)
  (let ((out ())) (while (<john-world>-action w) (push out (<john-world>-action w)) (set w (<john-world>-parent w))) out))
(define john-sat-satisfy)
(define john-search)
;; How a goal gets solved is separate from what it means (RN-2008-003, Six).  A strategy takes (o g args using by).
;; A goal's first goal-strategy whose guard holds names one; otherwise set-opt planner does; otherwise it's the search.
(define *john-strategies* ())	; (name . function)
(define-function john-strategy (name function) (push *john-strategies* (cons name function)))
(define *john-goal-strategies* ())	; (class goal strategy guard), in program order
(define-function john-goal-named? (g)
  (let ((found ())) (list-do d *john-goals* (and (= g (cadr d)) (set found 1))) found))
(define-function john-strategy-for (o g)
  (let ((name ()))
    (list-do d *john-goal-strategies*
      (or (john-goal-named? (cadr d)) (john-fail "goal-strategy for no goal: " (cadr d)))
      (and (not name)
	   (= g (cadr d))
	   (john-isa? (john-object-class o) (car d))
	   (or (not (cadddr d)) (john-true? (john-eval (cadddr d) *john-world* (list (cons 'it o)))))
	   (set name (caddr d))))
    (set name (or name (cdr (assq 'planner *john-options*)) 'search))
    (or (cdr (assq name *john-strategies*)) (john-fail "no strategy " name))))
(define-function john-satisfy (o g args using by)
  ((john-strategy-for o g) o g args using by))
(define-function john-goal-of (o g)	; o's goal g, its class's or a group's
  (let ((goal ()) (c (john-object-class o)))
    (list-do d *john-goals* (and (= g (cadr d)) (john-isa? c (car d)) (set goal d)))
    (or goal (john-fail "no goal " g " for " o))
    goal))
(define-function john-satisfied (found)	; the world a plan reaches, now the current one
  (set *john-world* found)
  (john-say (concat-string "satisfied at time: " (format "%d" (<john-world>-time found))))
  (let ((s "satisfied by: [ ") (first 1))
    (list-do st (john-path found) (set s (concat-strings s (if first "" " , ") (john-step-text st))) (set first ()))
    (john-say (concat-string s " ]"))))
(define-function john-search (o g args using by)
  (let* ((goal (john-goal-of o g)) (frontier (list *john-world*)) (found ()) (k 0)
	 (ahead (cdr (assq 'max-time-ahead *john-options*))) (horizon ahead) (committed *john-world*)
	 (merge (john-true? (cdr (assq 'merge-worlds *john-options*)))) (seen (and merge (equal-hash-table))))
    (and merge (john-new-state? seen *john-world*))
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
		     (and merge (let () (set seen (equal-hash-table)) (list-do w frontier (john-new-state? seen w))))
		     (john-say (concat-strings "certain: " (john-step-text (<john-world>-action step))))))
	      (list-do w frontier (list-do c (john-expand w o g using by) (and (or (not merge) (john-new-state? seen c)) (push next c))))
	      (set next (list-reverse! next))	; concat-list recurses per element and overflows on a wide level
	      (set k (+ k 1))
	      (set frontier next)
	      (and next (john-say (concat-strings "looking " (format "%d" k) " time unit ahead (" (format "%d" (list-length next)) " possible worlds)")))))))
    (if found (john-satisfied found) (john-say (if frontier "not satisfied within the time limit" "unsatisfiable")))))

(john-strategy 'search john-search)
(john-strategy 'sat (lambda (o g args using by)	; john-sat.l, loaded when first asked for
		      (require "john-sat.l")
		      (john-sat-satisfy o g args using by)))

;;; ---- statements

(define-function john-make (c o vals env)	; a name given to make is an object, made or not yet
  (let ((cl (john-class c)))
    (or cl (john-fail "make: no class " c))
    (set o (if (symbol? o) o (john-eval o *john-world* env)))
    (set *john-objects* (concat-list *john-objects* (list (cons o c))))
    (let ((ps (cadr cl)))
      (or (= (list-length ps) (list-length vals)) (john-fail "make " o ": " (list-length ps) " properties, " (list-length vals) " values"))
      (list-do v vals (john-write *john-world* o (car ps) (if (symbol? v) v (john-eval v *john-world* env))) (set ps (cdr ps))))))
(define-function john-at-time-query (t e)	; past: that world; future: every possible world that far ahead
  (let ((now (<john-world>-time *john-world*)))
    (if (<= t now) (john-say (john-text (john-eval e (john-at-time *john-world* t) ())))
      (let ((ws (list *john-world*)) (vs ()) (k now))
	(while (< k t)
	  (let ((next ())) (list-do w ws (list-do c (john-children w () ()) (push next c))) (set ws (list-reverse! next)))
	  (set k (+ k 1)))
	(list-do w ws (let ((v (john-eval e w ()))) (or (member? v vs) (set vs (concat-list vs (list v))))))
	(john-say (concat-strings "Possible World values (" (format "%d" (- t now)) " time unit from now):"))
	(let ((s "{ ") (first 1)) (list-do v vs (set s (concat-strings s (if first "" ", ") (john-text v))) (set first ()))
	  (john-say (concat-string s " }")))))))
(define-function john-do (r a args)	; one action, here and now; the memo's do (§11), its arguments given
  (let ((d ()))
    (list-do x *john-actions* (and (= a (cadr x)) (john-isa? (john-object-class r) (car x)) (set d x)))
    (or d (john-fail r " has no action " a))
    (let ((c (john-step *john-world* r d args)))
      (if c (set *john-world* c) (john-say (concat-strings (john-text r) " can't " (john-text a)))))))
;; a field reads by its name, so it can't hide what every value answers, and each is named once
(define-function john-check-fields (members)
  (list-do m members
    (let ((seen ()))
      (list-do f (cdr m)
	(and (assq f *john-builtins*) (john-fail (car m) " can't have a field " f ": every value answers " f))
	(and (member? f seen) (john-fail (car m) " names its field " f " twice"))
	(push seen f)))))
(define-function john-set-text (vs)
  (let ((s "{ ") (first 1)) (list-do v vs (set s (concat-strings s (if first "" ", ") (john-text v))) (set first ())) (concat-string s " }")))
(define-function john-statement (s)
  (let ((op (car s)))
    (cond ((= op 'load) (require (cadr s)))
	  ((= op 'enumeration) (john-check-fields (cddr s)) (set *john-enumerations* (cons (cdr s) *john-enumerations*)))
	  ((= op 'start-world) (set *john-world* (new <john-world>)) (set (<john-world>-time *john-world*) 0))
	  ((= op 'end-world))
	  ((= op 'group) (or (john-class (cadr s)) (push *john-classes* (list (cadr s) ())))
	   (list-do m (cddr s) (let ((cl (or (john-class m) (let () (push *john-classes* (list m ())) (john-class m)))))
				 (set-cdr (cdr cl) (cons (cadr s) (cddr cl))))))
	  ((= op 'create) (let ((ps (if (= 'typed (caddr s)) (map caddr (cdddr s)) (cddr s))) (cl (john-class (cadr s))))
			    (if cl (set-car (cdr cl) ps) (push *john-classes* (list (cadr s) ps)))))
	  ((= op 'make) (john-make (cadr s) (caddr s) (cdddr s) ()))
	  ((= op 'for) (list-do x (john-elements (john-eval (cadr s) *john-world* ()))
			 (let ((b (caddr s)) (env (list (cons 'each x))))
			   (if (= 'make (car b)) (john-make (cadr b) (caddr b) (cdddr b) env)
			     (john-say (john-text (john-eval b *john-world* env)))))))
	  ((= op 'qualify) (set *john-quals* (concat-list *john-quals* (list (cdr s)))))
	  ((= op 'rel-qualify) (or (cadr s) (push *john-rels* (list (cadddr s) (caddr s) (car (cddddr s)) (cadr (cddddr s))))))
	  ((= op 'action) (set *john-actions* (concat-list *john-actions* (list (list (cadr s) (caddr s) (cadddr s) (cddddr s))))))
	  ((= op 'rule) (set *john-rules* (concat-list *john-rules* (list (cdr s)))))
	  ((= op 'goal) (push *john-goals* (cdr s)))
	  ((= op 'heuristic) (set *john-heuristics* (concat-list *john-heuristics* (list (cdr s)))))
	  ((= op 'set-opt) (push *john-options* (cons (cadr s) (if (symbol? (caddr s)) (caddr s) (john-eval (caddr s) *john-world* ()))))	; a word is itself: planner sat
	   (and (= (cadr s) 'time-limit) (set *john-limit* (cdar *john-options*))))
	  ((= op 'action-optimization) (set *john-aopts* (concat-list *john-aopts* (list (cdr s)))))
	  ((= op 'goal-strategy) (set *john-goal-strategies* (concat-list *john-goal-strategies* (list (cdr s)))))
	  ((= op 'goal-optimization) (set *john-gopts* (concat-list *john-gopts* (list (cdr s)))))
	  ((= op 'satisfy) (john-satisfy (cadr s) (caddr s) (map (lambda (a) (john-eval a *john-world* ())) (cadddr s))
					 (car (cddddr s)) (cadr (cddddr s))))
	  ((= op 'query) (john-say (cond ((= 'time (cadr s)) (john-text (<john-world>-time *john-world*)))	; time.: the current world's
					 ((and (pair? (cadr s)) (= 'all (car (cadr s))))	; a class's instances, a set as §14 prints them
					  (john-set-text (john-eval (cadr s) *john-world* ())))
					 (else (john-text (john-eval (cadr s) *john-world* ()))))))
	  ((= op 'is) (john-say (john-text (john-eval (cadr s) *john-world* ()))))	; the memos' is ... ?
	  ((= op 'at-time) (john-at-time-query (john-eval (cadr s) *john-world* ()) (caddr s)))
	  ((= op 'do) (john-do (cadr s) (caddr s) (map (lambda (a) (john-eval a *john-world* ())) (cdddr s))))
	  (else (john-fail "statement not read yet: " op)))))
(define-function john-begin ()
  (set *john-limit* 16)
  (set *john-classes* ()) (set *john-objects* ()) (set *john-quals* ()) (set *john-rels* ()) (set *john-actions* ())
  (set *john-rules* ()) (set *john-goals* ()) (set *john-aopts* ()) (set *john-gopts* ()) (set *john-goal-strategies* ()) (set *john-enumerations* (john-prelude-enumerations)) (set *john-heuristics* ()) (set *john-options* ()) (set *john-out* ()) (set *john-world* (new <john-world>))
  (set (<john-world>-time *john-world*) 0))
;; entering a statement
(define *john-declarations* '(load enumeration start-world end-world group create make qualify rel-qualify action rule goal
			      heuristic set-opt action-optimization goal-strategy goal-optimization))
(define-function john-mutations (from to)	; each step from world from to world to: time T: STEP, then what it wrote
  (let ((ws ()))
    (while (and to (not (= to from))) (push ws to) (set to (<john-world>-parent to)))
    (list-do w ws
      (john-say (concat-strings "time " (john-text (<john-world>-time w)) ": " (john-step-text (<john-world>-action w))))
      (list-do wr (let ((r ())) (list-do x (<john-world>-writes w) (push r x)) r)	; writes are newest first
	(john-say (concat-strings "  " (john-text (car wr)) " " (john-text (cadr wr)) " = " (john-text (cddr wr))))))))
(define-function john-condition-text (c)	; (error part ...) as one line
  (let ((s "")) (list-do p (cdr c) (set s (concat-string s (if (string? p) p (john-text p))))) s))
(define-function john-enter (s)
  (let ((before *john-out*) (w *john-world*))
    (if (not *john-echo*) (john-statement s)
      (let ((failed (let () (require "recover.l")	; at the prompt only (it takes a second to load): batch runs end on an error
		      ((eval 'try-call) (lambda () (john-statement s) ()) john-condition-text))))	; found when run, as it loads late
	(cond (failed (john-say failed))
	      ((or (member? (car s) *john-declarations*) (and (= 'for (car s)) (= 'make (car (caddr s))))) (john-say "ok."))	; a for that makes declares
	      ((not (= w *john-world*)) (john-mutations w *john-world*)))))
    (let ((out ()) (l *john-out*)) (while (not (= l before)) (push out (car l)) (set l (cdr l))) out)))
(define-function john-run (forms)
  (john-begin)
  (list-do s forms (john-enter s))
  (list-reverse! *john-out*))
(define-function john-run-file (path) (john-run (john-read path)))
