;;; ksworld-render.l -- a KSWorld document drawn by a Gezira: (ksworld-render box gezira width height) asks gezira to fill
;;; each path under box, in drawing order, with (gezira-fill-path gezira matrix width height paint floats count): the path
;;; as the shape holds it, a FloatArray of quadratic Béziers, placed by matrix, clipped to width x height, painted.  The
;;; geometry is Gezira's, in Nile.  Which Gezira is the caller's: gezira-library.l's draws through libgezira and libnile, and
;;; Gezira compiled into the image answers the same message, so neither has to be a library.
;;; A box draws its shape, then its contents in order, so later ones are on top (TR-2013-002, 4.1 and 4.2): each
;;; transformation is relative to the box's container, and a glyph's shape has its own transform from em units, so each
;;; box's matrix is composed here, six numbers, in Gezira's terms.  A text box's spans, laid out by ksworld-text.l, are drawn
;;; after its shape, each character its TrueType outline.
(require "kscript.l")
(require "ksworld-text.l")

(define-selector gezira-fill-path (gezira matrix width height paint floats count)
  (error "ksworld-render: " gezira " is no Gezira"))

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

;; what a fill paints, as a Gezira is told it: (uniform alpha red green blue)
(define-function ksworld-paint (fill)
  (if (and (ks-object? fill) (= 'GeziraFillUniform (<ks-object>-class fill)))
      (list 'uniform (* 1.0 (ks-slot fill 'alpha)) (* 1.0 (ks-slot fill 'red)) (* 1.0 (ks-slot fill 'green)) (* 1.0 (ks-slot fill 'blue)))
    (error "ksworld-render: can't paint with " fill)))

(define-function ksworld-render-path (path m gezira width height)
  (let ((floats (<ks-object>-data (ks-slot path 'floats))))
    (and floats
	 (gezira-fill-path gezira m width height (ksworld-paint (ks-slot path 'myFill)) floats (/ (data-length floats) 4)))))

;; a text box's selection, while it shows, as rectangles in its layout's selection colour, under the text
(define-function ksworld-render-selection (box m gezira width height)
  (let ((layout (ks-slot box 'handler)) (sel ()))
    (when (and (= 'true (ks-val box 'showSelection)) (ks-object? (set sel (ks-val layout 'selection))))
      (let ((c (ks-slot layout 'selectionColor)))
	(list-do r (ks-text-selection-rects box (ks-slot sel 'start) (- (ks-slot sel 'stop) 1))
	  (let ((floats (data (* 4 24))) (i 0)
		(corners (list (car r) (cadr r) (caddr r) (cadr r) (caddr r) (cadddr r) (car r) (cadddr r) (car r) (cadr r))))
	    (for (k 0 4)	; each side a straight segment: start, start, end
	      (let ((x0 (car corners)) (y0 (cadr corners)) (x1 (caddr corners)) (y1 (cadddr corners)))
		(list-do v (list x0 y0 x0 y0 x1 y1) (set-float-at floats i (* 1.0 v)) (set i (+ i 1))))
	      (set corners (cddr corners)))
	    (gezira-fill-path gezira m width height
			      (list 'uniform (<ks-color>-a c) (<ks-color>-r c) (<ks-color>-g c) (<ks-color>-b c)) floats 24)))))))

(define-function ksworld-render-box (box m gezira width height)
  (when (and (ks-object? box) (not (= 'false (ks-val box 'visible))))
    (let* ((here (ks-compose m (ks-matrix-of (ks-val box 'transformation))))
	   (shape (ks-val box 'shape)))
      (when (ks-object? shape)
	(let ((sm (ks-compose here (ks-matrix-of (ks-slot shape 'transform)))))
	  (list-do element (ks-items (ks-slot shape 'elements))
	    (and (ks-object? element) (= 'GeziraPath (<ks-object>-class element))
		 (ksworld-render-path element sm gezira width height)))))
      (when (ks-text-box? box)
	(ksworld-render-selection box here gezira width height)
	(list-do g (ks-text-glyphs box)
	  (let ((floats (ks-glyph-floats g)))
	    (and (< 0 (data-length floats))
		 (gezira-fill-path gezira (ks-compose here (ks-glyph-matrix g)) width height (<ks-glyph>-paint g)
				   floats (/ (data-length floats) 4))))))
      (list-do part '(backgroundParts contents parts)
	(list-do child (ks-items (ks-val box part))
	  (ksworld-render-box child here gezira width height))))))

(define-function ksworld-render (box gezira width height)
  (ksworld-render-box box ks-identity gezira width height))
