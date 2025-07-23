;;; Meta-compile simple evaluator with threaded backend

(load "emit-c-threaded.l")

;; Try to compile the main expression from simple-eval.l
(compile-threaded '(+ 10 32))