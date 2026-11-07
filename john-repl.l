;;; john-repl.l -- JOHN at a prompt.   ./eval john-repl.l [FILE...]
;;; Each FILE's statements are entered into one session, then statements are read from standard input, echo on, as in
;;; RN-2008-003's transcripts: a declaration answers ok., a query its value, a step its mutations, an error its message.
;;; A statement ends at a line whose last character, blanks aside, is . or ?; the prompt shows only on a terminal.
(require "john-eval.l")

(define getchar (subr "getchar" ">i"))
(define isatty (subr "isatty" "i>i"))
(define fflush (subr "fflush" "p>i"))
(define-function john-repl-line ()	; a line without its newline, or () at the end of input
  (let ((cs ()) (c (getchar)))
    (if (< c 0) ()
      (while (and (>= c 0) (!= c 10)) (push cs c) (set c (getchar)))
      (list->string (list-reverse! cs)))))
(define-function john-repl-ends? (line)	; the last character, blanks aside, is . (46) or ? (63)
  (let ((i (- (string-length line) 1)))
    (while (and (>= i 0) (member? (string-at line i) '(32 9 10 13))) (set i (- i 1)))
    (and (>= i 0) (member? (string-at line i) '(46 63)))))
(define-function john-repl-read (text)	; read once, keeping the relations declared so far
  (let ((parser (text-parser-for-on <john> text)))
    (if ($program parser) (<john>-result parser) (error "john: can't read: " text))))
(define-function john-repl-answer (text)
  (set *john-echo* 1)
  (require "recover.l")
  (let ((forms (try-call (lambda () (john-repl-read text)) (lambda (c) (println (john-condition-text c)) ()))))
    (list-do s forms (list-do l (john-enter s) (println l)))))

(john-begin)
(set *john-relations* *john-prelude-relations*)
(list-do path *arguments*
  (let ((forms (john-read path)))	; a file is read twice, so a relation may be used before its rel-qualify
    (list-do s forms (john-enter s))))
(set *arguments* ())
(let ((tty (= 1 (isatty 0))) (text "") (line ()))
  (while (let () (and tty (let () (print "> ") (fflush 0))) (set line (john-repl-line)))
    (set text (concat-strings text line "\n"))
    (and (john-repl-ends? text) (let () (john-repl-answer text) (set text ""))))
  (or (= "" text) (println "unfinished statement")))
