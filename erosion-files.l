;;; erosion-files.l -- the files the lines and erosion checks count (doc/measures.md), from any repository's root: tracked or
;;; new but not ignored, outside notes/, here and in the nile and gezira submodules, named with one of the suffixes asked
;;; for (or Makefile), and marked neither derived nor unused in .gitattributes.
(require "spawn.l")

;; files the erosion check can't read whole (they change language partway, or are broken on purpose), so not measured
(define erosion-unread '("compile.l" "gen-asm-x86.k" "maruby.l" "net/structure-diagram.k" "test-pepsi.l" "test-recursion.l"
			 "test-repl.l" "test.l" "check/tpeg-broken.g"))

;; the elements of list pred holds for, in order
(define-function select (pred list) (let ((out ())) (list-do x list (and (pred x) (push out x))) (list-reverse! out)))
;; where sub first occurs in str, or ()
(define-function string-find (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (and (<= i n) i)))
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
    (select (lambda (n) (not (member? n marked))) names)))
(define-function counted-in (root d suffixes)	; the counted files under d, paths from root
  (let* ((dir (if (= d ".") root (concat-strings root "/" d)))
	 (named (select (lambda (f) (named-with? f suffixes))
			(text-lines (cdr (program-result '("git" "ls-files" "-co" "--exclude-standard" "--" "." ":!notes") dir))))))
    (map (lambda (f) (if (= d ".") f (concat-strings d "/" f))) (and named (unmarked dir named)))))
(define-function counted-files-in (root suffixes)
  (concat-list (counted-in root "." suffixes) (concat-list (counted-in root "nile" suffixes) (counted-in root "gezira" suffixes))))
(define-function counted-files (suffixes) (counted-files-in "." suffixes))
(define-function measured-file? (path)	; a file erosion measures: .l, .k or .g, and one it can read whole
  (and (or (ends-with? path ".l") (ends-with? path ".k") (ends-with? path ".g")) (not (member? path erosion-unread))))
;; one path, measured or not, as measured-files would count it: its repository (the superproject, nile or gezira) asked
;; whether it is derived or unused, and notes/ left out
(define-function starts-with? (s prefix) (and (<= (string-length prefix) (string-length s)) (= prefix (string-copy s 0 (string-length prefix)))))
(define-function counted-path? (root path)
  (let* ((sub (cond ((starts-with? path "nile/") "nile") ((starts-with? path "gezira/") "gezira")))
	 (name (if sub (string-copy path (+ 1 (string-length sub)) (- (string-length path) (+ 1 (string-length sub)))) path)))
    (and (measured-file? path) (not (starts-with? name "notes/"))
	 (unmarked (if sub (concat-strings root "/" sub) root) (list name)) 't)))
(define-function measured-files (root) (select measured-file? (counted-files-in root '(".l" ".k" ".g"))))
