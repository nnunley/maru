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
;; a formula as DIMACS text, built once and joined: the checker parses this, never the solver's memory
(define-function sat-dimacs-text (n clauses)
  (let ((parts (list (concat-strings "p cnf " (format "%d" n) " " (format "%d" (list-length clauses)) "\n"))))
    (list-do c clauses
      (let ((line "")) (list-do l c (set line (concat-strings line (format "%d" l) " "))) (push parts (concat-string line "0\n"))))
    (apply concat-strings (list-reverse! parts))))
(define-function sat-c-string (p n)	; n bytes at p, as a Maru string
  (let ((s (string n))) (for (i 0 n) (set-string-at s i (byte-at p i))) s))
;; a check that fails keeps its evidence: the formula and the proof, written to the scratch
;; directory and named in the error; a check that passes writes nothing
(define-function sat-keep (text ext)
  ((subr "system" "s>i") "mkdir -p /tmp/maru-sat")
  (let ((path (concat-strings "/tmp/maru-sat/failed-" (format "%d" ((subr "getpid" ">l"))) ext)))
    (let ((f ((subr "fopen" "ss>p") path "w"))) ((subr "fputs" "sp>i") text f) ((subr "fclose" "p>i") f))
    path))

;; a clause with a literal and its negation is dropped, and a repeated literal kept once, so the
;; formula written for the checker is well formed DIMACS
(define-function sat-clean (clauses)
  (let ((out ()))
    (list-do c clauses
      (let ((kept ()) (taut ()))
	(list-do l c (or (member? l kept) (let () (and (member? (- l) kept) (set taut 1)) (push kept l))))
	(or taut (push out (list-reverse! kept)))))
    (list-reverse! out)))

;; a fresh solver for one formula over n variables: (sat . values), (unsat) or (unknown); with
;; keep, (unsat . proof-text).  A model is checked against the clauses (E_MODEL), and a
;; refutation's proof by drat-check.irl against the formula's DIMACS text (E_PROOF), in memory.
(define-function sat-decide (n given . keep)
  (let ((s (sat-init)) (out ()) (clauses (sat-clean given)))
    ((sat-fn "sat_reserve" "pl") s n)
    ((sat-fn "sat_proof_on" "p") s)
    (list-do c clauses (sat-add-clause s c))
    (let ((r (sat-solve s)))
      (cond ((= r 10) (let ((vals (array (+ n 1))))
			(for (v 1 (+ n 1)) (set-array-at vals v (< 0 (sat-val s v))))
			(or (sat-model-holds? clauses vals)
			    (error "E_MODEL: a clause is false in the solver's model; the formula is "
				   (sat-keep (sat-dimacs-text n clauses) ".cnf")))
			(set out (cons 'sat vals))))
	    ((= r 20) (let* ((cnf (sat-dimacs-text n clauses))
			     (text ((sat-fn "sat_proof_text" "p>p") s))
			     (len ((sat-fn "sat_proof_length" "p>l") s)))
			(or (= 1 ((sat-fn "drat_check_text" "slpl>l") cnf (string-length cnf) text len))
			    (error "E_PROOF: the refutation's proof fails at line " ((sat-fn "drat_failed_line" ">l"))
				   "; the formula is " (sat-keep cnf ".cnf") " and the proof " (sat-keep (sat-c-string text len) ".drat")))
			(set out (if keep (cons 'unsat (sat-c-string text len)) (list 'unsat)))))
	    (else (set out (list 'unknown)))))
    (sat-release s)
    out))
