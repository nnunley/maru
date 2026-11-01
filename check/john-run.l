;;; john-eval.l runs JOHN programs: Towers of Hanoi with 2 and 3 disks solved in the fewest
;;; moves by searching possible worlds, qualifications clause by clause, quantifiers over a
;;; class's instances, and an unknown name as an error; the memos' x86 allocator, its
;;; optimizations choosing the actions and arguments, to a valid allocation.  "program TEXT"
;;; runs TEXT in a child, and "puzzle" the puzzle allocator asked to satisfy its goal.
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
(define-function child-mode (args)	; output and errors of this file run in a child with args
  (system "mkdir -p /tmp/maru-check")
  (system (concat-strings "./eval check/john-run.l " args " >/tmp/maru-check/john-run.out 2>&1"))
  (contents-of-file-named "/tmp/maru-check/john-run.out"))
(define-function child (text) (child-mode (concat-strings "program '" text "'")))

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
  (expect "make gives every property a value" (has? (child "create C a b. make C X 1.") "make X: 2 properties, 1 values"))
;; lists count from 1; Word holds names that are not objects, so empty repeatn: works
  (expect "list operations" (equal (run-text "[ 1, 2, 3 ] at: 2. [ 1, 2, 3 ] to: 2. [ 1, 2, 3 ] from: 2. [ 1, 2, 3 ] last.
					      qualify Word repeatn: N [ ] if N = 0. qualify Word repeatn: N (its repeatn: (N - 1)) + it.
					      empty repeatn: 2.")
				   '("2" "[ 1, 2 ]" "[ 2, 3 ]" "3" "[ empty, empty ]")))
  (expect "the x86 allocator"
    (equal (john-run-file "check/john/x86-allocator.john")
	   '("looking 1 time unit ahead (4 possible worlds)" "looking 2 time unit ahead (4 possible worlds)"
	     "looking 3 time unit ahead (4 possible worlds)" "looking 4 time unit ahead (8 possible worlds)"
	     "looking 5 time unit ahead (12 possible worlds)" "looking 6 time unit ahead (12 possible worlds)"
	     "satisfied at time: 6"
	     "satisfied by: [ Al assign R1 Va , Al assign R3 VB , Al assign R2 Vc , Al assign R3 Vd , Al split R1 R4 , Al assign R1 VE ]")))
  ;; and the allocation is one: every slot from a variable's start to just before its end holds it in
  ;; one register (two for length 4, a register pair), and nowhere else does.  The memo's room check
  ;; reads only a range's two ends, so an assignment could overwrite a variable; this would catch it.
  (let ((slots (map (lambda (r) (john-eval (list 'send r 'allocations) *john-world* ())) '(R1 R2 R3 R4))) (fits 1))
    (list-do v '(Va VB Vc Vd VE)
      (let ((range (john-eval (list 'send v 'live-range) *john-world* ())) (want (/ (john-eval (list 'send v 'length) *john-world* ()) 2)))
	(for (i 1 13)
	  (let ((n 0) (inside (and (<= (car range) i) (< i (cadr range)))))
	    (list-do r slots (and (= v (john-builtin r 'at: (list i))) (set n (+ n 1))))
	    (or (= n (if inside want 0)) (let () (set fits ()) (println "slot " i " holds " v " " n " times")))))))
    (expect "the x86 allocation fills each live range, slot by slot" fits))
  ;; the memo's puzzle goal reads live-vars, a name, where each live-vars is meant
  (expect "the puzzle allocator's goal names nothing" (has? (child-mode "puzzle") "unknown name: live-vars"))
  (and ok (println "john run ok")))

(if (not *arguments*) (suite)
  (if (= "puzzle" (next-argument))
      (println (john-run (concat-list (john-read "check/john/puzzle-allocator.john") '((satisfy Al done () () ())))))
    (println (run-text (next-argument)))))
