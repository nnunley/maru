;;; Compile mini-eval.l with threaded backend

(load "emit-c-threaded.l")

;; Compile a mini evaluator-like expression that our backend supports
;; This is a conditional that acts like a simple evaluator
(compile-threaded '(if 1 (+ 20 22) 0))