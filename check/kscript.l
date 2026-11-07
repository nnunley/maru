;;; kscript.g reads every KScript listing transcribed from TR-2012-001 (the arguments), and
;;; kscript.l runs streams tick by tick: fby, lag, when, undefined, and a selector on a box.
(require "kscript.l")

(define ok 1)
(define-function expect (what got want)
  (or (equal got want)
      (let () (set ok ()) (println "FAIL " what ": got " got ", want " want))))

(define-function box-of (source)
  (let ((box (new <ks-object> 'KSBox 1 () () () 0)))
    (list-do st (kscript-parse source) (ks-eval st () box))
    box))

;; a stream's value at each of ticks logical times
(define-function ticks (source name n)
  (let ((box (box-of source))
	(ev (ks-evaluator-new))
	(out ()))
    (ks-evaluator-add-from ev box)
    (for (t 0 n)
      (ks-sort-and-evaluate-at ev t)
      (push out (ks-val box name)))
    (list-reverse! out)))

(let ((n 0))
  (while *arguments*
    (kscript-read (next-argument))
    (incr n))
  (expect "listings read" n 39))

(expect "a stream, its lag and fby"
	(kscript-parse "nat <- 0 fby nat' + 1")
	'((stream-def nat (fby 0 (+ (lag nat) 1) ()))))

;; a primed name isn't a dependency: with no trigger, nat "would never update"
(expect "nat with no trigger" (ticks "nat <- 0 fby nat' + 1" 'nat 5) '(0 0 0 0 0))

;; mutual references, each through a lag (the report's a and b)
(let ((source "timer <- timerE(1)
a <- true fby when timer then b'
b <- false fby when timer then a'
"))
  (expect "a" (ticks source 'a 5) '(true false true false true))
  (expect "b" (ticks source 'b 5) '(false true false true false)))

;; undefined stops a change propagating, and the stream keeps its value (the report's stopper)
(let ((source "myTimer <- timerE(1)
stopper <- if myTimer > 2 then undefined else myTimer
viewer <- stopper * 10
"))
  (expect "stopper" (ticks source 'stopper 5) '(0 1 2 2 2))
  (expect "viewer" (ticks source 'viewer 5) '(0 10 20 20 20)))

;; mergeE takes the stream that fired, not one holding an older value
(expect "mergeE"
	(ticks "even <- timerE(2)
odd <- when timerE(1) then 100
m <- mergeE(even, odd)
" 'm 4)
	'(0 100 2 100))

;; a when that doesn't fire is undefined, and the stream keeps its value
(expect "when holds between events"
	(ticks "t <- timerE(2)
c <- 0 fby when t then c' + 1
" 'c 5)
	'(0 0 1 1 2))

(expect "a long equals a double" (ks-eval (car (kscript-parse "1 == 1.0")) () ()) 'true)

(let ((box (box-of "")))
  (ks-set-val box 'bounds (ks-rect 1 2 3 4))
  (let ((p (ks-eval (car (kscript-parse "this.topLeft()")) () box)))
    (expect "a box's topLeft" (list (<ks-point>-x p) (<ks-point>-y p)) '(1 2))))

;; for over a range by a step
(expect "for by" (ks-val (box-of "total := 0
for i in [0...10] by 5 total := total + i
") 'total) 15)

;; true, false and nil have kinds of their own (True, False, UndefinedObject), and answer what they answered as text
(expect "true, false and nil as booleans and text"
	(list (ks-send 'true 'asBoolean () () ()) (ks-send 'false 'asBoolean () () ()) (ks-send 'nil 'asBoolean () () ())
	      (ks-send 'true 'printString () () ()) (ks-send 'false 'asString () () ()))
	'(true false false "true" "false"))

;; KScript's lists are Maru arrays (one representation with Smalltalk's Arrays): a literal, a range and a comprehension
;; each make one, counted from 0 by an index, and an empty one is a collection, true as a test, never nil or false
(define-function ks-run (text) (ks-stream-curr (ks-eval (car (kscript-parse text)) () ())))
(let ((a (ks-run "[1, 2, 3]")))
  (expect "a literal is an array" (and (array? a) (array->list a)) '(1 2 3)))
(expect "a range is an array" (let ((a (ks-run "[1...3]"))) (and (array? a) (array->list a))) '(1 2 3))
(expect "a comprehension is an array" (let ((a (ks-run "[x * 2 for x in [1, 2, 3] when x > 1]"))) (and (array? a) (array->list a))) '(4 6))
(expect "an index counts from 0" (ks-run "[10, 20, 30][1]") 20)
(expect "an empty array: size 0, isEmpty, and true as a test"
	(list (ks-run "[].size()") (ks-truthy? (ks-run "[].isEmpty()")) (ks-run "if [] then 1 else 2") (ks-run "if nil then 1 else 2"))
	'(0 t 1 2))
(expect "for, a comprehension and a detect over an array"
	(list (ks-val (box-of "total := 0\nfor i in [1, 2, 3] total := total + i\n") 'total) (ks-run "(x in [1, 2, 3] when x > 1)"))
	'(6 2))
(expect "first, second, copy and sort of an array"
	(list (ks-run "[3, 1, 2].first()") (ks-run "[3, 1, 2].second()") (array->list (ks-run "[3, 1, 2].copy()")) (array->list (ks-run "[3, 1, 2].sort()")))
	'(3 1 (3 1 2) (1 2 3)))

(and ok (println "kscript ok"))
