;;; Reading a plan: its JOHN program, then its ledger, a chain of worlds written as Maru forms (john-serialize.l), so
;;; what's asked of it is read through John's own evaluator (doc/rfc/draft-ndn-maru-john-development-00.md).
;;;
;;;   (plan-load dir name tree)   a fresh session: DIR/NAME.john, Now's tree, then DIR/NAME.answers if there is one
;;;   (plan-names dir)            the names of DIR/*.john, sorted
;;;   (plan-ask object message)   what it answers in the current world; plan-yes? whether that's yes
;;;   (plan-replay dir name)      ((now . form) ...): each ledger form as the plan's actions write it now, and as it is
;;;   (plan-ledger-drift dir name) () if the ledger is what the plan's actions write now, else which line isn't
(require "john-serialize.l")
(define-function plan-file-lines (path)	; a file's lines, or () if there is no file
  (and (= 0 ((subr "access" "si>i") path 4))
       (let ((text (contents-of-file-named path)) (out ()) (start 0))
	 (for (i 0 (string-length text))
	   (when (= ?\n (string-at text i))
	     (push out (string-copy text start (- i start)))
	     (set start (+ i 1))))
	 (and (< start (string-length text)) (push out (string-copy text start (- (string-length text) start))))
	 (list-reverse! out))))
(define-function plan-ledger-path (dir name) (concat-strings dir "/" name ".answers"))
(define-function plan-load (dir name tree)
  (john-run (concat-list (john-read (concat-strings dir "/" name ".john")) (list (list 'make 'Code 'Now tree))))
  (let ((ledger (plan-ledger-path dir name)))
    (set *john-ledger-file* (list dir "/" name ".answers"))
    (and (= 0 ((subr "access" "si>i") ledger 4)) (john-deserialize (read ledger)))
    (set *john-ledger-file* ())))
(define-function plan-file-lines-of-command (command)	; what a shell command prints, line by line
  (let ((file (concat-strings "/tmp/maru-plan-" (long->string ((subr "getpid" ">i"))))))
    ((subr "system" "s>i") (concat-strings command " > " file))
    (let ((lines (plan-file-lines file))) ((subr "system" "s>i") (concat-strings "rm -f " file)) lines)))
(define-function plan-names (dir)
  (let ((names ()))
    (list-do line (plan-file-lines-of-command (concat-strings "ls " dir))
      (let ((n (string-length line)))
	(and (< 5 n) (= ".john" (string-copy line (- n 5) 5)) (push names (string-copy line 0 (- n 5))))))
    (list-reverse! names)))
(define-function plan-ask (object message . args)
  (john-eval `(send ,object ,message ,@args) *john-world* ()))
(define-function plan-yes? (object message . args)
  (= 'yes (john-eval `(send ,object ,message ,@args) *john-world* ())))
;; a condition's parts as text, joined outside the world that failed
(define-selector plan-part-text (x) (john-text x))
(define-method plan-part-text <string> () self)
(define-function plan-condition-text (c) (apply concat-strings (map plan-part-text (cdr c))))
;; a ledger's worlds, each step taken again by the plan's action as it stands; a retired object's line is kept as it is
(define-function plan-replay (dir name)
  (john-run (concat-list (john-read (concat-strings dir "/" name ".john")) (list (list 'make 'Code 'Now "replay"))))
  (let ((out ()) (ledger (plan-ledger-path dir name)))
    (and (= 0 ((subr "access" "si>i") ledger 4))
	 (list-do f (read ledger)
	   (if (or (not (= 'world (john-ledger-shape f))) (john-ledger-retired (concat-list (cadr f) (map car (caddr f)))))
	       (push out (cons f f))
	     (let ((t (<john-world>-time *john-world*)) (a (cadr f)))
	       (john-do (car a) (cadr a) (map john-form->value (cddr a)))
	       (push out (cons (and (< t (<john-world>-time *john-world*)) (car (john-serialize-worlds t *john-world*))) f))))))
    (list-reverse! out)))
(define-function plan-ledger-drift (dir name)
  (let ((n 0) (bad ()))
    (list-do e (plan-replay dir name)
      (set n (+ n 1))
      (or bad (equal (car e) (cdr e)) (set bad (cons n e))))
    (and bad (concat-strings (plan-ledger-path dir name) ": ledger " (long->string (car bad)) ": "
			     (symbol->string (cadr (cadr (cddr bad))))
			     (if (cadr bad) " writes what the line doesn't hold" " takes no step now")
			     "; ./eval notes/plan/replay.l write rewrites the ledger"))))
