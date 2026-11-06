;;; ksworld-render.l -- a KSWorld document drawn by Gezira: (ksworld-render box image process width height) feeds each path
;;; under box, in drawing order, to a pipeline of libgezira's kernels (libgezira.k): its matrix through TransformBeziers,
;;; clipped to the image, rasterised and composited in its fill's colour.  The path goes in as the shape holds it, a
;;; FloatArray of quadratic Béziers; Gezira does the geometry.  A box draws its shape, then its contents in order, so later
;;; ones are on top (TR-2013-002, 4.1 and 4.2): each transformation is relative to the box's container, and a glyph's shape
;;; has its own transform from em units, so each box's matrix is composed here, six numbers, in Gezira's terms.
(require "kscript.l")

;; what libgezira.k and libnile.k define when their libraries load (init-libgezira); named here so this file can use them
(define gezira_TransformBeziers) (define gezira_ClipBeziers) (define gezira_Rasterize)
(define gezira_CompositeUniformColorOverImage_ARGB32) (define nile_Process_pipe) (define nile_Process_feed)

(define ks-identity (ks-matrix 1 0 0 1 0 0))
;; parent then child: x' = a x + c y + e, y' = b x + d y + f
(define-function ks-compose (p c)
  (ks-matrix (+ (* (<ks-matrix>-a p) (<ks-matrix>-a c)) (* (<ks-matrix>-c p) (<ks-matrix>-b c)))
	     (+ (* (<ks-matrix>-b p) (<ks-matrix>-a c)) (* (<ks-matrix>-d p) (<ks-matrix>-b c)))
	     (+ (* (<ks-matrix>-a p) (<ks-matrix>-c c)) (* (<ks-matrix>-c p) (<ks-matrix>-d c)))
	     (+ (* (<ks-matrix>-b p) (<ks-matrix>-c c)) (* (<ks-matrix>-d p) (<ks-matrix>-d c)))
	     (+ (+ (* (<ks-matrix>-a p) (<ks-matrix>-e c)) (* (<ks-matrix>-c p) (<ks-matrix>-f c))) (<ks-matrix>-e p))
	     (+ (+ (* (<ks-matrix>-b p) (<ks-matrix>-e c)) (* (<ks-matrix>-d p) (<ks-matrix>-f c))) (<ks-matrix>-f p))))
(define-function ks-matrix-of (v) (if (ks-matrix? v) v ks-identity))

;; what a fill paints, by its class: a uniform colour, as alpha red green blue
(define-selector ksworld-paint (fill image process) (error "ksworld-render: can't paint with " fill))
(define-method ksworld-paint <ks-object> (image process)
  (if (= 'GeziraFillUniform self.class)
      (gezira_CompositeUniformColorOverImage_ARGB32 process image
	(* 1.0 (ks-slot self 'alpha)) (* 1.0 (ks-slot self 'red)) (* 1.0 (ks-slot self 'green)) (* 1.0 (ks-slot self 'blue)))
    (error "ksworld-render: can't paint with " self.class)))

(define-function ksworld-render-path (path m image process width height)
  (let ((floats (<ks-object>-data (ks-slot path 'floats))))
    (when floats
      (nile_Process_feed
       (nile_Process_pipe
	(gezira_TransformBeziers process (<ks-matrix>-a m) (<ks-matrix>-b m) (<ks-matrix>-c m)
				 (<ks-matrix>-d m) (<ks-matrix>-e m) (<ks-matrix>-f m))
	(gezira_ClipBeziers process 0.0 0.0 (* 1.0 width) (* 1.0 height))
	(gezira_Rasterize process)
	(ksworld-paint (ks-slot path 'myFill) image process)
	0)
       floats (/ (data-length floats) 4)))))

(define-function ksworld-render-box (box m image process width height)
  (when (and (ks-object? box) (not (= 'false (ks-val box 'visible))))
    (let* ((here (ks-compose m (ks-matrix-of (ks-val box 'transformation))))
	   (shape (ks-val box 'shape)))
      (when (ks-object? shape)
	(let ((sm (ks-compose here (ks-matrix-of (ks-slot shape 'transform)))))
	  (list-do element (ks-items (ks-slot shape 'elements))
	    (and (ks-object? element) (= 'GeziraPath (<ks-object>-class element))
		 (ksworld-render-path element sm image process width height)))))
      (list-do part '(backgroundParts contents parts)
	(list-do child (ks-items (ks-val box part))
	  (ksworld-render-box child here image process width height))))))

(define-function ksworld-render (box image process width height)
  (ksworld-render-box box ks-identity image process width height))
