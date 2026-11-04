;;; catch.l: non-local exit, in native code and Maru.  (catch tag thunk) answers thunk's value, or the value thrown to
;;; tag; (throw tag value) unwinds to it.  (unwind-protect body cleanup...) runs cleanup however body ends.
;;;
;;; %catch saves what C expects preserved, the collector's root stack and the evaluator's call depth, in a frame on the stack, and applies its
;;; arguments; %throw drops the stack to the newest frame, restores from it and returns from %catch.  A throw stops at
;;; each catch, which throws again if the tag isn't its own, so a cleanup between the two runs on the way.
(require "osdefs.k")
(require "asm-table.l")
(require "asm-arm64.l")
(require "asm-x86.l")
(require "code-region.l")
(require "stub.l")

(define catch-top ((subr "malloc" "l>p") 8))
(stub-set-word-at catch-top 0 0)
(define catch-roots (stub-symbol "GC_stack_roots"))
(define catch-trace (stub-symbol "traceDepth"))		; how deep the evaluator's record of its calls is

(define %catch
  (stub-primitive
   `((save)
     (constant s0 ,catch-top) (load s1 s0 0)
     (constant s2 ,catch-roots) (load s3 s2 0)
     (push2 s1 s3)
     (constant s2 ,catch-trace) (load s3 s2 0)
     (push2 s3 s3)
     (sp-to s1) (store s1 s0 0)
     (constant s4 ,stub-apply) (call s4)
     (constant s0 ,catch-top)
     (pop2 s1 s3)
     (pop2 s1 s3) (store s1 s0 0)
     (restore)
     (return))))
(define %throw
  (stub-primitive
   `((constant s0 ,catch-top) (load s1 s0 0)
     (sp-from s1)
     (pop2 s1 s3)
     (constant s2 ,catch-trace) (store s3 s2 0)
     (pop2 s1 s3) (store s1 s0 0)
     (constant s2 ,catch-roots) (store s3 s2 0)
     (result-from-arg)
     (restore)
     (return))))

(define *catch-tags* ())	; the tags of the catches now running, newest first
(define *handlers* ())		; recover.l's handlers, as they stood when each catch began
(define *thrown* ())		; (tag . value), while a throw is on its way

(define-function throw (tag value)
  (or (member? tag *catch-tags*) (error "throw: no catch for " tag))
  (set *thrown* (cons tag value))
  (%throw))

(define-function catch (tag thunk)
  (let* ((tags *catch-tags*)
	 (handlers *handlers*)
	 (_ (set *catch-tags* (cons tag tags)))
	 (answer (%catch thunk ())))
    (set *catch-tags* tags)
    (set *handlers* handlers)
    (if *thrown*
	(if (= tag (car *thrown*))
	    (let ((value (cdr *thrown*)))
	      (set *thrown* ())
	      value)
	  (%throw))
      answer)))

;; a catch no thrower can name, so a throw stops here on its way, the cleanup runs, and it goes on
(define-function unwind-protect-call (body cleanup)
  (let* ((tags *catch-tags*)
	 (handlers *handlers*)
	 (_ (set *catch-tags* (cons (cons 'unwind-protect ()) tags)))	; a tag no thrower can name
	 (answer (%catch body ())))
    (set *catch-tags* tags)
    (set *handlers* handlers)
    (let ((thrown *thrown*))
      (set *thrown* ())
      (cleanup)
      (and thrown (let () (set *thrown* thrown) (%throw)))
      answer)))
(define-form unwind-protect (body . cleanup)
  `(unwind-protect-call (lambda () ,body) (lambda () ,@cleanup)))
