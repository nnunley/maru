;;; Load boot.l manually to bypass issue
(load "boot.l")

;;; Load emit.l and emit-c.l 
(load "emit.l")
(load "emit-c.l")

;;; Override gen-env to use C backend
(define-function gen-env (env) (gen-env-c env))

;;; Test case
(compile-begin)

(define printf (extern 'printf))

(define-function add (a b)
  (+ a b))

(define-function main (argc argv)
  (printf "Result: %d\n" (add 40 2))
  0)

(compile-end)