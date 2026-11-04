;;; Messages a John program loads: John objects answer them by reading Maru, here a grammar's rule.
(define-john-builtin doubled john-doubled)
(define-method john-doubled <long> () (* 2 self))
(define-john-builtin parses-as-c john-parses-as-c)
(define-method john-parses-as-c <string> ()
  (let ((p (text-parser-for-on <cexpr> self)))
    (john-bool (and ($expression p) (= (<text-parser>-position p) (string-length self))))))
(define-john-builtin text-of john-text-of)
(define-method john-text-of <symbol> () (john-lookup *john-world* self 'text))
