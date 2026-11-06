;;; truetype.l -- glyph outlines from a TrueType font, as the quadratic Béziers Gezira draws: (ttf-load path) reads a font,
;;; (ttf-glyph font code) a character's glyph number, (ttf-outline font glyph) its contours as (x1 y1 x2 y2 x3 y3) in whole
;;; font units (y up), and (ttf-advance font glyph) how far it moves the pen.  A straight segment is written start, start, end,
;;; as KSWorld wrote its own glyphs; two control points in a row imply an on-curve point between them.  Composite glyphs
;;; are their components, moved (and scaled, if they say so).
(define ttf-open	(subr "open" "si>i"))
(define ttf-lseek	(subr "lseek" "ili>l"))
(define ttf-read-c	(subr "read" "ipl>l"))
(define ttf-close	(subr "close" "i>i"))
(define ttf-malloc	(subr "malloc" "l>p"))

(define-structure <ttf> (bytes size upem loca-long glyf loca hmtx metrics cmap ascent descent))

;; the file's bytes in C memory, read whole; byte-at reads them
(define-function ttf-file-bytes (path)
  (let ((fd (ttf-open path 0)))
    (and (< fd 0) (error "truetype: can't open " path))
    (let* ((size (ttf-lseek fd 0 2)) (bytes (ttf-malloc size)) (at 0))
      (ttf-lseek fd 0 0)
      (while (< at size)
	(let ((n (ttf-read-c fd (+ bytes at) (- size at))))
	  (and (<= n 0) (error "truetype: short read of " path))
	  (set at (+ at n))))
      (ttf-close fd)
      (cons bytes size))))

;; big-endian fields
(define-function ttf-u8 (f at) (byte-at (<ttf>-bytes f) at))
(define-function ttf-u16 (f at) (+ (<< (ttf-u8 f at) 8) (ttf-u8 f (+ at 1))))
(define-function ttf-i16 (f at) (let ((v (ttf-u16 f at))) (if (< v 32768) v (- v 65536))))
(define-function ttf-u32 (f at) (+ (<< (ttf-u16 f at) 16) (ttf-u16 f (+ at 2))))
(define-function ttf-i8 (f at) (let ((v (ttf-u8 f at))) (if (< v 128) v (- v 256))))

;; a table's offset, by its four-letter tag, or ()
(define-function ttf-table (f tag)
  (let ((n (ttf-u16 f 4)) (found ()))
    (for (i 0 n)
      (let ((entry (+ 12 (* 16 i))) (same 1))
	(for (k 0 4) (or (= (ttf-u8 f (+ entry k)) (string-at tag k)) (set same ())))
	(and same (not found) (set found (ttf-u32 f (+ entry 8))))))
    found))

;; the cmap subtable for Unicode's basic plane, format 4 (platform 3 encoding 1, or platform 0)
(define-function ttf-cmap4 (f)
  (let* ((cmap (ttf-table f "cmap")) (n (ttf-u16 f (+ cmap 2))) (found ()))
    (for (i 0 n)
      (let* ((rec (+ cmap (+ 4 (* 8 i))))
	     (platform (ttf-u16 f rec)) (encoding (ttf-u16 f (+ rec 2)))
	     (sub (+ cmap (ttf-u32 f (+ rec 4)))))
	(and (not found) (= 4 (ttf-u16 f sub))
	     (or (and (= platform 3) (= encoding 1)) (= platform 0))
	     (set found sub))))
    (or found (error "truetype: no Unicode cmap"))))

(define-function ttf-load (path)
  (let* ((file (ttf-file-bytes path))
	 (f (new <ttf> (car file) (cdr file) 0 () 0 0 0 0 0 0 0)))
    (let ((head (ttf-table f "head")) (hhea (ttf-table f "hhea")))
      (set (<ttf>-upem f) (ttf-u16 f (+ head 18)))
      (set (<ttf>-loca-long f) (= 1 (ttf-i16 f (+ head 50))))
      (set (<ttf>-ascent f) (ttf-i16 f (+ hhea 4)))
      (set (<ttf>-descent f) (ttf-i16 f (+ hhea 6)))
      (set (<ttf>-metrics f) (ttf-u16 f (+ hhea 34))))
    (set (<ttf>-glyf f) (ttf-table f "glyf"))
    (set (<ttf>-loca f) (ttf-table f "loca"))
    (set (<ttf>-hmtx f) (ttf-table f "hmtx"))
    (set (<ttf>-cmap f) (ttf-cmap4 f))
    f))

