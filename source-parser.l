;;; source-parser.l: a parser over any source with the input selectors (input.l), as compile-tpeg.l
;;; --on source generates for it. Its position is a stream cell, so value-pe's save and restore of
;;; self.position carry over. Text stays on <text-parser> (text-parser.l), which doesn't load this.
(require "input.l")

(define-structure <source-parser> (source position result foreign))

(define-function source-parser-for (class source)
  (new class source (stream-of source)))

(define source-parser-match-any
  (define-method parser-match-any <source-parser> ()
    (let ((c self.position))
      (when (not (stream-end? c))
	(set self.result (stream-head c))
	(set self.position (stream-tail c))
	1))))

;; a class is a string of characters: an element matches if it is a character in it
(define source-parser-match-class
  (define-method parser-match-class <source-parser> (class)
    (let ((c self.position))
      (when (and (not (stream-end? c))
		 (long? (stream-head c))
		 (string-search class (stream-head c)))
	(set self.result (stream-head c))
	(set self.position (stream-tail c))
	1))))

(define source-parser-match-object
  (define-method parser-match-object <source-parser> (obj)
    (let ((c self.position))
      (when (and (not (stream-end? c))
		 (in-same (stream-head c) obj))
	(set self.result obj)
	(set self.position (stream-tail c))
	1))))

;; a literal character, whose result is a one-character string, as on text
(define source-parser-match-char
  (define-method parser-match-char <source-parser> (obj)
    (let ((c self.position))
      (when (and (not (stream-end? c))
		 (in-same (stream-head c) obj))
	(set self.result (list->string (list obj)))
	(set self.position (stream-tail c))
	1))))

;; a string literal matches consecutive elements, as Warth's seq does
(define source-parser-match-string
  (define-method parser-match-string <source-parser> (string len)
    (let ((c self.position)
	  (i 0))
      (while (and (< i len)
		  (not (stream-end? c))
		  (in-same (stream-head c) (string-at string i)))
	(set c (stream-tail c))
	(incr i))
      (when (= i len)
	(set self.result string)
	(set self.position c)
	1))))

(define source-parser-list-from-to
  (define-method parser-list-from-to <source-parser> (from to)
    (stream-span from to)))

(define source-parser-string-from-to
  (define-method parser-string-from-to <source-parser> (from to)
    (list->string (stream-span from to))))

(define source-parser-expected
  (define-method parser-expected <source-parser> (what)
    (error what " expected")))

(define-function source-parser-invoke-rule (name rule self . args)
  (apply rule (cons self args)))

(define source-parser-invoke-rule-simply source-parser-invoke-rule)

(define-function parse-source (grammar rule source)
  (let ((p (source-parser-for grammar source)))
    (or (source-parser-invoke-rule (<selector>-name rule) rule p)
	(error "failed to parse with grammar " (name-of-type grammar) "." (<selector>-name rule)))
    (<source-parser>-result p)))
