;;; source-tokens.l -- (source-text-tokens text) divides Maru source text as eval.c's reader does into an array of <token>s
;;; (maru-tokens.g): kind (open, open-bracket, open-brace, close, symbol, number, string, char, quote, quasiquote, unquote,
;;; unquote-splicing, comment), text, start and end positions, and the line it starts on, from 1.
(require "text-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(define-structure <token> (kind text start end line))
(define-method do-print <token> () (print "<" self.kind " " self.line ":" self.text ">"))
(define maru-token ())	; the grammar's action, defined once the grammar's type is
(tpeg-load "maru-tokens.g")
(set maru-token
     (lambda (parser kind start)	; not self: make binds self to what it makes
       (let* ((end (<text-parser>-position parser))
	      (text (string-copy (<text-parser>-string parser) start (- end start)))
	      (line (<maru-tokens>-line parser)))
	 (array-append (<maru-tokens>-tokens parser) (make <token> kind: kind text: text start: start end: end line: line)))))
(define-function source-text-tokens (text)
  (let ((p (text-parser-for-on <maru-tokens> text)))
    (set (<maru-tokens>-tokens p) (array))
    (set (<maru-tokens>-line p) 1)
    (or ($tokens p) (error "source-tokens: can't divide the text past " (<text-parser>-position p)))
    (<maru-tokens>-tokens p)))
