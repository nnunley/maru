;;; source.l -- what loading defined answers its own source: as load evaluates each top-level form (boot.l's *load-hook*),
;;; a definition is kept as a <source>, the file it was read from, its first and last lines and the form as Maru's reader made
;;; it (raw, before expansion), keyed by the object it defined in a weak table, so a definition no longer reachable takes its
;;; source with it; a type, being a number, is kept by its number.  A definition made again keeps only its latest source.
;;; Each answers the selectors source-of, source-form, form-count (maru-forms.l's forms: lists outside quoted data),
;;; line-count (the lines from first to last holding more than a comment), source-text and sources (a selector's: its own and
;;; each method's, in the order defined).  What loading didn't define, a lambda made at run time, has no source: ().
;;; A file that only runs is read without running it: (file-definitions path) answers the <definition>s its forms make (kind
;;; function, form, selector, method, apply or type; its name; its <source>), read by source-lift.g, each answering the same
;;; selectors; erosion.l measures through them.
(require "hash.l")
(require "maru-forms.l")

(define-structure <source> (path first last form serial))	; serial: the order sources were kept in
(define-method do-print <source> () (print "<source " self.path ":" self.first "-" self.last ">"))
(define-structure <source-file> (text starts))			; starts: where each line begins, line 1 at index 0

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
(define-function source-keep (object path form)
  (let* ((s (<pair>-source form))
	 (first (if (and (pair? s) (long? (cdr s))) (cdr s) 0))
	 (source (make <source> path: path first: first last: (source-last-line form first) form: form
		       serial: (set *source-serial* (+ *source-serial* 1)))))
    (if (long? object)
	(set-array-at *type-sources* object source)
      (and object (hash-at-put *sources* object source)))))

;; what a top-level form defined, by its head, or ()
(define-function source-defined (form)
  (let ((op (car form)) (rest (cdr form)))
    (and (pair? rest) (symbol? (car rest))
	 (cond ((memq op '(define-function define-form define-selector define-structure define-class)) (eval (car rest)))
	       ((= op 'define-method)
		(let ((sel (eval (car rest))) (type (eval (cadr rest))))
		  (and (selector? sel) (long? type) (array-at (<selector>-methods sel) type))))
	       ((= op 'define)
		(and (pair? (cdr rest)) (pair? (cadr rest)) (= 'lambda (car (cadr rest))) (eval (car rest))))))))
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
(define-method line-count <source> ()
  (let* ((f (source-file self.path)) (text (<source-file>-text f)) (starts (<source-file>-starts f)) (n 0))
    (for (l self.first (+ self.last 1))
      (let ((from (array-at starts (- l 1)))
	    (to (if (< l (array-length starts)) (array-at starts l) (string-length text))))
	(and from (source-line-holds-code? text from to) (set n (+ n 1)))))
    n))
(define-selector source-text (self) (let ((s (source-of self))) (and s (source-text s))))
(define-method source-text <source> ()	; its lines, the last without its newline
  (let* ((f (source-file self.path)) (text (<source-file>-text f)) (starts (<source-file>-starts f))
	 (from (array-at starts (- self.first 1)))
	 (to (if (< self.last (array-length starts)) (- (array-at starts self.last) 1) (string-length text))))
    (string-copy text from (- to from))))
(define-function source-by-serial (ss)	; an insertion sort: a selector has a handful of methods
  (let ((out ()))
    (list-do s ss
      (let ((before ()) (after out))
	(while (and after (< (<source>-serial (car after)) (<source>-serial s))) (push before (car after)) (set after (cdr after)))
	(set out (concat-list (list-reverse! before) (cons s after)))))
    out))
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
