;;; irl-grammar.l -- an irl grammar block as typed Maru (draft-ndn-maru-sat-00 [R-irl-grammar]).
;;;
;;;   (irl-grammar-forms record)	maru.k forms for one (grammar-define <G> <parent> (fields) rules...)
;;;
;;; The matching is tpeg's own: each rule's body is compile-tpeg.l's value-pe output, lowered
;;; here to typed Maru over text-parser.k's runtime.  A grammar G becomes a struct G (string
;;; limit position result span, then its fields, each a long) and one function per rule,
;;; long G_rule(struct G* self).  Its actions are maru.k forms, copied in unchanged.  Rules the
;;; block doesn't define come from its parent, so an inherited rule calls the child's
;;; override.  Typed grammars have no memos, no left recursion and no lists or strings.

(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")

(define *irl-grammars* ())	; (G fields rules) for each block so far
(define *irl-g* ())		; the grammar and rule being lowered, for errors
(define *irl-r* ())
(define *irl-runtime* ())	; text-parser.k is loaded once

(define-function irl-grammar-name (sym)	; <sums> -> sums
  (let ((s (symbol->string sym))) (string->symbol (string-copy s 1 (- (string-length s) 2)))))
(define-function irl-grammar-fail (what) (error "irl grammar: " *irl-g* "." *irl-r* ": " what))
(define-function irl-rule-fn (rule)
  (string->symbol (concat-strings (symbol->string *irl-g*) "_" (symbol->string rule))))

;; what typed Maru can't hold: a string, a symbol, a list, an object, another grammar's rule
(define-function irl-refuse (pe)
  (and (pair? pe) (not (member? (car pe) '(result-expr peek-expr)))
       (let ()
	 (and (member? (car pe) '(make-string make-symbol match-list match-object match-rule-in))
	      (irl-grammar-fail (concat-string (symbol->string (car pe)) " has no typed value")))
	 (list-do x (cdr pe) (irl-refuse x)))))

;; actions are typed already: marked before generation so lowering leaves them alone
(define-function irl-mark-actions (pe)
  (cond ((not (pair? pe)) pe)
	((member? (car pe) '(result-expr peek-expr)) (list (car pe) (list 'tp-action (cadr pe))))
	(else (cons (car pe) (map irl-mark-actions (cdr pe))))))

;; value-pe's output as typed Maru: self.x is a member, a binding a long, a rule a direct call,
;; when and unless their and/or, () false, and list building nothing
(define irl-lower)
(define-function irl-field (sym)	; self.position -> position, or ()
  (let ((s (symbol->string sym)))
    (and (< 5 (string-length s))
	 (= "self." (string-copy s 0 5))
	 (string->symbol (string-copy s 5 (- (string-length s) 5))))))
(define-function irl-lower-binding (b)
  (if (symbol? b) `((,b long) 0) `((,(car b) long) ,(irl-lower (cadr b)))))
(define *irl-lower-renames*	; text-parser.l's runtime -> text-parser.k's
  '((text-parser-match-object . tp-match-char) (text-parser-match-char . tp-match-char)
    (text-parser-match-string . tp-match-string) (text-parser-match-class . tp-match-class)
    (text-parser-match-any . tp-match-any) (text-parser-list-from-to . tp-span)))
(define-function irl-lower (x)
  (cond ((not x) 0)
	((symbol? x) (let ((f (irl-field x))) (if f `(member self ,f) x)))
	((not (pair? x)) x)
	(else (let ((h (car x)))
		(cond ((= h 'tp-action) (cadr x))
		      ((= h 'set)
		       (let ((f (and (symbol? (cadr x)) (irl-field (cadr x)))) (v (caddr x)))
			 (if (and (= f 'result) (pair? v) (= 'tp-action (car v)))
			     `(set-member self result (cast ,(cadr v) long))
			     (if f
				 `(set-member self ,f ,(irl-lower v))
				 `(set ,(cadr x) ,(irl-lower v))))))
		      ((= h 'let)
		       `(let ,(map irl-lower-binding (cadr x)) ,@(map irl-lower (cddr x))))
		      ((and (= h 'and)
			    (= 3 (list-length x))
			    (pair? (caddr x))
			    (= 'array-append (car (caddr x))))	; x?, in statement position
		       `(if ,(irl-lower (cadr x)) (tp-nothing self) (tp-nothing self)))
		      ((= h 'when) `(and ,(irl-lower (cadr x)) (let () ,@(map irl-lower (cddr x)))))
		      ((= h 'unless)
		       `(or ,(irl-lower (cadr x)) (let () ,@(map irl-lower (cddr x)))))
		      ((= h 'text-parser-invoke-rule) `(!= (,(irl-rule-fn (cadr (cadr x))) self) 0))
		      ((member? h '(text-parser-invoke-rule-simply text-parser-invoke-rule-in))
		       (irl-grammar-fail
			 "a rule with arguments, or another grammar's, has no typed call"))
		      ((member? h '(text-parser-string-from-to string->symbol))
		       (irl-grammar-fail "make-string has no typed value"))
		      ((= h 'array) 0)
		      ((= h 'array-append) '(tp-nothing self))
		      ((= h 'array->list) 0)
		      ((= h 'list->string) (irl-lower (cadr x)))
		      ((= h 'string->number-base)
		       `(tp-number self ,(irl-lower (cadr x)) ,(caddr x)))
		      ((= h 'text-parser-expected) 0)
		      (else (let ((r (assq h *irl-lower-renames*)))
			      (cons (if r (cdr r) h) (map irl-lower (cdr x))))))))))

;; left recursion: the rules a rule can call before it consumes anything
(define-function irl-nullable? (pe)
  (let ((h (car pe)))
    (cond ((member? h '(match-zero-one match-zero-more peek-for peek-not peek-expr result-expr)) 1)
	  ((= h 'match-string) (= 0 (string-length (cadr pe))))
	  ((= h 'match-all)
	   (let ((r 1))
	     (list-do e (cdr pe) (or (irl-nullable? e) (set r ())))
	     r))
	  ((= h 'match-first)
	   (let ((r ()))
	     (list-do e (cdr pe) (and (irl-nullable? e) (set r 1)))
	     r))
	  ((member? h '(match-one-more make-span make-string make-symbol))
	   (irl-nullable? (cadr pe)))
	  ((member? h '(assign-result make-number)) (irl-nullable? (caddr pe)))
	  (else ()))))
(define-function irl-left-calls (pe)
  (let ((h (car pe)))
    (cond ((= h 'match-rule) (list (cadr pe)))
	  ((= h 'match-all)
	   (let ((out ()) (go 1))
	     (list-do e (cdr pe)
	       (and go
		    (let ()
		      (set out (concat-list out (irl-left-calls e)))
		      (or (irl-nullable? e) (set go ())))))
	     out))
	  ((= h 'match-first)
	   (let ((out ()))
	     (list-do e (cdr pe) (set out (concat-list out (irl-left-calls e))))
	     out))
	  ((member? h
		    '(match-zero-one
		      match-zero-more
		      match-one-more
		      peek-for
		      peek-not
		      make-span
		      make-string
		      make-symbol))
	   (irl-left-calls (cadr pe)))
	  ((member? h '(assign-result make-number)) (irl-left-calls (caddr pe)))
	  (else ()))))
(define-function irl-left-recursive? (rule rules)	; rule reaches itself through left calls
  (let ((seen ()) (todo (irl-left-calls (cadr (assq rule rules)))) (found ()))
    (while (and todo (not found))
      (let ((r (car todo)))
	(set todo (cdr todo))
	(if (= r rule)
	    (set found 1)
	    (or (member? r seen)
		(let ((d (assq r rules)))
		  (push seen r)
		  (and d (set todo (concat-list todo (irl-left-calls (cadr d))))))))))
    found))

;; (grammar-define <G> <parent> (fields) (rule pe args)...)
(define-function irl-grammar-forms (record)
  (let* ((g (irl-grammar-name (cadr record)))
	 (parent (caddr record))
	 (own (cddddr record))
	 (base (if (= parent '<text-parser>)
		   (list () ())
		   (or (cdr (assq (irl-grammar-name parent) *irl-grammars*))
		       (error "irl grammar: " g ": no grammar block " parent))))
	 (fields (concat-list (car base) (cadddr record)))
	 (rules ())
	 (runtime (and (not *irl-runtime*) (set *irl-runtime* 1) '((load "text-parser.k")))))
    (list-do r (cadr base) (or (assq (car r) own) (push rules r)))
    (set rules (concat-list (list-reverse! rules) own))
    (push *irl-grammars* (list g fields rules))
    (set *irl-g* g)
    (concat-list runtime
		 (cons `(define-struct ,g
				       ((string char *)
					(limit long)
					(position long)
					(result long)
					(span long)
					,@(map (lambda (f) (list f 'long)) fields)))
		       (map (lambda (r)
			      (set *irl-r* (car r))
			      (and (irl-left-recursive? (car r) rules)
				   (error "irl grammar: " g "." (car r) " is left-recursive"))
			      (irl-refuse (cadr r))
			      (let ((body (irl-mark-actions (cadr r))))
				`(define-function ,(irl-rule-fn (car r)) (long)
				   ((self struct ,g *))
				   (let ,(map irl-lower-binding (find-vars body))
				     (return (cast ,(irl-lower (value-pe body)) long))))))
			    rules)))))
