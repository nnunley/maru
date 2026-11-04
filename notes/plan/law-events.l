;;; ./eval notes/plan/law-events.l TREE REPORT: what check/law.l printed, in the file REPORT, as events of evidence about the
;;; code TREE, one a law.  A law that stopped the run has no verdict, so it failed.
(require "source-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(tpeg-load "notes/plan/law-report.g")
(require "notes/plan/event-text.l")
(define-function field-text (f) (concat-strings ", " (symbol->string (car f)) " " (event-text (cadr f))))
(let* ((tree (next-argument))
       (parser (text-parser-for-on <lawreport> (contents-of-file-named (next-argument)))))
  ($report parser)
  (list-do verdict (<text-parser>-result parser)
    (when verdict
      (let ((s (concat-strings (symbol->string (car verdict)) " do observed " (symbol->string (cadr verdict))
			       "(tree: " (event-text tree))))
	(list-do f (cddr verdict) (set s (concat-string s (field-text f))))
	(println s ").")))))