;; a character's glyph number, 0 (the missing glyph) if the font hasn't one
(define-function ttf-glyph (f code)
  (let* ((sub (<ttf>-cmap f)) (segs (/ (ttf-u16 f (+ sub 6)) 2))
	 (ends (+ sub 14)) (starts (+ ends (+ (* 2 segs) 2))) (deltas (+ starts (* 2 segs))) (ranges (+ deltas (* 2 segs)))
	 (glyph 0) (done ()))
    (for (s 0 segs)
      (unless done
	(when (<= code (ttf-u16 f (+ ends (* 2 s))))
	  (set done 1)
	  (let ((start (ttf-u16 f (+ starts (* 2 s)))))
	    (when (>= code start)
	      (let ((range (ttf-u16 f (+ ranges (* 2 s)))) (delta (ttf-u16 f (+ deltas (* 2 s)))))
		(if (= 0 range)
		    (set glyph (& 65535 (+ code delta)))
		  (let ((g (ttf-u16 f (+ (+ ranges (* 2 s)) (+ range (* 2 (- code start)))))))
		    (set glyph (if (= 0 g) 0 (& 65535 (+ g delta))))))))))))
    glyph))

(define-function ttf-advance (f glyph)
  (ttf-u16 f (+ (<ttf>-hmtx f) (* 4 (min glyph (- (<ttf>-metrics f) 1))))))

(define-function ttf-glyph-offset (f glyph)	; where its data starts in glyf, and where the next glyph's does
  (if (<ttf>-loca-long f)
      (cons (ttf-u32 f (+ (<ttf>-loca f) (* 4 glyph))) (ttf-u32 f (+ (<ttf>-loca f) (* 4 (+ glyph 1)))))
    (cons (* 2 (ttf-u16 f (+ (<ttf>-loca f) (* 2 glyph)))) (* 2 (ttf-u16 f (+ (<ttf>-loca f) (* 2 (+ glyph 1))))))))

(define-function last-pair (l) (if (cdr l) (last-pair (cdr l)) l))
(define-function ttf-bit? (flags bit) (!= 0 (& flags bit)))	; 0 is true in Maru, so a bit is tested this way
;; between two control points, the point on the curve they imply, in whole font units rounded down, as KSWorld's own glyphs have it
(define-function ttf-mid (a b) (let ((s (+ a b))) (if (< s 0) (/ (- s 1) 2) (/ s 2))))
(define ttf-composite)	; components are outlines too: ttf-outline and it call each other

;; a simple glyph's points: (x y on-curve) each, and the index of each contour's last point
(define-function ttf-simple-points (f at contours)
  (let* ((ends (let ((out ())) (for (c 0 contours) (push out (ttf-u16 f (+ at (+ 10 (* 2 c)))))) (list-reverse! out)))
	 (count (+ 1 (car (last-pair ends))))
	 (p (+ at (+ 10 (* 2 contours))))
	 (p (+ p (+ 2 (ttf-u16 f p))))	; past the instructions
	 (flags ()) (xs ()) (ys ()))
    ;; flags, each maybe repeated
    (while (< (list-length flags) count)
      (let ((flag (ttf-u8 f p)))
	(set p (+ p 1))
	(push flags flag)
	(when (ttf-bit? flag 8)
	  (let ((repeat (ttf-u8 f p)))
	    (set p (+ p 1))
	    (for (r 0 repeat) (push flags flag))))))
    (set flags (list-reverse! flags))
    ;; coordinates as deltas: a byte whose sign the flag gives, unchanged, or a signed word
    (let ((coordinates (lambda (short same)
			 (let ((v 0) (out ()))
			   (list-do flag flags
			     (cond ((ttf-bit? flag short) (set v (+ v (if (ttf-bit? flag same) (ttf-u8 f p) (- (ttf-u8 f p))))) (set p (+ p 1)))
				   ((ttf-bit? flag same))
				   (else (set v (+ v (ttf-i16 f p))) (set p (+ p 2))))
			     (push out v))
			   (list-reverse! out)))))
      (set xs (coordinates 2 16))
      (set ys (coordinates 4 32)))
    (let ((points ()))
      (while flags
	(push points (list (car xs) (car ys) (& (car flags) 1)))
	(set flags (cdr flags)) (set xs (cdr xs)) (set ys (cdr ys)))
      (cons (list-reverse! points) ends))))


