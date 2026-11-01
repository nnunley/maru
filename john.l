;;; john.l -- reads JOHN programs (john.g) to statement forms.
;;;
;;;   (john-read-text text)   the forms of a program's statements, in order
;;;   (john-read path)        the same, for a file

(require "text-parser.l")
(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

;; a name reads as an infix relation only if declared (G6): by a rel-qualify anywhere in
;; the program, or here, for the built-in in and the relations the sources use without
;; showing them
(define *john-prelude-relations* '(in permutation-of in-chess-move-span))
(define *john-relations* ())
(define-function john-relation? (n) (member? n *john-relations*))
(define-function john-relation (n form) (or (member? n *john-relations*) (push *john-relations* n)) form)

(define-function john-kw (x) (string->symbol (concat-string (symbol->string x) ":")))
(define-function john-selector (parts)	; ((at: . x) (put: . y)) -> at:put:
  (let ((s "")) (list-do p parts (set s (concat-string s (symbol->string (car p))))) (string->symbol s)))
;; an effect's left side is a unary send: X p = v sets property p of X
(define-function john-effect (target value guard)
  (or (and (pair? target) (= 'send (car target)) (= 3 (list-length target))) (error "an effect sets a property: " target))
  `(set ,(cadr target) ,(caddr target) ,value ,@guard))

(require "cexpr.g.l")
(require "john.g.l")

;; two passes, so a relation may be used before its rel-qualify, as JOHN lets any name be:
;; the first collects the declared relations (its forms may misread a use above one)
(define-function john-parse (text) (let ((parser (text-parser-for-on <john> text))) (and ($program parser) parser)))
(define-function john-read-text (text)
  (set *john-relations* *john-prelude-relations*)
  (john-parse text)
  (let ((parser (john-parse text)))
    (or parser (error "syntax error"))
    (<john>-result parser)))
(define-function john-read (path) (john-read-text (contents-of-file-named path)))
