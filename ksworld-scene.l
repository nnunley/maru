;;; ksworld-scene.l -- what a KSWorld document draws, as Gezira would be handed it: (ksworld-scene box) answers the paths
;;; under box, each (fill . beziers) with its quadratic Béziers (x1 y1 x2 y2 x3 y3) in the window's coordinates, in drawing
;;; order.  A box draws its shape, then its contents in order, so later ones are on top (TR-2013-002, 4.1 and 4.2): each
;;; transformation is relative to the box's container, and a glyph's shape has its own transform from em units.
(require "kscript.l")

(define ks-identity (ks-matrix 1 0 0 0 1 0))
;; parent then child: x' = a x + b y + c, y' = d x + e y + f, as Squeak's MatrixTransform2x3
(define-function ks-compose (p c)
  (ks-matrix (+ (* (<ks-matrix>-a p) (<ks-matrix>-a c)) (* (<ks-matrix>-b p) (<ks-matrix>-d c)))
	     (+ (* (<ks-matrix>-a p) (<ks-matrix>-b c)) (* (<ks-matrix>-b p) (<ks-matrix>-e c)))
	     (+ (+ (* (<ks-matrix>-a p) (<ks-matrix>-c c)) (* (<ks-matrix>-b p) (<ks-matrix>-f c))) (<ks-matrix>-c p))
	     (+ (* (<ks-matrix>-d p) (<ks-matrix>-a c)) (* (<ks-matrix>-e p) (<ks-matrix>-d c)))
	     (+ (* (<ks-matrix>-d p) (<ks-matrix>-b c)) (* (<ks-matrix>-e p) (<ks-matrix>-e c)))
	     (+ (+ (* (<ks-matrix>-d p) (<ks-matrix>-c c)) (* (<ks-matrix>-e p) (<ks-matrix>-f c))) (<ks-matrix>-f p))))
(define-function ks-apply-x (m x y) (+ (+ (* (<ks-matrix>-a m) x) (* (<ks-matrix>-b m) y)) (<ks-matrix>-c m)))
(define-function ks-apply-y (m x y) (+ (+ (* (<ks-matrix>-d m) x) (* (<ks-matrix>-e m) y)) (<ks-matrix>-f m)))

;; a path's Béziers, six floats each, through m
(define-function ks-path-beziers (path m)
  (let* ((floats (<ks-object>-data (ks-slot path 'floats)))
	 (n (if floats (/ (/ (data-length floats) 4) 6) 0))
	 (out ()))
    (for (i 0 n)
      (let ((at (lambda (k) (float-at floats (+ (* 6 i) k)))))
	(push out (list (ks-apply-x m (at 0) (at 1)) (ks-apply-y m (at 0) (at 1))
			(ks-apply-x m (at 2) (at 3)) (ks-apply-y m (at 2) (at 3))
			(ks-apply-x m (at 4) (at 5)) (ks-apply-y m (at 4) (at 5))))))
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
		 (set-car out (cons (cons (ks-slot element 'myFill) (ks-path-beziers element sm)) (car out)))))))
      (list-do part '(backgroundParts contents parts)
	(list-do child (ks-items (ks-val box part))
	  (ksworld-scene-into child here out))))))

(define-function ksworld-scene (box)
  (let ((out (list ())))
    (ksworld-scene-into box ks-identity out)
    (list-reverse! (car out))))
