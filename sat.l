;;; sat.l -- the SAT solver library (build/sat.dylib, which make builds from dimacs.irl,
;;; sat.irl and drat-check.irl) from untyped Maru (draft-ndn-maru-sat-00).
;;;
;;;   (sat-library)                     the library, opened once by its path in the tree
;;;   (sat-fn name signature)           a subr for one of its exported functions
;;;   (sat-write-dimacs path n clauses) a formula over n variables, as DIMACS

(define *sat-library* ())
(define *sat-path* (if (= 0 ((subr "system" "s>i") "test `uname` = Darwin")) "build/sat.dylib" "build/sat.so"))
(define-function sat-library ()	; its path in the tree, with a slash so dlopen searches nowhere (R-native)
  (or *sat-library*
      (let ((lib ((subr "dlopen" "si>p") *sat-path* 2)))
	(and (= 0 lib) (error "E_LIBRARY: " *sat-path* " not built; run make " *sat-path*))
	(set *sat-library* lib))))
(define-function sat-fn (name signature)
  (let ((addr ((subr "dlsym" "ps>p") (sat-library) name)))
    (and (= 0 addr) (error "E_LIBRARY: " *sat-path* " has no " name))
    (subr addr signature)))
(define-function sat-write-dimacs (path n clauses)
  (let ((f ((subr "fopen" "ss>p") path "w")) (puts (subr "fputs" "sp>i")))
    (puts (concat-strings "p cnf " (format "%d" n) " " (format "%d" (list-length clauses)) "\n") f)
    (list-do c clauses
      (let ((s "")) (list-do l c (set s (concat-strings s (format "%d" l) " "))) (puts (concat-string s "0\n") f)))
    ((subr "fclose" "p>i") f)))

;;; IPASIR (sat.irl), and every model checked against the clauses it answers (R-model-checked)
(define-function sat-init () ((sat-fn "sat_init" ">p")))
(define-function sat-release (s) ((sat-fn "sat_release" "p") s))
(define-function sat-add (s lit) ((sat-fn "sat_add" "pl") s lit))
(define-function sat-add-clause (s clause) (list-do l clause (sat-add s l)) (sat-add s 0))
(define-function sat-assume (s lit) ((sat-fn "sat_assume" "pl") s lit))
(define-function sat-solve (s) ((sat-fn "sat_solve" "p>l") s))
(define-function sat-val (s lit) ((sat-fn "sat_val" "pl>l") s lit))
(define-function sat-failed (s lit) ((sat-fn "sat_failed" "pl>l") s lit))
(define-function sat-model-holds? (clauses values)	; values: an array by variable, t or ()
  (let ((ok 1))
    (list-do c clauses
      (let ((holds ()))
	(list-do l c (and (if (< 0 l) (array-at values l) (not (array-at values (- l)))) (set holds 1)))
	(or holds (set ok ()))))
    ok))
;; where formulas and proofs are written: made if missing, never through a symbolic link at
;; its last component (draft-ndn-maru-sat-00, Security Considerations)
(define *sat-proof-dir* "/tmp/maru-sat")
(define *sat-files* 0)
(define-function sat-proof-dir-usable? (dir)
  (let ((buf ((subr "malloc" "l>p") 4096)))
    (and (= 0 ((subr "system" "s>i") (concat-strings "mkdir -p " dir)))
	 (let ((link ((subr "readlink" "spl>l") dir buf 4096))) ((subr "free" "p") buf) (< link 0)))))
(define-function sat-file (ext)	; this process's next file there, named so agents running at once don't collide
  (or (sat-proof-dir-usable? *sat-proof-dir*) (error "E_PROOF_DIR: " *sat-proof-dir* " is not a directory to write proofs in"))
  (set *sat-files* (+ *sat-files* 1))
  (concat-strings *sat-proof-dir* "/" (format "%d" ((subr "getpid" ">l"))) "-" (format "%d" *sat-files*) ext))

;; a clause with a literal and its negation is dropped, and a repeated literal kept once, so the
;; formula written for the checker is well formed DIMACS
(define-function sat-clean (clauses)
  (let ((out ()))
    (list-do c clauses
      (let ((kept ()) (taut ()))
	(list-do l c (or (member? l kept) (let () (and (member? (- l) kept) (set taut 1)) (push kept l))))
	(or taut (push out (list-reverse! kept)))))
    (list-reverse! out)))

;; a fresh solver for one formula over n variables: (sat . values), (unsat . proof-path) or
;; (unknown).  A model is checked against the clauses (E_MODEL), and a refutation's proof by
;; drat-check.irl against the formula as written (E_PROOF).
(define-function sat-decide (n given)
  (let ((s (sat-init)) (out ()) (cnf (sat-file ".cnf")) (proof (sat-file ".drat")) (clauses (sat-clean given)))
    (sat-write-dimacs cnf n clauses)
    ((sat-fn "sat_reserve" "pl") s n)
    ((sat-fn "sat_set_proof" "ps>l") s proof)
    (list-do c clauses (sat-add-clause s c))
    (let ((r (sat-solve s)))
      (cond ((= r 10) (let ((vals (array (+ n 1))))
			(for (v 1 (+ n 1)) (set-array-at vals v (< 0 (sat-val s v))))
			(or (sat-model-holds? clauses vals) (error "E_MODEL: a clause is false in the solver's model"))
			(set out (cons 'sat vals))))
	    ((= r 20) (sat-release s) (set s ())
		      (or (= 1 ((sat-fn "drat_check" "ss>l") cnf proof))
			  (error "E_PROOF: the refutation's proof fails at line " ((sat-fn "drat_failed_line" ">l"))))
		      (set out (cons 'unsat proof)))
	    (else (set out (list 'unknown)))))
    (and s (sat-release s))
    out))
