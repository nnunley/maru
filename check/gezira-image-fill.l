;;; check/gezira-image-fill.l -- an image as a Gezira paint, as KSWorld's GeziraFillImage paints one: a texture matrix taking
;;; the target's points to the image's, then ReadFromImage_ARGB32, through the bilinear filter or not, and GeziraBindings'
;;; downsample and a PNG's straight alpha made premultiplied.  On one worker and four.  With MARU_DBJR, the front page
;;; drawn by ksworld-render.l, its photograph's pixels held to what GeziraFillImage's pipeline gives worked out here from
;;; the PNG's own (the downsampled texel, then the bilinear filter, then the writer's rounding) on a 10 x 10 grid over it.
;;; Prints "gezira image fill ok".
(require "ksworld-pp.l")
(require "gezira-maru.l")
(require "check/temp.l")
(require "ksworld-run.l")
(require "ksworld-events.l")

(define failures 0)
(define-function expect (what got want)
  (or (= got want) (let () (set failures (+ failures 1)) (println "FAIL " what ": got " got ", want " want))))

(define-function floats-of (values)
  (let ((floats (data (* 4 (list-length values)))) (i 0))
    (list-do v values (set-float-at floats i (* 1.0 v)) (set i (+ i 1)))
    floats))
;; a rectangle's sides as Béziers, each start, start, end, as Rectangle>>asGeziraPath writes them
(define-function rectangle (x0 y0 x1 y1)
  (floats-of (list x0 y0 x0 y0 x1 y0  x1 y0 x1 y0 x1 y1  x1 y1 x1 y1 x0 y1  x0 y1 x0 y1 x0 y0)))
;; an image of w x h ARGB32 words in C memory, each (f x y)
(define-function image (w h f)
  (let ((p ((subr "malloc" "l>p") (* 4 (* w h)))))
    (for (y 0 h) (for (x 0 w) (set-int32-at p (+ x (* y w)) (f x y))))
    p))
(define-function word (p i) (int32-at p i))

