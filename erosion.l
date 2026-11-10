;;; erosion.l -- SlopCodeBench's erosion and verbosity (Orlanski et al., NeurIPS 2026) over Maru source, counted in forms, as
;;; docs/plans/2026-11-10-erosion-by-reflection.md has them.  (erosion-of sources), sources ((path . forms) ...), the forms as
;;; Maru's own reader made them, answers an <erosion-metrics>: erosion, the share of complexity mass (CC x sqrt(forms)) held
;;; by callables of CC over 10, and verbosity, the share of forms a verbose pattern flags or a clone covers, each per mille,
;;; rounded down.  A form is a list outside quoted data; maru-forms.l walks each top-level form once for its complexity, its
;;; forms, the verbose patterns in it and the variables it binds.
(require "maru-forms.l")

(define-structure <ledger-entry> (metric change reason))	; a line of check/erosion
(define-function erosion-parse-text (grammar rule text what)	; what rule reads of all of text, or an error naming what
  (let ((p (text-parser-for-on grammar text)))
    (or (rule p) (error "erosion: can't read " what))
    (<text-parser>-result p)))
(tpeg-load "erosion-ledger.g")

(define-structure <callable> (name path line cc forms))	; a definition, where it starts, its complexity and forms
(define-structure <verbose-finding> (rule form))		; a form a verbose pattern flags
(define-structure <erosion-metrics> (erosion verbosity callables forms flagged findings))	; per mille; counts of forms
(define-method do-print <callable> () (print "<" self.name " " self.path ":" self.line " CC " self.cc ", " self.forms " forms>"))
(define sqrt (subr "sqrt" "d>d"))
(define-function erosion-mass (c) (* (<callable>-cc c) (sqrt (* 1.0 (<callable>-forms c)))))

