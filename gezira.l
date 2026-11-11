;;; gezira.l -- the messages a Gezira answers, declared once for everyone who uses one: gezira-fill-path (a path, placed by a
;;; matrix, clipped to width x height, painted uniformly), gezira-image (its pixels, ARGB32, in C memory), gezira-clear (the
;;; page, opaque white), gezira-pixel (one pixel, for reading back) and gezira-stop (the runtime's shut down).  A paint is
;;; (uniform alpha red green blue) or (image pixels width height texture-matrix filter): premultiplied ARGB32 pixels, each
;;; target point taken to the image's by the matrix, and filtered bilinearly unless filter is 0.  gezira-downsample makes
;;; an image half the size (GeziraBindings' downsample), and gezira-premultiply makes a PNG's straight alpha premultiplied.  Which Gezira
;;; is the caller's: gezira-maru.l's is the library on the Maru runtime, gezira-library.l's the old C library.
;;; gezira-fill-clipped fills a path inside clipping stages, as GeziraCanvas builds a pipeline for its clips interleaved
;;; with its transforms: stages, outermost first, are each (matrix . (left top right bottom)), a clip rectangle in its own
;;; coordinates and the matrix from those to the stage outside it (the image's for the first); the path's matrix takes it
;;; into the innermost stage's.  A Gezira that doesn't clip (a check's, counting paths) fills it placed in the image.
(define-selector gezira-fill-path (gezira matrix width height paint floats count)
  (error "gezira: " gezira " is no Gezira"))
(define gezira-staged-matrix)	; ksworld-render.l's, where matrices compose: the path's matrix into the image
(define-selector gezira-fill-clipped (gezira matrix stages width height paint floats count)
  (gezira-fill-path gezira (gezira-staged-matrix matrix stages) width height paint floats count))
(define-selector gezira-image (gezira) (error "gezira: " gezira " paints no image"))
(define-selector gezira-clear (gezira) (error "gezira: " gezira " paints no image"))
(define-selector gezira-pixel (gezira x y) (error "gezira: " gezira " paints no image"))
(define-selector gezira-stop (gezira) (error "gezira: " gezira " is no Gezira"))
(define-selector gezira-downsample (gezira pixels width height) (error "gezira: " gezira " paints no image"))
(define-selector gezira-premultiply (gezira pixels count) (error "gezira: " gezira " paints no image"))
