;;; erosion-files.l -- the files the lines and erosion checks count (doc/measures.md), from any repository's root: tracked or
;;; new but not ignored, outside notes/, here and in the nile and gezira submodules, named with one of the suffixes asked
;;; for (or Makefile), and marked neither derived nor unused in .gitattributes.
(require "spawn.l")

;; files the erosion check can't read whole (they change language partway, or are broken on purpose), so not measured
(define erosion-unread '("compile.l" "gen-asm-x86.k" "maruby.l" "net/structure-diagram.k" "test-pepsi.l" "test-recursion.l"
			 "test-repl.l" "test.l" "check/tpeg-broken.g"))

(define-function ends-with? (s suffix)
  (and (<= (string-length suffix) (string-length s)) (= suffix (string-copy s (- (string-length s) (string-length suffix)) (string-length suffix)))))
(define-function text-lines (text)	; its lines, each without its newline
  (let ((out ()) (start 0))
    (for (i 0 (string-length text)) (when (= ?\n (string-at text i)) (push out (string-copy text start (- i start))) (set start (+ i 1))))
    (and (< start (string-length text)) (push out (string-copy text start (- (string-length text) start))))
    (list-reverse! out)))
(define-function named-with? (f suffixes)
  (or (ends-with? f "Makefile") (let ((hit ())) (list-do x suffixes (and (ends-with? f x) (set hit 't))) hit)))
(define-function unmarked (dir names)	; those of names check-attr says are neither derived nor unused
  (let ((listed (concat-strings "/tmp/maru-files-" (long->string ((subr "getpid" ">i"))) ".txt")) (marked ()))
    (contents-to-file-named (let ((s "")) (list-do n names (set s (concat-strings s n "\n"))) s) listed)
    ;; check-attr says, for each file and each attribute, path: attribute: value
    (list-do l (text-lines (cdr (program-result '("git" "check-attr" "--stdin" "derived" "unused") dir listed)))
      (or (ends-with? l ": unspecified") (push marked (let ((i 0)) (while (not (= ?: (string-at l i))) (incr i)) (string-copy l 0 i)))))
    ((subr "unlink" "s>i") listed)
    (let ((out ())) (list-do n names (or (member? n marked) (push out n))) (list-reverse! out))))
(define-function counted-in (root d suffixes)	; the counted files under d, paths from root
  (let* ((dir (if (= d ".") root (concat-strings root "/" d)))
	 (named (let ((out ()))
		  (list-do f (text-lines (cdr (program-result '("git" "ls-files" "-co" "--exclude-standard" "--" "." ":!notes") dir)))
		    (and (named-with? f suffixes) (push out f)))
		  (list-reverse! out))))
    (map (lambda (f) (if (= d ".") f (concat-strings d "/" f))) (and named (unmarked dir named)))))
(define-function counted-files-in (root suffixes)
  (concat-list (counted-in root "." suffixes) (concat-list (counted-in root "nile" suffixes) (counted-in root "gezira" suffixes))))
(define-function counted-files (suffixes) (counted-files-in "." suffixes))
(define-function measured-file? (path)	; a file erosion measures: .l, .k or .g, and one it can read whole
  (and (or (ends-with? path ".l") (ends-with? path ".k") (ends-with? path ".g")) (not (member? path erosion-unread))))
(define-function measured-files (root)
  (let ((out ())) (list-do f (counted-files-in root '(".l" ".k" ".g")) (and (measured-file? f) (push out f))) (list-reverse! out)))
