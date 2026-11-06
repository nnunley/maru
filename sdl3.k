;;; SDL3 for typed Maru: the externs, and a window that shows a frame of uint32
;;; ARGB pixels and reads events.  Built with sdl3.osdefs.k, which make measures
;;; from SDL3's headers (event and surface offsets, constants).  The generated C
;;; declares these functions itself, so the program is linked with SDL3's library:
;;;
;;;   cc -o prog prog.c $(pkg-config --libs sdl3)
;;;
;;; A frame is drawn into the renderer, read back, and then presented.  The
;;; check (check/sdl3-window.k) runs it on SDL's dummy video driver (SDL_VIDEO_DRIVER=dummy).

;; the C functions, as SDL3 declares them: bool is char, enums and Uint32 are int32
(define (SDL_Init (char int32) *)				(extern SDL_Init))
(define (SDL_Quit (void void) *)				(extern SDL_Quit))
(define (SDL_GetError (char * void) *)				(extern SDL_GetError))
(define (SDL_CreateWindow (void * char * int int int64) *)	(extern SDL_CreateWindow))
(define (SDL_DestroyWindow (void void *) *)			(extern SDL_DestroyWindow))
(define (SDL_CreateRenderer (void * void * char *) *)		(extern SDL_CreateRenderer))
(define (SDL_DestroyRenderer (void void *) *)			(extern SDL_DestroyRenderer))
(define (SDL_CreateTexture (void * void * int32 int int int) *)	(extern SDL_CreateTexture))
(define (SDL_DestroyTexture (void void *) *)			(extern SDL_DestroyTexture))
(define (SDL_UpdateTexture (char void * void * void * int) *)	(extern SDL_UpdateTexture))
(define (SDL_RenderTexture (char void * void * void * void *) *) (extern SDL_RenderTexture))
(define (SDL_RenderPresent (char void *) *)			(extern SDL_RenderPresent))
(define (SDL_RenderReadPixels (void * void * void *) *)		(extern SDL_RenderReadPixels))
(define (SDL_DestroySurface (void void *) *)			(extern SDL_DestroySurface))
(define (SDL_PollEvent (char void *) *)				(extern SDL_PollEvent))
(define (SDL_PushEvent (char void *) *)				(extern SDL_PushEvent))
(define (malloc (void * long) *)				(extern malloc))
(define (calloc (void * long long) *)			(extern calloc))
(define (free (void void *) *)					(extern free))

;; the value of TYPE at BASE plus OFFSET bytes (pointer arithmetic moves by bytes)
(define-form at (base offset type)
  `(indir (cast (+ ,base ,offset) ,@type *) 0))

;; store VALUE as TYPE at BASE plus OFFSET bytes
(define-form put (base offset type value)
  `(set (indir (cast (+ ,base ,offset) ,@type *) 0) ,value))

(define-struct <sdl3-window> ((window void *) (renderer void *) (texture void *) (width int) (height int)))

;; one event, read by sdl3-poll: kind is SDL_EVENT_* (0 when the queue is empty)
(define-struct <sdl3-event> ((kind int) (x int) (y int) (button int) (key int)))

;; A window of WIDTH x HEIGHT pixels with a streaming ARGB8888 texture.  Its
;; window is null if SDL couldn't start or open one; sdl3-error says why.
(define-function sdl3-open (struct <sdl3-window>) ((title char *) (width int) (height int))
  (let (((win struct <sdl3-window>)))
    (set (member win width) width)
    (set (member win height) height)
    (set (member win window) (cast 0 void *))
    (set (member win renderer) (cast 0 void *))
    (set (member win texture) (cast 0 void *))
    (if (SDL_Init SDL_INIT_VIDEO)
	(let ()
	  (set (member win window) (SDL_CreateWindow title width height 0))
	  (if (member win window)
	      (let ()
		(set (member win renderer) (SDL_CreateRenderer (member win window) "software"))
		(set (member win texture)
		     (SDL_CreateTexture (member win renderer) SDL_PIXELFORMAT_ARGB8888
					SDL_TEXTUREACCESS_STREAMING width height))))))
    (return win)))

(define-function sdl3-error (char *) ()
  (return (SDL_GetError)))

;; Draws PIXELS (width x height uint32 ARGB, row-major) into the renderer's
;; frame.  Nothing is shown until sdl3-present.
(define-function sdl3-draw void ((win struct <sdl3-window>) (pixels void *))
  (SDL_UpdateTexture (member win texture) (cast 0 void *) pixels (* 4 (member win width)))
  (SDL_RenderTexture (member win renderer) (member win texture) (cast 0 void *) (cast 0 void *)))

