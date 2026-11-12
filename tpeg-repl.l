;;; tpeg-repl.l: code and grammars interleaved on one input, as repl.l does for peg (check/tpeg-interleave.l).
;;;
;;; ./eval tpeg-repl.l FILE
;;;
;;; The reader is a <tpeg> parser over the file. A grammar block is read by tpeg.g's own rules, then evaluated:
;;; its rules compile in process (compile-tpeg.l's generator), and its expression matches the input after the
;;; block, on the reader's string and position. The reader then goes on from where that match stops.

(require "source-parser.l")
(define compile-tpeg-definitions-only 1)
(require "compile-tpeg.l")

(define-class <tpeg-running> <text-parser> ())

(define *tpeg-reader*  ())			; the <tpeg> parser reading the file
(define *tpeg-running* '<tpeg-running>)		; the grammar that { rules } enriches: the last one defined or extended

;; Matches a grammar's expression, run on a parser of cls, over the reader's input from the reader's position.
;; Both parsers share the string; the reader's position moves to where the match stops.
(define-function tpeg-match-rest (cls run)
  (let* ((r (or *tpeg-reader* (error "a grammar block outside the reader")))
	 (g (text-parser-for-on cls (<text-parser>-string r))))
    (set (<text-parser>-position g) (<text-parser>-position r))
    (let ((ok (run g)))
      (set (<text-parser>-position r) (<text-parser>-position g))
      ok)))

;; { <x> : <parent> (fields) rules }: a new grammar, which becomes the running one
(define-form grammar-define (name parent fields . rules)
  (tpeg-define (list name parent fields) rules)
  (set *tpeg-running* name)
  ())

;; { <x> + rules }: more rules for a grammar, which becomes the running one
(define-form grammar-extend (name . rules)
  (tpeg-define-rules name rules)
  (set *tpeg-running* name)
  ())

;; { rules }, or { rules expression }: the rules enrich the running grammar. The expression is a rule of its own,
;; in a child of the running grammar, so it sees every rule the running grammar has, and it matches the input.
(define-form grammar-eval (rules expr)
  (and rules (tpeg-define-rules *tpeg-running* rules))
  (and expr
       (let ()
	 (eval `(define-class <tpeg-block> ,*tpeg-running* ()))
	 (tpeg-define-rules '<tpeg-block> (list (list 'start expr ())))
	 `(tpeg-match-rest <tpeg-block> (lambda (p) ($start p))))))

;; A file run as a script names its reader on a first line, #!./eval tpeg-repl.l, which the reader passes over as eval does
(define-function tpeg-skip-script-line (p source)
  (and (< 1 (string-length source)) (= ?# (string-at source 0)) (= ?! (string-at source 1))
       (let ((i 2))
	 (while (and (< i (string-length source)) (not (= ?\n (string-at source i)))) (incr i))
	 (set (<text-parser>-position p) i))))

;; Called with where each form or block of the outermost file starts and ends, before it's evaluated: --forms prints them,
;; so erosion reads a script's code and blocks without the input a block takes, which only running it finds
(define *tpeg-read-hook* ())

;; Reads and evaluates a file's forms and blocks in order, as repl.l's repl-parser-stream does.
(define-function tpeg-read-text (source)
  (let ((p (text-parser-for-on <tpeg> source))
	(saved *tpeg-reader*))
    (set *tpeg-reader* p)
    (tpeg-skip-script-line p source)
    (let ((start (<text-parser>-position p)))
      (while ($sexpression p)
	(and *tpeg-read-hook* (not saved) (*tpeg-read-hook* start (<text-parser>-position p)))
	(eval (<text-parser>-result p))
	(set start (<text-parser>-position p))))	; past the input a block took
    ($sspace p)
    (set *tpeg-reader* saved)
    (or (= (<text-parser>-position p) (<text-parser>-limit p))
	(let ()
	  (print "\nsyntax error in read-eval-print near: ")
	  (parser-context p)
	  (error "abort")))))

;; a file of forms and blocks, read as the reader reads its arguments: a check reads its shared blocks with it
(define-function tpeg-read-file (path) (tpeg-read-text (contents-of-file-named path)))

(when (and *arguments* (= "--forms" (car *arguments*)))
  (next-argument)
  (set *tpeg-read-hook* (lambda (start end) (print "\n;tpeg-form " start " " end "\n"))))	; on a line of its own, whatever the script printed
(while *arguments*
  (tpeg-read-file (next-argument)))

(exit 0)
