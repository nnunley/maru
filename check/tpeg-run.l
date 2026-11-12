;;; Running a rule on any source, for checks past the selectors.
(require "check/tpeg-try.l")

;; a one-element list holding the result, or nil if the rule failed, so a nil result is visible.  Any grammar: a new
;; parser of the grammar's type takes the source and runs the rule, each kind of parser as it runs its rules.
(define-selector try-rule)
(define-method try-rule <source-parser> (rule source)
  (set self.source source)
  (set self.position (source-parser-stream-of self source))
  (and (source-parser-invoke-rule (<selector>-name rule) rule self) (list self.result)))
(define-method try-rule <text-parser> (rule source)	; text-parser-for-on's parser, on a string
  (set self.string source)
  (set self.limit (string-length source))
  (set self.position 0)
  (set self.memos (array))
  (set self.refill text-parser-refill-default)
  (and (text-parser-invoke-rule (<selector>-name rule) rule self) (list self.result)))
(and (defined? '<parser>)	; peg's grammars (parser.l), when it's loaded first: parse-from runs a rule on a stream
     (let ()
       (eval '(define-selector peg-stream-of (source) source))	; a stream already
       (eval '(define-method peg-stream-of <string> () (string-stream self)))
       (eval '(define-method peg-stream-of <pair> () (list-stream self)))
       (eval '(define-method try-rule <parser> (rule source)
		(and (parse-from self (peg-stream-of source) rule) (list self.result))))))
(define-function try (grammar rule source) (try-rule (new grammar) rule source))

;; did a rule leave the parser where it started
(define-function stays-at-start (grammar rule source)
  (let* ((p (source-parser-for grammar source))
	 (start (<source-parser>-position p)))
    (source-parser-invoke-rule (<selector>-name rule) rule p)
    (and (= start (<source-parser>-position p)) 1)))

;; did a rule reach the end of its source
(define-function reaches-end (grammar rule source)
  (let ((p (source-parser-for grammar source)))
    (source-parser-invoke-rule (<selector>-name rule) rule p)
    (and (stream-end? (<source-parser>-position p)) 1)))
