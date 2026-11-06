;;; png.l: PNGs read to ARGB words.  Our fixtures (check/png/) hold the three kinds of deflate block (stored.png stored,
;;; filters.png fixed Huffman, dynamic.png dynamic) and every row filter, RGBA and RGB (rgb.png); the expected pixels
;;; were worked out separately, through zlib.  With MARU_DBJR, the front page's image too, at five points and in sum.
(require "png.l")
(require "check/temp.l")
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

(let ((dbjr (env-var "MARU_DBJR")))
  (if dbjr
      (let ((img (png-load (concat-string dbjr "/Front page Onward Full v8.ks/64651595172821202997888553198115738008910820758.png"))))
	(expect "the front page's image, size" (list (<png>-width img) (<png>-height img)) '(730 980))
	(expect "the front page's image, pixels" (at-points img '((0 0) (365 490) (729 979) (100 200) (600 50)))
		(list 0xffd85000 0xffccdfe6 0xffc35c1f 0xffffffff 0xffea924a))
	(expect "the front page's image, bytes" (byte-sum img) 668546107))
    (println "png: the front page's image skipped, MARU_DBJR unset")))
(println (if ok "png ok" "png FAILED"))
