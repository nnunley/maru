;;; source.l -- what loading defined answers its own source: as load evaluates each top-level form (boot.l's *load-hook*),
;;; a definition is kept as a <source>, the file it was read from, its first and last lines and the form as Maru's reader made
;;; it (raw, before expansion), keyed by the object it defined in a weak table, so a definition no longer reachable takes its
;;; source with it; a type, being a number, is kept by its number.  A definition made again keeps only its latest source.
;;; Each answers the selectors source-of, source-form, form-count (maru-forms.l's forms: lists outside quoted data),
;;; line-count (the lines from first to last holding more than a comment), source-text and sources (a selector's: its own and
;;; each method's, in the order defined) and source-tokens (its text as Maru's reader divides it, source-tokens.l, each
;;; token's line the file's); a <source> is an input of its tokens (input.l), so a tree grammar walks them.  What loading didn't define, a lambda made at run time, has no source: ().
;;; A file that only runs is read without running it: (file-definitions path) answers the <definition>s its forms make (kind
;;; function, form, selector, method, apply or type; its name; its <source>), read by source-lift.g, each answering the same
;;; selectors; erosion.l measures through them.
(require "hash.l")
(require "maru-forms.l")
(require "source-tokens.l")

(define-structure <source> (path first last form serial span))	; first, last: the lines the reader noted; serial: the order kept
(define-structure <source-extent> (start end first last tokens))	; where its text is: positions, its true lines, its tokens
(define-method do-print <source> () (print "<source " self.path ":" self.first "-" self.last ">"))
(define-structure <source-file> (text starts tokens forms ranges))	; starts: where each line begins; the rest read when asked

(define *sources* (weak-identity-hash-table))	; object -> <source>
(define *type-sources* (array))			; type -> <source>
(define *source-files* (equal-hash-table))	; path -> <source-file>, read once when asked
(define *source-serial* 0)

;; the greatest line any pair in form was read on, along spines in a loop and into elements by a stack
(define-function source-last-line (form first)
  (let ((todo (list form)) (last first))
    (while todo
      (let ((x (car todo)))
	(set todo (cdr todo))
	(while (pair? x)
	  (let ((s (<pair>-source x))) (and (pair? s) (long? (cdr s)) (< last (cdr s)) (set last (cdr s))))
	  (and (pair? (car x)) (push todo (car x)))
	  (set x (cdr x)))))
    last))
(define-function source-put (object source)
  (set (<source>-serial source) (set *source-serial* (+ *source-serial* 1)))
  (if (long? object)
      (set-array-at *type-sources* object source)
    (and object (hash-at-put *sources* object source))))
(define-function source-keep (object path form)
  (let* ((s (<pair>-source form))
	 (first (if (and (pair? s) (long? (cdr s))) (cdr s) 0))
	 (source (make <source> path: path first: first last: (source-last-line form first) form: form
		       serial: (set *source-serial* (+ *source-serial* 1)))))
    (if (long? object)
	(set-array-at *type-sources* object source)
      (and object (hash-at-put *sources* object source)))))

;; what a top-level form defined, by its head, or (): the object its name is bound to now
(define-function source-value (name) (let ((b (and (symbol? name) (defined? name)))) (and b (%binding-value b))))
(define-function source-defined (form)
  (let ((op (car form)) (rest (cdr form)))
    (and (pair? rest) (symbol? (car rest))
	 (cond ((memq op '(define-function define-form define-selector define-structure define-class)) (source-value (car rest)))
	       ((= op 'define-method)
		(let ((sel (source-value (car rest))) (type (and (pair? (cdr rest)) (source-value (cadr rest)))))
		  (and (selector? sel) (long? type) (array-at (<selector>-methods sel) type))))
	       ((= op 'define)
		(and (pair? (cdr rest)) (pair? (cadr rest)) (= 'lambda (car (cadr rest))) (source-value (car rest))))))))
(set *load-hook* (lambda (path form value) (and (pair? form) (source-keep (source-defined form) path form))))

(define-function source-file (path)
  (or (hash-at *source-files* path)
      (let* ((text (or (contents-of-file-named path) "")) (starts (array 0)))
	(array-append starts 0)
	(for (i 0 (string-length text)) (and (= 10 (string-at text i)) (array-append starts (+ i 1))))
	(hash-at-put *source-files* path (make <source-file> text: text starts: starts)))))
(define-function source-line-holds-code? (text from to)	; whether text from..to has more than blanks and a comment
  (let ((i from) (c 32))
    (while (and (< i to) (or (= c 32) (= c 9) (= c 13))) (set c (string-at text i)) (set i (+ i 1)))
    (not (or (= c 32) (= c 9) (= c 13) (= c 10) (= c ?\;)))))

(define-selector source-of (self) (hash-at *sources* self))
(define-method source-of <long> () (array-at *type-sources* self))
(define-method source-of <source> () self)
(define-selector source-form (self) (let ((s (source-of self))) (and s (source-form s))))
(define-method source-form <source> () self.form)
(define-selector form-count (self) (let ((s (source-of self))) (and s (form-count s))))
(define-method form-count <source> () (maru-forms-count self.form))
(define-selector line-count (self) (let ((s (source-of self))) (and s (line-count s))))
;; Where a definition's text is: the reader notes a line on each pair, which misses a closing paren on a line of its own and
;; drifts after a string holding newlines, and a line may hold more than one definition.  So the file is divided into tokens
;; once (source-tokens.l), read back to forms keeping each list's opening and closing token, and a definition's extent is the
;; list equal to its form nearest the line its reader noted.
(define-function source-file-read (f)	; its tokens, the forms they read back to, and each list's range
  (or (<source-file>-tokens f)
      (let* ((tokens (source-text-tokens (<source-file>-text f))) (fr (tokens-forms-ranges tokens)))
	(set (<source-file>-forms f) (car fr))
	(set (<source-file>-ranges f) (cdr fr))
	(set (<source-file>-tokens f) tokens)))
  f)
(define-function source-extent (s)
  (or (<source>-span s)
      (let* ((f (source-file-read (source-file (<source>-path s)))) (form (<source>-form s)) (ranges (<source-file>-ranges f))
	     (best ()) (distance 0) (todo (list (<source-file>-forms f))))
	(while todo	; every list in the file, along spines in a loop
	  (let ((x (car todo)))
	    (set todo (cdr todo))
	    (and (pair? x) (= (car x) (car form)) (equal x form)
		 (let* ((r (hash-at ranges x)) (d (and r (- (<token>-line (car r)) (<source>-first s)))))
		   (and r (< d 0) (set d (- 0 d)))
		   (and r (or (not best) (< d distance)) (let () (set best r) (set distance d)))))
	    (while (pair? x) (and (pair? (car x)) (push todo (car x))) (set x (cdr x)))))
	(and best
	     (let ((start (<token>-start (car best))) (end (<token>-end (cdr best))) (tokens ()))
	       (array-do t (<source-file>-tokens f) (and (<= start (<token>-start t)) (<= (<token>-end t) end) (push tokens t)))
	       (set (<source>-span s) (make <source-extent> start: start end: end first: (<token>-line (car best))
					    last: (<token>-line (cdr best)) tokens: (list->array (list-reverse! tokens)))))))))
(define-method line-count <source> ()	; its lines, from its first token's to its last's, that hold more than a comment
  (let ((e (source-extent self)))
    (and e
	 (let* ((f (source-file self.path)) (text (<source-file>-text f)) (starts (<source-file>-starts f)) (n 0))
	   (for (l (<source-extent>-first e) (+ (<source-extent>-last e) 1))
	     (let ((from (array-at starts (- l 1)))
		   (to (if (< l (array-length starts)) (array-at starts l) (string-length text))))
	       (and from (source-line-holds-code? text from to) (set n (+ n 1)))))
	   n))))
(define-selector source-text (self) (let ((s (source-of self))) (and s (source-text s))))
(define-method source-text <source> ()	; its own text, from its opening paren to its closing one
  (let ((e (source-extent self)))
    (and e (string-copy (<source-file>-text (source-file self.path)) (<source-extent>-start e)
			(- (<source-extent>-end e) (<source-extent>-start e))))))
(define-function source-by-serial (ss)	; an insertion sort: a selector has a handful of methods
  (let ((out ()))
    (list-do s ss
      (let ((before ()) (after out))
	(while (and after (< (<source>-serial (car after)) (<source>-serial s))) (push before (car after)) (set after (cdr after)))
	(set out (concat-list (list-reverse! before) (cons s after)))))
    out))
(define-selector source-tokens (self) (let ((s (source-of self))) (and s (source-tokens s))))
(define-method source-tokens <source> () (let ((e (source-extent self))) (and e (<source-extent>-tokens e))))
(define-method in-enter <source> ()		1)
(define-method in-start <source> ()		0)
(define-method in-at-end <source> (pos)		(>= pos (array-length (source-tokens self))))
(define-method in-head <source> (pos)		(array-at (source-tokens self) pos))
(define-method in-tail <source> (pos)		(+ pos 1))
(define-selector sources (self) (let ((s (source-of self))) (and s (list s))))
(define-method sources <selector> ()	; its own and each method's, in the order kept
  (let ((out ()))
    (and (source-of self) (push out (source-of self)))
    (array-do m (<selector>-methods self) (let ((s (and m (source-of m)))) (and s (push out s))))
    (source-by-serial out)))

;; definitions read, not run
(define-structure <definition> (kind name source))
(define-method do-print <definition> () (print "<" self.kind " " self.name ">"))
(define-method source-of <definition> () self.source)
(define-function source-lift-concat (ds) (let ((out ())) (list-do d ds (list-do e d (push out e))) (list-reverse! out)))
(define source-lift ())	; the grammar's action, set once its type exists
(tpeg-load "source-lift.g")
(set source-lift
     (lambda (parser d form)
       (let* ((path (<source-lift>-path parser))
	      (s (<pair>-source form))
	      (first (if (and (pair? s) (long? (cdr s))) (cdr s) 0))
	      (source (make <source> path: path first: first last: (source-last-line form first) form: form serial: 0)))
	 (list (make <definition> kind: (car d) name: (cdr d) source: source)))))
(define-function forms-definitions (path forms)	; the definitions forms, read from path, make
  (let ((p (source-parser-for <source-lift> forms)))
    (set (<source-lift>-path p) path)
    (or ($forms p) (error "source: can't read the definitions of " path))
    (<source-parser>-result p)))
(define-function file-definitions (path) (forms-definitions path (find-and-read path)))
;; what was read before this file: the boot file, which the evaluator read itself before load or its hook existed, and each
;; file required before, read again in the order they were evaluated (a file's forms in turn, a require read where it stands,
;; once), so the definition kept for a name is the one the program ran last
(define-function source-replay (path seen)
  (unless (hash-at seen path)
    (hash-at-put seen path 't)
    (list-do form (find-and-read path)
      (if (and (pair? form) (= 'require (car form)) (pair? (cdr form)) (string? (cadr form)) (member? (cadr form) *loaded*))
	  (source-replay (cadr form) seen)
	(list-do d (forms-definitions path (list form))
	  (let ((object (source-defined (source-form d))))
	    (and object (source-put object (<definition>-source d)))))))))
(let ((paths ()) (seen (equal-hash-table)))	; *loaded* is newest first
  (list-do path *loaded* (push paths path))
  (list-do path (cons (if (defined? 'find-and-read-in) "boot2.l" "boot.l") paths) (source-replay path seen)))
