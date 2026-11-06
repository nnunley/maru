;;; A document running in a window as it runs on its own (ksworld-window.l): after its start-up evaluation, logical time
;;; is the window's clock in milliseconds, each step evaluates what is due then, and a frame is drawn when something
;;; fired.  Our fixture check/ksworld/tiny.pp counts timerE(1)'s ticks: with the clock held still nothing runs or draws, and
;;; when it moves on the timer fires once however many milliseconds went by.  Needs SDL3 (else SKIP).
(require "ksworld-run.l")
(require "ksworld-window.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))

(define-structure <gezira-counting> (paths image))
(define-method gezira-fill-path <gezira-counting> (m width height paint floats count) (set self.paths (+ 1 self.paths)))
(define-method gezira-image <gezira-counting> () self.image)
(define-method gezira-clear <gezira-counting> () (set self.paths 0))

(if (not (sdl3-library))
    (println "SKIP ksworld clock: no SDL3 library in " *sdl3-libraries*)
  (let ()
  (let* ((r (ksworld-run "check/ksworld/tiny.pp" 1))	; the start-up evaluation, time 0, and no more
	 (s (ksworld-session r))
	 (count (ks-slot (cdr (assq 'root r)) 'count))
	 (now 0)
	 (win (ksworld-window s (new <gezira-counting> 0 ((subr "calloc" "ll>p") (* 64 48) 4)) 64 48)))
    (expect "the count after start-up" (ks-stream-curr count) 0)
    (set (<ksworld-window>-clock win) (lambda () now))
    (ksworld-window-start win)
    (ksworld-window-step win)
    (expect "the first frame: the timer fired once" (list (<ksworld-window>-frames win) (ks-stream-curr count)) '(1 1))
    (ksworld-window-step win)
    (expect "the clock held still: nothing ran, nothing drawn" (list (<ksworld-window>-frames win) (ks-stream-curr count)) '(1 1))
    (set now 7)
    (ksworld-window-step win)
    (expect "seven milliseconds on: one firing, one frame" (list (<ksworld-window>-frames win) (ks-stream-curr count)) '(2 2))
    (set now 8)
    (ksworld-window-step win)
    (expect "one more millisecond" (list (<ksworld-window>-frames win) (ks-stream-curr count)) '(3 3))
    (expect "the fixture's failing stream, reported once over four steps" (list-length (<ksworld-window>-failed win)) 1)
    ;; events in a burst, the clock held still: each happens at its own time, but within this millisecond, so they
    ;; neither run ahead of the clock nor fire the timer (a press on the root box, given an extent and a buttonDown)
    (let ((root (<ksworld-session>-root s)))
      (ks-set-slot root 'extent (ks-point 64 48))
      (ks-set-slot root 'buttonDown (ks-make-stream root "exprE" "nil" ()))
      (for (i 0 50) (sdl3-push '(down 5 5 1)))
      (ksworld-window-step win)
      (expect "fifty presses with the clock held: the timer unfired" (ks-stream-curr count) 3)
      (expect "and document time within the clock's millisecond" (< (<ksworld-session>-time s) 10) 't))
    (ksworld-window-close win))
  ;; a timer fires when time passes a multiple of its step, though no evaluation lands on one: check/ksworld/timer.pp's
  ;; timerE(1000) and timerE(2.5), the clock read at milliseconds that skip their multiples (document time is the clock
  ;; plus the start-up evaluation's tick)
  (let* ((r (ksworld-run "check/ksworld/timer.pp" 1))
	 (root (cdr (assq 'root r)))
	 (now 0)
	 (win (ksworld-window (ksworld-session r) (new <gezira-counting> 0 ((subr "calloc" "ll>p") (* 64 48) 4)) 64 48)))
    (set (<ksworld-window>-clock win) (lambda () now))
    (ksworld-window-start win)
    (list-do t '(1 3 6) (set now t) (ksworld-window-step win))	; document times 2, 4, 7: past 2.5 and past 5
    (expect "timerE(2.5) at 2, 4 and 7" (ks-stream-curr (ks-slot root 'halfCount)) 2)
    (list-do t '(15 32 49 1000 1015 2000) (set now t) (ksworld-window-step win))	; 16 … 1001 … 2001
    (expect "timerE(1000) past 1000 and past 2000" (ks-stream-curr (ks-slot root 'slowCount)) 2)
    (ksworld-window-close win))
  (println (if ok "ksworld clock ok" "ksworld clock FAILED"))))
