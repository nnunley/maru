;;; john-eval.l runs JOHN programs: Towers of Hanoi with 2 and 3 disks solved in the fewest
;;; moves by searching possible worlds, qualifications clause by clause, quantifiers over a
;;; class's instances, and an unknown name as an error.  "program TEXT" runs TEXT in a child.
(require "john-eval.l")

(define system (subr "system" "s"))
(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))
(define-function last (l) (if (cdr l) (last (cdr l)) (car l)))
(define-function run-text (text) (john-run (john-read-text text)))
(define-function child (text)	; a program's output and errors, run in a child process
  (system "mkdir -p /tmp/maru-check")
  (system (concat-strings "./eval check/john-run.l program '" text "' >/tmp/maru-check/john-run.out 2>&1"))
  (contents-of-file-named "/tmp/maru-check/john-run.out"))

(define-function suite ()
  (expect "Hanoi2 in 3 moves"
    (equal (john-run-file "check/john/hanoi2.john")
	   '("looking 1 time unit ahead (2 possible worlds)" "looking 2 time unit ahead (6 possible worlds)"
	     "looking 3 time unit ahead (16 possible worlds)" "satisfied at time: 3"
	     "satisfied by: [ A move Peg2 , B move Peg3 , A move B ]")))
  (expect "Hanoi3 in 7 moves"
    (equal (last (john-run-file "check/john/hanoi3.john"))
	   "satisfied by: [ A move Peg3 , B move Peg2 , A move B , C move Peg3 , A move Peg1 , B move C , A move B ]"))
  ;; RN-2008-003's meaning of sort: the first clause whose guard holds gives the value
  (expect "sorted" (equal (run-text "qualify List sorted if its size < 2.
				     qualify List sorted if its first <= its second and its rest sorted = yes.
				     [ 1, 2, 3 ] sorted. [ 2, 1 ] sorted. [ ] sorted.")
			  '("yes" "no" "yes")))
  ;; a class is its instances where a collection is expected, created before or after
  (expect "quantifiers" (equal (run-text "create C. make C X. make C Y. for every C do each = X. for some C do each = Y.
					  for any [ 1, 2 ] do each = 3. select all C by which = Y.")
			       '("no" "yes" "no" "[ Y ]")))
  ;; every effect reads the world the action starts in (M-2009-001 Table 15: Time1 in, Time2 out)
  (expect "a swap" (equal (run-text "create P a b. make P X 1 2.
				    action P swap consequence it a = its b and it b = its a.
				    goal P done try its a = 2 and its b = 1. X satisfy done.")
			  '("looking 1 time unit ahead (1 possible worlds)" "satisfied at time: 1" "satisfied by: [ X swap ]")))
  (expect "an unknown name is an error" (has? (child "nosuch.") "unknown name: nosuch"))
  (expect "an unknown property is an error" (has? (child "create C. make C X. X colour.") "no property or qualification colour of X"))
  (and ok (println "john run ok")))

(if *arguments* (let () (next-argument) (println (run-text (next-argument)))) (suite))
