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

;; the rectangle inside clipping stages (gezira_fill_clipped), as GeziraCanvas clips: in a stage at (10, 20) whose rectangle
;; is 20 by 15, only that part of it; in a stage turned a quarter (x' = 40 - y, y' = x + 10) whose rectangle is 10 by 30
;; in its own coordinates, the part of it that rectangle holds, from x 10 to 40 and y 10 to 20 in the image
(let ((g (gezira-maru 64 64 1)) (red (list 'uniform 1.0 1.0 0.0 0.0)))
  (gezira-clear g)
  (gezira-fill-clipped g (ks-matrix 1.0 0.0 0.0 1.0 0.0 0.0) (list (cons (ks-matrix 1.0 0.0 0.0 1.0 10.0 20.0) '(0 0 20 15))) 64 64 red
		       (floats-of rectangle) 24)
  (expect "inside the stage's rectangle, red" (= (gezira-pixel g 15 25) (gezira-pixel g 25 30)))
  (expect "inside the stage's rectangle, painted" (not (= -1 (gezira-pixel g 15 25))))
  (expect "the rectangle past the stage's right edge, untouched" (= -1 (gezira-pixel g 35 25)))
  (expect "the rectangle past the stage's bottom edge, untouched" (= -1 (gezira-pixel g 15 40)))
  (gezira-clear g)
  (gezira-fill-clipped g (ks-matrix 1.0 0.0 0.0 1.0 0.0 0.0) (list (cons (ks-matrix 0.0 1.0 -1.0 0.0 40.0 10.0) '(0 0 10 30))) 64 64 red
		       (floats-of rectangle) 24)
  (expect "a turned stage: inside its rectangle, painted" (not (= -1 (gezira-pixel g 25 15))))
  (expect "a turned stage: the rectangle outside its rectangle, untouched" (= -1 (gezira-pixel g 25 25)))
  (expect "a turned stage: nothing past its own right edge" (= -1 (gezira-pixel g 45 15)))
  ;; stages counted but not given are refused (BAD_ARG, 2), before anything is drawn
  (gezira-clear g)
  (expect "a stage counted but not given, refused"
	  (= 2 (gezira-fill-clipped-entry (<gezira-maru>-init g) (<gezira-maru>-image g) 64 64
					  (gezira-params (ks-matrix 1.0 0.0 0.0 1.0 0.0 0.0) red) (floats-of rectangle) 24 0 1)))
  (expect "and nothing drawn" (= -1 (gezira-pixel g 25 30)))
  (gezira-stop g))

(if (= 0 failures)
    (println "gezira maru ok")
    (println failures " failures"))
