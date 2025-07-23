;;; test-eval-k-simple.l - Simple test to verify eval.k syntax
;;;
;;; This just loads eval.k to check for syntax errors

(load "boot.l")

(println "Checking eval.k syntax...")

;; Try to load eval.k as a regular .l file to check basic syntax
(let ((input (open "core/eval.k")))
  (if input
      (let ((forms ())
            (form ()))
        (while (set form (read input))
          (set forms (cons form forms))
          (and (= 0 (% (list-length forms) 10))
               (print ".")))
        (close input)
        (println)
        (println "Read " (list-length forms) " forms from eval.k")
        (println "Basic syntax appears valid"))
    (println "Could not open core/eval.k")))

(println "Done.")