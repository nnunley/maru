;;; gezira.l -- the messages a Gezira answers, declared once for everyone who uses one: gezira-fill-path (a path, placed by a
;;; matrix, clipped to width x height, painted uniformly), gezira-image (its pixels, ARGB32, in C memory), gezira-clear (the
;;; page, opaque white), gezira-pixel (one pixel, for reading back) and gezira-stop (the runtime's shut down).  Which Gezira
;;; is the caller's: gezira-maru.l's is the library on the Maru runtime, gezira-library.l's the old C library.
(define-selector gezira-fill-path (gezira matrix width height paint floats count)
  (error "gezira: " gezira " is no Gezira"))
(define-selector gezira-image (gezira) (error "gezira: " gezira " paints no image"))
(define-selector gezira-clear (gezira) (error "gezira: " gezira " paints no image"))
(define-selector gezira-pixel (gezira x y) (error "gezira: " gezira " paints no image"))
(define-selector gezira-stop (gezira) (error "gezira: " gezira " is no Gezira"))
