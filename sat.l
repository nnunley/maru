;;; sat.l -- the SAT solver library (build/sat.dylib, which make builds from dimacs.irl,
;;; sat.irl and drat-check.irl) from untyped Maru (draft-ndn-maru-sat-00).
;;;
;;;   (sat-library)                     the library, opened once by its path in the tree
;;;   (sat-fn name signature)           a subr for one of its exported functions
;;;   (sat-write-dimacs path n clauses) a formula over n variables, as DIMACS

(define *sat-library* ())
(define *sat-path* (if (= 0 ((subr "system" "s>i") "test `uname` = Darwin"))
		       "build/sat.dylib"
		       "build/sat.so"))
;; its path in the tree, with a slash so dlopen searches nowhere (R-native)
(define-function sat-library ()
  (or *sat-library*
      (let ((lib ((subr "dlopen" "si>p") *sat-path* 2)))
	(and (= 0 lib) (error "E_LIBRARY: " *sat-path* " not built; run make " *sat-path*))
	(set *sat-library* lib))))
(define *sat-fns* ())	; (name . subr), looked up once each
(define-function sat-fn (name signature)
  (let ((hit (assq name *sat-fns*)))
    (if hit
	(cdr hit)
	(let ((addr ((subr "dlsym" "ps>p") (sat-library) name)))
	  (and (= 0 addr) (error "E_LIBRARY: " *sat-path* " has no " name))
	  (let ((f (subr addr signature)))
	    (push *sat-fns* (cons name f))
	    f)))))
(define-function sat-write-dimacs (path n clauses)
  (let ((f ((subr "fopen" "ss>p") path "w")) (puts (subr "fputs" "sp>i")))
    (puts (concat-strings "p cnf " (format "%d" n) " " (format "%d" (list-length clauses)) "\n") f)
    (list-do c clauses
      (let ((s ""))
	(list-do l c (set s (concat-strings s (format "%d" l) " ")))
	(puts (concat-string s "0\n") f)))
    ((subr "fclose" "p>i") f)))

;;; IPASIR (sat.irl), and every model checked against the clauses it answers (R-model-checked)
(define-function sat-init () ((sat-fn "sat_init" ">p")))
(define-function sat-release (s) ((sat-fn "sat_release" "p") s))
(define-function sat-add (s lit) ((sat-fn "sat_add" "pl") s lit))
(define-function sat-add-clause (s clause)
  (list-do l clause (sat-add s l))
  (sat-add s 0))
(define-function sat-assume (s lit) ((sat-fn "sat_assume" "pl") s lit))
(define-function sat-solve (s) ((sat-fn "sat_solve" "p>l") s))
(define-function sat-val (s lit) ((sat-fn "sat_val" "pl>l") s lit))
(define-function sat-failed (s lit) ((sat-fn "sat_failed" "pl>l") s lit))
(define-function sat-c-string (p n)	; n bytes at p, as a Maru string
  (let ((s (string n)))
    (for (i 0 n) (set-string-at s i (byte-at p i)))
    s))
;; a check that fails keeps its evidence: the formula and the proof, written to the scratch
;; directory and named in the error; a check that passes writes nothing
(define-function sat-keep (text ext)
  ((subr "system" "s>i") "mkdir -p /tmp/maru-sat")
  (let ((path (concat-strings "/tmp/maru-sat/failed-" (format "%d" ((subr "getpid" ">l"))) ext)))
    (let ((f ((subr "fopen" "ss>p") path "w")))
      ((subr "fputs" "sp>i") text f)
      ((subr "fclose" "p>i") f))
    path))

;; a clause with a literal and its negation is dropped, and a repeated literal kept once, so the
;; formula written for the checker is well formed DIMACS
(define-function sat-clean (clauses)
  (let ((out ()))
    (list-do c clauses
      (let ((kept ()) (taut ()))
	(list-do l c
	  (or (member? l kept)
	      (let ()
		(and (member? (- l) kept) (set taut 1))
		(push kept l))))
	(or taut (push out (list-reverse! kept)))))
    (list-reverse! out)))

;; a fresh solver for one formula over n variables: (sat . values), (unsat) or (unknown); with
;; keep, (unsat . proof-text).  A model is checked against the clauses (E_MODEL), and a
;; refutation's proof by drat-check.irl against the formula's DIMACS text (E_PROOF), in memory.
;; a solve gives up, unknown, after this many conflicts; () is the solver's own limit
(define *sat-conflicts* ())
;; the same for a formula in a store (dimacs.irl): the solver reads it, the model is checked
;; against it, and a refutation's proof against its DIMACS text, all without copying it into Maru
(define-function sat-store-text (n f)	; the store's DIMACS text, as a Maru string
  (let* ((t ((sat-fn "store_text" "pl>p") f n))
	 (text (sat-c-string ((sat-fn "text_chars" "p>p") t) ((sat-fn "text_length" "p>l") t))))
    ((sat-fn "text_free" "p") t)
    text))
(define-function sat-decide-store (n f . keep)
  (let ((s (sat-init))
	(out ()))
    ((sat-fn "sat_reserve" "pl") s n)
    ((sat-fn "sat_proof_on" "p") s)
    (and *sat-conflicts* ((sat-fn "sat_set_conflicts" "pl") s *sat-conflicts*))
    ((sat-fn "sat_add_store" "pp") s f)
    (let ((r (sat-solve s)))
      (cond ((= r 10)
	     (or (= 1 ((sat-fn "sat_store_holds" "pp>l") s f))
		 (error "E_MODEL: a clause is false in the solver's model; the formula is "
			(sat-keep (sat-store-text n f) ".cnf")))
	     (let ((vals (array (+ n 1))))
	       (for (v 1 (+ n 1)) (set-array-at vals v (< 0 (sat-val s v))))
	       (set out (cons 'sat vals))))
	    ((= r 20)
	     (let* ((cnf ((sat-fn "store_text" "pl>p") f n))
		    (chars ((sat-fn "text_chars" "p>p") cnf))
		    (clen ((sat-fn "text_length" "p>l") cnf))
		    (text ((sat-fn "sat_proof_text" "p>p") s))
		    (len ((sat-fn "sat_proof_length" "p>l") s)))
	       (or (= 1 ((sat-fn "drat_check_text" "plpl>l") chars clen text len))
		   (error "E_PROOF: the refutation's proof fails at line "
			  ((sat-fn "drat_failed_line" ">l"))
			  "; the formula is "
			  (sat-keep (sat-c-string chars clen) ".cnf")
			  " and the proof "
			  (sat-keep (sat-c-string text len) ".drat")))
	       ((sat-fn "text_free" "p") cnf)
	       (set out (if keep (cons 'unsat (sat-c-string text len)) (list 'unsat)))))
	    (else (set out (list 'unknown)))))
    (sat-release s)
    out))
(define-function sat-decide-clean (n clauses . keep)	; clauses already as sat-clean leaves them
  (let ((f ((sat-fn "store_new" ">p")))
	(emit (sat-fn "store_lit" "pl")))
    (list-do c clauses
      (list-do l c (emit f l))
      (emit f 0))
    (let ((out (apply sat-decide-store (cons n (cons f keep)))))
      ((sat-fn "store_free" "p") f)
      out)))
(define-function sat-decide (n given . keep)
  (apply sat-decide-clean (cons n (cons (sat-clean given) keep))))
