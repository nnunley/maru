;;; sdl3.l -- SDL3 for untyped Maru, as sdl3.k is for typed: a window that shows a frame of uint32 ARGB pixels from C memory,
;;; and the mouse, key and quit events it reads, as lists.  The constants and offsets are sdl3.osdefs.k's, which make
;;; measures from this machine's SDL3 headers; the library is the first of *sdl3-libraries* that opens.
(define-form define-constant (name value) `(define ,name ,value))
(load "sdl3.osdefs.k")

(define *sdl3-libraries* '("/opt/homebrew/lib/libSDL3.dylib" "/usr/local/lib/libSDL3.dylib" "libSDL3.dylib"
			   "libSDL3.so.0" "libSDL3.so"))
(define sdl3-dlopen (subr "dlopen" "si>p"))
(define-function sdl3-library ()
  (let ((found ()))
    (list-do path *sdl3-libraries*
      (or found (= 0 (sdl3-dlopen path 9)) (set found path)))	; RTLD_LAZY | RTLD_GLOBAL, so subr finds its functions
    found))

(define-structure <sdl3-window> (window renderer texture width height))
(define sdl3-functions ())
(define-function sdl3-bind ()
  (or sdl3-functions
      (set sdl3-functions
	   (list (cons 'init (subr "SDL_Init" "i>i"))
		 (cons 'create-window (subr "SDL_CreateWindow" "siil>p"))
		 (cons 'create-renderer (subr "SDL_CreateRenderer" "pl>p"))
		 (cons 'create-texture (subr "SDL_CreateTexture" "piiii>p"))
		 (cons 'update-texture (subr "SDL_UpdateTexture" "plpi>i"))
		 (cons 'render-texture (subr "SDL_RenderTexture" "ppll>i"))
		 (cons 'present (subr "SDL_RenderPresent" "p>i"))
		 (cons 'poll (subr "SDL_PollEvent" "p>i"))
		 (cons 'push (subr "SDL_PushEvent" "p>i"))
		 (cons 'ticks (subr "SDL_GetTicks" ">l"))
		 (cons 'destroy-window (subr "SDL_DestroyWindow" "p"))
		 (cons 'quit (subr "SDL_Quit" ""))))))
(define-function sdl3 (name) (cdr (assq name (sdl3-bind))))
(define-function sdl3-ticks () ((sdl3 'ticks)))	; milliseconds since SDL started

(define-function sdl3-open (title width height)
  (or (sdl3-library) (error "sdl3: no SDL3 library in " *sdl3-libraries*))
  (or (= 1 ((sdl3 'init) SDL_INIT_VIDEO)) (error "sdl3: SDL_Init failed"))
  (let* ((w ((sdl3 'create-window) title width height 0))
	 (r ((sdl3 'create-renderer) w 0))
	 (t ((sdl3 'create-texture) r SDL_PIXELFORMAT_ARGB8888 SDL_TEXTUREACCESS_STREAMING width height)))
    (and (= 0 w) (error "sdl3: no window"))
    (and (= 0 r) (error "sdl3: no renderer"))
    (new <sdl3-window> w r t width height)))

;; show width x height ARGB pixels, a row every width * 4 bytes
(define-function sdl3-show (win pixels)
  ((sdl3 'update-texture) (<sdl3-window>-texture win) 0 pixels (* 4 (<sdl3-window>-width win)))
  ((sdl3 'render-texture) (<sdl3-window>-renderer win) (<sdl3-window>-texture win) 0 0)
  ((sdl3 'present) (<sdl3-window>-renderer win)))

(define-function sdl3-close (win)
  ((sdl3 'destroy-window) (<sdl3-window>-window win))
  ((sdl3 'quit)))

(define-function sdl3-u16 (d at) (+ (byte-at d at) (<< (byte-at d (+ at 1)) 8)))
(define-function sdl3-u32 (d at) (+ (sdl3-u16 d at) (<< (sdl3-u16 d (+ at 2)) 16)))

;; the next event, or (): (down x y button), (up x y button), (move x y), (key code) or (quit); others are (other type)
(define-function sdl3-poll ()
  (let ((e (data event_size)))
    (and (not (= 0 ((sdl3 'poll) e)))
	 (let ((type (sdl3-u32 e event_type)))
	   (cond ((or (= type SDL_EVENT_MOUSE_BUTTON_DOWN) (= type SDL_EVENT_MOUSE_BUTTON_UP))
		  (list (if (= type SDL_EVENT_MOUSE_BUTTON_DOWN) 'down 'up)
			(float-at e (/ mouse_button_x 4)) (float-at e (/ mouse_button_y 4)) (byte-at e mouse_button_button)))
		 ((= type SDL_EVENT_MOUSE_MOTION) (list 'move (float-at e (/ mouse_motion_x 4)) (float-at e (/ mouse_motion_y 4))))
		 ((= type SDL_EVENT_KEY_DOWN) (list 'key (sdl3-u32 e keyboard_key)))
		 ((= type SDL_EVENT_QUIT) (list 'quit))
		 (else (list 'other type)))))))

;; put an event on SDL's queue, as the window system would: (down x y button), (up x y button), (move x y) or (quit)
(define-function sdl3-push (event)
  (let ((e (data event_size)) (kind (car event)))
    (let ((type (cdr (assq kind (list (cons 'down SDL_EVENT_MOUSE_BUTTON_DOWN) (cons 'up SDL_EVENT_MOUSE_BUTTON_UP)
				      (cons 'move SDL_EVENT_MOUSE_MOTION) (cons 'quit SDL_EVENT_QUIT))))))
      (for (k 0 4) (set-byte-at e (+ event_type k) (& 255 (>> type (* 8 k)))))
      (cond ((= kind 'quit))
	    ((= kind 'move)
	     (set-float-at e (/ mouse_motion_x 4) (* 1.0 (cadr event)))
	     (set-float-at e (/ mouse_motion_y 4) (* 1.0 (caddr event))))
	    (else
	     (set-float-at e (/ mouse_button_x 4) (* 1.0 (cadr event)))
	     (set-float-at e (/ mouse_button_y 4) (* 1.0 (caddr event)))
	     (set-byte-at e mouse_button_button (cadddr event))
	     (set-byte-at e mouse_button_down (if (= kind 'down) 1 0))))
      (= 1 ((sdl3 'push) e)))))
