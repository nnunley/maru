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

;; the cells of a call's arguments, first argument first, whose tail is the caller's input
(define-function source-parser-arguments (source args tail)
  (if (pair? args)
      (new <cell> source () () (car args) (source-parser-arguments source (cdr args) tail) ())
      tail))

;; A rule takes no parameters: its arguments are the first elements of its input. On failure the
;; saved cell is restored, so no argument cell stays behind.
(define-function source-parser-invoke-rule (name rule self . args)
  (let ((saved (<source-parser>-position self)))
    (set (<source-parser>-position self) (source-parser-arguments (<source-parser>-source self) args saved))
    (or (rule self)
	(let () (set (<source-parser>-position self) saved) ()))))

(define source-parser-invoke-rule-simply source-parser-invoke-rule)

;; the method a rule name finds on a type: its own, or the nearest parent's (what a call by name reaches)
(define-function source-parser-method-of (sel type)
  (or (array-at (<selector>-methods sel) type)
      (<selector>-inherit (<selector>-methods sel) type)))

;; {apply x args}: the rule named x on this object's type, so an override is the one called. A name with
;; no rule fails the match. prefix is $ for a value and $$ for an effect, as the rule's selectors are.
(define-function source-parser-apply (self prefix name . args)
  (let* ((sym  (concat-symbol prefix name))
	 (sel  (and (defined? sym) (eval sym)))
	 (rule (and (selector? sel) (source-parser-method-of sel (type-of self)))))
    (and rule (apply source-parser-invoke-rule (cons name (cons rule (cons self args)))))))

;; {super r args}: r as the parent defines it, whatever the object's type is. parent is the base of the class
;; the calling rule is defined in, so an override reaches the rule it overrides, or what that inherits.
(define-function source-parser-super (self prefix parent name . args)
  (let* ((sel  (eval (concat-symbol prefix name)))
	 (rule (or (source-parser-method-of sel parent)
		   (error "no rule " name " in " (name-of-type parent)))))
    (apply source-parser-invoke-rule (cons name (cons rule (cons self args))))))

(define-function parse-source (grammar rule source)
  (let ((p (source-parser-for grammar source)))
    (or (source-parser-invoke-rule (<selector>-name rule) rule p)
	(error "failed to parse with grammar " (name-of-type grammar) "." (<selector>-name rule)))
    (<source-parser>-result p)))
