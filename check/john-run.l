;;; john-eval.l runs JOHN programs: Towers of Hanoi with 2 and 3 disks solved in the fewest
;;; moves by searching possible worlds, qualifications clause by clause, quantifiers over a
;;; class's instances, and an unknown name as an error; the memos' x86 allocator, its
;;; optimizations choosing the actions and arguments, to a valid allocation; heuristics
;;; committing a search every max-time-ahead levels, and minimax in a two-player game; and,
;;; ours, merge-worlds dropping a world whose state was reached before; time: at time t E in
;;; the past and over the possible futures, and McCarthy's airline, read from its history.  "program TEXT"
;;; runs TEXT in a child, and "puzzle" the puzzle allocator asked to satisfy its goal.
(require "john-eval.l")
(require "check/john-allocation.l")
(require "check/temp.l")

(require "spawn.l")
(define ok 1)
(define-function expect (what c) (or c (let () (set ok ()) (println "FAIL " what))))
(define-function has? (str sub)
  (let ((i 0) (n (- (string-length str) (string-length sub))))
    (while (and (<= i n) (not (= sub (string-copy str i (string-length sub))))) (incr i))
    (<= i n)))
(define-function last (l) (if (cdr l) (last (cdr l)) (car l)))
(define-function run-text (text) (john-run (john-read-text text)))
(define-function child-mode (args)	; output and errors of this file run in a child with args, a list
  (program-output (concat-list '("./eval" "check/john-run.l") args)))
(define-function child (text) (child-mode (list "program" text)))

(define trap "create Square near blocked. create Robot position.
  make Square S 2 yes. make Square D 1 no. make Square M 2 no. make Square G 0 no. make Robot R S.
  rel-qualify Square:A next Square:B if (A = S and (B = D or B = M)) or (A = M and B = G).
  action Robot move Square consequence its position = Square and Square blocked = yes.
  rule Robot move is Square blocked = no. rule Robot move is its position next Square.
  goal Robot reach try its position = G. heuristic Robot reach 1 minimize its position near. ")
(define nim "create Game pile turn. create Player opponent. make Player White Black. make Player Black White.
  action Player take1 consequence G pile = G pile - 1 and G turn = its opponent.
  rule Player take1 is G turn = it. rule Player take1 is G pile >= 1.
  action Player take2 consequence G pile = G pile - 2 and G turn = its opponent.
  rule Player take2 is G turn = it. rule Player take2 is G pile >= 2.
  goal Player win try G pile = 0 and G turn = its opponent.
  heuristic Player win 1 minimize G pile. ")
(define-function no-satisfy (fs) (let ((out ())) (list-do f fs (or (= 'satisfy (car f)) (push out f))) (list-reverse! out)))
(define-function hanoi (f opts) (john-run (concat-list (no-satisfy (john-read f)) (concat-list opts '((satisfy Hanoi win () () ()))))))
(define-function airline (text) (john-run (concat-list (john-read "check/john/airline.john") (john-read-text text))))
(define-function maze (more) (john-run (concat-list (john-read "check/john/maze.john") more)))

;; is: the same value, or one of a kind; a qualification's is gives that value
(define is-program
  (concat-strings
    "set E = none | ran(at) | good(at, n). group Fine good none. group Thing P Q. "
    "create P e f x. create Q y. make P A ran(at: \"t\") ran(at: \"t\") 3. make P B none good(at: \"t\", n: 1) 4. make Q C 1. "
    "qualify P same-as: o is its e = o e. qualify P latest is its e. "))
(define-function is-says (question answer)
  (expect (concat-strings "is " question "? " answer)
	  (equal (list answer) (run-text (concat-strings is-program "is " question "?")))))
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
  (expect "at: below 1 is an error" (has? (child "[ 1, 2 ] at: 0.") "at: 0 is below 1"))
  ;; a program loads Maru files, and its objects and values answer the messages they define
  (let ((out (run-text "load \"check/john-message.l\". create Source text. make Source S \"1 + f(2)\". qualify Source valid is (it text-of) parses-as-c. make Source B \"1 +\". 21 doubled. S valid. B valid.")))
    (expect "a message from a loaded file" (= "42" (car out)))
    (expect "an object asks a grammar" (and (= "yes" (cadr out)) (= "no" (caddr out)))))
  (expect "a message nothing defines stays an error" (has? (child "21 tripled.") "no property or qualification tripled"))
  ;; a goal says how it's solved, by the first strategy whose guard holds: the meaning stays the same
  (let* ((world "create C n. action C up consequence its n = its n + 1. goal C at-two try its n = 2. ")
	 (ask (lambda (text) (run-text (concat-strings "load \"check/john-message.l\". " world text " satisfy at-two.")))))
    (expect "the search by default" (has? (last (ask "make C X 0. X")) "X up , X up"))
    (expect "a named strategy" (has? (last (ask "make C X 0. goal-strategy C at-two sat. X")) "X up , X up"))
    (expect "the sat strategy ran" (has? (car (ask "make C X 0. goal-strategy C at-two sat. X")) "trying 0 steps"))
    (expect "a loaded file's strategy" (= "gave up" (last (ask "make C X 0. goal-strategy C at-two give-up. X"))))
    (expect "the first whose guard holds, by the data"
	    (= "gave up" (last (ask "make C X 0. goal-strategy C at-two sat if its n > 5. goal-strategy C at-two give-up if its n < 5. X"))))
    (expect "the planner option when no guard holds"
	    (has? (car (ask "make C X 0. set-opt planner sat. goal-strategy C at-two give-up if its n > 5. X")) "trying 0 steps")))
  (expect "an unknown planner is an error, not a quiet search"
	  (has? (child "create C n. make C X 0. goal C g try its n = 0. set-opt planner telepathy. X satisfy g.") "no strategy telepathy"))
  (expect "a strategy for a goal nothing defines is an error"
	  (has? (child "create C n. make C X 0. goal C g try its n = 0. goal-strategy C typo sat. X satisfy g.") "goal-strategy for no goal: typo"))
  (expect "an unknown strategy is an error"
	  (has? (child "create C n. make C X 0. goal C g try its n = 0. goal-strategy C g telepathy. X satisfy g.") "no strategy telepathy"))
  ;; enumerated values: plain ones are names a typo can't be, and fields are read by name
  (let* ((world "set Result = untested | passed(tree, trials) | refuted(tree, seed). create C r. action C ran R consequence its r = R. make C X untested. ")
	 (ask (lambda (text) (last (run-text (concat-strings world text))))))
    (expect "a plain value" (= "yes" (ask "X r = untested.")))
    (expect "its kind" (= "untested" (ask "X r kind.")))
    (expect "a value with fields"
	    (= "passed(tree: abc, trials: 3)" (ask "X do ran passed(tree: \"abc\", trials: 3). X r.")))
    (expect "its field" (= "3" (ask "X do ran passed(tree: \"abc\", trials: 1 + 2). X r trials.")))
    (expect "its kind" (= "refuted" (ask "X do ran refuted(seed: 7, tree: \"t\"). X r kind.")))
    (expect "the same by what it holds"
	    (= "yes" (ask "X do ran passed(tree: \"a\", trials: 1). X r = passed(trials: 1, tree: \"a\").")))
    (expect "different by what it holds"
	    (= "no" (ask "X do ran passed(tree: \"a\", trials: 1). X r = passed(tree: \"a\", trials: 2).")))
    (expect "different by kind"
	    (= "no" (ask "X do ran passed(tree: \"a\", trials: 1). X r = refuted(tree: \"a\", seed: 1).")))
    (expect "a world keeps the value it was given"
	    (= "untested" (ask "X do ran passed(tree: \"a\", trials: 1). at time 0 X r kind.")))
    (expect "a set's values can have qualifications"
	    (= "yes" (ask "qualify Result good if its kind = passed. X do ran passed(tree: \"a\", trials: 1). X r good."))))
  (let ((world "set Result = untested | passed(tree). create C r. make C X untested. "))
    (expect "a typo of a plain value is an error" (has? (child (concat-strings world "X r = untseted.")) "unknown name: untseted"))
    (expect "a field it doesn't have" (has? (child (concat-strings world "passed(tree: 1) seed.")) "no property or qualification seed"))
    (expect "a field a value can't be given" (has? (child (concat-strings world "passed(tree: 1, seed: 2).")) "passed has no field seed"))
    (expect "a field left out" (has? (child (concat-strings world "passed(tree: 1) = 1. passed(tree: 2) tree. passed(x: 1)."))
				     "passed has no field x"))
    (expect "a value missing its field" (has? (child (concat-strings world "set Other = both(a, b). both(a: 1)."))
					      "both needs its field b"))
    (expect "a bare name is its kind" (= "yes" (last (run-text (concat-strings world "passed(tree: 1) kind = passed.")))))
    (expect "a value against a bare name is an error, not a quiet no"
	    (has? (child (concat-strings world "passed(tree: 1) = passed.")) "compare its kind"))
    (expect "and the other way round" (has? (child (concat-strings world "passed = passed(tree: 1).")) "compare its kind"))
    (expect "yes, no and empty are still words" (= "yes" (last (run-text "create C r. make C X no. X r = no."))))
    (expect "a value of no set" (has? (child (concat-strings world "other(a: 1).")) "no such value: other")))
  ;; time before the first world is an error when read, and an empty stretch of a window that reaches there
  (expect "at time before the first world" (has? (child "start-world w. create A p. make A X 1. at time (time - 1) X p.") "before the first world"))
  (expect "a window reaching before the first world" (has? (child "start-world w. create A p. action A go consequence its p = 2. make A X 1. X do go. for some time T after (time - 9) up to time do (at time T X p = 2).") "yes"))
  (expect "to: a negative length is an error" (has? (child "[ 1 ] to: -1.") "to: -1 is a negative length"))
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
  (expect "the x86 allocation fills each live range, slot by slot" (john-allocation-fits?))
  ;; the memo's puzzle goal reads live-vars, a name, where each live-vars is meant
  (expect "the puzzle allocator's goal names nothing" (has? (child-mode '("puzzle")) "unknown name: live-vars"))
  ;; RN-2008-003 section 10: past max-time-ahead levels the best-scoring world's next move is
  ;; certain and every other branch is dropped; same path here, fewer worlds looked at
  (expect "the maze, breadth first" (equal (maze '((satisfy R reach () () ())))
    '("looking 1 time unit ahead (2 possible worlds)" "looking 2 time unit ahead (3 possible worlds)"
      "looking 3 time unit ahead (8 possible worlds)" "looking 4 time unit ahead (13 possible worlds)"
      "looking 5 time unit ahead (25 possible worlds)" "looking 6 time unit ahead (33 possible worlds)"
      "satisfied at time: 6" "satisfied by: [ R move B1 , R move B2 , R move C2 , R move C3 , R move C4 , R move D4 ]")))
  (expect "the maze, two levels ahead" (equal (maze '((set-opt max-time-ahead 2) (satisfy R reach () () ())))
    '("looking 1 time unit ahead (2 possible worlds)" "looking 2 time unit ahead (3 possible worlds)" "certain: R move B1"
      "looking 3 time unit ahead (3 possible worlds)" "looking 4 time unit ahead (5 possible worlds)" "certain: R move B2"
      "looking 5 time unit ahead (10 possible worlds)" "looking 6 time unit ahead (13 possible worlds)"
      "satisfied at time: 6" "satisfied by: [ R move B1 , R move B2 , R move C2 , R move C3 , R move C4 , R move D4 ]")))
  ;; and pruning is incomplete, as the memo says: a dead end that scores better is committed to
  (expect "a trap, breadth first" (equal (last (run-text (concat-string trap "R satisfy reach."))) "satisfied by: [ R move M , R move G ]"))
  (expect "a trap, one level ahead" (equal (run-text (concat-string trap "set-opt max-time-ahead 1. R satisfy reach."))
					    '("looking 1 time unit ahead (2 possible worlds)" "certain: R move D" "unsatisfiable")))
  ;; section 12: in a two-player game the opponent makes only its best-scoring replies.  Nim, take 1
  ;; or 2, the last stick wins: from 3 White wins only if Black blunders, from 4 always
  (expect "nim from 3, Black blundering" (equal (last (run-text (concat-string nim "make Game G 3 White. White satisfy win.")))
						 "satisfied by: [ White take1 , Black take1 , White take1 ]"))
  (expect "nim from 3, Black at its best" (equal (last (run-text (concat-string nim "make Game G 3 White. set-opt two-player-game [ White, Black ]. White satisfy win.")))
						  "unsatisfiable"))
  (expect "nim from 4, Black at its best" (equal (last (run-text (concat-string nim "make Game G 4 White. set-opt two-player-game [ White, Black ]. White satisfy win.")))
						  "satisfied by: [ White take1 , Black take2 , White take1 ]"))
  ;; time-limit (ours): satisfy looks this many steps ahead, 16 unless set, for this program only
  (let ((count "create Counter n. make Counter K 0. action Counter up consequence its n = its n + 1.
		goal Counter twenty try its n = 20. "))
    (expect "past the default limit" (equal (last (run-text (concat-string count "K satisfy twenty.")))
					    "not satisfied within the time limit"))
    (expect "a time limit reaches it" (member? "satisfied at time: 20"
					       (run-text (concat-string count "set-opt time-limit 25. K satisfy twenty."))))
    (expect "the limit is the program's own" (equal (last (run-text (concat-string count "K satisfy twenty.")))
						    "not satisfied within the time limit")))
  ;; merge-worlds (ours, G12): a state reached before is not searched again, so Hanoi3 looks at 8
  ;; worlds at its last level instead of 1086, and Hanoi4 (15 moves) is in reach; plans stay shortest
  (let ((lines (hanoi "check/john/hanoi3.john" '((set-opt merge-worlds yes)))))
    (expect "Hanoi3 merged" (and (member? "looking 7 time unit ahead (8 possible worlds)" lines)
				  (equal (last lines) "satisfied by: [ A move Peg3 , B move Peg2 , A move B , C move Peg3 , A move Peg1 , B move C , A move B ]"))))
  (expect "Hanoi4 merged, in 15 moves" (equal (last (hanoi "check/john/hanoi4-ours.john" '((set-opt merge-worlds yes))))
    "satisfied by: [ A move Peg2 , B move Peg3 , A move B , C move Peg2 , A move D , B move C , A move B , D move Peg3 , A move D , B move Peg1 , A move B , C move D , A move Peg2 , B move C , A move B ]"))
  ;; a commit forgets the states seen on the branches it drops: L, first reached on the dropped branch,
  ;; is the only way on from R
  (expect "a commit forgets dropped states"
    (equal (run-text "create Spot dist. create Robot position.
		       make Spot S 3. make Spot L 2. make Spot R 1. make Spot G 0. make Robot Bot S.
		       rel-qualify Spot:A link Spot:B if (A = S and (B = L or B = R)) or (A = R and (B = S or B = L))
			 or (A = L and (B = S or B = R or B = G)).
		       action Robot move Spot consequence its position = Spot. rule Robot move is its position link Spot.
		       goal Robot reach try its position = G. heuristic Robot reach 1 minimize its position dist.
		       set-opt merge-worlds yes. set-opt max-time-ahead 1. Bot satisfy reach.")
	   '("looking 1 time unit ahead (2 possible worlds)" "certain: Bot move R" "looking 2 time unit ahead (2 possible worlds)"
	     "certain: Bot move L" "looking 3 time unit ahead (3 possible worlds)" "satisfied at time: 3"
	     "satisfied by: [ Bot move R , Bot move L , Bot move G ]")))
  (expect "the maze merged, two levels ahead" (equal (last (maze '((set-opt merge-worlds yes) (set-opt max-time-ahead 2) (satisfy R reach () () ()))))
    "satisfied by: [ R move B1 , R move B2 , R move C2 , R move C3 , R move C4 , R move D4 ]"))
  ;; RN-2008-003 section 4: the world at an earlier time answers for it, and a later time has the
  ;; values over every possible world that far ahead
  (expect "time in the maze" (equal (maze (john-read-text "time. at time 1 R position. at time 3 R position.
							       R satisfy reach. time. at time 1 R position. at time 4 R position."))
    '("0" "Possible World values (1 time unit from now):" "{ B1, A2 }"
      "Possible World values (3 time unit from now):" "{ A2, C2, B3, B1, A4 }"
      "looking 1 time unit ahead (2 possible worlds)" "looking 2 time unit ahead (3 possible worlds)"
      "looking 3 time unit ahead (8 possible worlds)" "looking 4 time unit ahead (13 possible worlds)"
      "looking 5 time unit ahead (25 possible worlds)" "looking 6 time unit ahead (33 possible worlds)"
      "satisfied at time: 6" "satisfied by: [ R move B1 , R move B2 , R move C2 , R move C3 , R move C4 , R move D4 ]"
      "6" "B1" "C3")))
  ;; Elephant's airline (ours): no record of reservations, only the events.  A request made when the
  ;; flight was full is forgotten; a cancelled reservation frees its seat
  (expect "the airline" (equal (airline "P1 do reserve. P2 do reserve. P3 do reserve.
					  P1 has-reservation. P2 has-reservation. P3 has-reservation. F booked.
					  P1 do cancel. P3 has-reservation. F booked.
					  P3 do reserve. P3 has-reservation. F booked. P1 has-reservation.
					  P1 do reserve. P1 has-reservation.
					  at time 2 P2 has-reservation. at time 4 P1 has-reservation. time.")
			       '("yes" "yes" "no" "2" "no" "1" "yes" "2" "no" "no" "yes" "no" "6")))
  ;; an expression reads only the past: Elephant's futuristic reference is a goal for satisfy
  (expect "a future time in an expression" (has? (child "create C a. make C X 1. qualify C later if at time 5 it a = 1. X later.")
						 "at time 5: an expression reads only the past"))
  (expect "a future time in a quantifier" (has? (child "create C a. make C X 1. qualify C ever if for some time T up to 3 do it a = 1. X ever.")
						"time 3 is later than now"))
  (expect "a field can't hide kind" (has? (child "set E = a(kind). create P e. make P A a(kind: 5).") "every value answers kind"))
  (expect "a set names a field once" (has? (child "set E = a(x, x). create P e. make P A a(x: 1, x: 2).") "names its field x twice"))
  (expect "a value is given a field once" (has? (child "set E = a(x). create P e. make P A a(x: 1, x: 2).") "given its field x twice"))
  (is-says "A e is ran" "yes")
  (is-says "A e is good" "no")
  (is-says "B e is none" "yes")
  (is-says "A e is E" "yes")
  (is-says "B f is Fine" "yes")
  (is-says "A e is Fine" "no")
  (is-says "A is P" "yes")
  (is-says "A is Thing" "yes")
  (is-says "C is P" "no")
  (is-says "A is A" "yes")
  (is-says "A is B" "no")
  (is-says "3 is Number" "yes")
  (is-says "A e is A f" "yes")
  (is-says "B e is B f" "no")
  (is-says "B f is good(at: \"t\", n: 1)" "yes")
  (is-says "B f is good(at: \"t\", n: 2)" "no")
  (is-says "A latest is ran" "yes")
  (and ok (println "john run ok")))

(if (not *arguments*) (suite)
  (if (= "puzzle" (next-argument))
      (println (john-run (concat-list (john-read "check/john/puzzle-allocator.john") '((satisfy Al done () () ())))))
    (println (run-text (next-argument)))))
