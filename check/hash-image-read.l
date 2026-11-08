;;; After the image is loaded: every key found by itself in the identity table and by an equal one in the other, a
;;; fresh string not in the identity table, the order kept, and the identity table growing past a doubling; the weak table
;;; still weak, its held entry found and the other gone after a collection.
(println (map (lambda (k) (= k (hash-at h k))) keys) " " (hash-at h "a" 0))
(println (hash-at e 'b) " " (hash-includes? e ()) " " (hash-at e (concat-string "s" "")) " " (hash-at e 2.0) " " (hash-at e 3 'gone)
	 " " (hash-keys e))
(let ((more (map (lambda (i) (cons i i)) '(0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19))) (found 0))
  (list-do k more (hash-at-put h k k))
  (list-do k (concat-list keys more) (and (= k (hash-at h k)) (set found (+ found 1))))
  (println found " of " (hash-count h)))
((subr "GC_gcollect"))
(println "weak " (hash-at w (car keys)) " " (hash-count w))
