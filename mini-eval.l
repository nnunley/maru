;;; mini-eval.l - Minimal evaluator that can be compiled by threaded backend

;; Define a minimal evaluator function as a simple expression
;; that our threaded backend can handle

;; This represents: mini_eval(expr) = if (long?(expr)) expr else ((+ 20 22))
;; Which is a simple pattern that can evaluate numbers or return a default calculation

(if (long? 42) 42 (+ 20 22))