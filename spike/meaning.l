;;; THROWAWAY SPIKE.  Call by meaning (Samimi, Deaton, Ohshima, Warth, Millstein, Onward! 2014, VPRI TR-2014-003) with a model where they
;;; had Cyc.  Cyc was a prover over a knowledge base and the paper trusts providers' specs (its 8.3); a model proves nothing, so every
;;; answer here is held to something John can check, as its 8.2 suggests: input-output pairs.
;;;   "can tell the time" find-passing: "tells-time"   tier I: an object whose spec means that, and which passes the probe tells-time,
;;;                                                    a qualification of its class
;;;   "minutes from seconds" adapt: [ [ 120, 2 ], [ 30, 0 ] ]   tier III: not a value but a formula in x, arithmetic only, that maps
;;;                                                    each example's first to its second; then x apply-adapter: ... runs it, no model
;;; Answers are operations, as before; a refused one is told to the model, which tries again.
(require "spike/john-model.l")
(define *meaning-attempts* 3)
(define-function spec-of (o)			; an object's spec, or ()
  (let ((ps (john-props (john-object-class o))) (v ()))
    (and (has-equal? 'spec ps) (set v (john-lookup *john-world* o 'spec)))
    (and (string? v) v)))
(define-function with-feedback (prompt tried)
  (if tried (concat-strings prompt "\nThese answers were refused:\n" tried) prompt))
;; ---- tier I
(define-john-builtin find-passing: john-find-passing)
(define-method john-find-passing <string> (probe)
  (let ((listing "") (found ()) (tried "") (tries 0) (query self))
    (list-do o *john-objects*
      (let ((s (spec-of (car o))))
	(and s (set listing (concat-strings listing (john-text (car o)) ": " s "\n")))))
    (while (and (not found) (< tries *meaning-attempts*))
      (set tries (+ tries 1))
      (let* ((prompt (with-feedback (concat-strings "Each line names an object and says what it means:\n" listing
						    "\nWhich object " query "? Reply with its name only.") (if (equal tried "") () tried)))
	     (answer (replica-ask *john-replica* prompt))
	     (words (and answer (tidy-words (words-of (car (lines-of answer))))))
	     (o (and words (known-object (car words)))))
	(cond
	  ((not answer) (set tried (concat-strings tried "(the service failed)\n")))
	  ((not (and o (spec-of o))) (set tried (concat-strings tried answer ": that's no object with a spec\n")))
	  ((not (john-true? (john-eval (list 'send o (string->symbol probe)) *john-world* ())))
	   (set tried (concat-strings tried (john-text o) ": its behaviour doesn't match " probe ", whatever its spec says\n")))
	  (else (set found o)))))
    (or found (john-fail "no object found for: " query))))
;; ---- tier III: a formula, arithmetic in x only, so what the model wrote can't do anything but compute
(define-function formula-ok? (x)
  (cond
    ((long? x) 1)
    ((= x 'x) 1)
    ((and (pair? x) (has-equal? (car x) '(+ - * /)) (= 3 (list-length x)))
     (and (formula-ok? (cadr x)) (formula-ok? (caddr x))))
    (else ())))
(define-function john-parse-quietly (text)	; the parser's forms, or () on a syntax error
  (and (john-parse text) (john-read-text text)))
(define-function formula-of (text)		; the form, or () if it isn't arithmetic in x
  (let ((line (car (lines-of text))) (forms ()))
    (and (not (text-find line "." 0))
	 (let ()
	   ;; read by John's parser as a qualification's value, and kept only if every node is arithmetic or x
	   (set forms (john-parse-quietly (concat-strings "qualify Adapter value is " line ".")))
	   (and forms (pair? (car forms)) (= 'qualify (caar forms))
		(let ((v (car (cddddr (car forms)))))
		  (and (pair? v) (= 'value (car v)) (formula-ok? (cadr v)) (cadr v))))))))
(define-function formula-value (f x) (john-eval f *john-world* (list (cons 'x x))))
(define *adapters* ())				; (query . formula), from the store, never asked twice
(define-john-builtin adapt: john-adapt)
(define-method john-adapt <string> (examples)
  (let ((found ()) (tried "") (tries 0) (query self) (shown ""))
    (list-do e examples (set shown (concat-strings shown "  " (john-text (car e)) " -> " (john-text (cadr e)) "\n")))
    (while (and (not found) (< tries *meaning-attempts*))
      (set tries (+ tries 1))
      (let* ((prompt (with-feedback (concat-strings "Write a formula in x for: " query "\nIt must map:\n" shown
						    "Use only x, whole numbers, + - * / and parentheses; / divides whole numbers, dropping the fraction, and operators apply strictly left to right, as in Smalltalk (1 + 2 * 3 is 9), so parenthesize. "
						    "Reply with the formula only, on one line.") (if (equal tried "") () tried)))
	     (answer (replica-ask *john-replica* prompt))
	     (f (and answer (formula-of answer))))
	(cond
	  ((not answer) (set tried (concat-strings tried "(the service failed)\n")))
	  ((not f) (set tried (concat-strings tried (car (lines-of answer)) ": not a formula of x, + - * / and whole numbers\n")))
	  (else
	   (let ((bad ()))
	     (list-do e examples (or bad (= (formula-value f (car e)) (cadr e)) (set bad e)))
	     (if bad
		 (set tried (concat-strings tried (car (lines-of answer)) ": gives " (john-text (formula-value f (car bad)))
					    " for " (john-text (car bad)) ", not " (john-text (cadr bad)) "\n"))
	       (set found f)))))))
    (or found (john-fail "no formula found for: " query))
    (push *adapters* (cons query found))
    query))
(define-john-builtin apply-adapter: john-apply-adapter)
(define-method john-apply-adapter <long> (query)
  (let ((f (cdr (assoc-text query *adapters*))))
    (or f (john-fail "no adapter for: " query))
    (formula-value f self)))
