;;; check/gezira-scene.l -- check/ksworld/scene.pp (one red path, a 10 by 20 rectangle, placed by two transformations: its
;;; composed matrix is 2 0 0 2 105 57) drawn by ksworld-render.l through gezira-maru.l's Gezira: the path covers 20 by 40
;;; pixels exactly (its edges fall on pixel boundaries), inside is opaque red and outside is the white page.
;;; Needs ksworld-render.l and the KSWorld documents' support (kscript.l, ksworld-text.l), which come with main.
;;; Prints "gezira scene ok" or each failure.
(require "ksworld-render.l")
(require "gezira-maru.l")

(define failures 0)
(define-function expect (what ok)
  (if (not ok)
      (let ()
	(set failures (+ failures 1))
	(println "FAIL " what))))

(define root (car (ksworld-load "check/ksworld/scene.pp")))
(define g (gezira-maru 200 200 1))
(gezira-clear g)
(ksworld-render root g 200 200)

(define painted 0)
(for (y 0 200)
  (for (x 0 200)
    (if (not (= -1 (gezira-pixel g x y))) (set painted (+ painted 1)))))
(expect "the placed path covers 800 pixels" (= painted 800))
(expect "inside is opaque red" (= -65536 (gezira-pixel g 110 70)))
(expect "the first row inside is red" (= -65536 (gezira-pixel g 110 57)))
(expect "the last row inside is red" (= -65536 (gezira-pixel g 124 96)))
(expect "left of the path is the page" (= -1 (gezira-pixel g 104 70)))
(expect "right of the path is the page" (= -1 (gezira-pixel g 125 70)))
(expect "above the path is the page" (= -1 (gezira-pixel g 110 56)))
(expect "below the path is the page" (= -1 (gezira-pixel g 110 97)))
(gezira-stop g)

(if (= 0 failures)
    (println "gezira scene ok")
    (println failures " failures"))
