;;; JOHN runs as a session (docs/rfc/draft-ndn-maru-john-session-00.md): statements entered one at a time into a
;;; knowledge base and a working memory, time moved only by steps, echo at the prompt (ok. and each step's
;;; mutations), a failed statement leaving the session as it was; and the REPL replaying RN-2008-003's transcripts.
(require "john-eval.l")
(require "check/temp.l")

(define ok 1)
(define-function expect (what got want)
  (or (equal got want) (let () (set ok ()) (print "FAIL " what ": got ") (dump got) (print ", want ") (dump want) (println))))
(define-function after (x l) (if l (if (equal x (car l)) (cdr l) (after x (cdr l))) ()))	; what follows x in l
(define-function enter (text)	; every line the statements of text answer, in order
  (let ((out ())) (list-do s (john-read-text text) (set out (concat-list out (john-enter s)))) out))
(define counter "create Counter n. make Counter C 0.
  action Counter bump consequence its n = its n + 1.
  goal Counter reach try its n = 2.")

;; R-session-enter, R-time-by-steps: declarations leave time at 0, a step moves it, and world 0 keeps the facts
(john-begin)
(expect "a declaration answers nothing in a file" (enter counter) ())
(expect "declarations don't move time" (enter "time.") '("0"))
(expect "a query answers its value" (enter "C n.") '("0"))
(enter "C do bump.")
(expect "a step moves time" (enter "time.") '("1"))
(expect "the step's value" (enter "C n.") '("1"))
(expect "world 0 keeps the facts declared before it" (enter "at time 0 C n.") '("0"))
(expect "a make after a step writes the current world" (enter "make Counter D 7. D n. time.") '("7" "1"))
(expect "john-run is a session fed a program" (john-run (john-read-text (concat-string counter " C do bump. C n. time."))) '("1" "1"))

;; R-echo: at the prompt a declaration answers ok., and a step what it changed
(john-begin)
(set *john-echo* 1)
(expect "a declaration answers ok." (enter "create Counter n.") '("ok."))
(enter "make Counter C 0. action Counter bump consequence its n = its n + 1. goal Counter reach try its n = 2.")
(expect "a step answers its mutations" (enter "C do bump.") '("time 1: C bump" "  C n = 1"))
(let ((out (enter "C satisfy reach.")))
  (expect "a satisfied goal answers each new step's mutations after its plan"
	  (and (member? "satisfied by: [ C bump , C bump ]" out) 1) 1)
  (expect "only the steps the search took" (after "satisfied by: [ C bump , C bump ]" out) '("time 2: C bump" "  C n = 2")))

;; R-failed-statement: an error is answered, and the session is as it was before the statement
(john-begin)
(set *john-echo* 1)
(enter counter)
(expect "an error is answered by name" (enter "C do fly.") '("john: C has no action fly"))
(expect "a make that fails leaves no object" (car (enter "make Counter D 1 2.")) "john: make D: 1 properties, 2 values")
(expect "nothing of it stays" (enter "D n.") '("john: unknown name: D"))
(expect "time didn't move" (enter "time.") '("0"))
(set *john-echo* ())

;; a for whose body is a make declares, so it answers ok.
(john-begin)
(set *john-echo* 1)
(expect "a for that makes answers ok." (enter "create Var n. for [ [ \"X1\" name ], [ \"X2\" name ] ] do make Var (each first) 0.") '("ok." "ok."))
(expect "and its objects are made" (enter "X2 n.") '("0"))
(set *john-echo* ())

;; RN-2008-003 §14: all is a set, and one-from its one element
(john-begin)
(enter "create block col row.
  make block A1 A 1. make block A2 A 2. make block A3 A 3. make block B1 B 1. make block B2 B 2. make block B3 B 3.
  qualify block top-neighbor one-from select all block by which row = its row + 1 and which col = its col.")
(expect "all block is a set" (enter "all block.") '("{ A1, A2, A3, B1, B2, B3 }"))
(expect "one-from answers the one element" (enter "B2 top-neighbor.") '("B3"))

;; R-repl: each transcript's statements piped to the REPL answer what the transcript says.  grid.session is RN-2008-003
;; §14's nine blocks with one departure: the memo's top-neighbor has which row = its row - 1 yet answers B3 for B2, so
;; it is written row + 1 here, which gives the answer the memo prints
(define system (subr "system" "s>i"))
(define-function starts? (s p) (and (<= (string-length p) (string-length s)) (= p (string-copy s 0 (string-length p)))))
(define-function file-lines (path)	; its lines, each without its newline
  (let ((out ()) (start 0) (text (or (contents-of-file-named path) "")))
    (for (i 0 (string-length text))
      (and (= ?\n (string-at text i)) (let () (push out (string-copy text start (- i start))) (set start (+ i 1)))))
    (list-reverse! out)))
(list-do name '("opponent" "grid" "counter" "errors")
  (let* ((session (concat-strings "check/john/" name ".session"))
	 (in (concat-strings check-tmp "/" name ".in")) (out (concat-strings check-tmp "/" name ".out"))
	 (inputs ()) (want ()))
    (list-do l (file-lines session) (if (starts? l "> ") (push inputs (string-copy l 2 (- (string-length l) 2))) (push want l)))
    (let ((f ((subr "fopen" "ss>p") in "w")))
      (list-do l (list-reverse! inputs) ((subr "fputs" "sp>i") (concat-string l "\n") f))
      ((subr "fclose" "p>i") f))
    (system (concat-strings "./eval john-repl.l < " in " > " out " 2>&1"))
    (expect (concat-string "transcript " name) (file-lines out) (list-reverse! want))))


;; blank lines after the last statement are no unfinished statement
(let ((in (concat-string check-tmp "/blank.in")) (out (concat-string check-tmp "/blank.out")))
  (let ((f ((subr "fopen" "ss>p") in "w"))) ((subr "fputs" "sp>i") "create C n.\n\n  \n" f) ((subr "fclose" "p>i") f))
  (system (concat-strings "./eval john-repl.l < " in " > " out " 2>&1"))
  (expect "trailing blank lines" (file-lines out) '("ok.")))
;; a relation one file declares, another file and the prompt use
(let ((a (concat-string check-tmp "/rel-a.john")) (b (concat-string check-tmp "/rel-b.john"))
      (in (concat-string check-tmp "/rel.in")) (out (concat-string check-tmp "/rel.out")))
  (let ((f ((subr "fopen" "ss>p") a "w")))
    ((subr "fputs" "sp>i") "create Box size. make Box S 1. make Box L 2.\nrel-qualify Box:A smaller Box:B if A size < B size.\n" f)
    ((subr "fclose" "p>i") f))
  (let ((f ((subr "fopen" "ss>p") b "w"))) ((subr "fputs" "sp>i") "qualify Box tiny if it smaller L.\n" f) ((subr "fclose" "p>i") f))
  (let ((f ((subr "fopen" "ss>p") in "w"))) ((subr "fputs" "sp>i") "S tiny.\nS smaller L.\n" f) ((subr "fclose" "p>i") f))
  (system (concat-strings "./eval john-repl.l " a " " b " < " in " > " out " 2>&1"))
  (expect "relations carry across files and to the prompt" (file-lines out) '("yes" "yes")))
;; recover.l loaded before john-eval.l keeps its try
(let ((script (concat-string check-tmp "/order.l")) (out (concat-string check-tmp "/order.out")))
  (let ((f ((subr "fopen" "ss>p") script "w")))
    ((subr "fputs" "sp>i") "(require \"recover.l\") (require \"john-eval.l\") (john-begin) (set *john-echo* 1)
(list-do s (john-read-text \"create C n. C fly.\") (list-do l (john-enter s) (println l)))\n" f)
    ((subr "fclose" "p>i") f))
  (system (concat-strings "./eval " script " > " out " 2>&1"))
  (expect "recover.l first, then john-eval.l" (file-lines out) '("ok." "john: no property or qualification fly of C")))

(if ok (println "john session ok") (exit 1))
