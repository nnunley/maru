;;; SPIKE: holes as placeholder names, found in the parsed form
(load "notes/spikes/laws/gen.l")
(require "cexpr.g.l")
(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)
;; {x} -> holex in the text
(define-function placeholders (s)
  (let ((out "") (i 0) (n (string-length s)))
    (while (< i n)
      (let ((c (string-at s i)))
	(cond
	  ((= c ?{) (set out (concat-string out "hole")))
	  ((= c ?}) ())
	  (else     (set out (concat-string out (character->string c))))))
      (set i (+ i 1)))
    out))
(define-function find-holes (form)
  (cond
    ((and (symbol? form) (let ((s (symbol->string form))) (and (< 4 (string-length s)) (= "hole" (string-copy s 0 4)))))
     (list form))
    ((pair? form) (concat-list (find-holes (car form)) (find-holes (cdr form))))
    (else ())))
(list-do s '("a + {x} * b" "{c} ? {t} : {e}" "f({x}, 1)" "-{x}" "{x} - {y} - {z}")
  (let ((form (car (parses <cexpr> 'expression (placeholders s)))))
    (print "cexpr  " s "  =>  ") (dump form) (print "   holes ") (dumpln (find-holes form))))
