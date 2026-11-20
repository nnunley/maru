;;; ledger.l -- check/ledger, the one ledger for every measure (doc/measures.md): lines, erosion and verbosity, each entry
;;; its metric, its change and why, read by ledger.g.  Each measure's check holds the tree to its metric's sum.  An entry
;;; needs a reason, but lines removed may go without one.  A line include: PATH brings in the ledger at PATH; a file
;;; included twice, or a cycle, is refused.  An include's summary is checked against the file, which is always read:
;;; without a fingerprint it must match; with one, it must match at that fingerprint, and a file that has moved on since
;;; is counted as it is now, with a note saying how far it moved.
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(require "erosion-files.l")	; text-lines, and spawn.l
(define-structure <ledger-entry> (metric change reason))	; a line of check/ledger
(define-function ledger-join (t us) (let ((s t)) (list-do u us (set s (concat-strings s " " u))) s))	; a folded line, joined
(tpeg-load "ledger.g")

(define-function ledger-parse (text)	; entries and (include path summary fingerprint)s, or an error
  (let ((p (text-parser-for-on <ledger> text)))
    (or ($ledger p) (error "ledger: can't read the ledger"))
    (<text-parser>-result p)))
(define-function ledger-fingerprint (path)	; a file's git blob id, as git hash-object gives it
  (let ((r (program-result (list "git" "hash-object" "--no-filters" path) ".")))
    (and (= 0 (car r)) (car (text-lines (cdr r))))))

;; sums, (lines erosion verbosity): of entries, of a summary ((metric . n) ...), and written as a summary is
(define-function ledger-add (sums m n)
  (cond ((= m 'lines) (list (+ n (car sums)) (cadr sums) (caddr sums)))
	((= m 'erosion) (list (car sums) (+ n (cadr sums)) (caddr sums)))
	(else (list (car sums) (cadr sums) (+ n (caddr sums))))))
(define-function entries-sums (es) (let ((s '(0 0 0))) (list-do e es (set s (ledger-add s (<ledger-entry>-metric e) (<ledger-entry>-change e)))) s))
(define-function summary-sums (items) (let ((s '(0 0 0))) (list-do i items (set s (ledger-add s (car i) (cdr i)))) s))
(define *ledger-metrics* '(lines erosion verbosity))
(define-function sums-text (sums signed?)	; "lines 3, erosion 1": the measures not 0 (lines 0 if none)
  (let ((out "") (ms *ledger-metrics*))
    (list-do n sums
      (or (= 0 n) (set out (concat-strings out (if (= "" out) "" ", ") (symbol->string (car ms)) " "
					   (if (and signed? (< 0 n)) "+" "") (long->string n))))
      (set ms (cdr ms)))
    (if (= "" out) (if signed? "sums unchanged" "lines 0") out)))
(define-function sums-minus (a b) (list (- (car a) (car b)) (- (cadr a) (cadr b)) (- (caddr a) (caddr b))))

(define-function ledger-unreasoned? (e)	; an entry with no reason, unless it removes lines
  (and (not (<ledger-entry>-reason e)) (not (and (= 'lines (<ledger-entry>-metric e)) (< (<ledger-entry>-change e) 0)))))
(define-function include-checked (path entries summary want fp notes)	; the summary held to the file; a note if it moved
  (let ((have (entries-sums entries)) (said (summary-sums summary)))
    (if (not want)
	(or (equal have said) (error "ledger: " path "'s summary says " (sums-text said ()) " but it holds " (sums-text have ())
				     "; write include: " path " " (sums-text have ()) " @ " (fp path)))
      (let ((now (fp path)))
	(if (= now want)
	    (or (equal have said) (error "ledger: " path "'s summary says " (sums-text said ()) " at " want " but it holds " (sums-text have ())))
	  (set-car notes (cons (concat-strings path " moved since its summary: " (sums-text (sums-minus have said) 't) ", now @ " now) (car notes))))))))
(define-function ledger-collect (text reader fp seen notes)	; the entries of text and what it includes; seen, notes: boxes
  (let ((out ()))
    (list-do x (ledger-parse text)
      (cond ((not x))
	    ((pair? x)	; (include path summary fingerprint): each file once, so a cycle is refused too
	     (let* ((path (cadr x)) (inner (or (reader path) (error "ledger: no ledger at " path))))
	       (and (member? path (car seen)) (error "ledger: " path " included twice"))
	       (set-car seen (cons path (car seen)))
	       (let ((es (ledger-collect inner reader fp seen notes)))
		 (and (caddr x) (include-checked path es (caddr x) (car (cdddr x)) fp notes))
		 (list-do e es (push out e)))))
	    ((ledger-unreasoned? x) (error "ledger: an entry with no reason: " (<ledger-entry>-metric x) " " (<ledger-entry>-change x)))
	    (else (push out x))))
    (list-reverse! out)))
(define-function ledger-read (text . opts)	; (sums . notes); opts: a path's text (the file's), a path's fingerprint
  (let ((reader (or (car opts) (lambda (path) (contents-of-file-named path))))
	(fp (or (cadr opts) ledger-fingerprint))
	(notes (list ())))
    (cons (entries-sums (ledger-collect text reader fp (list ()) notes)) (list-reverse! (car notes)))))
(define-function ledger-entries (text . opts)
  (ledger-collect text (or (car opts) (lambda (path) (contents-of-file-named path))) (lambda (t) ()) (list ()) (list ())))
(define-function ledger-sums (text . opts) (car (apply ledger-read (cons text opts))))	; (lines erosion verbosity)
