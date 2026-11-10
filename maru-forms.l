;;; maru-forms.l -- maru-forms.g's walk over a form as Maru's reader made it: (maru-forms-walk form binders flags) answers
;;; (cc forms ()), adding the variables form binds to binders and each list a verbose pattern matches to flags, both identity
;;; tables; (maru-forms-count form) is how many forms it holds, a form being a list outside quoted data (erosion.l, source.l).
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
;; the actions that read the parser's fields, set once the grammar's type exists
(define forms-bind ())
(define forms-params ())
(define forms-list ())
(tpeg-load "maru-forms.g")
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

(define-function maru-forms-walk (form binders flags)	; maru-forms.g's answer for form
  (let ((p (source-parser-for <maru-forms> (list form))))
    (set (<maru-forms>-binders p) binders)
    (set (<maru-forms>-flags p) flags)
    (or ($form p) (error "maru-forms: can't walk a form"))
    (<source-parser>-result p)))
(define-function maru-forms-count (form) (cadr (maru-forms-walk form (identity-hash-table) (identity-hash-table))))

