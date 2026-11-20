;;; erosion.l -- SlopCodeBench's erosion and verbosity (Orlanski et al., NeurIPS 2026) over Maru source, counted in forms, as
;;; doc/plans/2026-11-10-erosion-by-reflection.md has them.  (erosion-of sources), sources ((path . forms) ...), the forms as
;;; each file's own reader made them (erosion-read-file: grammars' as tpeg reads them, each rule a callable), answers an
;;; <erosion-metrics>: erosion, the share of complexity mass (CC x sqrt(forms)) held by callables of CC over 10, and
;;; verbosity, the share of forms a verbose pattern flags or a clone covers, each per mille, rounded down.  A form is a list
;;; outside quoted data; maru-forms.l walks each top-level form once for its complexity, its forms, the verbose patterns in
;;; it and the variables it binds.
(require "maru-forms.l")
(require "spawn.l")	; a script run directly to find its forms
(require "source.l")

(define-function erosion-parse-text (grammar rule text what)	; what rule reads of all of text, or an error naming what
  (let ((p (text-parser-for-on grammar text)))
    (or (rule p) (error "erosion: can't read " what))
    (<text-parser>-result p)))
(require "ledger.l")	; check/ledger, read by ledger.g
(tpeg-load "erosion-spans.g")

(define-structure <callable> (name path line last cc forms flagged))	; a definition, its first and last line, its complexity,
										; its forms, and its forms a verbose pattern or clone covers
(define-structure <verbose-finding> (rule form))		; a form a verbose pattern flags
(define-structure <erosion-metrics> (erosion verbosity callables forms flagged findings seen))	; per mille; counts of forms;
										; seen: each clone key's count
(define-method do-print <callable> () (print "<" self.name " " self.path ":" self.line " CC " self.cc ", " self.forms " forms>"))
(define sqrt (subr "sqrt" "d>d"))
(define-function erosion-mass (c) (* (<callable>-cc c) (sqrt (* 1.0 (<callable>-forms c)))))

