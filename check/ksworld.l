;;; KSWorld documents run headless (ksworld-run.l): a fixture of ours, every stream read and run tick by tick, a send no
;;; method answers named as the failure; and KSWorld.ks, from the dbjr documents MARU_DBJR names (notes/plan/fetch-dbjr).
(require "ksworld-run.l")
(require "ksworld-render.l")
(require "check/temp.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function at (r k) (cdr (assq k r)))

(let* ((r (ksworld-run "check/ksworld/tiny.pp" 4))
       (box (array-at (at r 'table) 1)))
  (expect "objects and streams" (list (at r 'objects) (at r 'streams) (at r 'setters) (at r 'code) (at r 'unreadable)) '(5 4 1 3 0))
  (expect "the counter counts the timer's ticks" (ks-val box 'count) 3)
  (expect "evaluations, fired, failed" (list (at r 'evaluations) (at r 'fired) (at r 'failed)) '(12 8 1))
  (expect "a setter keeps the value the document holds" (ks-val box 'label) "hello")
  (expect "a send nothing answers fails its stream, naming kind and selector"
	  (at r 'failures) '(("KScript: no method blink for KSBox" . 1))))

;; what a document draws, asked of a Gezira: here one that records each path it's asked to fill, so the walk is checked
;; with no Gezira built
(define-structure <gezira-recording> (paths))
(define-method gezira-fill-path <gezira-recording> (m width height paint floats count)
  (let ((fs ())) (for (i 0 count) (push fs (float-at floats i)))
    (push self.paths (list (list (<ks-matrix>-a m) (<ks-matrix>-b m) (<ks-matrix>-c m) (<ks-matrix>-d m) (<ks-matrix>-e m) (<ks-matrix>-f m))
			   (list width height) paint (list-reverse! fs)))))
(define-function drawn (doc width height)
  (let ((g (new <gezira-recording> ())))
    (ksworld-render (car (ksworld-load doc)) g width height)
    (list-reverse! (<gezira-recording>-paths g))))

(require "gezira-library.l")	; the Gezira that's libgezira and libnile loads, though nothing here opens the libraries
(expect "the library Gezira is one" (type-of (gezira-library 0 0)) <gezira-library>)
(let ((path (car (drawn "check/ksworld/scene.pp" 200 150))))
  (expect "one path, placed by both transformations composed, clipped to the image, painted red"
	  (list (car path) (cadr path) (caddr path)) '((2.0 0.0 0.0 2.0 105.0 57.0) (200 150) (uniform 1.0 1.0 0.0 0.0)))
  (expect "given as the shape holds it: transforming it is Gezira's"
	  (cadddr path)
	  '(0.0 0.0 0.0 0.0 10.0 0.0 10.0 0.0 10.0 0.0 10.0 20.0 10.0 20.0 10.0 20.0 0.0 20.0 0.0 20.0 0.0 20.0 0.0 0.0)))

(expect "Color's class and its colours answer apart"
	(list (<ks-color>-r (ks-send 'Color 'white () () ())) (try (ks-send 'Color 'lighter () () ()) (lambda (c) (ksw-message c))))
	'(1.0 "KScript: no method lighter for ColorClass"))
(expect "match (the pattern receives it) and sort, as a listing uses them"
	(list (ks-send "*.jpg" 'match '("photo.JPG") () ()) (ks-send "*.jpg" 'match '("a.txt") () ()) (ks-send '(3 1 2) 'sort () () ()))
	'(true false (1 2 3)))
(expect "a value's kind names the failure too"
	(try (ks-send 5 'frobnicate () () ()) (lambda (c) (ksw-message c))) "KScript: no method frobnicate for Number")

(let ((dir (env-var "MARU_DBJR")))	; laid out as tinlizzie.org/dbjr: notes/plan/fetch-dbjr DIR makes one
  (if (not dir)
      (println "KSWorld.ks: skipped, MARU_DBJR names no dbjr documents")
    (let ((doc (concat-string dir "/KSWorld.ks/index.pp")))
      (if (not (= 0 ((subr "access" "si>i") doc 4)))
	  (expect "MARU_DBJR holds KSWorld.ks" doc ())	; named but missing is a failure, not a skip
	(let ((r (ksworld-run doc 3)))
	  (expect "KSWorld.ks: objects and streams" (list (at r 'objects) (at r 'streams) (at r 'setters) (at r 'code) (at r 'unreadable))
		  '(520 346 281 65 0))
	  (expect "KSWorld.ks: what's missing"
		  (at r 'failures)
		  '(("KScript: no method installSelection for KSTextLayout" . 10)
		    ("KScript: no method handlePointerMotion for KSTextLayout" . 5)
		    ("KScript: no method handleButtonDown for KSTextLayout" . 5)))
	  (expect "KSWorld.ks: the paths its boxes' shapes draw, before text" (list-length (drawn doc 1024 768)) 7))))))

(println (if ok "ksworld ok" "ksworld FAILED"))
