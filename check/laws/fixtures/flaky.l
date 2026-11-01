;;; For flaky.law: a reference that crashes on its first question only, and a fork that always fails.
(define flaky-asked 0)
(define-function flaky (x) (set flaky-asked (+ flaky-asked 1)) (if (= 1 flaky-asked) '(crash 7) 'accept))
(set fork (lambda () -1))
