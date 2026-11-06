;;; THROWAWAY SPIKE.  A goal strategy that asks a model for a plan and believes none of it.  The reply is untrusted text, so it never
;;; reaches John's parser, where `load` would run code: each line is split into words, and the words must name a known object, one
;;; of its actions and arguments of the right class.  The plan then replays through John's own rules, and the goal must hold at
;;; its end.  A refusal says why and the model tries again.  Every prompt and answer is an operation, so a replay asks nothing.
;;;   goal-strategy Towers win model.             no plan is an answer that says the model found none, not that none exists
;;;   goal-strategy Towers win model-or-search.   the search then decides
(require "spike/john-llm.l")
(define *model-program-text* "")	; the program, as the prompt shows it
(define *model-attempts* 3)
(define *model-longest-plan* 64)
(define *skip-goal-check* ())		; mutations a test must catch
(define *skip-class-check* ())
(define *no-feedback* ())
(define *why* "")			; why the last plan was refused
(define-function refuse (first . rest) (set *why* (apply concat-strings (cons first rest))) ())
;; ---- words
(define-function words-of (line)
  (let ((out ()) (start ()) (n (string-length line)))
    (for (i 0 n)
      (let ((c (string-at line i)))
	(if (or (= c 32) (= c 9) (= c 13))
	    (and start (let () (push out (string-from line (- start 1) i)) (set start ())))
	  (or start (set start (+ i 1))))))
    (and start (push out (string-from line (- start 1) n)))
    (list-reverse! out)))
(define-function lines-of (text)
  (let ((out ()) (from 0) (n (string-length text)))
    (for (i 0 n)
      (and (= 10 (string-at text i))
	   (let () (push out (string-from text from i)) (set from (+ i 1)))))
    (push out (string-from text from n))
    (list-reverse! out)))
(define-function without-last-char (w) (string-from w 0 (- (string-length w) 1)))
(define-function numbering? (w)			; "1." or "-", what a model puts before a list
  (or (equal w "-") (equal w "*")
      (let ((ok (< 1 (string-length w))) (last (- (string-length w) 1)))
	(and ok (= 46 (string-at w last))
	     (let ()
	       (for (i 0 last) (let ((c (string-at w i))) (or (and (>= c 48) (<= c 57)) (set ok ()))))
	       ok)))))
(define-function tidy-words (words)		; drops numbering and a closing "." or ","
  (and words (numbering? (car words)) (set words (cdr words)))
  (let ((out ()))
    (list-do w words
      (let ((c (string-at w (- (string-length w) 1))))
	(push out (if (and (or (= c 46) (= c 44)) (< 1 (string-length w))) (without-last-char w) w))))
    (list-reverse! out)))
(define-function fence? (line) (and (< 2 (string-length line)) (= 96 (string-at line 0)) (= 96 (string-at line 1))))
;; ---- from words to (actor action-definition args)
(define-function known-object (word)		; an object John already has, or ()
  (let ((found ()))
    (list-do o *john-objects* (and (equal word (symbol->string (car o))) (set found (car o))))
    found))
(define-function action-of (actor word)
  (let ((d ()))
    (list-do x *john-actions*
      (and (equal word (symbol->string (cadr x))) (john-isa? (john-object-class actor) (car x)) (set d x)))
    d))
(define-function parse-move (words line)	; a move, or () with *why* set
  (let ((actor (known-object (car words))))
    (cond
      ((not actor) (refuse "\"" line "\" doesn't begin with an object"))
      ((not (cdr words)) (refuse "\"" line "\" names no action"))
      (else
       (let ((d (action-of actor (cadr words))) (args ()) (bad ()))
	 (list-do w (cddr words)
	   (let ((o (known-object w))) (if o (push args o) (set bad w))))
	 (set args (list-reverse! args))
	 (cond
	   ((not d) (refuse "\"" line "\": " (car words) " has no action " (cadr words)))
	   (bad (refuse "\"" line "\": " bad " is no object"))
	   ((!= (list-length args) (list-length (caddr d)))
	    (refuse "\"" line "\": " (cadr words) " takes " (long->string (list-length (caddr d))) " arguments"))
	   ((and (not *skip-class-check*)
		 (let ((wrong ()) (ts (caddr d)))
		   (list-do a args
		     (or (john-isa? (john-object-class a) (caar ts)) (set wrong a))
		     (set ts (cdr ts)))
		   wrong))
	    (refuse "\"" line "\": an argument is the wrong kind of thing"))
	   (else (list actor d args))))))))
