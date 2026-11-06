;;; ksworld-scene.l -- what a KSWorld document draws, as Gezira is handed it: (ksworld-scene box) answers the paths under
;;; box in drawing order, each (fill matrix . beziers): its quadratic Béziers (x1 y1 x2 y2 x3 y3) as the shape holds them,
;;; and the matrix that places them in the window, in Gezira's order (a b c d e f: x' = a x + c y + e, y' = b x + d y + f).
;;; Transforming the points is Gezira's TransformBeziers, in Nile; here only each box's matrix is composed.  A box draws its
;;; shape, then its contents in order, so later ones are on top (TR-2013-002, 4.1 and 4.2): each transformation is relative
;;; to the box's container, and a glyph's shape has its own transform from em units.
(require "kscript.l")

(define ks-identity (ks-matrix 1 0 0 0 1 0))
;; parent then child, in Squeak's MatrixTransform2x3 order: x' = a x + b y + c, y' = d x + e y + f
(define-function ks-compose (p c)
  (ks-matrix (+ (* (<ks-matrix>-a p) (<ks-matrix>-a c)) (* (<ks-matrix>-b p) (<ks-matrix>-d c)))
	     (+ (* (<ks-matrix>-a p) (<ks-matrix>-b c)) (* (<ks-matrix>-b p) (<ks-matrix>-e c)))
	     (+ (+ (* (<ks-matrix>-a p) (<ks-matrix>-c c)) (* (<ks-matrix>-b p) (<ks-matrix>-f c))) (<ks-matrix>-c p))
	     (+ (* (<ks-matrix>-d p) (<ks-matrix>-a c)) (* (<ks-matrix>-e p) (<ks-matrix>-d c)))
	     (+ (* (<ks-matrix>-d p) (<ks-matrix>-b c)) (* (<ks-matrix>-e p) (<ks-matrix>-e c)))
	     (+ (+ (* (<ks-matrix>-d p) (<ks-matrix>-c c)) (* (<ks-matrix>-e p) (<ks-matrix>-f c))) (<ks-matrix>-f p))))
;; Squeak's order to Gezira's
(define-function ks-gezira-matrix (m)
  (list (<ks-matrix>-a m) (<ks-matrix>-d m) (<ks-matrix>-b m) (<ks-matrix>-e m) (<ks-matrix>-c m) (<ks-matrix>-f m)))

;; a path's Béziers as the shape holds them, six floats each
(define-function ks-path-beziers (path)
  (let* ((floats (<ks-object>-data (ks-slot path 'floats)))
	 (n (if floats (/ (/ (data-length floats) 4) 6) 0))
	 (out ()))
    (for (i 0 n)
      (let ((b ()))
	(for (k 0 6) (push b (float-at floats (+ (* 6 i) k))))
	(push out (list-reverse! b))))
    (list-reverse! out)))

(define-function ks-matrix-of (v) (if (ks-matrix? v) v ks-identity))

(define-function ksworld-scene-into (box m out)
  (when (and (ks-object? box) (not (= 'false (ks-val box 'visible))))
    (let* ((here (ks-compose m (ks-matrix-of (ks-val box 'transformation))))
	   (shape (ks-val box 'shape)))
      (when (ks-object? shape)
	(let ((sm (ks-compose here (ks-matrix-of (ks-slot shape 'transform)))))
	  (list-do element (ks-items (ks-slot shape 'elements))
	    (and (ks-object? element) (= 'GeziraPath (<ks-object>-class element))
		 (set-car out (cons (cons (ks-slot element 'myFill) (cons (ks-gezira-matrix sm) (ks-path-beziers element)))
				    (car out)))))))
      (list-do part '(backgroundParts contents parts)
	(list-do child (ks-items (ks-val box part))
	  (ksworld-scene-into child here out))))))

(define-function ksworld-scene (box)
  (let ((out (list ())))
    (ksworld-scene-into box ks-identity out)
    (list-reverse! (car out))))