;; The frame drawn so far, as an SDL_Surface the caller frees with
;; sdl3-free-surface.
(define-function sdl3-read (void *) ((win struct <sdl3-window>))
  (return (SDL_RenderReadPixels (member win renderer) (cast 0 void *))))

(define-function sdl3-free-surface void ((surface void *))
  (SDL_DestroySurface surface))

;; The ARGB pixel at (x, y) of a surface from sdl3-read, as an unsigned 32-bit value.
(define-function sdl3-pixel long ((surface void *) (x int) (y int))
  (let* (((pitch int)	(at surface surface_pitch (int)))
	 ((base char *)	(cast (at surface surface_pixels (void *)) char *))
	 ((value int32)	(at (+ base (* y pitch)) (* 4 x) (int32))))
    (return (& (cast value long) (- (<< (cast 1 long) 32) 1)))))

(define-function sdl3-present void ((win struct <sdl3-window>))
  (SDL_RenderPresent (member win renderer)))

(define-function sdl3-close void ((win struct <sdl3-window>))
  (SDL_DestroyTexture (member win texture))
  (SDL_DestroyRenderer (member win renderer))
  (SDL_DestroyWindow (member win window))
  (SDL_Quit))

;; Reads the next event, or kind 0 when there is none.  Mouse events carry x,
;; y (truncated to whole pixels) and button; key events carry key.
(define-function sdl3-poll (struct <sdl3-event>) ()
  (let* (((raw void *)	(calloc 1 event_size))
	 ((ev struct <sdl3-event>)))
    (set (member ev kind) 0)
    (set (member ev x) 0)
    (set (member ev y) 0)
    (set (member ev button) 0)
    (set (member ev key) 0)
    (if (SDL_PollEvent raw)
	(let (((kind int) (at raw event_type (int32))))
	  (set (member ev kind) kind)
	  (if (or (= kind SDL_EVENT_MOUSE_BUTTON_DOWN) (= kind SDL_EVENT_MOUSE_BUTTON_UP))
	      (let ()
		(set (member ev x) (cast (at raw mouse_button_x (float)) int))
		(set (member ev y) (cast (at raw mouse_button_y (float)) int))
		(set (member ev button) (cast (at raw mouse_button_button (int8)) int))))
	  (if (= kind SDL_EVENT_MOUSE_MOTION)
	      (let ()
		(set (member ev x) (cast (at raw mouse_motion_x (float)) int))
		(set (member ev y) (cast (at raw mouse_motion_y (float)) int))))
	  (if (= kind SDL_EVENT_KEY_DOWN)
	      (set (member ev key) (at raw keyboard_key (int32))))))
    (free raw)
    (return ev)))

;; Queues a mouse button event (SDL_EVENT_MOUSE_BUTTON_DOWN or _UP) at (x, y).
(define-function sdl3-push-button char ((kind int) (x int) (y int) (button int))
  (let (((raw void *) (calloc 1 event_size)))
    (put raw event_type (int32) kind)
    (put raw mouse_button_button (int8) (cast button int8))
    (put raw mouse_button_down (int8) (cast (= kind SDL_EVENT_MOUSE_BUTTON_DOWN) int8))
    (put raw mouse_button_x (float) (cast x float))
    (put raw mouse_button_y (float) (cast y float))
    (let (((ok char) (SDL_PushEvent raw)))
      (free raw)
      (return ok))))

;; Queues a mouse motion event to (x, y).
(define-function sdl3-push-motion char ((x int) (y int))
  (let (((raw void *) (calloc 1 event_size)))
    (put raw event_type (int32) SDL_EVENT_MOUSE_MOTION)
    (put raw mouse_motion_x (float) (cast x float))
    (put raw mouse_motion_y (float) (cast y float))
    (let (((ok char) (SDL_PushEvent raw)))
      (free raw)
      (return ok))))

;; Queues a key press of KEY.
(define-function sdl3-push-key char ((key int))
  (let (((raw void *) (calloc 1 event_size)))
    (put raw event_type (int32) SDL_EVENT_KEY_DOWN)
    (put raw keyboard_key (int32) key)
    (put raw keyboard_down (int8) (cast 1 int8))
    (let (((ok char) (SDL_PushEvent raw)))
      (free raw)
      (return ok))))
