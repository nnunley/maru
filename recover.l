;;; recover.l: a running system survives its errors, and they leave its state as it was.
;;;
;;;   (with-handler handler thunk)  runs thunk; a condition signalled in it calls handler where it happened, with the
;;;                                 stack intact.  Returning declines; to go on from elsewhere, a handler throws.
;;;   (signal condition)            offers it to each handler, newest first, and returns if all decline
;;;   (set-heap-limit bytes)        bounds what's in use, 0 for no bound.  Reaching it collects, and if that's not enough
;;;                                 signals (fatal "out of memory") with a reserve beyond the limit for handlers to run in.
;;;                                 If none takes it, or it happens again before a collection has made a reserve's room
;;;                                 under the limit, the program exits.
;;;   (try body handler)            body in a world (Warth, "Worlds", 3.1): if it ends normally its writes stay.  If it
;;;                                 fails, or a throw leaves it, they're undone, and on a failure handler gets the condition.
;;;
;;; error and the evaluators' own fatal errors signal (error . args) and (fatal message).  With no handler they end the
;;; program as they always did.  Worlds cover Maru's heap: files, the screen, what C holds and raw memory aren't undone,
;;; so those need unwind-protect.  A definition is undone like a write; on eval, a name new in the world stays bound.  A value that leaves a failed world keeps what it was made with: writes into it there
;;; are undone like any others.
(require "catch.l")

(define-function with-handler (handler thunk)
  (let ((saved *handlers*))
    (set *handlers* (cons handler saved))
    (let ((answer (thunk)))
      (set *handlers* saved)
      answer)))
(define-function signal (condition)
  (let ((saved *handlers*))
    (while *handlers*
      (let ((handler (car *handlers*)))
	(set *handlers* (cdr *handlers*))	; a handler isn't its own handler
	(handler condition)))
    (set *handlers* saved)))

(define recover-default-error error)
(set error (lambda args
	     (signal (cons 'error args))
	     (apply recover-default-error args)))
;; C's fatal has already printed its message and calls this before exiting; a throw from here carries on instead
(define recover-message (stub-symbol "maru_fatal_message"))
;; made with logging paused: a string is filled in by writes, and these must outlast the failing world
(define-function recover-fatal-text ()
  (let ((bytes ()) (n 0) (_ (undo-pause)))
    (while (< 0 (byte-at recover-message n))
      (push bytes (byte-at recover-message n))
      (set n (+ n 1)))
    (let ((text (list->string (list-reverse! bytes))))
      (undo-resume)
      text)))
(define recover-default-backtrace *backtrace*)
(set *backtrace* (lambda (stack depth)
		   (signal (list 'fatal (recover-fatal-text)))
		   (and recover-default-backtrace (recover-default-backtrace stack depth))))

;; one store: writing it a byte at a time from here would allocate, against a limit that's only partly written
(define set-heap-limit (subr "GC_set_heap_limit" "l"))

(define-function try-call (body handler)
  (let* ((mark (undo-begin))
	 (tag (cons 'try ()))
	 (tags *catch-tags*)
	 (handlers *handlers*)
	 (_ (set *catch-tags* (cons tag tags)))
	 (outcome (%catch (lambda ()
			    (with-handler (lambda (condition) (throw tag (cons 'failed condition)))
					  (lambda () (cons 'ended (body)))))
			  ())))
    (if *thrown*
	(let ((thrown *thrown*))
	  (set *thrown* ())
	  (undo-rollback mark)
	  (set *catch-tags* tags)
	  (set *handlers* handlers)
	  (if (= tag (car thrown))
	      (handler (cddr thrown))
	    (set *thrown* thrown)
	    (%throw)))
      (undo-commit mark)
      (set *catch-tags* tags)
      (set *handlers* handlers)
      (cdr outcome))))
(define-form try (body handler) `(try-call (lambda () ,body) ,handler))
