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
