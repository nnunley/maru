;;; KSWorld.ks in an SDL3 window (ksworld-window.l), on SDL's dummy video driver: the first step draws it; a press, a drag
;;; and a release put on SDL's queue as the window system would reach the title's text through ksworld-pointer, each
;;; drawing a frame; a quit stops it.  The Gezira here counts the paths it's asked to fill and paints nothing: the window
;;; shows whatever its Gezira paints.  Needs SDL3 (else SKIP) and the dbjr documents (MARU_DBJR).
(require "ksworld-run.l")
(require "ksworld-window.l")
(require "check/temp.l")
(define dir (env-var "MARU_DBJR"))
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))

(define-structure <gezira-counting> (paths image))
(define-method gezira-fill-path <gezira-counting> (m width height paint floats count) (set self.paths (+ 1 self.paths)))
(define-method gezira-image <gezira-counting> () self.image)
(define-method gezira-clear <gezira-counting> () (set self.paths 0))

(cond
  ((not (sdl3-library)) (println "SKIP ksworld window: no SDL3 library in " *sdl3-libraries*))
  ((not dir) (println "KSWorld.ks's window: skipped, MARU_DBJR names no dbjr documents"))
  (else
   (set *ks-font-path* (cons (concat-string dir "/fonts") *ks-font-path*))
   (let* ((r (ksworld-run (concat-string dir "/KSWorld.ks/index.pp") 3))
	  (s (ksworld-session r))
	  (g (new <gezira-counting> 0 ((subr "calloc" "ll>p") (* 1024 768) 4)))
	  (win (ksworld-window s g 1024 768))
	  (box (array-at (cdr (assq 'table r)) 204))	; the title, as check/ksworld-mouse.l presses it
	  (layout (ks-slot box 'handler))
	  (m (let ((f ())) (list-do bm (ks-boxes-in (<ksworld-session>-root s)) (and (= box (car bm)) (set f (cdr bm)))) f))
	  (at (lambda (x y) (let ((p (ks-apply-matrix m (ks-point x y)))) (list (<ks-point>-x p) (<ks-point>-y p))))))
     (expect "the first step draws the document" (list (ksworld-window-step win) (<ksworld-window>-frames win) (<gezira-counting>-paths g))
	     '(t 1 937))
     (expect "a step with nothing waiting draws nothing" (list (ksworld-window-step win) (<ksworld-window>-frames win)) '(t 1))
     (sdl3-push (cons 'down (concat-list (at 200 13) '(1))))
     (ksworld-window-step win)
     (expect "a press from SDL puts the caret, and a frame shows it"
	     (list (ks-selection-gaps layout) (<ksworld-window>-frames win) (<gezira-counting>-paths g)) '((5 . 5) 2 938))
     (sdl3-push (cons 'move (at 300 13)))
     (ksworld-window-step win)
     (expect "a drag selects, and a frame shows it" (list (ks-selection-gaps layout) (<ksworld-window>-frames win)) '((5 . 18) 3))
     (sdl3-push (cons 'up (concat-list (at 300 13) '(1))))
     (ksworld-window-step win)
     (expect "a release lets go" (<ks-hand>-focus (<ksworld-session>-hand s)) 'nil)
     (sdl3-push '(move 10 10))
     (expect "so a motion after it draws nothing" (list (ksworld-window-step win) (<ksworld-window>-frames win)) '(t 4))
     (sdl3-push '(quit))
     (expect "a quit stops it" (ksworld-window-step win) ())
     (ksworld-window-close win))))

(println (if ok "ksworld window ok" "ksworld window FAILED"))
