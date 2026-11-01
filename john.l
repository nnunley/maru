;;; john.l -- reads JOHN programs (john.g) to statement forms.
;;;
;;;   (john-read-text text)   the forms of a program's statements, in order
;;;   (john-read path)        the same, for a file

(require "text-parser.l")
(set text-parser-invoke-rule text-parser-invoke-rule-with-recursion)

;; a name reads as an infix relation only once declared (G6): by rel-qualify, or here,
;; for the built-in in and the relations the sources use without showing them
(define *john-prelude-relations* '(in permutation-of in-chess-move-span))
(define *john-relations* ())
(define-function john-relation? (n) (member? n *john-relations*))
(define-function john-relation (n form) (or (member? n *john-relations*) (push *john-relations* n)) form)

;; and a name reads as a class in for some C only once create or group declares it
(define *john-classes* ())
(define-function john-class? (n) (member? n *john-classes*))
(define-function john-class (n form) (or (member? n *john-classes*) (push *john-classes* n)) form)

(define-function john-kw (x) (string->symbol (concat-string (symbol->string x) ":")))
(define-function john-selector (parts)	; ((at: . x) (put: . y)) -> at:put:
  (let ((s "")) (list-do p parts (set s (concat-string s (symbol->string (car p))))) (string->symbol s)))
;; an effect's left side is a unary send: X p = v sets property p of X
(define-function john-effect (target value guard)
  (or (and (pair? target) (= 'send (car target)) (= 3 (list-length target))) (error "an effect sets a property: " target))
  `(set ,(cadr target) ,(caddr target) ,value ,@guard))

(require "cexpr.g.l")
(require "john.g.l")

(define-function john-read-text (text)
  (set *john-relations* *john-prelude-relations*)
  (set *john-classes* ())
  (let ((parser (text-parser-for-on <john> text)))
    (or ($program parser) (error "syntax error"))
    (<john>-result parser)))
(define-function john-read (path) (john-read-text (contents-of-file-named path)))
