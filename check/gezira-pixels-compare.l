;;; check/gezira-pixels-compare.l -- two builds' outputs of check/gezira-pixels.l held to each other within an error
;;; band: the same scenes in the same order, and each word's four 8-bit channels (ARGB32) within EPS (default 1) of the
;;; other's.  Floats rounded differently (a compiler fusing a multiply and an add, rounding once) move a channel by one;
;;; a wrong value moves it further.  Prints, for each scene, the words that differ and the largest channel difference,
;;; then "pixels within N" or each failure.
;;;   ./eval check/gezira-pixels-compare.l A B [EPS]
(require "check/strings.l")
(define failures 0)
(define-function fail (what) (set failures (+ failures 1)) (and (< failures 20) (println "FAIL " what)))

(define-function channel (w k) (& 255 (>> w (* 8 k))))	; channel k of an ARGB32 word: 0 blue … 3 alpha
(define-function channel-difference (a b)	; the largest of the four channels' differences
  (let ((most 0))
    (for (k 0 4) (let ((d (- (channel a k) (channel b k)))) (set most (max most (if (< d 0) (- 0 d) d)))))
    most))

;; the comparison's own cases: a word against itself, one channel by one, by two, and the sign of a 32-bit word
(define-function expect (what got want) (or (= got want) (fail (concat-string what (concat-string ": got " (long->string got))))))
(expect "the same word" (channel-difference -65536 -65536) 0)
(expect "blue one apart" (channel-difference -65536 -65535) 1)
(expect "alpha two apart" (channel-difference -16777216 -50331648) 2)
(expect "a signed word against its unsigned bits" (channel-difference -1 4294967295) 0)
(or (= 0 failures) (error "gezira-pixels-compare: its own cases failed"))

;; two outputs' lines compared: () if they agree within eps, else the first disagreement's description; each scene's
;; differing words and largest difference are printed when report is set
(define-function words-of (line) (map string->long (words line)))
(define-function scene-line? (line) (and (< 0 (string-length line)) (<= ?a (string-at line 0)) (<= (string-at line 0) ?z)))
(define-function compare-lines (a b eps report)
  (let* ((problem ()) (scene "") (differ 0) (most 0) (row 0)
	(close (lambda ()
		 (and report (< 0 (string-length scene)) (< 0 row)
		      (println "  " scene ": " differ " words differ, by at most " most)))))
    (while (and (not problem) (or a b))
      (let ((x (car a)) (y (car b)))
	(cond ((or (not a) (not b))	(set problem (concat-string "one output ends early, in " scene)))
	      ((scene-line? x)
	       (if (not (= 0 (string-compare x y)))
		   (set problem (concat-string "scene " (concat-string x (concat-string " against " y))))
		 (close) (set scene x) (set differ 0) (set most 0) (set row 0)))
	      (else
	       (let ((xs (words-of x)) (ys (words-of y)))
		 (if (not (= (list-length xs) (list-length ys)))
		     (set problem (concat-string "a row's words in " scene))
		   (map (lambda (p q)
			  (let ((d (channel-difference p q)))
			    (and (< 0 d) (set differ (+ differ 1)))
			    (set most (max most d))))
			xs ys)
		   (and (< eps most) (set problem (concat-string scene (concat-string ": a channel " (concat-string (long->string most) (concat-string " apart, row " (long->string row))))))))
		 (set row (+ row 1)))))
	(set a (cdr a)) (set b (cdr b))))
    (or problem (close))
    problem))
;; cases on small outputs: the same; a channel one apart (within 1); two apart; a scene renamed; a word or a line missing
(define-function lines-case (what a b eps want)
  (let ((got (compare-lines a b eps ())))
    (or (if want got (not got)) (fail (concat-string what (if want ": agreed" (concat-string ": " got)))))))
(lines-case "the same" '("rectangle" "-1 -65536 ") '("rectangle" "-1 -65536 ") 1 ())
(lines-case "a channel one apart" '("rectangle" "-1 -65536 ") '("rectangle" "-1 -65535 ") 1 ())
(lines-case "a channel two apart" '("rectangle" "-1 -65536 ") '("rectangle" "-1 -65534 ") 1 't)
(lines-case "a scene renamed" '("rectangle" "-1 ") '("rounded" "-1 ") 1 't)
(lines-case "a word missing" '("rectangle" "-1 -1 ") '("rectangle" "-1 ") 1 't)
(lines-case "a line missing" '("rectangle" "-1 " "-1 ") '("rectangle" "-1 ") 1 't)
(or (= 0 failures) (error "gezira-pixels-compare: its own cases failed"))

;; the two files given
(and *arguments*
     (let* ((a (pop *arguments*)) (b (pop *arguments*)) (eps (if *arguments* (string->long (pop *arguments*)) 1))
	    (problem (compare-lines (lines (contents-of-file-named a)) (lines (contents-of-file-named b)) eps 1)))
       (if problem
	   (error "gezira-pixels-compare: " problem)
	 (println "pixels within " eps))))