(list-do workers '(1 4)
  (let ((g (gezira-maru 64 64 workers))
	(tile (image 4 3 (lambda (x y) (| -16777216 (| (<< (* 60 x) 16) (| (<< (* 80 y) 8) 17)))))))
    ;; unfiltered: a whole-pixel translation copies the image, each target pixel the image's pixel it lands in
    (gezira-clear g)
    (gezira-fill-path g (ks-matrix 1 0 0 1 0 0) 64 64 (list 'image tile 4 3 (ks-matrix 1 0 0 1 -10 -10) 0) (rectangle 10 10 14 13) 24)
    (for (y 0 3) (for (x 0 4) (expect "a copied pixel" (gezira-pixel g (+ 10 x) (+ 10 y)) (word tile (+ x (* 4 y))))))
    (expect "the pixel beside the copy is the page" (gezira-pixel g 14 10) -1)
    ;; filtered and downsampled: a uniform image stays exactly its colour
    (let* ((plain (image 8 6 (lambda (x y) -13408615)))	; 0xFF336699
	   (half (gezira-downsample g plain 8 6)))
      (for (k 0 12) (expect "a downsampled pixel" (word half k) -13408615))
      (gezira-clear g)
      (gezira-fill-path g (ks-matrix 2 0 0 2 20 20) 64 64 (list 'image plain 8 6 (ks-matrix 0.5 0 0 0.5 -10 -10) 1) (rectangle 0 0 4 3) 24)
      (expect "a filtered pixel inside" (gezira-pixel g 23 23) -13408615))
    ;; straight alpha to premultiplied, rounded as the writer rounds
    (let ((p (image 1 1 (lambda (x y) 0))))
      (set-int32-at p 0 (| (<< 128 24) (<< 255 16)))
      (gezira-premultiply g p 1)
      (expect "half-transparent red, premultiplied" (word p 0) (| (<< -128 24) (<< 128 16))))	; 0x80800000, a signed word
    (gezira-stop g)))

;; GeziraFillImage's pipeline worked out from the image's pixels, for one target pixel: ReadFromImage's pixel for a point,
;; BilinearFilter's four reads and weights, the downsample's texel, and the writer's rounding
(define-function ref-chan (p k) (& 255 (>> p (* 8 k))))
(define-function ref-floor (v) (let ((n (double->long v))) (if (> (long->double n) v) (- n 1) n)))
(define-function ref-read (px w h x y)	; a colour (r g b a) in [0, 1], premultiplied as stored
  (let ((x (if (= x (long->double w)) (- x 1.0) x)) (y (if (= y (long->double h)) (- y 1.0) y)))
    (if (or (< x 0.0) (< y 0.0) (> x (long->double w)) (> y (long->double h)))
	(list 0.0 0.0 0.0 0.0)
      (let ((c (& 0xffffffff (px (double->long x) (double->long y)))))
	(list (/ (ref-chan c 2) 255.0) (/ (ref-chan c 1) 255.0) (/ (ref-chan c 0) 255.0) (/ (ref-chan c 3) 255.0))))))
(define-function ref-bilinear (px w h px-x px-y)
  (let* ((x (+ 0.5 (long->double (ref-floor (- px-x 0.5))))) (y (+ 0.5 (long->double (ref-floor (- px-y 0.5)))))
	 (u (- px-x x)) (v (- px-y y))
	 (sum (list 0.0 0.0 0.0 0.0)))
    (list-do pw (list (list x y (* (- 1.0 u) (- 1.0 v))) (list (+ x 1.0) y (* u (- 1.0 v)))
		      (list x (+ y 1.0) (* (- 1.0 u) v)) (list (+ x 1.0) (+ y 1.0) (* u v)))
      (set sum (map (lambda (s c) (+ s (* (caddr pw) c))) sum (ref-read px w h (car pw) (cadr pw)))))
    sum))
(define-function ref-byte (v) (% (double->long (+ (* v 255.0) 0.5)) 256))
(define-function ref-word (c)	; (r g b a) as ARGB
  (+ (<< (ref-byte (cadddr c)) 24) (+ (<< (ref-byte (car c)) 16) (+ (<< (ref-byte (cadr c)) 8) (ref-byte (caddr c))))))

;; the front page: its photograph's matrix is the one the renderer composes, kept as it paints
(let ((dir (env-var "MARU_DBJR")))
  (if (not dir)
      (println "the front page's photograph: skipped, MARU_DBJR unset")
    (set *ks-font-path* (cons (concat-string dir "/fonts") *ks-font-path*))
    (let* ((seen ())
	   (paint ksworld-image-paint)
	   (r (ksworld-run (concat-string dir "/Front page Onward Full v8.ks/index.pp") 1))
	   (s (ksworld-session r))
	   (g (gezira-maru 1024 768 4))
	   (exact 0) (worst 0))
      (set ksworld-image-paint (lambda (fill m gezira) (set seen m) (paint fill m gezira)))
      (gezira-clear g)
      (ksworld-render (<ksworld-session>-root s) g 1024 768)
      (set ksworld-image-paint paint)
      (let* ((t (ks-invert seen)) (img (cadr (car ksworld-forms))) (w (<png>-width img)) (h (<png>-height img))
	     (tw (/ w 2)) (th (/ h 2))
	     (full (lambda (i j) (png-pixel img i j)))
	     (half (lambda (i j) (ref-word (ref-bilinear full w h (* (/ (long->double w) (long->double tw)) (+ 0.5 i))
							 (* (/ (long->double h) (long->double th)) (+ 0.5 j)))))))
	(for (j 1 11) (for (i 1 11)
	  (let* ((p (ks-apply-matrix seen (ks-point (* (/ w 10) (- i 0.5)) (* (/ h 10) (- j 0.5)))))
		 (x (double->long (<ks-point>-x p))) (y (double->long (<ks-point>-y p)))
		 (q (ks-apply-matrix t (ks-point (+ x 0.5) (+ y 0.5))))
		 (a (& 0xffffffff (gezira-pixel g x y)))
		 (b (ref-word (ref-bilinear half tw th (* 0.5 (<ks-point>-x q)) (* 0.5 (<ks-point>-y q)))))
		 (d 0))
	    (for (k 0 4) (let ((e (- (ref-chan a k) (ref-chan b k)))) (set d (max d (if (< e 0) (- 0 e) e)))))
	    (and (= a b) (set exact (+ exact 1)))
	    (set worst (max worst d))))))
      (or (>= exact 95) (expect "the photograph's pixels as its pipeline gives them, of 100" exact 95))
      (or (<= worst 2) (expect "the photograph's largest difference from its pipeline" worst 2))
      (gezira-stop g))))
(println (if (= 0 failures) "gezira image fill ok" (concat-string (long->string failures) " failures")))
