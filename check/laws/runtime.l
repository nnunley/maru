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

(define system (subr "system" "s>i"))
(define-function rt_shell (cmd)
  (or (= 0 (system cmd)) (error "runtime: nonzero exit running " cmd)))

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

(define-function rt_run (mode workers w ints)
  (let* ((dir (rt_env "NILE_LAW_TMP"))
	 (in (concat-strings dir "/in"))
	 (out (concat-strings dir "/out"))
	 (args ""))
    (list-do x ints (set args (concat-strings args " " (long->string x))))
    (rt_shell (concat-strings "printf '%s\\n'" args " > " in))
    (rt_shell (concat-strings (rt_env "NILE_LAW_RUNTIME") " " (long->string workers) " " mode " " (long->string w)
			      " < " in " > " out))
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
(define-function rt_glyphs (n s)
  (let ((out ()) (k 0))
    (while (< k n)
      (push out (+ 1 (% (+ (+ (* k s) k) 3) 7)))
      (push out (if (= 0 (% (+ k s) 3)) 1 0))
      (set k (+ k 1)))
    (list-reverse! out)))

;; sums over a flat list: the elements at offset in each run of step
(define-function rt_every (xs step at)
  (let ((s 0) (i 0))
    (list-do x xs
      (if (= at (% i step)) (set s (+ s x)))
      (set i (+ i 1)))
    s))
(define-function rt_word_width (words) (rt_every words 3 0))
(define-function rt_word_glyphs (words) (rt_every words 3 2))
(define-function rt_glyph_width (glyphs) (rt_every glyphs 2 0))
(define-function rt_glyph_count (glyphs) (/ (list-length glyphs) 2))

;; the words of a line: none of style 1 (those never break), or two or more with a total of at most lw
(define-function rt_line_fits (line lw)
  (let ((total 0) (count 0) (styled ()))
    (list-do t line
      (set total (+ total (car t)))
      (set count (+ count 1))
      (if (= 1 (cadr t)) (set styled 1)))
    (if (or styled (< count 2) (<= total lw)) 1 ())))

;; InsertLineBreaks' output, split at its markers (style 2), each line fits
(define-function rt_lines_fit (words lw)
  (let ((line ()) (ok 1))
    (list-do t (rt_chunks words 3)
      (if (= 2 (cadr t))
	  (let () (if (rt_line_fits line lw) () (set ok ())) (set line ()))
	  (set line (cons t line))))
    (if (rt_line_fits line lw) () (set ok ()))
    (if ok 1 ())))

;; each glyph after one on its line starts where that one ends: x' = x + w, the same y
(define-function rt_contiguous (ps gs)
  (if (and (pair? ps) (pair? (cdr ps)) (pair? gs))
      (if (or (not (= (cadr (car ps)) (cadr (cadr ps))))
	      (= (car (cadr ps)) (+ (car (car ps)) (car (car gs)))))
	  (rt_contiguous (cdr ps) (cdr gs))
	  ())
      1))
(define-function rt_points_contiguous (points glyphs)
  (if (= (list-length points) (list-length glyphs))
      (if (rt_contiguous (rt_chunks points 2) (rt_chunks glyphs 2)) 1 ())
      ()))

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
