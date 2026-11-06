;;; check/gezira-maru.l -- gezira-maru.l's Gezira on the Maru runtime, through its own selectors: the rectangle of
;;; gezira_image (40 by 30 at (10.5, 20), its edges half covered) filled with a non-identity matrix, on one worker and four,
;;; and the image read back. Prints "gezira maru ok" or each failure.
(require "ksworld-pp.l")
(require "gezira-maru.l")

(define failures 0)
(define-function expect (what ok)
  (if (not ok)
      (let ()
	(set failures (+ failures 1))
	(println "FAIL " what))))

;; the rectangle's corners as Béziers, each side start, start, end
(define rectangle
  (list 0.0 0.0  0.0 0.0  40.0 0.0
	40.0 0.0 40.0 0.0 40.0 30.0
	40.0 30.0 40.0 30.0 0.0 30.0
	0.0 30.0 0.0 30.0 0.0 0.0))

(define-function floats-of (values)
  (let ((floats (data (* 4 24))) (i 0))
    (list-do v values (set-float-at floats i v) (set i (+ i 1)))
    floats))

;; the pixels the rectangle must leave: opaque red inside, half covered red-over-white on the two edge columns, white elsewhere
(define-function rectangle-check (g)
  (let ((count 0) (y 0))
    (while (< y 64)
      (let ((x 0))
	(while (< x 64)
	  (if (not (= -1 (gezira-pixel g x y))) (set count (+ count 1)))
	  (set x (+ x 1))))
      (set y (+ y 1)))
    (expect "1230 pixels are painted" (= count 1230))
    (expect "the interior is opaque red" (= -65536 (gezira-pixel g 30 35)))
    (expect "the left edge is half covered (0xFFFF7F7F)" (= -32897 (gezira-pixel g 10 35)))
    (expect "the right edge is half covered (0xFFFF7F7F)" (= -32897 (gezira-pixel g 50 35)))
    (expect "the pixel left of the edge is untouched" (= -1 (gezira-pixel g 9 35)))
    (expect "the pixel right of the edge is untouched" (= -1 (gezira-pixel g 51 35)))
    (expect "a corner outside is untouched" (= -1 (gezira-pixel g 5 5)))))

(list-do workers '(1 4)
  (let ((g (gezira-maru 64 64 workers)))
    (gezira-clear g)
    (gezira-fill-path g (ks-matrix 1.0 0.0 0.0 1.0 10.5 20.0) 64 64 (list 'uniform 1.0 1.0 0.0 0.0)
		      (floats-of rectangle) 24)
    (rectangle-check g)
    (gezira-stop g)))

(if (= 0 failures)
    (println "gezira maru ok")
    (println failures " failures"))
