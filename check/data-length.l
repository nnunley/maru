;;; data-length answers the length a Data was made with, not the size of the collector's block holding it (eval, eval3;
;;; eval2 has no data-length).
(let ((wrong ()))
  (for (n 0 3000) (let ((d (data n))) (or (= n (data-length d)) (set wrong (cons (cons n (data-length d)) wrong)))))
  (println (if wrong (concat-string "FAIL data-length, asked and answered: " (long->string (list-length wrong))) "data-length ok")))
