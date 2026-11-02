;;; john-allocation.l -- the x86 allocator's allocation, checked slot by slot in the current world:
;;; every slot from a variable's start to just before its end holds it in one register (two for
;;; length 4, a register pair), and nowhere else does.  The memo's room check reads only a range's
;;; two ends, so an assignment could overwrite a variable; this would catch it.  Shared by
;;; check/john-run.l (the search) and check/sat-john.l (planner sat).

(define-function john-allocation-fits? ()
  (let ((slots (map (lambda (r) (john-eval (list 'send r 'allocations) *john-world* ())) '(R1 R2 R3 R4))) (fits 1))
    (list-do v '(Va VB Vc Vd VE)
      (let ((range (john-eval (list 'send v 'live-range) *john-world* ())) (want (/ (john-eval (list 'send v 'length) *john-world* ()) 2)))
	(for (i 1 13)
	  (let ((n 0) (inside (and (<= (car range) i) (< i (cadr range)))))
	    (list-do r slots (and (= v (john-builtin r 'at: (list i))) (set n (+ n 1))))
	    (or (= n (if inside want 0)) (let () (set fits ()) (println "slot " i " holds " v " " n " times")))))))
    fits))
