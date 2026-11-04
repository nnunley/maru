;;; ./eval notes/plan/live-grammar.l HOST G... -- CLASS RULE SAMPLE...
;;; Compiles each grammar G in process, in order, and has rule RULE of CLASS read every sample to its end.
;;; HOST is a file holding what the grammar's actions call, or "" for none.
(require "source-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)	; cexpr.g is left recursive
;; a host may be a command too, reading *arguments*, so it sees none
(let ((host (next-argument)) (rest *arguments*))
  (set *arguments* ())
  (or (= host "") (require host))
  (set *arguments* rest))
(let ((g (next-argument)))
  (while (not (= g "--"))
    (tpeg-load g)
    (set g (next-argument))))
(let* ((class (eval (string->symbol (next-argument))))
       (rule (eval (string->symbol (concat-string "$" (next-argument))))))
  (while *arguments*
    (let* ((path (next-argument))
	   (text (contents-of-file-named path))
	   (parser (text-parser-for-on class text)))
      (or (rule parser) (error path ": no match"))
      ;; a grammar may leave what follows its last token; only blanks may remain
      (let ((i (<text-parser>-position parser)) (n (string-length text)))
	(while (and (< i n) (<= (string-at text i) 32)) (set i (+ i 1)))
	(or (= i n) (error path ": stopped at " (<text-parser>-position parser) " of " n)))
      (println path " read"))))
