;;; runtime.l -- the Nile runtime's built-ins and text-layout.nl's pipeline, run through the batch
;;; driver nile/runtimes/maru/test/law-runtime.k, for check/laws/runtime.law.
;;;   (run_on kind workers xs)        the built-in KIND over the integers xs (pass, reverse, sort, dupcat, dupzip)
;;;   (layout kind workers w glyphs)  the layout KIND (words, breaks, points) at line width w over the flat
;;;                                   glyph pairs (width, style) of glyphs
;;; NILE_LAW_RUNTIME names the driver's binary and NILE_LAW_TMP a directory for its input and output (check.l's
;;; nile_laws case sets both). A run that exits nonzero is an error, not a verdict.
;;; The generators (rt_input, rt_pairs, rt_glyphs) are pure Maru from (n, s), so a law's values are reproducible
;;; from its numbers and the seed, and the expected values are the laws' own, from the source's rules.

(define-function rt_env (name)
  (let ((p ((subr "getenv" "s>p") name)) (chars ()) (i 0))
    (or (and p (!= 0 p)) (error name " is not set"))
    (while (< 0 (byte-at p i)) (push chars (byte-at p i)) (set i (+ i 1)))
    (list->string (list-reverse! chars))))

(require "spawn.l")
(define-function rt_run_program (argv in out err)	; the driver run to its end, or an error naming it
  (or (= 0 (program-status argv in out err)) (error "runtime: nonzero exit running " argv)))
(define fopen (subr "fopen" "ss>p"))
(define fprintf (subr "fprintf" "ps.>i"))
(define fclose (subr "fclose" "p>i"))

;; the output's integers, one per line
(define-function rt_numbers (text)
  (let ((out ()) (start 0) (i 0) (n (string-length text)))
    (while (<= i n)
      (let ((c (if (< i n) (string-at text i) 10)))
	(if (= c 10)
	    (let ()
	      (if (< start i) (push out (string->long (string-copy text start (- i start)))))
	      (set start (+ i 1)))))
      (set i (+ i 1)))
    (list-reverse! out)))

;; the integers go in through a file written with fprintf: concat-strings over a long input cost 60 ms a run
(define-function rt_run (mode workers w ints)
  (let* ((dir (rt_env "NILE_LAW_TMP"))
	 (in (concat-strings dir "/in"))
	 (out (concat-strings dir "/out"))
	 (f (fopen in "w")))
    (or (and f (!= 0 f)) (error "runtime: can't write " in))
    (list-do x ints (fprintf f "%ld\n" x))
    (fclose f)
    (rt_run_program (list (rt_env "NILE_LAW_RUNTIME") (long->string workers) mode (long->string w)) in out ())
    (rt_numbers (contents-of-file-named out))))

(define-function run_on (kind workers xs) (rt_run kind workers 10 xs))
(define-function layout (kind workers w glyphs) (rt_run kind workers w glyphs))

;; (flat) lists in order
(define-function rt_reverse (xs) (let ((out ())) (list-do x xs (set out (cons x out))) out))
(define-function rt_append (xs ys) (let ((out ys)) (list-do x (rt_reverse xs) (set out (cons x out))) out))
(define-function rt_interleave (xs ys)
  (if (and (pair? xs) (pair? ys))
      (cons (car xs) (cons (car ys) (rt_interleave (cdr xs) (cdr ys))))
      ()))
(define-function rt_chunks (xs k)	; xs in runs of k
  (let ((out ()) (cur ()) (i 0))
    (list-do x xs
      (set cur (cons x cur))
      (set i (+ i 1))
      (if (= 0 (% i k))
	  (let () (push out (list-reverse! cur)) (set cur ()))))
    (list-reverse! out)))

;; the generators: n integers for seed s, (k*s + 7*k*k) mod 97 - 48 at k; pairs of (value, index); glyphs of
;; (width 1..7, style 0 or 1) from k, s
(define-function rt_input (n s)
  (let ((out ()) (k (- n 1)))
    (while (>= k 0)
      (push out (- (% (+ (* k s) (* 7 (* k k))) 97) 48))
      (set k (- k 1)))
    out))
(define-function rt_pairs (n s)
  (let ((out ()) (k 0))
    (list-do x (rt_input n s)
      (push out x)
      (push out k)
      (set k (+ k 1)))
    (list-reverse! out)))
