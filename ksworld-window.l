;;; ksworld-window.l -- a running KSWorld document in an SDL3 window: (ksworld-window session gezira width height) opens it,
;;; and each (ksworld-window-step win) reads SDL's events, hands the mouse's to the document (ksworld-pointer: a press,
;;; a motion, a release, button 1, window points being document points), and when one reached a box, or for the first
;;; frame, draws the document again with the Gezira and shows what it painted.  Escape or closing the window stops it.
;;; The document runs as it runs on its own: logical time is the window's clock in milliseconds from when it started
;;; (SDL_GetTicks, or any clock put in its clock field), each step evaluates what is due then (a timer, say), and a step
;;; in which something fired draws a frame.
;;; A Gezira that paints answers gezira-image (its width x height ARGB pixels, in C memory) and gezira-clear, beside
;;; gezira-fill-path; which Gezira is the caller's, as for ksworld-render.
(require "ksworld-run.l")	; its stream-failure messages
(require "ksworld-events.l")
(require "sdl3.l")

(require "gezira.l")

(define-structure <ksworld-window> (session gezira sdl width height frames running clock origin start failed))

(define-function ksworld-window (session gezira width height)
  (new <ksworld-window> session gezira (sdl3-open "KSWorld" width height) width height 0 (quote t) sdl3-ticks () () ()))

;; a stream that fails doesn't stop the document, as in ksworld-run: it's reported once, and the rest run on
(define-function ksworld-window-guarded (win thunk)
  (let ((plain ks-evaluate-stream))
    (set ks-evaluate-stream
	 (lambda (s ast home)
	   (try (plain s ast home)
		(lambda (c)
		  (unless (memq s (<ksworld-window>-failed win))
		    (set (<ksworld-window>-failed win) (cons s (<ksworld-window>-failed win)))
		    (println "ksworld: a stream failed: " (ksw-message c)))))))
    (unwind-protect (thunk) (set ks-evaluate-stream plain))))

;; the clock's reading now becomes the session's next logical time; the first step starts it if nothing has
(define-function ksworld-window-start (win)
  (set (<ksworld-window>-origin win) ((<ksworld-window>-clock win)))
  (set (<ksworld-window>-start win) (<ksworld-session>-time (<ksworld-window>-session win))))
(define-function ksworld-window-now (win)
  (+ (<ksworld-window>-start win) (- ((<ksworld-window>-clock win)) (<ksworld-window>-origin win))))

;; the document's streams due at the clock's time, if it has moved on since the last evaluation; answers whether any fired
(define-function ksworld-window-tick (win)
  (let* ((s (<ksworld-window>-session win)) (now (ksworld-window-now win)) (ev (<ksworld-session>-evaluator s)))
    (when (>= now (<ksworld-session>-time s))
      (ks-sort-and-evaluate-at ev now)
      (set (<ksworld-session>-time s) (+ 1 now))
      (ks-any-fired? (<ks-evaluator>-streams ev)))))

(define-function ksworld-window-draw (win)
  (let ((g (<ksworld-window>-gezira win)))
    (gezira-clear g)
    (ksworld-render (<ksworld-session>-root (<ksworld-window>-session win)) g (<ksworld-window>-width win) (<ksworld-window>-height win))
    (sdl3-show (<ksworld-window>-sdl win) (gezira-image g))
    (set (<ksworld-window>-frames win) (+ 1 (<ksworld-window>-frames win)))))

;; every event waiting, then a frame if one changed anything; answers whether the window is still running
(define-function ksworld-window-step-guarded (win)
  (or (<ksworld-window>-origin win) (ksworld-window-start win))
  (let ((dirty (= 0 (<ksworld-window>-frames win))) (e ()) (s (<ksworld-window>-session win)))
    ;; an event happens now: no earlier than the clock says
    (set (<ksworld-session>-time s) (max (<ksworld-session>-time s) (ksworld-window-now win)))
    (while (and (<ksworld-window>-running win) (set e (sdl3-poll)))
      (let ((kind (car e)))
	(cond ((or (= kind 'quit) (and (= kind 'key) (= (cadr e) SDLK_ESCAPE)))
	       (set (<ksworld-window>-running win) ()))
	      ((and (member? kind '(down up)) (not (= 1 (cadddr e)))))	; other buttons: nothing listens yet
	      ((member? kind '(down up move))
	       (and (ksworld-pointer (<ksworld-window>-session win) kind (ks-point (cadr e) (caddr e)))
		    (set dirty 1))))))
    (and (ksworld-window-tick win) (set dirty 1))
    (and dirty (<ksworld-window>-running win) (ksworld-window-draw win))
    (<ksworld-window>-running win)))

(define-function ksworld-window-step (win) (ksworld-window-guarded win (lambda () (ksworld-window-step-guarded win))))

(define-function ksworld-window-close (win) (sdl3-close (<ksworld-window>-sdl win)))
