;;; check/gezira-pixels.l -- Gezira's pixels for a set of scenes, printed whole, for comparing two builds of the same
;;; Gezira: the library (build/gezira.dylib, Nile's Maru back end through ir-gen-c.k and cc) and, given IMAGE, a code image
;;; of it compiled by Maru's native back end (check/native-nile.l IMAGE).  The same scenes on one worker and four: a
;;; rectangle with half-covered edges; a rounded shape of quadratic Béziers, rotated, at half alpha over it; an image paint,
;;; filtered, through a rotating texture matrix; a downsample; and premultiplied colours.  Each scene prints its name, then
;;; its words, a line a row.  Two builds agree when the outputs are the same bytes (check.l's native_nile).
;;;   ./eval check/gezira-pixels.l [IMAGE] > OUT
(define gezira-native-image (and *arguments* (pop *arguments*)))
(require "ksworld-pp.l")
(require "gezira-maru.l")

(define size 128)
(define-function floats-of (values)
  (let ((floats (data (* 4 (list-length values)))) (i 0))
    (list-do v values (set-float-at floats i (* 1.0 v)) (set i (+ i 1)))
    floats))
(define-function rectangle (x0 y0 x1 y1)	; sides as Béziers, each start, start, end
  (floats-of (list x0 y0 x0 y0 x1 y0  x1 y0 x1 y0 x1 y1  x1 y1 x1 y1 x0 y1  x0 y1 x0 y1 x0 y0)))
(define rounded	; four quadratic Béziers about the origin, start, control, end
  (floats-of '(0 -30 30 -30 30 0  30 0 30 30 0 30  0 30 -30 30 -30 0  -30 0 -30 -30 0 -30)))
(define-function image (w h f)	; w x h ARGB32 words in C memory, each (f x y)
  (let ((p ((subr "malloc" "l>p") (* 4 (* w h)))))
    (for (y 0 h) (for (x 0 w) (set-int32-at p (+ x (* y w)) (f x y))))
    p))
(define tile (image 8 6 (lambda (x y) (| -16777216 (| (<< (* 30 x) 16) (| (<< (* 40 y) 8) (* 9 (+ x y))))))))

(define-function print-image (name g)
  (println name)
  (for (y 0 size)
    (let ((row ()))
      (for (x 0 size) (push row (gezira-pixel g x y)))
      (apply println (map (lambda (p) (concat-string (long->string p) " ")) (list-reverse! row))))))
(define-function print-words (name p n)
  (println name)
  (let ((row ())) (for (i 0 n) (push row (concat-string (long->string (int32-at p i)) " "))) (apply println (list-reverse! row))))

(list-do workers '(1 4)
  (let ((g (gezira-maru size size workers)))
    (println "workers " workers)
    (gezira-clear g)
    (gezira-fill-path g (ks-matrix 1.0 0.0 0.0 1.0 10.5 20.0) size size (list 'uniform 1.0 1.0 0.0 0.0) (rectangle 0 0 40 30) 24)
    (print-image "rectangle" g)
    (gezira-fill-path g (ks-matrix 0.8 0.6 -0.6 0.8 60.0 64.0) size size (list 'uniform 0.5 0.0 0.8 0.2) rounded 24)
    (print-image "rounded, half alpha, over it" g)
    (gezira-clear g)
    (gezira-fill-path g (ks-matrix 1 0 0 1 0 0) size size (list 'image tile 8 6 (ks-matrix 0.05 0.02 -0.02 0.05 -1.5 -1.0) 1)
		      (rectangle 20 15 110 100) 24)
    (print-image "image paint, filtered, rotated" g)
    (print-words "downsample" (gezira-downsample g tile 8 6) 12)
    (let ((p (image 4 1 (lambda (x y) (| (<< (* 60 (+ x 1)) 24) (| (<< 255 16) (| (<< (* 50 x) 8) 200)))))))
      (gezira-premultiply g p 4)
      (print-words "premultiplied" p 4))
    (gezira-stop g)))
(println "gezira pixels done")
