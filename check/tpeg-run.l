;;; Running a rule on any source, for checks past the selectors.
(require "check/tpeg-try.l")

;; a one-element list holding the result, or nil if the rule failed, so a nil result is visible
(define-function try (grammar rule source)
  (let ((p (source-parser-for grammar source)))
    (and (source-parser-invoke-rule (<selector>-name rule) rule p)
	 (list (<source-parser>-result p)))))

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
