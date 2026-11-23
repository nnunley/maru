;;; grammar-data.l -- a tpeg grammar's rules as data, for a program that composes with them without loading a parser:
;;; (define VAR '((name pattern parameters [annotations]) ...)), each pattern the tree tpeg parses (match-all,
;;; match-list, assign-result, match-rule, peek-expr, result-expr, ...), the same trees compile-tpeg.l compiles.
;;;   ./eval grammar-data.l FILE.g VAR > FILE-data.l
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(let* ((path (next-argument)) (var (string->symbol (next-argument))))
  (dumpln (list 'define var (list 'quote (cdr (tpeg-parse-whole-file path))))))