;; one contour's points to Béziers: start on a point that's on the curve (or between two that aren't)
(define-function ttf-contour-beziers (points)
  (let* ((n (list-length points))
	 (at (lambda (i) (let ((l points) (k (% i n))) (while (< 0 k) (set l (cdr l)) (set k (- k 1))) (car l))))
	 (first (let ((i 0)) (while (and (< i n) (= 0 (caddr (at i)))) (set i (+ i 1))) i))
	 (start (if (< first n)
		    (let ((p (at first))) (list (car p) (cadr p)))
		  (list (ttf-mid (car (at 0)) (car (at 1))) (ttf-mid (cadr (at 0)) (cadr (at 1))))))
	 (pen start) (control ()) (out ()))
    (for (k 1 (+ n 1))
      (let* ((p (at (+ (if (< first n) first 0) k)))
	     (x (car p)) (y (cadr p)))
	(if (= 1 (caddr p))
	    (let ((c (or control pen)))
	      (push out (list (car pen) (cadr pen) (car c) (cadr c) x y))
	      (set pen (list x y)) (set control ()))
	  (if control
	      (let ((mx (ttf-mid (car control) x)) (my (ttf-mid (cadr control) y)))
		(push out (list (car pen) (cadr pen) (car control) (cadr control) mx my))
		(set pen (list mx my)) (set control (list x y)))
	    (set control (list x y))))))
    (and control (push out (list (car pen) (cadr pen) (car control) (cadr control) (car start) (cadr start))))
    (list-reverse! out)))

;; a glyph's bounding box, (x-min y-min x-max y-max) in font units; all 0 for one with no outline
(define-function ttf-bounds (f glyph)
  (let* ((where (ttf-glyph-offset f glyph)) (at (+ (<ttf>-glyf f) (car where))))
    (if (= (car where) (cdr where))
	'(0 0 0 0)
      (list (ttf-i16 f (+ at 2)) (ttf-i16 f (+ at 4)) (ttf-i16 f (+ at 6)) (ttf-i16 f (+ at 8))))))

(define-function ttf-outline (f glyph)
  (let* ((where (ttf-glyph-offset f glyph)) (at (+ (<ttf>-glyf f) (car where))))
    (if (= (car where) (cdr where))
	()	; no outline: a space
      (let ((contours (ttf-i16 f at)))
	(if (>= contours 0)
	    (let* ((pe (ttf-simple-points f at contours)) (points (car pe)) (out ()) (from 0))
	      (list-do end (cdr pe)
		(let ((contour ()) (i 0))
		  (list-do p points (and (<= from i) (<= i end) (push contour p)) (set i (+ i 1)))
		  (set out (concat-list out (ttf-contour-beziers (list-reverse! contour))))
		  (set from (+ end 1))))
	      out)
	  (ttf-composite f (+ at 10)))))))

;; a composite glyph: its components, each moved by its offsets and scaled if it says so
(define-function ttf-composite (f p)
  (let ((out ()) (more 1))
    (while more
      (let* ((flags (ttf-u16 f p)) (glyph (ttf-u16 f (+ p 2))) (words (ttf-bit? flags 1)) (q (+ p 4))
	     (dx (if words (ttf-i16 f q) (ttf-i8 f q)))
	     (dy (if words (ttf-i16 f (+ q 2)) (ttf-i8 f (+ q 1))))
	     (q (+ q (if words 4 2)))
	     (a 1.0) (b 0.0) (c 0.0) (d 1.0)
	     (f2dot14 (lambda (at) (/ (ttf-i16 f at) 16384.0))))
	(cond ((ttf-bit? flags 8) (set a (f2dot14 q)) (set d a) (set q (+ q 2)))
	      ((ttf-bit? flags 64) (set a (f2dot14 q)) (set d (f2dot14 (+ q 2))) (set q (+ q 4)))
	      ((ttf-bit? flags 128) (set a (f2dot14 q)) (set b (f2dot14 (+ q 2))) (set c (f2dot14 (+ q 4))) (set d (f2dot14 (+ q 6))) (set q (+ q 8))))
	(list-do z (ttf-outline f glyph)
	  (let ((tx (lambda (x y) (+ (+ (* a x) (* c y)) dx))) (ty (lambda (x y) (+ (+ (* b x) (* d y)) dy))))
	    (push out (list (tx (car z) (cadr z)) (ty (car z) (cadr z))
			    (tx (caddr z) (cadddr z)) (ty (caddr z) (cadddr z))
			    (tx (car (cddddr z)) (cadr (cddddr z))) (ty (car (cddddr z)) (cadr (cddddr z)))))))
	(set more (ttf-bit? flags 32))
	(set p q)))
    (list-reverse! out)))
