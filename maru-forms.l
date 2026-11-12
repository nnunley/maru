;;; maru-forms.l -- maru-forms.g's walk over a form as Maru's reader made it: (maru-forms-walk form binders flags) answers
;;; (cc forms ()), adding the variables form binds to binders and each list a verbose pattern matches to flags, both identity
;;; tables, a grammar's form among them (tpeg-forms.g); (maru-forms-count form) is how many forms it holds, a form being a
;;; list outside quoted data (erosion.l, source.l).
(require "source-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(require "hash.l")

;; the forms that are decisions, besides cond's clauses and and's and or's operands
(define *erosion-decisions* '(if when unless while until for list-do lists-do array-do alist-do string-do namespace-do hash-do))
(define-function erosion-decision? (op) (and (symbol? op) (memq op *erosion-decisions*) 't))

;; what maru-forms.g's rules answer: (cc forms flag), flag a verbose pattern's name, reader (the reader's syntax, no form) or ()
(define *forms-none* '(0 0 ()))
(define-function forms-sum (rs)
  (let ((cc 0) (n 0)) (list-do r rs (set cc (+ cc (car r))) (set n (+ n (cadr r)))) (list cc n ())))
(define-function forms-add (r cc n) (list (+ cc (car r)) (+ n (cadr r)) ()))
(define-function forms-decide (rs) (forms-add (forms-sum rs) 1 0))			; a decision
(define-function forms-operands (rs) (forms-add (forms-sum rs) (- (list-length rs) 1) 0))	; and, or: each operand past the first
(define-function forms-clauses (cs) (forms-sum cs))					; each clause decided its own
(define-function forms-template (ts) (forms-sum ts))
(define-function forms-one (r) (forms-add r 0 1))					; r inside one more list
(define-function forms-reader (r) (list (car r) (cadr r) 'reader))
(define-function forms-flag (rule r) (list (car r) (cadr r) rule))
(define-function forms-any-member? (xs ys)	; keys are made afresh, so compared by equal
  (let ((hit ())) (list-do x xs (list-do y ys (and (equal x y) (set hit 't)))) hit))
;; A lookup on the next element: of the choices, each a list of the keys it's led by, or () for none, those led by keys not
;; met before are tried at once.  Answers (keys tried-in-turn): how many keys, and how many choices are tried one by one
;; (led by a key met before, or by none).
(define-function forms-lookup (key-lists)
  (let ((keys ()) (in-turn 0))
    (list-do kl key-lists
      (if (and kl (not (forms-any-member? kl keys)))
	  (set keys (concat-list kl keys))
	(set in-turn (+ in-turn 1))))
    (list (list-length keys) in-turn)))
(define-function forms-lookup-decisions (l)	; a lookup a decision once, if it has two keys or more; each other try one
  (+ (if (<= 2 (car l)) 1 0) (cadr l)))
;; a grammar's choice: each alternative tried in turn after the first is a decision, those led by distinct literals one
(define-function forms-choice (key-lists rs)
  (let ((l (forms-lookup key-lists)))
    (forms-add (forms-sum rs) (- (+ (forms-lookup-decisions l) (if (< 0 (car l)) 1 0)) 1) 0)))
(define-function forms-string-keys (s)	; a string is looked up by its first character, so "a" and "ab" share a key
  (and (< 0 (string-length s)) (list (cons 'char (string-at s 0)))))
(define-function forms-keys-in (kind keys) (map (lambda (k) (cons kind k)) keys))
(define-function forms-keys-all (key-lists) (let ((all ())) (list-do kl key-lists (if kl (set all (concat-list kl all)) (set all ()))) (and (not (memq () key-lists)) all)))
;; a cond: each test clause is a decision (clause adds it), but those testing one variable against distinct constants,
;; the first such variable's, are one lookup
(define-function forms-constant? (x) (or (long? x) (string? x) (and (pair? x) (= 'quote (car x)) (not (pair? (cadr x))))))
(define-function forms-constant (x) (if (pair? x) (cons 'quote (cadr x)) x))
(define-function forms-test-key (a b)	; (v . k) for (= v k) or (= k v), v a variable and k a constant
  (cond ((and (symbol? a) (forms-constant? b)) (cons a (forms-constant b)))
	((and (symbol? b) (forms-constant? a)) (cons b (forms-constant a)))))
(define-function forms-cond (ks cs)
  (let* ((tests (let ((ts ())) (list-do k ks (or (= k 'else) (push ts k))) (list-reverse! ts)))
	 (subject (let ((s ())) (list-do k tests (and (pair? k) (not s) (set s (car k)))) s))
	 (key-lists (map (lambda (k) (and (pair? k) (= subject (car k)) (list (cdr k)))) tests))
	 (l (forms-lookup key-lists)))
    (forms-add (forms-sum cs) (- (+ (if (< 0 (car l)) 1 0) (cadr l)) (list-length tests)) 0)))
;; the actions that read the parser's fields, set once the grammar's type exists
(define forms-bind ())
(define forms-params ())
(define forms-list ())
(define *forms-rule-answers* ())	; each grammar rule's answer, by the rule, while erosion.l walks a file (or ())
(define forms-rule ())
(tpeg-load "maru-forms.g")
(tpeg-load "tpeg-forms.g")	; and grammars, each rule a callable
(set forms-bind (lambda (self v) (and v (symbol? v) (hash-at-put (<maru-forms>-binders self) v 't)) *forms-none*))
(set forms-params	; a parameter list's names bound, its dotted rest among them; one form if it's a list
     (lambda (self ps)
       (let ((p ps))
	 (while (pair? p) (forms-bind self (car p)) (set p (cdr p)))
	 (forms-bind self p))
       (if (pair? ps) '(0 1 ()) *forms-none*)))
(set forms-list		; a list's answer: quoted data none, the reader's syntax not itself a form
     (lambda (self x r)
       (cond ((= r 'data)		*forms-none*)
	     ((= (caddr r) 'reader)	(list (car r) (cadr r) ()))
	     (else			(and (caddr r) (hash-at-put (<maru-forms>-flags self) x (caddr r)))
					(list (car r) (+ 1 (cadr r)) ())))))

(set forms-rule		; a grammar rule's answer, kept for its callable
     (lambda (self x r)
       (let ((a (forms-list self x r)))
	 (and *forms-rule-answers* (hash-at-put *forms-rule-answers* x a))
	 a)))
(define *forms-grammar-heads* '(grammar-define grammar-extend grammar-eval))
(define-function maru-forms-walk-by (rule x binders flags)	; rule's answer for x: tpeg-forms.g's for a grammar or its rule,
  (let ((p (source-parser-for (if (or (= rule $rule) (and (pair? x) (memq (car x) *forms-grammar-heads*)))	; else maru-forms.g's
				  <tpeg-forms> <maru-forms>)
			      (list x))))
    (set (<maru-forms>-binders p) binders)
    (set (<maru-forms>-flags p) flags)
    (or (rule p) (error "maru-forms: can't walk a form"))
    (<source-parser>-result p)))
(define-function maru-forms-walk (form binders flags) (maru-forms-walk-by $form form binders flags))
(define-function maru-forms-count (form) (cadr (maru-forms-walk form (identity-hash-table) (identity-hash-table))))