;; callables: the top-level definitions, and a define or set of a lambda
(define-function erosion-definition-name (form)
  (and (pair? form) (pair? (cdr form))
       (let ((op (car form)) (name (cadr form)))
	 (cond ((memq op '(define-function define-method define-form define-selector define-apply)) name)
	       ((and (memq op '(define set)) (pair? (cddr form)) (pair? (caddr form)) (= 'lambda (car (caddr form)))) name)))))
(define-function erosion-line (form)	; the line Maru's reader noted on form's first pair
  (let ((s (and (pair? form) (<pair>-source form)))) (and (pair? s) (cdr s))))

;; clones: a list of at least 12 atoms found twice or more, once each variable its definition binds is renamed to one
;; placeholder (a type-2 clone: what a variable is called doesn't matter).  Renaming goes by name over the whole
;; definition, not by scope: a parameter named list renames the definition's calls of list too (an approximation, until
;; grammars see environments).  Each list's key is a hash of its renamed form, made from its elements' as the scan comes
;; back up, so no renamed copy is made or walked again: each atom by its kind and its whole text or value, a list by its
;; elements, its length and a dotted tail marked apart from an element; 61 bits, so two of the tree's hundred thousand
;; lists share one by chance about once in ten million runs
(define *erosion-hash-mask* (- (<< 1 61) 1))
(define-function erosion-mix (h x) (& *erosion-hash-mask* (+ (* h 1000003) x)))
(define-function erosion-text-hash (tag text)
  (let ((h tag)) (for (i 0 (string-length text)) (set h (erosion-mix h (string-at text i)))) (erosion-mix h (string-length text))))
(define *erosion-symbol-hashes* (identity-hash-table))	; a symbol's hash, by its name, worked out once
(define-function erosion-symbol-hash (x)
  (or (hash-at *erosion-symbol-hashes* x) (hash-at-put *erosion-symbol-hashes* x (erosion-text-hash 1 (symbol->string x)))))
(define-function erosion-atom-hash (x bound)	; each kind of atom tagged apart: nil, symbol, long, double, string
  (cond ((not x)				5)
	((symbol? x)				(erosion-symbol-hash (if (hash-at bound x) '_ x)))
	((long? x)				(erosion-mix 2 (& *erosion-hash-mask* x)))
	((double? x)				(erosion-text-hash 3 (format "%.17g" x)))
	((string? x)				(erosion-text-hash 4 x))
	(else					(erosion-mix 6 (& *erosion-hash-mask* (equal-hash x))))))
(define-function erosion-scan (x bound visit)	; (hash . atoms) for x, calling (visit list hash atoms) on each list inside
  (if (not (pair? x))				; x; it walks a spine in a loop and recurses only into elements
      (cons (erosion-atom-hash x bound) (if x 1 0))
    (let ((h 7) (atoms 0) (n 0) (rest x))
      (while (pair? rest)
	(let ((r (erosion-scan (car rest) bound visit)))
	  (set h (erosion-mix h (car r)))
	  (set atoms (+ atoms (cdr r)))
	  (set n (+ n 1)))
	(set rest (cdr rest)))
      (set h (erosion-mix (erosion-mix h 8) n))	; its length, after a mark no element's hash makes
      (when rest
	(set h (erosion-mix (erosion-mix h 9) (erosion-atom-hash rest bound)))	; a dotted tail, marked as such
	(set atoms (+ atoms 1)))
      (visit x h atoms)
      (cons h atoms))))

;; the forms in x a covered list holds, each counted once: a covered list's forms, and below the rest (no quoted data)
(define-function erosion-covered-forms (x covered)
  (let ((todo (list x)) (n 0))
    (while todo
      (let ((y (car todo)))
	(set todo (cdr todo))
	(when (and (pair? y) (not (= 'quote (car y))))
	  (if (hash-at covered y)
	      (set n (+ n (maru-forms-count y)))
	    (while (pair? y) (push todo (car y)) (set y (cdr y)))))))
    n))

;; whether metrics m equal their ledger's sums, (erosion . verbosity)
(define-function erosion-matches? (m sums)
  (and (= (<erosion-metrics>-erosion m) (car sums)) (= (<erosion-metrics>-verbosity m) (cdr sums)) 't))
;; the metrics over sources, ((path . forms) ...)
(define-function erosion-of (sources)
  (let ((callables ()) (forms 0) (flags (identity-hash-table)) (seen (identity-hash-table)) (occurrences ()) (tops ()))
    (list-do src sources
      (list-do form (cdr src)
	(let* ((binders (identity-hash-table)) (r (maru-forms-walk form binders flags)) (name (erosion-definition-name form)))
	  (set forms (+ forms (cadr r)))
	  (push tops form)
	  (and name (push callables (make <callable> name: name path: (car src) line: (erosion-line form)
					  cc: (+ 1 (car r)) forms: (cadr r))))
	  (erosion-scan form binders
			(lambda (x key atoms)
			  (when (<= 12 atoms)
			    (hash-at-put seen key (+ 1 (hash-at seen key 0)))
			    (push occurrences (cons key x))))))))
    (let ((covered (identity-hash-table)) (flagged 0) (findings ()))
      (hash-do flags (lambda (x rule) (hash-at-put covered x 't) (push findings (make <verbose-finding> rule: rule form: x))))
      (list-do o occurrences (and (< 1 (hash-at seen (car o))) (hash-at-put covered (cdr o) 't)))
      (list-do form tops (set flagged (+ flagged (erosion-covered-forms form covered))))
      (set callables (list-reverse! callables))
      (let ((total 0.0) (eroded 0.0))
	(list-do c callables
	  (set total (+ total (erosion-mass c)))
	  (and (< 10 (<callable>-cc c)) (set eroded (+ eroded (erosion-mass c)))))
	(make <erosion-metrics>
	      erosion: (if (< 0.0 total) (double->long (/ (* 1000.0 eroded) total)) 0)
	      verbosity: (if (< 0 forms) (/ (* 1000 flagged) forms) 0)
	      callables: callables forms: forms flagged: flagged findings: (list-reverse! findings))))))
;; check/erosion's ledger, read by erosion-ledger.g to entries; answers each metric's sum, (erosion . verbosity)
(define-function erosion-ledger (text)
  (let ((e 0) (v 0))
    (list-do entry (erosion-parse-text <erosion-ledger> $ledger text "the ledger")
      (when entry
	(if (= 'erosion (<ledger-entry>-metric entry))
	    (set e (+ e (<ledger-entry>-change entry)))
	  (set v (+ v (<ledger-entry>-change entry))))))
    (cons e v)))
