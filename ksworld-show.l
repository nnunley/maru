;;; ksworld-show.l -- a KSWorld document in a real SDL3 window: ./eval ksworld-show.l DOC.pp, with DOC.pp the document's
;;; index.pp (the dbjr documents' KSWorld.ks/index.pp). The document is evaluated once, as it starts, and then runs as
;;; it runs on its own: the window draws it through a painting Gezira (gezira-maru.l), its clock is the document's time,
;;; and it steps until Escape or closing the window. Presses, drags and releases
;;; reach the document as ksworld-window.l sends them. Needs SDL3 and the fonts the document names (*ks-font-path*,
;;; ksworld-run.l's search path, plus a fonts directory given in KS_FONTS when it isn't in the document's own place).
(define doc (car *arguments*))
(set *arguments* ())			; ksworld-run.l runs its own main on any arguments
(require "ksworld-run.l")
(require "ksworld-window.l")
(require "gezira-maru.l")
(require "check/temp.l")
(define usleep (subr "usleep" "i>i"))

(cond
  ((not doc) (println "usage: ./eval ksworld-show.l DOC.pp"))
  ((not (sdl3-library)) (println "no SDL3 library in " *sdl3-libraries*))
  (else
   (let ((fonts (env-var "KS_FONTS")))
     (if fonts (set *ks-font-path* (cons fonts *ks-font-path*))))
   (let* ((r (ksworld-run doc 1))	; the start-up evaluation, time 0
	  (s (ksworld-session r))
	  (g (gezira-maru 1024 768 4))
	  (win (ksworld-window s g 1024 768)))
     (while (ksworld-window-step win)
       (usleep 16000))
     (ksworld-window-close win)
     (gezira-stop g)
     (println "ksworld show: closed after " (<ksworld-window>-frames win) " frames"))))