;; glyphs from a linear congruential sequence started at s, x' = (75 x + 74) mod 65537: a glyph's style is 1 when x mod 10
;; is under 3, its width 1 + (x / 10) mod 7, so runs of either style have no fixed length
(define-function rt_glyphs (n s)
  (let ((out ()) (k 0) (x s))
    (while (< k n)
      (set x (% (+ (* 75 x) 74) 65537))
      (push out (+ 1 (% (/ x 10) 7)))
      (push out (if (< (% x 10) 3) 1 0))
      (set k (+ k 1)))
    (list-reverse! out)))

;; sums over a flat list: the elements at offset in each run of step
(define-function rt_every (xs step at)
  (let ((s 0) (i 0))
    (list-do x xs
      (if (= at (% i step)) (set s (+ s x)))
      (set i (+ i 1)))
    s))
(define-function rt_word_glyphs (words) (rt_every words 3 2))
(define-function rt_glyph_count (glyphs) (/ (list-length glyphs) 2))

;; MakeWords, text-layout.nl:8: a glyph G starts a new word after W when G.s /= W.s, W.s = 2 or W.w + G.w > w
(define-function rt_splits (W G lw)
  (or (not (= (cadr G) (cadr W))) (= 2 (cadr W)) (> (+ (car W) (car G)) lw)))
