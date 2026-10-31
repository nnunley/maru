;; {x} -> holex in the text
(define-function placeholders (s)
  (let ((out "") (i 0) (n (string-length s)))
    (while (< i n)
      (let ((c (string-at s i)))
	(cond
	  ((= c ?{) (set out (concat-string out "hole")))
	  ((= c ?}) ())
	  (else     (set out (concat-string out (character->string c))))))
      (set i (+ i 1)))
    out))
(define-function find-holes (form)
  (cond
    ((and (symbol? form) (let ((s (symbol->string form))) (and (< 4 (string-length s)) (= "hole" (string-copy s 0 4)))))
     (list form))
    ((pair? form) (concat-list (find-holes (car form)) (find-holes (cdr form))))
    (else ())))
