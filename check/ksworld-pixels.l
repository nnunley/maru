;;; check/ksworld-pixels.l -- KSWorld.ks in an SDL3 window on SDL's dummy driver, drawn by a <gezira-maru>: the first frame's
;;; pixels, then a press and a drag on the title, whose selection is painted in the layout's colour. The Gezira writes
;;; each fill over the image by coverage (Gezira's WriteToImage: source times coverage plus destination times inverse
;;; coverage, the C reference's rule), so a pixel's value follows from the fills that cover it. Needs SDL3 (else SKIP)
;;; and the dbjr documents (MARU_DBJR). Prints "ksworld pixels ok" or each failure.
(require "ksworld-run.l")
(require "ksworld-window.l")
(require "gezira-maru.l")
(require "check/temp.l")
(define lround (subr "lround" "d>l"))
(define dir (env-var "MARU_DBJR"))
(define ok 't)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))

;; a channel of an ARGB32 pixel, as the 0..255 it is, from the signed int the Gezira returns
(define-function channel (px shift)
  (let ((u (if (< px 0) (+ px 4294967296) px)))
    (% (/ u shift) 256)))
(define-function argb (a r g b)	; signed, as the Gezira returns a pixel
  (let ((u (+ (+ (* a 16777216) (* r 65536)) (+ (* g 256) b))))
    (if (>= u 2147483648) (- u 4294967296) u)))
;; a colour component in [0, 1] as Gezira's byte: the C's (uint8_t) (v * 255 + 0.5), which is lround (v * 255)
(define-function byte-of (v) (lround (* v 255.0)))
(define-function pixel-of (x y) (list (lround (- x 0.5)) (lround (- y 0.5))))
;; the pixels of the window rectangle x0 .. x1 by y0 .. y1 (whole pixels) that satisfy (test px); how many
(define-function count-pixels (g x0 y0 x1 y1 test)
  (let ((n 0) (y y0))
    (while (<= y y1)
      (let ((x x0))
	(while (<= x x1)
	  (if (test (gezira-pixel g x y)) (set n (+ n 1)))
	  (set x (+ x 1))))
      (set y (+ y 1)))
    n))
;; the window rectangle of a box-space rectangle r (x0 y0 x1 y1) under the box matrix m, as whole pixels
(define-function window-bounds (m r)
  (let* ((a (ks-apply-matrix m (ks-point (car r) (cadr r))))
	 (b (ks-apply-matrix m (ks-point (caddr r) (cadddr r))))
	 (x0 (min (<ks-point>-x a) (<ks-point>-x b))) (x1 (max (<ks-point>-x a) (<ks-point>-x b)))
	 (y0 (min (<ks-point>-y a) (<ks-point>-y b))) (y1 (max (<ks-point>-y a) (<ks-point>-y b))))
    (list (lround (+ x0 0.5)) (lround (+ y0 0.5)) (lround (- x1 0.5)) (lround (- y1 0.5)))))

(cond
  ((not (sdl3-library)) (println "SKIP ksworld pixels: no SDL3 library in " *sdl3-libraries*))
  ((not dir) (println "KSWorld.ks's pixels: skipped, MARU_DBJR names no dbjr documents"))
  (else
   (set *ks-font-path* (cons (concat-string dir "/fonts") *ks-font-path*))
   (let* ((r (ksworld-run (concat-string dir "/KSWorld.ks/index.pp") 3))
	  (s (ksworld-session r))
	  (g (gezira-maru 1024 768 4))
	  (win (ksworld-window s g 1024 768))
	  (box (array-at (cdr (assq 'table r)) 204))	; the title, as check/ksworld-mouse.l presses it
	  (layout (ks-slot box 'handler))
	  (m (let ((f ())) (list-do bm (ks-boxes-in (<ksworld-session>-root s)) (and (= box (car bm)) (set f (cdr bm)))) f))
	  (at (lambda (x y) (let ((p (ks-apply-matrix m (ks-point x y)))) (list (<ks-point>-x p) (<ks-point>-y p))))))
     ;; the first frame
     (ksworld-window-step win)
     ;; the bar: a 1 pixel wide light green path at x 662.35 .. 663.35, its coverage of pixel 662 about 0.65. Gezira's
     ;; fill of a transparent paint (alpha 0) before it had set that pixel to 0, and the bar's composite over 0 gives
     ;; (r, g, b, a) = (116, 165, 116, 166) (0xa674a574); a black glyph's fill over it then changes the last bits.
     (expect "the bar pixel (662,130) is the bar's coverage over the transparent pixel, then the glyph"
	     (gezira-pixel g 662 130) -1502304908)
     (expect "the page outside is white" (gezira-pixel g 1000 700) -1)
     ;; a filled shape's colour inside it: the largest opaque coloured path, black
     ;; a filled shape's colour: the largest opaque coloured path, black, 604 .. 626 by 52 .. 66 in the window: some of
     ;; its pixels are black and fully covered (the title's glyphs are on other fills, so not all of them)
     (expect "a filled shape's colour inside it: black pixels among its window pixels"
	     (> (count-pixels g 605 53 624 65 (lambda (px) (= px -16777216))) 0) 't)
     (expect "the page is white where no fill reaches" (count-pixels g 0 0 9 9 (lambda (px) (= px -1))) 100)
     ;; the selection's rectangle: the drag below selects gaps 5 .. 18, so its text is the rectangle from 5 to 17 (the Interval's
     ;; stop is one past the last character), the same rectangle each frame. Its fully covered pixels in the selection's colour
     ;; are the selection as drawn.
     (let* ((c (ks-slot layout 'selectionColor))
	    (a (<ks-color>-a c)) (cr (<ks-color>-r c)) (cg (<ks-color>-g c)) (cb (<ks-color>-b c))
	    (full (argb (byte-of a) (byte-of (* a cr)) (byte-of (* a cg)) (byte-of (* a cb))))
	    (rc (car (ks-text-selection-rects box 5 17)))
	    (w (window-bounds m rc))
	    (selected (lambda () (count-pixels g (car w) (cadr w) (caddr w) (cadddr w) (lambda (px) (= px full))))))
       (println "selection rect " rc " window " w " colour a r g b " a " " cr " " cg " " cb)
       ;; a press puts the caret: a zero-width selection, so nothing of it is drawn; the frame is drawn all the same
       (sdl3-push (cons 'down (concat-list (at 200 13) '(1))))
       (ksworld-window-step win)
       (expect "the press puts a caret, which draws no selection" (selected) 0)
       ;; the drag selects, and the next frame draws the selection: its pixels change between the two frames
       (sdl3-push (cons 'move (at 300 13)))
       (ksworld-window-step win)
       (let ((after-drag (selected)))
	 (expect "the drag's selection is drawn: its pixels in the selection's colour change from the press's frame"
		 (> after-drag 0) 't)
	 ;; the release keeps the selection drawn, and the glyphs drawn over it are darker than it
	 (sdl3-push (cons 'up (concat-list (at 300 13) '(1))))
	 (ksworld-window-step win)
	 (expect "the release keeps the selection drawn" (= (selected) after-drag) 't)
	 (expect "glyphs are darker than the selection they're drawn on"
		 (> (count-pixels g (car w) (cadr w) (caddr w) (cadddr w) (lambda (px) (< (channel px 256) 128))) 0) 't)))
     (ksworld-window-close win)
     (gezira-stop g)))
  )

(println (if ok "ksworld pixels ok" "ksworld pixels FAILED"))
