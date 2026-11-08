;;; erosion.l -- SlopCodeBench's erosion and verbosity (Orlanski et al., NeurIPS 2026) over Maru source, as
;;; docs/plans/2026-11-08-erosion-metrics.md has them.  (erosion-of sources), sources ((path . text) ...), answers an
;;; <erosion-metrics>: erosion, the share of complexity mass (CC x sqrt(SLOC)) held by callables of CC over 10, and
;;; verbosity, the share of source lines a verbose pattern flags or a clone covers, each per mille, rounded down.
(require "maru-lines.l")
(require "hash.l")

;; the forms that are decisions, besides cond's clauses and and's and or's operands (erosion-complexity.g)
(define *erosion-decisions* '(if when unless while until for list-do lists-do array-do alist-do string-do namespace-do hash-do))
(define-function erosion-decision? (op) (and (symbol? op) (memq op *erosion-decisions*) 't))
(define-function erosion-sum (ns) (let ((s 0)) (list-do n ns (set s (+ s n))) s))
(define-function erosion-flat (lists) (let ((out ())) (list-do l lists (list-do x l (push out x))) out))
(define-function erosion-join (vs lists) (concat-list vs (erosion-flat lists)))
(define-function erosion-params (ps)	; a parameter list's names, its dotted rest among them (a tree pattern reads past it)
  (let ((out ()))
    (while (pair? ps) (and (symbol? (car ps)) (push out (car ps))) (set ps (cdr ps)))
    (and ps (symbol? ps) (push out ps))
    out))
(tpeg-load "erosion-complexity.g")
(tpeg-load "erosion-binders.g")
(tpeg-load "erosion-verbose.g")
(define-structure <ledger-entry> (metric change reason))	; a line of check/erosion
(define-function erosion-parse-text (grammar rule text what)	; what rule reads of all of text, or an error naming what
  (let ((p (text-parser-for-on grammar text)))
    (or (rule p) (error "erosion: can't read " what))
    (<text-parser>-result p)))
(tpeg-load "erosion-ledger.g")
(tpeg-load "erosion-lines.g")

(define-structure <callable> (name path first last cc sloc))	; a definition, its lines, complexity and source lines
(define-structure <verbose-finding> (rule form))			; a form a verbose pattern flags
(define-structure <erosion-metrics> (erosion verbosity callables lines flagged))	; per mille; the callables; line counts
(define-method do-print <callable> () (print "<" self.name " " self.path ":" self.first " CC " self.cc ", " self.sloc " lines>"))
(define sqrt (subr "sqrt" "d>d"))
(define-function erosion-mass (c) (* (<callable>-cc c) (sqrt (* 1.0 (<callable>-sloc c)))))

;; which lines hold code: not blank, and not only a comment (erosion-lines.g)
(define-function erosion-code-lines (text)	; an array, t at index i if line i + 1 holds code
  (list->array (erosion-parse-text <erosion-lines> $lines text "a file's lines")))
(define-function erosion-count-code (code first last)
  (let ((n 0)) (for (l first (+ last 1)) (and (<= l (array-length code)) (array-at code (- l 1)) (set n (+ n 1)))) n))

;; callables: the top-level definitions, and a define or set of a lambda
(define-function erosion-definition-name (form)
  (and (pair? form) (pair? (cdr form))
       (let ((op (car form)) (name (cadr form)))
	 (cond ((memq op '(define-function define-method define-form define-selector define-apply)) name)
	       ((and (memq op '(define set)) (pair? (cddr form)) (pair? (caddr form)) (= 'lambda (car (caddr form)))) name)))))
(define-function erosion-callables (forms code)	; code: erosion-code-lines of the text the forms were read from
  (let ((out ()))
    (list-do form forms
      (let ((name (erosion-definition-name form)) (span (maru-lines-span form)))
	(when (and name span)
	  (push out (make <callable> name: name path: (<source-span>-path span)
			  first: (<source-span>-first span) last: (<source-span>-last span)
			  cc: (+ 1 (parse-source <erosion-complexity> $form (list form)))
			  sloc: (erosion-count-code code (<source-span>-first span) (<source-span>-last span)))))))
    (list-reverse! out)))

;; every list in a form, outermost first (a stack, not recursion: a deep form takes no frame per level)
(define-function erosion-lists-do (form fn)
  (let ((todo (list form)))
    (while todo
      (let ((x (car todo)))
	(set todo (cdr todo))
	(when (pair? x)
	  (fn x)
	  (or (= 'quote (car x))	; its elements, pushed so the first comes off first (no concat-list: it recurses)
	      (let ((more ())) (while (pair? x) (push more (car x)) (set x (cdr x))) (list-do e more (push todo e)))))))))
(define-function erosion-findings (forms)
  (let ((out ()))
    (list-do form forms
      (erosion-lists-do form (lambda (x) (let ((rule (parse-source <erosion-verbose> $flag (list x)))) (and rule (push out (make <verbose-finding> rule: rule form: x)))))))
    (list-reverse! out)))

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
(define-function erosion-bound (form)	; the variables form binds, as a set
  (let ((vars (identity-hash-table)))
    (list-do v (parse-source <erosion-binders> $form (list form)) (and v (symbol? v) (hash-at-put vars v 't)))
    vars))

;; how erosion-of reads a source's forms (erosion-run.l reads them once and holds them to Maru's own reader)
(define erosion-read maru-lines-read)
;; whether metrics m equal their ledger's sums, (erosion . verbosity)
(define-function erosion-matches? (m sums)
  (and (= (<erosion-metrics>-erosion m) (car sums)) (= (<erosion-metrics>-verbosity m) (cdr sums)) 't))
;; the metrics over sources, ((path . text) ...)
(define-function erosion-of (sources)
  (let ((callables ()) (lines 0) (flagged 0) (seen (identity-hash-table)) (occurrences ()) (files ()))	; files: ((code . marks) ...)
    (list-do src sources
      (let* ((text (cdr src)) (forms (erosion-read text (car src))) (code (erosion-code-lines text)) (marks (array (array-length code))))
	(list-do c (erosion-callables forms code) (push callables c))	; newest first, put in order below
	(list-do f (erosion-findings forms)
	  (let ((s (maru-lines-span (<verbose-finding>-form f)))) (and s (for (l (<source-span>-first s) (+ (<source-span>-last s) 1)) (set-array-at marks (- l 1) 't)))))
	(list-do form forms
	  (erosion-scan form (erosion-bound form)
			(lambda (x key atoms)
			  (when (and (<= 12 atoms) (maru-lines-span x))
			    (hash-at-put seen key (+ 1 (hash-at seen key 0)))
			    (let ((span (maru-lines-span x)))	; its lines, not the list: each file's forms can go once read
			      (push occurrences (list key (<source-span>-first span) (<source-span>-last span) marks)))))))
	(for (i 0 (array-length code)) (and (array-at code i) (set lines (+ lines 1))))
	(push files (cons code marks))))
    (list-do o occurrences	; every line of a list met twice or more
      (when (< 1 (hash-at seen (car o)))
	(let ((marks (cadddr o)))
	  (for (l (cadr o) (+ (caddr o) 1)) (set-array-at marks (- l 1) 't)))))
    (list-do f files
      (let ((code (car f)) (marks (cdr f)))
	(for (i 0 (array-length code)) (and (array-at code i) (array-at marks i) (set flagged (+ flagged 1))))))
    (set callables (list-reverse! callables))
    (let ((total 0.0) (eroded 0.0))
      (list-do c callables
	(set total (+ total (erosion-mass c)))
	(and (< 10 (<callable>-cc c)) (set eroded (+ eroded (erosion-mass c)))))
      (make <erosion-metrics>
	    erosion: (if (< 0.0 total) (double->long (/ (* 1000.0 eroded) total)) 0)
	    verbosity: (if (< 0 lines) (/ (* 1000 flagged) lines) 0)
	    callables: callables lines: lines flagged: flagged))))
;; check/erosion's ledger, read by erosion-ledger.g to entries; answers each metric's sum, (erosion . verbosity)
(define-function erosion-ledger (text)
  (let ((e 0) (v 0))
    (list-do entry (erosion-parse-text <erosion-ledger> $ledger text "the ledger")
      (when entry
	(if (= 'erosion (<ledger-entry>-metric entry))
	    (set e (+ e (<ledger-entry>-change entry)))
	  (set v (+ v (<ledger-entry>-change entry))))))
    (cons e v)))
