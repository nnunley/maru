;;; source-tokens.l -- (source-text-tokens text) divides Maru source text as eval.c's reader does (maru-tokens.g) into an array
;;; of <token>s: kind (open, open-bracket, open-brace, close, symbol, number, string, char, quote, quasiquote, unquote,
;;; unquote-splicing, comment), text, start and end positions, and the line it starts on, from 1, counted afterwards from the
;;; positions.  (tokens-forms tokens) reads them back to the forms Maru's reader makes (maru-token-forms.g).  Tokens are made
;;; for what's asked, a definition's text, not a tree: a text grammar costs some microseconds a character.
(require "source-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")
(require "hash.l")
(define-structure <token> (kind text start end line))
(define-method do-print <token> () (print "<" self.kind " " self.line ":" self.text ">"))
(define-function maru-token (parser kind start end)	; not self: make binds self to what it makes
  (let ((text (string-copy (<text-parser>-string parser) start (- end start))))
    (make <token> kind: kind text: text start: start end: end line: 0)))
(tpeg-load "maru-tokens.g")

;; each token's line: eval.c's reader moves on at a newline and its carriage returns, or a carriage return and its newlines
(define-function source-token-lines (text tokens)
  (let ((line 1) (i 0) (n (string-length text)))
    (array-do t tokens
      (while (< i (<token>-start t))
	(let ((c (string-at text i)))
	  (set i (+ i 1))
	  (when (or (= c 10) (= c 13))
	    (set line (+ line 1))
	    (while (and (< i n) (= (string-at text i) (if (= c 10) 13 10))) (set i (+ i 1))))))
      (set (<token>-line t) line))
    tokens))
(define-function source-text-tokens (text)
  (let ((p (text-parser-for-on <maru-tokens> text)))
    (or ($tokens p) (error "source-tokens: can't divide the text past " (<text-parser>-position p)))
    (source-token-lines text (list->array (<text-parser>-result p)))))

;; tokens to forms
(define-function token-kind? (t kind) (and (= <token> (type-of t)) (= kind (<token>-kind t))))
(define-function token-forms-list (xs)	; xs, dotted if a . comes before its last form, as eval.c's reader has it
  (let ((p xs))
    (while (and (pair? p) (pair? (cdr p)) (pair? (cddr p)) (not (= '. (cadr p)))) (set p (cdr p)))
    (and (pair? p) (pair? (cdr p)) (pair? (cddr p)) (= '. (cadr p)) (not (cdddr p)) (set-cdr p (caddr p))))
  xs)
(define-function token-value (rule text)
  (let ((p (text-parser-for-on <maru-tokens> text)))
    (or (rule p) (error "source-tokens: can't read " text))
    (<text-parser>-result p)))
(define-function token-digits (text from base)	; the whole number text's digits from from make, in base
  (let ((n 0))
    (for (i from (string-length text))
      (let ((c (string-at text i)))
	(set n (+ (* n base) (cond ((and (<= ?0 c) (<= c ?9)) (- c ?0)) ((<= ?a c) (+ 10 (- c ?a))) (else (+ 10 (- c ?A))))))))
    n))
(define-function token-has? (text c)	; whether text holds c (string-search halves a sorted string)
  (let ((i 0) (n (string-length text)))
    (while (and (< i n) (!= c (string-at text i))) (set i (+ i 1)))
    (< i n)))
(define-function token-number (text)	; as eval.c: a double with . or e, else wcstoul's base 0 (0x hex, a leading 0 octal)
  (let* ((negative (= ?- (string-at text 0))) (digits (if negative (string-copy text 1 (- (string-length text) 1)) text)))
    (cond ((or (token-has? digits ?.) (and (token-has? digits ?e) (not (token-has? digits ?x)))) (string->double text))
	  (else (let ((n (cond ((and (< 1 (string-length digits)) (= ?x (string-at digits 1))) (token-digits digits 2 16))
			       ((and (< 1 (string-length digits)) (= ?0 (string-at digits 0))) (token-digits digits 1 8))
			       (else (token-digits digits 0 10)))))
		  (if negative (- 0 n) n))))))
(define-function token-forms-atom (t)
  (let ((kind (<token>-kind t)) (text (<token>-text t)))
    (cond ((= kind 'symbol)	(string->symbol text))
	  ((= kind 'number)	(token-number text))
	  ((= kind 'string)	(token-value $string_value text))
	  (else			(token-value $char_value text)))))
(define token-forms-range ())	; the grammar's action, set once its type exists
(tpeg-load "maru-token-forms.g")
(set token-forms-range (lambda (parser open close list) (and (pair? list) (hash-at-put (<maru-token-forms>-ranges parser) list (cons open close))) list))
(define-function tokens-forms-ranges (tokens)	; (forms . ranges): ranges, by each list, its (opening . closing) tokens
  (let ((p (source-parser-for <maru-token-forms> tokens)))
    (set (<maru-token-forms>-ranges p) (identity-hash-table))
    (or ($forms p) (error "source-tokens: can't read the tokens to forms"))
    (cons (<source-parser>-result p) (<maru-token-forms>-ranges p))))
(define-function tokens-forms (tokens) (car (tokens-forms-ranges tokens)))
