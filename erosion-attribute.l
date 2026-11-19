;;; erosion-attribute.l -- how a change moved erosion and verbosity, callable by callable
;;; (doc/rfc/draft-ndn-erosion-attribution-00.md).  diff.g reads the change, git's unified diff or jj's conflict markers,
;;; into the records below.
(require "erosion.l")

(define-structure <hunk> (old-start old-count new-start new-count lines))	; lines: (- text), (+ text), (" " text)
(define-structure <file-diff> (old-path new-path status hunks submodule))	; status: modified added deleted renamed submodule
(define-structure <conflict> (index of sides))
(define-structure <side> (kind label lines))	; kind: diff, snapshot or base; a diff side's label is (from . to)

;; ---- what diff.g's actions make

(define-function diff-strip-side (p)	; a path as --- and +++ write it, less its a/ or b/
  (if (and (< 2 (string-length p)) (= ?/ (string-at p 1))) (string-copy p 2 (- (string-length p) 2)) p))
(define-function diff-header-paths (h)	; (old . new) from "a/P b/Q", for a file with no --- and +++: P and Q the same unless a rename says otherwise
  (let ((n (string-length h)))
    (if (and (< 5 n) (= 1 (& n 1)))	; "a/" P " b/" P is 2 + 2|P| + 3 characters, odd
	(let ((p (string-copy h 2 (/ (- n 5) 2)))) (cons p p))
      (cons h h))))
(define-function diff-header-get (xs key) (let ((v ())) (list-do x xs (and (= key (car x)) (not v) (set v (cdr x)))) v))
(define-function diff-subproject (line)	; "Subproject commit X" -> X
  (and line (< 18 (string-length (cadr line))) (= "Subproject commit " (string-copy (cadr line) 0 18))
       (string-copy (cadr line) 18 (- (string-length (cadr line)) 18))))
(define-function diff-paths (h xs on)	; (old . new): a rename's, else --- and +++'s, else the header's
  (let ((from (diff-header-get xs 'rename-from)))
    (cond (from (cons from (diff-header-get xs 'rename-to))) (on on) (else (diff-header-paths h)))))
(define-function diff-gitlink? (xs)	; a submodule: its index line ends in mode 160000
  (let ((index (diff-header-get xs 'index)))
    (and index (< 7 (string-length index)) (= " 160000" (string-copy index (- (string-length index) 7) 7)))))
(define-function diff-status (xs paths)
  (cond ((diff-gitlink? xs) 'submodule) ((diff-header-get xs 'rename-from) 'renamed)
	((or (diff-header-get xs 'new) (not (car paths))) 'added)
	((or (diff-header-get xs 'deleted) (not (cdr paths))) 'deleted) (else 'modified)))
(define-function diff-commits (hs)	; a submodule's (old . new) commits, from its one hunk
  (let ((ls (<hunk>-lines (car hs)))) (cons (diff-subproject (car ls)) (diff-subproject (cadr ls)))))
(define-function diff-file (h xs on hs)
  (let* ((paths (diff-paths h xs on)) (status (diff-status xs paths)))
    (if (= status 'submodule)
	(new <file-diff> (car paths) (cdr paths) status () (and hs (diff-commits hs)))
      (new <file-diff> (car paths) (cdr paths) status hs ()))))
(define-function diff-lines (ls) (let ((out ())) (list-do l ls (or (= l 'no-newline) (push out l))) (list-reverse! out)))
(define-function diff-hunk (o n ls) (new <hunk> (car o) (cdr o) (car n) (cdr n) (diff-lines ls)))
(define-function diff-conflict (i m ss) (new <conflict> i m ss))
(define-function diff-side (kind label ls) (new <side> kind label (if (= kind 'diff) (diff-lines ls) ls)))
(tpeg-load "diff.g")

;; ---- reading

(define-function diff-read (rule text what)	; what rule reads of all of text, or an error naming the line it stopped at
  (let ((p (text-parser-for-on <diff> text)))
    (rule p)
    (or (= (<text-parser>-position p) (<text-parser>-limit p))
	(let ((line 1))
	  (for (i 0 (<text-parser>-position p)) (and (= ?\n (string-at text i)) (set line (+ line 1))))
	  (error "erosion: can't read " what " past line " line)))
    (<text-parser>-result p)))
(define-function read-diff (text) (diff-read $diff text "the diff"))	; a list of <file-diff>
(define-function read-conflicts (text) (diff-read $conflicted text "the conflicts"))	; common lines and <conflict>s
(define-function select-conflicts (items) (let ((out ())) (list-do x items (or (string? x) (push out x))) (list-reverse! out)))

;; each side's whole file: the common lines with that side's lines in every conflict (a diff side's context and added
;; lines), as (label . text), labelled as jj labels the side (a diff side by the revision it leads to)
(define-function side-at (l i) (while (< 0 i) (set l (cdr l)) (set i (- i 1))) (car l))	; the i-th, from 0
(define-function side-version? (s) (not (= 'base (<side>-kind s))))
(define-function side-name (s) (if (= 'diff (<side>-kind s)) (cdr (<side>-label s)) (<side>-label s)))
(define-function side-text-lines (s)
  (if (= 'diff (<side>-kind s))
      (let ((out ())) (list-do l (<side>-lines s) (or (= '- (car l)) (push out (cadr l)))) (list-reverse! out))
    (<side>-lines s)))
(define-function versions-of (c) (let ((out ())) (list-do s (<conflict>-sides c) (and (side-version? s) (push out s))) (list-reverse! out)))
(define-function conflict-sides (text)
  (let* ((items (read-conflicts text))
	 (first (car (select-conflicts items)))
	 (n (if first (list-length (versions-of first)) 0))
	 (out ()))
    (for (i 0 n)
      (let ((s "") (name ()))
	(list-do x items
	  (if (string? x)
	      (set s (concat-strings s x "\n"))
	    (let ((side (side-at (versions-of x) i)))
	      (or name (set name (side-name side)))
	      (list-do l (side-text-lines side) (set s (concat-strings s l "\n"))))))
	(push out (cons name s))))
    (list-reverse! out)))
