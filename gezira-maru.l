;;; gezira-maru.l -- a Gezira on the Maru runtime, for untyped Maru: (gezira-maru width height workers) makes one, an image
;;; of width x height ARGB32 pixels and a runtime with that many workers, both in build/gezira.dylib (Makefile), which is
;;; the 2016 Gezira source (gezira/nile/gezira.nl) through Nile's Maru back end, with WriteToImage_ARGB32 and the entry
;;; points in nile/runtimes/maru.  Its gezira-fill-path (ksworld-render.l's selector) fills a path with a uniform paint
;;; into the image, clipped to its size; gezira-image answers the pixels' C address, gezira-clear clears them, and
;;; gezira-pixel reads one.  gezira-clear makes it opaque white, as a page is.  The paint is (uniform alpha red green blue), the floats a Data buffer of 32-bit floats.
(define dlopen (subr "dlopen" "si>p"))
(define dlsym (subr "dlsym" "ps>p"))
(define system (subr "system" "s>i"))

(define-selector gezira-image (gezira) (error "gezira-maru: " gezira " paints no image"))
(define-selector gezira-clear (gezira) (error "gezira-maru: " gezira " paints no image"))
(define-selector gezira-pixel (gezira x y) (error "gezira-maru: " gezira " paints no image"))
(define-selector gezira-stop (gezira) (error "gezira-maru: " gezira " is no Gezira"))
(define-selector gezira-fill-path (gezira matrix width height paint floats count)
  (error "gezira-maru: " gezira " is no Gezira"))

;; the library's shared object, by the platform's suffix, opened once from the tree (as make builds it)
(define gezira-lib-path
  (if (= 0 (system "test `uname` = Darwin")) "build/gezira.dylib" "build/gezira.so"))
(define gezira-lib (dlopen gezira-lib-path 2))		; RTLD_NOW
(define-function gezira-entry (name sig)
  (let ((f (if (= 0 gezira-lib) 0 (dlsym gezira-lib name))))
    (if (= 0 f) (error "gezira-maru: " gezira-lib-path " has no " name))
    (subr f sig)))
(define gezira-start-entry (gezira-entry "gezira_start" "i>l"))
(define gezira-image-new-entry (gezira-entry "gezira_image_new" "ii>l"))
(define gezira-image-clear-entry (gezira-entry "gezira_image_clear" "liii"))
(define gezira-pixel-entry (gezira-entry "gezira_pixel" "liii>i"))
(define gezira-stop-entry (gezira-entry "gezira_stop" "l"))
(define gezira-fill-entry (gezira-entry "gezira_fill" "lliippi>i"))

(define-structure <gezira-maru> (init image width height))

(define-function gezira-maru (width height workers)
  (let ((init (gezira-start-entry workers)))
    (new <gezira-maru> init (gezira-image-new-entry width height) width height)))

(define-method gezira-image <gezira-maru> () self.image)

;; clears to opaque white, a document's page
(define-method gezira-clear <gezira-maru> ()
  (gezira-image-clear-entry self.image self.width self.height -1))

(define-method gezira-pixel <gezira-maru> (x y)
  (gezira-pixel-entry self.image self.width x y))

;; the matrix and paint as the entry point's params buffer: a b c d e f, then alpha red green blue
(define-method gezira-fill-path <gezira-maru> (m width height paint floats count)
  (if (not (= width self.width)) (error "gezira-maru: a path is clipped to the image's width, " self.width))
  (if (not (= height self.height)) (error "gezira-maru: a path is clipped to the image's height, " self.height))
  (let ((params (data 40)) (i 0) (status 0))
    (list-do v (list (<ks-matrix>-a m) (<ks-matrix>-b m) (<ks-matrix>-c m) (<ks-matrix>-d m) (<ks-matrix>-e m) (<ks-matrix>-f m)
		     (cadr paint) (caddr paint) (cadddr paint) (car (cddddr paint)))
      (set-float-at params i (* 1.0 v))
      (set i (+ i 1)))
    (set status (gezira-fill-entry self.init self.image self.width self.height params floats count))
    (if (not (= 0 status)) (error "gezira-maru: the runtime reports status " status))
    status))

(define-method gezira-stop <gezira-maru> ()
  (gezira-stop-entry self.init))
