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
	  (at r 'failures) '(("Smalltalk: KSBox does not understand blink" . 1))))

;; what a document draws, asked of a Gezira: here one that records each path it's asked to fill, so the walk is checked
;; with no Gezira built
(define-structure <gezira-recording> (paths))
(define-method gezira-fill-path <gezira-recording> (m width height paint floats count)
  (let ((fs ())) (for (i 0 count) (push fs (float-at floats i)))
    (push self.paths (list (list (<ks-matrix>-a m) (<ks-matrix>-b m) (<ks-matrix>-c m) (<ks-matrix>-d m) (<ks-matrix>-e m) (<ks-matrix>-f m))
			   (list width height) paint (list-reverse! fs)))))
;; and inside clipping stages, each stage (matrix . rectangle) recorded after the path, as the matrices are
(define-method gezira-fill-clipped <gezira-recording> (m stages width height paint floats count)
  (gezira-fill-path self m width height paint floats count)
  (let ((p (car self.paths)) (m6 (lambda (m) (list (<ks-matrix>-a m) (<ks-matrix>-b m) (<ks-matrix>-c m) (<ks-matrix>-d m) (<ks-matrix>-e m) (<ks-matrix>-f m)))))
    (set-car self.paths (concat-list p (list (map (lambda (st) (cons (m6 (car st)) (cdr st))) stages))))))
(define-function drawn (doc width height)
  (let ((g (new <gezira-recording> ())))
    (ksworld-render (car (ksworld-load doc)) g width height)
    (list-reverse! (<gezira-recording>-paths g))))

