;;; ksworld-window.l -- a running KSWorld document in an SDL3 window: (ksworld-window session gezira width height) opens it,
;;; and each (ksworld-window-step win) reads SDL's events, hands the mouse's to the document (ksworld-pointer: a press,
;;; a motion, a release, button 1, window points being document points), and when one reached a box, or for the first
;;; frame, draws the document again with the Gezira and shows what it painted.  Escape or closing the window stops it.
;;; A Gezira that paints answers gezira-image (its width x height ARGB pixels, in C memory) and gezira-clear, beside
;;; gezira-fill-path; which Gezira is the caller's, as for ksworld-render.
(require "ksworld-events.l")
(require "sdl3.l")

(define-selector gezira-image (gezira) (error "ksworld-window: " gezira " paints no image"))
(define-selector gezira-clear (gezira) (error "ksworld-window: " gezira " paints no image"))

(define-structure <ksworld-window> (session gezira sdl width height frames running))

(define-function ksworld-window (session gezira width height)
  (new <ksworld-window> session gezira (sdl3-open "KSWorld" width height) width height 0 (quote t)))

(define-function ksworld-window-draw (win)
  (let ((g (<ksworld-window>-gezira win)))
    (gezira-clear g)
    (ksworld-render (<ksworld-session>-root (<ksworld-window>-session win)) g (<ksworld-window>-width win) (<ksworld-window>-height win))
    (sdl3-show (<ksworld-window>-sdl win) (gezira-image g))
    (set (<ksworld-window>-frames win) (+ 1 (<ksworld-window>-frames win)))))

;; every event waiting, then a frame if one changed anything; answers whether the window is still running
(define-function ksworld-window-step (win)
  (let ((dirty (= 0 (<ksworld-window>-frames win))) (e ()))
    (while (and (<ksworld-window>-running win) (set e (sdl3-poll)))
      (let ((kind (car e)))
	(cond ((or (= kind 'quit) (and (= kind 'key) (= (cadr e) SDLK_ESCAPE)))
	       (set (<ksworld-window>-running win) ()))
	      ((and (member? kind '(down up)) (not (= 1 (cadddr e)))))	; other buttons: nothing listens yet
	      ((member? kind '(down up move))
	       (and (ksworld-pointer (<ksworld-window>-session win) kind (ks-point (cadr e) (caddr e)))
		    (set dirty 1))))))
    (and dirty (<ksworld-window>-running win) (ksworld-window-draw win))
    (<ksworld-window>-running win)))

(define-function ksworld-window-close (win) (sdl3-close (<ksworld-window>-sdl win)))
