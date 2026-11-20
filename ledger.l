;;; ledger.l -- check/ledger, the one ledger for every measure (doc/measures.md): lines, erosion and verbosity, each entry
;;; its metric, its change and why, read by ledger.g.  Each measure's check holds the tree to its metric's sum.  An entry
;;; needs a reason, but lines removed may go without one.  A line include: PATH brings in the ledger at PATH; a file
;;; included twice, or a cycle, is refused.
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(define-structure <ledger-entry> (metric change reason))	; a line of check/ledger
(tpeg-load "ledger.g")

(define-function ledger-parse (text)	; entries and (include . path)s, or an error
  (let ((p (text-parser-for-on <ledger> text)))
    (or ($ledger p) (error "ledger: can't read the ledger"))
    (<text-parser>-result p)))
(define-function ledger-unreasoned? (e)	; an entry with no reason, unless it removes lines
  (and (not (<ledger-entry>-reason e)) (not (and (= 'lines (<ledger-entry>-metric e)) (< (<ledger-entry>-change e) 0)))))
(define-function ledger-collect (text reader seen)	; the entries of text and what it includes; seen: (paths), a box
  (let ((out ()))
    (list-do x (ledger-parse text)
      (cond ((not x))
	    ((pair? x)	; (include . path): each file once, so a cycle is refused too
	     (and (member? (cdr x) (car seen)) (error "ledger: " (cdr x) " included twice"))
	     (set-car seen (cons (cdr x) (car seen)))
	     (set out (concat-list (list-reverse! (ledger-collect (or (reader (cdr x)) (error "ledger: no ledger at " (cdr x))) reader seen)) out)))
	    ((ledger-unreasoned? x) (error "ledger: an entry with no reason: " (<ledger-entry>-metric x) " " (<ledger-entry>-change x)))
	    (else (push out x))))
    (list-reverse! out)))
(define-function ledger-entries (text . read)	; read: a path's text, for an include (the file's, if not given)
  (ledger-collect text (or (car read) (lambda (path) (contents-of-file-named path))) (list ())))
(define-function ledger-sums (text . read)	; (lines erosion verbosity)
  (let ((l 0) (e 0) (v 0))
    (list-do entry (apply ledger-entries (cons text read))
      (when entry
	(let ((m (<ledger-entry>-metric entry)) (n (<ledger-entry>-change entry)))
	  (cond ((= m 'lines) (set l (+ l n))) ((= m 'erosion) (set e (+ e n))) (else (set v (+ v n)))))))
    (list l e v)))