;; the characters a document kept (each its own box, its shape a glyph from TrueType) against what truetype.l reads of the
;; same character from the same font, and each text box's last line, the one KSWorld left laid out, against where
;; ksworld-text.l puts its first character: Times New Roman, which KSWorld.ks's are, where this system has it.
(define-function shape-beziers (shape)
  (let* ((path (car (ks-items (ks-slot shape 'elements)))) (floats (ks-slot (ks-slot path 'floats) 'data)) (out ()))
    (for (i 0 (/ (ks-slot (ks-slot path 'floats) 'count) 6))
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
(define-function letter-as-kept (box)	; a letter box of box's contents with the kept one's character, bounds and extent
  (let ((c (ks-slot (ks-slot box 'handler) 'lineStart)) (found ()))
    (ks-text-layout box)
    (list-do l (ks-items (ks-val box 'contents))
      (let ((m (ks-val l 'transformation)) (k (ks-val c 'transformation)) (e (ks-val l 'extent)) (ke (ks-val c 'extent)))
	(and (ks-instance? l 'KSBox) (= box (ks-val l 'container)) (= (ks-val c 'unicode) (ks-val l 'unicode))
	     (near (<ks-matrix>-e m) (<ks-matrix>-e k)) (near (<ks-matrix>-f m) (<ks-matrix>-f k))
	     (near (<ks-point>-x e) (<ks-point>-x ke)) (near (<ks-point>-y e) (<ks-point>-y ke))
	     (set found 1))))
    found))
(define-function text-as-kept (table doc)
  (let ((kept 0) (boxes 0))
    (array-do o table
      (when (and (ks-object? o) (ks-instance? o 'KSBox) (< 0 (or (ks-val o 'unicode) 0)) (ks-object? (ks-val o 'shape)))
	(set kept (+ kept 1))
	(let ((font (ks-font 'TimesNewRoman (box-style o))))
	  (expect (concat-string "the glyph KSWorld kept for U+" (long->string (ks-val o 'unicode)))
		  (shape-beziers (ks-val o 'shape))
		  (map (lambda (z) (map (lambda (v) (* 1.0 v)) z)) (ttf-outline font (ttf-glyph font (ks-val o 'unicode)))))))
      (when (and (ks-object? o) (ks-instance? o 'KSBox) (ks-text-box? o))
	(set boxes (+ boxes 1))
	(expect (concat-strings "text box " (long->string (ks-ref o)) "'s last line, laid out as KSWorld did")
		(laid-out-as-kept o) 1)
	;; its contents are letter boxes, as KSWorld read the spans it wrote, and the kept letter's is where KSWorld put it
	(expect (concat-strings "text box " (long->string (ks-ref o)) "'s letters, the kept one placed as KSWorld placed it")
		(letter-as-kept o) 1)))
    (expect "KSWorld.ks's kept glyphs and text boxes, each compared" (list kept boxes) '(5 5))
    ;; its shapes, the carets of the three text boxes it kept showing their selection, and each character
    (expect "KSWorld.ks: the paths it draws, shapes, carets and characters" (list-length (drawn doc 1024 768)) 937)))

;; fonts fall through as a browser's do: Palatino Linotype to Palatino (macOS's, a collection) to the generic serif to
;; the last resort, and a character a font lacks to the next that has it
(expect "a family's fallbacks" (ks-font-chain 'PalatinoLinotype)
	'(PalatinoLinotype Palatino serif TimesNewRoman DejaVuSerif DejaVuSans sans-serif))
(define-function fonts-as-browsers-do (dir)
  (expect "a snowman, which Times New Roman lacks, from DejaVu Sans"
	  (ttf-full-name (ks-char-font (ks-fonts 'TimesNewRoman ks-plain) 9731)) "DejaVu Sans")
  (expect "an unknown family, from the last resort" (map ttf-full-name (ks-fonts 'Nonesuch ks-plain)) '("DejaVu Sans"))
  (when (ks-font-file 'Palatino ks-bold)
    (expect "Palatino Linotype bold, from Palatino's collection" (ttf-full-name (ks-font 'PalatinoLinotype ks-bold)) "Palatino Bold"))
  ;; the front page's text boxes in a font this system has are laid out as KSWorld did (411 a centred line with tabs);
  ;; those in Palatino Linotype aren't (Palatino's metrics are its own)
  (let ((matched ()))
    (array-do o (cadr (ksworld-load (concat-string dir "/Front page Onward Full v8.ks/index.pp")))
      (and (ks-object? o) (ks-instance? o 'KSBox) (ks-text-box? o) (laid-out-as-kept o)
	   (push matched (ks-ref o))))
    (expect "the front page's text boxes laid out as KSWorld did" (list-reverse! matched) '(131 340 411 479))))

(require "gezira-library.l")	; the Gezira that's libgezira and libnile loads, though nothing here opens the libraries
(expect "the library Gezira is one" (type-of (gezira-library 0 0)) <gezira-library>)
(let ((path (car (drawn "check/ksworld/scene.pp" 200 150))))
  (expect "one path, placed by both transformations composed, clipped to the image, painted red"
	  (list (car path) (cadr path) (caddr path)) '((2.0 0.0 0.0 2.0 105.0 57.0) (200 150) (uniform 1.0 1.0 0.0 0.0)))
  (expect "given as the shape holds it: transforming it is Gezira's"
	  (cadddr path)
	  '(0.0 0.0 0.0 0.0 10.0 0.0 10.0 0.0 10.0 0.0 10.0 20.0 10.0 20.0 10.0 20.0 0.0 20.0 0.0 20.0 0.0 20.0 0.0 0.0)))

;; a box whose clipping is on draws what it holds only inside its bounds, as KSBox>>drawOn: clips by drawingBounds: here
;; a 30@20 box at 100@50 holding a square scaled past its bottom edge, and one inside it.  Gezira clips (gezira.l's
;; gezira-fill-clipped): each path goes in the box's own coordinates, inside one stage, the box's matrix and its bounds
(let* ((paths (drawn "check/ksworld/clip.pp" 200 150)) (stage '(((1.0 0.0 0.0 1.0 100.0 50.0) 0 0 30.0 20.0))))
  (expect "what crosses the clip: in the box's coordinates, inside its stage"
	  (list (car (car paths)) (car (cddddr (car paths)))) (list '(2.0 0.0 0.0 2.0 5.0 7.0) stage))
  (expect "what lies inside the clip: the same"
	  (list (car (cadr paths)) (car (cddddr (cadr paths)))) (list '(1.0 0.0 0.0 1.0 5.0 0.0) stage)))
;; a press lands only where the render draws: the square past the box's bottom edge listens, and KSBox>>receive: passes a
;; point on through a clipping box only if the box holds it.  A glyph (a box with a font) doesn't clip, as KSBox>>drawOn:
(let* ((root (car (ksworld-load "check/ksworld/clip.pp"))) (square (ks-items (ks-val root 'contents))))
  (expect "a press on the square inside the box lands on it" (ksworld-box-at root (ks-point 110.0 60.0)) (car square))
  (expect "a press on the square below the box, where nothing is drawn, lands nowhere" (ksworld-box-at root (ks-point 110.0 75.0)) ())
  (expect "a clipping box clips, a clipping glyph doesn't" (list (ks-clips? root) (ks-clips? (caddr square))) '(t ())))

;; a collection a document saved with nil and false elements keeps them, each in its place
(expect "nil and false elements are elements, of a Maru array" (array->list (car (ksworld-load "check/ksworld/nils.pp"))) '(5 () () 7))
(expect "Color's class and its colours answer apart"
	(list (<ks-color>-r (ks-send (ks-class-named 'Color) 'white () () ())) (try (ks-send (ks-class-named 'Color) 'lighter () () ()) (lambda (c) (ksw-message c))))
	'(1.0 "Smalltalk: Color class does not understand lighter"))
(expect "match (the pattern receives it) and sort, as a listing uses them"
	(list (ks-send "*.jpg" 'match '("photo.JPG") () ()) (ks-send "*.jpg" 'match '("a.txt") () ()) (ks-send '(3 1 2) 'sort () () ()))
	'(t () (1 2 3)))
(expect "a value's kind names the failure too"
	(try (ks-send 5 'frobnicate () () ()) (lambda (c) (ksw-message c))) "Smalltalk: Number does not understand frobnicate")

(let ((dir (env-var "MARU_DBJR")))	; laid out as tinlizzie.org/dbjr: notes/plan/fetch-dbjr DIR makes one
  (if (not dir)
      (println "KSWorld.ks: skipped, MARU_DBJR names no dbjr documents")
    (let ((doc (concat-string dir "/KSWorld.ks/index.pp")))
      (if (not (= 0 ((subr "access" "si>i") doc 4)))
	  (expect "MARU_DBJR holds KSWorld.ks" doc ())	; named but missing is a failure, not a skip
	(let ((r (ksworld-run doc 3)))
	  (expect "KSWorld.ks: objects and streams" (list (at r 'objects) (at r 'streams) (at r 'setters) (at r 'code) (at r 'unreadable))
		  '(520 346 281 65 0))
	  (expect "KSWorld.ks: nothing it names is missing (KSTextLayout's handlers are ksworld-events.l's)" (at r 'failures) ())
	  (set *ks-font-path* (cons (concat-string dir "/fonts") *ks-font-path*))
	  (if (ks-font-file 'TimesNewRoman ks-bold)
	      (let () (text-as-kept (at r 'table) doc) (fonts-as-browsers-do dir))
	    (println "KSWorld.ks's text: skipped, no Times New Roman in " *ks-font-path*)))))))

(println (if ok "ksworld ok" "ksworld FAILED"))
