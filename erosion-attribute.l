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

;; ---- measuring a change's files, each text written under the scratch directory at its own relative path

(define-structure <change> (path old-path base-text current-text added removed))	; added, removed: line numbers
(define-structure <move> (path name edited cc-before cc-after forms-before forms-after flagged-before flagged-after))
(define-structure <attribution> (erosion verbosity moves rebuilt))	; each metric (base now whole edited share), per mille

(define-function attribution-scratch ()	; MARU_CHECK_TMP's attribution/, else one of this process's own under /tmp
  (concat-strings (if (= "/tmp" (erosion-scratch)) (concat-strings "/tmp/maru-attribution-" (long->string (erosion-getpid)))
		    (erosion-scratch))
		  "/attribution"))
(define-function scratch-write (side path text)	; text written at side/path under the scratch directory; its file's path
  (let* ((file (concat-strings (attribution-scratch) "/" side "/" path)) (slash (string-length file)))
    (while (not (= ?/ (string-at file (- slash 1)))) (set slash (- slash 1)))
    (make-directory (string-copy file 0 slash))
    (contents-to-file-named text file)
    file))
(define-function measure-texts (pairs)	; erosion-of over ((path . text) ...), each read by erosion-read-file
  (erosion-of (map (lambda (p) (cons (car p) (erosion-read-file (scratch-write "now" (car p) (cdr p))))) pairs)))
(define-function measure-one (side path text)	; one file's metrics, or () for no text
  (and text (erosion-of (list (cons path (erosion-read-file (scratch-write side path text)))))))

;; a change from two texts: git's line diff of them (--no-index), read by diff.g, gives its added and removed lines
(define-function hunk-lines (hs start count)	; the numbers a list of hunks' sides cover
  (let ((out ()))
    (list-do h hs (for (i 0 (count h)) (push out (+ i (start h)))))
    (list-reverse! out)))
(define-function text-change (path old-path base current)
  (let* ((a (if base (scratch-write "base" old-path base) "/dev/null"))
	 (b (if current (scratch-write "now" path current) "/dev/null"))
	 (fd (car (read-diff (program-output (list "git" "diff" "--no-index" "--unified=0" "--no-color" a b)))))
	 (hs (and fd (<file-diff>-hunks fd))))
    (make <change> path: path old-path: old-path base-text: base current-text: current
	  added: (hunk-lines hs (lambda (h) (<hunk>-new-start h)) (lambda (h) (<hunk>-new-count h)))
	  removed: (hunk-lines hs (lambda (h) (<hunk>-old-start h)) (lambda (h) (<hunk>-old-count h))))))

;; ---- matching and edits

(define-function callables-of-metrics (m) (if m (<erosion-metrics>-callables m) ()))
(define-function take-named (name cs)	; the first callable of that name in cs, and cs without it
  (let ((hit ()) (rest ()))
    (list-do c cs (if (and (not hit) (= name (<callable>-name c))) (set hit c) (push rest c)))
    (cons hit (list-reverse! rest))))
(define-function match-callables (before after)	; ((b . a) ...): same name, in order; () where one side has none
  (let ((pairs ()))
    (list-do b before
      (let ((t (take-named (<callable>-name b) after))) (push pairs (cons b (car t))) (set after (cdr t))))
    (list-do a after (push pairs (cons () a)))
    (list-reverse! pairs)))
