;;; check/source-tokens.l -- ./eval check/source-tokens.l FILE...: source-tokens.l reads Maru text to tokens, each with its
;;; kind, text, place and line, and the tokens read back to the forms Maru's own reader makes, for each file named.
(require "source.l")
(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))
(define-function kinds (text) (map (lambda (t) (<token>-kind t)) (array->list (source-text-tokens text))))
(define-function texts (text) (map (lambda (t) (<token>-text t)) (array->list (source-text-tokens text))))
(expect "kinds" (kinds "(f 'x) ; c\n") '(open symbol quote symbol close comment))
(expect "texts" (texts "(f 'x) ; c\n") '("(" "f" "'" "x" ")" "; c"))
(expect "quasiquote" (kinds "`(a ,b ,@c)") '(quasiquote open symbol unquote symbol unquote-splicing symbol close))
(expect "atoms" (kinds "\"a\\\"b\" ?c 12 -3.5 0x1f 3e -x") '(string char number number number number symbol))
(expect "1+ is a number and a symbol, as eval.c reads it" (texts "1+") '("1" "+"))
(list-do s '("<pair>" "*g*" "%eax" "$rule" ".long" "a,b" "x->y" "a?")
  (expect s (texts s) (list s)))
(let ((ts (source-text-tokens "a\n\n  (b\n c)")))
  (expect "lines" (map (lambda (t) (<token>-line t)) (array->list ts)) '(1 3 3 4 4))
  (expect "starts" (map (lambda (t) (<token>-start t)) (array->list ts)) (quote (0 5 6 9 10))))
;; a definition's tokens, as source.l answers them
(load "check/source/defs.l")
(define defined (list source-fixture-f source-fixture-g source-fixture-s <source-fixture> source-fixture-h
		      (array-at (<selector>-methods source-fixture-s) <long>) load hash-at))
(list-do x defined
  (expect "a definition's tokens read back to its form" (tokens-forms (source-tokens x)) (list (source-form x))))
(expect "a token's line is the file's" (<token>-line (array-at (source-tokens (array-at (<selector>-methods source-fixture-s) <long>)) 0)) 9)
(tpeg-load "check/source/symbols.g")
(expect "a tree grammar walks a definition's tokens" (parse-source <source-symbols> $count (source-of source-fixture-f)) 5)
(while *arguments*
  (let* ((path (next-argument)) (text (contents-of-file-named path)))
    (or (equal (tokens-forms (source-text-tokens text)) (find-and-read path))
	(error "source-tokens: " path " reads otherwise than Maru's reader"))))
(println (if ok "source tokens ok" "source tokens FAILED"))
