;;; Extract a compilable function from eval.l's concepts

(load "emit-c-threaded.l")

;; This represents the core of eval.l's type checking logic
;; Simplified to work with our threaded backend
;; "If the expression is a number (represented as 1), return it, else return 0"

;; This embodies eval.l's "numbers evaluate to themselves" rule
(compile-threaded '(if 1 42 0))