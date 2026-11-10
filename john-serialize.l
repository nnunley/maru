;;; john-serialize.l: a session's chain of worlds as ledger lines, one Maru form each, and back, evaluating nothing
;;; (doc/rfc/draft-ndn-maru-john-development-00.md, R-ledger-forms, R-history-index, R-retired).
;;;
;;;   (john-serialize-worlds from to)  the forms of the worlds after time from, up to world to, oldest first
;;;   (john-ledger-line form)          a form as one line of text, which read gives back
;;;   (john-deserialize forms)         makes, into world 0, then each world appended to the current chain with its own
;;;                                    writes; then every property's history.  A retired object's lines are skipped
;;;   (john-skipped)                   ((name . count) ...) the last john-deserialize skipped
;;;
;;; A world is (world (ACTOR ACTION ARG ...) ((OBJECT PROPERTY VALUE) ...)), a declaration (make CLASS NAME VALUE ...);
;;; a value is a name, a number or a string, (list V ...), or (value KIND (FIELD V) ...) for a value with fields.
(require "john-eval.l")
(define-function john-reversed (l) (let ((out ())) (list-do x l (push out x)) out))	; a copy, reversed

(define-selector john-value->form (v) v)
(define-method john-value->form <pair> () (cons 'list (map john-value->form self)))
(define-method john-value->form <john-variant> ()
  `(value ,(<john-variant>-kind self) ,@(map (lambda (f) (list (car f) (john-value->form (cdr f)))) (<john-variant>-fields self))))

(define-function john-world-form (w)
  `(world ,(map john-value->form (<john-world>-action w))
	  ,(map (lambda (e) (list (car e) (cadr e) (john-value->form (cddr e)))) (john-reversed (<john-world>-writes w)))))
(define-function john-serialize-worlds (from to)
  (let ((out ()))
    (while (> (<john-world>-time to) from)
      (push out (john-world-form to))
      (set to (<john-world>-parent to)))
    out))

;; the text of a form, as Maru's reader reads it back
(define-selector john-ledger-text (x) (error "a ledger holds names, whole numbers, strings and lists, not " x))
(define-method john-ledger-text <symbol> () (symbol->string self))
(define-method john-ledger-text <long> () (long->string self))
(define-method john-ledger-text <string> ()
  (let ((out (array)))
    (array-append out ?\")
    (for (i 0 (string-length self))
      (let ((c (string-at self i)))
	(cond ((= c ?\n) (array-append out ?\\) (array-append out ?n))
	      ((or (= c ?\") (= c ?\\)) (array-append out ?\\) (array-append out c))
	      (else (array-append out c)))))
    (array-append out ?\")
    (array->string out)))
(define-method john-ledger-text <pair> ()
  (let ((s "(") (first 1))
    (list-do x self
      (set s (concat-strings s (if first "" " ") (if x (john-ledger-text x) "()")))
      (set first ()))
    (concat-string s ")")))
(define-function john-ledger-line (form) (john-ledger-text form))

;; ---- reading back
(define-selector john-form->value (f) f)
(define *john-ledger-line* 0)	; the form being read, from 1
(define *john-skipped* ())
(define-function john-skipped () *john-skipped*)
;; the message in parts, none made here: a try that catches it undoes what its body built
(define-function john-ledger-fail args (apply error (cons "ledger " (cons *john-ledger-line* (cons ": " args)))))
(define-function john-ledger-variant (kind fields)
  (let ((m (john-member kind)) (out ()))
    (or m (john-ledger-fail "unknown kind " kind))
    (list-do f fields (or (member? (car f) (cddr m)) (john-ledger-fail kind " has no field " (car f))))
    (list-do name (cddr m)
      (let ((f (assq name fields)))
	(or f (john-ledger-fail kind " needs its field " name))
	(push out (cons name (john-form->value (cadr f))))))
    (new <john-variant> (car m) kind (list-reverse! out))))
(define-method john-form->value <pair> ()
  (cond ((= 'list (car self)) (map john-form->value (cdr self)))
	((= 'value (car self)) (john-ledger-variant (cadr self) (cddr self)))
	(else (john-ledger-fail "not a value: " (john-ledger-text self)))))

(define-function john-ledger-retired (names)	; the first retired name among names, or ()
  (let ((r ())) (list-do n names (and (not r) (symbol? n) (member? n *john-retired*) (set r n))) r))
(define-function john-skip (name)
  (let ((e (assq name *john-skipped*)))
    (if e (set-cdr e (+ 1 (cdr e))) (set *john-skipped* (concat-list *john-skipped* (list (cons name 1)))))))
(define-function john-ledger-object (o)
  (or (john-object? o) (john-ledger-fail "unknown object " o)))
(define-function john-ledger-make (form root)
  (let ((r (john-ledger-retired (list (caddr form)))))
    (if r (john-skip r)
      (let ((now *john-world*))
	(or (john-class (cadr form)) (john-ledger-fail "unknown class " (cadr form)))
	(set *john-world* root)
	(john-make-values (cadr form) (caddr form) (map john-form->value (cdddr form)))
	(set *john-world* now)))))
(define-function john-ledger-world (form)
  (let* ((action (cadr form)) (writes (caddr form))
	 (r (john-ledger-retired (concat-list action (map car writes)))))
    (if r (john-skip r)
      (let ((actor (car action)) (child (new <john-world>)))
	(john-ledger-object actor)
	(let ((found ()))
	  (list-do a *john-actions* (and (= (cadr action) (cadr a)) (john-isa? (john-object-class actor) (car a)) (set found 1)))
	  (or found (john-ledger-fail "unknown action " (cadr action) " of " actor)))
	(set (<john-world>-time child) (+ 1 (<john-world>-time *john-world*)))
	(set (<john-world>-parent child) *john-world*)
	(set (<john-world>-action child) (cons actor (cons (cadr action) (map john-form->value (cddr action)))))
	(list-do e writes
	  (john-ledger-object (car e))
	  (or (member? (cadr e) (john-props (john-object-class (car e)))) (john-ledger-fail "unknown property " (cadr e) " of " (car e)))
	  (john-write child (car e) (cadr e) (john-form->value (caddr e))))
	(set *john-world* child)))))
(define-function john-ledger-shape (form)	; a world or a make, or an error naming the line
  (or (and (pair? form) (= 'world (car form)) (= 3 (list-length form)) (pair? (cadr form)) (or (pair? (caddr form)) (not (caddr form))) 'world)
      (and (pair? form) (= 'make (car form)) (<= 3 (list-length form)) 'make)
      (john-ledger-fail "not a world or a make")))

;; each property's writes, oldest first, over the whole chain, shared by every world of it
(define-function john-build-history ()
  (let ((chain ()) (w *john-world*) (props (equal-hash-table)))
    (while w (push chain w) (set w (<john-world>-parent w)))
    (let ((worlds (list->array chain)) (lists (equal-hash-table)) (h (new <john-history>)))
      (list-do w chain
	(list-do e (john-reversed (<john-world>-writes w))
	  (let ((key (cons (car e) (cadr e))))
	    (hash-at-put lists key (cons (cons (<john-world>-time w) (cddr e)) (hash-at lists key ()))))))
      (hash-do lists (lambda (key es) (hash-at-put props key (list->array (john-reversed es)))))
      (set (<john-history>-worlds h) worlds)
      (set (<john-history>-props h) props)
      (list-do w chain (set (<john-world>-history w) h)))))

(define-function john-deserialize (forms)
  (set *john-skipped* ())
  (let ((root *john-world*))
    (while (<john-world>-parent root) (set root (<john-world>-parent root)))
    (set *john-ledger-line* 0)
    (list-do f forms
      (set *john-ledger-line* (+ 1 *john-ledger-line*))
      (and (= 'make (john-ledger-shape f)) (john-ledger-make f root)))
    (set *john-ledger-line* 0)
    (list-do f forms
      (set *john-ledger-line* (+ 1 *john-ledger-line*))
      (and (= 'world (john-ledger-shape f)) (john-ledger-world f)))
    (john-build-history)))
