;;; ksworld-run.l -- a KSWorld document, run headless: ./eval ksworld-run.l DOC.pp [TICKS]
;;;
;;; (ksworld-run path ticks) answers the report as an alist, the loaded objects under table.
;;; Loads the document (ksworld-pp.l), reads every stream's code, and runs the evaluator (kscript.l) for TICKS logical
;;; times (default 3), each stream on its own so one that fails doesn't stop the rest.  Then it says what happened:
;;;   document PATH
;;;   objects N, streams S: setters A, dormant B, code C
;;;   code read R, unreadable U
;;;   ticks T: evaluations E, fired F, failed X     (X counts unreadable streams too, each stream once)
;;;   failed: COUNT MESSAGE        (one line each, streams that failed with that message, most first)
;;; A setter's code is a printout of the value it starts with, which the document also holds, so it isn't read.
(require "kscript.l")
(require "recover.l")
(require "ksworld-events.l")

(define-function ksw-assoc (key alist) (let ((r ())) (list-do p alist (and (not r) (equal (car p) key) (set r p))) r))
(define-function ksw-count (table key)		; table is (list . alist): bump key's count
  (let ((entry (ksw-assoc key (car table))))
    (if entry (set-cdr entry (+ 1 (cdr entry))) (set-car table (cons (cons key 1) (car table))))))
(define-function ksw-text (x) (cond ((string? x) x) ((symbol? x) (symbol->string x)) ((long? x) (long->string x)) (else "?")))
(define-function ksw-message (condition) (apply concat-strings (map ksw-text (cdr condition))))
(define-function ksw-sorted (alist)		; most first
  (let ((out ()) (rest alist))
    (while rest
      (let ((best (car rest)))
	(list-do e rest (and (> (cdr e) (cdr best)) (set best e)))
	(push out best)
	(let ((left ())) (list-do e rest (or (= e best) (push left e))) (set rest left))))
    (list-reverse! out)))

(define-function ksworld-run (path ticks)
  (let* ((doc (ksworld-load path)) (table (cadr doc))
	 (objects 0) (streams ()) (setters 0) (dormant 0) (code ())
	 (unreadable 0) (evaluations 0) (fired 0)
	 (failed (list ())) (failed-streams ()))
    (array-do o table	; every object the document numbered, its Arrays (Maru arrays) among them
      (when o
	(set objects (+ objects 1))
	(and (ks-object? o) (ks-stream? o) (push streams o))))
    (list-do s streams
      (cond ((= (ks-attr s ':__type__) "setter") (set setters (+ setters 1)))
	    ((= (ks-attr s ':__dormant__) "true") (set dormant (+ dormant 1)))
	    (else (push code s))))
    (let ((ev (ks-evaluator-new)) (read ()))
      (list-do s code
	(ks-stream-ast s)
	(if (not (ks-attr s ':__unreadable__))
	    (push read s)
	  (ksw-count failed (concat-string "unreadable: " (ksw-message (ks-attr s ':__unreadable__))))
	  (set unreadable (+ unreadable 1))
	  (push failed-streams s)))
      (set (<ks-evaluator>-streams ev) read)
      (let ((plain ks-evaluate-stream))
	(set ks-evaluate-stream
	     (lambda (s ast home)
	       (set evaluations (+ evaluations 1))
	       (try (let () (plain s ast home) (and (ks-fired? s) (set fired (+ fired 1))))
		    (lambda (c)
		      (unless (memq s failed-streams)	; a stream counts once, at its first failure
			(push failed-streams s)
			(ksw-count failed (ksw-message c)))))))
	(unwind-protect (for (t 0 ticks) (ks-sort-and-evaluate-at ev t))
	  (set ks-evaluate-stream plain)))
      (list (cons 'document path) (cons 'root (car doc)) (cons 'evaluator ev) (cons 'time ticks) (cons 'objects objects) (cons 'streams (list-length streams)) (cons 'setters setters)
	    (cons 'dormant dormant) (cons 'code (list-length code)) (cons 'read (list-length read)) (cons 'unreadable unreadable)
	    (cons 'ticks ticks) (cons 'evaluations evaluations) (cons 'fired fired) (cons 'failed (list-length failed-streams))
	    (cons 'failures (ksw-sorted (car failed))) (cons 'table table)))))

(define-function ksworld-report (r)
  (let ((at (lambda (k) (cdr (assq k r)))))
    (println "document " (at 'document))
    (println "objects " (at 'objects) ", streams " (at 'streams) ": setters " (at 'setters) ", dormant " (at 'dormant) ", code " (at 'code))
    (println "code read " (at 'read) ", unreadable " (at 'unreadable))
    (println "ticks " (at 'ticks) ": evaluations " (at 'evaluations) ", fired " (at 'fired) ", failed " (at 'failed))
    (list-do f (at 'failures) (println "failed: " (cdr f) " " (car f)))))

(when *arguments*
  (let* ((path (next-argument))
	 (ticks (if *arguments* (string->long (next-argument)) 3)))
    (ksworld-report (ksworld-run path ticks))))
