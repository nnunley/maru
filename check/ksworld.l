;;; KSWorld documents run headless (ksworld-run.l): a fixture of ours, every stream read and run tick by tick, a send no
;;; method answers named as the failure; and KSWorld.ks, from the dbjr documents MARU_DBJR names (notes/plan/fetch-dbjr).
(require "ksworld-run.l")
(require "ksworld-render.l")
(require "truetype.l")
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

;; the characters a document kept (each its own box, its shape a glyph from TrueType) against what truetype.l reads of the
;; same character from the same font, and each text box's last line, the one KSWorld left laid out, against where
;; ksworld-text.l puts its first character: Times New Roman, which KSWorld.ks's are, where this system has it.
(define-function shape-beziers (shape)
  (let* ((path (car (ks-items (ks-slot shape 'elements)))) (floats (<ks-object>-data (ks-slot path 'floats))) (out ()))
    (for (i 0 (/ (/ (data-length floats) 4) 6))
      (let ((z ())) (for (k 0 6) (push z (float-at floats (+ (* 6 i) k)))) (push out (list-reverse! z))))
    (list-reverse! out)))
(define-function box-style (box) (ks-slot (ks-slot (ks-val box 'font) 'face) 'style))
(define-function near (a b) (let ((d (- a b))) (< (* d d) 0.00000001)))
(define-function laid-out-as-kept (box)
  (let ((c (ks-slot (ks-slot box 'handler) 'lineStart)) (found ()))
    (list-do g (ks-text-glyphs box)
      (let ((p (ks-glyph-box g)) (m (ks-val c 'transformation)))
	(and (= (<ks-glyph>-glyph g) (ttf-glyph (<ks-glyph>-font g) (ks-val c 'unicode)))
	     (near (<ks-point>-x p) (<ks-matrix>-e m)) (near (<ks-point>-y p) (<ks-matrix>-f m))
	     (set found 1))))
    found))
(define-function text-as-kept (table doc)
  (let ((kept 0) (boxes 0))
    (array-do o table
      (when (and (ks-object? o) (= 'KSBox (<ks-object>-class o)) (< 0 (or (ks-val o 'unicode) 0)) (ks-object? (ks-val o 'shape)))
	(set kept (+ kept 1))
	(let ((font (ks-font 'TimesNewRoman (box-style o))))
	  (expect (concat-string "the glyph KSWorld kept for U+" (long->string (ks-val o 'unicode)))
		  (shape-beziers (ks-val o 'shape))
		  (map (lambda (z) (map (lambda (v) (* 1.0 v)) z)) (ttf-outline font (ttf-glyph font (ks-val o 'unicode)))))))
      (when (and (ks-object? o) (= 'KSBox (<ks-object>-class o)) (ks-text-box? o))
	(set boxes (+ boxes 1))
	(expect (concat-strings "text box " (long->string (<ks-object>-ref o)) "'s last line, laid out as KSWorld did")
		(laid-out-as-kept o) 1)))
    (expect "KSWorld.ks's kept glyphs and text boxes, each compared" (list kept boxes) '(5 5))
    (expect "KSWorld.ks: the paths it draws, shapes then each character" (list-length (drawn doc 1024 768)) 934)))

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
	  (set *ks-font-path* (cons (concat-string dir "/fonts") *ks-font-path*))
	  (if (ks-font-file 'TimesNewRoman ks-bold)
	      (text-as-kept (at r 'table) doc)
	    (println "KSWorld.ks's text: skipped, no Times New Roman in " *ks-font-path*)))))))

(println (if ok "ksworld ok" "ksworld FAILED"))
