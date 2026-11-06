;;; png.l: PNGs read to ARGB words.  Our fixtures (check/png/) hold the three kinds of deflate block (stored.png stored,
;;; filters.png fixed Huffman, dynamic.png dynamic) and every row filter, RGBA and RGB (rgb.png), and chunks.png the
;;; chunks that carry no pixels (gAMA cHRM sRGB pHYs tEXt zTXt iTXt, a suggested PLTE, a private one, tIME and tEXt after
;;; the data) and the data split over three IDATs; the expected pixels were worked out separately, through zlib.  An
;;; unknown critical chunk, and an ancillary chunk whose CRC is wrong, are refused.  Random images round-trip: written by
;;; png-encode (every filter, stored and fixed Huffman blocks, IDATs of 1 to 64 bytes, tEXt around them) and read back,
;;; each pixel the same.  With MARU_DBJR, the front page's image too, at five points and in sum.
(require "png.l")
(require "check/temp.l")
(require "recover.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function pixels (img)
  (let ((out ()))
    (for (y 0 (<png>-height img)) (for (x 0 (<png>-width img)) (push out (png-pixel img x y))))
    (list-reverse! out)))
(define-function byte-sum (img)
  (let ((s 0) (p (<png>-pixels img))) (for (i 0 (* 4 (* (<png>-width img) (<png>-height img)))) (set s (+ s (byte-at p i)))) s))
(define-function at-points (img points) (map (lambda (xy) (png-pixel img (car xy) (cadr xy))) points))

(define filtered '(352323342 990977837 1629632332 2268286827 874456621 1513111116 2151765611 2790420106 1396589900
		   2035244395 2673898890 3312553385 1918723179 2557377674 3196032169 3834686664 2440856458 3079510953
		   3718165448 61852647))
(expect "filters.png" (pixels (png-load "check/png/filters.png")) filtered)
(expect "stored.png" (pixels (png-load "check/png/stored.png")) filtered)
(expect "rgb.png" (pixels (png-load "check/png/rgb.png")) '(4278850590 4280824380 4282798170 4284174663 4282200873 4280227083))
(let ((img (png-load "check/png/dynamic.png")))
  (expect "dynamic.png's size" (list (<png>-width img) (<png>-height img)) '(24 16))
  (expect "dynamic.png's pixels" (at-points img '((0 0) (23 0) (5 7) (23 15))) '(0 2225160931 1423288959 2691223608))
  ;; the byte sum is of the unfiltered RGBA bytes, the same in any order
  (expect "dynamic.png's bytes" (byte-sum img) 198148))

;; chunks that carry no pixels are skipped, wherever they are, and the data may be split over several IDATs
(expect "chunks.png" (pixels (png-load "check/png/chunks.png"))
	'(3019914360 3693634720 72387784 746108144 1419828248 3306245513 2991243834 3349896979 70525972 1776619837
	  2603854627 2962508028 3978104317 1389296166 3752267639 877446332 2177572271 4009219281 4287483550 1986887125))
;; what can't be skipped is refused, by name
(define-function last-of (l) (if (cdr l) (last-of (cdr l)) (car l)))
(define-function refusal (path) (try (let () (png-load path) "no refusal") (lambda (c) (last-of (cdr c)))))
(expect "an unknown critical chunk" (refusal "check/png/critical.png") "an unknown critical chunk")
(expect "an ancillary chunk's CRC" (refusal "check/png/ancillary-crc.png") "a chunk's CRC doesn't match")

;; hostile input (check/png/bad/, each made to break one rule) is refused, for its own reason, never read past
(list-do case '(("truncated" "the file ends early") ("chunk-length" "the file ends early")
		("no-ihdr" "IHDR isn't the first chunk") ("idat-first" "IHDR isn't the first chunk")
		("ihdr-short" "IHDR isn't 13 bytes") ("zero-width" "the width or height is 0")
		("huge" "the image is too large") ("compression" "a compression or filter method other than 0")
		("filter-method" "a compression or filter method other than 0") ("no-iend" "there is no IEND")
		("fdict" "the image data asks for a preset dictionary") ("no-adler" "the file ends early")
		("stored-nlen" "a stored block's length doesn't match its complement") ("stored-long" "the file ends early")
		("length-286" "a length or distance code no stream may use")
		("distance-30" "a length or distance code no stream may use")
		("oversubscribed" "a Huffman code with more codes than its lengths allow"))
  (expect (concat-string "bad/" (car case)) (refusal (concat-string "check/png/bad/" (concat-string (car case) ".png"))) (cadr case)))

;; the round trip: random images, every filter and both block kinds, IDATs of 1 to 64 bytes, read back pixel for pixel
(define seed 12345)
(define-function random (n) (set seed (% (+ (* seed 1103515245) 12345) 2147483648)) (% (>> seed 8) n))
(define trips 0)
(for (trial 0 120)
  (let* ((w (+ 1 (random 17))) (h (+ 1 (random 13))) (rgba (random 2)) (few (random 2))
	 (img (new <png> w h ((subr "malloc" "l>p") (* 4 (* w h)))))
	 (filters ()) (written ()) (back ()) (same 1))
    (for (k 0 (* w h))	; a few colours make runs for the Huffman blocks to repeat
      (set-int32-at (<png>-pixels img) k
		    (| (if (= rgba 1) (<< (random 256) 24) (<< -1 24))
		       (if (= few 1) (* 1118481 (random 3)) (random 16777216)))))
    (for (y 0 h) (push filters (random 5)))
    (set written (png-encode img rgba filters (random 2) (+ 1 (random 64))))
    (set back (png-decode (car written) (cdr written) "a round trip"))
    (or (and (= w (<png>-width back)) (= h (<png>-height back))) (set same ()))
    (for (k 0 (* w h)) (or (= (int32-at (<png>-pixels img) k) (int32-at (<png>-pixels back) k)) (set same ())))
    (if same (set trips (+ trips 1)) (println "FAIL round trip " trial ": " w "x" h " rgba " rgba " filters " filters))))
(expect "images that round-trip" trips 120)

(let ((dbjr (env-var "MARU_DBJR")))
  (if dbjr
      (let ((img (png-load (concat-string dbjr "/Front page Onward Full v8.ks/64651595172821202997888553198115738008910820758.png"))))
	(expect "the front page's image, size" (list (<png>-width img) (<png>-height img)) '(730 980))
	(expect "the front page's image, pixels" (at-points img '((0 0) (365 490) (729 979) (100 200) (600 50)))
		(list 0xffd85000 0xffccdfe6 0xffc35c1f 0xffffffff 0xffea924a))
	(expect "the front page's image, bytes" (byte-sum img) 668546107))
    (println "png: the front page's image skipped, MARU_DBJR unset")))
(println (if ok "png ok" "png FAILED"))