(define-function touched? (c lines)	; a line of lines within c's
  (let ((hit ())) (and c (<callable>-line c) (list-do l lines (and (<= (<callable>-line c) l) (<= l (<callable>-last c)) (set hit 't)))) hit))
(define-function pair-edited? (p ch)
  (or (not (car p)) (not (cdr p)) (touched? (car p) (<change>-removed ch)) (touched? (cdr p) (<change>-added ch))))
(define-function cc-of (c) (and c (<callable>-cc c)))
(define-function forms-of (c) (and c (<callable>-forms c)))
(define-function flagged-of (c) (if c (<callable>-flagged c) 0))
(define-function pair-move (path p edited)
  (make <move> path: path name: (<callable>-name (or (cdr p) (car p))) edited: edited
	cc-before: (cc-of (car p)) cc-after: (cc-of (cdr p)) forms-before: (forms-of (car p)) forms-after: (forms-of (cdr p))
	flagged-before: (and (car p) (<callable>-flagged (car p))) flagged-after: (and (cdr p) (<callable>-flagged (cdr p)))))
(define-function move-moved? (m)
  (or (<move>-edited m) (not (equal (<move>-cc-before m) (<move>-cc-after m))) (not (equal (<move>-forms-before m) (<move>-forms-after m)))
      (not (equal (<move>-flagged-before m) (<move>-flagged-after m)))))

;; ---- attribution

(define-structure <side-totals> (masses forms flagged))	; a side's (eroded . total) mass, forms and flagged forms
(define-function totals-of (ms)	; summed over metrics, () among them for a file that isn't there
  (let ((e 0.0) (t 0.0) (n 0) (f 0))
    (list-do m ms (when m (let ((ma (erosion-masses (<erosion-metrics>-callables m))))
			    (set e (+ e (car ma))) (set t (+ t (cdr ma)))
			    (set n (+ n (<erosion-metrics>-forms m))) (set f (+ f (<erosion-metrics>-flagged m))))))
    (make <side-totals> masses: (cons e t) forms: n flagged: f)))
(define-function per-mille-of (num den) (if (= 0 den) 0 (/ (* 1000 num) den)))
(define-function rebuilt-base (now cur base)	; the tree at the base: now, less the changed files as they are, plus as they were
  (let ((ma (cons (+ (- (car (<side-totals>-masses now)) (car (<side-totals>-masses cur))) (car (<side-totals>-masses base)))
		  (+ (- (cdr (<side-totals>-masses now)) (cdr (<side-totals>-masses cur))) (cdr (<side-totals>-masses base))))))
    (cons (erosion-per-mille ma)
	  (per-mille-of (+ (- (<side-totals>-flagged now) (<side-totals>-flagged cur)) (<side-totals>-flagged base))
			(+ (- (<side-totals>-forms now) (<side-totals>-forms cur)) (<side-totals>-forms base))))))
(define-function eroded-mass (c) (if (and c (< 10 (<callable>-cc c))) (erosion-mass c) 0.0))
(define-function metric-split (base now edited)	; (base now whole edited share): share the rest, so they sum
  (list base now (- now base) edited (- (- now base) edited)))
(define-function attribution-of-totals (now cur base tree-now ledger de df moves)
  (let* ((rebuilt (rebuilt-base now cur base))
	 (holds (and ledger (= (car ledger) (car rebuilt))))
	 (b (if holds ledger rebuilt))
	 (total (cdr (<side-totals>-masses now))))
    (make <attribution>
	  erosion: (metric-split (car b) (<erosion-metrics>-erosion tree-now) (if (< 0.0 total) (double->long (/ (* 1000.0 de) total)) 0))
	  verbosity: (metric-split (cdr b) (<erosion-metrics>-verbosity tree-now) (per-mille-of df (<side-totals>-forms now)))
	  moves: moves rebuilt: (not holds))))
(define-function attribute (changes tree-now base-ledger)
  (let ((pairs ()) (moves ()) (befores ()) (afters ()) (de 0.0) (df 0))
    (list-do ch changes
      (let ((b (measure-one "base" (<change>-old-path ch) (<change>-base-text ch)))
	    (a (measure-one "now" (<change>-path ch) (<change>-current-text ch))))
	(push befores b) (push afters a)
	(list-do p (match-callables (callables-of-metrics b) (callables-of-metrics a))
	  (let ((m (pair-move (<change>-path ch) p (pair-edited? p ch))))
	    (when (<move>-edited m)
	      (set de (+ de (- (eroded-mass (cdr p)) (eroded-mass (car p)))))
	      (set df (+ df (- (flagged-of (cdr p)) (flagged-of (car p))))))
	    (and (move-moved? m) (push moves m))))))
    (attribution-of-totals (totals-of (list tree-now)) (totals-of afters) (totals-of befores) tree-now base-ledger de df (list-reverse! moves))))

;; ---- the report

(define-function signed (n) (if (< 0 n) (concat-string "+" (long->string n)) (long->string n)))
(define-function side-text (x) (if x (long->string x) "none"))
(define-function metric-line (name m)	; m: (base now whole edited share)
  (concat-strings name " " (long->string (car m)) " -> " (long->string (cadr m)) ": whole " (signed (caddr m))
		  ", edited " (signed (cadddr m)) ", share " (signed (car (cddddr m)))))
(define-function move-mass (cc forms) (if (and cc forms) (* cc (sqrt (* 1.0 forms))) 0.0))
(define-function mass-moved (m)	; how much of the tree's complexity mass a move moved
  (let ((d (- (move-mass (<move>-cc-after m) (<move>-forms-after m)) (move-mass (<move>-cc-before m) (<move>-forms-before m)))))
    (if (< d 0.0) (- 0.0 d) d)))
(define-function crossed-10? (m)
  (let ((b (<move>-cc-before m)) (a (<move>-cc-after m))) (and b a (not (= (< 10 b) (< 10 a))))))
(define-function move-line (m)
  (concat-strings (if (<move>-edited m) "edited " "share ") (<move>-path m) " " (symbol->string (<move>-name m))
		  ": CC " (side-text (<move>-cc-before m)) " -> " (side-text (<move>-cc-after m)) (if (crossed-10? m) " (crossed 10)" "")
		  ", forms " (side-text (<move>-forms-before m)) " -> " (side-text (<move>-forms-after m))
		  ", flagged " (side-text (<move>-flagged-before m)) " -> " (side-text (<move>-flagged-after m))))
(define-function insert-by-mass (m sorted)
  (if (or (not sorted) (< (mass-moved (car sorted)) (mass-moved m))) (cons m sorted) (cons (car sorted) (insert-by-mass m (cdr sorted)))))
(define-function sort-by-mass (ms)	; insertion, most mass first
  (let ((out ()))
    (list-do m ms (set out (insert-by-mass m out)))
    out))
(define-function moves-in-order (a)	; edited first, each group by mass moved, most first
  (let ((edited ()) (share ()))
    (list-do m (<attribution>-moves a) (if (<move>-edited m) (push edited m) (push share m)))
    (concat-list (sort-by-mass edited) (sort-by-mass share))))
(define-function move-named-in-entry (m metric)	; f (CC 9 to 12), or f (flagged 0 to 2)
  (let ((b (if (= metric 'erosion) (<move>-cc-before m) (<move>-flagged-before m)))
	(a (if (= metric 'erosion) (<move>-cc-after m) (<move>-flagged-after m))))
    (concat-strings (symbol->string (<move>-name m))
		    (if (and b a (not (= b a))) (concat-strings (if (= metric 'erosion) " (CC " " (flagged ") (long->string b) " to " (long->string a) ")") ""))))
(define-function entry-for (metric m moves)	; check/erosion's line for a metric that moved, naming the edits most moved
  (let ((names "") (n 0))
    (list-do mv moves
      (when (and (<move>-edited mv) (< n 3))
	(set names (concat-strings names (if (= 0 n) "" ", ") (move-named-in-entry mv metric)))
	(incr n)))
    (concat-strings (symbol->string metric) " " (signed (caddr m)) " edits: " (if (= 0 n) "none" names) "; share " (signed (car (cddddr m))))))
(define-function attribution-ledger-entries (a)
  (let ((moves (moves-in-order a)) (out ()))
    (and (not (= 0 (caddr (<attribution>-erosion a)))) (push out (entry-for 'erosion (<attribution>-erosion a) moves)))
    (and (not (= 0 (caddr (<attribution>-verbosity a)))) (push out (entry-for 'verbosity (<attribution>-verbosity a) moves)))
    (list-reverse! out)))
(define-function attribution-report (a)	; lines: the metrics, then each move, then the drafted ledger entries
  (concat-list (list (metric-line "erosion" (<attribution>-erosion a)) (metric-line "verbosity" (<attribution>-verbosity a)))
	       (concat-list (if (<attribution>-rebuilt a) '("the base's values rebuilt from the changed files: no ledger at the base holds") ())
			    (concat-list (map move-line (moves-in-order a)) (cons "ledger:" (attribution-ledger-entries a))))))
