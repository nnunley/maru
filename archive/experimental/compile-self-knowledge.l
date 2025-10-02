;;; Compile individual pieces of self-knowledge

(load "emit-c-threaded.l")

;; Compile the most complex self-knowledge expression the backend can handle
(compile-threaded '(if 1 (+ 42 0) 40))