;; the words partition the glyphs: each word is the next n of them, all of its style, its width their sum; a word of
;; two or more is at most lw wide (each glyph joined it with W.w + G.w <= w); the first glyph of each word splits from the
;; word before it; and the initial (0, 0, 0) is output only if the first glyph splits from it, or there are no glyphs
(define-function rt_words_partition (words glyphs lw)
  (let ((gs (rt_chunks glyphs 2)) (prev '(0 0 0)) (first 1) (ok 1))
    (or words (set ok ()))
    (list-do W (rt_chunks words 3)
      (if (= 0 (caddr W))
	  (or (and first (equal W '(0 0 0)) (or (not gs) (rt_splits prev (car gs) lw))) (set ok ()))
	  (let ((n (caddr W)) (width 0))
	    (if first
		(and gs (rt_splits prev (car gs) lw) (set ok ()))
		(or (and gs (rt_splits prev (car gs) lw)) (set ok ())))
	    (while (and ok (< 0 n))
	      (if (and gs (= (cadr (car gs)) (cadr W)))
		  (let () (set width (+ width (car (car gs)))) (set gs (cdr gs)))
		  (set ok ()))
	      (set n (- n 1)))
	    (or (= width (car W)) (set ok ()))
	    (and (< 1 (caddr W)) (> (car W) lw) (set ok ()))))
      (set prev W)
      (set first ()))
    (and gs (set ok ()))
    (if ok 1 ())))

;; InsertLineBreaks, text-layout.nl:21: over the line's offset o, a word that continues its line (no marker, style 2, just
;; before it) is style 1 or fits, o + W.w <= w; a marker comes before a word that is not style 1 and doesn't fit, and only
;; there: never last, never twice.  Its output is never empty, and either way the word adds to o, from 0 after a marker
(define-function rt_breaks_walk (words lw nofit nomax)	; nofit, nomax: 1 leaves that half unchecked
  (let ((o 0) (marked ()) (ok (and (pair? words) (= 0 (% (list-length words) 3)))))	; MakeWords outputs a word at least
    (list-do W (rt_chunks words 3)
      (cond
	((= 2 (cadr W))	(and marked (not nomax) (set ok ())) (set marked 1))
	(marked		(or (and (not (= 1 (cadr W))) (> (+ o (car W)) lw)) nomax (set ok ()))
			(set o (car W))
			(set marked ()))
	(else		(or (= 1 (cadr W)) (<= (+ o (car W)) lw) nofit (set ok ()))
			(set o (+ o (car W))))))
    (and marked (not nomax) (set ok ()))
    (if ok 1 ())))
(define-function rt_breaks_fit (words lw) (rt_breaks_walk words lw () 1))
(define-function rt_breaks_maximal (words lw) (rt_breaks_walk words lw 1 ()))
;; the words without InsertLineBreaks' markers
(define-function rt_unbroken (words)
  (let ((out ()))
    (list-do W (rt_chunks words 3)
      (or (= 2 (cadr W)) (set out (concat-list (rt_reverse W) out))))
    (list-reverse! out)))

;; PlaceWords, RepeatPlacement and PlaceGlyphs, text-layout.nl:29-55, at b = (0, 0) and h = 1: each glyph's point is
;; (the width of the glyphs before it on its line, the line's number), a marker starting the next line
(define-function rt_placed (words glyphs)
  (let ((gs (rt_chunks glyphs 2)) (x 0) (y 0) (out ()))
    (list-do W (rt_chunks words 3)
      (if (= 2 (cadr W))
	  (let () (set x 0) (set y (+ y 1)))
	  (let ((n (caddr W)))
	    (while (and gs (< 0 n))
	      (push out x)
	      (push out y)
	      (set x (+ x (car (car gs))))
	      (set gs (cdr gs))
	      (set n (- n 1))))))
    (list-reverse! out)))

;; keys (field 0 of each pair) nondecreasing; the pairs as codes key * 1000 + payload, and sorted codes
(define-function rt_keys_ordered (out xs)	; out holds xs' pairs, in key order, and no more or fewer
  (let ((ps (rt_chunks out 2)) (ok (= (list-length out) (list-length xs))) (first 1) (prev 0))
    (list-do p ps
      (if (and (= first 0) (< (car p) prev)) (set ok ()))
      (set first 0)
      (set prev (car p)))
    (if ok 1 ())))
;; a built-in's output has as many floats as its input, twice over for the duplicators
(define-function rt_count_is (out kind xs)
  (let ((factor (if (or (equal kind "dupcat") (equal kind "dupzip")) 2 1)))
    (if (= (list-length out) (* factor (list-length xs))) 1 ())))
;; a layout's output: the glyphs' count in its words, or a point for each glyph's two floats
(define-function rt_layout_count (kind out glyphs)
  (if (equal kind "points")
      (if (= (list-length out) (list-length glyphs)) 1 ())
      (if (= (rt_word_glyphs out) (rt_glyph_count glyphs)) 1 ())))
(define-function rt_codes (pairs)
  (let ((out ()))
    (list-do p (rt_chunks pairs 2) (set out (cons (+ (* 1000 (car p)) (cadr p)) out)))
    out))
(define-function rt_insert (x sorted)
  (if (and (pair? sorted) (< (car sorted) x))
      (cons (car sorted) (rt_insert x (cdr sorted)))
      (cons x sorted)))
(define-function rt_sorted (xs)
  (let ((out ()))
    (list-do x xs (set out (rt_insert x out)))
    out))

;;; Schedules (check/laws/runtime-schedules.law). A schedule is the term the law's rules generate, pct(priorities, changes):
;;; the driver's threads take turns by that PCT schedule in full (nile_schedule_pct: slot i starts at priority i of the
;;; list, and at each turn in changes the running thread drops below every other), so a refutation names an interleaving
;;; that runs again, and shrinking the term shrinks the schedule. The claim is the law file's; here is only the run.

;; the driver's argument for a schedule: a number is a seed, as is; a term pct(P, C) is "pct:P0,P1,.../C1,C2,..."
(define-function rt_pct_text (s)
  (if (long? s)
      (long->string s)
      (let ((text "pct:") (sep ""))
	(list-do p (cadr s) (set text (concat-strings text sep (long->string p))) (set sep ","))
	(set text (concat-strings text "/")) (set sep "")
	(list-do c (caddr s) (set text (concat-strings text sep (long->string c))) (set sep ","))
	text)))

;; the driver's run of kind on workers threads, line width w, input ints, under schedule s: a record of its contracts
;; (dropped, requeued, unreturned, deadlocks: the driver's last line) and its output
(define-function scheduled (kind workers w ints s)
  (let* ((dir (rt_env "NILE_LAW_TMP"))
	 (in (concat-strings dir "/in"))
	 (out (concat-strings dir "/out"))
	 (f (fopen in "w")))
    (or (and f (!= 0 f)) (error "runtime: can't write " in))
    (list-do x ints (fprintf f "%ld\n" x))
    (fclose f)
    (rt_run_program (list (rt_env "NILE_LAW_RUNTIME") (long->string workers) kind (long->string w) (rt_pct_text s)) in out "/dev/null")
    (let* ((text (contents-of-file-named out))
	   (end (string-length text))
	   (k (- end 2)))
      (while (and (>= k 0) (!= 10 (string-at text k))) (set k (- k 1)))	; the start of the last line, "contracts D R U K"
      (let ((counts (string-copy text (+ k 11) (- end (+ k 11)))))
	(for (i 0 (string-length counts))	; the four counts are on one line: one to a line, as rt_numbers reads them
	  (and (= 32 (string-at counts i)) (set-string-at counts i 10)))
	(law-record "contracts" (rt_numbers counts)
		    "output" (rt_numbers (string-copy text 0 (+ k 1))))))))
