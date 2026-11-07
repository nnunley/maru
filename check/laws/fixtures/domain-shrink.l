;;; domain-shrink.law's support: checked(w) answers 1 for a worker count the facts hold, and stops the run otherwise
(define-function workers (x) x)
(define-function checked (w)
  (or (member? w '(2 4 8)) (error "checked: " w " is not a worker count"))
  1)
