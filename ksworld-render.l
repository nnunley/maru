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

(require "gezira.l")
(require "png.l")

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

(define-function ks-invert (m)
  (let* ((a (<ks-matrix>-a m)) (b (<ks-matrix>-b m)) (c (<ks-matrix>-c m)) (d (<ks-matrix>-d m))
	 (e (<ks-matrix>-e m)) (f (<ks-matrix>-f m)) (det (- (* a d) (* b c))))
    (ks-matrix (/ d det) (/ (- b) det) (/ (- c) det) (/ a det)
	       (/ (- (* c f) (* d e)) det) (/ (- (* b e) (* a f)) det))))

;; a number with no fraction (a Squeak point that equals its rounding), and a square root
(define-function ks-whole? (x) (= (* 1.0 x) (long->double (double->long (* 1.0 x)))))
(define ks-sqrt (subr "sqrt" "d>d"))

;; an image fill's form: its PNG read once, made premultiplied, as GeziraFillImage's setForm: takes a 32-bit form;
;; (form png mipmaps), mipmaps ((level . pixels) …) made as the original makes them, by GeziraBindings' downsample
(define ksworld-forms ())
(define-function ksworld-form (form gezira)
  (or (assq form ksworld-forms)
      (let ((png (png-load (or (ks-attr form ':__path__) (error "ksworld-render: no image file for " form)))))
	(gezira-premultiply gezira (<png>-pixels png) (* (<png>-width png) (<png>-height png)))
	(car (push ksworld-forms (list form png ()))))))

;; GeziraFillImage's pipelineOn:for:, as its paint: the canvas's inverse transformation (composed with the fill's own
;; transform), unfiltered if filtering is off or that is a whole-pixel translation, else mipmapped while the
;; minification passes 2, 4 … (each level half the size, the matrix halved) and filtered bilinearly
(define-function ksworld-image-paint (fill m gezira)
  (let* ((entry (ksworld-form (ks-slot fill 'form) gezira))
	 (png (cadr entry))
	 (t (ks-invert m))
	 (own (ks-slot fill 'transform)))
    (and (ks-matrix? own) (set t (ks-compose own t)))
    (if (or (ks-slot-false? fill 'filter)
	    (and (= 1.0 (<ks-matrix>-a t)) (= 0.0 (<ks-matrix>-b t)) (= 0.0 (<ks-matrix>-c t)) (= 1.0 (<ks-matrix>-d t))
		 (ks-whole? (<ks-matrix>-e t)) (ks-whole? (<ks-matrix>-f t))))
	(list 'image (<png>-pixels png) (<png>-width png) (<png>-height png) t 0)
      (let ((pixels (<png>-pixels png)) (w (<png>-width png)) (h (<png>-height png)) (level 2)
	    (minification (ks-sqrt (+ (* (<ks-matrix>-a t) (<ks-matrix>-a t)) (* (<ks-matrix>-c t) (<ks-matrix>-c t))))))
	(while (and (> minification level) (or (> w 1) (> h 1)))
	  (let ((made (assq level (caddr entry))))
	    (or made (set-car (cddr entry) (cons (set made (cons level (gezira-downsample gezira pixels w h))) (caddr entry))))
	    (set pixels (cdr made)) (set w (/ w 2)) (set h (/ h 2)))
	  (set t (ks-matrix (* 0.5 (<ks-matrix>-a t)) (* 0.5 (<ks-matrix>-b t)) (* 0.5 (<ks-matrix>-c t))
			    (* 0.5 (<ks-matrix>-d t)) (* 0.5 (<ks-matrix>-e t)) (* 0.5 (<ks-matrix>-f t))))
	  (set level (* 2 level)))
	(list 'image pixels w h t 1)))))

;; what a fill paints, as a Gezira is told it: (uniform alpha red green blue), or an image (ksworld-image-paint)
(define-function ksworld-paint (fill m gezira)
  (cond ((and (ks-object? fill) (ks-instance? fill 'GeziraFillUniform))
	 (list 'uniform (* 1.0 (ks-slot fill 'alpha)) (* 1.0 (ks-slot fill 'red)) (* 1.0 (ks-slot fill 'green)) (* 1.0 (ks-slot fill 'blue))))
	((and (ks-object? fill) (ks-instance? fill 'GeziraFillImage)) (ksworld-image-paint fill m gezira))
	(else (error "ksworld-render: can't paint with " fill))))

;; a box whose clipping is on draws itself and what it holds only inside its bounds, as KSBox>>drawOn: clips its canvas
;; by its drawingBounds: the rectangle (left top right bottom) in the image that the clipping boxes drawing now leave, or
;; () for none
(define *ksworld-clip* ())

;; a path's quadratic Béziers placed by m, each (ax ay bx by cx cy), in the image's coordinates
(define-function ks-placed-beziers (m floats count)
  (let ((out ()) (a (<ks-matrix>-a m)) (b (<ks-matrix>-b m)) (c (<ks-matrix>-c m)) (d (<ks-matrix>-d m))
	(e (<ks-matrix>-e m)) (f (<ks-matrix>-f m)))
    (for (i 0 (/ count 6))
      (let ((z ()))
	(for (k 0 3)
	  (let ((x (float-at floats (+ (* 6 i) (* 2 k)))) (y (float-at floats (+ (* 6 i) (+ 1 (* 2 k))))))
	    (push z (+ (+ (* a x) (* c y)) e))
	    (push z (+ (+ (* b x) (* d y)) f))))
	(push out (list-reverse! z))))
    (list-reverse! out)))
(define-function ks-bezier-xs (z) (list (car z) (caddr z) (car (cddddr z))))
(define-function ks-bezier-ys (z) (list (cadr z) (cadddr z) (cadr (cddddr z))))
(define-function ks-all? (pred l) (let ((ok 1)) (list-do v l (or (pred v) (set ok ()))) ok))
(define-function ks-bezier-inside? (z r)
  (and (ks-all? (lambda (x) (and (<= (car r) x) (<= x (caddr r)))) (ks-bezier-xs z))
       (ks-all? (lambda (y) (and (<= (cadr r) y) (<= y (cadddr r)))) (ks-bezier-ys z))))
(define-function ks-bezier-beyond? (z r)	; wholly to one side of the rectangle
  (or (ks-all? (lambda (x) (<= x (car r))) (ks-bezier-xs z)) (ks-all? (lambda (x) (<= (caddr r) x)) (ks-bezier-xs z))
      (ks-all? (lambda (y) (<= y (cadr r))) (ks-bezier-ys z)) (ks-all? (lambda (y) (<= (cadddr r) y)) (ks-bezier-ys z))))
(define-function ks-clamp (v lo hi) (max lo (min hi v)))
(define-function ks-distance (a b) (max (- a b) (- b a)))
(define-function ks-snap (v lo hi)	; a split point's coordinate onto the nearer edge, if within 0.1 of it
  (let* ((edge (if (< (ks-distance v lo) (ks-distance v hi)) lo hi)))
    (if (< (ks-distance v edge) 0.1) edge v)))

;; Gezira's ClipBeziers (gezira/nile/gezira.nl), on Béziers placed in the image: one inside the rectangle passes; one wholly
;; to one side is clamped onto it, so its edge keeps the winding it contributes; any other is split at its middle (snapped
;; to the nearer edge within 0.1) and each half considered again
(define-function ks-clip-beziers (zs r)
  (let ((todo zs) (out ()))
    (while todo
      (let ((z (car todo)))
	(set todo (cdr todo))
	(cond ((ks-bezier-inside? z r) (push out z))
	      ((ks-bezier-beyond? z r)
	       (push out (list (ks-clamp (car z) (car r) (caddr r)) (ks-clamp (cadr z) (cadr r) (cadddr r))
			       (ks-clamp (caddr z) (car r) (caddr r)) (ks-clamp (cadddr z) (cadr r) (cadddr r))
			       (ks-clamp (car (cddddr z)) (car r) (caddr r)) (ks-clamp (cadr (cddddr z)) (cadr r) (cadddr r)))))
	      (else
	       (let* ((ax (car z)) (ay (cadr z)) (bx (caddr z)) (by (cadddr z)) (cx (car (cddddr z))) (cy (cadr (cddddr z)))
		      (abx (* 0.5 (+ ax bx))) (aby (* 0.5 (+ ay by))) (bcx (* 0.5 (+ bx cx))) (bcy (* 0.5 (+ by cy)))
		      (nx (ks-snap (* 0.5 (+ abx bcx)) (car r) (caddr r))) (ny (ks-snap (* 0.5 (+ aby bcy)) (cadr r) (cadddr r))))
		 (push todo (list nx ny bcx bcy cx cy))
		 (push todo (list ax ay abx aby nx ny)))))))
    (list-reverse! out)))

;; every fill: as given where no box clips or the path lies inside the clip, else placed, clipped and given as placed
(define-function ksworld-fill (gezira m width height paint floats count)
  (if (not *ksworld-clip*)
      (gezira-fill-path gezira m width height paint floats count)
    (let ((zs (ks-placed-beziers m floats count)))
      (if (ks-all? (lambda (z) (ks-bezier-inside? z *ksworld-clip*)) zs)
	  (gezira-fill-path gezira m width height paint floats count)
	(let* ((clipped (ks-clip-beziers zs *ksworld-clip*)) (out (data (* 24 (list-length clipped)))) (i 0))
	  (list-do z clipped (list-do v z (set-float-at out i (* 1.0 v)) (set i (+ i 1))))
	  (and clipped (gezira-fill-path gezira ks-identity width height paint out (* 6 (list-length clipped)))))))))

;; a box's bounds in the image, its extent placed by m: the rectangle around its four corners
(define-function ks-image-bounds (box m)
  (let ((e (ks-val box 'extent)) (xs ()) (ys ()))
    (and (ks-point? e)
	 (let ()
	   (list-do p (list (cons 0 0) (cons (<ks-point>-x e) 0) (cons 0 (<ks-point>-y e)) (cons (<ks-point>-x e) (<ks-point>-y e)))
	     (push xs (+ (+ (* (<ks-matrix>-a m) (car p)) (* (<ks-matrix>-c m) (cdr p))) (<ks-matrix>-e m)))
	     (push ys (+ (+ (* (<ks-matrix>-b m) (car p)) (* (<ks-matrix>-d m) (cdr p))) (<ks-matrix>-f m))))
	   (list (apply min xs) (apply min ys) (apply max xs) (apply max ys))))))
(define-function ks-rect-meet (r s)	; what two rectangles share; one may be () for no clip yet
  (if (not r) s (list (max (car r) (car s)) (max (cadr r) (cadr s)) (min (caddr r) (caddr s)) (min (cadddr r) (cadddr s)))))

(define-function ksworld-render-path (path m gezira width height)
  (let ((floats (ks-slot (ks-slot path 'floats) 'data)))
    (and floats
	 (ksworld-fill gezira m width height (ksworld-paint (ks-slot path 'myFill) m gezira) floats (ks-slot (ks-slot path 'floats) 'count)))))

;; a text box's selection, while it shows, as rectangles in its layout's selection colour, under the text
(define-function ksworld-render-selection (box m gezira width height)
  (let ((layout (ks-slot box 'handler)) (sel ()))
    (when (and (= 't (ks-val box 'showSelection)) (ks-object? (set sel (ks-val layout 'selection))))
      (let ((c (ks-slot layout 'selectionColor)))
	(list-do r (ks-text-selection-rects box (ks-slot sel 'start) (- (ks-slot sel 'stop) 1))
	  (let ((floats (data (* 4 24))) (i 0)
		(corners (list (car r) (cadr r) (caddr r) (cadr r) (caddr r) (cadddr r) (car r) (cadddr r) (car r) (cadr r))))
	    (for (k 0 4)	; each side a straight segment: start, start, end
	      (let ((x0 (car corners)) (y0 (cadr corners)) (x1 (caddr corners)) (y1 (cadddr corners)))
		(list-do v (list x0 y0 x0 y0 x1 y1) (set-float-at floats i (* 1.0 v)) (set i (+ i 1))))
	      (set corners (cddr corners)))
	    (ksworld-fill gezira m width height
			  (list 'uniform (<ks-color>-a c) (<ks-color>-r c) (<ks-color>-g c) (<ks-color>-b c)) floats 24)))))))

(define ksworld-render-box-clipped)
(define-function ksworld-render-box (box m gezira width height)
  (when (and (ks-object? box) (not (ks-slot-false? box 'visible)))
    (let* ((here (ks-compose m (ks-matrix-of (ks-val box 'transformation))))
	   (outer *ksworld-clip*) (bounds (and (= 't (ks-val box 'clipping)) (ks-image-bounds box here))))
      (and bounds (set *ksworld-clip* (ks-rect-meet outer bounds)))
      (ksworld-render-box-clipped box here gezira width height)
      (set *ksworld-clip* outer))))

(define-function ksworld-render-box-clipped (box here gezira width height)
  (let ((shape (ks-val box 'shape)))
      (when (ks-object? shape)
	(let ((sm (ks-compose here (ks-matrix-of (ks-slot shape 'transform)))))
	  (list-do element (ks-items (ks-slot shape 'elements))
	    (and (ks-object? element) (ks-instance? element 'GeziraPath)
		 (ksworld-render-path element sm gezira width height)))))
      (when (ks-text-box? box)
	(ksworld-render-selection box here gezira width height)
	(list-do g (ks-text-glyphs box)
	  (let ((floats (ks-glyph-floats g)))
	    (and (< 0 (ks-glyph-count g))
		 (ksworld-fill gezira (ks-compose here (ks-glyph-matrix g)) width height (<ks-glyph>-paint g)
			       floats (ks-glyph-count g))))))
      (list-do part '(backgroundParts contents parts)
	(list-do child (ks-items (ks-val box part))
	  (ksworld-render-box child here gezira width height)))))

(define-function ksworld-render (box gezira width height)
  (ksworld-render-box box ks-identity gezira width height))
