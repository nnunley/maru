;;; Running a rule on any source, for checks past the selectors.
(require "check/tpeg-try.l")

;; a one-element list holding the result, or nil if the rule failed, so a nil result is visible
(define-function try (grammar rule source)
  (let ((p (text-parser-for-source grammar source)))
    (and (text-parser-invoke-rule (<selector>-name rule) rule p)
	 (list (<text-parser>-result p)))))

;; where the parser stands after a rule, matched or not
(define-function position-after (grammar rule source)
  (let ((p (text-parser-for-source grammar source)))
    (text-parser-invoke-rule (<selector>-name rule) rule p)
    (<text-parser>-position p)))
