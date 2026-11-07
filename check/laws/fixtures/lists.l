;;; lists.law's support: as_list answers "ok" when its argument is a Maru list of numbers, which a rule's [c | s] is.
(define-function numbers? (s) (or (not s) (and (pair? s) (long? (car s)) (numbers? (cdr s)))))
(define-function as_list (s) (if (numbers? s) "ok" (cons 'bad s)))
