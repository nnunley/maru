;;; ksworld-text.l -- a text box's spans laid out as KSWorld laid them out: (ks-text-glyphs box) is where each character
;;; goes, a <ks-glyph> (font, glyph, scale, pen x, baseline y, paint) in the box's coordinates, drawn from its TrueType
;;; outline scaled by size / units per em with y flipped.  The box's handler, a KSTextLayout, gives the margins, the
;;; justification, the tab stops and whether lines wrap; a carriage return ends a line.
;;; What KSWorld.ks kept of its own layout (each text box's last line's first character) fixes the rest: lines are a
;;; font's ascent plus its descent plus 2 apart, a character's box is at its glyph's bounding box (pen plus left bearing,
;;; baseline less top), and a line's width, as centring and right justification read it, adds its first glyph's left
;;; bearing.
(require "ksworld-pp.l")
(require "truetype.l")

;; fonts, as a browser finds them: a family falls through to its alternatives, then its generic family, then the last
;; resort, and each of those that has a file (its style's, or else its plain one) in a directory of *ks-font-path* is
;; tried in turn for each character, the first with a glyph for it drawing it
(define ks-font-files
  (list (cons 'TimesNewRoman
	      (list (cons ks-plain	 "Times New Roman")
		    (cons ks-bold	 "Times New Roman Bold")
		    (cons ks-italic	 "Times New Roman Italic")
		    (cons ks-bold-italic "Times New Roman Bold Italic")))
	(cons 'PalatinoLinotype
	      (list (cons ks-plain	 "pala")
		    (cons ks-bold	 "palab")
		    (cons ks-italic	 "palai")
		    (cons ks-bold-italic "palabi")))
	(cons 'Palatino	; a collection: its file, and the face in it
	      (list (cons ks-plain	 '("Palatino" "Palatino"))
		    (cons ks-bold	 '("Palatino" "Palatino Bold"))
		    (cons ks-italic	 '("Palatino" "Palatino Italic"))
		    (cons ks-bold-italic '("Palatino" "Palatino Bold Italic"))))
	(cons 'DejaVuSerif
	      (list (cons ks-plain	 "DejaVuSerif")
		    (cons ks-bold	 "DejaVuSerif-Bold")
		    (cons ks-italic	 "DejaVuSerif-Italic")
		    (cons ks-bold-italic "DejaVuSerif-BoldItalic")))
	(cons 'DejaVuSans
	      (list (cons ks-plain	 "DejaVuSans")
		    (cons ks-bold	 "DejaVuSans-Bold")
		    (cons ks-italic	 "DejaVuSans-Oblique")
		    (cons ks-bold-italic "DejaVuSans-BoldOblique")))))
(define ks-font-alternatives	; a family, what stands in for it, and its generic family
  '((TimesNewRoman serif) (PalatinoLinotype Palatino serif) (Palatino serif) (DejaVuSerif serif) (DejaVuSans sans-serif)
    (serif TimesNewRoman DejaVuSerif) (sans-serif DejaVuSans)))
(define ks-font-last-resort '(DejaVuSans))
(define *ks-font-path* '("/System/Library/Fonts/Supplemental" "/System/Library/Fonts" "/Library/Fonts"
			 "/usr/share/fonts/truetype/msttcorefonts" "/usr/share/fonts/truetype/dejavu"))
(define *ks-fonts* ())	; (path . font), each loaded once

(define-function ks-readable? (path) (= 0 ((subr "access" "si>i") path 4)))

;; the file for a family and style, a .ttf's path or a .ttc's path and face, or () if no directory has it
(define-function ks-font-file (family style)
  (let ((name (cdr (assq style (cdr (assq family ks-font-files))))) (found ()))
    (and name
	 (list-do dir *ks-font-path*
	   (let ((path (if (pair? name) (concat-strings dir "/" (car name) ".ttc") (concat-strings dir "/" name ".ttf"))))
	     (and (not found) (ks-readable? path) (set found (if (pair? name) (cons path (cadr name)) path))))))
    found))

;; the families a family falls through to, in order, each once
(define-function ks-font-chain (family)
  (let ((out ()))
    (let ((visit ()))
      (set visit (lambda (f)
		   (unless (member? f out)
		     (push out f)
		     (list-do g (cdr (assq f ks-font-alternatives)) (visit g)))))
      (visit family)
      (list-do f ks-font-last-resort (visit f)))
    (list-reverse! out)))

(define-function ks-load-font (path)
  (let ((found ()))
    (list-do p *ks-fonts* (and (equal path (car p)) (set found (cdr p))))
    (or found
	(let ((f (if (pair? path) (ttf-load-face (car path) (cdr path)) (ttf-load path))))
	  (set *ks-fonts* (cons (cons path f) *ks-fonts*))
	  f))))

;; every font a family and style can draw with, best first
(define-function ks-fonts (family style)
  (list-do flag ks-emphasis
    (or (= 0 (& style (cdr flag))) (not (= 0 (& (cdr flag) ks-bold-italic))) (error "ksworld-text: no " (car flag) " text yet")))
  (let ((out ()))
    (list-do f (ks-font-chain family)
      (let ((path (or (ks-font-file f style) (ks-font-file f ks-plain))))
	(and path (push out (ks-load-font path)))))
    (or (list-reverse! out) (error "ksworld-text: no font for " family " in style " style ", nor anything to stand in for it"))))
(define-function ks-font (family style) (car (ks-fonts family style)))

;; the font that draws a character: the first with a glyph for it, or the best, with its missing glyph
(define-function ks-char-font (fonts code)
  (let ((found ()))
    (list-do f fonts (and (not found) (< 0 (ttf-glyph f code)) (set found f)))
    (or found (car fonts))))

;; a span's fill, "red green blue alpha" from 0 to 255, as ksworld-paint answers one
(define-function ks-span-paint (fill)
  (let ((v (map (lambda (x) (/ (ks-parse-num x) 255.0)) (ks-split fill 32))))
    (list 'uniform (cadddr v) (car v) (cadr v) (caddr v))))

(define-structure <ks-char> (code font scale paint advance x index letter))
(define-structure <ks-glyph> (font glyph scale x y paint))

;; a text box's letter boxes (its contents, ksworld-pp.l's ks-letter-contents) as characters, each knowing its font,
;; scale, paint, place in the text and letter; letters sharing a font object share its TrueType fonts
(define-function ks-letter-chars (letters)
  (let ((out ()) (index 0) (font-of ()) (fonts ()) (size 0) (paint ()))
    (list-do l letters
      (let ((f (ks-slot l 'font)))
	(unless (= f font-of)
	  (let ()	; a span's font keeps what the document wrote as entries under its keywords
	    (set font-of f)
	    (set fonts (ks-fonts (string->symbol (ks-attr f ':family)) (string->long (ks-attr f ':style))))
	    (set size (string->double (ks-attr f ':size)))
	    (set paint (ks-span-paint (ks-attr f ':fill)))))
	(let* ((code (ks-slot l 'unicode)) (font (ks-char-font fonts code)) (scale (/ size (<ttf>-upem font))))
	  (push out (new <ks-char> code font scale paint (* scale (ttf-advance font (ttf-glyph font code))) 0 index l))
	  (set index (+ index 1)))))
    (list-reverse! out)))

(define-function ks-space? (c) (or (= 32 (<ks-char>-code c)) (= 9 (<ks-char>-code c))))

;; how far a glyph's ink starts from its pen
(define-function ks-left-bearing (c)
  (* (<ks-char>-scale c) (car (ttf-bounds (<ks-char>-font c) (ttf-glyph (<ks-char>-font c) (<ks-char>-code c))))))

;; how far a character moves the pen from x: a tab to the next stop.  The stops (start, stop, step) are from the box's
;; edge, and KSWorld's pen starts at the line's first glyph's left bearing, so origin, where x is 0, is the left margin
;; plus that bearing
(define-function ks-char-width (c x tabs origin)
  (if (and (= 9 (<ks-char>-code c)) tabs)
      (let ((stop (car tabs)) (at (+ x origin)))
	(while (and (<= stop at) (<= stop (cadr tabs))) (set stop (+ stop (caddr tabs))))
	(if (> stop at) (- stop at) (<ks-char>-advance c)))
    (<ks-char>-advance c)))

;; characters into lines, each (hard origin chars...) with chars in order and their pen x set: a carriage return ends a
;; line hard, and a word that runs past width (unless wrapping is off) starts the next one, the space before it ending this
(define-function ks-break-lines (chars width tabs wrap left)
  (let ((lines ()) (line ()) (pen 0) (origin left))
    (let ((finish (lambda (hard) (push lines (cons hard (cons origin (list-reverse! line)))) (set line ()) (set pen 0)))
	  (place (lambda (c)
		   (or line (set origin (+ left (ks-left-bearing c))))
		   (set (<ks-char>-x c) pen)
		   (set pen (+ pen (ks-char-width c pen tabs origin)))
		   (push line c))))
      (list-do c chars
	(cond ((= 13 (<ks-char>-code c)) (finish 1))
	      (else
	       (when (and wrap (not (ks-space? c)) (> (+ pen (ks-char-width c pen tabs origin)) width))
		 (let ((tail ()) (rest line))
		   (while (and rest (not (ks-space? (car rest)))) (push tail (car rest)) (set rest (cdr rest)))
		   (when rest
		     (set line rest)
		     (finish ())
		     (list-do k tail (place k)))))
	       (place c))))
      (finish 1))
    (list-reverse! lines)))

;; a line's characters before its trailing spaces, and how wide they are
(define-function ks-line-ink (chars)
  (let ((backwards ()) (ink ()) (seen ()))
    (list-do c chars (push backwards c))
    (list-do c backwards (and (or seen (not (ks-space? c))) (let () (set seen 1) (push ink c))))
    ink))
(define-function ks-line-width (ink tabs origin)
  (if ink (let ((c (car (last-pair ink)))) (+ (<ks-char>-x c) (ks-char-width c (<ks-char>-x c) tabs origin))) 0))

;; a box holding text: its data are spans and its handler lays them out
;; where KSWorld put a glyph's own box: at its bounding box's top left
(define-function ks-glyph-box (g)
  (let ((b (ttf-bounds (<ks-glyph>-font g) (<ks-glyph>-glyph g))) (s (<ks-glyph>-scale g)))
    (ks-point (+ (<ks-glyph>-x g) (* s (car b))) (- (<ks-glyph>-y g) (* s (cadddr b))))))
(define-function ks-glyph-extent (g)	; as KSWorld's letters kept it: the glyph's advance wide, its ink tall
  (let ((b (ttf-bounds (<ks-glyph>-font g) (<ks-glyph>-glyph g))) (s (<ks-glyph>-scale g)))
    (ks-point (* s (ttf-advance (<ks-glyph>-font g) (<ks-glyph>-glyph g))) (* s (- (cadddr b) (cadr b))))))
;; a letter box placed as KSWorld placed its glyph: its transformation at the glyph's box, its extent and bounds that box
(define-function ks-place-letter (letter g)
  (let ((p (ks-glyph-box g)) (e (ks-glyph-extent g)))
    (ks-set-slot letter 'transformation (ks-matrix 1 0 0 1 (<ks-point>-x p) (<ks-point>-y p)))
    (ks-set-slot letter 'extent e)
    (ks-set-slot letter 'bounds (ks-rect (<ks-point>-x p) (<ks-point>-y p)
					 (+ (<ks-point>-x p) (<ks-point>-x e)) (+ (<ks-point>-y p) (<ks-point>-y e))))))

(define-function ks-text-box? (box)	; a KSTextLayout's box whose contents are letters
  (let ((c (ks-val box 'contents)) (layout (ks-slot box 'handler)))
    (and (ks-object? c) (ks-instance? c 'KSContentsCollection)
	 (ks-object? layout) (ks-instance? layout 'KSTextLayout))))

;; a text box laid out: its glyphs, and its lines, each (top bottom start cells), start the index its first character
;; would have and each cell (index left right) a character's place, spaces too
(define-function ks-text-layout (box)
  (let* ((layout (ks-slot box 'handler))
	 (left (ks-slot layout 'leftMargin)) (top (ks-slot layout 'topMargin))
	 (width (- (- (<ks-point>-x (ks-val box 'extent)) left) (ks-slot layout 'rightMargin)))
	 (justification (string->symbol (ks-slot layout 'justification)))
	 (interval (ks-slot layout 'tabArray))
	 (tabs (and (ks-object? interval) (list (ks-slot interval 'start) (ks-slot interval 'stop) (ks-slot interval 'step))))
	 (chars (ks-letter-chars (ks-items (ks-val box 'contents))))
	 (y top) (out ()) (lines ()) (next 0))
    (list-do line (ks-break-lines chars width tabs (not (= 't (ks-slot layout 'noWrap))) left)
      (let* ((hard (car line)) (origin (cadr line)) (chars (cddr line)) (ink (ks-line-ink chars))
	     (used (if ink (+ (ks-line-width ink tabs origin) (ks-left-bearing (car ink))) 0))
	     (spaces (let ((n 0)) (list-do c ink (and (= 32 (<ks-char>-code c)) (set n (+ n 1)))) n))
	     (offset (cond ((= justification 'center) (/ (- width used) 2))
			   ((= justification 'right) (- width used))
			   (else 0)))
	     (spread (if (and (= justification 'full) (not hard) (< 0 spaces)) (/ (- width (ks-line-width ink tabs origin)) spaces) 0))
	     (ascent 0) (descent 0) (extra 0) (cells ()))
	(list-do c chars
	  (set ascent (max ascent (* (<ks-char>-scale c) (<ttf>-ascent (<ks-char>-font c)))))
	  (set descent (max descent (* (<ks-char>-scale c) (- (<ttf>-descent (<ks-char>-font c)))))))
	(list-do c chars
	  (let ((x (+ (+ left offset) (+ (<ks-char>-x c) extra))))
	    (push cells (list (<ks-char>-index c) x (+ x (ks-char-width c (<ks-char>-x c) tabs origin))))
	    (let ((g (new <ks-glyph> (<ks-char>-font c) (ttf-glyph (<ks-char>-font c) (<ks-char>-code c)) (<ks-char>-scale c)
			  x (+ y ascent) (<ks-char>-paint c))))
	      (ks-place-letter (<ks-char>-letter c) g)
	      (or (ks-space? c) (not (memq c ink)) (push out g)))
	    (and (= 32 (<ks-char>-code c)) (memq c ink) (set extra (+ extra spread)))))
	(push lines (list y (+ (+ y ascent) descent) next (list-reverse! cells)))
	(and chars (set next (+ 1 (<ks-char>-index (car (last-pair chars))))))
	(and hard (set next (+ next 1)))	; past the carriage return, which no line holds
	(set y (+ (+ y ascent) (+ descent 2)))))
    (cons (list-reverse! out) (list-reverse! lines))))
(define-function ks-text-glyphs (box) (car (ks-text-layout box)))

;; the gap a point is nearest, in the box: its line the one it's in (or the nearest), then the first character whose
;; middle is past it
(define-function ks-text-gap (box point)
  (let* ((lines (cdr (ks-text-layout box))) (line (car lines)) (x (<ks-point>-x point)) (y (<ks-point>-y point)) (gap ()))
    (list-do l lines (and (<= (car l) y) (set line l)))
    (set gap (caddr line))
    (list-do cell (cadddr line)
      (and (< (* 0.5 (+ (cadr cell) (caddr cell))) x) (set gap (+ 1 (car cell)))))
    gap))

;; where a selection of the gaps from to to shows: a rectangle (left top right bottom) on each line it covers, a caret
;; one point wide where from is to
(define-function ks-text-selection-rects (box from to)
  (let ((out ()))
    (list-do l (cdr (ks-text-layout box))
      (let ((top (car l)) (bottom (cadr l)) (left ()) (right ()) (end (caddr l)))
	(list-do cell (cadddr l)
	  (when (and (<= from (car cell)) (< (car cell) to))
	    (or left (set left (cadr cell)))
	    (set right (caddr cell)))
	  (and (= (car cell) from) (= from to) (set left (cadr cell)) (set right (+ (cadr cell) 1)))
	  (set end (caddr cell)))
	(and (= from to) (not left) (cadddr l) (= from (+ 1 (car (car (last-pair (cadddr l))))))
	     (set left end) (set right (+ end 1)))
	(and left (push out (list left top right bottom)))))
    (list-reverse! out)))

;; what a Gezira draws for a glyph: its outline as floats, and the matrix from font units to the box
(define-function ks-glyph-floats (g)
  (let* ((beziers (ttf-outline (<ks-glyph>-font g) (<ks-glyph>-glyph g)))
	 (floats (data (* 24 (list-length beziers)))) (i 0))
    (list-do z beziers (list-do v z (set-float-at floats i (* 1.0 v)) (set i (+ i 1))))
    floats))
;; the floats ks-glyph-floats writes: a glyph's outline, counted
(define-function ks-glyph-count (g)
  (let ((n 0))
    (list-do z (ttf-outline (<ks-glyph>-font g) (<ks-glyph>-glyph g)) (set n (+ n (list-length z))))
    n))
(define-function ks-glyph-matrix (g)
  (let ((s (<ks-glyph>-scale g))) (ks-matrix s 0 0 (- s) (<ks-glyph>-x g) (<ks-glyph>-y g))))
