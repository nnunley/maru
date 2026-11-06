;;; sdl3.k opens a window on SDL's dummy video driver (check.l sets SDL_VIDEO_DRIVER), draws a known
;;; frame, reads the frame back and compares pixels, then round-trips synthetic mouse and key events.
;;; check.l concatenates sdl3.osdefs.k, sdl3.k and this file, and links SDL3.  Prints "sdl3 ok".

(define (printf (int char * ...) *) (extern printf))
(define (exit   (void int) *)	    (extern exit))

(define-constant W 64)
(define-constant H 48)

;; the colour of an ARGB pixel, without its alpha byte
(define-function rgb long ((pixel long))
  (return (& pixel 16777215)))

;; the frame's ARGB pixel at (x, y): opaque, red rising across x, green down y, blue 128
(define-function frame-pixel long ((x int) (y int))
  (return (| (| (<< (cast 255 long) 24) (<< (cast (% (* x 4) 256) long) 16))
	     (| (<< (cast (% (* y 4) 256) long) 8) 128))))

(define-function fill-frame void ((pixels int32 *))
  (let (((y int) 0))
    (while (< y H)
      (let (((x int) 0))
	(while (< x W)
	  (set (indir pixels (+ (* y W) x)) (cast (frame-pixel x y) int32))
	  (set x (+ x 1))))
      (set y (+ y 1)))))

(define-function fail void ((what char *))
  (printf "FAIL %s\n" what)
  (exit 1))

(define-form expect (what test)
  `(if (not ,test) (fail ,what)))

;; the next event of kind WANTED, skipping the window's own events before it.  SDL 3.4 (dummy driver) can
;; hold a pushed event back from the first poll after a mouse button, so this polls up to 32 times; kind 0 if
;; none of them is WANTED.
(define-function next-of-kind (struct <sdl3-event>) ((wanted int))
  (let (((ev struct <sdl3-event>) (sdl3-poll)) ((polls int) 1))
    (while (and (!= wanted (member ev kind)) (< polls 32))
      (set ev (sdl3-poll))
      (set polls (+ polls 1)))
    (return ev)))

(define-function main int ((argc int) (argv char * *))
  (let (((win struct <sdl3-window>) (sdl3-open "sdl3 window" W H)))
    (expect "the window opens" (!= 0 (cast (member win window) long)))
    (let (((pixels int32 *) (cast (malloc (cast (* 4 (* W H)) long)) int32 *)))
      (fill-frame pixels)
      (sdl3-draw win (cast pixels void *))
      (let (((surface void *) (sdl3-read win)))
	(expect "the frame reads back as a surface" (!= 0 (cast surface long)))
	;; the renderer reads back XRGB8888 (no alpha byte), so the colours are compared without the top byte
	(expect "the surface is XRGB8888" (= SDL_PIXELFORMAT_XRGB8888 (at surface surface_format (int32))))
	(expect "pixel (0, 0)" (= (rgb (frame-pixel 0 0)) (rgb (sdl3-pixel surface 0 0))))
	(expect "pixel (10, 20)" (= (rgb (frame-pixel 10 20)) (rgb (sdl3-pixel surface 10 20))))
	(expect "pixel (33, 7)" (= (rgb (frame-pixel 33 7)) (rgb (sdl3-pixel surface 33 7))))
	(expect "pixel (63, 47)" (= (rgb (frame-pixel 63 47)) (rgb (sdl3-pixel surface 63 47))))
	(sdl3-free-surface surface))
      (free (cast pixels void *)))
    (sdl3-present win)

    (sdl3-push-button SDL_EVENT_MOUSE_BUTTON_DOWN 30 40 1)
    (let (((ev struct <sdl3-event>) (next-of-kind SDL_EVENT_MOUSE_BUTTON_DOWN)))
      (expect "a mouse button down at (30, 40) with button 1"
	      (and (= 30 (member ev x)) (= 40 (member ev y)) (= 1 (member ev button)))))

    (sdl3-push-motion 50 60)
    (let (((ev struct <sdl3-event>) (next-of-kind SDL_EVENT_MOUSE_MOTION)))
      (expect "a mouse motion to (50, 60)" (and (= 50 (member ev x)) (= 60 (member ev y)))))

    (sdl3-push-key SDLK_ESCAPE)
    (let (((ev struct <sdl3-event>) (next-of-kind SDL_EVENT_KEY_DOWN)))
      (expect "a key down for escape" (= SDLK_ESCAPE (member ev key))))

    (sdl3-close win))
  (printf "sdl3 ok\n")
  (return 0))