;; a grammar's rules carry no lines, so each grammar form's rule spans, (first . last) in rule order, are found in its
;; text by tpeg's own rules: its header if it has one, then each definition, the parser's position noted around it
(define *erosion-rule-lines* (identity-hash-table))
(define-function erosion-line-at (text pos) (let ((n 1)) (for (i 0 pos) (and (= ?\n (string-at text i)) (incr n))) n))
(define-function erosion-rule-spans (text start)	; start: the grammar's first character, after a block's {
  (let ((p (text-parser-for-on <tpeg> text)) (spans ()) (going 't))
    (set (<text-parser>-position p) start)
    (let ((before (<text-parser>-position p)))
      (or ($parser_decl p) (set (<text-parser>-position p) before)))
    (while going
      ($space p)
      (let ((from (<text-parser>-position p)))
	(if ($definition p)
	    (push spans (cons (erosion-line-at text from) (erosion-line-at text (- (<text-parser>-position p) 1))))
	  (set going ()))))
    (list-reverse! spans)))

;; a script's grammar block: its rules' lines, from the text after its opening brace
(define-function erosion-block-lines (text start form)
  (when (and (pair? form) (memq (car form) '(grammar-define grammar-extend grammar-eval)))
    (let ((brace start))
      (while (and (< brace (string-length text)) (not (= ?{ (string-at text brace)))) (incr brace))
      (hash-at-put *erosion-rule-lines* form (erosion-rule-spans text (+ brace 1))))))

;; a script tpeg-repl.l reads: its forms and blocks, each read by tpeg's sexpression rule from where tpeg-repl.l --forms says
;; it lies.  The input a block takes is found only by running the script, so a child process runs it.
(define erosion-getpid (subr "getpid" ">i"))
(define-function erosion-scratch () (or (spawn-getenv "MARU_CHECK_TMP") "/tmp"))	; the check's own directory, which the runner empties
(define-function erosion-read-script (path text)
  (let ((spans (concat-strings (erosion-scratch) "/maru-erosion-" (long->string (erosion-getpid)) ".forms"))
	(forms ()))
    (let* ((status (program-status (list "./eval" "tpeg-repl.l" "--forms" path) () spans spans))
	   (out (contents-of-file-named spans)))
      ((subr "unlink" "s>i") spans)
      (or (= 0 status) (error "erosion: " path " failed as it ran, so its forms aren't all known"))	; not measured in part
      (list-do start (erosion-parse-text <erosion-spans> $spans out "a script's forms")
	(when start
	  (let ((p (text-parser-for-on <tpeg> text)))
	    (set (<text-parser>-position p) start)
	    (when ($sexpression p)
	      (erosion-block-lines text start (<text-parser>-result p))
	      (push forms (<text-parser>-result p)))))))
    (list-reverse! forms)))

;; a file's forms, read by its own reader: a .g file's grammar as tpeg reads it, one (grammar-define name parent fields
;; rule...) form, or (grammar-eval (rule...) ()) for a file with no header, whose rules join the running grammar; a script tpeg-repl.l reads, as it reads it; any other file's as Maru's reader reads them
(define *erosion-script-line* "#!./eval tpeg-repl.l")
(define-function erosion-read-file (path)
  (let ((text (contents-of-file-named path)))
    (cond ((= ".g" (string-copy path (max 0 (- (string-length path) 2)) 2))
	   (let* ((spec (tpeg-parse-whole-file path))	; with no header, rules for the grammar it's loaded into, as a block's
		  (form (if (caar spec) `(grammar-define ,@(caar spec) ,@(cdr spec)) `(grammar-eval ,(cdr spec) ()))))
	     (hash-at-put *erosion-rule-lines* form (erosion-rule-spans text 0))
	     (list form)))
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
;; callables' mass, (eroded . total): eroded the mass of those of CC over 10; erosion is their share, per mille, rounded down
(define-function erosion-masses (callables)
  (let ((total 0.0) (eroded 0.0))
    (list-do c callables
      (set total (+ total (erosion-mass c)))
      (and (< 10 (<callable>-cc c)) (set eroded (+ eroded (erosion-mass c)))))
    (cons eroded total)))
(define-function erosion-per-mille (masses) (if (< 0.0 (cdr masses)) (double->long (/ (* 1000.0 (car masses)) (cdr masses))) 0))
;; a grammar form's rules as callables, each (rule . <callable>), with the lines erosion-rule-spans found for them
(define-function erosion-rule-callables (path form)
  (let ((spans (hash-at *erosion-rule-lines* form)) (out ()))	; each rule's lines, in rule order
    (list-do rule (erosion-grammar-rules form)
      (let ((r (or (hash-at *forms-rule-answers* rule) (maru-forms-walk-by $rule rule (identity-hash-table) (identity-hash-table))))
	    (span (car spans)))
	(set spans (cdr spans))
	(push out (cons rule (make <callable> name: (car rule) path: path line: (car span) last: (cdr span) cc: (+ 1 (car r)) forms: (cadr r))))))
    (list-reverse! out)))
;; a file's definitions as callables, each (form . <callable>): a definition inside a let walked on its own, a top-level
;; form's walk reused from walked
(define-function erosion-definition-callables (path forms walked)
  (let ((out ()))
    (list-do d (forms-definitions path forms)
      (unless (= 'type (<definition>-kind d))
	(let* ((form (source-form d))
	       (s (<definition>-source d))
	       (r (or (hash-at walked form) (maru-forms-walk form (identity-hash-table) (identity-hash-table)))))
	  (push out (cons form (make <callable> name: (<definition>-name d) path: path line: (erosion-line form)
				     last: (if s (<source>-last s) (erosion-line form)) cc: (+ 1 (car r)) forms: (cadr r)))))))
    (list-reverse! out)))
;; one file's walk: each top-level form's answer added to forms, its clone candidates to occurrences (counted by key in
;; seen), its verbose findings to flags, and its callables to owned, each (form . <callable>)
(define-structure <erosion-walk> (forms tops occurrences owned flags seen elsewhere))	; elsewhere: a key's count outside these sources
(define-function erosion-candidate (w x key atoms)	; a list of at least 12 atoms is a clone candidate, counted by its key
  (when (<= 12 atoms)
    (hash-at-put (<erosion-walk>-seen w) key (+ 1 (hash-at (<erosion-walk>-seen w) key 0)))
    (set (<erosion-walk>-occurrences w) (cons (cons key x) (<erosion-walk>-occurrences w)))))
(define-function erosion-walk-source (src w)
  (let ((walked (identity-hash-table)))	; each top-level form's walk, which a definition that is one reuses
    (set *forms-rule-answers* (identity-hash-table))	; and each grammar rule's, which its callable reuses
    (list-do form (cdr src)
      (let* ((binders (identity-hash-table)) (r (maru-forms-walk form binders (<erosion-walk>-flags w))))
	(and (pair? form) (hash-at-put walked form r))
	(set (<erosion-walk>-forms w) (+ (<erosion-walk>-forms w) (cadr r)))
	(set (<erosion-walk>-tops w) (cons form (<erosion-walk>-tops w)))
	(erosion-scan form binders (lambda (x key atoms) (erosion-candidate w x key atoms)))))
    (list-do form (cdr src) (list-do o (erosion-rule-callables (car src) form) (set (<erosion-walk>-owned w) (cons o (<erosion-walk>-owned w)))))
    (list-do o (erosion-definition-callables (car src) (cdr src) walked) (set (<erosion-walk>-owned w) (cons o (<erosion-walk>-owned w))))))
;; what a verbose pattern flags or a clone covers, (covered-table . findings): a candidate met twice or more is a clone
(define-function erosion-coverage (w)
  (let ((covered (identity-hash-table)) (findings ()))
    (hash-do (<erosion-walk>-flags w) (lambda (x rule) (hash-at-put covered x 't) (push findings (make <verbose-finding> rule: rule form: x))))
    (list-do o (<erosion-walk>-occurrences w)
      (and (< 1 (+ (hash-at (<erosion-walk>-seen w) (car o)) ((<erosion-walk>-elsewhere w) (car o)))) (hash-at-put covered (cdr o) 't)))
    (cons covered (list-reverse! findings))))
(define-function erosion-of (sources . elsewhere)	; elsewhere: a clone key's count in the rest of a tree, these sources not in it
  (let ((w (let ((e (or (car elsewhere) (lambda (key) 0))))
	     (make <erosion-walk> forms: 0 flags: (identity-hash-table) seen: (identity-hash-table) elsewhere: e)))
	(callables ()) (flagged 0))
    (list-do src sources (erosion-walk-source src w))
    (let* ((coverage (erosion-coverage w)) (covered (car coverage)) (forms (<erosion-walk>-forms w)))
      (list-do form (<erosion-walk>-tops w) (set flagged (+ flagged (erosion-covered-forms form covered))))
      (list-do o (<erosion-walk>-owned w)	; each callable's own covered forms: a flagged form belongs to the callable whose form holds it
	(set (<callable>-flagged (cdr o)) (erosion-covered-forms (car o) covered))
	(push callables (cdr o)))
      (make <erosion-metrics>
	    erosion: (erosion-per-mille (erosion-masses callables))
	    verbosity: (if (< 0 forms) (/ (* 1000 flagged) forms) 0)
	    callables: callables forms: forms flagged: flagged findings: (cdr coverage) seen: (<erosion-walk>-seen w)))))
;; the ledger's erosion and verbosity, (erosion . verbosity), from check/ledger's entries (ledger.l)
(define-function erosion-ledger (text . read) (let ((sums (apply ledger-sums (cons text read)))) (cons (cadr sums) (caddr sums))))
