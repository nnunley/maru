;;; Core forms give the same integers in both namespaces, and comparisons and
;;; logic the same truth.  With no argument, print each form's untyped value;
;;; with "k", print a typed program that prints each one's typed value.

(define core-values
  '((+ 2 3) (- 7 10) (* 6 7) (/ 17 5) (% 17 5) (<< 1 4) (>> 64 2)
    (& 12 10) (| 12 10) (^ 12 10) (- 5) (~ 5) (if (< 1 2) 3 4)))

(define core-truths
  '((< 1 2) (< 2 1) (<= 2 2) (= 3 3) (!= 3 3) (>= 1 2) (> 2 1) (not (< 1 2))
    (and (< 1 2) (< 2 3)) (or (< 2 1) (< 1 2))))

(define core-forms (concat-list core-values (map (lambda (f) `(if ,f 1 0)) core-truths)))

(if (pop *arguments*)
    (let ()
      (dumpln '(define (printf (int char * ...) *) (extern printf)))
      (dumpln `(define-function main int ()
		 ,@(map (lambda (f) `(printf "%d\n" ,f)) core-forms)
		 (return 0))))
  (list-do f core-forms (println (eval f))))
