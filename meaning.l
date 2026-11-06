;;; meaning.l: call by meaning (Samimi, Deaton, Ohshima, Warth and Millstein, Onward! 2014, VPRI TR-2014-003) for John, with
;;; a model where the paper had Cyc.  Cyc proved its answers from a knowledge base; a model proves nothing, so every answer
;;; is held to something John can check, input-output pairs as the paper's 8.2 suggests, and a refused one goes back to
;;; the model with the reason.  A John program that loads this file can send:
;;;   "converts minutes to seconds" find-passing: "minutes-to-seconds"
;;;       tier I: an object whose spec (a property named spec) means the text, and which passes the probe, a
;;;       qualification of its class, whatever its spec says
;;;   "minutes from seconds" adapt: [ [ 120, 2 ], [ 30, 0 ] ]
;;;       tier III: a formula in x (meaning.g) that maps each example's first to its second, kept in the world it was
;;;       found in, so a branch that fails takes it with it
;;;   900 apply-adapter: "minutes from seconds"
;;;       the formula's value at 900, with no model
;;; Finding nothing in *meaning-attempts* tries is an error, which recover.l's try catches.  Answers are recorded by
;;; prompt, so a question asked again isn't sent again.  *meaning-model* is ollama-ask: what it's sent leaves the machine.
(require "john-eval.l")
(require "ollama.l")
(define-function formula-left (a r) (list-do s r (set a (list (car s) a (cadr s)))) a)
(tpeg-load "meaning.g")
(tpeg-load "meaning-value.g")
(define *meaning-attempts* 3)
(define *meaning-model* ollama-ask)
(define *meaning-answers* ())			; (prompt . answer), every answer the model gave
(define-function meaning-ask (prompt)
  (let ((known (assoc-text prompt *meaning-answers*)))
    (if known (cdr known)
      (let ((answer (*meaning-model* prompt)))	; a failed call isn't recorded, so it can be asked again
	(and answer (push *meaning-answers* (cons prompt answer)))
	answer))))
(define-function meaning-read (rule text)	; what rule reads from text, in a list, or ()
  (let ((p (text-parser-for-on <meaning> text)))
    (and (rule p) (list (<text-parser>-result p)))))
(define-function formula-value (f x)		; (value) at x, or () for a division by zero
  (let ((p (source-parser-for <formulavalue> (list f))))
    (and (source-parser-invoke-args 'value $value p x) (list (<source-parser>-result p)))))
;; asks until answer->found gives something, telling the model what was wrong with each refusal
(define-function meaning-search (prompt answer->found)
  (let ((refused "") (found ()) (tries 0))
    (while (and (not found) (< tries *meaning-attempts*))
      (set tries (+ tries 1))
      (let* ((answer (meaning-ask (if (equal refused "") prompt
				    (concat-strings prompt "\nThese answers were refused:\n" refused))))
	     (verdict (if answer (answer->found answer) (cons () "the service failed"))))
	(if (car verdict) (set found (car verdict))
	  (set refused (concat-strings refused (cdr verdict) "\n")))))
    found))

;; ---- tier I
(define-function spec-of (o w)			; an object's spec, or ()
  (and (member? 'spec (john-props (john-object-class o)))
       (let ((v (john-lookup w o 'spec))) (and (string? v) v))))
(define-john-builtin find-passing: john-find-passing)
(define-method john-find-passing <string> (probe)
  (let ((w *john-builtin-world*) (listing ()))
    (list-do o *john-objects*
      (let ((s (spec-of (car o) w))) (and s (push listing (concat-strings (john-text (car o)) ": " s "\n")))))
    (or (meaning-search
	 (concat-strings "Each line names an object and says what it means:\n" (apply concat-strings (list-reverse! listing))
			 "\nWhich object " self "? Reply with its name only.")
	 (lambda (answer)
	   (let* ((name (meaning-read $name answer))
		  (o (and name (string->symbol (car name)))))
	     (cond ((not (and o (john-object? o) (spec-of o w))) (cons () (concat-strings answer ": that's no object with a spec")))
		   ((not (john-true? (john-send o (string->symbol probe) () w)))
		    (cons () (concat-strings (car name) ": its behaviour doesn't match " probe ", whatever its spec says")))
		   (else (list o))))))
	(john-fail "no object found for: " self))))

;; ---- tier III
(define-function adapter-of (w query)		; the formula found for query in w or an earlier world, or ()
  (let ((key (string->symbol query)) (found ()))
    (while (and w (not found))
      (list-do e (<john-world>-writes w) (and (not found) (= (car e) '%adapter) (= (cadr e) key) (set found (list (cddr e)))))
      (set w (<john-world>-parent w)))
    (car found)))
(define-function example-text (e) (concat-strings "  " (john-text (car e)) " -> " (john-text (cadr e)) "\n"))
(define-john-builtin adapt: john-adapt)
(define-method john-adapt <string> (examples)
  (let ((w *john-builtin-world*))
    (or (adapter-of w self)
	(let ((f (meaning-search
		  (concat-strings "Write a formula in x for: " self "\nIt must map:\n" (apply concat-strings (map example-text examples))
				  "Use only x, whole numbers, + - * / and parentheses, with the usual precedence; / divides whole numbers, "
				  "dropping the fraction. Reply with the formula only, on one line.")
		  (lambda (answer)
		    (let ((f (meaning-read $formula answer)) (bad ()))
		      (if (not f) (cons () (concat-strings answer ": not a formula of x, + - * / and whole numbers"))
			(list-do e examples (or bad (equal (formula-value (car f) (car e)) (list (cadr e))) (set bad e)))
			(if (not bad) f
			  (let ((v (formula-value (car f) (car bad))))
			    (cons () (concat-strings answer ": gives " (if v (john-text (car v)) "no value") " for "
						     (john-text (car bad)) ", not " (john-text (cadr bad))))))))))))
	  (or f (john-fail "no formula found for: " self))
	  (john-write w '%adapter (string->symbol self) f)))
    self))
(define-john-builtin apply-adapter: john-apply-adapter)
(define-method john-apply-adapter <long> (query)
  (let* ((f (or (adapter-of *john-builtin-world* query) (john-fail "no adapter for: " query)))
	 (v (formula-value f self)))
    (or v (john-fail query " has no value at " self))
    (car v)))