(define-function parse-plan (text)		; ((actor definition args) ...), or -1 with *why* set
  (let ((moves ()) (failed ()))
    (list-do line (lines-of text)
      (or failed (fence? line)
	  (let ((words (tidy-words (words-of line))))
	    (and words
		 (let ((m (parse-move words line)))
		   (if m (push moves m) (set failed 1)))))))
    (cond
      (failed -1)
      ((not moves) (refuse "the reply held no moves") -1)
      ((< *model-longest-plan* (list-length moves)) (refuse "the plan is longer than " (long->string *model-longest-plan*) " moves") -1)
      (else (list-reverse! moves)))))
;; ---- replay: the same tests as sat's replay, run on what the model said
(define-function replay-plan (moves o g args using)	; the world reached, or () with *why* set
  (let ((w *john-world*) (goal (john-goal-of o g)) (n 0))
    (list-do m moves
      (and w
	   (let ((actor (car m)) (d (cadr m)) (vals (caddr m)) (u (john-using w o g using)))
	     (set n (+ n 1))
	     (let ((child (and (or (not u) (member? (cadr d) u))
			       (john-allowed? w actor d vals)
			       (john-step w actor d vals))))
	       (or child
		   (refuse "move " (long->string n) " (" (john-step-text (cons actor (cons (cadr d) vals)))
			   ") isn't allowed in the state before it"))
	       (set w child)))))
    (and w
	 (if (or *skip-goal-check*
		 (john-true? (john-eval (cadddr goal) w (john-bind (caddr goal) args (list (cons 'it o))))))
	     w
	   (refuse "the plan runs, but the goal doesn't hold at its end")))))
;; ---- the prompt
(define-function state-text (w)
  (let ((parts ()))
    (list-do o *john-objects*
      (list-do p (john-props (cdr o))
	(push parts (concat-strings (john-text (car o)) " " (john-text p) " = " (john-text (john-lookup w (car o) p)) "\n"))))
    (apply concat-strings (list-reverse! parts))))
(define-function plan-prompt (o g args feedback)
  (concat-strings
   "This is a program in JOHN, a planning language. An action's rules must all hold before it, and its effects all read the state before it.\n\n"
   *model-program-text*
   "\n\nThe objects' properties now:\n" (state-text *john-world*)
   "\nFind a sequence of actions after which " (john-text o) "'s goal " (john-text g) " holds.\n"
   "Reply with nothing but the moves, one per line, each as: Object action Arguments\nFor example: A move Peg2\n"
   (if feedback (concat-strings "\nYour last answer was:\n" (car feedback) "\nIt was refused: " (cdr feedback) "\n") "")))
;; ---- oracles: what a strategy demands beyond the goal.  An oracle takes (w start o g args using), the world a plan reached and where
;; it started, and answers () if content or the text of its refusal, which goes back to the model.  Failing to decide is a refusal.
(define *model-oracles* ())
(define-function oracles-refuse (w start o g args using)	; true if one refused, *why* saying why
  (let ((why ()))
    (list-do oracle *model-oracles*
      (or why (set why (oracle w start o g args using))))
    (and why (let () (refuse why) 1))))
;; ---- the strategy
(define-function model-plan (o g args using)	; the world reached, or ()
  (let ((found ()) (feedback ()) (tries 0))
    (while (and (not found) (< tries *model-attempts*))
      (set tries (+ tries 1))
      (let* ((answer (replica-ask *john-replica* (plan-prompt o g args (and (not *no-feedback*) feedback))))
	     (moves (if answer (parse-plan answer) (let () (refuse "the model service failed: " (or *http-failure* "no answer")) -1)))
	     (start *john-world*)
	     (w (and (!= moves -1) (replay-plan moves o g args using)))
	     (w (and w (not (oracles-refuse w start o g args using)) w)))
	(if w
	    (set found w)
	  (john-say (concat-strings "model, attempt " (long->string tries) ": " *why*))
	  (and answer (set feedback (cons answer *why*))))))
    found))
(define-function model-strategy (name oracles)	; a strategy that also demands what these oracles demand
  (john-strategy name
    (lambda (o g args using by)
      (set *model-oracles* oracles)
      (let ((w (model-plan o g args using)))
	(if w
	    (john-satisfied w)
	  (john-say (concat-strings "the model found no plan in " (long->string *model-attempts*) " attempts, which doesn't mean there is none")))))))
(john-strategy 'model
  (lambda (o g args using by)
    (set *model-oracles* ())
    (let ((w (model-plan o g args using)))
      (if w
	  (john-satisfied w)
	(john-say (concat-strings "the model found no plan in " (long->string *model-attempts*) " attempts, which doesn't mean there is none"))))))
(john-strategy 'model-or-search
  (lambda (o g args using by)
    (set *model-oracles* ())
    (let ((w (model-plan o g args using)))
      (if w
	  (john-satisfied w)
	(john-say "the model found no plan, so searching")
	(john-search o g args using by)))))
