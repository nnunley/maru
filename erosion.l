;;; erosion.l -- SlopCodeBench's erosion and verbosity (Orlanski et al., NeurIPS 2026) over Maru source, counted in forms, as
;;; doc/plans/2026-11-10-erosion-by-reflection.md has them.  (erosion-of sources), sources ((path . forms) ...), the forms as
;;; each file's own reader made them (erosion-read-file: grammars' as tpeg reads them, each rule a callable), answers an
;;; <erosion-metrics>: erosion, the share of complexity mass (CC x sqrt(forms)) held by callables of CC over 10, and
;;; verbosity, the share of forms a verbose pattern flags or a clone covers, each per mille, rounded down.  A form is a list
;;; outside quoted data; maru-forms.l walks each top-level form once for its complexity, its forms, the verbose patterns in
;;; it and the variables it binds.
(require "maru-forms.l")
(require "source.l")

(define-structure <ledger-entry> (metric change reason))	; a line of check/erosion
(define-function erosion-parse-text (grammar rule text what)	; what rule reads of all of text, or an error naming what
  (let ((p (text-parser-for-on grammar text)))
    (or (rule p) (error "erosion: can't read " what))
    (<text-parser>-result p)))
(tpeg-load "erosion-ledger.g")
(tpeg-load "erosion-spans.g")

(define-structure <callable> (name path line cc forms))	; a definition, where it starts, its complexity and forms
(define-structure <verbose-finding> (rule form))		; a form a verbose pattern flags
(define-structure <erosion-metrics> (erosion verbosity callables forms flagged findings))	; per mille; counts of forms
(define-method do-print <callable> () (print "<" self.name " " self.path ":" self.line " CC " self.cc ", " self.forms " forms>"))
(define sqrt (subr "sqrt" "d>d"))
(define-function erosion-mass (c) (* (<callable>-cc c) (sqrt (* 1.0 (<callable>-forms c)))))

;; a script tpeg-repl.l reads: its forms and blocks, each read by tpeg's sexpression rule from where tpeg-repl.l --forms says
;; it lies.  The input a block takes is found only by running the script, so a child process runs it.
(define erosion-getpid (subr "getpid" ">i"))
(define-function erosion-read-script (path text)
  (let ((spans (concat-strings "/tmp/maru-erosion-" (long->string (erosion-getpid)) ".forms"))
	(forms ()))
    (let* ((status ((subr "system" "s>i") (concat-strings "./eval tpeg-repl.l --forms '" path "' > " spans " 2>&1")))
	   (out (contents-of-file-named spans)))
      ((subr "unlink" "s>i") spans)
      (or (= 0 status) (error "erosion: " path " failed as it ran, so its forms aren't all known"))	; not measured in part
      (list-do start (erosion-parse-text <erosion-spans> $spans out "a script's forms")
	(when start
	  (let ((p (text-parser-for-on <tpeg> text)))
	    (set (<text-parser>-position p) start)
	    (and ($sexpression p) (push forms (<text-parser>-result p)))))))
    (list-reverse! forms)))

;; a file's forms, read by its own reader: a .g file's grammar as tpeg reads it, one (grammar-define name parent fields
;; rule...) form; a script tpeg-repl.l reads, as it reads it; any other file's as Maru's reader reads them
(define *erosion-script-line* "#!./eval tpeg-repl.l")
(define-function erosion-read-file (path)
  (let ((text (contents-of-file-named path)))
    (cond ((= ".g" (string-copy path (max 0 (- (string-length path) 2)) 2))
	   (let ((spec (tpeg-parse-whole-file path))) (list `(grammar-define ,@(caar spec) ,@(cdr spec)))))
	  ((and (<= (string-length *erosion-script-line*) (string-length text))
		(= *erosion-script-line* (string-copy text 0 (string-length *erosion-script-line*))))
	   (erosion-read-script path text))
	  (else (find-and-read path)))))

;; a grammar form's rules: each a callable, as a definition is
(define-selector erosion-grammar-rules (form) ())
(define-method erosion-grammar-rules <pair> ()
  (let ((head (car self)))
    (cond ((= head 'grammar-define) (cddddr self))
	  ((= head 'grammar-extend) (cddr self))
	  ((= head 'grammar-eval) (cadr self)))))

;; callables: the definitions source.l reads from a file's forms (source-lift.g), all but types, and grammars' rules
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
      (let ((walked (identity-hash-table)))	; each top-level form's walk, which a definition that is one reuses
	(set *forms-rule-answers* (identity-hash-table))	; and each grammar rule's, which its callable reuses
	(list-do form (cdr src)
	  (let* ((binders (identity-hash-table)) (r (maru-forms-walk form binders flags)))
	    (and (pair? form) (hash-at-put walked form r))
	    (set forms (+ forms (cadr r)))
	    (push tops form)
	    (erosion-scan form binders
			(lambda (x key atoms)
			  (when (<= 12 atoms)
			    (hash-at-put seen key (+ 1 (hash-at seen key 0)))
			    (push occurrences (cons key x)))))))
	(list-do form (cdr src)
	  (list-do rule (erosion-grammar-rules form)
	    (let ((r (or (hash-at *forms-rule-answers* rule) (maru-forms-walk-by $rule rule (identity-hash-table) (identity-hash-table)))))
	      (push callables (make <callable> name: (car rule) path: (car src) line: (erosion-line rule)
				    cc: (+ 1 (car r)) forms: (cadr r))))))
	(list-do d (forms-definitions (car src) (cdr src))	; a definition inside a let is walked on its own
	  (unless (= 'type (<definition>-kind d))
	    (let* ((form (source-form d))
		   (r (or (hash-at walked form) (maru-forms-walk form (identity-hash-table) (identity-hash-table)))))
	      (push callables (make <callable> name: (<definition>-name d) path: (car src) line: (erosion-line form)
				    cc: (+ 1 (car r)) forms: (cadr r))))))))
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
